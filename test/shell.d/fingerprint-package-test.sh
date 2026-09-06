#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/home"
export CALL_LOG="$scratch/calls"
export HOME="$scratch/home"
export OMARCHY_PATH="$ROOT"
export PATH="$scratch/bin:$PATH"

cat > "$scratch/bin/omarchy-hw-fingerprint" <<'STUB'
#!/bin/bash
exit "${HARDWARE_STATUS:-0}"
STUB
cat > "$scratch/bin/omarchy-channel-current" <<'STUB'
#!/bin/bash
printf '%s\n' "$CHANNEL"
STUB
cat > "$scratch/bin/sudo" <<'STUB'
#!/bin/bash
case "$1" in
  pacman | fprintd-enroll) exec "$@" ;;
  *) echo "Unexpected privileged call: $*" >> "$CALL_LOG"; exit 99 ;;
esac
STUB
cat > "$scratch/bin/pacman" <<'STUB'
#!/bin/bash
printf 'pacman %s\n' "$*" >> "$CALL_LOG"
case "$1" in
  -Si)
    [[ -n $AVAILABLE_VERSION ]] || exit 1
    printf 'Version : %s\n' "$AVAILABLE_VERSION"
    ;;
  -S) exit "${INSTALL_STATUS:-0}" ;;
  *) exit 99 ;;
esac
STUB
cat > "$scratch/bin/fprintd-enroll" <<'STUB'
#!/bin/bash
# Stop before verification/PAM; no host authentication files may be changed.
echo enroll >> "$CALL_LOG"
exit 1
STUB
chmod +x "$scratch/bin/"*

run_setup() {
  : > "$CALL_LOG"
  if "$ROOT/bin/omarchy-setup-security-fingerprint" > "$scratch/output" 2>&1; then
    fail "setup stops on the simulated enrollment or installation failure"
  fi
  if grep -q 'Unexpected privileged call' "$CALL_LOG"; then
    fail "setup does not change PAM after failed enrollment"
  fi
}

export AVAILABLE_VERSION=1:1.94.100.r10.g6f9479c-1
for CHANNEL in edge dev stable rc unknown; do
  export CHANNEL
  run_setup
  case "$CHANNEL" in
    edge | dev) expected=libfprint-git ;;
    *) expected=libfprint ;;
  esac
  grep -qx "pacman -S --needed --noconfirm --ask 4 $expected fprintd usbutils" "$CALL_LOG" ||
    fail "$CHANNEL selects the expected driver in one transaction"
  grep -qx enroll "$CALL_LOG" || fail "$CHANNEL reaches enrollment after installation"
  [[ $(grep -c '^pacman -S ' "$CALL_LOG") == 1 ]] || fail "$CHANNEL uses one install transaction"
  if grep -q '^pacman -R' "$CALL_LOG"; then
    fail "$CHANNEL never removes the installed driver first"
  fi
  pass "$CHANNEL selects $expected and reaches enrollment"
done

export CHANNEL=edge
for AVAILABLE_VERSION in 1:1.94.10.r12.gd79f157-1.1 ''; do
  export AVAILABLE_VERSION
  run_setup
  if grep -Eq '^pacman -S |^enroll$' "$CALL_LOG"; then
    fail "old or missing edge packages stop before installation and enrollment"
  fi
  grep -q 'Run omarchy update' "$scratch/output" || fail "stale repository gives an update instruction"
done
pass "old and missing edge packages leave the installed driver alone"

export AVAILABLE_VERSION=1:1.94.100.r11.gabcdef0-1
run_setup
grep -qx enroll "$CALL_LOG" || fail "newer edge versions are accepted"
pass "newer edge versions reach enrollment"

export INSTALL_STATUS=1
run_setup
if grep -qx enroll "$CALL_LOG"; then
  fail "failed package transaction prevents enrollment"
fi
pass "failed installation stops before enrollment"

export HARDWARE_STATUS=1
run_setup
[[ ! -s $CALL_LOG ]] || fail "missing hardware stops before package operations"
pass "missing hardware performs no package operations"
