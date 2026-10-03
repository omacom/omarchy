import QtQuick
import Quickshell.Io

// Live fingerprint reader state for authentication UIs. pam_fprintd only
// reports the final verdict, but fprintd broadcasts finger-needed /
// finger-present and VerifyStatus while pam_fprintd holds the reader, so a
// passive `gdbus monitor` sees the scan as it happens. Display only: the
// caller's PAM context still decides whether authentication succeeds.
Item {
  id: root

  // Watch the reader while true.
  property bool active: false
  property bool needed: false
  property bool present: false
  // A finger reached the sensor since the last verdict. Some drivers (Apple
  // SEP) answer a verify that pam_fprintd cancels at its timeout with
  // verify-no-match, though nothing touched the sensor.
  property bool touched: false
  // Transient verdict shown briefly after a read: "", "match", "no-match", "retry".
  property string result: ""
  // "idle", "waiting", "scanning", "matched" or "rejected".
  readonly property string readerState: {
    if (result === "match") return "matched"
    if (result !== "") return "rejected"
    if (present) return "scanning"
    if (needed) return "waiting"
    return "idle"
  }

  // A finger landed on the sensor, starting a new read.
  signal fingerLanded()
  // A read finished: "match", "no-match" or "retry".
  signal verdict(string result)

  function clear() {
    needed = false
    present = false
    touched = false
    result = ""
    resultTimer.stop()
  }

  // The verify ended (PAM finished); keep any verdict on screen.
  function endVerify() {
    needed = false
    present = false
    touched = false
  }

  function showResult(value) {
    present = false
    result = value
    resultTimer.restart()
    verdict(value)
  }

  // One line of `gdbus monitor` output. Only the reader-state properties and
  // VerifyStatus matter; everything else fprintd emits is ignored.
  function handleLine(line) {
    if (!active) return
    line = String(line || "")

    var status = line.match(/VerifyStatus \('([a-z-]+)'/)
    if (status) {
      var wasTouched = touched
      touched = false
      if (status[1] === "verify-match") showResult("match")
      // A rejection with no finger on the sensor is a cancelled verify, not a
      // read: reporting it would flash a rejection every PAM timeout.
      else if (!wasTouched) return
      else if (status[1] === "verify-no-match") showResult("no-match")
      else if (status[1] !== "verify-disconnected" && status[1] !== "verify-unknown-error") showResult("retry")
      return
    }

    var neededMatch = line.match(/'finger-needed': <(true|false)>/)
    if (neededMatch) needed = neededMatch[1] === "true"

    var presentMatch = line.match(/'finger-present': <(true|false)>/)
    if (presentMatch) {
      var wasPresent = present
      present = presentMatch[1] === "true"
      // A new read replaces the last verdict.
      if (present && !wasPresent) {
        touched = true
        result = ""
        resultTimer.stop()
        fingerLanded()
      }
    }
  }

  Timer {
    id: resultTimer
    interval: 1500
    repeat: false
    onTriggered: root.result = ""
  }

  Process {
    command: ["gdbus", "monitor", "--system", "--dest", "net.reactivated.Fprint"]
    running: root.active
    stdout: SplitParser {
      onRead: function(data) { root.handleLine(data) }
    }
  }
}
