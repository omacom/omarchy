#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

for package in docker docker-buildx docker-compose docker-rootless-extras rootlesskit slirp4netns fuse-overlayfs lazydocker; do
  grep -qx "$package" "$ROOT/install/omarchy-base.packages" || fail "rootless Docker dependency is in the base install: $package"
done
pass "the base install keeps Docker tooling and adds the rootless runtime"

! rg -q 'systemctl --global enable docker.service' "$ROOT/install" "$ROOT/migrations/1789164756.sh" ||
  fail "rootless Docker starts globally before each account is initialized"
grep -q 'docker.service' "$ROOT/install/user/first-run/enable-user-units.sh" ||
  fail "first login starts the rootless Docker user service"
grep -q 'rootless_docker_ensure_subids' "$ROOT/install/config/docker.sh" ||
  fail "fresh installs allocate subordinate IDs before rootless Docker starts"
grep -q 'rootless_docker_ensure_subids' "$ROOT/bin/omarchy-provision-owner" ||
  fail "deferred provisioning allocates subordinate IDs"
pass "fresh and deferred installs prepare the rootless user daemon"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
python3 - "$ROOT/install/helpers/rootless-docker.sh" <<'PY'
from pathlib import Path
from types import SimpleNamespace
import tempfile
import sys


helper = Path(sys.argv[1]).read_text()
embedded = helper.split("<<'PY'\n", 1)[1].split("\nPY\n", 1)[0]
definitions = embedded.rsplit("\nmain()", 1)[0]
namespace = {"__name__": "rootless_docker_subid_test"}
exec(compile(definitions, sys.argv[1], "exec"), namespace)
ensure_range = namespace["ensure_range"]
assigned_uids = namespace["assigned_uids"]
assigned_gids = namespace["assigned_gids"]
include_ranges_from = namespace["include_ranges_from"]
account = SimpleNamespace(pw_name="migration-user", pw_uid=1000, pw_gid=1000)


def expect_rejection(contents, assigned, message):
    with tempfile.TemporaryDirectory() as directory:
        path = Path(directory) / "subids"
        path.write_text(contents)
        try:
            ensure_range(account, str(path), "--add-subuids", lambda ranges: assigned,
                         usermod="/bin/false")
        except SystemExit as error:
            assert message in str(error)
        else:
            raise AssertionError(f"unsafe subordinate IDs were accepted: {contents!r}")


expect_rejection("migration-user:0:65536\n", {0, 1000}, "intersects a host identity")
expect_rejection("alice:100000:65536\n", {0, 1000, 120000}, "intersects a host identity")
expect_rejection(
    "alice:100000:65536\nbob:150000:65536\n", {0, 1000}, "overlapping subordinate-ID ranges",
)

for assigned in ({0, 1000, 120000}, {0, 1000, 165535}):
    with tempfile.TemporaryDirectory() as directory:
        path = Path(directory) / "subids"
        path.write_text("")

        def allocate(arguments, check):
            assert check is True
            start, end = map(int, arguments[2].split("-"))
            path.write_text(f"migration-user:{start}:{end - start + 1}\n")

        namespace["subprocess"].run = allocate
        ensure_range(account, str(path), "--add-subuids", lambda ranges: assigned,
                     usermod="/usr/bin/usermod")
        _name, start, count = path.read_text().strip().split(":")
        start, count = int(start), int(count)
        assert count == 65536
        assert all(not start <= identity < start + count for identity in assigned)

with tempfile.TemporaryDirectory() as directory:
    path = Path(directory) / "subids"
    path.write_text("")
    identity_sets = iter(({0, 1000}, {0, 1000, 120000}))

    def allocate_before_nss_change(arguments, check):
        path.write_text("migration-user:100000:65536\n")

    namespace["subprocess"].run = allocate_before_nss_change
    try:
        ensure_range(account, str(path), "--add-subgids", lambda ranges: next(identity_sets),
                     usermod="/usr/bin/usermod")
    except SystemExit as error:
        assert "intersects a host identity" in str(error)
    else:
        raise AssertionError("an NSS identity added during subordinate-ID allocation was missed")

foreign_account = SimpleNamespace(pw_name="foreign-user", pw_uid=110000, pw_gid=120000)
namespace["pwd"].getpwall = lambda: [foreign_account]
namespace["grp"].getgrall = lambda: []
namespace["os"].getgrouplist = lambda name, primary: [primary, 140000] if name == "foreign-user" else [primary]
foreign_primary_gids = lambda ranges: assigned_gids(account, ranges)
assert {120000, 140000} < foreign_primary_gids([])
with tempfile.TemporaryDirectory() as directory:
    path = Path(directory) / "subgids"
    path.write_text("")

    def allocate_around_foreign_primary_gid(arguments, check):
        start, end = map(int, arguments[2].split("-"))
        path.write_text(f"migration-user:{start}:{end - start + 1}\n")

    namespace["subprocess"].run = allocate_around_foreign_primary_gid
    ensure_range(account, str(path), "--add-subgids", foreign_primary_gids,
                 usermod="/usr/bin/usermod")
    _name, start, count = path.read_text().strip().split(":")
    start, count = int(start), int(count)
    assert all(not start <= identity < start + count for identity in (120000, 140000))

high_account = SimpleNamespace(pw_name="directory-user", pw_uid=120000, pw_gid=130000)
namespace["pwd"].getpwall = lambda: []
namespace["grp"].getgrall = lambda: []
namespace["os"].getgrouplist = lambda name, primary: [primary, 140000]
assert assigned_uids(high_account, []) == {0, 120000}
assert assigned_gids(high_account, []) == {0, 130000, 140000}
for assigned_ids, option in (
        (lambda ranges: assigned_uids(high_account, ranges), "--add-subuids"),
        (lambda ranges: assigned_gids(high_account, ranges), "--add-subgids")):
    with tempfile.TemporaryDirectory() as directory:
        path = Path(directory) / "subids"
        path.write_text("")

        def allocate_for_non_enumerated_account(arguments, check):
            start, end = map(int, arguments[2].split("-"))
            path.write_text(f"directory-user:{start}:{end - start + 1}\n")

        namespace["subprocess"].run = allocate_for_non_enumerated_account
        ensure_range(high_account, str(path), option, assigned_ids,
                     usermod="/usr/bin/usermod")
        _name, start, count = path.read_text().strip().split(":")
        start, count = int(start), int(count)
        assert all(not start <= identity < start + count for identity in assigned_ids([]))

hidden_account = SimpleNamespace(pw_name="hidden-user", pw_uid=150000, pw_gid=170000)
namespace["pwd"].getpwall = lambda: []

def hidden_by_name(name):
    if name == hidden_account.pw_name:
        return hidden_account
    raise KeyError(name)


def hidden_by_uid(uid):
    if uid == hidden_account.pw_uid:
        return hidden_account
    raise KeyError(uid)


namespace["pwd"].getpwnam = hidden_by_name
namespace["pwd"].getpwuid = hidden_by_uid
namespace["os"].getgrouplist = lambda name, primary: [primary, 140000] if name == "hidden-user" else [primary]
for owner in (hidden_account.pw_name, str(hidden_account.pw_uid)):
    with tempfile.TemporaryDirectory() as directory:
        path = Path(directory) / "subgids"
        path.write_text(f"{owner}:100000:65536\n")
        try:
            ensure_range(
                account, str(path), "--add-subgids",
                lambda ranges: assigned_gids(account, ranges), usermod="/bin/false",
            )
        except SystemExit as error:
            assert "intersects a host identity" in str(error)
        else:
            raise AssertionError("a non-enumerated subordinate-ID owner group was missed")

for current_kind, other_kind, option, assigned_ids, protected in (
        ("subuid", "subgid", "--add-subuids", assigned_uids, {hidden_account.pw_uid}),
        ("subgid", "subuid", "--add-subgids", assigned_gids, {hidden_account.pw_gid, 140000})):
    with tempfile.TemporaryDirectory() as directory:
        current_path = Path(directory) / current_kind
        other_path = Path(directory) / other_kind
        current_path.write_text("")
        other_path.write_text(f"{hidden_account.pw_name}:300000:65536\n")

        def allocate_with_cross_file_owner(arguments, check):
            start, end = map(int, arguments[2].split("-"))
            current_path.write_text(f"migration-user:{start}:{end - start + 1}\n")

        namespace["subprocess"].run = allocate_with_cross_file_owner
        cross_file_ids = lambda ranges: assigned_ids(
            account, include_ranges_from(ranges, str(other_path)),
        )
        ensure_range(account, str(current_path), option, cross_file_ids,
                     usermod="/usr/bin/usermod")
        _name, start, count = current_path.read_text().strip().split(":")
        start, count = int(start), int(count)
        assert all(not start <= identity < start + count for identity in protected)
PY
pass "subordinate ID ranges exclude current and newly observed NSS identities"

home="$test_dir/home"
mkdir -p "$home/.local/state/omarchy/rootless-docker"
touch "$home/.local/state/omarchy/rootless-docker/enabled"
generator="$ROOT/default/systemd/user-environment-generators/60-omarchy-rootless-docker"
expected="DOCKER_HOST=unix://$test_dir/runtime/docker.sock"
actual=$(HOME="$home" XDG_RUNTIME_DIR="$test_dir/runtime" "$generator")
[[ $actual == "$expected" ]] || fail "the rootless Docker API endpoint is exported" "$actual"
rm "$home/.local/state/omarchy/rootless-docker/enabled"
[[ -z $(HOME="$home" XDG_RUNTIME_DIR="$test_dir/runtime" "$generator") ]] ||
  fail "the API endpoint stays unchanged before migration completes"
pass "the Docker endpoint activates only after rootless setup completes"

migration="$ROOT/migrations/1789164756.sh"
behavior_bin="$test_dir/behavior-bin"
behavior_home="$test_dir/behavior-home"
behavior_runtime="$test_dir/behavior-runtime"
behavior_log="$test_dir/behavior.log"
mkdir -p "$behavior_bin" "$behavior_home" "$behavior_runtime"
cat >"$behavior_bin/id" <<'EOF'
#!/bin/bash
case "$*" in
  -u) echo 1000 ;;
  -un) echo migration-user ;;
  *) echo migration-user ;;
esac
EOF
cat >"$behavior_bin/systemctl" <<'EOF'
#!/bin/bash
echo "systemctl $*" >>"$BEHAVIOR_LOG"
if [[ $* == "--user show-environment" || $* == "--user is-active --quiet docker.service" ]]; then
  exit 0
fi
exit 0
EOF
cat >"$behavior_bin/sudo" <<'EOF'
#!/bin/bash
echo "sudo $*" >>"$BEHAVIOR_LOG"
[[ $* == "/usr/bin/test -f /var/lib/omarchy/rootless-docker/enabled" ]] && exit 1
exit 0
EOF
cat >"$behavior_bin/omarchy-pkg-add" <<'EOF'
#!/bin/bash
echo "package $*" >>"$BEHAVIOR_LOG"
EOF
cat >"$behavior_bin/python3" <<'EOF'
#!/bin/bash
echo "python $*" >>"$BEHAVIOR_LOG"
[[ $* == *"--check-target-policy"* ]] && exit 1
exit 0
EOF
chmod +x "$behavior_bin"/*
behavior_migration="$test_dir/migration.sh"
sed \
  -e 's|export XDG_RUNTIME_DIR="/run/user/$migration_uid"|export XDG_RUNTIME_DIR="$TEST_RUNTIME"|' \
  -e "s|/usr/bin/python3|$behavior_bin/python3|g" \
  "$migration" >"$behavior_migration"
if HOME="$behavior_home" TEST_RUNTIME="$behavior_runtime" BEHAVIOR_LOG="$behavior_log" \
  OMARCHY_PATH="$ROOT" PATH="$behavior_bin:$PATH" bash -euo pipefail "$behavior_migration" >/dev/null 2>&1; then
  fail "an incompatible active rootless daemon passed migration setup"
fi
grep -q -- '--check-target-policy' "$behavior_log" ||
  fail "an active rootless daemon was not validated before service setup"
! grep -Eq 'systemctl --user (daemon-reload|enable|start|restart)' "$behavior_log" ||
  fail "an incompatible active rootless daemon was changed before rejection"
pass "active custom rootless workloads are rejected without service disruption"

reset_line=$(grep -n 'systemctl --user reset-failed docker.service' "$migration" | cut -d: -f1)
user_enable_line=$(grep -n 'systemctl --user enable docker.service' "$migration" | cut -d: -f1)
user_start_line=$(grep -n 'systemctl --user start docker.service' "$migration" | cut -d: -f1)
daemon_config_line=$(grep -n 'install -m 0644.*config/docker/daemon.json' "$migration" | cut -d: -f1)
active_probe_line=$(grep -n 'systemctl --user is-active --quiet docker.service' "$migration" | cut -d: -f1)
target_policy_line=$(grep -n -- '--check-target-policy' "$migration" | head -n1 | cut -d: -f1)
user_reload_line=$(grep -n 'systemctl --user daemon-reload' "$migration" | cut -d: -f1)
[[ -n $reset_line && -n $user_enable_line && -n $user_start_line && -n $daemon_config_line &&
  -n $active_probe_line && -n $target_policy_line && -n $user_reload_line ]] &&
  (( active_probe_line < daemon_config_line && daemon_config_line < target_policy_line &&
    target_policy_line < user_reload_line && user_reload_line < reset_line &&
    reset_line < user_enable_line && user_enable_line < user_start_line )) ||
  fail "migration does not validate and preserve an active rootless daemon before service setup"
! grep -q 'systemctl --user restart docker.service' "$migration" ||
  fail "migration restarts existing rootless workloads before destination preflight"
(( $(grep -c -- '--check-target-policy' "$migration") == 2 )) ||
  fail "migration does not verify target policy before and after setting up the user daemon"
grep -q 'migration_user=$(id -un)' "$migration" || fail "migration trusts the USER environment instead of the current account"
lock_line=$(grep -n '/usr/bin/flock -n' "$migration" | cut -d: -f1)
package_line=$(grep -n '^omarchy-pkg-add docker-rootless-extras' "$migration" | cut -d: -f1)
[[ -n $lock_line && -n $package_line ]] && (( lock_line < package_line )) ||
  fail "same-account migrations are not serialized before any setup or transfer"
completion_line=$(grep -n 'test -f "$machine_state/enabled"' "$migration" | cut -d: -f1)
inventory_line=$(grep -n 'docker_inventory=' "$migration" | cut -d: -f1)
[[ -n $completion_line && -n $inventory_line ]] && (( completion_line < inventory_line )) ||
  fail "later accounts can reach the machine-wide retained rootful store"
grep -q 'machine-wide rootful recovery store was left untouched' "$migration" ||
  fail "later accounts do not have an explicit rootful-store no-op path"
completion_return=$(grep -n 'machine-wide rootful recovery store was left untouched' "$migration" | cut -d: -f1)
later_group_drop=$(sed -n "${completion_line},${completion_return}p" "$migration" | grep -n '^  remove_legacy_docker_group' | cut -d: -f1)
[[ -n $later_group_drop ]] || fail "later accounts retain legacy docker-group membership"
socket_line=$(grep -n "socket_owner=" "$migration" | cut -d: -f1)
[[ -n $socket_line && -n $inventory_line ]] && (( socket_line < inventory_line )) ||
  fail "the legacy group socket remains writable during source migration"
listener_line=$(grep -n '^verify_rootful_listeners$' "$migration" | head -n1 | cut -d: -f1)
[[ -n $listener_line ]] && (( socket_line < listener_line && listener_line < inventory_line )) ||
  fail "custom rootful Docker listeners are not rejected before source migration"
grep -q -- '--check-windows "$windows_id"' "$migration" ||
  fail "the name-based Windows exception is not authenticated against its managed runtime"
windows_secure_line=$(grep -n '^/usr/bin/omarchy-windows-vm __migration-secure$' "$migration" | cut -d: -f1)
[[ -n $windows_secure_line && -n $inventory_line ]] && (( windows_secure_line < inventory_line )) ||
  fail "legacy Windows credentials and mounts are not secured before rootful inventory"
windows_check_line=$(grep -n -- '--check-windows "$windows_id"' "$migration" | head -n1 | cut -d: -f1)
owner_claim_line=$(grep -n 'owner = root / "migration-owner"' "$migration" | cut -d: -f1)
[[ -n $windows_check_line && -n $owner_claim_line ]] && (( windows_check_line < owner_claim_line )) ||
  fail "the machine migration owner is claimed before proving ownership of an existing Windows VM"
owner_replace_line=$(grep -n 'temporary.replace(owner)' "$migration" | cut -d: -f1)
owner_sync_line=$(grep -n 'os.fsync(directory_fd)' "$migration" | head -n1 | cut -d: -f1)
[[ -n $owner_replace_line && -n $owner_sync_line ]] && (( owner_replace_line < owner_sync_line )) ||
  fail "the machine migration owner rename is not directory-synced"
quiesce_line=$(grep -n -- '--quiesce-all "$windows_arg"' "$migration" | cut -d: -f1)
restart_line=$(grep -n 'systemctl restart docker.service' "$migration" | cut -d: -f1)
transfer_line=$(grep -n '^  /usr/bin/python3 "$migrator" "${container_names\[@\]}"' "$migration" | cut -d: -f1)
[[ -n $quiesce_line && -n $restart_line && -n $transfer_line ]] &&
  (( inventory_line < quiesce_line && quiesce_line < restart_line && restart_line < transfer_line )) ||
  fail "rootful connections are not revoked between durable quiesce and transfer"
(( $(grep -c '^restrict_rootful_socket$' "$migration") == 2 )) ||
  fail "rootful socket policy is not rechecked after daemon restart"
(( $(grep -c '^verify_rootful_listeners$' "$migration") == 3 )) ||
  fail "rootful Docker configuration is not rechecked immediately before and after daemon restart"
(( $(grep -c '^verify_rootful_socket_unit$' "$migration") == 2 )) ||
  fail "the effective rootful socket unit is not rechecked after daemon restart"
for property in SocketUser SocketGroup SocketMode Listen; do
  grep -q -- "--property=$property" "$migration" ||
    fail "migration does not verify effective docker.socket $property"
done
grep -q -- '--restore-windows "$windows_id"' "$migration" ||
  fail "a running Windows VM is not restored after rootful connection revocation"
pass "migration serializes ownership, secures Windows, and revokes existing rootful connections"

listener_verifier="$ROOT/default/docker/rootless/rootful-listeners.py"
python3 - "$listener_verifier" <<'PY'
import importlib.util
import json
import os
from pathlib import Path
import sys
import tempfile
import time

spec = importlib.util.spec_from_file_location("rootful_listeners", sys.argv[1])
listeners = importlib.util.module_from_spec(spec)
spec.loader.exec_module(listeners)

with tempfile.TemporaryDirectory() as directory:
    proc = Path(directory)
    descriptors = proc / "4242/fd"
    descriptors.mkdir(parents=True)
    (proc / "4242/net").mkdir()
    (proc / "etc/docker").mkdir(parents=True)
    (proc / "etc/docker/daemon.json").write_text(json.dumps(listeners.EXPECTED_DAEMON_CONFIG))
    clock_ticks = os.sysconf("SC_CLK_TCK")
    start_time = int((proc / "etc/docker/daemon.json").stat().st_ctime) + 10
    (proc / "stat").write_text("btime 1\n")
    (proc / "4242/stat").write_text(
        "4242 (dockerd) S " + " ".join(["0"] * 18) + f" {(start_time - 1) * clock_ticks}\n"
    )
    (proc / "4242/cmdline").write_bytes(b"/usr/bin/dockerd\0-H\0fd://\0")
    (proc / "4242/exe").symlink_to("/usr/bin/dockerd")
    os.symlink("socket:[101]", descriptors / "3")
    (proc / "4242/net/unix").write_text(
        "Num RefCount Protocol Flags Type St Inode Path\n"
        "00000000: 00000002 00000000 00010000 0001 01 101 /run/docker.sock\n"
    )
    tcp_header = "sl local_address rem_address st tx_queue rx_queue tr tm->when retrnsmt uid timeout inode\n"
    (proc / "4242/net/tcp").write_text(tcp_header)
    (proc / "4242/net/tcp6").write_text(tcp_header)
    peer = lambda _endpoint: (4242, 0, 0)
    assert listeners.verify(4242, proc, proc, os.getuid(), peer) == \
        "unix:///proc/4242/root/run/docker.sock"

    try:
        listeners.verify(4242, proc, proc, os.getuid(), lambda _endpoint: (9999, 0, 0))
    except RuntimeError:
        pass
    else:
        raise AssertionError("a replacement rootful API endpoint was accepted")

    config = proc / "etc/docker/daemon.json"
    trusted_config = proc / "etc/docker/daemon.trusted.json"
    config.replace(trusted_config)
    config.symlink_to(trusted_config)
    try:
        listeners.verify(4242, proc, proc, os.getuid(), peer)
    except RuntimeError:
        pass
    else:
        raise AssertionError("a symlinked rootful daemon configuration was accepted")
    config.unlink()
    trusted_config.replace(config)

    os.symlink("socket:[102]", descriptors / "4")
    (proc / "4242/net/tcp").write_text(
        tcp_header +
        "0: 0100007F:0947 00000000:0000 0A 00000000:00000000 00:00000000 00000000 0 0 102\n"
    )
    try:
        listeners.verify(4242, proc, proc, os.getuid(), peer)
    except RuntimeError:
        pass
    else:
        raise AssertionError("a rootful TCP API listener was accepted")
    (proc / "4242/net/tcp").write_text(tcp_header)
    time.sleep(0.01)
    (proc / "etc/docker/daemon.json").write_text(json.dumps(listeners.EXPECTED_DAEMON_CONFIG))
    stale_start = int((proc / "etc/docker/daemon.json").stat().st_ctime) - 10
    (proc / "4242/stat").write_text(
        "4242 (dockerd) S " + " ".join(["0"] * 18) + f" {(stale_start - 1) * clock_ticks}\n"
    )
    try:
        listeners.verify(4242, proc, proc, os.getuid(), peer)
    except RuntimeError:
        pass
    else:
        raise AssertionError("a daemon with post-start configuration changes was accepted")
    (proc / "4242/stat").write_text(
        "4242 (dockerd) S " + " ".join(["0"] * 18) + f" {(start_time - 1) * clock_ticks}\n"
    )
    for key, value in (
            ("init", True),
            ("dns", ["203.0.113.53"]),
            ("default-ulimits", {"nofile": {"Soft": 64, "Hard": 64}}),
            ("default-stop-timeout", 321)):
        configured = dict(listeners.EXPECTED_DAEMON_CONFIG)
        configured[key] = value
        (proc / "etc/docker/daemon.json").write_text(json.dumps(configured))
        try:
            listeners.verify(4242, proc, proc, os.getuid(), peer)
        except RuntimeError:
            pass
        else:
            raise AssertionError(f"a hidden rootful daemon default passed: {key}")
    (proc / "etc/docker/daemon.json").write_text(json.dumps(listeners.EXPECTED_DAEMON_CONFIG))
    (proc / "4242/exe").unlink()
    (proc / "4242/exe").symlink_to("/usr/local/bin/dockerd")
    try:
        listeners.verify(4242, proc, proc, os.getuid(), peer)
    except RuntimeError:
        pass
    else:
        raise AssertionError("a spoofed rootful dockerd argv was accepted")
    (proc / "4242/exe").unlink()
    (proc / "4242/exe").symlink_to("/usr/bin/dockerd")
    (proc / "4242/cmdline").write_bytes(b"/usr/bin/dockerd\0-H\0fd://\0--init=true\0")
    try:
        listeners.verify(4242, proc, proc, os.getuid(), peer)
    except RuntimeError:
        pass
    else:
        raise AssertionError("a hidden rootful command-line default passed")
print("ok - listener verification accepts only the protected rootful Unix socket")
PY
pass "rootful Docker listener verification rejects extra API endpoints"

grep -q "alias d='docker'" "$ROOT/default/bash/aliases" || fail "the d alias remains Docker"
! rg -q 'sudo[[:space:]]+docker' "$ROOT/bin/omarchy-install-docker-dbs" ||
  fail "development database installs still use rootful Docker"
! rg -q 'pkexec|omarchy-sudo-docker' "$ROOT/bin/omarchy-launch-docker-tui" ||
  fail "lazydocker still crosses a root boundary"
[[ ! -e $ROOT/bin/omarchy-sudo-docker && ! -e $ROOT/bin/omarchy-setup-security-sudoless-docker && ! -e $ROOT/bin/omarchy-remove-security-sudoless-docker ]] ||
  fail "the obsolete docker-group toggle remains installed"
! rg -q 'sudoless-docker|Sudoless Docker' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "the obsolete docker-group toggle remains in the menu"
pass "Docker CLI, Compose, Buildx, databases and lazydocker use the user daemon directly"

socket_policy="$ROOT/default/systemd/system/docker.socket.d/10-omarchy-rootful.conf"
grep -qx 'SocketUser=root' "$socket_policy" || fail "the Windows Docker socket is root-owned"
grep -qx 'SocketGroup=root' "$socket_policy" || fail "the Windows Docker socket has no docker-group access"
grep -qx 'SocketMode=0600' "$socket_policy" || fail "the Windows Docker socket is root-only"
grep -q 'host="unix:///proc/\$main_pid/root/run/docker.sock"' "$ROOT/bin/omarchy-windows-vm" ||
  fail "privileged Windows actions are not pinned to dockerd's mount namespace"
grep -q 'sudo "$target" __priv' "$ROOT/bin/omarchy-windows-vm" ||
  fail "terminal Windows operations do not authenticate"
grep -q 'pkexec "$target" __priv' "$ROOT/bin/omarchy-windows-vm" ||
  fail "graphical Windows operations do not authenticate"
pass "Windows remains on an authenticated root-only Docker daemon"
