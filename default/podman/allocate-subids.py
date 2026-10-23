"""Allocate local subordinate IDs without granting existing host identities."""

import fcntl
import grp
import os
import pwd
import subprocess
import sys

COUNT = 65536
MAX_ID = 2**32 - 2


def read_ranges(path):
    ranges = []
    try:
        with open(path) as source:
            for line in source:
                if line.strip() and not line.startswith("#"):
                    owner, start, count = line.strip().split(":")
                    start, count = int(start), int(count)
                    if not owner or start < 0 or count < 1 or start + count - 1 > MAX_ID:
                        raise ValueError(f"Invalid subordinate ID range in {path}")
                    ranges.append((owner, start, count))
    except FileNotFoundError:
        pass
    return ranges


def allocation(account, ranges, host_ids):
    owners = {account.pw_name, str(account.pw_uid)}
    own = [(start, count) for owner, start, count in ranges if owner in owners]
    others = [(start, start + count) for owner, start, count in ranges if owner not in owners]
    for start, count in own:
        if (any(start <= value < start + count for value in host_ids) or
                any(start < end and first < start + count for first, end in others)):
            raise ValueError("Existing subordinate IDs overlap a host identity or another account's grant; inspect the maps before migrating")
    if any(count >= COUNT for start, count in own):
        return None

    # Find a free interval, reserving both subordinate grants and actual host
    # identities. usermod accepts overlapping real IDs, so it is not a guard.
    occupied = [(start, start + count) for owner, start, count in ranges]
    occupied.extend((value, value + 1) for value in host_ids)
    candidate = 100000
    for first, end in sorted(occupied):
        if candidate + COUNT <= first:
            break
        if candidate < end:
            candidate = end
    if candidate + COUNT - 1 > MAX_ID:
        raise ValueError("No safe subordinate ID range is available")
    return candidate


def main():
    account = pwd.getpwnam(sys.argv[1])
    if account.pw_uid == 0:
        raise ValueError("Run the migration as the desktop user")
    fd = os.open("/run/omarchy-podman-subids.lock", os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600)
    with os.fdopen(fd, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        users = [account, *pwd.getpwall()]
        uid_ids = {0, *(user.pw_uid for user in users)}
        gid_ids = {0, *(user.pw_gid for user in users), *(group.gr_gid for group in grp.getgrall())}
        plans = []
        # Validate both maps before issuing either usermod command.
        for path, option, host_ids in (("/etc/subuid", "--add-subuids", uid_ids),
                                       ("/etc/subgid", "--add-subgids", gid_ids)):
            start = allocation(account, read_ranges(path), host_ids)
            if start is not None:
                plans.append(["usermod", option, f"{start}-{start + COUNT - 1}", account.pw_name])
        for command in plans:
            subprocess.run(command, check=True)


if __name__ == "__main__":
    try:
        main()
    except (ValueError, KeyError) as error:
        raise SystemExit(str(error)) from error
