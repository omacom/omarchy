#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

grep -Fq 'kill "$pid"' "$ROOT/bin/omarchy-webapp-promote" &&
  fail "promote must not kill the chrome pid (session singleton / keep-alive)"
pass "promote does not kill the chrome process"

grep -E -q 'omarchy-chromium|chrome\.path|WebAppHideCaptionOnTilingLinux' \
  "$ROOT/bin/omarchy-webapp-browser" "$ROOT/bin/omarchy-webapp-promote" &&
  fail "webapp helpers must not name a local Chromium tree or fork-only flags"
pass "webapp helpers stay on the stock Chromium path"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
home="$tmp/home"
mkdir -p "$home"
export HOME="$home"

# Fake a chromium with no --install-and-launch-app switch.
cat >"$tmp/chrome" <<'SH'
#!/bin/bash
echo fake-chrome
SH
chmod +x "$tmp/chrome"

export OMARCHY_WEBAPP_CHROMIUM="$tmp/chrome"
bash "$ROOT/bin/omarchy-webapp-promote" "https://example.com/"
[[ ! -f $home/.local/state/omarchy/webapps.map ]] ||
  fail "promote is a no-op when the binary lacks --install-and-launch-app"
pass "promote no-ops on stock chromium"
