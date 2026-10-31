import QtQuick

Item {
  property QtObject bar: null
  property string moduleName: ""
  property string ipcTarget: ""
  property bool manageIpc: true
  readonly property bool opened: true
  readonly property QtObject controller: QtObject {
    function show() {}
    function hide() {}
  }

  function setting(name, fallback) { return fallback }
}
