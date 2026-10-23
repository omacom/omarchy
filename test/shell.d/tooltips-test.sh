#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
ln -s "$ROOT/shell/Ui" "$stage/Ui"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
cp "$SHELL_TEST_DIR/fixtures/tooltips/shell.qml" "$stage/shell.qml"

# This window-only fixture can run offscreen; no production services start.
output=$(HOME="$stage" XDG_CONFIG_HOME="$stage/.config" OMARCHY_PATH="$ROOT" QT_QPA_PLATFORM=offscreen \
  QML_IMPORT_PATH="$ROOT/shell/styles${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
  QT_QUICK_CONTROLS_STYLE=Omarchy QT_QUICK_CONTROLS_FALLBACK_STYLE=Fusion \
  timeout 20 "${TOOLTIP_QUICKSHELL:-quickshell}" -n -p "$stage" --no-color 2>&1) || fail "native tooltip fixture loads and exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "native tooltip assertions pass" "$output"
if rg -q 'FAIL |RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<< "$output"; then
  fail "tooltip fixture has no QML errors" "$output"
fi
pass "native tooltip style, wrapping, theme, focus, cancellation and lazy lifecycle"

# Characterize the independent-process boundary explicitly: setting the style
# environment alone does not reach existing Quickshell apps. This negative
# control is a documented coverage gap, not acceptance of automatic coverage.
for respect_style in 0 1; do
  if (( respect_style )); then
    printf '%s\n' '//@ pragma RespectSystemStyle' > "$stage/shell.qml"
  else
    : > "$stage/shell.qml"
  fi
  cat "$SHELL_TEST_DIR/fixtures/tooltips/independent.qml" >> "$stage/shell.qml"
  output=$(HOME="$stage" XDG_CONFIG_HOME="$stage/.config" OMARCHY_PATH="$ROOT" QT_QPA_PLATFORM=offscreen \
    QML_IMPORT_PATH="$ROOT/shell/styles${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
    QT_QUICK_CONTROLS_STYLE=Omarchy QT_QUICK_CONTROLS_FALLBACK_STYLE=Fusion \
    QS_QUICK_CONTROLS_STYLE=Fusion TOOLTIP_EXPECT_STYLE="$respect_style" \
    timeout 10 "${TOOLTIP_QUICKSHELL:-quickshell}" -n -p "$stage" --no-color 2>&1) || fail "independent tooltip fixture loads" "$output"
  [[ $output == *"RESULT pass"* ]] || fail "independent tooltip style boundary matches" "$output"
done
pass "independent Qt attached tooltip requires entrypoint opt-in; automatic coverage remains incomplete"

# Dispatch real Qt input events inside an offscreen window. This is separate
# from physical Wayland/desktop validation and does not control the session.
cp "$SHELL_TEST_DIR/fixtures/tooltips/input.qml" "$stage/shell.qml"
output=$(HOME="$stage" XDG_CONFIG_HOME="$stage/.config" OMARCHY_PATH="$ROOT" QT_QPA_PLATFORM=offscreen \
  QML_IMPORT_PATH="$ROOT/shell/styles${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
  QT_QUICK_CONTROLS_STYLE=Omarchy QT_QUICK_CONTROLS_FALLBACK_STYLE=Fusion \
  timeout 20 "${TOOLTIP_QUICKSHELL:-quickshell}" -n -p "$stage" --no-color 2>&1) || fail "tooltip input fixture loads and exits cleanly" "$output"
[[ $output == *"INPUT_RESULT pass passed=8"* ]] || fail "tooltip input events pass" "$output"
if rg -q 'INPUT_RESULT fail|ReferenceError|TypeError|Error:|Binding loop' <<< "$output"; then
  fail "tooltip input fixture has no QML errors" "$output"
fi
pass "Qt input events: hover, transfer, action, cancellation, Tab/Escape, outside focus, motion and large-font edges"

mkdir -p "$stage/.config/omarchy"
cp "$SHELL_TEST_DIR/fixtures/tooltips/preferences.qml" "$stage/shell.qml"
output=$(HOME="$stage" XDG_CONFIG_HOME="$stage/.config" OMARCHY_PATH="$ROOT" QT_QPA_PLATFORM=offscreen \
  QML_IMPORT_PATH="$ROOT/shell/styles" QT_QUICK_CONTROLS_STYLE=Omarchy QT_QUICK_CONTROLS_FALLBACK_STYLE=Fusion \
  timeout 15 "${TOOLTIP_QUICKSHELL:-quickshell}" -n -p "$stage" --no-color 2>&1) || fail "tooltip preference fixture loads" "$output"
[[ $output == *"PREFERENCES_RESULT pass"* ]] || fail "tooltip preference file changes apply" "$output"
if rg -q 'FAIL |ReferenceError|TypeError|Error:|Binding loop' <<< "$output"; then
  fail "tooltip preferences have no QML errors" "$output"
fi
pass "shared tooltip preferences: atomic updates, all hosts, theme restore and invalid input"
