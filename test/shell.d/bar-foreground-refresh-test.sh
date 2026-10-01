#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell unavailable; skipping transparent foreground lifecycle"
  exit 0
fi
require_command python3
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/config" "$work/runtime" "$work/home" "$work/bin"
chmod 700 "$work/runtime"

# Run the actual production functions, timer and Process in an isolated QML
# root, without loading bar surfaces or connecting to the user's compositor.
python3 - "$ROOT" "$work/config/shell.qml" <<'PY'
from pathlib import Path
import sys
root, output = Path(sys.argv[1]), Path(sys.argv[2])
bar = (root / "shell/plugins/bar/Bar.qml").read_text()
start = bar.index("  function colorHex(")
end = bar.index("  FileView {", start)
fixture = (root / "test/shell.d/fixtures/bar-foreground/shell.qml").read_text()
output.write_text(fixture.replace("  // PRODUCTION_SAMPLER", bar[start:end].replace("Util.clamp", "util.clamp")))
PY

cat >"$work/bin/omarchy-bar-text-color" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$SAMPLE_CALLS"
if mkdir "$SAMPLE_FIRST" 2>/dev/null; then
  while [[ ! -e $SAMPLE_GATE ]]; do sleep 0.01; done
  if [[ $SCENARIO == "failure" || $SCENARIO == "failure-latest" ]]; then
    echo invalid
    exit 1
  fi
  echo '#111111'
else
  echo '#222222'
fi
STUB
chmod +x "$work/bin/omarchy-bar-text-color"

for scenario in foreground contrast position size background rapid toggle off failure early failure-latest; do
  rm -rf "$work/first" "$work/gate" "$work/calls"
  env -u WAYLAND_DISPLAY -u DISPLAY -u HYPRLAND_INSTANCE_SIGNATURE \
    HOME="$work/home" XDG_RUNTIME_DIR="$work/runtime" OMARCHY_PATH="$ROOT" \
    PATH="$work/bin:$PATH" QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= \
    QT_STYLE_OVERRIDE= QT_QUICK_BACKEND=software SCENARIO="$scenario" \
    SAMPLE_GATE="$work/gate" SAMPLE_FIRST="$work/first" SAMPLE_CALLS="$work/calls" \
    timeout 8 quickshell -p "$work/config" --no-color >"$work/log" 2>&1 || {
      cat "$work/log" >&2
      fail "transparent foreground $scenario fixture exits cleanly"
    }
  if ! grep -q "RESULT pass $scenario" "$work/log" || grep -q 'RESULT fail' "$work/log"; then
    cat "$work/log" >&2
    fail "transparent foreground $scenario converges without stale output or extra samples"
  fi
  case "$scenario" in
  foreground | early) expected='top 30 #444444 #eeeeee' ;;
  contrast) expected='top 30 #333333 #dddddd' ;;
  position) expected='bottom 30 #333333 #eeeeee' ;;
  size) expected='top 42 #333333 #eeeeee' ;;
  rapid) expected='right 42 #444444 #dddddd' ;;
  *) expected='top 30 #333333 #eeeeee' ;;
  esac
  [[ $(tail -n 1 "$work/calls") == "$expected" ]] || fail "transparent foreground $scenario samples the latest inputs"
  pass "transparent foreground $scenario converges without stale output or extra samples"
done
