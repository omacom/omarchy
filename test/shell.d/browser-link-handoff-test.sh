#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
applications="$test_tmp/data/applications"
mkdir -p "$mock_bin" "$applications" "$test_tmp/config" "$test_tmp/system/applications" "$test_tmp/home"

export HOME="$test_tmp/home"
export XDG_CONFIG_HOME="$test_tmp/config"
export XDG_CONFIG_DIRS="$test_tmp/etc"
export XDG_DATA_HOME="$test_tmp/data"
export XDG_DATA_DIRS="$test_tmp/system"
export XDG_CURRENT_DESKTOP=Hyprland
export PATH="$mock_bin:$ROOT/bin:$PATH"
unset BROWSER

for command in chromium firefox omarchy-notification-send update-desktop-database; do
  printf '#!/bin/bash\n' >"$mock_bin/$command"
done
chmod +x "$mock_bin"/*

for browser in chromium firefox; do
  printf '[Desktop Entry]\nType=Application\nName=%s\nExec=%s %%U\nMimeType=x-scheme-handler/http;x-scheme-handler/https;text/html;\n' \
    "$browser" "$browser" >"$test_tmp/system/applications/$browser.desktop"
done

cp "$ROOT/applications/omarchy-browser.desktop" "$applications/"
cp "$ROOT/config/hyprland-mimeapps.list" "$XDG_CONFIG_HOME/"

grep -qxF "Exec=omarchy-launch-browser %U" "$applications/omarchy-browser.desktop" ||
  fail "the link entry opens links through omarchy-launch-browser"
grep -qxF "NoDisplay=true" "$applications/omarchy-browser.desktop" ||
  fail "the link entry stays out of the app launcher"
pass "the link entry opens links through omarchy-launch-browser, out of the launcher's sight"

omarchy-default-browser firefox || fail "setting the default browser succeeds behind the link entry"
grep -qxF "x-scheme-handler/https=firefox.desktop" "$XDG_CONFIG_HOME/mimeapps.list" ||
  fail "setting the default browser records it in mimeapps.list" "$(cat "$XDG_CONFIG_HOME/mimeapps.list")"
[[ $(omarchy-cmd-default-browser) == "firefox.desktop" ]] ||
  fail "the default browser is the one behind the link entry" "actual: $(omarchy-cmd-default-browser)"
[[ $(omarchy-default-browser) == "firefox" ]] || fail "the default browser reads back by name"
pass "setting the default browser keeps the link entry in front of it"

[[ $(xdg-mime query default x-scheme-handler/https) == "omarchy-browser.desktop" ]] ||
  fail "xdg-open sends links to the link entry"
if command -v gio >/dev/null; then
  gio_default=$(gio mime x-scheme-handler/https)
  gio_default=${gio_default%%$'\n'*}
  [[ $gio_default == *"omarchy-browser.desktop"* ]] ||
    fail "the desktop portal sends links to the link entry" "$gio_default"
fi
pass "xdg-open and the desktop portal send links to the link entry"

omarchy-default-browser chromium || fail "changing the default browser succeeds behind the link entry"
[[ $(omarchy-cmd-default-browser) == "chromium.desktop" ]] || fail "a change of default browser takes effect"
pass "a change of default browser takes effect"

rm "$XDG_CONFIG_HOME/mimeapps.list"
[[ $(omarchy-cmd-default-browser) != "omarchy-browser.desktop" ]] ||
  fail "the link entry is never taken for the browser, which would launch itself"
pass "the link entry is never taken for the browser"
