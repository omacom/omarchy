import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "omarchy.tailscale"
  ipcTarget: "omarchy.tailscale"
  manageIpc: false

  property string focusSection: "header"
  // Which half of the panel is on screen: the tailnet's machines, or the
  // HTTPS services advertised on it. The bar icon reports both regardless.
  property string activeTab: "machines"
  property int headerIndex: 0
  property int accountIndex: 0
  property int peerIndex: 0
  property int exitNodeIndex: 0
  property int mullvadRegionIndex: 0
  property int serviceIndex: 0
  property bool cursorActive: false
  property bool copyMenuOpen: false
  property bool mullvadPickerOpen: false
  property string mullvadQuery: ""
  property int phraseIndex: 0
  readonly property var activePhrases: [
    "Encrypting connections",
    "Sending secrets",
    "Guarding wires",
    "Braiding packets",
    "Polishing tunnels",
    "Hiding routes",
    "Sealing ports",
    "Sorting tailnets",
    "Shuffling keys",
    "Watching machines"
  ]
  readonly property string heroPhraseText: activePhrases[phraseIndex % activePhrases.length]

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property bool showConnections: machinesTab && (tailscale.accounts.length > 1 || tailscale.accountsAccessDenied)
  readonly property bool showPeers: machinesTab && tailscale.active && tailscale.peers.length > 0
  readonly property var recentMullvadRegions: settings.recentMullvadRegions instanceof Array ? settings.recentMullvadRegions : (settings.recentMullvadCountries instanceof Array ? settings.recentMullvadCountries : [])
  readonly property var recentMullvadExitNodes: recentMullvadNodes()
  readonly property var exitNodes: displayExitNodes()
  readonly property bool showExitNodes: machinesTab && tailscale.active && (exitNodes.length > 0 || tailscale.mullvadRegions.length > 0)
  readonly property var filteredMullvadRegions: filteredMullvadRegionNodes()
  // Only claim the header cursor when the switch is actually on screen —
  // "header" stays navigable, but an absent CLI leaves nothing to highlight.
  readonly property bool headerHasCursor: cursorActive && focusSection === "header" && tailscale.installed
  readonly property color iconColor: tailscale.active ? foreground : dim
  readonly property string toggleHint: tailscale.active ? "Turn Tailscale off" : (tailscale.needsLogin ? "Authorize this device" : "Turn Tailscale on")
  readonly property color barIconColor: tailscale.active ? barForeground : Qt.darker(barForeground, 1.55)
  readonly property color hoverFill: bar ? Style.hoverFillFor(bar.foreground, Color.accent) : "transparent"
  readonly property color selectedFill: bar ? Style.selectedFillFor(bar.foreground, Color.accent) : "transparent"

  // A tailnet that advertises no services has no second tab, and the panel is
  // exactly what it always was. Nothing to turn on, nothing to turn off: the
  // tailnet already answered the question.
  readonly property bool hasServices: tailscale.serviceRows.length > 0
  readonly property bool machinesTab: !hasServices || activeTab === "machines"
  readonly property bool servicesTab: hasServices && activeTab === "services"
  readonly property var tabOptions: [
    { value: "machines", label: "Machines", tooltip: "Machines on this tailnet" },
    { value: "services", label: "Services", tooltip: "HTTPS services on this tailnet" }
  ]
  // Rows arrive from the status poll and their verdicts a probe later, so
  // "unreachable" and "not asked yet" are different states and only the first
  // is worth colouring.
  readonly property int probedServiceCount: {
    var probed = 0
    for (var i = 0; i < tailscale.serviceRows.length; i++) {
      if (tailscale.serviceRows[i].Probed) probed++
    }
    return probed
  }
  readonly property string servicesSummary: {
    if (!tailscale.active) return "Tailscale is disconnected"
    if (!hasServices) return "No HTTPS services advertised"
    if (tailscale.serviceProbeError !== "") return tailscale.serviceProbeError
    if (probedServiceCount === 0) return "Checking services…"
    return tailscale.reachableServiceCount + " of " + tailscale.serviceRows.length + " reachable"
  }
  // Only worth a dot in the bar when it says something the mark does not: that
  // a service the tailnet advertises is not answering. Rows that have not been
  // probed yet are not evidence of anything, so they neither raise the dot nor
  // colour it.
  readonly property bool barServiceDotVisible: tailscale.active
    && probedServiceCount > 0
    && tailscale.reachableServiceCount < probedServiceCount
  // The theme palette has no "success" role, so mix one for the partial case:
  // urgent when nothing answers, and the blend when only some of it does.
  // Staying in the palette keeps the dot legible in every theme, which a
  // hardcoded colour would not.
  readonly property color barServiceStatusColor: tailscale.reachableServiceCount === 0
    ? urgent
    : Qt.tint(barForeground, Qt.rgba(urgent.r, urgent.g, urgent.b, 0.55))
  readonly property string barTooltip: {
    if (!tailscale.installed) return "Tailscale is not installed"
    if (!tailscale.active || tailscale.serviceRows.length === 0) return tailscale.statusText
    return tailscale.statusText + " · " + root.servicesSummary
  }

  function selectedPeer() {
    if (tailscale.peers.length === 0) return null
    return tailscale.peers[Math.max(0, Math.min(peerIndex, tailscale.peers.length - 1))]
  }

  function selectedExitNode() {
    if (exitNodes.length === 0) return null
    return exitNodes[Math.max(0, Math.min(exitNodeIndex, exitNodes.length - 1))]
  }

  function selectedMullvadRegion() {
    if (filteredMullvadRegions.length === 0) return null
    return filteredMullvadRegions[Math.max(0, Math.min(mullvadRegionIndex, filteredMullvadRegions.length - 1))]
  }

  function displayExitNodes() {
    var nodes = []
    for (var i = 0; i < tailscale.tailnetExitNodes.length; i++) nodes.push(tailscale.tailnetExitNodes[i])
    for (var j = 0; j < recentMullvadExitNodes.length; j++) nodes.push(recentMullvadExitNodes[j])
    if (tailscale.mullvadRegions.length > 0) nodes.push({ id: "mullvad:add", AddMullvad: true, DisplayName: "Choose Mullvad region" })
    return nodes
  }

  function recentMullvadNodes() {
    var nodes = []
    var seen = {}
    for (var a = 0; a < tailscale.mullvadRegions.length && nodes.length < 5; a++) {
      var active = tailscale.mullvadRegions[a]
      var activeKey = mullvadRegionKey(active)
      if (active.ExitNode === true && activeKey !== "" && !seen[activeKey]) {
        nodes.push(active)
        seen[activeKey] = true
      }
    }
    for (var i = 0; i < recentMullvadRegions.length && nodes.length < 5; i++) {
      var region = String(recentMullvadRegions[i] || "")
      if (region === "" || seen[region]) continue
      var node = mullvadRegionNode(region)
      if (node) {
        nodes.push(node)
        seen[region] = true
      }
    }
    return nodes
  }

  function mullvadRegionKey(node) {
    if (!node) return ""
    var country = String(node.Country || "")
    var city = String(node.City || "")
    if (country === "" || city === "") return ""
    return country + "\n" + city
  }

  function mullvadRegionNode(region) {
    for (var i = 0; i < tailscale.mullvadRegions.length; i++) {
      var node = tailscale.mullvadRegions[i]
      if (mullvadRegionKey(node) === String(region || "")) return node
      if (String(node.Country || "") === String(region || "")) return node
    }
    return null
  }

  function filteredMullvadRegionNodes() {
    var query = String(mullvadQuery || "").trim().toLowerCase()
    var result = []
    for (var i = 0; i < tailscale.mullvadRegions.length; i++) {
      var node = tailscale.mullvadRegions[i]
      var label = (String(node.City || "") + " " + String(node.Country || "")).toLowerCase()
      if (query === "" || label.indexOf(query) !== -1) result.push(node)
    }
    return result
  }

  function mullvadRegionTitle(peer) {
    if (!peer) return "Unknown"
    var city = String(peer.City || "").trim()
    var country = String(peer.Country || "").trim()
    if (city === "" || city === "Any") return country || String(peer.DisplayName || "Unknown")
    return city
  }

  function mullvadRegionSubtitle(peer) {
    if (!peer) return ""
    return String(peer.Country || "").trim()
  }

  function persistRecentMullvad(region) {
    var name = String(region || "")
    if (name === "") return
    var next = [name]
    for (var i = 0; i < recentMullvadRegions.length && next.length < 5; i++) {
      var existing = String(recentMullvadRegions[i] || "")
      if (existing !== "" && existing !== name && next.indexOf(existing) === -1) next.push(existing)
    }
    if (!root.bar || !root.bar.shell || typeof root.bar.shell.updateEntryInline !== "function") return
    var entry = { id: root.moduleName }
    for (var key in settings) if (key !== "id") entry[key] = settings[key]
    entry.recentMullvadRegions = next
    root.bar.shell.updateEntryInline(root.moduleName, entry)
  }

  function chooseExitNode(peer) {
    if (!peer) return
    if (peer.AddMullvad === true) {
      mullvadPickerOpen = !mullvadPickerOpen
      mullvadRegionIndex = 0
      if (mullvadPickerOpen) Qt.callLater(function() { if (mullvadSearch) mullvadSearch.forceActiveFocus() })
      return
    }
    if (peer.Mullvad === true) persistRecentMullvad(mullvadRegionKey(peer))
    tailscale.setExitNode(peer)
    mullvadPickerOpen = false
  }

  function selectedAccount() {
    if (tailscale.accounts.length === 0) return null
    return tailscale.accounts[Math.max(0, Math.min(accountIndex, tailscale.accounts.length - 1))]
  }

  function selectedService() {
    if (tailscale.serviceRows.length === 0) return null
    return tailscale.serviceRows[Math.max(0, Math.min(serviceIndex, tailscale.serviceRows.length - 1))]
  }

  function setTab(name) {
    if (!hasServices) return
    var next = name === "services" ? "services" : "machines"
    if (activeTab === next) return
    activeTab = next
    // Land on the hero rather than wherever the other tab's cursor sat: the
    // sections do not line up, so keeping the row index would look random.
    focusSection = "header"
    if (next === "services") {
      serviceIndex = 0
      // The rows may be a poll old; arriving on the tab is a good moment to
      // ask again, and a probe is cheap.
      tailscale.probeServices()
    }
    if (panelFlick) panelFlick.contentY = 0
    ensureCursor()
  }

  function openService(service) {
    if (!service || !service.Url) return
    tailscale.openUrl(service.Url)
    close()
  }

  function openServicesAdmin() {
    tailscale.openServicesAdmin()
    close()
  }

  function setServiceCursor(index) {
    cursorActive = true
    focusSection = "services"
    serviceIndex = index
    scrollCursorIntoView()
  }

  function copySelectedServiceUrl() {
    var service = selectedService()
    if (!service || !service.Url) return
    tailscale.copyToClipboard(String(service.Url), String(service.Name || "Service") + " URL")
  }

  function ensureCursor() {
    if (headerIndex < 0) headerIndex = 0
    if (headerIndex > 0) headerIndex = 0
    if (accountIndex >= tailscale.accounts.length) accountIndex = Math.max(0, tailscale.accounts.length - 1)
    if (peerIndex >= tailscale.peers.length) peerIndex = Math.max(0, tailscale.peers.length - 1)
    if (exitNodeIndex >= exitNodes.length) exitNodeIndex = Math.max(0, exitNodes.length - 1)
    if (mullvadRegionIndex >= filteredMullvadRegions.length) mullvadRegionIndex = Math.max(0, filteredMullvadRegions.length - 1)
    if (serviceIndex >= tailscale.serviceRows.length) serviceIndex = Math.max(0, tailscale.serviceRows.length - 1)
    // The services tab is one flat list, so it has no section chain to repair:
    // the cursor is either on the hero or in the list.
    if (servicesTab) {
      if (focusSection !== "header" && focusSection !== "services") focusSection = "header"
      if (focusSection === "services" && !hasServices) focusSection = "header"
      return
    }
    if (focusSection === "services") focusSection = "header"
    if (focusSection === "auth" && !tailscale.accountsAccessDenied) focusSection = tailscale.accounts.length > 1 ? "accounts" : (showExitNodes ? "exitNodes" : (showPeers ? "peers" : "header"))
    if (focusSection === "accounts" && tailscale.accounts.length <= 1) focusSection = tailscale.accountsAccessDenied ? "auth" : (showExitNodes ? "exitNodes" : (showPeers ? "peers" : "header"))
    if (focusSection === "peers" && !showPeers) focusSection = showExitNodes ? "exitNodes" : (tailscale.accountsAccessDenied ? "auth" : (tailscale.accounts.length > 1 ? "accounts" : "header"))
    if (focusSection === "exitNodes" && !showExitNodes) focusSection = showPeers ? "peers" : (tailscale.accountsAccessDenied ? "auth" : (tailscale.accounts.length > 1 ? "accounts" : "header"))
  }

  function moveCursor(dx, dy) {
    // Left/right belongs to the tabs: neither list is horizontal, so the axis
    // is free and h/l lands where a Vim user reaches for it anyway. Switching
    // is not cursor movement, so it neither needs the priming keypress the
    // vertical keys take nor lights up a row.
    if (dx !== 0) {
      setTab(dx > 0 ? "services" : "machines")
      return
    }
    cursorActive = true
    ensureCursor()
    if (dy !== 0) {
      if (servicesTab) {
        if (focusSection === "header") {
          if (dy > 0 && hasServices) focusSection = "services"
        } else if (dy < 0) {
          if (serviceIndex <= 0) focusSection = "header"
          else serviceIndex--
        } else if (serviceIndex < tailscale.serviceRows.length - 1) {
          serviceIndex++
        }
      } else if (focusSection === "header") {
        if (dy > 0) {
          if (tailscale.accountsAccessDenied) focusSection = "auth"
          else if (tailscale.accounts.length > 1) focusSection = "accounts"
          else if (showExitNodes) focusSection = "exitNodes"
          else if (showPeers) focusSection = "peers"
        }
      } else if (focusSection === "auth") {
        if (dy < 0) focusSection = "header"
        else if (tailscale.accounts.length > 1) focusSection = "accounts"
        else if (showExitNodes) focusSection = "exitNodes"
        else if (showPeers) focusSection = "peers"
      } else if (focusSection === "accounts") {
        if (dy < 0) {
          if (accountIndex <= 0) focusSection = tailscale.accountsAccessDenied ? "auth" : "header"
          else accountIndex--
        } else {
          if (accountIndex < tailscale.accounts.length - 1) accountIndex++
          else if (showExitNodes) focusSection = "exitNodes"
          else if (showPeers) focusSection = "peers"
        }
      } else if (focusSection === "peers") {
        if (dy < 0) {
          if (peerIndex <= 0) focusSection = showExitNodes ? "exitNodes" : (tailscale.accounts.length > 1 ? "accounts" : (tailscale.accountsAccessDenied ? "auth" : "header"))
          else peerIndex--
        } else if (peerIndex < tailscale.peers.length - 1) {
          peerIndex++
        }
      } else if (focusSection === "exitNodes") {
        if (dy < 0) {
          if (exitNodeIndex <= 0) focusSection = tailscale.accounts.length > 1 ? "accounts" : (tailscale.accountsAccessDenied ? "auth" : "header")
          else exitNodeIndex--
        } else if (exitNodeIndex < exitNodes.length - 1) {
          exitNodeIndex++
        } else if (showPeers) {
          focusSection = "peers"
        }
      }
    }
    ensureCursor()
    scrollCursorIntoView()
  }

  function activateCursor() {
    ensureCursor()
    if (focusSection === "header") {
      tailscale.toggleTailscale()
    } else if (focusSection === "auth") {
      tailscale.authorizeTailscaleOperator()
    } else if (focusSection === "accounts") {
      var account = selectedAccount()
      if (account) tailscale.switchAccount(account.id)
    } else if (focusSection === "peers") {
      openSelectedPeerCopyMenu()
    } else if (focusSection === "exitNodes") {
      chooseExitNode(selectedExitNode())
    } else if (focusSection === "services") {
      openService(selectedService())
    }
  }

  function moveMullvadRegionCursor(delta) {
    if (filteredMullvadRegions.length === 0) return
    cursorActive = true
    mullvadRegionIndex = Math.max(0, Math.min(filteredMullvadRegions.length - 1, mullvadRegionIndex + delta))
    scrollMullvadRegionCursorIntoView()
  }

  function activateMullvadRegionCursor() {
    var region = selectedMullvadRegion()
    if (region) chooseExitNode(region)
  }

  function scrollItemIntoView(item) {
    if (!panelFlick || !item) return
    Qt.callLater(function() {
      if (!item) return
      var margin = Style.space(6)
      var point = item.mapToItem(panelFlick.contentItem, 0, 0)
      var top = point.y
      var bottom = top + item.height
      var viewTop = panelFlick.contentY
      var viewBottom = viewTop + panelFlick.height
      var maxY = Math.max(0, panelFlick.contentHeight - panelFlick.height)
      if (top < viewTop + margin) panelFlick.contentY = Math.max(0, top - margin)
      else if (bottom > viewBottom - margin) panelFlick.contentY = Math.min(maxY, bottom + margin - panelFlick.height)
    })
  }

  function scrollCursorIntoView() {
    if (focusSection === "peers" && peerColumn && peerIndex >= 0 && peerIndex < peerColumn.children.length) scrollItemIntoView(peerColumn.children[peerIndex])
    else if (focusSection === "exitNodes" && exitNodeColumn && exitNodeIndex >= 0 && exitNodeIndex < exitNodeColumn.children.length) scrollItemIntoView(exitNodeColumn.children[exitNodeIndex])
    else if (focusSection === "services" && serviceColumn && serviceIndex >= 0 && serviceIndex < serviceColumn.children.length) scrollItemIntoView(serviceColumn.children[serviceIndex])
  }

  function scrollMullvadRegionCursorIntoView() {
    if (mullvadRegionColumn && mullvadRegionIndex >= 0 && mullvadRegionIndex < mullvadRegionColumn.children.length) scrollItemIntoView(mullvadRegionColumn.children[mullvadRegionIndex])
  }

  function setPeerCursor(index) {
    cursorActive = true
    focusSection = "peers"
    peerIndex = index
    scrollCursorIntoView()
  }

  // The file picker takes over from here, so get the panel out of the way.
  function sendPeerFile(peer) {
    if (!tailscale.canSendFiles(peer)) return
    tailscale.sendFile(peer)
    close()
  }

  function openSelectedPeerCopyMenu() {
    if (!peerColumn || peerIndex < 0 || peerIndex >= peerColumn.children.length) return
    var item = peerColumn.children[peerIndex]
    if (item && item.openCopyMenu) item.openCopyMenu()
  }

  function setExitNodeCursor(index) {
    cursorActive = true
    focusSection = "exitNodes"
    exitNodeIndex = index
    scrollCursorIntoView()
  }

  function setAccountCursor(index) {
    cursorActive = true
    focusSection = "accounts"
    accountIndex = index
  }

  function setAuthCursor() {
    cursorActive = true
    focusSection = "auth"
  }

  function setHeaderCursor() {
    cursorActive = true
    focusSection = "header"
    headerIndex = 0
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onOpenedChanged: if (opened) {
    cursorActive = false
    // Settle the remembered tab on open rather than the moment services come
    // and go: a status blip that empties the list for one poll should not cost
    // the tab you were on, and `servicesTab` already falls back on its own.
    if (!hasServices) activeTab = "machines"
    if (panelFlick) panelFlick.contentY = 0
    // The status refresh carries the service probe with it, now that the panel
    // being open makes probing worth the traffic.
    tailscale.refresh()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }
  onPeerIndexChanged: scrollCursorIntoView()
  onExitNodeIndexChanged: scrollCursorIntoView()
  onServiceIndexChanged: scrollCursorIntoView()
  onMullvadRegionIndexChanged: if (mullvadPickerOpen) scrollMullvadRegionCursorIntoView()
  onShowConnectionsChanged: ensureCursor()
  onShowPeersChanged: ensureCursor()
  onShowExitNodesChanged: ensureCursor()
  onHasServicesChanged: ensureCursor()
  onFilteredMullvadRegionsChanged: ensureCursor()

  Service {
    id: tailscale
    settings: root.settings
    panelOpen: root.opened
  }

  Connections {
    target: tailscale
    function onPeersChanged() { root.ensureCursor() }
    function onAccountsChanged() { root.ensureCursor() }
    function onAccountsAccessDeniedChanged() { root.ensureCursor() }
    function onServiceRowsChanged() { root.ensureCursor() }
  }

  IpcHandler {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): string { tailscale.refresh(); return "ok" }
    function up(): string { tailscale.loginOrUp(); return "ok" }
    function down(): string { tailscale.down(); return "ok" }
    function toggleTailscale(): string { tailscale.toggleTailscale(); return "ok" }
    function status(): string { return tailscale.statusText }
    function services(): string { return root.servicesSummary }
    function refreshServices(): string { tailscale.probeServices(); return "ok" }
    function tab(name: string): string { root.setTab(name); return root.activeTab }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    tooltipText: root.barTooltip
    iconComponent: Component {
      Item {
        TailscaleIcon {
          anchors.centerIn: parent
          iconSize: Style.space(11)
          color: root.barIconColor
          badgeColor: root.urgent
          crossed: !tailscale.active && !tailscale.needsLogin
          warning: tailscale.needsLogin
          statusColor: root.barServiceStatusColor
          statusVisible: root.barServiceDotVisible
        }
      }
    }
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) tailscale.toggleTailscale()
      else if (buttonCode === Qt.MiddleButton) { tailscale.refresh(); tailscale.probeServices() }
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(column.implicitHeight, Style.space(560))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: root.copyMenuOpen
      onMoveRequested: function(dx, dy) {
        // Vertical keys keep the stock behaviour: the first press only lights
        // the cursor. Horizontal keys switch tab straight away.
        if (dx === 0 && !root.cursorActive) { root.cursorActive = true; return }
        root.moveCursor(dx, dy)
      }
      onActivateRequested: if (root.cursorActive) root.activateCursor()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (t === "t" || t === "T") tailscale.toggleTailscale()
        else if (t === "r" || t === "R") { tailscale.refresh(true); tailscale.probeServices() }
        // The copy keys follow the visible tab: on services there is one thing
        // worth copying, and no peer under the cursor to copy from.
        else if (root.servicesTab) {
          if (t === "c" || t === "C") root.copySelectedServiceUrl()
        }
        else if (t === "c" || t === "C") tailscale.copyPeerIp(root.selectedPeer())
        else if (t === "n" || t === "N") tailscale.copyPeerName(root.selectedPeer())
        else if (t === "d" || t === "D") tailscale.copyPeerDnsName(root.selectedPeer())
        else if (t === "s" || t === "S") root.sendPeerFile(root.selectedPeer())
      }

      Flickable {
        id: panelFlick
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        interactive: contentHeight > height
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Column {
          id: column
          width: panelFlick.width
          spacing: Style.space(12)

          Item {
            id: header
            width: parent.width
            implicitHeight: hero.implicitHeight
            // Exposed for the hero's trailingControl, whose `root` resolves to
            // PanelHero (not this Panel) — reach panel state via `header`.
            readonly property bool ringVisible: root.headerHasCursor
            function focusHero() { root.setHeaderCursor() }

            PanelHero {
              id: hero
              width: parent.width
              title: tailscale.installed ? (tailscale.selfName || "Tailscale") : "Tailscale"
              // The rotating phrases are flavour for the machines tab; on the
              // services tab the same line carries the reachability count.
              meta: !tailscale.active ? "Tailscale is disconnected"
                : (root.servicesTab ? root.servicesSummary : root.heroPhraseText)
              foreground: root.foreground
              fontFamily: root.fontFamily
              iconOpacity: tailscale.active ? 1.0 : 0.5
              // Status only — the switch owns toggling, mouse and keyboard alike.
              iconComponent: Component {
                TailscaleIcon {
                  iconSize: Style.font.display
                  color: root.iconColor
                  badgeColor: root.urgent
                  crossed: !tailscale.active && !tailscale.needsLogin
                  warning: tailscale.needsLogin
                }
              }

              // Compact on/off switch on the trailing edge of the hero, and the
              // header's only cursor target. The service already flips `active`
              // optimistically, so the knob throws the instant you click it.
              trailingControl: Component {
                ToggleSwitch {
                  id: powerSwitch
                  visible: tailscale.installed
                  checked: tailscale.active
                  busy: tailscale.busy
                  hasCursor: header.ringVisible
                  foreground: hero.foreground
                  onHovered: function(on) { if (on) header.focusHero() }
                  onToggled: tailscale.toggleTailscale()

                  PanelToolTip {
                    visible: powerSwitch.containsMouse
                    text: root.toggleHint
                    fontFamily: hero.fontFamily
                  }
                }
              }
            }
          }

          // Machines / Services. Centred rather than left-aligned so the two
          // chips read as one control instead of a stray pair of buttons.
          Item {
            visible: tailscale.installed && root.hasServices
            width: parent.width
            implicitHeight: tabs.implicitHeight

            ButtonGroup {
              id: tabs
              anchors.horizontalCenter: parent.horizontalCenter
              options: root.tabOptions
              value: root.activeTab
              foreground: root.foreground
              background: root.bar ? Color.bar.background : Color.background
              fontFamily: root.fontFamily
              fontSize: Style.font.bodySmall
              // The panel owns Tab (it switches bar panels), so the group must
              // not claim it as a focus stop.
              focusable: false
              onChanged: function(tab) { root.setTab(tab) }
            }
          }

          Text {
            textFormat: Text.PlainText
            visible: tailscale.actionStatus !== "" || tailscale.lastError !== ""
            width: parent.width
            text: tailscale.actionStatus !== "" ? tailscale.actionStatus : tailscale.lastError
            color: tailscale.lastError !== "" && tailscale.actionStatus === "" ? root.urgent : root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
            wrapMode: Text.WordWrap
          }

          CursorSurface {
            visible: !tailscale.installed
            width: parent.width
            implicitHeight: missingText.implicitHeight + Style.spacing.rowPaddingX
            foreground: root.foreground

            Text {
              id: missingText
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              anchors.margins: Style.space(12)
              text: "Tailscale CLI is not installed or not on PATH."
              color: root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.body
              wrapMode: Text.WordWrap
            }
          }

          PanelSeparator {
            visible: root.showConnections
            foreground: root.foreground
          }

          Column {
            visible: root.showConnections
            width: parent.width
            spacing: Style.space(10)

            PanelSectionHeader {
              text: "CONNECTIONS"
              foreground: root.foreground
              fontFamily: root.fontFamily
            }

            AuthRow {
              visible: tailscale.accountsAccessDenied
              width: parent.width
            }

            Repeater {
              model: tailscale.accounts
              AccountRow {
                required property var modelData
                required property int index
                width: parent.width
                account: modelData
                rowIndex: index
              }
            }
          }

          PanelSeparator {
            visible: root.showExitNodes
            foreground: root.foreground
          }

          Column {
            visible: root.showExitNodes
            width: parent.width
            spacing: Style.space(10)

            PanelSectionHeader {
              text: "EXIT NODES"
              foreground: root.foreground
              fontFamily: root.fontFamily
            }

            Column {
              id: exitNodeColumn
              width: parent.width
              spacing: Style.space(6)

              Repeater {
                model: root.exitNodes
                ExitNodeRow {
                  required property var modelData
                  required property int index
                  width: exitNodeColumn.width
                  peer: modelData
                  rowIndex: index
                }
              }

              Column {
                visible: root.mullvadPickerOpen
                width: parent.width
                spacing: Style.space(6)

                TextField {
                  id: mullvadSearch
                  width: parent.width
                  foreground: root.foreground
                  placeholderText: "Search regions"
                  text: root.mullvadQuery
                  onTextChanged: {
                    root.mullvadQuery = text
                    root.mullvadRegionIndex = 0
                  }
                  onAccepted: {
                    root.activateMullvadRegionCursor()
                  }
                  Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Down || event.text === "j") {
                      root.moveMullvadRegionCursor(1)
                      event.accepted = true
                      return
                    }
                    if (event.key === Qt.Key_Up || event.text === "k") {
                      root.moveMullvadRegionCursor(-1)
                      event.accepted = true
                      return
                    }
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                      root.activateMullvadRegionCursor()
                      event.accepted = true
                      return
                    }
                    if (event.key === Qt.Key_Escape) {
                      root.mullvadPickerOpen = false
                      keyCatcher.forceActiveFocus()
                      event.accepted = true
                    }
                  }
                }

                Text {
                  visible: root.filteredMullvadRegions.length === 0
                  width: parent.width
                  text: "No Mullvad regions found."
                  color: root.dim
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.bodySmall
                  horizontalAlignment: Text.AlignHCenter
                }

                Column {
                  id: mullvadRegionColumn
                  width: parent.width
                  spacing: Style.space(6)

                  Repeater {
                    model: root.filteredMullvadRegions
                    MullvadRegionRow {
                      required property var modelData
                      required property int index
                      width: parent.width
                      peer: modelData
                      rowIndex: index
                    }
                  }
                }
              }
            }
          }

          PanelSeparator {
            visible: root.machinesTab && tailscale.installed && tailscale.active
            foreground: root.foreground
          }

          Column {
            visible: root.machinesTab && tailscale.installed && tailscale.active
            width: parent.width
            spacing: Style.space(10)

            PanelSectionHeader {
              text: "MACHINES"
              foreground: root.foreground
              fontFamily: root.fontFamily
            }

            Text {
              visible: tailscale.installed && tailscale.active && tailscale.peers.length === 0
              width: parent.width
              text: "No machines found on this tailnet."
              color: root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.body
              horizontalAlignment: Text.AlignHCenter
            }

            Column {
              id: peerColumn
              visible: root.showPeers
              width: parent.width
              spacing: Style.space(6)

              Repeater {
                model: tailscale.peers
                PeerRow {
                  required property var modelData
                  required property int index
                  width: peerColumn.width
                  peer: modelData
                  rowIndex: index
                }
              }
            }
          }

          PanelSeparator {
            visible: root.servicesTab && tailscale.installed
            foreground: root.foreground
          }

          Column {
            visible: root.servicesTab && tailscale.installed
            width: parent.width
            spacing: Style.space(10)

            Item {
              width: parent.width
              implicitHeight: Math.max(servicesHeader.implicitHeight, servicesActions.implicitHeight)

              PanelSectionHeader {
                id: servicesHeader
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "SERVICES"
                foreground: root.foreground
                fontFamily: root.fontFamily
              }

              Row {
                id: servicesActions
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Style.space(4)

                Button {
                  text: "Admin"
                  iconText: "󰏌"
                  tooltipText: "Open the Tailscale admin console"
                  foreground: root.foreground
                  fontFamily: root.fontFamily
                  fontSize: Style.font.bodySmall
                  horizontalPadding: Style.space(6)
                  onClicked: root.openServicesAdmin()
                }

                // Button rather than PanelActionButton: only Button can spin
                // its glyph, and a probe that takes a moment should show it.
                Button {
                  iconText: "󰑐"
                  tooltipText: "Refresh service status"
                  foreground: root.foreground
                  fontFamily: root.fontFamily
                  fontSize: Style.font.bodySmall
                  horizontalPadding: Style.space(6)
                  iconSpinning: tailscale.probingServices
                  onClicked: tailscale.probeServices()
                }
              }
            }

            // The tab only exists while the tailnet advertises services, so
            // "none" and "Tailscale is off" are not states this section can be
            // in. A probe that could not run is, and it is worth saying.
            Text {
              textFormat: Text.PlainText
              visible: tailscale.serviceProbeError !== ""
              width: parent.width
              text: tailscale.serviceProbeError
              color: root.urgent
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
              wrapMode: Text.WordWrap
            }

            Column {
              id: serviceColumn
              width: parent.width
              spacing: Style.space(6)

              Repeater {
                model: tailscale.serviceRows
                ServiceRow {
                  required property var modelData
                  required property int index
                  width: serviceColumn.width
                  service: modelData
                  rowIndex: index
                }
              }
            }
          }
        }
      }
    }
  }

  Timer {
    id: phraseTimer
    interval: 2800
    running: root.opened && tailscale.active && root.machinesTab
    repeat: true
    onTriggered: phraseSwap.restart()
  }

  SequentialAnimation {
    id: phraseSwap
    PropertyAnimation {
      target: hero; property: "metaOpacity"
      to: 0.0; duration: 180; easing.type: Easing.OutQuad
    }
    ScriptAction {
      script: root.phraseIndex = (root.phraseIndex + 1) % root.activePhrases.length
    }
    PropertyAnimation {
      target: hero; property: "metaOpacity"
      to: 1.0; duration: 260; easing.type: Easing.InQuad
    }
  }

  component AuthRow: CursorSurface {
    id: authRow

    hasCursor: root.cursorActive && root.focusSection === "auth"
    foreground: root.foreground

    implicitHeight: row.implicitHeight + Style.spacing.rowPaddingX

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: tailscale.busy ? Qt.ArrowCursor : Qt.PointingHandCursor
      enabled: !tailscale.busy
      onEntered: root.setAuthCursor()
      onClicked: tailscale.authorizeTailscaleOperator()
    }

    RowLayout {
      id: row
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(10)
      spacing: Style.space(8)

      Text {
        text: "󰒃"
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.heading
        Layout.alignment: Qt.AlignVCenter
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.space(1)

        Text {
          Layout.fillWidth: true
          text: "Authorize Tailscale operator"
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          elide: Text.ElideRight
        }

        Text {
          Layout.fillWidth: true
          text: "Allow this user to operate this Tailscale profile"
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
        }
      }

    }
  }

  component AccountRow: CursorSurface {
    id: accountRow
    property var account: null
    property int rowIndex: 0
    readonly property bool selectedAccount: account && account.selected === true
    readonly property bool switchingAccount: account && tailscale.switchingAccountId === String(account.id || "")
    readonly property string accountText: account ? tailscale.accountLabel(account) : "Account"

    hasCursor: root.cursorActive && root.focusSection === "accounts" && root.accountIndex === rowIndex
    current: selectedAccount
    foreground: root.foreground
    fill: root.hoverFill
    currentFill: root.selectedFill

    implicitHeight: accountInner.implicitHeight + Style.spacing.xl

    Row {
      id: accountInner
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(6)
      anchors.rightMargin: Style.space(6)
      spacing: Style.space(8)

      Text {
        id: accountGlyph
        text: ""
        color: accountRow.selectedAccount || accountRow.switchingAccount ? root.foreground : root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        width: Style.space(22)
        horizontalAlignment: Text.AlignHCenter
        anchors.verticalCenter: parent.verticalCenter
        opacity: accountRow.switchingAccount ? 0.45 : 1.0

        SequentialAnimation on opacity {
          running: accountRow.switchingAccount
          NumberAnimation { to: 1.0; duration: 420; easing.type: Easing.InOutQuad }
          NumberAnimation { to: 0.45; duration: 420; easing.type: Easing.InOutQuad }
          loops: Animation.Infinite
        }
      }

      Text {
        textFormat: Text.PlainText
        text: accountRow.accountText
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        font.bold: accountRow.selectedAccount
        elide: Text.ElideRight
        width: parent.width - Style.space(22) - Style.space(8)
        anchors.verticalCenter: parent.verticalCenter
      }
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: root.setAccountCursor(accountRow.rowIndex)
      onClicked: if (accountRow.account) tailscale.switchAccount(accountRow.account.id)
    }
  }

  component PeerRow: CursorSurface {
    id: peerRow
    property var peer: null
    property int rowIndex: 0
    readonly property string peerName: peer ? String(peer.DisplayName || peer.HostName || "Unknown") : "Unknown"
    readonly property string peerIp: peer && peer.TailscaleIPs && peer.TailscaleIPs.length > 0 ? String(peer.TailscaleIPs[0]) : ""
    readonly property string peerIpv6: {
      if (!peer || !peer.TailscaleIPv6 || peer.TailscaleIPv6.length === 0) return ""
      return String(peer.TailscaleIPv6[0] || "")
    }
    readonly property string peerDns: peer ? String(peer.DNSName || "") : ""
    readonly property var copyOptions: {
      var options = []
      if (peerName !== "") options.push({ kind: "name", label: peerName })
      if (peerDns !== "") options.push({ kind: "dns", label: peerDns })
      if (peerIpv6 !== "") options.push({ kind: "ipv6", label: peerIpv6 })
      if (peerIp !== "") options.push({ kind: "ip", label: peerIp })
      return options
    }
    property int copyIndex: 0

    hasCursor: root.cursorActive && root.focusSection === "peers" && root.peerIndex === rowIndex
    foreground: root.foreground

    implicitHeight: Math.max(peerContent.implicitHeight, copyButton.implicitHeight) + Style.spacing.rowPaddingX

    function clampCopyIndex() {
      copyIndex = Math.max(0, Math.min(copyIndex, copyOptions.length - 1))
    }

    function openCopyMenu() {
      if (copyOptions.length === 0) return
      clampCopyIndex()
      copyPopup.open()
    }

    function moveCopyCursor(delta) {
      if (copyOptions.length === 0) return
      copyIndex = Math.max(0, Math.min(copyOptions.length - 1, copyIndex + delta))
    }

    function copyOption(kind) {
      if (kind === "name") tailscale.copyPeerName(peer)
      else if (kind === "dns") tailscale.copyPeerDnsName(peer)
      else if (kind === "ipv6") tailscale.copyToClipboard(peerIpv6, peerName + " IPv6")
      else if (kind === "ip") tailscale.copyPeerIp(peer)
      copyPopup.close()
    }

    function copyCurrentOption() {
      clampCopyIndex()
      if (copyOptions.length === 0) return
      copyOption(copyOptions[copyIndex].kind)
    }

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton
      hoverEnabled: true
      cursorShape: Qt.ArrowCursor
      onContainsMouseChanged: if (containsMouse) root.setPeerCursor(peerRow.rowIndex)
    }

    RowLayout {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(8)
      spacing: Style.space(8)

      Text {
        textFormat: Text.PlainText
        text: tailscale.osIcon(peer ? peer.OS : "")
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.icon
        Layout.alignment: Qt.AlignVCenter
      }

      ColumnLayout {
        id: peerContent
        Layout.fillWidth: true
        spacing: Style.space(1)

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: peerRow.peerName
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          elide: Text.ElideRight
        }

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: {
            var parts = []
            if (peerRow.peerIp !== "") parts.push(peerRow.peerIp)
            if (peerRow.peerDns !== "") parts.push(peerRow.peerDns)
            return parts.join(" · ")
          }
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
        }
      }

      PanelActionButton {
        id: sendButton
        visible: tailscale.canSendFiles(peerRow.peer)
        iconText: "󰒊"
        tooltipText: "Send files"
        foreground: root.foreground
        fontFamily: root.fontFamily
        Layout.alignment: Qt.AlignVCenter
        onClicked: root.sendPeerFile(peerRow.peer)
      }

      PanelActionButton {
        id: copyButton
        iconText: "󰆏"
        foreground: root.foreground
        fontFamily: root.fontFamily
        enabled: peerRow.peerIp !== "" || peerRow.peerName !== "" || peerRow.peerDns !== "" || peerRow.peerIpv6 !== ""
        Layout.alignment: Qt.AlignVCenter
        onClicked: peerRow.openCopyMenu()
      }

      Popup {
        id: copyPopup
        x: copyButton.x + copyButton.width - width
        y: copyButton.y + copyButton.height + Style.space(4)
        width: Style.space(280)
        padding: 0
        modal: false
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        function handleKey(event) {
          if (event.key === Qt.Key_Escape) {
            close()
            event.accepted = true
            return
          }
          if (event.key === Qt.Key_Down || event.text === "j") {
            peerRow.moveCopyCursor(1)
            event.accepted = true
            return
          }
          if (event.key === Qt.Key_Up || event.text === "k") {
            peerRow.moveCopyCursor(-1)
            event.accepted = true
            return
          }
          if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            peerRow.copyCurrentOption()
            event.accepted = true
          }
        }
        onOpenedChanged: {
          root.copyMenuOpen = opened
          if (opened) {
            peerRow.clampCopyIndex()
            Qt.callLater(function() { copyPopupContent.forceActiveFocus() })
          } else if (root.opened) {
            Qt.callLater(function() { keyCatcher.forceActiveFocus() })
          }
        }
        background: BorderSurface {
          color: Color.background
          borderSpec: Border.flat(root.dim, 1)
          radius: Style.cornerRadius
        }

        contentItem: Column {
          id: copyPopupContent
          width: parent.width
          focus: true
          Keys.priority: Keys.BeforeItem
          Keys.onPressed: function(event) { copyPopup.handleKey(event) }

          Repeater {
            model: peerRow.copyOptions
            CopyChoice {
              required property var modelData
              required property int index
              width: parent.width
              label: String(modelData.label || "")
              selected: peerRow.copyIndex === index
              onHovered: peerRow.copyIndex = index
              onChosen: peerRow.copyOption(String(modelData.kind || ""))
            }
          }
        }
      }
    }
  }

  component CopyChoice: CursorSurface {
    id: copyChoice
    signal chosen()
    signal hovered()
    property string label: ""
    property bool selected: false

    visible: enabled
    foreground: root.foreground
    hasCursor: selected
    implicitHeight: Style.space(48)
    radius: 0

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: copyChoice.hovered()
      onClicked: copyChoice.chosen()
    }

    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: Style.space(12)
      anchors.rightMargin: Style.space(12)
      spacing: Style.space(10)

      Text {
        textFormat: Text.PlainText
        Layout.fillWidth: true
        text: copyChoice.label
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        elide: Text.ElideRight
      }

      Text {
        text: "󰆏"
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.icon
        Layout.alignment: Qt.AlignVCenter
      }
    }
  }

  component ExitNodeRow: CursorSurface {
    id: exitNodeRow
    property var peer: null
    property int rowIndex: 0
    readonly property bool addMullvad: peer && peer.AddMullvad === true
    readonly property bool activeExitNode: peer && peer.ExitNode === true
    readonly property bool settingExitNode: peer && tailscale.settingExitNodeId === String(peer.id || "")
    readonly property string peerName: peer ? String(peer.DisplayName || peer.HostName || "Unknown") : "Unknown"
    readonly property string actionTooltip: addMullvad ? "" : (activeExitNode ? "Disconnect" : "Connect")

    hasCursor: root.cursorActive && root.focusSection === "exitNodes" && root.exitNodeIndex === rowIndex
    current: activeExitNode || settingExitNode || (addMullvad && root.mullvadPickerOpen)
    foreground: root.foreground
    fill: root.hoverFill
    currentFill: root.selectedFill

    implicitHeight: exitNodeInner.implicitHeight + Style.spacing.xl

    Row {
      id: exitNodeInner
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(6)
      anchors.rightMargin: Style.space(6)
      spacing: Style.space(8)

      Text {
        id: exitNodeGlyph
        textFormat: Text.PlainText
        text: exitNodeRow.addMullvad ? "+" : (peer && peer.Mullvad === true ? "󰖂" : "󱇢")
        color: exitNodeRow.activeExitNode || exitNodeRow.settingExitNode || exitNodeRow.addMullvad ? root.foreground : root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        width: Style.space(22)
        horizontalAlignment: Text.AlignHCenter
        anchors.verticalCenter: parent.verticalCenter

        NumberAnimation on rotation {
          running: exitNodeRow.settingExitNode
          from: 0
          to: 360
          duration: 900
          loops: Animation.Infinite
        }

        onRotationChanged: if (!exitNodeRow.settingExitNode && rotation !== 0) rotation = 0
      }

      Text {
        textFormat: Text.PlainText
        text: exitNodeRow.peerName
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        font.bold: exitNodeRow.activeExitNode
        elide: Text.ElideRight
        width: parent.width - Style.space(22) - Style.space(8)
        anchors.verticalCenter: parent.verticalCenter
      }
    }

    MouseArea {
      id: exitNodeMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: root.setExitNodeCursor(exitNodeRow.rowIndex)
      onClicked: root.chooseExitNode(exitNodeRow.peer)
    }

    PanelToolTip {
      visible: exitNodeRow.actionTooltip !== "" && exitNodeMouse.containsMouse
      text: exitNodeRow.actionTooltip
      fontFamily: root.fontFamily
    }
  }

  component MullvadRegionRow: CursorSurface {
    id: regionRow

    property var peer: null
    property int rowIndex: 0
    readonly property string regionName: root.mullvadRegionTitle(peer)
    readonly property string regionDetail: root.mullvadRegionSubtitle(peer)
    readonly property bool activeExitNode: peer && peer.ExitNode === true
    readonly property bool settingExitNode: peer && tailscale.settingExitNodeId === String(peer.id || "")
    readonly property bool selectedRegion: root.mullvadPickerOpen && root.mullvadRegionIndex === rowIndex
    readonly property string actionTooltip: activeExitNode ? "Disconnect" : "Connect"

    foreground: root.foreground
    fill: root.hoverFill
    currentFill: root.selectedFill
    current: activeExitNode || settingExitNode || selectedRegion
    implicitHeight: row.implicitHeight + Style.spacing.lg

    Row {
      id: row
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(6)
      anchors.rightMargin: Style.space(6)
      spacing: Style.space(8)

      Text {
        text: "󰖂"
        color: regionRow.current ? root.foreground : root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        width: Style.space(22)
        horizontalAlignment: Text.AlignHCenter
        anchors.verticalCenter: parent.verticalCenter
      }

      Column {
        width: parent.width - Style.space(30)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(1)

        Text {
          textFormat: Text.PlainText
          width: parent.width
          text: regionRow.regionName
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          font.bold: regionRow.activeExitNode
          elide: Text.ElideRight
        }

        Text {
          textFormat: Text.PlainText
          width: parent.width
          text: regionRow.regionDetail
          visible: text !== ""
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
        }
      }
    }

    MouseArea {
      id: regionMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: root.mullvadRegionIndex = regionRow.rowIndex
      onClicked: root.chooseExitNode(regionRow.peer)
    }

    PanelToolTip {
      visible: regionMouse.containsMouse
      text: regionRow.actionTooltip
      fontFamily: root.fontFamily
    }
  }

  component ServiceRow: CursorSurface {
    id: serviceRow
    property var service: null
    property int rowIndex: 0
    readonly property bool reachable: service && service.Reachable === true
    readonly property bool probed: service && service.Probed === true
    readonly property string serviceName: service ? String(service.Name || "") : ""
    readonly property string serviceUrl: service ? String(service.Url || "") : ""
    // Which machine currently answers for the service, then what the probe got
    // back from it: "shed · HTTP 200 · 11 ms". An offline carrier says so —
    // that is the difference between "nobody serves this" and "go wake that
    // machine up".
    readonly property string detail: {
      if (!service) return ""
      var host = String(service.HostName || "")
      if (host === "") host = "No current host"
      else if (service.HostOnline !== true) host += " (offline)"
      if (!probed) return host + " · Checking…"
      var code = Number(service.Code || 0)
      if (!reachable) return host + " · " + (code > 0 ? "HTTP " + code : "Unreachable")
      var response = code > 0 ? "HTTP " + code : "Reachable"
      var latency = Number(service.LatencyMs || 0)
      if (latency > 0) response += " · " + latency + " ms"
      return host + " · " + response
    }

    hasCursor: root.cursorActive && root.focusSection === "services" && root.serviceIndex === rowIndex
    foreground: root.foreground

    implicitHeight: Math.max(serviceContent.implicitHeight, copyServiceButton.implicitHeight) + Style.spacing.rowPaddingX

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onContainsMouseChanged: if (containsMouse) root.setServiceCursor(serviceRow.rowIndex)
      onClicked: root.openService(serviceRow.service)
    }

    RowLayout {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(8)
      spacing: Style.space(8)

      // Neutral until the first probe lands: an unprobed service is not a
      // failing one, and a row of red on open would say otherwise.
      Rectangle {
        Layout.preferredWidth: Style.space(8)
        Layout.preferredHeight: Style.space(8)
        Layout.alignment: Qt.AlignVCenter
        radius: Layout.preferredWidth / 2
        color: !serviceRow.probed ? root.dim : (serviceRow.reachable ? root.foreground : root.urgent)
      }

      ColumnLayout {
        id: serviceContent
        Layout.fillWidth: true
        spacing: Style.space(1)

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: serviceRow.serviceName
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          elide: Text.ElideRight
        }

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: serviceRow.serviceUrl
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideMiddle
        }

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: serviceRow.detail
          color: !serviceRow.probed || serviceRow.reachable ? root.dim : root.urgent
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
        }
      }

      PanelActionButton {
        id: copyServiceButton
        iconText: "󰆏"
        tooltipText: "Copy service URL"
        foreground: root.foreground
        fontFamily: root.fontFamily
        enabled: serviceRow.serviceUrl !== ""
        Layout.alignment: Qt.AlignVCenter
        onClicked: tailscale.copyToClipboard(serviceRow.serviceUrl, serviceRow.serviceName + " URL")
      }

      PanelActionButton {
        iconText: "󰏌"
        tooltipText: "Open in browser"
        foreground: root.foreground
        fontFamily: root.fontFamily
        enabled: serviceRow.serviceUrl !== ""
        Layout.alignment: Qt.AlignVCenter
        onClicked: root.openService(serviceRow.service)
      }
    }
  }
}
