import QtQuick

// Forwards the wheel the way WidgetButton does.
Item {
  id: root
  property QtObject bar: null
  property string text: ""
  property bool active: false
  property string tooltipText: ""
  signal pressed(int button)
  signal wheelMoved(int delta)

  implicitWidth: 24
  implicitHeight: 24

  MouseArea {
    anchors.fill: parent
    onWheel: function(wheel) { root.wheelMoved(wheel.angleDelta.y) }
  }
}
