#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub_bin="$tmpdir/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == "getoption" ]]; then
  echo '{"int": 0}'
fi
exit 0
SH

cat >"$stub_bin/omarchy-capture-region" <<'SH'
#!/bin/bash
echo "12345"
echo "0,0 100x100"
SH

cat >"$stub_bin/grim" <<'SH'
#!/bin/bash
touch "$3"
exit 0
SH

cat >"$stub_bin/wl-copy" <<'SH'
#!/bin/bash
cat >/dev/null
exit 0
SH

cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_NOTIFICATION_ARGS"
SH

chmod +x "$stub_bin"/*

export PATH="$stub_bin:$ROOT/bin:$PATH"
export OMARCHY_TEST_NOTIFICATION_ARGS="$tmpdir/notification-args"
export OMARCHY_SCREENSHOT_DIR="$tmpdir/screenshots"
mkdir -p "$OMARCHY_SCREENSHOT_DIR"

"$ROOT/bin/omarchy-capture-screenshot"

grep -Fx -- "-i" "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null || fail "omarchy-capture-screenshot passes -i flag"
grep -Fx -- "applets-screenshooter" "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null || fail "omarchy-capture-screenshot sets applets-screenshooter icon"
grep -Fx -- "-g" "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null || fail "omarchy-capture-screenshot passes -g flag"
grep -Fx -- "" "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null || fail "omarchy-capture-screenshot sets screenshot glyph"

pass "omarchy-capture-screenshot sends notification with icon and glyph"
