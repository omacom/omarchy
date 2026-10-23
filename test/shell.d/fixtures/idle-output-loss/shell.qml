import QtQuick
import Quickshell

ShellRoot {
  id: root

  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string wakeLog: Quickshell.env("OMARCHY_WAKE_LOG")
  property var failures: []
  property int checks: 0
  property int step: 0
  property var service: null

  readonly property var realScreen: ({ name: "DP-1", width: 1920, height: 1080 })
  readonly property var fallbackScreen: ({ name: "FALLBACK", width: 1920, height: 1080 })
  readonly property string saver: "org.omarchy.screensaver"

  Item { id: host }

  function check(condition, message) {
    checks += 1
    if (!condition) failures.push(message)
  }

  function mark(name) {
    var quoted = "'" + name.replace(/'/g, "'\\''") + "'"
    Quickshell.execDetached(["bash", "-c", "echo \"S " + name + "\" >> \"$1\"", "_", wakeLog])
  }

  // A cycle that idled with the screensaver up on a window at 0x1, as the
  // idle service sees it once the screensaver has opened.
  function begin(name, screens) {
    if (service) service.destroy()
    var component = Qt.createComponent("file://" + rootPath + "/shell/plugins/services/idle/Service.qml", Component.PreferSynchronous)
    if (component.status !== Component.Ready) throw new Error(component.errorString())
    service = component.createObject(host, { outputScreens: screens })
    if (!service) throw new Error(component.errorString())
    service.stayAwakeStateLoaded = true
    service.idledThisCycle = true
    service.screensaverStartedThisCycle = true
    service.handleHyprlandEvent({ name: "openwindow", data: "0x1,1,org.omarchy.screensaver,t" })
    check(service.screensaverWindowCount === 1, name + ": the screensaver window is tracked")
    mark(name)
  }

  function closeSaver() { service.handleHyprlandEvent({ name: "closewindow", data: "0x1" }) }

  property var scenarios: [
    function() {
      begin("no-outputs-close", [])
      closeSaver()
      check(service.idledThisCycle, "closing with no outputs keeps the cycle")
      service.handleActiveSignal()
      check(service.idledThisCycle, "resumed after the output loss keeps the cycle")
    },
    function() {
      begin("fallback-only-close", [fallbackScreen])
      closeSaver()
      check(service.idledThisCycle, "a FALLBACK-only screen list counts as no outputs")
      service.handleActiveSignal()
      check(service.idledThisCycle, "resumed with only FALLBACK keeps the cycle")
    },
    function() {
      begin("stale-list-monitorremoved", [realScreen])
      service.handleHyprlandEvent({ name: "monitorremoved", data: "DP-1" })
      closeSaver()
      check(service.idledThisCycle, "monitorremoved before a stale screen list keeps the cycle")
      service.handleActiveSignal()
      check(service.idledThisCycle, "resumed right after monitorremoved keeps the cycle")
    },
    function() {
      begin("fallback-removed-close", [realScreen])
      service.handleHyprlandEvent({ name: "monitorremoved", data: "FALLBACK" })
      closeSaver()
      check(!service.idledThisCycle, "removing only FALLBACK is not an output loss")
    },
    function() {
      begin("real-dismissal", [realScreen])
      closeSaver()
      check(!service.idledThisCycle, "closing the screensaver with outputs present still cancels")
    },
    function() {
      begin("real-activity", [realScreen])
      service.handleHyprlandEvent({ name: "closewindow", data: "0x9" })
      check(service.idledThisCycle, "closing an unrelated window leaves the cycle")
      service.screensaverStartedThisCycle = false
      service.handleActiveSignal()
      check(!service.idledThisCycle, "resumed with outputs present is real activity")
    }
  ]

  function finish() {
    if (service) service.destroy()
    var payload = JSON.stringify({ ok: failures.length === 0, checks: checks, failures: failures })
    var quoted = "'" + payload.replace(/'/g, "'\\''") + "'"
    Quickshell.execDetached(["bash", "-c", "printf '%s' " + quoted + " > \"$1\"", "_", resultPath])
  }

  // Each scenario gets time for its wake stub (if any) to log before the next.
  Timer {
    interval: 700
    repeat: true
    running: true
    onTriggered: {
      if (root.step >= root.scenarios.length) {
        stop()
        root.finish()
        return
      }
      try {
        root.scenarios[root.step]()
      } catch (error) {
        root.failures.push(String(error))
      }
      root.step += 1
    }
  }
}
