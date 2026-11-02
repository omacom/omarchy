pragma Singleton
import QtQuick

QtObject {
  property string clockFormat: "dddd HH:mm"
  readonly property string timeFormat: ClockFormat.compactTimeFormat(clockFormat)
}
