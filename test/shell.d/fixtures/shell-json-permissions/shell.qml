import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
  id: root

  readonly property string home: Quickshell.env("HOME")
  readonly property string userConfigPath: home + "/.config/omarchy/shell.json"
  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")

  property var failures: []

  function fail(message) {
    failures.push(String(message))
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult(ok) {
    var payload = JSON.stringify({
      ok: ok && failures.length === 0,
      failures: failures
    })
    if (resultPath) {
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
    }
  }

  function secureUserConfigFile() {
    Quickshell.execDetached(["bash", "-c", "[[ -f \"$0\" ]] && chmod 0600 \"$0\" || true", root.userConfigPath])
  }

  function persistShellConfig(nextConfig) {
    var payload = JSON.parse(JSON.stringify(nextConfig))
    payload.version = 1
    userConfigFile.setText(JSON.stringify(payload, null, 2) + "\n")
    secureUserConfigFile()
    secureUserConfigTimer.restart()
  }

  Timer {
    id: secureUserConfigTimer
    interval: 50
    repeat: false
    onTriggered: root.secureUserConfigFile()
  }

  FileView {
    id: userConfigFile
    path: root.userConfigPath
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: root.secureUserConfigFile()
    onFileChanged: root.secureUserConfigFile()
  }

  Process {
    id: checkModeProcess
    property string targetMode: "600"
    property var onPass: null
    property var onFail: null

    stdout: StdioCollector {
      onStreamFinished: {
        var mode = value.trim()
        if (mode === checkModeProcess.targetMode) {
          if (checkModeProcess.onPass) checkModeProcess.onPass()
        } else {
          root.fail("expected mode " + checkModeProcess.targetMode + " but got " + mode)
          if (checkModeProcess.onFail) checkModeProcess.onFail()
        }
      }
    }
  }

  function checkMode(expected, passCb, failCb) {
    checkModeProcess.targetMode = expected
    checkModeProcess.onPass = passCb
    checkModeProcess.onFail = failCb
    checkModeProcess.command = ["stat", "-c", "%a", root.userConfigPath]
    checkModeProcess.running = true
  }

  Timer {
    id: testRunner
    interval: 100
    running: true
    onTriggered: {
      root.persistShellConfig({ version: 1, test: "fresh" })
      step1VerifyTimer.start()
    }
  }

  Timer {
    id: step1VerifyTimer
    interval: 200
    onTriggered: {
      root.checkMode("600", function() {
        Quickshell.execDetached(["bash", "-c", "chmod 0644 " + root.shellQuote(root.userConfigPath)])
        step2ReloadTimer.start()
      }, function() {
        root.writeResult(false)
      })
    }
  }

  Timer {
    id: step2ReloadTimer
    interval: 100
    onTriggered: {
      userConfigFile.reload()
      step2VerifyTimer.start()
    }
  }

  Timer {
    id: step2VerifyTimer
    interval: 200
    onTriggered: {
      root.checkMode("600", function() {
        root.writeResult(true)
      }, function() {
        root.writeResult(false)
      })
    }
  }
}
