#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

export HOME="$test_tmp/home"
export OMARCHY_TEST_XDG_SETTINGS_LOG="$test_tmp/xdg-settings"

cat >"$mock_bin/xdg-settings" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_XDG_SETTINGS_LOG"
SH
printf '#!/bin/bash\n' >"$mock_bin/vivaldi-stable"
printf '#!/bin/bash\n' >"$mock_bin/omarchy-notification-send"
chmod +x "$mock_bin"/*
export PATH="$mock_bin:$ROOT/bin:$PATH"

# An installed Vivaldi has no bundled extensions to check, so choosing it
# goes straight to saving the default instead of failing on the extension
# helper, which only knows the browsers it can wire extensions into.
omarchy-default-browser vivaldi >/dev/null 2>&1 ||
  fail "choosing an installed Vivaldi succeeds"
grep -Fxq "set default-web-browser vivaldi-stable.desktop" "$OMARCHY_TEST_XDG_SETTINGS_LOG" ||
  fail "choosing an installed Vivaldi saves it as the default browser"

pass "choosing an installed Vivaldi saves it as the default browser"
