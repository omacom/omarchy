#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin" "$tmp_dir/home/.local/share/applications"

write_desktop() {
  local name="$1" exec_line="$2"

  cat >"$tmp_dir/home/.local/share/applications/$name" <<EOF
[Desktop Entry]
Exec=$exec_line
EOF
}

# Ecosia is Chromium-based (AUR: ecosia-browser-bin) and supports --app like
# the other browsers already recognized here, so it should launch under its
# own profile rather than silently falling back to chromium.desktop.
write_desktop "org.ecosia.Browser.desktop" "ecosiabrowser %U"
write_desktop "chromium.desktop" "chromium %U"

cat >"$tmp_dir/bin/xdg-settings" <<'SH'
#!/bin/bash
printf '%s\n' "$OMARCHY_TEST_BROWSER"
SH

cat >"$tmp_dir/bin/setsid" <<'SH'
#!/bin/bash
exec "$@"
SH

cat >"$tmp_dir/bin/uwsm-app" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_LAUNCH"
SH

chmod +x "$tmp_dir/bin"/*

launch_webapp() {
  local browser="$1" url="$2"

  : >"$tmp_dir/launch"
  OMARCHY_TEST_BROWSER="$browser" OMARCHY_TEST_LAUNCH="$tmp_dir/launch" \
    HOME="$tmp_dir/home" PATH="$tmp_dir/bin:$PATH" \
    "$ROOT/bin/omarchy-launch-webapp" "$url"
}

launch_webapp "org.ecosia.Browser.desktop" "https://app.zoom.us/wc/home"
grep -Fq "ecosiabrowser --app=https://app.zoom.us/wc/home" "$tmp_dir/launch" ||
  fail "webapp launch uses the Ecosia binary when Ecosia is the default browser" \
    "launch: $(cat "$tmp_dir/launch")"
pass "webapp launch recognizes org.ecosia.Browser.desktop instead of falling back to chromium"

launch_webapp "some-unknown-browser.desktop" "https://example.com"
grep -Fq "chromium --app=https://example.com" "$tmp_dir/launch" ||
  fail "webapp launch still falls back to chromium.desktop for an unrecognized browser" \
    "launch: $(cat "$tmp_dir/launch")"
pass "webapp launch keeps the chromium.desktop fallback for browsers outside the recognized list"
