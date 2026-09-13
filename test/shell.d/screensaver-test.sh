#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command timeout

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mock_bin="$tmp_dir/bin"
test_home="$tmp_dir/home"
ttfx_log="$tmp_dir/ttfx.log"
mkdir -p "$mock_bin" "$test_home"

cat >"$mock_bin/ttfx" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_TTFX_LOG"
[[ ${OMARCHY_TEST_TTFX_FAIL:-false} != "true" ]] || exit 1
sleep 0.3
STUB

cat >"$mock_bin/hyprctl" <<'STUB'
#!/bin/bash
if [[ $1 == "activewindow" ]]; then
  echo '{"class":"org.omarchy.screensaver"}'
fi
exit 0
STUB

printf '#!/bin/bash\nexit 0\n' >"$mock_bin/pkill"
chmod +x "$mock_bin"/*

run_screensaver() {
  HOME="$test_home" OMARCHY_PATH="$ROOT" OMARCHY_TEST_TTFX_LOG="$ttfx_log" PATH="$mock_bin:$PATH" \
    timeout 5 "$ROOT/bin/omarchy-screensaver" >/dev/null 2>&1
}

# Missing branding falls back to the stock wordmark, and a keypress dismisses.
: >"$ttfx_log"
echo x | run_screensaver || fail "screensaver exits cleanly on a keypress"
grep -q -- "-i $ROOT/logo.txt " "$ttfx_log" || fail "missing branding falls back to the stock logo" "$(<"$ttfx_log")"
pass "missing branding falls back to the stock logo"

# User branding is preferred when present.
mkdir -p "$test_home/.config/omarchy/branding"
printf 'custom\n' >"$test_home/.config/omarchy/branding/screensaver.txt"
: >"$ttfx_log"
echo x | run_screensaver || fail "screensaver exits cleanly on a keypress"
grep -q -- "-i $test_home/.config/omarchy/branding/screensaver.txt " "$ttfx_log" || fail "user branding is used when present" "$(<"$ttfx_log")"
pass "user branding is used when present"

# A ttfx that cannot start must end the screensaver rather than being
# relaunched forever with no way to read input.
: >"$ttfx_log"
OMARCHY_TEST_TTFX_FAIL=true run_screensaver </dev/null || fail "screensaver exits when ttfx fails to start"
launches=$(wc -l <"$ttfx_log")
(( launches == 1 )) || fail "failed ttfx is not relaunched in a loop" "ttfx launched $launches times"
pass "failed ttfx ends the screensaver instead of looping"
