import QtQml

QtObject {
  id: root

  property bool pending: false
  property bool replyReceived: false
  property string reply: ""
  property var exitCode: null
  signal completed(var result)

  function begin() {
    replyReceived = false
    reply = ""
    exitCode = null
    pending = true
  }

  function receive(text) {
    reply = text
    replyReceived = true
    finish()
  }

  function exited(code) {
    exitCode = code
    finish()
  }

  function finish() {
    if (!pending || !replyReceived || exitCode === null) return
    var result
    try {
      result = JSON.parse(reply)
    } catch (error) {
      result = null
    }
    completed({
      ok: exitCode === 0 && result !== null && result.ok === true,
      error: result && result.error,
      otherWorkspace: result ? Number(result.otherWorkspace) || 0 : 0
    })
    pending = false
  }
}
