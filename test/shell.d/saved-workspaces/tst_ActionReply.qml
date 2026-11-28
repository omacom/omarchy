import QtQml
import QtTest
import "../../../shell/plugins/saved-workspaces" as Scenes

TestCase {
  name: "ScenesActionReply"

  Scenes.ActionReply { id: action }
  SignalSpy { id: replies; target: action; signalName: "completed" }

  function init() {
    replies.clear()
    action.begin()
  }

  function test_success_data() {
    return [
      { tag: "exit first", exitFirst: true },
      { tag: "reply first", exitFirst: false }
    ]
  }

  function test_success(data) {
    const reply = '{"ok":true,"otherWorkspace":8}'
    if (data.exitFirst) action.exited(0)
    else action.receive(reply)
    compare(replies.count, 0)
    verify(action.pending)

    if (data.exitFirst) action.receive(reply)
    else action.exited(0)
    compare(replies.count, 1)
    verify(replies.signalArguments[0][0].ok)
    compare(replies.signalArguments[0][0].otherWorkspace, 8)
    verify(!action.pending)
  }

  function test_failed_action_does_not_reuse_previous_reply() {
    action.receive('{"ok":true}')
    action.exited(0)
    action.begin()
    replies.clear()
    action.exited(1)
    compare(replies.count, 0)
    action.receive('{"ok":false,"error":"Could not restore"}')
    compare(replies.count, 1)
    verify(!replies.signalArguments[0][0].ok)
    compare(replies.signalArguments[0][0].error, "Could not restore")
    verify(!action.pending)
  }

  function test_empty_output_releases_busy_state() {
    action.receive("")
    action.exited(-1)
    compare(replies.count, 1)
    verify(!replies.signalArguments[0][0].ok)
    verify(!action.pending)
  }
}
