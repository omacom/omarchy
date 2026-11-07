import QtQuick

Item {
  Component.onCompleted: console.log("STARTUP_PROBE disabled started")
  Component.onDestruction: console.log("STARTUP_PROBE disabled stopped")
}
