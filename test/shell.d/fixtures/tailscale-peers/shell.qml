import QtQuick
import Quickshell
import qs.Commons
import "tailscale" as Tailscale

ShellRoot {
  id: test
  property bool failed: false
  function check(ok, message) {
    if (!ok) { failed = true; console.log("RESULT fail " + message) }
  }
  property string snapshot: JSON.stringify({
    BackendState: "Running",
    Self: { HostName: "old-self", DNSName: "self.tailnet.ts.net.", UserID: 1,
      CapMap: { "https://tailscale.com/cap/file-sharing": null } },
    Peer: {
      online: { HostName: "Old Phone", DNSName: "phone.tailnet.ts.net.", Online: true,
        UserID: 1, TaildropTarget: 1, TailscaleIPs: ["100.64.0.2"] },
      offline: { HostName: "Old Laptop", DNSName: "laptop.tailnet.ts.net.", Online: false,
        UserID: 1, TaildropTarget: 0, ExitNodeOption: true, TailscaleIPs: ["100.64.0.3"] }
    }
  })
  Item {
    Tailscale.Panel {
      id: panel
      settings: ({ refreshIntervalSec: 60, recentMullvadRegions: ["Canada\nToronto"] })
      bar: QtObject {
        property var shell: QtObject {
          property int writes: 0
          function updateEntryInline(id, entry) {
            test.check(id === panel.moduleName && entry.id === id, "setting writes target the active widget")
            test.check(entry.refreshIntervalSec === 60, "toggle preserves refresh interval")
            test.check(entry.recentMullvadRegions[0] === "Canada\nToronto", "toggle preserves recent regions")
            writes++
            panel.settings = entry
          }
        }
        property color foreground: Color.foreground
        property color barForeground: Color.foreground
        property color urgent: Color.urgent
        property string fontFamily: Style.font.family
        property string position: "top"
        property int barSize: 24
        property bool vertical: false
        property bool foregroundAnimationEnabled: false
        property var activePopout: null
        function requestPopout(owner) { activePopout = owner }
        function releasePopout(owner) { activePopout = null }
        function registerClickTarget(target) {}
        function unregisterClickTarget(target) {}
        function hideTooltip(target) {}
        function showTooltip(target, text) {}
      }
    }
  }
  Timer {
    interval: 100
    running: true
    onTriggered: {
      panel.testService.installed = true
      panel.testService.parseStatus(test.snapshot)
      Qt.callLater(defaultChecks)
    }
  }
  function defaultChecks() {
    var service = panel.testService
    check(service.selfName === "self", "registered self name")
    check(service.peers.length === 1 && service.peers[0].DisplayName === "phone", "online-only default")
    check(service.canSendFiles(service.peers[0]), "online Taildrop remains available")
    check(!panel.testOfflineSwitch.checked, "visible switch starts off")
    panel.testOfflineSwitch.toggled()
    Qt.callLater(offlineChecks)
  }
  function offlineChecks() {
    var service = panel.testService
    check(panel.testOfflineSwitch.checked && panel.bar.shell.writes === 1, "switch follows persisted state")
    check(service.peers.length === 2, "setting reveals cached offline peer immediately")
    var peer = service.peers[1]
    check(peer.DisplayName === "laptop" && !peer.Online, "offline registered name and state")
    check(service.tailnetExitNodes.length === 0, "offline exit node excluded")
    check(!service.canSendFiles(peer), "offline legacy Taildrop target rejected")
    check(!service.canSendFiles({ Online: false, UserID: "1", TaildropTarget: 1 }), "offline state overrides available Taildrop grade")
    service.copyPeerName(peer)
    service.copyPeerDnsName(peer)
    service.copyPeerIp(peer)
    service.sendFile(peer)
    panel.focusSection = "peers"
    panel.peerIndex = 0
    panel.moveCursor(0, 1)
    check(panel.peerIndex === 1, "keyboard reaches offline peer")
    panel.testKeys.textKey("O")
    Qt.callLater(hiddenChecks)
  }
  function hiddenChecks() {
    var service = panel.testService
    check(!panel.testOfflineSwitch.checked && panel.bar.shell.writes === 2, "keyboard shortcut persists the same setting")
    check(service.peers.length === 1 && panel.peerIndex === 0, "hiding offline row clamps keyboard cursor")
    panel.settings = { showOfflinePeers: true }
    service.parseStatus(JSON.stringify({ BackendState: "Running", Peer: {
      only: { HostName: "old", DNSName: "sleeping.tailnet.ts.net.", Online: false }
    }}))
    Qt.callLater(offlineOnlyChecks)
  }
  function offlineOnlyChecks() {
    check(panel.testService.peers.length === 1, "offline-only tailnet visible when enabled")
    panel.focusSection = "peers"
    panel.settings = {}
    Qt.callLater(emptyChecks)
  }
  function emptyChecks() {
    check(panel.testService.peers.length === 0, "removing setting restores default")
    check(panel.focusSection === "header", "empty list moves keyboard focus to header")
    panel.settings = { showOfflinePeers: true }
    panel.testService.parseStatus(JSON.stringify({ BackendState: "Stopped", Peer: {
      stale: { Online: true, HostName: "stale" }
    }}))
    Qt.callLater(stoppedChecks)
  }
  function stoppedChecks() {
    check(panel.testService.peers.length === 0, "stopped connection clears peers")
    panel.testService.parseStatus(test.snapshot)
    panel.testService.parseStatus("{")
    Qt.callLater(function() {
      check(panel.testService.peers.length === 0, "parse failure clears cached peers")
      console.log(failed ? "RESULT failed" : "RESULT pass")
      Qt.quit()
    })
  }
}
