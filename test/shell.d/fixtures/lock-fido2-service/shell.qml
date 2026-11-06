import QtQuick
import Quickshell
import Quickshell.Services.Pam
import qs.Commons

ShellRoot {
  id: root

  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []
  property int checks: 0

  Item { id: host }

  function check(condition, message) {
    checks += 1
    if (!condition) failures.push(message)
  }

  function retryTimer(service) {
    var objects = service.data || []
    for (var i = 0; i < objects.length; i++) {
      if (objects[i].objectName === "fido2RetryTimer") return objects[i]
    }
    throw new Error("Missing fido2 retry timer")
  }

  function attempt(service, prompted, ageMs) {
    service.fido2Authenticating = true
    service.fido2Prompting = prompted
    service.fido2AttemptStartedMs = Date.now() - ageMs
  }

  function run() {
    var component = Qt.createComponent("file://" + rootPath + "/shell/plugins/lock/Service.qml", Component.PreferSynchronous)
    if (component.status !== Component.Ready) throw new Error(component.errorString())
    var service = component.createObject(host, { omarchyPath: rootPath })
    if (!service) throw new Error(component.errorString())
    try {
      var retry = retryTimer(service)
      service.lockRequested = true
      service.fido2Configured = true

      attempt(service, false, 100)
      service.handleFido2Finished(PamResult.Failed)
      check(!service.fido2Authenticating && !service.fido2Prompting, "a failed attempt closes and clears the cue")
      check(service.fido2Streak === 1 && retry.running && retry.interval === 2000, "an attempt that never prompted backs off")
      check(service.lockRequested, "a failed attempt never unlocks")

      attempt(service, false, 100)
      service.settleFido2Attempt()
      check(service.fido2Streak === 2 && retry.interval === 4000, "consecutive misses keep doubling the wait")
      service.settleFido2Attempt()
      check(service.fido2Streak === 2, "a second completion signal settles nothing")

      attempt(service, true, 6000)
      service.settleFido2Attempt()
      check(service.fido2Streak === 0 && retry.interval === 1000, "a touch window that ran out retries at the normal pace")

      attempt(service, true, 100)
      service.settleFido2Attempt()
      check(service.fido2Streak === 1, "a prompt that failed at once still backs off")

      // Blanking drops a pending touch without counting it as a miss, and
      // nothing arms a retry until the screen is woken.
      attempt(service, true, 1000)
      service.fido2Streak = 3
      service.pauseFido2()
      check(service.fido2Paused && !service.fido2Authenticating && !service.fido2Prompting, "pausing drops a pending touch and its cue")
      check(!retry.running && service.fido2Streak === 3, "pausing stops the retry and keeps the backoff")
      attempt(service, false, 100)
      service.settleFido2Attempt()
      check(!retry.running, "an attempt ending while paused arms no retry")
      service.fido2Authenticating = false
      service.resumeFido2()
      check(!service.fido2Paused, "waking resumes the key")

      // Removing the service file mid-lock disarms everything.
      attempt(service, false, 100)
      service.settleFido2Attempt()
      check(retry.running, "a retry is armed while configured")
      service.fido2Configured = false
      check(!retry.running && service.fido2Streak === 0, "removing the service stops the retries")

      service.fido2Configured = true
      attempt(service, true, 100)
      service.resetAuthenticationState()
      check(!service.fido2Authenticating && !service.fido2Prompting && !retry.running && service.fido2Streak === 0, "a lock reset clears the key attempt")
    } finally {
      service.resetAuthenticationState()
      service.destroy()
    }
  }

  Timer {
    interval: 1
    running: true
    onTriggered: {
      try {
        root.run()
      } catch (error) {
        root.failures.push(String(error))
      }
      var payload = JSON.stringify({ ok: root.failures.length === 0, checks: root.checks, failures: root.failures })
      var quoted = "'" + payload.replace(/'/g, "'\\''") + "'"
      Quickshell.execDetached(["bash", "-c", "printf '%s' " + quoted + " > \"$1\"", "_", root.resultPath])
    }
  }
}
