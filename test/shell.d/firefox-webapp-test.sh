#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
mock_bin="$tmpdir/bin"
mkdir -p "$home/.local/share/applications" "$mock_bin" "$tmpdir/profiles"

# Deterministic flavor detection: pretend the xdg default is Chromium
# (not Firefox-based), so the launcher falls back to firefox unless told otherwise.
cat >"$mock_bin/xdg-settings" <<'SH'
#!/bin/bash
echo chromium.desktop
SH
chmod +x "$mock_bin/xdg-settings"

export PATH="$mock_bin:$ROOT/bin:$PATH"
export HOME="$home"
export FIREFOX_SSB_BASE="$tmpdir/profiles"
unset FIREFOX_FLAVOR || true
unset FIREFOX_BIN || true

launcher="$ROOT/bin/omarchy-launch-firefox-webapp"

out=$(DRY_RUN=1 bash "$launcher" "https://youtube.com/" 2>"$tmpdir/err") ||
  fail "firefox launcher dry-runs an https URL" "$(cat "$tmpdir/err")"
grep -Fq "FLAVOR=firefox" <<<"$out" || fail "firefox launcher defaults to the firefox flavor" "$out"
grep -Fq "BINARY=firefox" <<<"$out" || fail "firefox launcher uses the firefox binary" "$out"
grep -Fq -- "--no-remote" <<<"$out" || fail "firefox launcher isolates with --no-remote (Mint parity)" "$out"
grep -Fq -- "--new-window" <<<"$out" || fail "firefox launcher opens a new window" "$out"
grep -Fq "https://youtube.com/" <<<"$out" || fail "firefox launcher keeps the URL" "$out"
pass "firefox launcher dry-runs with an isolated instance"

wm_class=$(grep '^WM_CLASS=' <<<"$out" | cut -d= -f2)
[[ $wm_class == FFWebApp-* ]] || fail "firefox launcher derives an FFWebApp window class" "$out"

out=$(DRY_RUN=1 bash "$launcher" --browser zen "https://youtube.com/" 2>"$tmpdir/err") ||
  fail "firefox launcher accepts --browser zen" "$(cat "$tmpdir/err")"
grep -Fq "FLAVOR=zen" <<<"$out" || fail "firefox launcher reports the zen flavor" "$out"
grep -Fq "zen-browser" <<<"$out" || fail "firefox launcher uses the zen binary" "$out"
grep -Fq "ZenWebApp-" <<<"$out" || fail "firefox launcher derives a Zen window class" "$out"
pass "firefox launcher supports the zen flavor"

out=$(DRY_RUN=1 bash "$launcher" "youtube.com" 2>"$tmpdir/err") ||
  fail "firefox launcher normalizes a schemeless URL" "$(cat "$tmpdir/err")"
grep -Fq "https://youtube.com" <<<"$out" || fail "firefox launcher prefixes https" "$out"
pass "firefox launcher normalizes schemeless URLs"

for url in "javascript:alert(1)" "file:///etc/passwd" "data:text/html,hi" "https://exa mple.com"; do
  if DRY_RUN=1 bash "$launcher" "$url" >"$tmpdir/out" 2>"$tmpdir/err"; then
    fail "firefox launcher refuses '$url'"
  fi
done
pass "firefox launcher refuses non-http(s) URLs"

if DRY_RUN=1 bash "$launcher" --browser bogus "https://youtube.com/" >"$tmpdir/out" 2>"$tmpdir/err"; then
  fail "firefox launcher refuses an unknown flavor"
fi
pass "firefox launcher refuses unknown flavors"

if DRY_RUN=1 bash "$launcher" >"$tmpdir/out" 2>"$tmpdir/err"; then
  fail "firefox launcher requires a URL"
fi
pass "firefox launcher requires a URL"

# xdg default flavor detection follows the default browser when Firefox-based.
cat >"$mock_bin/xdg-settings" <<'SH'
#!/bin/bash
echo zen.desktop
SH
out=$(DRY_RUN=1 bash "$launcher" "https://youtube.com/" 2>"$tmpdir/err") ||
  fail "firefox launcher reads the xdg default browser" "$(cat "$tmpdir/err")"
grep -Fq "FLAVOR=zen" <<<"$out" || fail "firefox launcher follows an xdg zen default" "$out"
pass "firefox launcher follows a Firefox-based xdg default"

cat >"$mock_bin/xdg-settings" <<'SH'
#!/bin/bash
echo chromium.desktop
SH
out=$(FIREFOX_FLAVOR=librewolf DRY_RUN=1 bash "$launcher" "https://youtube.com/" 2>"$tmpdir/err") ||
  fail "firefox launcher honors FIREFOX_FLAVOR" "$(cat "$tmpdir/err")"
grep -Fq "FLAVOR=librewolf" <<<"$out" || fail "firefox launcher uses FIREFOX_FLAVOR over xdg" "$out"
pass "firefox launcher honors FIREFOX_FLAVOR"

# Installer wrapper writes a Chromium-style desktop entry for Firefox web apps.
expected_class=$(DRY_RUN=1 bash "$launcher" "https://youtube.com/" | grep '^WM_CLASS=' | cut -d= -f2)
if HOME="$home" bash "$ROOT/bin/omarchy-webapp-install-firefox" "YouTube" "https://youtube.com/" "youtube" >"$tmpdir/out" 2>"$tmpdir/err"; then
  :
else
  fail "firefox webapp install accepts an https URL" "$(cat "$tmpdir/err")"
fi
desktop="$home/.local/share/applications/YouTube.desktop"
[[ -f $desktop ]] || fail "firefox webapp install writes a desktop file"
grep -Fxq 'Exec=omarchy-launch-firefox-webapp "https://youtube.com/"' "$desktop" ||
  fail "firefox webapp install launches the URL with the firefox launcher" "$(cat "$desktop")"
grep -Fxq "StartupWMClass=$expected_class" "$desktop" ||
  fail "firefox webapp install records the window class" "$(cat "$desktop")"
pass "firefox webapp install writes a firefox desktop entry"

if HOME="$home" bash "$ROOT/bin/omarchy-webapp-install-firefox" "YouTube-Zen" "https://youtube.com/" "youtube" "zen" >"$tmpdir/out" 2>"$tmpdir/err"; then
  :
else
  fail "firefox webapp install accepts a flavor" "$(cat "$tmpdir/err")"
fi
zen_desktop="$home/.local/share/applications/YouTube-Zen.desktop"
grep -Fxq 'Exec=omarchy-launch-firefox-webapp --browser zen "https://youtube.com/"' "$zen_desktop" ||
  fail "firefox webapp install keeps the flavor in Exec" "$(cat "$zen_desktop")"
grep -Fq "StartupWMClass=ZenWebApp-" "$zen_desktop" ||
  fail "firefox webapp install records the zen window class" "$(cat "$zen_desktop")"
pass "firefox webapp install writes a zen desktop entry"

if HOME="$home" bash "$ROOT/bin/omarchy-webapp-install-firefox" "Bad" "https://youtube.com/" "youtube" "bogus" >"$tmpdir/out" 2>"$tmpdir/err"; then
  fail "firefox webapp install refuses an unknown flavor"
fi
[[ ! -e $home/.local/share/applications/Bad.desktop ]] || fail "firefox webapp install writes nothing for an unknown flavor"
pass "firefox webapp install refuses unknown flavors"

# Focus-or-launch passes the pattern and the firefox launch command through.
cat >"$mock_bin/omarchy-launch-or-focus" <<'SH'
#!/bin/bash
printf 'pattern=%s\ncommand=%s\n' "$1" "$2" >"$OMARCHY_TEST_FOCUS_LOG"
SH
chmod +x "$mock_bin/omarchy-launch-or-focus"
export OMARCHY_TEST_FOCUS_LOG="$tmpdir/focus"
bash "$ROOT/bin/omarchy-launch-or-focus-firefox-webapp" "YouTube" "https://youtube.com/" 2>"$tmpdir/err" ||
  fail "firefox or-focus wrapper runs" "$(cat "$tmpdir/err")"
grep -Fq "pattern=YouTube" "$tmpdir/focus" || fail "firefox or-focus wrapper forwards the pattern" "$(cat "$tmpdir/focus")"
grep -Fq "omarchy-launch-firefox-webapp https://youtube.com/" "$tmpdir/focus" ||
  fail "firefox or-focus wrapper builds the firefox launch command" "$(cat "$tmpdir/focus")"
pass "firefox or-focus wrapper delegates with the firefox launcher"

# New commands carry slim self-documenting metadata (mirrors test/cli).
for binary in omarchy-launch-firefox-webapp omarchy-launch-or-focus-firefox-webapp omarchy-webapp-install-firefox; do
  header=$(head -n 80 "$ROOT/bin/$binary")
  grep -q '^# omarchy:summary=' <<<"$header" || fail "metadata summary is present: $binary"
  ! grep -q '^# omarchy:binary=' <<<"$header" || fail "metadata does not repeat inferred binary: $binary"
  ! grep -q '^# omarchy:args=$' <<<"$header" || fail "metadata does not include empty args: $binary"
  ! grep -Eq '^# omarchy:(legacy|usage|visibility|mutates|interactive)=' <<<"$header" ||
    fail "metadata avoids removed fields: $binary"
done
pass "firefox webapp commands carry slim metadata"

new_bins=$(printf '%s\n' "$ROOT/bin/omarchy-launch-firefox-webapp" "$ROOT/bin/omarchy-launch-or-focus-firefox-webapp" "$ROOT/bin/omarchy-webapp-install-firefox")
raw_command_checks=$(grep -l 'command -v' $new_bins || true)
[[ -z $raw_command_checks ]] || fail "firefox webapp commands use command helpers" "$raw_command_checks"
raw_notifications=$(grep -l -P '^[[:space:]]*[^#[:space:]].*\bnotify-send\b' $new_bins || true)
[[ -z $raw_notifications ]] || fail "firefox webapp commands never call notify-send" "$raw_notifications"
pass "firefox webapp commands follow bin style"
