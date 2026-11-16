import QtQuick

// Only presentation lives here. The parent owns the session lock and PAM.
// It draws the user's QML artwork when there is one, else backgroundComponent.
Item {
  id: root

  property bool active: false
  property url source: ""
  property Component backgroundComponent: null
  property int dismissalKey: 0

  signal dismissed()
  signal loadFailed()

  onActiveChanged: {
    dismissalKey = 0
    if (active) Qt.callLater(function() { root.forceActiveFocus() })
  }

  Loader {
    anchors.fill: parent
    active: root.active && !root.source.toString()
    sourceComponent: root.backgroundComponent
  }

  Loader {
    anchors.fill: parent
    active: root.active && root.source.toString().length > 0
    source: root.source
    onStatusChanged: {
      if (status === Loader.Error) root.loadFailed()
    }
  }

  // The artwork gives way when the first key pressed is released, so a held
  // wake key cannot repeat into the password field behind it.
  function pressKey(key, isAutoRepeat) {
    if (active && !isAutoRepeat && dismissalKey === 0) dismissalKey = key
  }

  function releaseKey(key, isAutoRepeat) {
    if (!active || isAutoRepeat || key !== dismissalKey) return
    dismissalKey = 0
    dismissed()
  }

  // Every key stops here, so Tab cannot move focus behind the artwork.
  Keys.priority: Keys.BeforeItem
  Keys.onPressed: function(event) {
    event.accepted = true
    root.pressKey(event.key, event.isAutoRepeat)
  }
  Keys.onReleased: function(event) {
    event.accepted = true
    root.releaseKey(event.key, event.isAutoRepeat)
  }

  MouseArea {
    anchors.fill: parent
    enabled: root.active
    acceptedButtons: Qt.AllButtons
    cursorShape: Qt.BlankCursor
    onPressed: function(mouse) { mouse.accepted = true }
    onWheel: function(wheel) { wheel.accepted = true }
  }
}
