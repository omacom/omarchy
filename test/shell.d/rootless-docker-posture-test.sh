#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

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
