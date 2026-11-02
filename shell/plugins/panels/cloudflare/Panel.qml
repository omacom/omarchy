import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "Model.js" as Model

Panel {
  id: root
  moduleName: "omarchy.cloudflare"
  ipcTarget: "omarchy.cloudflare"
  manageIpc: false

  // Items inside the panel's lazily built content, null until it first
  // opens. Code inside the content reaches its own ids directly.
  readonly property Item panelFlick: panel.loadedContent ? panel.loadedContent.panelFlick : null
  readonly property Item column: panel.loadedContent ? panel.loadedContent.column : null
  readonly property Item versionsSection: panel.loadedContent ? panel.loadedContent.versionsSection : null
  readonly property Item versionFlick: panel.loadedContent ? panel.loadedContent.versionFlick : null
  readonly property Item versionColumn: panel.loadedContent ? panel.loadedContent.versionColumn : null
  readonly property Item workerColumn: panel.loadedContent ? panel.loadedContent.workerColumn : null
  readonly property Item zoneColumn: panel.loadedContent ? panel.loadedContent.zoneColumn : null

  readonly property string domainGlyph: "󰖟"
  readonly property string workerGlyph: "󰅴"
  readonly property string backGlyph: I18n.rightToLeft ? "󰅂" : "󰅁"
  readonly property string chevronGlyph: I18n.rightToLeft ? "󰅁" : "󰅂"

  // Workers and Domains share one cursor: indexes below workers.length are
  // Workers, the rest are domains. Signed out, the only target is sign-in.
  // Inside a Worker's view the same cursor walks its versions.
  property int rowIndex: 0
  property int listRowIndex: 0
  property bool cursorActive: false

  readonly property color foreground: bar ? bar.foreground : Commons.Color.foreground
  readonly property color urgent: bar ? bar.urgent : Commons.Color.urgent
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property bool signedIn: SharedService.authenticated
  readonly property bool healthy: signedIn && SharedService.tokenValid
  readonly property bool inWorker: signedIn && SharedService.detailWorker !== null
  readonly property int rowCount: !signedIn ? 0 : (inWorker ? SharedService.detailVersions.length : SharedService.zones.length + SharedService.workers.length)
  // Shown in one go once the deployment is in, rather than growing a source
  // a moment after the date.
  readonly property string workerMeta: {
    if (!SharedService.deploymentsLoaded) return I18n.t("common.loading")
    var rollout = Model.rolloutText(SharedService.detailLive, I18n.t, I18n.formatNumber)
    if (rollout !== "") return rollout
    var when = Model.relativeTime(SharedService.detailDeployedOn, undefined, I18n.t, I18n.formatNumber)
    if (when === "") return I18n.t("cloudflare.worker")
    if (SharedService.detailSource === "") return I18n.t("cloudflare.deployed").arg(when)
    return I18n.t("cloudflare.deployedVia").arg(when).arg(SharedService.detailSource)
  }
  // The service keeps its messages untranslated; read here, inside bindings, so
  // a language switch also reaches a message already on screen.
  function messageText(message) {
    if (!message) return ""
    if (message.key === undefined) return message.text
    var text = I18n.t(message.key)
    for (var i = 0; i < message.args.length; i++) text = text.arg(message.args[i])
    return text
  }
  readonly property string actionStatusText: messageText(SharedService.actionStatus)
  readonly property string lastErrorText: messageText(SharedService.lastError)
  // The service keeps its status in English for IPC; this is how it reads here.
  readonly property string statusLabel: {
    switch (SharedService.statusText) {
    case "Checking…": return I18n.t("cloudflare.checking")
    case "Not installed": return I18n.t("cloudflare.notInstalled")
    case "Signed out": return I18n.t("cloudflare.signedOut")
    case "Status error": return I18n.t("cloudflare.statusError")
    case "Could not verify Cloudflare login": return I18n.t("cloudflare.couldNotVerify")
    case "Signed in": return I18n.t("cloudflare.signedIn")
    }
    return SharedService.statusText
  }
  readonly property real maxContentHeight: Style.space(560)
  // In a Worker's view the header and metrics stay put and only the versions
  // scroll: the list gets whatever height is left below the section's top.
  // The card is also capped by the screen, and its padding comes out of the
  // same height, so size against what the column can actually show.
  readonly property real maxColumnHeight: {
    var cap = panel.availableCardHeight > 0 ? Math.min(panel.availableCardHeight, maxContentHeight) : maxContentHeight
    return cap - panel.verticalContentInset
  }
  readonly property real versionsViewportHeight: Math.max(Style.space(120), maxColumnHeight - (versionsSection ? versionsSection.y + versionsSection.rowsTop : 0))
  // While versions load, their place is held at the height the list will
  // most likely fill, so the card does not jump when they arrive.
  readonly property real versionsLoadingHeight: Math.max(Style.space(120), maxColumnHeight - (versionsSection ? versionsSection.y + versionsSection.statusTop : 0))
  readonly property color iconColor: healthy ? foreground : dim
  // Only a confirmed sign-out carries the needs-login badge. An
  // unverified token or missing CLI dims the mark.
  readonly property bool needsLogin: SharedService.installed && !signedIn
  readonly property color barIconColor: healthy ? barForeground : Qt.darker(barForeground, 1.55)

  function clampCursor() {
    if (rowIndex >= rowCount) rowIndex = Math.max(0, rowCount - 1)
    if (rowIndex < 0) rowIndex = 0
  }

  function moveCursor(dx, dy) {
    pointerGate.reset()
    cursorActive = true
    if (dx !== 0) {
      if (inWorker) {
        if (dx < 0) closeWorker()
      } else {
        switchAccount(dx)
      }
      return
    }
    if (rowCount === 0) return
    rowIndex = Math.max(0, Math.min(rowCount - 1, rowIndex + dy))
    scrollCursorIntoView()
  }

  function switchAccount(step) {
    var accounts = SharedService.accounts
    if (accounts.length < 2) return
    var current = 0
    for (var i = 0; i < accounts.length; i++) {
      if (accounts[i].id === SharedService.selectedAccountId) current = i
    }
    var next = (current + step + accounts.length) % accounts.length
    rowIndex = 0
    SharedService.selectAccount(accounts[next].id)
  }

  function selectedWorker() {
    return rowIndex < SharedService.workers.length ? SharedService.workers[rowIndex] : null
  }

  // The Worker under the cursor starts loading once the cursor settles on
  // it, so its view is usually ready by the time it is opened.
  function schedulePrefetch() {
    if (opened && cursorActive && !inWorker && selectedWorker()) prefetchTimer.restart()
    else prefetchTimer.stop()
  }

  function selectedZone() {
    var index = rowIndex - SharedService.workers.length
    return index >= 0 && index < SharedService.zones.length ? SharedService.zones[index] : null
  }

  function setRowCursor(index) {
    cursorActive = true
    rowIndex = index
  }

  // Rows follow the pointer only once it actually moves. A row appearing
  // under a still pointer (the panel opening, or the list coming back from a
  // Worker's view) must not steal the keyboard cursor.
  function selectFromPointer(index, item, mouse) {
    if (!pointerGate.moved(item, mouse)) return
    setRowCursor(index)
  }

  function openWorkerView(worker) {
    if (!worker) return
    pointerGate.reset()
    listRowIndex = rowIndex
    rowIndex = 0
    if (panelFlick) panelFlick.contentY = 0
    if (versionFlick) versionFlick.contentY = 0
    SharedService.openWorkerDetail(worker)
    prefetchTimer.stop()
  }

  // Back to the list, with the cursor on the Worker we came from.
  function closeWorker() {
    if (!inWorker) return
    pointerGate.reset()
    SharedService.closeWorkerDetail()
    rowIndex = listRowIndex
    scrollCursorIntoView()
  }

  function selectedVersion() {
    var versions = SharedService.detailVersions
    return rowIndex >= 0 && rowIndex < versions.length ? versions[rowIndex] : null
  }

  // Enter opens: a domain in the dashboard, a Worker into its own view, and
  // inside a Worker's view, that Worker in the dashboard.
  function openSelected() {
    if (!signedIn) {
      SharedService.login()
      return
    }
    if (inWorker) {
      SharedService.openWorker(SharedService.detailWorker)
      return
    }
    var worker = selectedWorker()
    var zone = selectedZone()
    if (worker) openWorkerView(worker)
    else if (zone) SharedService.openZone(zone)
    else SharedService.openDashboard()
  }

  function copySelected() {
    if (inWorker) {
      SharedService.copyVersion(selectedVersion())
      return
    }
    var worker = selectedWorker()
    var zone = selectedZone()
    if (worker) SharedService.copyWorker(worker)
    else if (zone) SharedService.copyZoneId(zone)
  }

  function refreshView() {
    if (inWorker) SharedService.refreshWorkerDetail()
    else SharedService.refresh()
  }

  function scrollItemIntoView(item, flick) {
    var view = flick || panelFlick
    if (!view || !item) return
    Qt.callLater(function() {
      if (!item) return
      var margin = Style.space(6)
      var point = item.mapToItem(view.contentItem, 0, 0)
      var top = point.y
      var bottom = top + item.height
      var viewTop = view.contentY
      var viewBottom = viewTop + view.height
      var maxY = Math.max(0, view.contentHeight - view.height)
      if (top < viewTop + margin) view.contentY = Math.max(0, top - margin)
      else if (bottom > viewBottom - margin) view.contentY = Math.min(maxY, bottom + margin - view.height)
    })
  }

  function scrollCursorIntoView() {
    if (inWorker) {
      if (versionColumn && rowIndex < versionColumn.children.length) scrollItemIntoView(versionColumn.children[rowIndex], versionFlick)
      return
    }
    var workerCount = SharedService.workers.length
    if (rowIndex < workerCount) {
      if (workerColumn && rowIndex < workerColumn.children.length) scrollItemIntoView(workerColumn.children[rowIndex])
    } else if (zoneColumn && rowIndex - workerCount < zoneColumn.children.length) {
      scrollItemIntoView(zoneColumn.children[rowIndex - workerCount])
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onOpenedChanged: if (opened) {
    pointerGate.reset()
    cursorActive = false
    rowIndex = 0
    if (panelFlick) panelFlick.contentY = 0
    Qt.callLater(function() { if (panel.loadedContent) panel.loadedContent.forceActiveFocus() })
  }
  onRowIndexChanged: {
    scrollCursorIntoView()
    schedulePrefetch()
  }
  onCursorActiveChanged: schedulePrefetch()
  onRowCountChanged: clampCursor()

  Client {
    opened: root.opened
    settings: root.settings
  }

  Timer {
    id: prefetchTimer
    interval: 450
    repeat: false
    onTriggered: if (root.opened && !root.inWorker) SharedService.prefetchWorker(root.selectedWorker())
  }

  PointerMoveGate {
    id: pointerGate
    referenceItem: column
  }

  ShellIpc {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): string { SharedService.refresh(); return "ok" }
    function login(): string { SharedService.login(); return "ok" }
    function status(): string { return SharedService.statusText }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    iconComponent: Component {
      Item {
        CloudflareIcon {
          anchors.centerIn: parent
          iconSize: Style.space(11)
          color: root.barIconColor
          badgeColor: root.urgent
          warning: root.needsLogin
        }
      }
    }
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) SharedService.openDashboard()
      else if (buttonCode === Qt.MiddleButton) SharedService.refresh()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight, root.maxContentHeight)

    content: PanelKeyCatcher {
      id: keyCatcher
      property alias panelFlick: panelFlick
      property alias column: column
      property alias versionsSection: versionsSection
      property alias versionFlick: versionFlick
      property alias versionColumn: versionColumn
      property alias workerColumn: workerColumn
      property alias zoneColumn: zoneColumn
      implicitHeight: column.implicitHeight
      anchors.fill: parent
      onMoveRequested: function(dx, dy) {
        if (!root.cursorActive && dx === 0) { root.cursorActive = true; return }
        root.moveCursor(dx, dy)
      }
      onActivateRequested: if (root.cursorActive || !root.signedIn) root.openSelected()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (t === "\b") root.closeWorker()
        else if (t === "r" || t === "R") root.refreshView()
        else if (t === "o" || t === "O") root.openSelected()
        else if (t === "c" || t === "C") root.copySelected()
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

          PanelHero {
            id: hero
            width: parent.width
            // Like the Agents panel: the service by name, and a fact under it
            // (which login this is) rather than activity phrases, since
            // nothing runs locally for Cloudflare.
            title: root.inWorker ? SharedService.detailWorker.name : "Cloudflare"
            meta: root.inWorker ? root.workerMeta : (root.healthy && SharedService.email !== "" ? SharedService.email : root.statusLabel)
            foreground: root.foreground
            fontFamily: root.fontFamily
            iconOpacity: root.healthy ? 1.0 : 0.5
            // In a Worker's view the mark becomes the way back, like the
            // menu's parent row.
            iconComponent: Component {
              Item {
                implicitWidth: root.inWorker ? backText.implicitWidth : heroMark.implicitWidth
                implicitHeight: heroMark.implicitHeight

                CloudflareIcon {
                  id: heroMark
                  visible: !root.inWorker
                  anchors.centerIn: parent
                  iconSize: Style.font.display
                  color: root.iconColor
                  badgeColor: root.urgent
                  warning: root.needsLogin
                }

                Text {
                  id: backText
                  visible: root.inWorker
                  anchors.centerIn: parent
                  textFormat: Text.PlainText
                  text: root.backGlyph
                  color: backArea.containsMouse ? root.foreground : root.iconColor
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.display
                }

                MouseArea {
                  id: backArea
                  anchors.fill: parent
                  enabled: root.inWorker
                  hoverEnabled: true
                  cursorShape: root.inWorker ? Qt.PointingHandCursor : Qt.ArrowCursor
                  onClicked: root.closeWorker()
                }
              }
            }
          }

          // Only there when the login reaches more than one account, like the
          // agents panel's provider switch. h / l cycle it from the keyboard.
          Row {
            id: accountSwitch
            visible: root.signedIn && !root.inWorker && SharedService.accounts.length > 1
            width: parent.width
            spacing: Style.spacing.md

            readonly property real cellWidth: SharedService.accounts.length > 0
              ? (width - spacing * (SharedService.accounts.length - 1)) / SharedService.accounts.length
              : 0

            Repeater {
              model: SharedService.accounts

              Button {
                required property var modelData

                width: accountSwitch.cellWidth
                text: modelData.name
                selected: modelData.id === SharedService.selectedAccountId
                bordered: true
                foreground: root.foreground
                fontFamily: root.fontFamily
                fontSize: Style.font.bodySmall
                verticalPadding: Style.spacing.controlPaddingY
                onClicked: {
                  root.rowIndex = 0
                  SharedService.selectAccount(modelData.id)
                }
              }
            }
          }

          Text {
            textFormat: Text.PlainText
            visible: root.actionStatusText !== "" || root.lastErrorText !== ""
            width: parent.width
            text: root.actionStatusText !== "" ? root.actionStatusText : root.lastErrorText
            color: root.lastErrorText !== "" && root.actionStatusText === "" ? root.urgent : root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
            wrapMode: Text.WordWrap
          }

          Text {
            textFormat: Text.PlainText
            visible: SharedService.loginCode !== ""
            width: parent.width
            text: SharedService.loginCode
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.display
            font.letterSpacing: Style.space(2)
          }

          LoginRow {
            visible: !root.signedIn
            width: parent.width
          }

          PanelSeparator {
            visible: root.signedIn && !root.inWorker
            foreground: root.foreground
          }

          ResourceSection {
            visible: root.signedIn && !root.inWorker
            title: I18n.t("cloudflare.workers")
            count: SharedService.workers.length
            error: root.messageText(SharedService.workersError)
            loading: SharedService.loadingResources
            loadingText: I18n.t("cloudflare.loadingWorkers")
            emptyText: I18n.t("cloudflare.noWorkers")

            Column {
              id: workerColumn
              width: parent.width
              spacing: Style.space(6)

              Repeater {
                model: SharedService.workers
                ResourceRow {
                  required property var modelData
                  required property int index
                  width: workerColumn.width
                  rowIndex: index
                  glyph: root.workerGlyph
                  title: modelData.name
                  detail: Model.relativeTime(modelData.deployedOn, undefined, I18n.t, I18n.formatNumber)
                  copyTooltip: modelData.url !== "" ? I18n.t("cloudflare.copyWorkersDevUrl") : I18n.t("cloudflare.copyWorkerName")
                  drillable: true
                  onActivated: root.openWorkerView(modelData)
                  onOpenRequested: SharedService.openWorker(modelData)
                  onCopyRequested: SharedService.copyWorker(modelData)
                }
              }
            }
          }

          PanelSeparator {
            visible: root.signedIn && !root.inWorker
            foreground: root.foreground
          }

          ResourceSection {
            visible: root.signedIn && !root.inWorker
            title: I18n.t("cloudflare.domains")
            count: SharedService.zones.length
            error: root.messageText(SharedService.zonesError)
            loading: SharedService.loadingResources
            loadingText: I18n.t("cloudflare.loadingDomains")
            emptyText: I18n.t("cloudflare.noDomains")

            Column {
              id: zoneColumn
              width: parent.width
              spacing: Style.space(6)

              Repeater {
                model: SharedService.zones
                ResourceRow {
                  required property var modelData
                  required property int index
                  width: zoneColumn.width
                  rowIndex: SharedService.workers.length + index
                  glyph: root.domainGlyph
                  title: modelData.name
                  detail: Model.zoneDetail(modelData, I18n.t)
                  detailUrgent: Model.zoneProblem(modelData) !== ""
                  copyTooltip: I18n.t("cloudflare.copyZoneId")
                  onActivated: SharedService.openZone(modelData)
                  onOpenRequested: SharedService.openZone(modelData)
                  onCopyRequested: SharedService.copyZoneId(modelData)
                }
              }
            }
          }

          PanelSeparator {
            visible: root.inWorker
            foreground: root.foreground
          }

          Column {
            visible: root.inWorker
            width: parent.width
            spacing: Style.space(10)

            PanelSectionHeader {
              text: I18n.t("cloudflare.metricsLast24Hours")
              foreground: root.foreground
              fontFamily: root.fontFamily
            }

            Text {
              textFormat: Text.PlainText
              visible: !!SharedService.metricsError
              width: parent.width
              text: root.messageText(SharedService.metricsError)
              color: root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
              wrapMode: Text.WordWrap
            }

            Column {
              visible: !SharedService.metricsError || Object.keys(SharedService.detailMetrics).length > 0
              width: parent.width
              spacing: Style.space(12)

              MetricRow {
                label: I18n.t("cloudflare.invocations")
                metric: SharedService.detailMetrics.invocations || null
                format: "count"
              }

              MetricRow {
                label: I18n.t("cloudflare.cpuTime")
                metric: SharedService.detailMetrics.cpu || null
                format: "ms"
                higherIsWorse: true
              }

              MetricRow {
                label: I18n.t("cloudflare.errors")
                metric: SharedService.detailMetrics.errors || null
                format: "count"
                // Like the dashboard: the count says it all, and "down 100%"
                // from a handful of errors to none is noise.
                showChange: false
                alarming: !!metric && metric.value > 0
              }
            }
          }

          PanelSeparator {
            visible: root.inWorker
            foreground: root.foreground
          }

          ResourceSection {
            id: versionsSection
            visible: root.inWorker
            title: I18n.t("cloudflare.versions")
            count: SharedService.detailVersions.length
            error: root.messageText(SharedService.versionsError)
            loading: SharedService.versionsLoading
            loadingText: I18n.t("cloudflare.loadingVersions")
            loadingHeight: root.versionsLoadingHeight
            emptyText: I18n.t("cloudflare.noVersions")

            Flickable {
              id: versionFlick
              width: parent.width
              height: Math.min(versionColumn.implicitHeight, root.versionsViewportHeight)
              contentWidth: width
              contentHeight: versionColumn.implicitHeight
              clip: true
              boundsBehavior: Flickable.StopAtBounds
              flickableDirection: Flickable.VerticalFlick
              interactive: contentHeight > height
              ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
              // A status line above the card's sections takes its height
              // from this list, so keep the cursor's row in view.
              onHeightChanged: if (root.cursorActive) root.scrollCursorIntoView()

              Column {
                id: versionColumn
                width: versionFlick.width
                spacing: Style.space(6)

                Repeater {
                  model: SharedService.detailVersions
                  VersionRow {
                    required property var modelData
                    required property int index
                    width: versionColumn.width
                    version: modelData
                    rowIndex: index
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  component LoginRow: CursorSurface {
    id: loginRow

    hasCursor: root.cursorActive
    foreground: root.foreground
    implicitHeight: loginContent.implicitHeight + Style.spacing.rowPaddingX

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      enabled: SharedService.installed && !SharedService.busy
      cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
      onPositionChanged: function(mouse) { if (pointerGate.moved(loginRow, mouse)) root.cursorActive = true }
      onClicked: SharedService.login()
    }

    RowLayout {
      id: loginContent
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(10)
      spacing: Style.space(8)

      Text {
        textFormat: Text.PlainText
        text: "󰌋"
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.heading
        Layout.alignment: Qt.AlignVCenter
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.space(1)

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: SharedService.installed ? I18n.t("cloudflare.signIn") : I18n.t("cloudflare.cliMissing")
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          elide: Text.ElideRight
        }

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: SharedService.installed ? I18n.t("cloudflare.signInHint") : I18n.t("cloudflare.installHint")
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
        }
      }
    }
  }

  // A section header over its rows, with the loading, empty, and error states
  // every list needs. Rows go in as children.
  component ResourceSection: Column {
    id: section
    property string title: ""
    property int count: 0
    property string error: ""
    property bool loading: false
    property string loadingText: ""
    property real loadingHeight: 0
    property string emptyText: ""
    readonly property bool waiting: loading && count === 0 && error === ""
    readonly property real statusTop: statusLine.y
    readonly property real rowsTop: rowHolder.y
    default property alias rows: rowHolder.data

    width: parent.width
    spacing: Style.space(10)

    PanelSectionHeader {
      text: section.title
      foreground: root.foreground
      fontFamily: root.fontFamily
    }

    Text {
      id: statusLine
      textFormat: Text.PlainText
      visible: section.error !== "" || section.count === 0
      width: parent.width
      height: section.waiting ? Math.max(implicitHeight, section.loadingHeight) : implicitHeight
      text: section.error !== "" ? section.error : (section.loading ? section.loadingText : section.emptyText)
      color: section.error !== "" ? root.urgent : root.dim
      font.family: root.fontFamily
      font.pixelSize: section.error !== "" ? Style.font.bodySmall : Style.font.body
      horizontalAlignment: section.error !== "" ? Text.AlignLeft : Text.AlignHCenter
      wrapMode: Text.WordWrap
    }

    Item {
      id: rowHolder
      visible: section.count > 0
      width: parent.width
      implicitHeight: childrenRect.height
    }
  }

  // One domain or Worker: glyph, name, a dim detail on the right, then copy
  // and open. Clicking the row opens it too, like the dashboard's list rows.
  component ResourceRow: CursorSurface {
    id: resourceRow
    property int rowIndex: 0
    property string glyph: ""
    property string title: ""
    property string detail: ""
    property bool detailUrgent: false
    property string copyTooltip: ""
    property bool drillable: false
    signal activated()
    signal openRequested()
    signal copyRequested()

    hasCursor: root.cursorActive && root.rowIndex === rowIndex
    foreground: root.foreground
    implicitHeight: resourceContent.implicitHeight + Style.spacing.rowPaddingX

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onPositionChanged: function(mouse) { root.selectFromPointer(resourceRow.rowIndex, resourceRow, mouse) }
      onClicked: resourceRow.activated()
    }

    RowLayout {
      id: resourceContent
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(6)
      spacing: Style.space(8)

      Text {
        textFormat: Text.PlainText
        text: resourceRow.glyph
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.icon
        Layout.alignment: Qt.AlignVCenter
      }

      Text {
        textFormat: Text.PlainText
        Layout.fillWidth: true
        text: resourceRow.title
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        elide: Text.ElideRight
        Layout.alignment: Qt.AlignVCenter
      }

      Text {
        textFormat: Text.PlainText
        visible: text !== ""
        text: resourceRow.detail
        color: resourceRow.detailUrgent ? root.urgent : root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        Layout.alignment: Qt.AlignVCenter
      }

      PanelActionButton {
        iconText: "󰆏"
        tooltipText: resourceRow.copyTooltip
        foreground: root.foreground
        fontFamily: root.fontFamily
        Layout.alignment: Qt.AlignVCenter
        onHovered: function(on) { if (on) root.setRowCursor(resourceRow.rowIndex) }
        onClicked: resourceRow.copyRequested()
      }

      PanelActionButton {
        iconText: "󰏌"
        tooltipText: I18n.t("cloudflare.openInDashboard")
        foreground: root.foreground
        fontFamily: root.fontFamily
        Layout.alignment: Qt.AlignVCenter
        onHovered: function(on) { if (on) root.setRowCursor(resourceRow.rowIndex) }
        onClicked: resourceRow.openRequested()
      }

      Text {
        textFormat: Text.PlainText
        visible: resourceRow.drillable
        text: root.chevronGlyph
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.icon
        Layout.alignment: Qt.AlignVCenter
      }
    }
  }

  // One metric in the Agents panel's limit-row shape: label on the left,
  // value and change against the previous 24 hours on the right, and the
  // day's history drawn full width underneath.
  component MetricRow: Column {
    id: metricRow
    property string label: ""
    property var metric: null
    property string format: "count"
    property bool higherIsWorse: false
    property bool alarming: false
    property bool showChange: true
    readonly property bool loading: metric === null && SharedService.metricsLoading
    readonly property string valueText: format === "ms" ? Model.formatMs(metric ? metric.value : null, I18n.formatNumber) : Model.formatCount(metric ? metric.value : null, I18n.formatNumber)
    readonly property string changeText: metric && showChange ? Model.formatChange(metric.value, metric.previous, I18n.formatNumber) : ""
    readonly property bool worse: higherIsWorse && changeText.indexOf("↗") === 0

    width: parent.width
    spacing: Style.space(4)

    RowLayout {
      width: parent.width
      spacing: Style.space(8)

      Text {
        textFormat: Text.PlainText
        Layout.fillWidth: true
        text: metricRow.label
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        elide: Text.ElideRight
      }

      Text {
        textFormat: Text.PlainText
        visible: text !== ""
        text: metricRow.changeText
        color: metricRow.worse ? root.urgent : root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }

      Text {
        textFormat: Text.PlainText
        text: metricRow.loading ? "…" : metricRow.valueText
        color: metricRow.alarming ? root.urgent : root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
      }
    }

    Sparkline {
      width: parent.width
      values: metricRow.metric ? metricRow.metric.series : []
      color: metricRow.alarming ? root.urgent : root.foreground
    }
  }

  // A version as the dashboard lists it: short ID, deploy message, then the
  // commit tag, source, and author, with an accent bar on the live one.
  component VersionRow: CursorSurface {
    id: versionRow
    property var version: null
    property int rowIndex: 0
    readonly property bool live: !!version && SharedService.detailLive[version.id] !== undefined
    readonly property string meta: {
      if (!version) return ""
      var parts = []
      if (version.tag !== "") parts.push(version.tag)
      if (version.source !== "") parts.push(version.author !== "" ? I18n.t("cloudflare.sourceBy").arg(version.source).arg(version.author) : version.source)
      return parts.join(" · ")
    }

    hasCursor: root.cursorActive && root.rowIndex === rowIndex
    foreground: root.foreground
    implicitHeight: versionContent.implicitHeight + Style.spacing.rowPaddingX

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onPositionChanged: function(mouse) { root.selectFromPointer(versionRow.rowIndex, versionRow, mouse) }
    }

    Rectangle {
      visible: versionRow.live
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      width: Style.space(3)
      height: parent.height - Style.space(10)
      radius: width / 2
      color: Commons.Color.accent
    }

    RowLayout {
      id: versionContent
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(6)
      spacing: Style.space(8)

      Text {
        textFormat: Text.PlainText
        text: versionRow.version ? versionRow.version.shortId : ""
        color: versionRow.live ? root.foreground : root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: Style.space(2)
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.space(1)

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: versionRow.version && versionRow.version.message !== "" ? versionRow.version.message : I18n.t("cloudflare.noMessage")
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
          elide: Text.ElideRight
        }

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          visible: text !== ""
          text: versionRow.meta
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
        }
      }

      Text {
        textFormat: Text.PlainText
        text: versionRow.version ? Model.relativeTime(versionRow.version.createdOn, undefined, I18n.t, I18n.formatNumber) : ""
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: Style.space(2)
      }

      PanelActionButton {
        iconText: "󰆏"
        tooltipText: I18n.t("cloudflare.copyVersionId")
        foreground: root.foreground
        fontFamily: root.fontFamily
        Layout.alignment: Qt.AlignVCenter
        onHovered: function(on) { if (on) root.setRowCursor(versionRow.rowIndex) }
        onClicked: SharedService.copyVersion(versionRow.version)
      }
    }
  }
}
