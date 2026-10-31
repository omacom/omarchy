import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
  id: harness
  property int tick: 0
  property var first: null
  property var second: null
  property int closedCount: 0
  Component { id: consumer; Client {} }
  Component.onCompleted: {
    first = consumer.createObject(harness, { settings: { refreshIntervalSec: 60 } })
    second = consumer.createObject(harness, { settings: { refreshIntervalSec: 30 } })
  }

  FileView { id: log; path: Quickshell.env("CF_TEST_CALLS"); blockLoading: true; watchChanges: true; onFileChanged: reload() }
  function calls() {
    var text = log.text().trim()
    return text ? text.split("\n").map(function(line) { return JSON.parse(line)[1].join(" ") }) : []
  }
  function count(prefix) { return calls().filter(function(call) { return call.indexOf(prefix) === 0 }).length }
  function check(value, label) { console.log((value ? "ok - " : "not ok - ") + label) }
  function shortenPolling() {
    for (var i = 0; i < SharedService.data.length; i++) {
      var child = SharedService.data[i]
      if (child.repeat === true) { child.interval = 200; return }
    }
    check(false, "refresh timer was found")
  }

  Timer {
    interval: 100
    running: true
    repeat: true
    onTriggered: {
      harness.tick++
      if (Quickshell.env("CF_TEST_SCENARIO") === "reattach") {
        if (harness.tick === 1) {
          // Reattach in the same turn, before the cancelled Process can emit
          // exited. Client destruction calls detach again, which is a no-op.
          SharedService.detach(harness.first)
          SharedService.detach(harness.second)
          harness.first.destroy()
          harness.second.destroy()
          harness.first = consumer.createObject(harness)
        }
        if (harness.tick === 12) {
          harness.check(SharedService.installed && SharedService.authenticated, "recreating widgets during a cancelled probe recovers the bar status")
          harness.first.opened = true
        }
        if (harness.tick === 24) {
          harness.check(SharedService.workers.length === 1 && SharedService.zones.length === 1, "recreated widget loads account resources")
          harness.first.destroy()
          Qt.quit()
        }
        return
      }
      if (harness.tick === 8) {
        harness.check(harness.count("auth whoami") === 1, "two closed monitor clients share one startup status probe")
        harness.check(harness.count("workers list") === 0 && harness.count("zones list") === 0, "closed monitors start no resource requests")
        harness.check(SharedService.parent === null, "authentication service has no host QObject parent")
        harness.first.opened = true
        harness.second.opened = true
      }
      if (harness.tick === 20) {
        harness.check(harness.count("auth whoami") === 2 && harness.count("workers list") === 1 && harness.count("zones list") === 1, "two visible clients share one resource refresh")
        harness.check(SharedService.refreshIntervalSec === 30, "visible clients use the shortest configured refresh interval")
        SharedService.openWorkerDetail({ name: "beta", logsEnabled: true })
        harness.second.opened = false
        harness.check(SharedService.refreshIntervalSec === 60, "closed clients no longer shorten the refresh interval")
      }
      if (harness.tick === 25) {
        harness.second.opened = true
        harness.check(SharedService.detailWorker.name === "beta" && SharedService.detailMetrics.invocations.value === 42, "opening another monitor preserves the shared Worker view")
        harness.first.opened = false
        harness.second.opened = false
        harness.shortenPolling()
      }
      if (harness.tick === 30) harness.closedCount = harness.calls().length
      if (harness.tick === 38) {
        harness.check(harness.calls().length === harness.closedCount, "closed panels remain quiet across refresh intervals")
        SharedService.login()
      }
      if (harness.tick === 52) {
        harness.check(harness.count("auth login") === 1 && !SharedService.busy && SharedService.authenticated, "browser-focused sign-in finishes while panels are closed")
        harness.check(harness.count("workers list") === 1, "sign-in completion does not fetch hidden lists")
        harness.first.opened = true
      }
      if (harness.tick === 58) {
        harness.check(harness.count("auth whoami") > 3, "visible panel resumes remote polling")
        harness.first.destroy()
        harness.second.destroy()
      }
      if (harness.tick === 66) harness.closedCount = harness.calls().length
      if (harness.tick === 74) {
        harness.check(!SharedService.available && !SharedService.panelOpen && !SharedService.busy && !SharedService.loadingResources, "destroying the last consumer stops requests")
        harness.check(harness.calls().length === harness.closedCount, "destroyed consumers leave no idle polling")
        Qt.quit()
      }
    }
  }
}
