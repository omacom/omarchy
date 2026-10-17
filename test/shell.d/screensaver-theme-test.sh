#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
cleanup() {
  [[ -n ${pid:-} ]] && kill "$pid" 2>/dev/null
  rm -rf "$tmpdir"
}
trap cleanup EXIT

mkdir -p "$tmpdir/bin" "$tmpdir/home/.config/omarchy/branding" "$tmpdir/home/.local/state/omarchy/current/theme"

# No pgrep match -> the inner "is ttfx still running" loop never runs, so the
# outer loop just keeps respawning ttfx. That is all this test needs: one
# recorded invocation of the real command the script builds.
printf '#!/bin/bash\nexit 1\n' >"$tmpdir/bin/pgrep"
printf '#!/bin/bash\nexit 0\n' >"$tmpdir/bin/hyprctl"
printf '#!/bin/bash\nexit 0\n' >"$tmpdir/bin/pkill"
printf '#!/bin/bash\necho /dev/pts/9\n' >"$tmpdir/bin/tty"
printf '#!/bin/bash\necho "40 120"\n' >"$tmpdir/bin/stty"
cat >"$tmpdir/bin/ttfx" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_DIR/calls"
SH
chmod +x "$tmpdir/bin/"*

: >"$tmpdir/calls"
echo "branding art" >"$tmpdir/home/.config/omarchy/branding/screensaver.txt"

run_screensaver() {
  : >"$tmpdir/calls"
  PATH="$tmpdir/bin:$PATH" HOME="$tmpdir/home" TEST_DIR="$tmpdir" \
    timeout 1 "$ROOT/bin/omarchy-screensaver" </dev/null >/dev/null 2>&1 &
  pid=$!
  for (( attempt = 0; attempt < 100; attempt++ )); do
    [[ -s $tmpdir/calls ]] && break
    sleep 0.02
  done
  wait "$pid" 2>/dev/null || true
  head -n1 "$tmpdir/calls"
}

call=$(run_screensaver)
[[ $call == *"-i $tmpdir/home/.config/omarchy/branding/screensaver.txt"* ]] ||
  fail "falls back to the global branding file when the theme has no screensaver.txt" "$call"
pass "falls back to the global branding file when the theme has no screensaver.txt"

echo "theme art" >"$tmpdir/home/.local/state/omarchy/current/theme/screensaver.txt"

call=$(run_screensaver)
[[ $call == *"-i $tmpdir/home/.local/state/omarchy/current/theme/screensaver.txt"* ]] ||
  fail "a theme's screensaver.txt takes precedence over the global branding file" "$call"
pass "a theme's screensaver.txt takes precedence over the global branding file"

cat >"$tmpdir/home/.local/state/omarchy/current/theme/screensaver.conf" <<'CONF'
# a comment, and a blank line below should both be ignored

--frame-rate
30
--include-effects
matrix
CONF

call=$(run_screensaver)
[[ $call == *"--frame-rate 30 --include-effects matrix" ]] ||
  fail "a theme's screensaver.conf appends extra ttfx arguments, overriding the matching default" "$call"
pass "a theme's screensaver.conf appends extra ttfx arguments, overriding the matching default"
