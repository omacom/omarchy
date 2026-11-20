import QtQuick
import qs.Commons
import qs.Commons as Commons

// The line between two things on a scene, and something on its way along it.
Item {
  id: root

  // How far along it is: nothing shows before it sets out or once it is there.
  property real along: 0

  property color foreground: Commons.Color.menu.text
  property color accent: Commons.Color.accent

  height: Style.space(6)

  Rectangle {
    width: parent.width
    height: Style.spacing.hairline
    anchors.verticalCenter: parent.verticalCenter
    color: Util.alpha(root.foreground, 0.2)
  }

  Rectangle {
    visible: root.along > 0 && root.along < 1
    width: parent.height
    height: width
    x: (parent.width - width) * root.along
    color: root.accent
  }
}
