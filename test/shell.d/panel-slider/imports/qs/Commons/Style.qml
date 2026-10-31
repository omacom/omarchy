pragma Singleton
import QtQuick

QtObject {
  readonly property var spacing: ({ controlHeight: 40, md: 8 })

  function space(value) {
    return value
  }

  function duration(value) {
    return value
  }

  function selectedFillFor(foreground, accent) {
    return accent
  }
}
