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

  // The process that turns the displays off.
  function blankProcess(service) {
    var objects = service.data || []
    for (var i = 0; i < objects.length; i++) {
      var command = objects[i].command
      if (command && String(command).indexOf("omarchy-brightness-display off") !== -1) return objects[i]
    }
    return null
  }

  // The idle blank countdown is the timer with an idle run-up of its own.
  function idleBlank(service) {
    var objects = service.data || []
    for (var i = 0; i < objects.length; i++) {
      if (objects[i].idleMs !== undefined && objects[i].resumeMs !== undefined) return objects[i]
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
      // Stopping gdbus is asynchronous, and the attempt runs on through the
      // blank, so a line already in the pipe can still arrive.
      check(service.fingerprintAuthenticating, "the attempt runs on through the blank")
      service.applyFingerprintMonitorLine(root.presentLine)
      check(!service.fingerprintScanning, "a finger line read after the blank starts no scan")
      service.resumeFingerprint()
      check(service.fingerprintMonitoring, "a wake watches fprintd again")

      service.lockRequested = false
      check(!service.fingerprintMonitoring, "unlocking stops the watch")

      // pam_fprintd's error message, a no-match or an ask to scan again, ends
      // the scan and shows for a moment; the lock resetting, a blank or the
      // moment passing ends that, and the next finger landing doesn't, since
      // pam_fprintd matches a finger left on the reader again at once.
      var rejectTimer = findByObjectName(service, "fingerprintRejectTimer")
      check(rejectTimer !== null, "the service bounds a rejection with a timer")
      if (!rejectTimer) return
      service.lockRequested = true
      service.fingerprintAuthenticating = true
      service.applyFingerprintMonitorLine(root.presentLine)
      service.noteFingerprintRejected()
      check(service.fingerprintRejected && rejectTimer.running, "a rejected finger shows, under its bound")
      check(!service.fingerprintScanning && !scanTimer.running, "a rejection ends the scan, though the reader still reports the finger")
      service.applyFingerprintMonitorLine(root.absentLine)
      check(service.fingerprintRejected, "the rejected finger leaving keeps the rejection showing")
      var count = service.fingerprintRejectCount
      service.noteFingerprintRejected()
      check(service.fingerprintRejectCount === count + 1, "a rejection while the last one still shows counts as a new one")
      rejectTimer.triggered()
      check(!service.fingerprintRejected && !rejectTimer.running, "the rejection ends when its moment passes")
      service.noteFingerprintRejected()
      service.applyFingerprintMonitorLine(root.presentLine)
      check(service.fingerprintRejected && service.fingerprintScanning, "the next finger landing starts its scan and keeps the rejection showing")
      service.resetAuthenticationState()
      check(!service.fingerprintRejected && !rejectTimer.running, "an unlock's reset ends the rejection")
      service.fingerprintAuthenticating = true
      service.noteFingerprintRejected()
      service.pauseFingerprint()
      check(!service.fingerprintRejected, "blanking the displays ends the rejection")
      service.noteFingerprintRejected()
      check(!service.fingerprintRejected && !rejectTimer.running, "a rejection while the displays are off shows nothing")
      service.resumeFingerprint()
      service.lockRequested = false
      service.noteFingerprintRejected()
      check(!service.fingerprintRejected, "a rejection after the unlock shows nothing")
      service.lockRequested = true

      // A finger on the reader holds the idle blank, and so does the moment
      // after a rejection; lifting it, the verdict or the moment passing
      // starts a fresh run-up. The blank's own command is swapped for `true`
      // before it may fire, or it would drive this machine's real displays.
      var blank = idleBlank(service)
      check(blank !== null, "the service has its idle blank countdown")
      if (blank) {
        service.clearFingerprintReject()
        service.fingerprintAuthenticating = true
        service.armBlankTimer()
        check(blank.running, "the countdown runs while the lock waits")
        service.applyFingerprintMonitorLine(root.presentLine)
        check(!blank.running, "a finger on the reader holds the countdown")
        service.applyFingerprintMonitorLine(root.absentLine)
        check(blank.running, "the finger lifting starts a fresh run-up")
        service.applyFingerprintMonitorLine(root.presentLine)
        service.noteFingerprintRejected()
        service.applyFingerprintMonitorLine(root.absentLine)
        check(!blank.running, "the moment after a rejection keeps holding it")
        findByObjectName(service, "fingerprintRejectTimer").triggered()
        check(blank.running, "the rejection's moment passing starts a fresh run-up")
        service.applyFingerprintMonitorLine(root.presentLine)
        service.pauseFingerprint()
        check(!blank.running, "a hold ending in a blank arms nothing while the displays are off")
        service.resumeFingerprint()
        service.applyFingerprintMonitorLine(root.presentLine)
        service.authenticatingPassword = true
        service.applyFingerprintMonitorLine(root.absentLine)
        check(!blank.running, "a hold ending during a password check leaves the check holding the display")
        service.authenticatingPassword = false
        check(blank.running, "the password check ending starts the run-up")
        service.applyFingerprintMonitorLine(root.presentLine)
        service.lockRequested = false
        service.resetAuthenticationState()
        check(!blank.running, "a hold ending in an unlock arms nothing")
        blank.stop()

        // The blank's trigger refuses while a finger holds the display, even
        // when input restarted the countdown during the hold.
        var blanker = blankProcess(service)
        if (blanker) blanker.command = ["true"]
        check(blanker !== null && blanker.command.length === 1 && blanker.command[0] === "true", "the blank's command is a stand-in before the trigger fires")
        if (blanker && blanker.command[0] === "true") {
          service.lockRequested = true
          service.fingerprintAuthenticating = true
          service.applyFingerprintMonitorLine(root.presentLine)
          service.armBlankTimer()
          blank.triggered()
          check(!service.fingerprintPaused, "the countdown firing under a finger doesn't blank")
          service.clearFingerprintScan()
          service.armBlankTimer()
          blank.triggered()
          check(service.fingerprintPaused, "the countdown firing with nothing holding it blanks")
          service.resumeFingerprint()
          blank.stop()
          service.lockRequested = false
        }
      }
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
  // lands in the event loop too and settles any attempt, so the stand-in
  // starts only once the probe has exited. Each step moves on when what it
  // waits for happens; the timer only fails a step that never does.
  property var wiringService: null
  property bool wiringDone: false

  function probeProcess(service) {
    var objects = service.data || []
    for (var i = 0; i < objects.length; i++) {
      var command = objects[i].command
      if (command && String(command).indexOf("fprintd-list") !== -1) return objects[i]
    }
    return null
  }

  function startWiring() {
    var service = load("/shell/plugins/lock/Service.qml").createObject(host, { omarchyPath: rootPath })
    if (!service) throw new Error("Service failed to instantiate for the wiring check")
    wiringService = service
    wiringTimeout.start()
    var probe = probeProcess(service)
    check(probe !== null, "the service has its enrolment probe")
    if (probe && probe.running) probe.exited.connect(function() { Qt.callLater(root.armWiring) })
    else Qt.callLater(root.armWiring)
  }

  function armWiring() {
    var service = wiringService
    if (!service || wiringDone) return
    try {
      var monitor = findByObjectName(service, "fingerprintMonitor")
      monitor.command = ["printf", "%s\\n", root.presentLine]
      service.fingerprintScanningChanged.connect(function() {
        if (service.fingerprintScanning) root.finishWiring(true)
      })
      service.fingerprintConfigured = true
      service.lockRequested = true
      service.fingerprintAuthenticating = true
      check(!service.fingerprintScanning, "nothing is scanning before the monitor's line arrives")
    } catch (error) {
      root.failures.push("lock fingerprint scan fixture threw: " + error)
      root.finishWiring(false)
    }
  }

  function finishWiring(scanned) {
    if (wiringDone) return
    wiringDone = true
    wiringTimeout.stop()
    var service = wiringService
    wiringService = null
    check(scanned, "a finger the monitor process reports starts the scan")
    if (service) {
      service.lockRequested = false
      service.destroy()
    }
    writeResult()
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
        if (root.wiringService) root.finishWiring(false)
        else root.writeResult()
      }
    }
  }

  Timer {
    id: wiringTimeout
    interval: 5000
    repeat: false
    onTriggered: root.finishWiring(false)
  }
}
