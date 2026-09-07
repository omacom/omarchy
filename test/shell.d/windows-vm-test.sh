#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

windows_vm_command="$ROOT/bin/omarchy-windows-vm"
windows_vm_rules="$ROOT/default/hypr/apps/windows-vm.lua"

rg -q '^    restart: "no"$' "$windows_vm_command" ||
  fail "Windows VM uses manual startup by default"
pass "Windows VM uses manual startup by default"

if rg -q '^    restart: unless-stopped$' "$windows_vm_command"; then
  fail "Windows VM does not restart automatically at boot"
fi
pass "Windows VM does not restart automatically at boot"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
fake_bin="$test_tmp/bin"
mkdir -p "$test_home/.config/windows" "$fake_bin"

cat >"$test_home/.config/windows/docker-compose.yml" <<'YAML'
services:
  windows:
    environment:
      USERNAME: "docker"
      PASSWORD: "admin"
YAML

cat >"$fake_bin/docker" <<'STUB'
#!/bin/bash
[[ $1 == "inspect" ]] && echo running
STUB

cat >"$fake_bin/docker-compose" <<'STUB'
#!/bin/bash
printf 'docker-compose %s\n' "$*" >>"$TEST_LOG"
STUB

cat >"$fake_bin/gum" <<'STUB'
#!/bin/bash
:
STUB

cat >"$fake_bin/hyprctl" <<'STUB'
#!/bin/bash
echo '[{"focused":true,"scale":1}]'
STUB

cat >"$fake_bin/xfreerdp3" <<'STUB'
#!/bin/bash
exit "${RDP_STATUS:-0}"
STUB

chmod +x "$fake_bin"/*

run_launch() (
  export HOME="$test_home" TEST_LOG="$test_tmp/calls.log" PATH="$fake_bin:$PATH"
  export RDP_STATUS="$1"
  set -- help
  source "$windows_vm_command" >/dev/null
  migrate_legacy_compose() { return 0; }
  read_credential() { echo test; }
  priv() { printf '%s\n' "$*" >>"$TEST_LOG"; }
  launch_windows ""
)

set +e
output=$(run_launch 1 2>&1)
status=$?
set -e

(( status == 1 )) || fail "Windows VM launch returns the RDP failure" "got status $status"
! grep -qx down "$test_tmp/calls.log" ||
  fail "Windows VM stays running when RDP fails" "$(cat "$test_tmp/calls.log")"
grep -qF 'RDP connection failed. Windows VM is still running.' <<<"$output" ||
  fail "Windows VM explains how to reconnect after RDP fails" "$output"
pass "Windows VM survives a failed RDP connection"

run_launch 0 >/dev/null

grep -qFx down "$test_tmp/calls.log" ||
  fail "Windows VM still stops after a successful RDP session" "$(cat "$test_tmp/calls.log")"
pass "Windows VM keeps its automatic stop after a successful RDP session"
# Tolerate either shell quoting of the argument -- what must not drift is the
# title itself, since the Hyprland rule below matches on it.
rg -q 'title:"?Windows VM - Omarchy"' "$windows_vm_command" ||
  fail "Windows VM launches FreeRDP with its expected title"
rg -q 'class = "\^xfreerdp\$", title = "\^Windows VM - Omarchy\$"' "$windows_vm_rules" ||
  fail "Windows VM opacity rule targets its FreeRDP window"
rg -q 'tag = "-default-opacity"' "$windows_vm_rules" ||
  fail "Windows VM opts out of default opacity"
rg -q 'opacity = "1 1"' "$windows_vm_rules" ||
  fail "Windows VM stays fully opaque"
pass "Windows VM stays fully opaque"
