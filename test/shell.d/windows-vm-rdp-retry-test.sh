#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
export HOME="$TMPDIR/home"
mkdir -p "$HOME"
export CREDENTIALS_FILE="$HOME/.config/windows/credentials"
export COMPOSE_FILE="$TMPDIR/docker-compose.yml"
export RUNTIME_DIR="$TMPDIR/runtime"
export OMARCHY_WINDOWS_DIR="$RUNTIME_DIR"
mkdir -p "$RUNTIME_DIR"
touch "$COMPOSE_FILE"

cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

set -- help
source "$ROOT/bin/omarchy-windows-vm" >/dev/null 2>&1
COMPOSE_FILE="$TMPDIR/docker-compose.yml"

priv() { [[ $1 == up_wait || $1 == down ]]; }
hyprctl() { printf '[{"focused":true,"scale":1}]\n'; }
gum() {
  [[ $1 == input ]] || return 0
  case "$*" in
    *'--header=Enter Windows username:'*) printf '%s\n' retry-user ;;
    *'--header=Enter Windows password:'*) printf '%s\n' retry-pass ;;
    *) return 1 ;;
  esac
}
xfreerdp3() {
  local args
  args=$(cat)
  printf '%s\n' "$args" >>"$TMPDIR/rdp-args"
  if [[ ! -e $TMPDIR/failed ]]; then
    touch "$TMPDIR/failed"
    return 132
  fi
  return 0
}
xdg-open() { :; }
omarchy-notification-send() { :; }
gum_style() { :; }

write_credentials old-user old-pass
set +e
launch_windows --keep-alive
status=$?
set -e
[[ $status == 0 ]] || fail "credential retry did not complete"

[[ $(read_credential USERNAME) == retry-user ]] || fail "retry username was saved"
[[ $(read_credential PASSWORD) == retry-pass ]] || fail "retry password was saved"
[[ $(grep -c '^/u:retry-user$' "$TMPDIR/rdp-args") == 1 ]] || fail "retry credentials reached FreeRDP"
[[ $(grep -c '^/u:old-user$' "$TMPDIR/rdp-args") == 1 ]] || fail "saved credentials were tried first"
pass "RDP retries after failure and saves entered credentials"

gum_calls_file="$TMPDIR/gum-calls"
rm -f "$gum_calls_file"
gum() {
  [[ $1 == input ]] || return 0
  touch "$gum_calls_file"
  return 99
}
xfreerdp3() { cat >/dev/null; return 2; }
write_credentials saved-user saved-pass
rm -f "$TMPDIR/failed"
set +e
launch_windows --keep-alive
status=$?
set -e
[[ $status == 0 ]] || fail "ordinary RDP exit propagated unexpectedly"
[[ ! -e $gum_calls_file ]] || fail "ordinary RDP exit re-prompted for credentials"
pass "ordinary RDP exit does not retry credentials"
