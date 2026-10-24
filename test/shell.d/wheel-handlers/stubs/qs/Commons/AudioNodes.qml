pragma Singleton
import QtQuick

QtObject {
  function isShellLevelMeter(name) { return false }
  function platformHides(name, names) { return false }
}
