pragma Singleton
import QtQuick

// Returns the key, so the test can tell which string the dialog would show.
QtObject {
  readonly property bool rightToLeft: false
  function t(key) { return key }
}
