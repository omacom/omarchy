#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
stub_dir="$tmpdir/bin"
mkdir -p "$stub_dir"
log="$tmpdir/log"

cat >"$stub_dir/rfkill" <<'SH'
#!/bin/bash
printf '%s\n' "rfkill $*" >>"$BT_LOG"
SH
chmod +x "$stub_dir/rfkill"

cat >"$stub_dir/systemctl" <<'SH'
#!/bin/bash
printf '%s\n' "systemctl $*" >>"$BT_LOG"
if [[ $1 == "restart" && $2 == "bluetooth.service" ]]; then
  exit "${SYSTEMCTL_RESTART_RC:-0}"
fi
exit 0
SH
chmod +x "$stub_dir/systemctl"

BT_LOG="$log" PATH="$stub_dir:$PATH" "$ROOT/bin/omarchy-restart-bluetooth" >/dev/null
grep -qx 'rfkill unblock bluetooth' "$log" || fail "restart-bluetooth unblocks first" "$(cat "$log")"
grep -qx 'systemctl restart bluetooth.service' "$log" || fail "restart-bluetooth restarts bluetooth.service" "$(cat "$log")"
pass "restart-bluetooth unblocks and restarts bluetooth.service"

: >"$log"
if BT_LOG="$log" SYSTEMCTL_RESTART_RC=1 PATH="$stub_dir:$PATH" \
  "$ROOT/bin/omarchy-restart-bluetooth" >/dev/null 2>"$tmpdir/err"; then
  fail "restart-bluetooth exits nonzero when systemctl restart fails"
fi
grep -q 'failed to restart bluetooth.service' "$tmpdir/err" ||
  fail "restart-bluetooth reports restart failure" "$(cat "$tmpdir/err")"
pass "restart-bluetooth fails when bluetooth.service will not restart"
