#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

stub_bin="$tmp/bin"
home="$tmp/home"
mkdir -p "$stub_bin" "$home"

cat >"$stub_bin/systemd-run" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$SYSTEMD_RUN_LOG"
EOF

cat >"$stub_bin/omarchy-notification-send" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$NOTIFY_LOG"
EOF

cat >"$stub_bin/pgrep" <<'EOF'
#!/bin/bash
[[ ${LOCALSEND_RUNNING:-0} == "1" ]]
EOF

cat >"$stub_bin/wl-paste" <<'EOF'
#!/bin/bash
if [[ ${WL_PASTE_FAIL:-0} == "1" ]]; then
  exit 1
fi
printf '%s' "${WL_PASTE_TEXT:-}"
EOF

chmod +x "$stub_bin/systemd-run" "$stub_bin/omarchy-notification-send" \
  "$stub_bin/pgrep" "$stub_bin/wl-paste"

run_share() {
  : >"$tmp/systemd-run.log"
  : >"$tmp/notify.log"
  PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" OMARCHY_PATH="$ROOT" \
    SYSTEMD_RUN_LOG="$tmp/systemd-run.log" NOTIFY_LOG="$tmp/notify.log" \
    "$ROOT/bin/omarchy-menu-share" "$@"
}

# A nonexistent path exits non-zero, notifies, and does not launch LocalSend.
missing="$tmp/does-not-exist"
status=0
err=$(run_share file "$missing" 2>&1) || status=$?
(( status != 0 )) || fail "missing share path exits non-zero"
[[ ! -s $tmp/systemd-run.log ]] || fail "missing share path does not launch LocalSend" "$(cat "$tmp/systemd-run.log")"
grep -Fq "Could not share" "$tmp/notify.log" && grep -Fq "$missing" "$tmp/notify.log" ||
  fail "missing share path sends a notification naming the path" "$(cat "$tmp/notify.log")"
pass "missing share path fails with a notification and does not launch LocalSend"

# Empty or failed clipboard read exits non-zero, notifies, and does not launch LocalSend.
status=0
err=$(WL_PASTE_TEXT="" run_share clipboard 2>&1) || status=$?
(( status != 0 )) || fail "empty clipboard exits non-zero"
[[ ! -s $tmp/systemd-run.log ]] || fail "empty clipboard does not launch LocalSend" "$(cat "$tmp/systemd-run.log")"
grep -Fq "The clipboard is empty" "$tmp/notify.log" ||
  fail "empty clipboard sends a notification explaining the refusal" "$(cat "$tmp/notify.log")"
pass "empty clipboard fails with a notification and does not launch LocalSend"

# When LocalSend is already running, refuse with a notification and do not launch another instance.
sample="$tmp/sample.txt"
printf 'hello' >"$sample"
status=0
err=$(LOCALSEND_RUNNING=1 run_share file "$sample" 2>&1) || status=$?
(( status != 0 )) || fail "already-running LocalSend exits non-zero"
[[ ! -s $tmp/systemd-run.log ]] || fail "already-running LocalSend does not launch another instance" "$(cat "$tmp/systemd-run.log")"
grep -Fq "LocalSend is already running" "$tmp/notify.log" ||
  fail "already-running LocalSend notifies the user what to do" "$(cat "$tmp/notify.log")"
pass "already-running LocalSend fails with a notification and does not launch another instance"

# Valid share launches LocalSend when it is not already running.
run_share file "$sample" || fail "valid share launches LocalSend"
grep -Fq "localsend --headless send $sample" "$tmp/systemd-run.log" ||
  fail "valid share invokes systemd-run for LocalSend" "$(cat "$tmp/systemd-run.log")"
[[ ! -s $tmp/notify.log ]] || fail "valid share sends no error notification" "$(cat "$tmp/notify.log")"
pass "valid share launches LocalSend"
