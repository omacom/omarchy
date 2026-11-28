#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

qml_test_runner=""
for candidate in /usr/lib/qt6/bin/qmltestrunner /usr/lib/qt6/qmltestrunner; do
  if [[ -x $candidate ]]; then
    qml_test_runner=$candidate
    break
  fi
done

if [[ -z $qml_test_runner ]]; then
  skip "Qt6 qmltestrunner not found; skipping Color.loadColors tests"
  exit 0
fi

fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/Quickshell/Io" "$fixture/qs/Commons" "$fixture/home"

cat >"$fixture/Quickshell/qmldir" <<'EOF'
module Quickshell
singleton Quickshell 1.0 Quickshell.qml
EOF
cat >"$fixture/Quickshell/Quickshell.qml" <<'EOF'
pragma Singleton
import QtQuick
QtObject {
  function env(name) { return "" }
}
EOF

cat >"$fixture/Quickshell/Io/qmldir" <<'EOF'
module Quickshell.Io
FileView 1.0 FileView.qml
EOF
cat >"$fixture/Quickshell/Io/FileView.qml" <<'EOF'
import QtQuick
QtObject {
  property string path: ""
  property bool watchChanges: false
  property bool printErrors: false
  signal loaded()
  signal loadFailed()
  signal fileChanged()
  function text() { return "" }
  function reload() {}
}
EOF

cat >"$fixture/qs/Commons/qmldir" <<'EOF'
module qs.Commons
singleton Color 1.0 Color.qml
singleton Style 1.0 Style.qml
singleton Util 1.0 Util.qml
EOF
cat >"$fixture/qs/Commons/Style.qml" <<'EOF'
pragma Singleton
import QtQuick
QtObject {
  function applyShellValues(values) {}
}
EOF
cat >"$fixture/qs/Commons/Util.qml" <<'EOF'
pragma Singleton
import QtQuick
QtObject {
  function clampAlpha(n) { return Math.max(0, Math.min(1, n)) }
  function alpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }
}
EOF

cp "$ROOT/shell/Commons/Color.qml" "$ROOT/shell/Commons/BorderGeometry.js" "$fixture/qs/Commons/"

cat >"$fixture/tst_color_palette.qml" <<'EOF'
import QtQuick
import QtTest
import qs.Commons as Commons

TestCase {
  name: "ColorPalette"

  function test_partial_reload_resets_omitted_keys_to_defaults() {
    Commons.Color.loadColors(
      'foreground = "#112233"\n' +
      'background = "#445566"\n' +
      'accent = "#778899"\n' +
      'color1 = "#aa1122"\n' +
      'color3 = "#bbcc33"\n' +
      'muted = "#223344"\n'
    )
    compare(String(Commons.Color.foreground), "#112233")
    compare(String(Commons.Color.background), "#445566")
    compare(String(Commons.Color.accent), "#778899")
    compare(String(Commons.Color.splashForeground), "#112233")
    compare(String(Commons.Color.splashBackground), "#445566")
    compare(String(Commons.Color.splashAccent), "#778899")
    compare(String(Commons.Color.urgent), "#aa1122")
    compare(String(Commons.Color.warning), "#bbcc33")
    compare(String(Commons.Color.muted), "#223344")

    // Splash overrides take precedence without affecting the desktop palette.
    Commons.Color.loadColors(
      'foreground = "#a9b1d6"\n' +
      'background = "#1a1b26"\n' +
      'accent = "#7aa2f7"\n' +
      'splash_foreground = "#c0caf5"\n' +
      'splash_accent = "#a8cd76"\n'
    )
    compare(String(Commons.Color.foreground), "#a9b1d6")
    compare(String(Commons.Color.background), "#1a1b26")
    compare(String(Commons.Color.accent), "#7aa2f7")
    compare(String(Commons.Color.splashForeground), "#c0caf5")
    compare(String(Commons.Color.splashBackground), "#1a1b26")
    compare(String(Commons.Color.splashAccent), "#a8cd76")

    // Longer hex values are rejected so startup cover matches omarchy-theme-set-login.
    Commons.Color.loadColors(
      'foreground = "#a9b1d6"\n' +
      'background = "#1a1b26"\n' +
      'accent = "#7aa2f7"\n' +
      'splash_accent = "#11223344"\n' +
      'splash_foreground = "#11223344"\n' +
      'splash_background = "#11223344"\n'
    )
    compare(String(Commons.Color.splashAccent), "#7aa2f7")
    compare(String(Commons.Color.splashForeground), "#a9b1d6")
    compare(String(Commons.Color.splashBackground), "#1a1b26")

    // Reloading an empty or partial theme must not keep colors from the previous one.
    Commons.Color.loadColors('mode = "light"\n')
    compare(String(Commons.Color.foreground), "#cacccc")
    compare(String(Commons.Color.background), "#101315")
    compare(String(Commons.Color.accent), "#cacccc")
    compare(String(Commons.Color.splashForeground), "#cacccc")
    compare(String(Commons.Color.splashBackground), "#101315")
    compare(String(Commons.Color.splashAccent), "#cacccc")
    compare(String(Commons.Color.urgent), "#a55555")
    compare(String(Commons.Color.warning), "#c4a35a")
    compare(String(Commons.Color.muted), "#cacccc")

    // Explicit keys still beat Base24 aliases regardless of key order.
    Commons.Color.loadColors(
      'accent = "#123456"\n' +
      'color4 = "#654321"\n' +
      'color0 = "#010203"\n' +
      'color7 = "#fefefd"\n' +
      'color8 = "#667788"\n'
    )
    compare(String(Commons.Color.accent), "#123456")
    compare(String(Commons.Color.background), "#010203")
    compare(String(Commons.Color.foreground), "#fefefd")
    compare(String(Commons.Color.muted), "#667788")
    compare(String(Commons.Color.urgent), "#a55555")
    compare(String(Commons.Color.warning), "#c4a35a")
  }
}
EOF

output=$(HOME="$fixture/home" QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= QT_QUICK_BACKEND=software \
  "$qml_test_runner" -import "$fixture" -input "$fixture/tst_color_palette.qml" -o -,txt 2>&1) ||
  fail "partial colors.toml reload resets omitted palette roles to defaults" "$output"
printf '%s\n' "$output" | sed -n '/^Totals:/p'
pass "partial colors.toml reload resets omitted palette roles to defaults"
