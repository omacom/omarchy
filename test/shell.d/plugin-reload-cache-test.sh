#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Plugin hot-reload must not rely solely on Qt.clearComponentCache — that API
# is C++-only and is never a function on the QML Qt object (issue #10568).

shell_qml="$ROOT/shell/shell.qml"
registry_qml="$ROOT/shell/services/PluginRegistry.qml"

[[ -f $shell_qml ]] || fail "shell.qml exists"
[[ -f $registry_qml ]] || fail "PluginRegistry.qml exists"

grep -F 'componentCacheEpoch' "$registry_qml" >/dev/null ||
  fail "PluginRegistry tracks a componentCacheEpoch for URL cache-busting"
grep -F 'omarchyReload=' "$registry_qml" >/dev/null ||
  fail "entryPointUrl appends omarchyReload epoch query"
pass "PluginRegistry cache-busts entryPointUrl on reload epoch"

grep -F 'componentCacheEpoch++' "$shell_qml" >/dev/null ||
  fail "finishPluginReload advances componentCacheEpoch before rescan"
grep -F 'Qt.clearComponentCache is unavailable' "$shell_qml" >/dev/null ||
  fail "finishPluginReload warns once when clearComponentCache is missing"
pass "finishPluginReload advances epoch and warns when cache clear is missing"

# Prove the QML Qt object still lacks clearComponentCache on this machine so
# the bust path is not dead code relative to the runtime we ship against.
require_command qml6
probe=$(mktemp --suffix=.qml)
trap 'rm -f "$probe"' EXIT
cat >"$probe" <<'QML'
import QtQuick
Item {
  Component.onCompleted: {
    Qt.exit(typeof Qt.clearComponentCache === "function" ? 0 : 3)
  }
}
QML
set +e
QT_QPA_PLATFORM=offscreen qml6 "$probe" >/dev/null 2>&1
status=$?
set -e
(( status == 3 )) || fail "Qt.clearComponentCache remains unavailable on QML Qt object (exit=$status)"
pass "Qt.clearComponentCache remains unavailable on QML Qt object"

# Contract fixture must cover the epoch query behaviour.
fixture="$ROOT/test/shell.d/fixtures/plugin-registry/shell.qml"
grep -F 'componentCacheEpoch' "$fixture" >/dev/null ||
  fail "plugin-registry fixture asserts entryPointUrl epoch cache-bust"
pass "plugin-registry fixture asserts entryPointUrl epoch cache-bust"
