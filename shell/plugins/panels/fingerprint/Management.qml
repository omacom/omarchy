import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons as Commons

Item {
  id: root
  visible: false
  readonly property string helper: Quickshell.env("OMARCHY_PATH") + "/default/fingerprint/manage.py"
  property var state: ({ readers: [], reader: "", prints: [], capacity: 0, lock: false, sudo: "custom" })
  property string reader: ""
  property string action: ""
  property string afterMatch: ""
  property string notice: ""
  readonly property bool busy: list.running || action !== ""
  readonly property bool authorizing: action === "remove" || action === "sudo-on" || action === "sudo-off" || action === "prepare-lock"
  signal refreshed()

  function refresh(token) {
    reader = token || ""
    list.command = [helper, "list", reader]
    list.running = true
  }
  Component.onCompleted: refresh("")

  function run(name, command) {
    action = name
    worker.command = command
    worker.running = true
  }

  function verify(slot, next) {
    afterMatch = next || ""
    notice = Commons.I18n.t("fingerprint.verifyTouch")
    run("verify", [helper, "verify", state.reader, slot])
  }

  function changeLock(on) {
    notice = ""
    if (on) verify("any", "lock-on")
    else run("lock-off", ["omarchy-toggle", "lock-fingerprint-off", "on"])
  }

  function changeSudo(on) {
    notice = ""
    if (on) verify("any", "sudo-on")
    else sudoPam(false)
  }

  function sudoPam(on) {
    // pkexec must always execute the root-owned copy, including in a dev shell.
    run(on ? "sudo-on" : "sudo-off", ["pkexec", "/usr/share/omarchy/default/fingerprint/sudo_pam.py", on ? "enable" : "disable"])
  }

  Process {
    id: list
    stdout: StdioCollector { id: result; waitForEnd: true }
    onExited: function(code) {
      try {
        if (code !== 0) throw new Error()
        root.state = JSON.parse(result.text)
        root.reader = root.state.reader
        if (root.state.error) root.notice = Commons.I18n.t("fingerprint.failNoReader")
      } catch (e) {
        root.state = { readers: [], reader: "", prints: [], capacity: 0, lock: false, sudo: "custom" }
        root.notice = Commons.I18n.t("fingerprint.manageFailed")
      }
      root.refreshed()
    }
  }

  Process {
    id: worker
    stdout: StdioCollector { id: output; waitForEnd: true }
    onExited: function(code) {
      const action = root.action
      root.action = ""
      if (code !== 0) {
        root.afterMatch = ""
        root.notice = output.text.trim().endsWith("fail no-match")
          ? Commons.I18n.t("fingerprint.failNoMatch") : Commons.I18n.t("fingerprint.manageFailed")
      } else if (action === "verify") {
        const next = root.afterMatch
        root.afterMatch = ""
        root.notice = Commons.I18n.t("fingerprint.matched")
        if (next === "sudo-on") { root.sudoPam(true); return }
        if (next === "lock-on") {
          if (!root.state.lockPam) {
            root.run("prepare-lock", ["pkexec", "/usr/bin/omarchy-setup-security-fingerprint-enroll", "enable-lock"])
          } else {
            root.run("lock-on", ["omarchy-toggle", "lock-fingerprint-off", "off"])
          }
          return
        }
      } else if (action === "prepare-lock") {
        root.run("lock-on", ["omarchy-toggle", "lock-fingerprint-off", "off"])
        return
      } else root.notice = ""
      root.refresh(root.reader)
    }
  }
}
