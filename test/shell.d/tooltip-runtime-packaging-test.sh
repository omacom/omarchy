#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command quickshell
require_command python3
require_command bsdtar
stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
base_root=${TOOLTIP_TEST_BASE:-$ROOT}
mkdir -p "$stage/base/shell/plugins" "$stage/base/bin" "$stage/base/default/uwsm"
cp -a "$base_root/shell/Ui" "$base_root/shell/Commons" "$stage/base/shell/"
cp -a "$base_root/shell/plugins/bar" "$stage/base/shell/plugins/"
cp "$base_root/shell/shell.qml" "$stage/base/shell/"
cp "$base_root/bin/omarchy-launch-shell" "$stage/base/bin/"
cp "$base_root/default/uwsm/default" "$stage/base/default/uwsm/"
if [[ -z ${TOOLTIP_TEST_BASE:-} ]]; then
  # Keep a stock launcher snapshot and restore the stock namespace imports.
  # A feature checkout already has both fixes and would mask regressions.
  cp "$SHELL_TEST_DIR/fixtures/tooltips/base-launcher.txt" "$stage/base/bin/omarchy-launch-shell"
  python3 - "$stage/base" <<'PY_BASE'
from pathlib import Path
import sys
for name in ['Style', 'Border']:
    path = Path(sys.argv[1]) / f'shell/Commons/{name}.qml'
    path.write_text(path.read_text().replace('import "." as Commons', 'import qs.Commons as Commons'))
PY_BASE
fi
python3 - "$stage/stock.pkg.tar" <<'PY'
import io, sys, tarfile
raw = b'pkgname = quickshell\npkgver = 0.3.1-1\narch = any\nlicense = LGPL-3.0-only\nurl = https://quickshell.org\ndepend = qt6-base\n'
with tarfile.open(sys.argv[1], 'w') as archive:
    entry = tarfile.TarInfo('.PKGINFO')
    entry.size = len(raw)
    archive.addfile(entry, io.BytesIO(raw))
PY
python3 "$ROOT/default/tooltips/prepare-trial.py" --source "$ROOT" --installed "$stage/base" \
  --stock-package "$stage/stock.pkg.tar" --runtime "$(command -v quickshell)" --output "$stage/trial" > "$stage/prepare.json"
rg -Fq 'OMARCHY_STARTUP_BACKGROUND="$startup_background" QS_DISABLE_FILE_WATCHER=1' "$stage/trial/omarchy/bin/omarchy-launch-shell" || fail "base launcher assignments survive"
rg -q 'QT_QUICK_CONTROLS_STYLE=Omarchy' "$stage/trial/omarchy/bin/omarchy-launch-shell" || fail "base launcher gains style selection"
if rg -q '^import qs\.Commons' "$stage/trial/module/Omarchy/Kit/Commons/"*.qml; then
  fail "private provider has no consumer namespace imports"
fi
mkdir -p "$stage/consumer" "$stage/home/.config/omarchy" "$stage/home/.local/state/omarchy/current/theme"
cp "$SHELL_TEST_DIR/fixtures/tooltips/global.qml" "$stage/consumer/shell.qml"
printf '%s\n' '[tooltip]' 'background = "#121212"' > "$stage/home/.local/state/omarchy/current/theme/shell.toml"
printf '%s\n' 'background = "#121212"' 'foreground = "#ffffff"' > "$stage/home/.local/state/omarchy/current/theme/colors.toml"
output=$(HOME="$stage/home" XDG_CONFIG_HOME="$stage/home/.config" OMARCHY_PATH="$stage/base" \
  QT_QPA_PLATFORM=offscreen QML_IMPORT_PATH="$stage/trial/module" \
  QT_QUICK_CONTROLS_STYLE=Omarchy QT_QUICK_CONTROLS_FALLBACK_STYLE=Fusion \
  timeout 15 quickshell -n -p "$stage/consumer" --no-color 2>&1) || fail "independent provider loads" "$output"
[[ $output == *"GLOBAL_RESULT pass"* ]] || fail "packaged style is self-contained and live" "$output"
if rg -q 'FAIL |ReferenceError|TypeError|Error:|Binding loop' <<< "$output"; then
  fail "independent provider has no QML errors" "$output"
fi
pass "packaged tooltip provider needs no consumer kit and follows preferences/theme changes"
