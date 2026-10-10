import QtQml

QtObject {
  id: root
  property bool running: false
  property var command: []
  property QtObject stdout: null
  property QtObject stderr: null
  property var signals: []
  property int startCount: 0
  signal exited(int exitCode, int exitStatus)

  onRunningChanged: if (running) {
    startCount++
    if (stdout && "text" in stdout) stdout.text = ""
    if (stderr && "text" in stderr) stderr.text = ""
  }
  Component.onCompleted: ProcessHarness.processes = ProcessHarness.processes.concat([root])

  function complete(code, status, output) {
    if (stdout && "text" in stdout) {
      stdout.text = output || ""
      stdout.streamFinished()
    }
    running = false
    exited(code, status)
  }

  function signal(number) { signals = signals.concat([number]) }
}
