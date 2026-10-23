import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.spacer"

  readonly property real authoredSize: settings && settings.size !== undefined ? Number(settings.size) : 12

  // A spacer is a gap like any other, so its size follows the spacing scale and
  // [font] base-size.
  readonly property int span: Style.space(authoredSize)

  implicitWidth: vertical ? barSize : span
  implicitHeight: vertical ? span : barSize
  visible: span > 0
}
