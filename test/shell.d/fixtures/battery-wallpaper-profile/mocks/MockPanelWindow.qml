import QtQuick

// No window or compositor surface is created by the offscreen fixture.
Item {
  property var screen: null
  property color color: "transparent"
  property bool updatesEnabled: true
}
