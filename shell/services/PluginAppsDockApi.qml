import QtQuick

// Only the app-grid operations, without a reference to the dock or its host.
QtObject {
  required property string ownerPluginId
  property bool available: false
  property var pinnedKeys: []
  property var _invoke: null

  function isPinned(key) {
    return pinnedKeys.indexOf(String(key || "")) >= 0
  }

  function setPinned(key, pinned) {
    if (_invoke) _invoke("setPinned", [String(key || ""), pinned === true])
  }

  function launchEntry(entry) {
    if (_invoke && entry) _invoke("launchEntry", [{ id: String(entry.id || ""), name: String(entry.name || "") }])
  }

  function moveExternalDrag(screen, x, y) {
    if (_invoke) _invoke("moveExternalDrag", [screen, Number(x), Number(y)])
  }

  function dropExternalDrag(screen, x, y, key) {
    if (_invoke) _invoke("dropExternalDrag", [screen, Number(x), Number(y), String(key || "")])
  }

  function endExternalDrag() {
    if (_invoke) _invoke("endExternalDrag", [])
  }
}
