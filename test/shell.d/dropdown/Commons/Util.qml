pragma Singleton
import QtQuick

QtObject {
  function alpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }
}
