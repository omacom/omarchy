import QtQuick
import QtTest
import Quickshell.Io
import DropboxUnderTest

TestCase {
  id: testCase
  name: "DropboxCollection"
  when: windowShown

  Component { id: serviceComponent; DropboxService {} }

  function processFor(mode) {
    for (var i = 0; i < ProcessHarness.processes.length; i++) {
      var process = ProcessHarness.processes[i]
      if (process.command.indexOf(mode) >= 0) return process
    }
    return null
  }

  function status(folder) {
    return JSON.stringify({ ok: true, installed: true, running: false,
      authenticated: true, accountPath: folder || "/Dropbox", statusText: "Stopped",
      quotaBytes: 2000, quotaKnown: true, inventoryLoaded: false })
  }

  function inventory(folder) {
    return JSON.stringify({ ok: true, authenticated: true, inventoryLoaded: true, accountPath: folder || "/Dropbox",
      usedBytes: 100, files: [{ name: "retained.txt" }] })
  }

  function test_inventoryLifetime() {
    var service = createTemporaryObject(serviceComponent, testCase)
    verify(service !== null)
    tryVerify(function() { return processFor("--status-only") !== null })
    var daemon = processFor("--status-only")
    compare(daemon.command[0], "timeout")
    compare(daemon.command[1], "--kill-after=2s")
    compare(daemon.command[2], "8s")
    daemon.complete(0, 0, status())
    compare(service.authenticated, true)
    compare(processFor("--inventory-only"), null)
    service.refresh()
    daemon.complete(0, 0, status())
    compare(processFor("--inventory-only"), null)

    service.inventoryRequested = true
    tryCompare(daemon, "running", true)
    daemon.complete(0, 0, status())
    tryVerify(function() { return processFor("--inventory-only") !== null })
    var scan = processFor("--inventory-only")
    compare(scan.command[0], "timeout")
    compare(scan.command[1], "--kill-after=2s")
    compare(scan.command[2], "15s")
    compare(service.inventoryRefreshing, true)
    service.refresh(false)
    daemon.complete(0, 0, status())
    compare(service.inventoryPending, false)
    scan.complete(0, 0, inventory())
    compare(service.inventoryLoaded, true)
    compare(service.usedBytes, 100)
    compare(service.files[0].name, "retained.txt")

    service.applyInventory(JSON.stringify({ ok: true, authenticated: false,
      inventoryLoaded: true, accountPath: "/Dropbox", usedBytes: 0, files: [] }), "/Dropbox")
    verify(service.inventoryError.length > 0)
    compare(service.usedBytes, 100)
    compare(service.files[0].name, "retained.txt")
    service.applyInventory(JSON.stringify({ ok: true, authenticated: true,
      inventoryLoaded: false, accountPath: "/Dropbox" }), "/Dropbox")
    verify(service.inventoryError.length > 0)
    compare(service.usedBytes, 100)
    compare(service.files[0].name, "retained.txt")
    service.applyInventory(inventory(), "/Dropbox")
    compare(service.inventoryError, "")

    service.inventoryRequested = false
    service.refresh()
    daemon.complete(0, 0, status())
    compare(scan.startCount, 1)
    compare(service.usedBytes, 100)

    service.inventoryRequested = true
    daemon.complete(0, 0, status())
    compare(scan.startCount, 2)
    service.inventoryRequested = false
    compare(scan.signals[0], 15)
    // Reopening before the cancelled process has exited queues one new scan.
    service.inventoryRequested = true
    daemon.complete(0, 0, status())
    scan.complete(143, 0, "")
    compare(scan.startCount, 3)
    compare(service.inventoryError, "")
    scan.complete(124, 0, "")
    verify(service.inventoryError.indexOf("timed out") >= 0)
    compare(service.inventoryLoaded, true)
    compare(service.usedBytes, 100)

    service.refresh()
    daemon.complete(0, 0, status())
    service.refresh(false)
    daemon.complete(0, 0, status("/Other Dropbox"))
    compare(service.inventoryLoaded, false)
    compare(service.files.length, 0)
    scan.complete(0, 0, inventory())
    compare(service.usedBytes, 0)
    compare(scan.accountPath, "/Other Dropbox")
    scan.complete(0, 0, inventory("/Other Dropbox"))
    compare(service.inventoryLoaded, true)
    compare(service.usedBytes, 100)
    service.inventoryRequested = false
  }
}
