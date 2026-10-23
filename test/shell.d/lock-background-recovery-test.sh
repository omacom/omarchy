#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
require_compositor "lock wallpaper recovery test"
require_command quickshell
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/bin" "$stage/home"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
ln -s "$ROOT/shell/Ui" "$stage/Ui"
ln -s "$ROOT/shell/plugins/lock" "$stage/lock"
cp "$SHELL_TEST_DIR/fixtures/lock-background-recovery/shell.qml" "$stage/shell.qml"
# Use the production service's whole preload block without starting PAM,
# session-lock surfaces, or any actual lock operation.
python3 - "$ROOT/shell/plugins/lock/Service.qml" "$stage/LockPreloads.qml" <<'PY'
import sys
from pathlib import Path
source=Path(sys.argv[1]).read_text()
start=source.index('  Variants {\n    id: preloadVariants')
opened=source.index('{',start)
depth=1;end=opened+1
while depth:
    if source[end]=='{':depth+=1
    if source[end]=='}':depth-=1
    end+=1
prefix='import QtQuick\nimport Quickshell\nimport qs.Ui\nItem {\n  id: root\n  property string lockWallpaperPath: Quickshell.env("LOCK_CANONICAL")\n  property int backgroundVersion: 0\n  property alias instances: preloadVariants.instances\n'
Path(sys.argv[2]).write_text(prefix+source[start:end]+'\n}\n')
PY
printf 'P3\n1 1\n255\n0 180 80\n' >"$stage/canonical.ppm"
printf 'Qt cannot decode this variant\n' >"$stage/broken.png"
# A selected file can pass the CLI probe and still fail Qt decoding. Isolate
# that boundary with a resolver response; the real QML resolver, preload,
# LockView and image decoder run unchanged.
cat >"$stage/bin/omarchy-theme-bg-resolve" <<'STUB'
#!/bin/bash
path="$LOCK_BROKEN"
[[ " $* " != *" --canonical-only "* ]] || path="$LOCK_CANONICAL"
printf '%s\n' "$*" >>"$LOCK_RESOLVE_LOG"
jq -cn --arg path "$path" '{path:$path,fill:"crop",backdrop:"solid",fill_color:"#000000",focal_x:0.5,focal_y:0.5}'
STUB
chmod +x "$stage/bin/omarchy-theme-bg-resolve"
output=$(HOME="$stage/home" XDG_CONFIG_HOME="$stage/home/.config" XDG_STATE_HOME="$stage/home/.local/state" PATH="$stage/bin:$PATH" LOCK_CANONICAL="$stage/canonical.ppm" LOCK_BROKEN="$stage/broken.png" LOCK_RESOLVE_LOG="$stage/resolve.log" LOCK_CAPTURE="${OMARCHY_TEST_ARTIFACT_DIR:+$OMARCHY_TEST_ARTIFACT_DIR/lock-background-recovery.png}" timeout 8 quickshell -p "$stage" --no-color 2>&1) || fail "lock background fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* && $output != *"RESULT fail"* ]] || fail "lock backgrounds retry the canonical after a Qt decode failure" "$output"
if rg -q 'ReferenceError|TypeError|Unable to assign|Binding loop' <<<"$output"; then fail "lock background fixture has no QML errors" "$output"; fi
grep -q -- '--canonical-only' "$stage/resolve.log" || fail "failed variants invoke the canonical resolver path"
pass "production lock preloads and independent lock views recover canonical pixels after Qt decode failures"
