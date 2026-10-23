#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command xdg-settings
require_command xdg-mime

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/config" "$stage/data/applications" "$stage/bin" "$stage/etc"
export XDG_CONFIG_HOME="$stage/config" XDG_CONFIG_DIRS="$stage/etc"
export XDG_DATA_HOME="$stage/data" XDG_DATA_DIRS="$stage/system"
export XDG_CURRENT_DESKTOP=Hyprland
export PATH="$stage/bin:$ROOT/default/xdg-utils:$ROOT/bin:$PATH"
unset BROWSER

for browser in old-browser new-browser; do
  printf '#!/bin/bash\nexit 0\n' >"$stage/bin/$browser"
  chmod +x "$stage/bin/$browser"
  printf '[Desktop Entry]\nType=Application\nName=%s\nExec=%s %%U\nMimeType=text/html;x-scheme-handler/http;x-scheme-handler/https;\n' \
    "$browser" "$browser" >"$stage/data/applications/$browser.desktop"
done
cp "$ROOT/applications/omarchy-browser.desktop" "$stage/data/applications/"
cp "$ROOT/config/hyprland-mimeapps.list" "$stage/config/"
seed_defaults() {
  printf '[Default Applications]\ntext/html=old-browser.desktop\nx-scheme-handler/http=old-browser.desktop\nx-scheme-handler/https=old-browser.desktop\nx-scheme-handler/about=old-browser.desktop\nx-scheme-handler/unknown=old-browser.desktop\n' >"$stage/config/mimeapps.list"
}
seed_defaults
if /usr/bin/xdg-settings set default-web-browser new-browser.desktop; then
  fail "the regression reproduces with the system setter"
fi
grep -qxF 'text/html=new-browser.desktop' "$stage/config/mimeapps.list" || fail "the failed setter changes HTML"
grep -qxF 'x-scheme-handler/http=omarchy-browser.desktop' "$stage/config/mimeapps.list" || fail "the failed setter rolls HTTP back to the router"
grep -qxF 'x-scheme-handler/https=old-browser.desktop' "$stage/config/mimeapps.list" || fail "the failed setter leaves HTTPS on the old browser"
pass "the system setter reproduces the partial native-browser change"

seed_defaults
BROWSER=omarchy-launch-browser xdg-settings set default-web-browser new-browser.desktop || fail "native setter works with shell launcher inherited"
for type in text/html x-scheme-handler/{http,https,about,unknown}; do
  [[ $(XDG_CURRENT_DESKTOP= xdg-mime query default "$type") == "new-browser.desktop" ]] || fail "native setter updates $type"
done
[[ $(xdg-settings get default-web-browser) == "new-browser.desktop" ]] || fail "native getter sees the selected browser"
[[ $(xdg-settings check default-web-browser new-browser.desktop) == "yes" ]] || fail "native default check succeeds"
[[ $(xdg-settings check default-web-browser old-browser.desktop) == "no" ]] || fail "old browser is no longer default"
[[ $(omarchy-cmd-default-browser) == "new-browser.desktop" ]] || fail "Omarchy launcher sees the native choice"
pass "native set, get and check agree with Omarchy on the chosen browser"

for scheme in http https; do
  [[ $(xdg-mime query default "x-scheme-handler/$scheme") == "omarchy-browser.desktop" ]] || fail "link routing is retained for $scheme"
done
if command -v gio >/dev/null; then
  [[ $(gio mime x-scheme-handler/https | head -1) == *omarchy-browser.desktop* ]] || fail "portal lookup retains Omarchy link routing"
fi
[[ $(xdg-settings get default-url-scheme-handler https) == "omarchy-browser.desktop" ]] || fail "scheme-handler queries keep the system routing view"
pass "xdg-open and portal routing retain the existing browser focus handoff"

# Changes are reversible, not a special case for one desktop ID.
xdg-settings set default-web-browser old-browser.desktop
[[ $(xdg-settings get default-web-browser) == "old-browser.desktop" ]] || fail "a later native choice takes effect"
if BROWSER=new-browser xdg-settings set default-web-browser new-browser.desktop >/dev/null 2>&1; then
  fail "a custom BROWSER override retains system refusal semantics"
fi
pass "later choices work and a custom BROWSER override is respected"

before=$(cat "$stage/config/mimeapps.list")
if xdg-settings set default-web-browser missing.desktop >/dev/null 2>&1; then fail "a missing browser is rejected"; fi
[[ $(cat "$stage/config/mimeapps.list") == "$before" ]] || fail "a missing browser leaves defaults unchanged"
if xdg-settings set default-web-browser ../bad.desktop >/dev/null 2>&1; then fail "an invalid desktop ID is rejected"; fi
pass "system validation rejects missing and invalid browsers"

printf '[Default Applications]\nx-scheme-handler/http=new-browser.desktop\nx-scheme-handler/https=new-browser.desktop\n' >"$stage/config/hyprland-mimeapps.list"
[[ $(xdg-settings get default-web-browser) == "$(/usr/bin/xdg-settings get default-web-browser)" ]] || fail "custom desktop routing keeps system lookup"
[[ $(xdg-settings get default-url-scheme-handler https) == "new-browser.desktop" ]] || fail "other properties use the system utility"
if xdg-settings unsupported-operation >"$stage/actual" 2>&1; then fail "unsupported operation fails"; fi
if /usr/bin/xdg-settings unsupported-operation >"$stage/expected" 2>&1; then fail "system unsupported operation fails"; fi
cmp "$stage/actual" "$stage/expected" || fail "other operations preserve system diagnostics"
pass "custom handlers and unrelated operations pass through unchanged"
