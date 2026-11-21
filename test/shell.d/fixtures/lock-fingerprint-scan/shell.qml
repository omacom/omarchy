import QtQuick
import Quickshell
import qs.Commons

ShellRoot {
  id: root

  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []
  property int checks: 0

  readonly property string presentLine: "/net/reactivated/Fprint/Device/0: org.freedesktop.DBus.Properties.PropertiesChanged ('net.reactivated.Fprint.Device', {'finger-present': <true>}, @as [])"
  readonly property string absentLine: "/net/reactivated/Fprint/Device/0: org.freedesktop.DBus.Properties.PropertiesChanged ('net.reactivated.Fprint.Device', {'finger-present': <false>}, @as [])"
  readonly property string rejectedLine: "/net/reactivated/Fprint/Device/0: net.reactivated.Fprint.Device.VerifyStatus ('verify-no-match', true)"
  readonly property string matchedLine: "/net/reactivated/Fprint/Device/0: net.reactivated.Fprint.Device.VerifyStatus ('verify-match', true)"
  readonly property string retryLine: "/net/reactivated/Fprint/Device/0: net.reactivated.Fprint.Device.VerifyStatus ('verify-retry-scan', false)"

  Item { id: host; width: 800; height: 600 }

  function check(condition, message) {
    checks += 1
    if (!condition) failures.push(message)
  }

  // Animations and timers are resources, not visual children, so walk data.
  function findByObjectName(node, name) {
    if (!node) return null
    if (node.objectName === name) return node
    var kids = node.data || node.children || []
    for (var i = 0; i < kids.length; i++) {
      var found = findByObjectName(kids[i], name)
      if (found) return found
    }
    return null
  }

  function load(path) {
    var component = Qt.createComponent("file://" + rootPath + path, Component.PreferSynchronous)
    if (component.status !== Component.Ready) throw new Error(component.errorString())
    return component
  }

  function runService() {
    var service = load("/shell/plugins/lock/Service.qml").createObject(host, { omarchyPath: rootPath })
    if (!service) throw new Error("Service failed to instantiate")
    try {
      var scanTimer = findByObjectName(service, "fingerprintScanTimer")
      var monitor = findByObjectName(service, "fingerprintMonitor")
      check(scanTimer !== null, "the service bounds a scan with a timer")
      check(monitor !== null, "the service has a monitor process for fprintd")
      if (!scanTimer || !monitor) return

      check(monitor.command[0] === "gdbus" && monitor.command.indexOf("net.reactivated.Fprint") > 0,
        "the monitor watches fprintd through gdbus")
      check(!service.fingerprintMonitoring && !monitor.running, "nothing watches fprintd while the session is unlocked")

      service.lockRequested = true
      check(!service.fingerprintMonitoring, "locking without a reader enrolled watches nothing")
      service.fingerprintConfigured = true
      // Quickshell reports the process running once started, and stopped only
      // once it has exited, so the stops below are read from the rule.
      check(service.fingerprintMonitoring && monitor.running, "locking with a reader enrolled starts the watch")

      service.fingerprintAuthenticating = false
      service.applyFingerprintMonitorLine(root.presentLine)
      check(!service.fingerprintScanning, "a finger outside the lock's own attempt is not its scan")

      service.fingerprintAuthenticating = true
      service.applyFingerprintMonitorLine("Monitoring signals from all objects owned by net.reactivated.Fprint")
      check(!service.fingerprintScanning, "the monitor's header starts no scan")

      service.applyFingerprintMonitorLine(root.presentLine)
      check(service.fingerprintScanning, "a finger on the reader during an attempt starts the scan")
      check(scanTimer.running, "a scan runs under its bound")

      service.applyFingerprintMonitorLine(root.absentLine)
      check(!service.fingerprintScanning && !scanTimer.running, "the finger leaving ends the scan")

      service.applyFingerprintMonitorLine(root.presentLine)
      service.settleFingerprintAttempt()
      check(!service.fingerprintScanning && !scanTimer.running, "the attempt settling ends the scan")

      service.fingerprintAuthenticating = true
      service.applyFingerprintMonitorLine(root.presentLine)
      service.resetAuthenticationState()
      check(!service.fingerprintScanning && !scanTimer.running, "an unlock's reset ends the scan")

      service.fingerprintAuthenticating = true
      service.applyFingerprintMonitorLine(root.presentLine)
      scanTimer.triggered()
      check(!service.fingerprintScanning, "a scan the daemon never ends is bounded")

      service.applyFingerprintMonitorLine(root.presentLine)
      check(service.fingerprintScanning, "the scan can start again after its bound")
      service.pauseFingerprint()
      check(!service.fingerprintScanning, "blanking the displays ends the scan")
      check(!service.fingerprintMonitoring, "nothing watches fprintd while the displays are off")
      service.resumeFingerprint()
      check(service.fingerprintMonitoring, "a wake watches fprintd again")

      service.lockRequested = false
      check(!service.fingerprintMonitoring, "unlocking stops the watch")

      // A rejected finger shows for a moment, whatever the attempt's state,
      // and the next finger landing, the lock resetting, a blank or the
      // moment passing ends it. Other verdicts show nothing.
      var rejectTimer = findByObjectName(service, "fingerprintRejectTimer")
      check(rejectTimer !== null, "the service bounds a rejection with a timer")
      if (!rejectTimer) return
      service.lockRequested = true
      service.fingerprintAuthenticating = true
      service.applyFingerprintMonitorLine(root.matchedLine)
      check(!service.fingerprintRejected, "a match is not a rejection")
      service.applyFingerprintMonitorLine(root.retryLine)
      check(!service.fingerprintRejected, "the reader asking to scan again is not a rejection")
      service.applyFingerprintMonitorLine(root.rejectedLine)
      check(service.fingerprintRejected && rejectTimer.running, "a rejected finger shows, under its bound")
      service.applyFingerprintMonitorLine(root.absentLine)
      check(service.fingerprintRejected, "the rejected finger leaving keeps the rejection showing")
      service.fingerprintAuthenticating = false
      service.applyFingerprintMonitorLine(root.rejectedLine)
      check(service.fingerprintRejected, "a rejection that ends the attempt still shows")
      rejectTimer.triggered()
      check(!service.fingerprintRejected && !rejectTimer.running, "the rejection ends when its moment passes")
      service.fingerprintAuthenticating = true
      service.applyFingerprintMonitorLine(root.rejectedLine)
      service.applyFingerprintMonitorLine(root.presentLine)
      check(!service.fingerprintRejected && service.fingerprintScanning, "the next finger landing ends the rejection and starts its scan")
      service.applyFingerprintMonitorLine(root.rejectedLine)
      service.resetAuthenticationState()
      check(!service.fingerprintRejected && !rejectTimer.running, "an unlock's reset ends the rejection")
      service.fingerprintAuthenticating = true
      service.applyFingerprintMonitorLine(root.rejectedLine)
      service.pauseFingerprint()
      check(!service.fingerprintRejected, "blanking the displays ends the rejection")
      service.resumeFingerprint()
      service.lockRequested = false
    } finally {
      service.lockRequested = false
      service.destroy()
    }
  }

  // The monitor's lines reach the scan through the process's own parser,
  // which the direct calls above don't exercise: a printf stands in for gdbus
  // and prints one finger landing, read once the event loop turns. A new
  // service asks fprintd-list about enrolment on creation, and that answer
  // (none, in this scratch home) lands in the event loop too and settles any
  // attempt, so the stand-in starts only once it has.
  property var wiringService: null

  function startWiring() {
    var service = load("/shell/plugins/lock/Service.qml").createObject(host, { omarchyPath: rootPath })
    if (!service) throw new Error("Service failed to instantiate for the wiring check")
    wiringService = service
    wiringTimer.phase = 1
    wiringTimer.start()
  }

  function armWiring() {
    var service = wiringService
    var monitor = findByObjectName(service, "fingerprintMonitor")
    monitor.command = ["printf", "%s\\n", root.presentLine]
    service.fingerprintConfigured = true
    service.lockRequested = true
    service.fingerprintAuthenticating = true
    check(!service.fingerprintScanning, "nothing is scanning before the monitor's line arrives")
  }

  function finishWiring() {
    var service = wiringService
    wiringService = null
    if (!service) return
    try {
      check(service.fingerprintScanning, "a finger the monitor process reports starts the scan")
    } finally {
      service.lockRequested = false
      service.destroy()
    }
  }

  function writeResult() {
    var payload = JSON.stringify({ ok: failures.length === 0, checks: checks, failures: failures })
    if (resultPath) {
      Quickshell.execDetached(["bash", "-lc", "printf '%s' '" + payload.replace(/'/g, "'\\''") + "' > '" + resultPath.replace(/'/g, "'\\''") + "'"])
    }
  }

  Timer {
    interval: 1
    running: true
    repeat: false
    onTriggered: {
      try {
        root.runService()
        root.startWiring()
      } catch (error) {
        root.failures.push("lock fingerprint scan fixture threw: " + error)
        root.writeResult()
      }
    }
  }

  Timer {
    id: wiringTimer
    interval: 400
    repeat: false
    property int phase: 0
    onTriggered: {
      if (phase === 1) {
        try {
          root.armWiring()
          phase = 2
          start()
        } catch (error) {
          root.failures.push("lock fingerprint scan fixture threw: " + error)
          root.writeResult()
        }
        return
      }
      try {
        root.finishWiring()
      } catch (error) {
        root.failures.push("lock fingerprint scan fixture threw: " + error)
      } finally {
        root.writeResult()
      }
    }
  }
}
