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

  // Wait for release so a held wake key cannot repeat into the password.
  Keys.priority: Keys.BeforeItem
  Keys.onPressed: function(event) {
    event.accepted = true
    if (root.active && !event.isAutoRepeat && root.dismissalKey === 0)
      root.dismissalKey = event.key
  }
  Keys.onReleased: function(event) {
    event.accepted = true
    if (root.active && !event.isAutoRepeat && event.key === root.dismissalKey) {
      root.dismissalKey = 0
      root.dismissed()
    }
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
