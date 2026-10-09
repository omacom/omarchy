#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/home/.config/vivaldi/Default"
cat >"$test_tmp/bin/pgrep" <<'SH'
#!/bin/bash
[[ -f $HOME/browser-started ]]
SH
cat >"$test_tmp/bin/omarchy-theme-color" <<'SH'
#!/bin/bash
case $1 in
  background) echo "${BACKGROUND_COLOR:-#123456}" ;;
  foreground) echo '#ffffff' ;;
  accent) echo '#00aaff' ;;
  lighter_background) echo '#555555' ;;
esac
SH
chmod +x "$test_tmp/bin"/*

HOME="$test_tmp/home" PATH="$test_tmp/bin:$PATH" python3 - <<'PY'
import fcntl
import json
import os
from pathlib import Path
import signal
import subprocess
import time

home = Path(os.environ["HOME"])
profile = home / ".config/vivaldi/Default"
preferences = profile / "Preferences"
preferences.write_text(json.dumps({"unrelated": "original"}))
preferences.chmod(0o600)
legacy_staged = profile / "Preferences.omarchy-staged"
legacy_staged.write_text("do not reuse or remove a fixed staging file")
command = ["bash", os.environ["ROOT"] + "/bin/omarchy-theme-set-vivaldi"]
processes = []
lock = os.open(str(preferences) + ".omarchy-lock", os.O_CREAT | os.O_RDWR, 0o600)


def start_writer(color="#123456"):
    env = os.environ.copy()
    env["BACKGROUND_COLOR"] = color
    env.pop("VIVALDI_OMARCHY_JSON", None)
    proc = subprocess.Popen(command, env=env, stderr=subprocess.PIPE, start_new_session=True)
    processes.append(proc)
    return proc


def assert_blocked(proc):
    try:
        proc.wait(timeout=0.5)
    except subprocess.TimeoutExpired:
        return
    raise AssertionError("a native writer must wait for the profile lock before reading")


def assert_success(proc):
    _, stderr = proc.communicate(timeout=10)
    assert proc.returncode == 0, stderr.decode()


try:
    fcntl.flock(lock, fcntl.LOCK_EX)
    proc = start_writer()
    assert_blocked(proc)
    preferences.write_text(json.dumps({"unrelated": "changed while blocked"}))
    fcntl.flock(lock, fcntl.LOCK_UN)
    assert_success(proc)
    data = json.loads(preferences.read_text())
    assert data["unrelated"] == "changed while blocked", "read-modify-write is inside the lock"
    theme_id = data["vivaldi"]["themes"]["user"][0]["id"]
    print("ok - native writers wait for a stable profile lock and read only after acquiring it")

    fcntl.flock(lock, fcntl.LOCK_EX)
    proc = start_writer("#654321")
    assert_blocked(proc)
    before = preferences.read_bytes()
    (home / "browser-started").touch()
    fcntl.flock(lock, fcntl.LOCK_UN)
    assert_success(proc)
    assert preferences.read_bytes() == before, "a waiting writer must skip a browser that started"
    (home / "browser-started").unlink()
    print("ok - a waiting native writer rechecks whether the user's Vivaldi started")

    data["unrelated"] = "preserved" * 25000
    preferences.write_text(json.dumps(data))
    fcntl.flock(lock, fcntl.LOCK_EX)
    writers = [start_writer("#%06x" % (100000 + n)) for n in range(8)]
    fcntl.flock(lock, fcntl.LOCK_UN)
    deadline = time.monotonic() + 10
    while any(proc.poll() is None for proc in writers):
        assert time.monotonic() < deadline, "concurrent writers finish without deadlock"
        observed = json.loads(preferences.read_text())
        assert observed["unrelated"] == data["unrelated"], "unmanaged preferences survive"
        time.sleep(0.005)
    for proc in writers:
        assert_success(proc)
    result = json.loads(preferences.read_text())
    themes = result["vivaldi"]["themes"]["user"]
    assert len(themes) == 1 and themes[0]["id"] == theme_id, "concurrent writers reuse one theme"
    assert preferences.stat().st_mode & 0o777 == 0o600, "the profile stays private"
    assert legacy_staged.read_text() == "do not reuse or remove a fixed staging file"
    assert not list(profile.glob(".Preferences.omarchy-*")), "unique staging files are removed"
    print("ok - concurrent native writes publish valid JSON and use private unique staging files")

    preferences.write_text("{malformed}")
    proc = start_writer()
    proc.communicate(timeout=10)
    assert proc.returncode != 0, "malformed preferences report failure"
    assert preferences.read_text() == "{malformed}", "failed reads do not rewrite the profile"
    assert not list(profile.glob(".Preferences.omarchy-*"))
    print("ok - malformed preferences remain intact and do not leave temporary files")
finally:
    fcntl.flock(lock, fcntl.LOCK_UN)
    os.close(lock)
    for proc in processes:
        try:
            os.killpg(proc.pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
        try:
            proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            os.killpg(proc.pid, signal.SIGKILL)
            proc.wait()
PY
