rootless_docker_ensure_subids() {
  local account="$1"

  /usr/bin/python3 - "$account" <<'PY'
import fcntl
import grp
import os
import pwd
import stat
import subprocess
import sys


MAX_ID = 4294967295
MIN_RANGE = 65536


def read_ranges(path):
    ranges = []
    try:
        with open(path, encoding="utf-8") as source:
            for number, line in enumerate(source, 1):
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                try:
                    name, start, count = line.split(":")
                    start, count = int(start), int(count)
                except ValueError as error:
                    raise SystemExit(f"cannot parse {path}:{number}") from error
                if start < 0 or count <= 0 or start + count - 1 > MAX_ID:
                    raise SystemExit(f"invalid subordinate-ID range in {path}:{number}")
                ranges.append((name, start, count))
    except FileNotFoundError:
        pass
    return ranges


def ranges_overlap(first_start, first_count, second_start, second_count):
    return max(first_start, second_start) < min(
        first_start + first_count, second_start + second_count
    )


def validate_ranges(path, ranges, assigned_ids):
    for index, (name, start, count) in enumerate(ranges):
        if any(start <= assigned < start + count for assigned in assigned_ids):
            raise SystemExit(f"subordinate-ID range for {name} intersects a host identity in {path}")
        if any(index != other_index and
               ranges_overlap(start, count, other_start, other_count)
               for other_index, (_other_name, other_start, other_count) in enumerate(ranges)):
            raise SystemExit(f"overlapping subordinate-ID ranges in {path}")


def owned_ranges(account, ranges):
    identities = {account.pw_name, str(account.pw_uid)}
    return [(start, count) for name, start, count in ranges if name in identities]


def discovered_accounts(account, ranges):
    accounts = {(account.pw_name, account.pw_uid): account}
    for entry in pwd.getpwall():
        accounts[(entry.pw_name, entry.pw_uid)] = entry
    for owner, _start, _count in ranges:
        try:
            entry = pwd.getpwnam(owner)
            accounts[(entry.pw_name, entry.pw_uid)] = entry
        except KeyError:
            pass
        if owner.isdecimal():
            try:
                entry = pwd.getpwuid(int(owner))
                accounts[(entry.pw_name, entry.pw_uid)] = entry
            except KeyError:
                pass
    return accounts.values()


def assigned_uids(account, ranges):
    return {0, *(entry.pw_uid for entry in discovered_accounts(account, ranges))}


def assigned_gids(account, ranges):
    assigned = {0, *(entry.gr_gid for entry in grp.getgrall())}
    for entry in discovered_accounts(account, ranges):
        assigned.add(entry.pw_gid)
        assigned.update(os.getgrouplist(entry.pw_name, entry.pw_gid))
    return assigned


def include_ranges_from(ranges, other_path):
    return [*ranges, *read_ranges(other_path)]


def available_range(ranges, assigned_ids):
    blocked = [(start, start + count - 1) for _name, start, count in ranges]
    blocked.extend((assigned, assigned) for assigned in assigned_ids if 0 <= assigned <= MAX_ID)
    candidate = 100000
    for blocked_start, blocked_end in sorted(blocked):
        if blocked_end < candidate:
            continue
        if blocked_start >= candidate + MIN_RANGE:
            break
        candidate = blocked_end + 1
        if candidate + MIN_RANGE - 1 > MAX_ID:
            raise SystemExit("no subordinate-ID range is available")
    return candidate, candidate + MIN_RANGE - 1


def ensure_range(account, path, option, assigned_ids, usermod="/usr/bin/usermod"):
    ranges = read_ranges(path)
    assigned = set(assigned_ids(ranges))
    validate_ranges(path, ranges, assigned)
    owned = owned_ranges(account, ranges)
    if any(count >= MIN_RANGE for _start, count in owned):
        return

    start, end = available_range(ranges, assigned)
    subprocess.run([usermod, option, f"{start}-{end}", account.pw_name], check=True)
    updated = read_ranges(path)
    validate_ranges(path, updated, set(assigned_ids(updated)))
    owned = owned_ranges(account, updated)
    if not any(count >= MIN_RANGE for _start, count in owned):
        raise SystemExit(f"could not verify subordinate-ID allocation for {account.pw_name} in {path}")


def main():
    account = pwd.getpwnam(sys.argv[1])
    if account.pw_uid == 0:
        raise SystemExit("rootless Docker cannot be configured for root")

    lock_path = "/run/lock/omarchy-rootless-docker-subids.lock"
    fd = os.open(lock_path, os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600)
    with os.fdopen(fd, "w") as lock:
        metadata = os.fstat(lock.fileno())
        if not stat.S_ISREG(metadata.st_mode) or metadata.st_uid != 0 or metadata.st_mode & 0o022:
            raise SystemExit(f"unsafe subordinate-ID lock: {lock_path}")
        fcntl.flock(lock, fcntl.LOCK_EX)

        ensure_range(account, "/etc/subuid", "--add-subuids",
                     lambda ranges: assigned_uids(
                         account, include_ranges_from(ranges, "/etc/subgid")
                     ))
        ensure_range(account, "/etc/subgid", "--add-subgids",
                     lambda ranges: assigned_gids(
                         account, include_ranges_from(ranges, "/etc/subuid")
                     ))


main()
PY
}
