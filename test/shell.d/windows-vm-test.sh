#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
mkdir -p "$test_tmp/home" "$fake_bin"
printf '#!/bin/bash\nexit 0\n' >"$fake_bin/omarchy-hw-x86"
printf '#!/bin/bash\n:\n' >"$fake_bin/gum"
cat >"$fake_bin/hyprctl" <<'STUB'
#!/bin/bash
echo '[{"focused":true,"scale":1}]'
STUB
cat >"$fake_bin/omarchy-notification-send" <<'STUB'
#!/bin/bash
printf 'notify %s\n' "$*" >>"$TEST_LOG"
STUB
printf '#!/bin/bash\nexit "$RDP_STATUS"\n' >"$fake_bin/xfreerdp3"
chmod +x "$fake_bin"/*

# Launch with FreeRDP exiting $1, recording every privileged action and notification.
run_launch() (
  export HOME="$test_tmp/home" OMARCHY_WINDOWS_DIR="$test_tmp/win" TEST_LOG="$test_tmp/calls.log"
  export PATH="$fake_bin:$PATH" RDP_STATUS="$1"
  : >"$TEST_LOG"
  set -- help
  source "$ROOT/bin/omarchy-windows-vm" >/dev/null
  migrate_legacy_compose() { return 0; }
  read_credential() { echo test; }
  priv() { printf '%s\n' "$*" >>"$TEST_LOG"; }
  launch_windows "" >/dev/null 2>&1
)

# FreeRDP exits 0 for a closed window, and 2, 4 or 12 for a logoff or the
# server's session limit: the session connected, so the VM stops.
for code in 0 2 4 12; do
  run_launch "$code" || fail "Windows VM launch succeeds after a session that ended with $code"
  grep -qFx down "$test_tmp/calls.log" ||
    fail "Windows VM stops after a session that ended with $code" "$(cat "$test_tmp/calls.log")"
done
pass "Windows VM stops after an RDP session that connected"

# Denied connections, credential failures and transport errors never connected.
for code in 7 9 10 131; do
  status=0
  run_launch "$code" || status=$?
  (( status == code )) || fail "Windows VM launch returns RDP failure $code" "got status $status"
  ! grep -qFx down "$test_tmp/calls.log" ||
    fail "Windows VM stays running when RDP fails with $code" "$(cat "$test_tmp/calls.log")"
  grep -q '^notify Windows VM ' "$test_tmp/calls.log" ||
    fail "Windows VM tells a launcher without a terminal that RDP failed with $code" "$(cat "$test_tmp/calls.log")"
done
pass "Windows VM stays running and says so when RDP fails"
