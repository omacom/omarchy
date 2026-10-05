import QtQuick
import Quickshell

ShellRoot {
  id: harness
  property string scenario: Quickshell.env("CF_TEST_SCENARIO")
  property int tick: 0
  property int failures: 0
  Service { id: service }

  function check(value, label) {
    console.log((value ? "ok - " : "not ok - ") + label)
    if (!value) failures++
  }

  Timer {
    interval: 100
    running: true
    repeat: true
    onTriggered: {
      harness.tick++
      if (harness.scenario === "account") {
        if (harness.tick === 4) service.selectAccount("b")
        if (harness.tick === 24) {
          harness.check(service.selectedAccountId === "b", "selected account stays B")
          harness.check(service.workers.length === 1 && service.workers[0].name === "b-worker", "in-flight account switch loads B Workers")
          harness.check(service.zones.length === 1 && service.zones[0].name === "b.test", "in-flight account switch loads B domains")
          Qt.quit()
        }
      } else if (harness.scenario === "detail") {
        if (harness.tick === 4) service.prefetchWorker({name: "alpha", logsEnabled: true})
        if (harness.tick === 8) service.openWorkerDetail({name: "beta", logsEnabled: true})
        if (harness.tick === 24) {
          harness.check(service.detailMetrics.invocations && service.detailMetrics.invocations.value === 42, "replacement Worker metrics loaded")
          harness.check(service.metricsError === "", "cancelled Worker cannot poison replacement metrics")
          harness.check(service._detailCache.beta && service._detailCache.beta.metricsError === "", "replacement cache has no stale error")
          Qt.quit()
        }
      }
      if (harness.scenario === "repeat-account") {
        if (harness.tick === 3) service.selectAccount("b")
        if (harness.tick === 4) service.selectAccount("a")
        if (harness.tick === 5) service.selectAccount("b")
        if (harness.tick === 24) {
          harness.check(service.workers.length === 1 && service.workers[0].name === "b-worker", "repeated interrupted account selection ends on B")
          Qt.quit()
        }
      } else if (harness.scenario === "signout") {
        if (harness.tick === 4) service.applyWhoami('{"authenticated":false}')
        if (harness.tick === 24) {
          harness.check(!service.authenticated && service.selectedAccountId === "", "sign-out clears account")
          harness.check(service.workers.length === 0 && service.zones.length === 0, "late lists cannot repopulate a signed-out service")
          Qt.quit()
        }
      } else if (harness.scenario === "offline") {
        if (harness.tick === 14) service.applyWhoami('{"authenticated":true,"tokenValid":false,"accounts":[]}')
        if (harness.tick === 16) {
          harness.check(service.authenticated && !service.tokenValid && service.selectedAccountId === "a", "failed verification preserves selected account")
          harness.check(service.workers.length === 1 && service.accounts.length === 2, "failed verification preserves resources and accounts")
          harness.check(service.statusText === "Could not verify Cloudflare login", "offline status does not claim token rejection")
          service.applyWhoami('bad json')
          harness.check(service.authenticated && service.selectedAccountId === "a", "malformed status does not sign the user out")
          service.refresh()
        }
        if (harness.tick === 30) {
          harness.check(service.tokenValid && service.lastError === "", "refresh recovers after failed verification")
          Qt.quit()
        }
      } else if (harness.scenario === "pagination" || harness.scenario === "pagination-failure") {
        if (harness.tick === 10 && harness.scenario === "pagination-failure") {
          harness.check(service.workers.length === 0 && service.zones.length === 0, "failed second page never publishes an incomplete list")
          harness.check(service.workersError !== "" && service.zonesError !== "", "failed pages report errors")
          service.refreshResources()
        }
        if (harness.tick === 24) {
          harness.check(service.workers.length === 102, "all Worker pages load")
          harness.check(service.zones.length === 52, "all account-scoped domain pages load")
          harness.check(service.workersError === "" && service.zonesError === "", "complete lists clear errors")
          Qt.quit()
        }
      } else if (harness.scenario === "repeat-detail") {
        if (harness.tick === 4) service.openWorkerDetail({name: "alpha", logsEnabled: true})
        if (harness.tick === 8) { service.closeWorkerDetail(); service.prefetchWorker({name: "beta", logsEnabled: true}) }
        if (harness.tick === 9) service.openWorkerDetail({name: "gamma", logsEnabled: true})
        if (harness.tick === 20) { service.closeWorkerDetail(); service.openWorkerDetail({name: "gamma", logsEnabled: true}) }
        if (harness.tick === 24) {
          harness.check(service._detailName === "gamma" && service.detailWorker.name === "gamma", "latest selection wins repeated open and close")
          harness.check(service.metricsError === "" && service._detailCache.gamma && service.detailMetrics.invocations.value === 42, "reopened Worker retains its successful cache")
          service.refreshWorkerDetail()
        }
        if (harness.tick === 30) {
          harness.check(!service.metricsLoading && service.metricsError === "", "repeated detail refresh completes")
          Qt.quit()
        }
      } else if (harness.scenario === "login") {
        if (harness.tick === 4) { service.login(); service.login() }
        if (harness.tick === 24) {
          harness.check(service.authenticated && !service.busy, "repeated login completes and refreshes status")
          Qt.quit()
        }
      }
      if (harness.scenario === "detail-timeout") {
        if (harness.tick === 4) {
          var found = false
          for (var i = 0; i < service.data.length; i++) {
            if (service.data[i].interval === 25000) { service.data[i].interval = 500; found = true }
          }
          harness.check(found, "fixture shortens the real detail watchdog")
          service.openWorkerDetail({name: "stalled", logsEnabled: false})
        }
        if (harness.tick === 18) {
          harness.check(!service.versionsLoading && service.versionsError !== "", "stalled versions time out even without Worker logs")
          harness.check(service.deploymentsLoaded, "stalled deployment call finishes loading state")
          service.openWorkerDetail({name: "beta", logsEnabled: true})
        }
        if (harness.tick === 28) {
          harness.check(!service.versionsLoading && service.detailVersions[0].id === "beta-version", "another Worker loads after version timeout")
          service.forgetWorkerDetail()
          Qt.quit()
        }
      } else if (harness.scenario === "stubborn-detail") {
        if (harness.tick === 4) service.openWorkerDetail({name: "stubborn", logsEnabled: false})
        if (harness.tick === 8) service.openWorkerDetail({name: "beta", logsEnabled: true})
        if (harness.tick === 28) {
          harness.check(!service.versionsLoading && service.detailVersions[0] && service.detailVersions[0].id === "beta-version", "cancelled calls that ignore SIGTERM cannot block the next Worker")
          Qt.quit()
        }
      } else if (harness.scenario === "errors-query") {
        if (harness.tick === 4) service.openWorkerDetail({name: "errorfail", logsEnabled: true})
        if (harness.tick === 18) {
          harness.check(service.metricsError !== "", "failed errors query is explained even when usage succeeds later")
          harness.check(service._detailCache.errorfail && service._detailCache.errorfail.metricsError !== "", "cached detail preserves errors-query failure")
          service.openWorkerDetail({name: "beta", logsEnabled: true})
        }
        if (harness.tick === 28) {
          harness.check(service.metricsError === "", "next Worker starts without the prior query failure")
          Qt.quit()
        }
      }
      if (harness.tick > 80) { harness.check(false, "scenario timed out"); Qt.quit() }
    }
  }
}
