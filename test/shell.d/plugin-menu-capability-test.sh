#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v quickshell >/dev/null 2>&1; then
  pass "quickshell not installed; skipping menu capability runtime test"
  exit 0
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

shell_qml="$ROOT/shell/shell.qml"
fixture="$TMPDIR/shell.qml"
log="$TMPDIR/quickshell.log"

extract_function() {
  local name=$1
  awk -v signature="  function $name(" '
    index($0, signature) == 1 { copying = 1 }
    copying { print }
    copying && $0 == "  }" { exit }
  ' "$shell_qml"
}

cat >"$fixture" <<'QML'
import QtQuick
import QtQml.Models
import Quickshell

ShellRoot {
  id: shell

  property var pluginRegistry: QtObject {
    property var installedPlugins: ({
      "acme.menu": { id: "acme.menu", kinds: ["menu"] },
      "acme.plain": { id: "acme.plain", kinds: ["panel"] },
      "omarchy.menu": { id: "omarchy.menu", kinds: ["menu"], __isFirstParty: true }
    })
  }
  property var appLibrary: QtObject {}
  property var _pluginShellApis: ({})
  property var _pluginShellApiDescriptors: ({})
  property var _pluginAppLibraryApis: ({})
  property var _pluginFirstPartyServiceApis: ({})
  property var _pluginBarEntryShellApis: ({})
  property var directMenuApi: null
  property int completedDelegates: 0
  property bool failed: false

  Timer {
    interval: 3000
    running: true
    onTriggered: {
      console.error("CAPABILITY_FAIL timeout after", shell.completedDelegates, "delegates")
      console.log("CAPABILITY_RESULT_FAIL")
      Qt.quit()
    }
  }

  Component {
    id: pluginShellApiComponent
    QtObject {
      property string pluginId
      property var appLibrary
      property var bar
      property var barConfig
      property var idleConfig
      property var _serviceLookup
      property var _firstPartyServiceLookup
      property var _barEntryShellLookup
      property var _summon
      property var _hide
      property var _toggle
      property var _isOpen
      property var _updateSettings
      property var _mutateBarConfig
    }
  }
  Component {
    id: pluginAppLibraryApiComponent
    QtObject {
      property string ownerPluginId
      property var _entryName
      property var _entrySubtext
      property var _sortedEntries
      property var _iconSource
      property var _refreshIcons
      property var _launch
      property var _remove
    }
  }

  function check(value, message) {
    if (value) return
    failed = true
    console.error("CAPABILITY_FAIL", message)
  }
  function pluginAppLibraryFor(cacheKey, pluginId) {
    if (_pluginAppLibraryApis[cacheKey]) return _pluginAppLibraryApis[cacheKey]
    var api = pluginAppLibraryApiComponent.createObject(null, { ownerPluginId: pluginId })
    var next = ({})
    for (var id in _pluginAppLibraryApis) next[id] = _pluginAppLibraryApis[id]
    next[cacheKey] = api
    _pluginAppLibraryApis = next
    return api
  }
  function pluginBarStateFor(cacheKey, pluginId) { return null }
  function publicBarConfig() { return ({}) }
  function publicIdleConfigFor(manifest) { return ({}) }
  function pluginFirstPartyServiceFor(cacheKey, pluginId, serviceId) { return null }
  function pluginServiceFor(pluginId, requestedId) { return null }
  function pluginOwnsTarget(pluginId, requestedId) { return false }
  function pluginShellForBarEntry(ownerId, moduleName) { return null }
  function barPluginMayControl(manifest, requestedId) { return false }
  function pluginCloneMaySummon(manifest, requestedId) { return false }
  function mutatePluginBarConfig(mutator) { return false }
  function summon(id, payload) { return false }
  function hide(id) { return false }
  function toggle(id, payload) { return false }
  function isPluginOpen(id) { return false }
  function updateEntryInline(id, settings) { return false }
QML

for name in manifestHasKind pluginHasBarCapabilities pluginShellCapabilityProfile cacheWithoutKey cacheWithoutPrefix revokePluginShellApi createScopedPluginShell pluginShellFor; do
  extract_function "$name" >>"$fixture"
done

cat >>"$fixture" <<'QML'

  property var entries: [
    { manifest: { id: "acme.menu", kinds: ["menu"] } },
    { manifest: { id: "acme.plain", kinds: ["menu"], __isFirstParty: true } }
  ]

  Instantiator {
    id: manifestInstantiator
    active: false
    model: shell.entries
    delegate: QtObject {
      required property var modelData
      Component.onCompleted: {
        var delegateManifest = modelData.manifest
        shell.check(!Array.isArray(delegateManifest.kinds), "Instantiator did not produce a V4Sequence")
        var api = shell.pluginShellFor(delegateManifest)
        if (delegateManifest.id === "acme.menu") {
          shell.check(api === shell.directMenuApi, "menu API identity changed at the delegate boundary")
          shell.check(api && api.appLibrary !== null, "registered menu lost application access")
          shell.check(api && api.appLibrary === shell.directMenuApi.appLibrary, "menu application API identity changed")
        } else {
          shell.check(api !== shell, "delegate manifest spoofed first-party access")
          shell.check(api && api.appLibrary === null, "delegate manifest added menu access")
        }
        shell.completedDelegates++
        if (shell.completedDelegates === shell.entries.length) Qt.callLater(function() {
          console.log(shell.failed ? "CAPABILITY_RESULT_FAIL" : "CAPABILITY_RESULT_OK")
          Qt.quit()
        })
      }
    }
  }

  Component.onCompleted: {
    directMenuApi = pluginShellFor(pluginRegistry.installedPlugins["acme.menu"])
    check(directMenuApi && directMenuApi.appLibrary !== null, "registered menu has no application access")
    check(pluginShellFor(pluginRegistry.installedPlugins["acme.menu"]) === directMenuApi,
      "repeated menu lookup revoked its API")
    check(pluginShellFor(pluginRegistry.installedPlugins["omarchy.menu"]) === shell,
      "first-party menu did not keep the host shell")
    check(pluginShellFor({ id: "missing", kinds: ["menu"], __isFirstParty: true }) === null,
      "missing plugin ID did not fail closed")
    check(pluginShellFor(null) === null, "missing manifest did not fail closed")
    var plainApi = pluginShellFor(pluginRegistry.installedPlugins["acme.plain"])
    check(plainApi && plainApi.appLibrary === null, "ordinary plugin received application access")
    manifestInstantiator.active = true
  }
}
QML

QT_QPA_PLATFORM=offscreen quickshell -p "$fixture" --no-color >"$log" 2>&1 || {
  cat "$log" >&2
  fail "menu capability fixture runs offscreen"
}

if grep -q 'CAPABILITY_FAIL\|CAPABILITY_RESULT_FAIL' "$log" || ! grep -q 'CAPABILITY_RESULT_OK' "$log"; then
  cat "$log" >&2
  fail "menu capabilities use the canonical registry manifest"
fi

pass "menu capabilities survive the Instantiator manifest conversion"
pass "plugin shell capabilities use only canonical registry manifests"
