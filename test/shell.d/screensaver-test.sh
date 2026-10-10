#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

stub_bin="$tmp_dir/bin"
mkdir -p "$stub_bin" "$tmp_dir/home/.config/omarchy/branding" "$tmp_dir/omarchy"

printf 'fallback-logo\n' >"$tmp_dir/omarchy/logo.txt"
printf 'user-branding\n' >"$tmp_dir/home/.config/omarchy/branding/screensaver.txt"

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash
if [[ ${1:-} == activewindow ]]; then
  printf '%s\n' '{"class":"org.omarchy.screensaver"}'
fi
exit 0
SH

cat >"$stub_bin/stty" <<'SH'
#!/bin/bash
printf '%s\n' "60 200"
SH

cat >"$stub_bin/pkill" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$stub_bin/ttfx" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TTFX_LOG"
count=0
[[ -f $TTFX_COUNT ]] && count=$(<"$TTFX_COUNT")
count=$((count + 1))
printf '%s\n' "$count" >"$TTFX_COUNT"
if (( count <= ${TTFX_SUCCESSES:-0} )); then
  exit 0
fi
exit "${TTFX_EXIT:-1}"
SH

chmod +x "$stub_bin"/*

run_screensaver() {
  : >"$tmp_dir/ttfx.log"
  : >"$tmp_dir/ttfx.count"
  PATH="$stub_bin:$PATH" \
    HOME="$tmp_dir/home" \
    OMARCHY_PATH="$tmp_dir/omarchy" \
    TTFX_LOG="$tmp_dir/ttfx.log" \
    TTFX_COUNT="$tmp_dir/ttfx.count" \
    TTFX_SUCCESSES="${TTFX_SUCCESSES:-0}" \
    TTFX_EXIT="${TTFX_EXIT:-1}" \
    timeout --kill-after=1s 3s bash "$ROOT/bin/omarchy-screensaver" </dev/null >/dev/null
}

status=0
run_screensaver || status=$?
(( status != 124 )) || fail "a missing-file screensaver does not busy-loop" "timeout after a failed ttfx"
[[ $(<"$tmp_dir/ttfx.count") == 1 ]] || fail "ttfx is launched once when the user branding file exists" "$(<"$tmp_dir/ttfx.count")"
[[ $(<"$tmp_dir/ttfx.log") == *"$tmp_dir/home/.config/omarchy/branding/screensaver.txt"* ]] ||
  fail "the user branding file is preferred when it exists" "$(<"$tmp_dir/ttfx.log")"
pass "the user branding file is preferred when it exists"

rm -f "$tmp_dir/home/.config/omarchy/branding/screensaver.txt"
status=0
run_screensaver || status=$?
(( status != 124 )) || fail "a missing branding file does not busy-loop" "timeout after a failed ttfx"
[[ $(<"$tmp_dir/ttfx.count") == 1 ]] || fail "ttfx is launched once when falling back to logo.txt" "$(<"$tmp_dir/ttfx.count")"
[[ $(<"$tmp_dir/ttfx.log") == *"$tmp_dir/omarchy/logo.txt"* ]] ||
  fail "a missing branding file falls back to logo.txt" "$(<"$tmp_dir/ttfx.log")"
pass "a missing branding file falls back to logo.txt"

rm -f "$tmp_dir/omarchy/logo.txt"
status=0
run_screensaver || status=$?
(( status != 124 )) || fail "a screensaver with no input file does not busy-loop" "timeout with no branding"
[[ ! -s $tmp_dir/ttfx.log ]] || fail "ttfx is not launched when no input file exists" "$(<"$tmp_dir/ttfx.log")"
(( status == 0 )) || fail "a screensaver with no input file exits cleanly" "exit $status"
pass "a screensaver with no input file exits instead of looping"

printf 'fallback-logo\n' >"$tmp_dir/omarchy/logo.txt"
TTFX_SUCCESSES=2
status=0
run_screensaver || status=$?
(( status != 124 )) || fail "a successful effect cycle does not hang" "timeout after successful ttfx runs"
[[ $(<"$tmp_dir/ttfx.count") == 3 ]] || fail "a finished effect is relaunched until ttfx fails" "$(<"$tmp_dir/ttfx.count")"
pass "a finished effect is relaunched until ttfx fails"
