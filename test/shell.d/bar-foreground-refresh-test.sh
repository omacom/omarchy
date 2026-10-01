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
ln -s "$ROOT/shell/Commons" "$work/config/Commons"
state_dir="$work/home/.local/state/omarchy"
mkdir -p "$state_dir/current/theme"
cat >"$state_dir/current/theme/shell.toml" <<'TOML'
[bar]
size-horizontal = 30
size-vertical = 36
scale-with-font = false
TOML
: >"$state_dir/wallpaper-a.png"
: >"$state_dir/wallpaper-b.png"

# Run the actual production geometry bindings, functions, timer, Process and
# wallpaper FileView in an isolated QML root, without loading bar surfaces or
# connecting to the user's compositor.
python3 - "$ROOT" "$work/config/shell.qml" <<'PY'
from pathlib import Path
import sys
root, output = Path(sys.argv[1]), Path(sys.argv[2])
bar = (root / "shell/plugins/bar/Bar.qml").read_text()
start = bar.index("  function colorHex(")
end = bar.index("  function runProcess(", start)
geometry_start = bar.index("  readonly property bool vertical:")
geometry_end = bar.index("  function normalizePosition(", geometry_start)
fixture = (root / "test/shell.d/fixtures/bar-foreground/shell.qml").read_text()
fixture = fixture.replace("  // PRODUCTION_GEOMETRY", bar[geometry_start:geometry_end])
output.write_text(fixture.replace("  // PRODUCTION_SAMPLER", bar[start:end]))
PY

cat >"$work/bin/omarchy-bar-text-color" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$SAMPLE_CALLS"
readlink -f "$HOME/.local/state/omarchy/current/background" >>"$SAMPLE_BACKGROUNDS"
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
# Style's real singleton can initialize without querying a live desktop.
cat >"$work/bin/hyprctl" <<'STUB'
#!/bin/bash
echo '{}'
STUB
chmod +x "$work/bin/omarchy-bar-text-color" "$work/bin/hyprctl"

for scenario in foreground contrast position orientation size orientation-size background rapid toggle off failure early failure-latest; do
  rm -rf "$work/first" "$work/gate" "$work/calls" "$work/backgrounds"
  ln -nsf "$state_dir/wallpaper-a.png" "$state_dir/current/background"
  env -u WAYLAND_DISPLAY -u DISPLAY -u HYPRLAND_INSTANCE_SIGNATURE \
    HOME="$work/home" XDG_RUNTIME_DIR="$work/runtime" OMARCHY_PATH="$ROOT" \
    PATH="$work/bin:$PATH" QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= \
    QT_STYLE_OVERRIDE= QT_QUICK_BACKEND=software SCENARIO="$scenario" \
    SAMPLE_GATE="$work/gate" SAMPLE_FIRST="$work/first" SAMPLE_CALLS="$work/calls" \
    SAMPLE_BACKGROUNDS="$work/backgrounds" BACKGROUND_NEXT="$state_dir/wallpaper-b.png" \
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
  orientation) expected='left 36 #333333 #eeeeee' ;;
  orientation-size) expected='right 42 #333333 #eeeeee' ;;
  rapid) expected='right 42 #444444 #dddddd' ;;
  *) expected='top 30 #333333 #eeeeee' ;;
  esac
  [[ $(tail -n 1 "$work/calls") == "$expected" ]] || fail "transparent foreground $scenario samples the latest inputs" "expected: $expected; actual: $(tail -n 1 "$work/calls")"
  if [[ $scenario == "background" ]]; then
    [[ $(head -n 1 "$work/backgrounds") == "$state_dir/wallpaper-a.png" &&
       $(tail -n 1 "$work/backgrounds") == "$state_dir/wallpaper-b.png" ]] ||
      fail "wallpaper watcher resamples the repointed background"
  fi
  pass "transparent foreground $scenario converges without stale output or extra samples"
done
