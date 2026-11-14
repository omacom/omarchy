import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.flight-mode"

  property bool enabled: false

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function refresh() {
    if (!statusProc.running) statusProc.running = true
  }

  function toggle() {
    root.bar.run("omarchy-toggle-flight-mode")
    toggleDebounce.restart()
  }

  IpcHandler {
    target: "omarchy.flight-mode"

    function refresh(): void {
      root.broadcast("refresh")
    }
  }

  Process {
    id: statusProc
    command: ["omarchy-toggle-flight-mode", "--status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          root.enabled = JSON.parse(text).enabled === true
        } catch (error) {
          root.enabled = false
        }
      }
    }
  }

  Timer {
    id: toggleDebounce
    interval: 250
    onTriggered: root.refresh()
  }

  Timer {
    interval: 15000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Component.onCompleted: root.refresh()

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰀝"
    active: root.enabled
    tooltipText: root.enabled ? "Flight Mode On" : "Flight Mode Off"
    onPressed: root.toggle()
  }
}
