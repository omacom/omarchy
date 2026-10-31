#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell unavailable; skipping native brightness lifecycle"
  exit 0
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
quickshell_binary=$(command -v quickshell)
timeout_binary=$(command -v timeout)
mkdir -p "$work/config" "$work/bin" "$work/runtime" "$work/home"
chmod 700 "$work/runtime"
cp "$SHELL_TEST_DIR/fixtures/brightness/shell.qml" "$work/config/shell.qml"
ln -s "$ROOT/shell/Ui" "$work/config/Ui"
ln -s "$ROOT/shell/Commons" "$work/config/Commons"
ln -s "$ROOT/shell/plugins/panels/monitor" "$work/config/Monitor"
ln -s "$(command -v sleep)" "$work/bin/sleep"

cat >"$work/bin/omarchy-brightness-display" <<'SH'
#!/bin/bash
sleep 0.15
case ${4:-} in
  80%) exit 1 ;;
  60%) kill -KILL "$$" ;;
esac
SH
chmod +x "$work/bin/omarchy-brightness-display"

for mode in normal missing; do
  if [[ $mode == "missing" ]]; then
    mv "$work/bin/omarchy-brightness-display" "$work/writer"
  fi
  HOME="$work/home" XDG_RUNTIME_DIR="$work/runtime" PATH="$work/bin" \
    OMARCHY_PATH="$ROOT" OMARCHY_BRIGHTNESS_TEST_MODE="$mode" \
    QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= QT_STYLE_OVERRIDE= QT_QUICK_BACKEND=software \
    "$timeout_binary" 20 "$quickshell_binary" -p "$work/config" --no-color >"$work/log" 2>&1 || {
      cat "$work/log" >&2
      fail "native brightness lifecycle runs ($mode)"
    }
  if ! rg -q 'BRIGHTNESS_RUNTIME_PASS' "$work/log" || rg -q 'FAIL!|BRIGHTNESS_RUNTIME_FAIL' "$work/log"; then
    cat "$work/log" >&2
    fail "native brightness lifecycle assertions pass ($mode)"
  fi
  pass "native brightness process and slider lifecycle ($mode)"
done
