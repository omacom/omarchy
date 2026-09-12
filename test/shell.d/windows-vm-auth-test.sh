#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

python3 - <<'PY'
import os
import pty
import subprocess
import tempfile
from pathlib import Path


script = r'''
set -e
set -- help
source "$ROOT/bin/omarchy-windows-vm" >/dev/null
priv_target() { printf '/fixture/omarchy-windows-vm\n'; }
sudo() { printf sudo >"$MODE_LOG"; printf exited; }
pkexec() { printf pkexec >"$MODE_LOG"; printf exited; }
migrate_legacy_compose() { :; }
status_windows
'''
with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    (root / "docker-compose.yml").touch()
    log = root / "mode"
    env = dict(os.environ, OMARCHY_WINDOWS_DIR=str(root), MODE_LOG=str(log), HOME=str(root))
    for name, terminal_input, terminal_error, expected in (
            ("terminal status", True, True, "sudo"),
            ("redirected stdin", False, True, "sudo"),
            ("graphical caller", False, False, "pkexec")):
        master, slave = pty.openpty()
        try:
            result = subprocess.run(["/bin/bash", "-c", script], env=env,
                                    stdin=slave if terminal_input else subprocess.DEVNULL,
                                    stdout=subprocess.PIPE,
                                    stderr=slave if terminal_error else subprocess.PIPE,
                                    text=True, timeout=10)
            assert result.returncode == 0, (name, result.stdout, result.stderr)
            assert log.read_text() == expected, (name, log.read_text(), expected)
            assert "Windows VM is stopped" in result.stdout
        finally:
            os.close(slave)
            os.close(master)
        print(f"ok - {name} uses {expected} while privileged status output is captured")
PY

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
touch "$test_dir/docker-compose.yml"
MODE_LOG="$test_dir/mode" OMARCHY_WINDOWS_DIR="$test_dir" ROOT="$ROOT" bash -c '
  set -e
  set -- help
  source "$ROOT/bin/omarchy-windows-vm" >/dev/null
  priv() { printf "priv:%s\n" "$1" >>"$MODE_LOG"; }
  secure_windows_migration
  [[ $(<"$MODE_LOG") == "priv:secure" ]]
  mkdir -p "$HOME/.config/windows"
  touch "$HOME/.config/windows/docker-compose.yml"
  : >"$MODE_LOG"
  migrate_legacy_compose() {
    printf "migrate\n" >>"$MODE_LOG"
    priv secure
    remove_legacy_compose
  }
  remove_legacy_compose() { printf "remove\n" >>"$MODE_LOG"; rm "$HOME/.config/windows/docker-compose.yml"; }
  secure_windows_migration
  [[ ! -e $HOME/.config/windows/docker-compose.yml ]]
  expected=$(printf "migrate\npriv:secure\nremove")
  [[ $(<"$MODE_LOG") == "$expected" ]]
  valid_priv_action secure
  rm "$OMARCHY_WINDOWS_DIR/docker-compose.yml"
  : >"$MODE_LOG"
  secure_windows_migration
  [[ $(<"$MODE_LOG") == "priv:secure" ]]
  touch "$HOME/.config/windows/docker-compose.yml"
  migrate_legacy_compose() { return 23; }
  if secure_windows_migration; then
    exit 1
  fi
'
pass "migration security repair authenticates and propagates upgrade failures"
