pragma Singleton
import QtQuick

// Only what PanelKeyCatcher reaches for: the real Style needs Quickshell,
// which qmltestrunner doesn't load.
QtObject {
  function byKey(action) { return action() }
}
