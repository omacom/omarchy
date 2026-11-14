import QtQuick

Item {
  Component.onCompleted: console.log("STARTUP_PROBE enabled started")
  Component.onDestruction: console.log("STARTUP_PROBE enabled stopped")
}
