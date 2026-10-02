#!/bin/bash

# Probe the engine that actually runs QML: qmltestrunner has no -version flag,
# and an unversioned executable may belong to Qt 5 on mixed installations.
find_qt6_qmltestrunner() {
  local scratch="$1" qt6_bins="${2:-/usr/lib/qt6/bin}"
  local candidate runner probe_output
  local probe="$scratch/qt-version.qml"
  cat >"$probe" <<'QML'
import QtQuick
import QtTest
TestCase {
  name: "QtVersionProbe"
  function test_version() {}
}
QML

  for candidate in qmltestrunner6 "$qt6_bins/qmltestrunner" qmltestrunner; do
    runner=$(command -v "$candidate" || true)
    [[ -n $runner && -x $runner ]] || continue
    if probe_output=$(QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= QT_QUICK_BACKEND=software \
      "$runner" -input "$probe" 2>&1); then
      if [[ $probe_output == *"Using QtTest library 6."* ]]; then
        printf '%s\n' "$runner"
        return 0
      fi
    fi
  done
  return 1
}
