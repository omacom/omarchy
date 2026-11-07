#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

runner=$(command -v qmltestrunner || true)
[[ -n $runner || ! -x /usr/lib/qt6/bin/qmltestrunner ]] || runner=/usr/lib/qt6/bin/qmltestrunner
if [[ -z $runner ]]; then
  pass "qmltestrunner not installed; skipping service lifecycle Qt runtime test"
  exit 0
fi
require_command node

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/home" "$test_tmp/runtime"
chmod 700 "$test_tmp/runtime"
cp "$SHELL_TEST_DIR/fixtures/service-lifecycle/"*.qml "$test_tmp/"
# The extracted production loader declares Component{} blocks for every
# scoped plugin-API type (PluginShellApi, PluginRegistryApi, ...) and
# unconditionally calls AuthServiceStore via ensureService's
# isAuthenticationService check. QML type-checks Component{} bodies at
# compile time regardless of whether they are ever instantiated, so the real
# services/ directory (all plain, dependency-free QtObject types plus the
# AuthServiceStore.js module) must be resolvable alongside the fixture.
cp -r "$ROOT/shell/services" "$test_tmp/services"

# Run the production service block in a plain QtQuick host, without Quickshell
# or a connection to the user's desktop session.
node - "$ROOT/shell/shell.qml" "$test_tmp/tst_service_lifecycle.qml" <<'JS'
const fs = require('fs')
const source = fs.readFileSync(process.argv[2], 'utf8')
const start = source.indexOf('  property var _services:')
const end = source.indexOf('  Connections {\n    target: shell.pluginRegistry', start)
if (start < 0 || end < 0) throw new Error('cannot locate production service loader')
const template = fs.readFileSync(process.argv[3], 'utf8')
fs.writeFileSync(process.argv[3], template.replace('  // PRODUCTION_SERVICE_LOADER', source.slice(start, end)))
JS

if ! output=$(env -u WAYLAND_DISPLAY -u DISPLAY -u QT_QPA_PLATFORMTHEME -u QT_IM_MODULE \
  HOME="$test_tmp/home" XDG_CONFIG_HOME="$test_tmp/home/config" \
  XDG_CACHE_HOME="$test_tmp/home/cache" XDG_DATA_HOME="$test_tmp/home/data" \
  XDG_STATE_HOME="$test_tmp/home/state" XDG_RUNTIME_DIR="$test_tmp/runtime" \
  DBUS_SESSION_BUS_ADDRESS="unix:path=$test_tmp/no-session-bus" \
  QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software \
  timeout 20 "$runner" -input "$test_tmp/tst_service_lifecycle.qml" 2>&1); then
  fail "service lifecycle Qt runtime checks" "$output"
fi
printf '%s\n' "$output"
pass "service lifecycle Qt runtime checks"
