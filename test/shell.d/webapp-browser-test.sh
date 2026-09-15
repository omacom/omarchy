#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export HOME="$scratch/home"
export XDG_CONFIG_HOME="$scratch/config"
export XDG_DATA_HOME="$scratch/data"
export OMARCHY_PATH="$ROOT"
export TEST_BIN="$scratch/bin"
export TEST_LAUNCH="$scratch/launch"
export TEST_DEFAULT="$scratch/default"
export TEST_XDG_CALLS="$scratch/xdg-calls"
mkdir -p "$HOME" "$TEST_BIN" "$XDG_DATA_HOME/applications"
export PATH="$TEST_BIN:$ROOT/bin:$PATH"

cat > "$TEST_BIN/omarchy-cmd-missing" <<'STUB'
#!/bin/bash
[[ ! -x "$TEST_BIN/$1" ]]
STUB
cat > "$TEST_BIN/omarchy-notification-send" <<'STUB'
#!/bin/bash
exit 0
STUB
cat > "$TEST_BIN/xdg-settings" <<'STUB'
#!/bin/bash
printf '%s:%s\n' "${BROWSER-unset}" "$*" >> "$TEST_XDG_CALLS"
[[ $1 == "get" ]] || exit 1
cat "$TEST_DEFAULT"
STUB
cat > "$TEST_BIN/setsid" <<'STUB'
#!/bin/bash
exec "$@"
STUB
cat > "$TEST_BIN/uwsm-app" <<'STUB'
#!/bin/bash
[[ $1 == "--" ]] || exit 1
shift
exec "$@"
STUB
for browser in chromium helium-browser; do
  cat > "$TEST_BIN/$browser" <<'STUB'
#!/bin/bash
printf '%s\0' "${0##*/}" "$@" > "$TEST_LAUNCH"
STUB
done
chmod +x "$TEST_BIN/"*
printf '[Desktop Entry]\nExec=chromium %%U\n' > "$XDG_DATA_HOME/applications/chromium.desktop"
printf '[Desktop Entry]\nExec=helium-browser %%U\n' > "$XDG_DATA_HOME/applications/helium.desktop"
printf 'zen.desktop\n' > "$TEST_DEFAULT"

[[ $(omarchy-default-webapp-browser) == "auto" ]] || fail "a fresh account starts in automatic mode"
[[ ! -e $XDG_CONFIG_HOME/omarchy/webapp-browser ]] || fail "reading the preference creates no config"
url='https://example.org/reports/weekly?x=1&y=2#section'
BROWSER=omarchy-launch-browser omarchy-launch-webapp "$url"
mapfile -d '' -t launch < "$TEST_LAUNCH"
[[ ${launch[0]} == "chromium" && ${launch[1]} == "--app=$url" ]] || fail "automatic Zen default falls back to Chromium with the full URL"
grep -Fqx 'unset:get default-web-browser' "$TEST_XDG_CALLS" || fail "XDG lookup excludes the BROWSER wrapper"
pass "automatic mode preserves the existing supported-browser fallback"

omarchy-default-webapp-browser helium
[[ $(omarchy-default-webapp-browser) == "helium.desktop" ]] || fail "selection persists in XDG_CONFIG_HOME"
omarchy-launch-webapp "$url" '--class=An app'
mapfile -d '' -t launch < "$TEST_LAUNCH"
[[ ${launch[0]} == "helium-browser" && ${launch[1]} == "--app=$url" && ${launch[2]} == "--class=An app" && ${#launch[@]} == 3 ]] || fail "Helium receives complete literal URL and extra arguments"
[[ $(cat "$TEST_DEFAULT") == "zen.desktop" ]] || fail "web app choice leaves the regular default unchanged"
pass "Helium web apps are independent of the regular browser"

if omarchy-default-webapp-browser zen >/dev/null 2>&1; then fail "unsupported native app mode cannot be selected"; fi
[[ $(omarchy-default-webapp-browser) == "helium.desktop" ]] || fail "invalid selection preserves the previous preference"
rm "$TEST_BIN/helium-browser"
if omarchy-default-webapp-browser helium >/dev/null 2>&1; then fail "missing browser cannot be selected"; fi
rm "$TEST_LAUNCH"
if omarchy-launch-webapp "$url" >/dev/null 2>&1; then fail "removed explicit browser must not silently switch profiles"; fi
[[ ! -e $TEST_LAUNCH ]] || fail "removed explicit browser launches nothing"
pass "invalid and unavailable explicit browsers fail without changing browser profiles"

omarchy-default-webapp-browser auto
[[ $(omarchy-default-webapp-browser) == "auto" ]] || fail "automatic mode can be restored"
omarchy-launch-webapp "$url"
mapfile -d '' -t launch < "$TEST_LAUNCH"
[[ ${launch[0]} == "chromium" ]] || fail "automatic mode restores fallback"
pass "returning to automatic mode restores the previous behavior"
