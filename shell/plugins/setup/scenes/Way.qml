import QtQuick
import qs.Commons
import qs.Commons as Commons

// The line between two things on a scene, and a soft-fading packet along it.
Item {
  id: root

  // How far along it is: nothing shows before it sets out or once it arrives.
  property real along: 0
  property bool active: along > 0 && along < 1

  property color foreground: Commons.Color.menu.text
  property color accent: Commons.Color.accent

  height: Style.space(6)

  Rectangle {
    width: parent.width
    height: Style.spacing.hairline
    anchors.verticalCenter: parent.verticalCenter
    color: root.active ? Util.alpha(root.accent, 0.36) : Util.alpha(root.foreground, 0.2)
    Behavior on color { ColorAnimation { duration: Style.duration(160) } }
  }

  Rectangle {
    visible: root.along > 0 && root.along < 1
    width: Style.space(5)
    height: width
    radius: Style.cornerRadius > 0 ? width / 2 : 0
    x: (parent.width - width) * root.along
    anchors.verticalCenter: parent.verticalCenter
    color: root.accent
    opacity: Math.sin(Math.PI * root.along)
  }
}
