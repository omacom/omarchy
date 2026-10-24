import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "Model.js" as Model

Item {
  id: root

  LabTranslations { id: labStrings }
  function t(key, fallback) { return labStrings.t(key, fallback) }
  readonly property var displayStrings: ({
    "Alt+Down": t("lab.altDown"),
    "Alt+Home": t("lab.altHome"),
    "Alt+Left": t("lab.altLeft"),
    "Alt+Right": t("lab.altRight"),
    "Alt+Up": t("lab.altUp"),
    "Apply custom": t("lab.applyCustom"),
    "Artifact capture": t("lab.artifactCapture"),
    "Aspect ratio": t("lab.aspectRatio"),
    "Audio": t("lab.audio"),
    "Auto resize": t("lab.autoResize"),
    "Automate": t("lab.automate"),
    "Balanced": t("lab.balanced"),
    "Branch deployment": t("lab.branchDeployment"),
    "Capture": t("lab.capture"),
    "Choose a local branch": t("lab.chooseALocalBranch"),
    "Choose files → guest": t("lab.chooseFilesGuest"),
    "Clipboard and files": t("lab.clipboardAndFiles"),
    "Close Lab controls": t("lab.closeLabControls"),
    "Compare latest": t("lab.compareLatest"),
    "Confirm delete": t("lab.confirmDelete"),
    "Confirm promote": t("lab.confirmPromote"),
    "Confirm rebuild": t("lab.confirmRebuild"),
    "Confirm reset": t("lab.confirmReset"),
    "Confirm restore": t("lab.confirmRestore"),
    "Console": t("lab.console"),
    "Console actions": t("lab.consoleActions"),
    "Could not start the Lab command. Check that the plugin is installed correctly and try again.": t("lab.couldNotStartTheLabCommandCheckThatThePluginIsInstalledCorrectlyAndTryAgain"),
    "Create": t("lab.create"),
    "Create checkpoint": t("lab.createCheckpoint"),
    "Creates a disposable VM; a terminal opens for setup and authentication": t("lab.createsADisposableVMATerminalOpensForSetupAndAuthentication"),
    "Ctrl+Left": t("lab.ctrlLeft"),
    "Ctrl+R": t("lab.ctrlR"),
    "Ctrl+Right": t("lab.ctrlRight"),
    "Cursor": t("lab.cursor"),
    "Custom resources": t("lab.customResources"),
    "Delete": t("lab.delete"),
    "Deploy branch": t("lab.deployBranch"),
    "Deploy branch + reboot": t("lab.deployBranchReboot"),
    "Develop": t("lab.develop"),
    "Diagnostic bundle": t("lab.diagnosticBundle"),
    "Diagnostics": t("lab.diagnostics"),
    "Drag header · Alt+arrows move · Alt+Home centers · Ctrl+←/→ pages · Esc closes": t("lab.dragHeaderAltArrowsMoveAltHomeCentersCtrlPagesEscCloses"),
    "Drive the graphical session without touching the console": t("lab.driveTheGraphicalSessionWithoutTouchingTheConsole"),
    "Environment": t("lab.environment"),
    "Escape": t("lab.escape"),
    "Explicit one-shot transfers; no shared host folders": t("lab.explicitOneShotTransfersNoSharedHostFolders"),
    "Extra room for heavier builds and multitasking": t("lab.extraRoomForHeavierBuildsAndMultitasking"),
    "For quick checks and lightweight testing": t("lab.forQuickChecksAndLightweightTesting"),
    "Full": t("lab.full"),
    "Fullscreen": t("lab.fullscreen"),
    "Gold image": t("lab.goldImage"),
    "Gold image unavailable": t("lab.goldImageUnavailable"),
    "Guest Downloads → host": t("lab.guestDownloadsHost"),
    "Guest clipboard → host": t("lab.guestClipboardHost"),
    "Guest command": t("lab.guestCommand"),
    "Guest shortcuts": t("lab.guestShortcuts"),
    "HOME": t("lab.hOME"),
    "Health dashboard": t("lab.healthDashboard"),
    "Health unavailable": t("lab.healthUnavailable"),
    "High-performance Lab allocation; Custom can go higher": t("lab.highPerformanceLabAllocationCustomCanGoHigher"),
    "Host clipboard → guest": t("lab.hostClipboardGuest"),
    "Install Lab VM": t("lab.installLabVM"),
    "Install the guest": t("lab.installTheGuest"),
    "Isolated": t("lab.isolated"),
    "Isolated network": t("lab.isolatedNetwork"),
    "Keep in bar": t("lab.keepInBar"),
    "Lab controls · middle click fullscreen · right click screenshot": t("lab.labControlsMiddleClickFullscreenRightClickScreenshot"),
    "Lab controls · viewer closed": t("lab.labControlsViewerClosed"),
    "Launcher": t("lab.launcher"),
    "Light": t("lab.light"),
    "Local cursor": t("lab.localCursor"),
    "Lock": t("lab.lock"),
    "Lock guest": t("lab.lockGuest"),
    "Menu bar pin": t("lab.menuBarPin"),
    "Model.js": t("lab.modelJs"),
    "NAT": t("lab.nAT"),
    "NAT network": t("lab.nATNetwork"),
    "Named checkpoints": t("lab.namedCheckpoints"),
    "Network mode": t("lab.networkMode"),
    "Network unavailable": t("lab.networkUnavailable"),
    "No captured artifacts": t("lab.noCapturedArtifacts"),
    "No checkout deployed": t("lab.noCheckoutDeployed"),
    "No local branches": t("lab.noLocalBranches"),
    "OMARCHY_LAB_NAME": t("lab.oMARCHYLABNAME"),
    "OMARCHY_LAB_VIEWER_SETTINGS": t("lab.oMARCHYLABVIEWERSETTINGS"),
    "OMARCHY_PATH": t("lab.oMARCHYPATH"),
    "Offline": t("lab.offline"),
    "Offline network": t("lab.offlineNetwork"),
    "Omarchy Lab": t("lab.omarchyLab"),
    "Open Lab": t("lab.openLab"),
    "Open launcher": t("lab.openLauncher"),
    "Open terminal": t("lab.openTerminal"),
    "Opening ": t("lab.opening"),
    "Opening Lab": t("lab.openingLab"),
    "Opening Lab…": t("lab.openingLabLabel"),
    "Opening installer": t("lab.openingInstaller"),
    "Opening installer…": t("lab.openingInstallerLabel"),
    "Opening terminal…": t("lab.openingTerminal"),
    "Performance": t("lab.performance"),
    "Preferences persist between sessions": t("lab.preferencesPersistBetweenSessions"),
    "Promote current": t("lab.promoteCurrent"),
    "Pull Downloads": t("lab.pullDownloads"),
    "Reboot": t("lab.reboot"),
    "Rebuild from ISO": t("lab.rebuildFromISO"),
    "Receive clipboard": t("lab.receiveClipboard"),
    "Recommended for most development and UI testing": t("lab.recommendedForMostDevelopmentAndUITesting"),
    "Record 10s": t("lab.record10s"),
    "Recording": t("lab.recording"),
    "Refresh Lab status": t("lab.refreshLabStatus"),
    "Refresh health": t("lab.refreshHealth"),
    "Reload Hyprland": t("lab.reloadHyprland"),
    "Rename": t("lab.rename"),
    "Rename checkpoint": t("lab.renameCheckpoint"),
    "Reset": t("lab.reset"),
    "Reset requires a second confirmation": t("lab.resetRequiresASecondConfirmation"),
    "Resize the guest and viewer together": t("lab.resizeTheGuestAndViewerTogether"),
    "Resource profile": t("lab.resourceProfile"),
    "Resources unavailable": t("lab.resourcesUnavailable"),
    "Restart shell": t("lab.restartShell"),
    "Restore": t("lab.restore"),
    "Run": t("lab.run"),
    "Run scenario": t("lab.runScenario"),
    "Scale content while preserving its shape": t("lab.scaleContentWhilePreservingItsShape"),
    "Scenario ": t("lab.scenario"),
    "Scenario runner": t("lab.scenarioRunner"),
    "Screenshot": t("lab.screenshot"),
    "Screenshot comparison": t("lab.screenshotComparison"),
    "Search local branches…": t("lab.searchLocalBranches"),
    "Select Confirm ": t("lab.selectConfirm"),
    "Send clipboard": t("lab.sendClipboard"),
    "Send files": t("lab.sendFiles"),
    "Stop": t("lab.stop"),
    "Sync branch": t("lab.syncBranch"),
    "Terminal": t("lab.terminal"),
    "USB": t("lab.uSB"),
    "USB redirection": t("lab.uSBRedirection"),
    "Validated command arrays; shell strings are never evaluated": t("lab.validatedCommandArraysShellStringsAreNeverEvaluated"),
    "Viewer": t("lab.viewer"),
    "Wake": t("lab.wake"),
    "Wake guest": t("lab.wakeGuest"),
    "Zoom": t("lab.zoom"),
  })
  function displayText(value) {
    value = String(value || "")
    if (Object.prototype.hasOwnProperty.call(displayStrings, value)) return displayStrings[value]
    var match = value.match(/^Opening (.*) terminal$/)
    if (match) return t("lab.openingActionTerminal").arg(displayText(match[1]))
    match = value.match(/^Select Confirm (.*) within five seconds\.$/)
    if (match) return t("lab.confirmActionPrompt").arg(displayText(match[1]))
    match = value.match(/^(.*) resources$/)
    if (match) return t("lab.actionResources").arg(displayText(match[1]))
    match = value.match(/^(.*) failed$/)
    if (match) return t("lab.actionFailed").arg(displayText(match[1]))
    return value
  }

  function labCommand(name) {
    if (name.startsWith("/")) return name
    return Quickshell.env("OMARCHY_PATH") + "/bin/" + name
  }

  property var shell: null
  property var manifest: null
  property bool opened: false
  property bool busy: false
  property string openingTerminalAction: ""
  readonly property bool installerOpening: busy && actionLabel === "Opening installer"
  readonly property bool inlineInstallError: currentPage === 0 && !status.installed && actionLabel === "Opening installer" && errorText !== ""
  property bool resetArmed: armedAction === "reset"
  property string armedAction: ""
  property string errorText: ""
  property string actionOutput: ""
  property string stderrText: ""
  property string actionLabel: ""
  property bool closeAfterAction: false
  property int currentPage: 0
  property var status: Model.defaultStatus()
  property string healthRaw: ""
  readonly property string healthSummary: Model.healthText(healthRaw, root.t, I18n.formatNumber)
  property string networkRaw: ""
  readonly property string networkSummary: Model.networkText(networkRaw, root.t, I18n.formatNumber)
  property string resourceRaw: ""
  readonly property string resourceSummary: Model.resourceText(resourceRaw, root.t, I18n.formatNumber)
  property var resources: Model.defaultResources()
  property int customResourceCpus: 1
  property int customResourceMemoryGiB: 1
  property bool customResourcesDirty: false
  property string deploymentRaw: ""
  readonly property string deploymentSummary: Model.deploymentText(deploymentRaw, root.t, I18n.formatNumber)
  property string goldRaw: ""
  readonly property string goldSummary: Model.goldText(goldRaw, root.t, I18n.formatNumber)
  property string artifactRaw: ""
  readonly property string artifactSummary: Model.artifactText(artifactRaw, root.t, I18n.formatNumber)
  property var branches: []
  property var checkpoints: []
  property var scenarios: []
  property string selectedBranch: ""
  property string selectedCheckpoint: ""
  property string selectedScenario: "smoke"
  property real cardOffsetX: 0
  property real cardOffsetY: 0

  readonly property string viewerCommand: labCommand("omarchy-lab-viewer")
  readonly property var pageOptions: ["Console", "Develop", "Environment", "Capture", "Automate"]
  readonly property var aspectOptions: ["16:9", "16:10", "3:2", "4:3", "21:9", "32:9"]
  readonly property var zoomOptions: ["50", "75", "100", "125", "150", "200"]
  readonly property var lightResources: Model.profileAllocation(resources, "light")
  readonly property var balancedResources: Model.profileAllocation(resources, "balanced")
  readonly property var performanceResources: Model.profileAllocation(resources, "performance")
  readonly property var fullResources: Model.profileAllocation(resources, "full")
  readonly property int maximumResourceCpus: Math.max(1, Number(resources.host.safeCpus || 1))
  readonly property int maximumResourceMemoryGiB: Model.memoryGiB(resources.host.safeMemoryBytes)
  readonly property color foreground: Commons.Color.popups.text
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string pluginId: (manifest && manifest.id) || "omarchy.lab"
  readonly property real currentPageHeight: {
    const pageHeights = [consolePage.implicitHeight, developPage.implicitHeight, environmentPage.implicitHeight, capturePage.implicitHeight, automatePage.implicitHeight]
    return pageHeights[currentPage] || 0
  }

  function open(payloadJson) {
    var payload = {}
    try { payload = JSON.parse(String(payloadJson || "{}")) || {} } catch (e) { payload = {} }
    opened = true
    armedAction = ""
    if (pageOptions.indexOf(String(payload.page || "")) !== -1)
      currentPage = pageOptions.indexOf(String(payload.page))
    refreshAll()
    Qt.callLater(function() { if (root.opened) keyCatcher.forceActiveFocus() })
  }

  function close() {
    opened = false
    armedAction = ""
    errorText = ""
  }

  function dismiss() {
    if (shell && typeof shell.hide === "function") shell.hide(pluginId)
    else close()
  }

  function startProcess(process) {
    if (!process.running) process.running = true
  }

  function refreshAll() {
    startProcess(viewerStatusProc)
    startProcess(healthProc)
    startProcess(branchListProc)
    startProcess(checkoutStatusProc)
    startProcess(checkpointListProc)
    startProcess(networkStatusProc)
    startProcess(resourceStatusProc)
    startProcess(goldStatusProc)
    startProcess(artifactListProc)
    startProcess(scenarioListProc)
  }

  function runCommand(command, args, label, closeAfter) {
    if (busy || actionProc.running) return
    busy = true
    armedAction = ""
    confirmTimer.stop()
    errorText = ""
    actionOutput = ""
    stderrText = ""
    var terminalArgs = Model.terminalCommand(command, args)
    openingTerminalAction = terminalArgs ? terminalArgs[1] : ""
    actionLabel = terminalArgs ? "Opening " + label + " terminal" : label
    closeAfterAction = closeAfter === true || terminalArgs !== null
    actionProc.command = terminalArgs ? [labCommand("omarchy-lab-terminal-launch")].concat(terminalArgs) : [labCommand(command)].concat(args)
    actionProc.running = true
  }

  function runViewer(args, label, closeAfter) {
    runCommand(viewerCommand, args, label, closeAfter)
  }

  function openInstaller() {
    runCommand("omarchy-lab-install-launch", [], "Opening installer", true)
  }

  function openLab() {
    if (!status.installed) return
    runViewer(["launch"], "Opening Lab", true)
  }

  function terminalButtonText(action, text) {
    return busy && openingTerminalAction === action ? root.t("lab.openingTerminal") : text
  }

  function actionFailedToStart() {
    if (!actionProc.running && busy) {
      busy = false
      errorText = "Could not start the Lab command. Check that the plugin is installed correctly and try again."
      closeAfterAction = false
    }
  }

  function recordViewer() {
    if (busy || actionProc.running) return
    close()
    runCommand("omarchy-lab-capture", ["record", "10", "--copy"], "Recording")
  }

  function setResourceProfile(profile, label) {
    customResourcesDirty = false
    runCommand("omarchy-lab-resource", ["set", profile], label + " resources")
  }

  function applyCustomResources() {
    customResourcesDirty = false
    runCommand("omarchy-lab-resource", ["set", "custom", String(customResourceCpus), String(customResourceMemoryGiB)], "Custom resources")
  }

  function armOrRun(key, command, args, label) {
    if (armedAction !== key) {
      armedAction = key
      confirmTimer.restart()
      actionOutput = "Select Confirm " + label + " within five seconds."
    } else {
      runCommand(command, args, label)
    }
  }

  function pageChanged(value) {
    currentPage = pageOptions.indexOf(value)
    pageScroll.contentItem.contentY = 0
    armedAction = ""
  }

  function moveCardTo(x, y) {
    var margin = Style.space(12)
    var horizontalLimit = Math.max(0, (keyCatcher.width - card.width) / 2 - margin)
    var verticalLimit = Math.max(0, (keyCatcher.height - card.height) / 2 - margin)
    cardOffsetX = Math.max(-horizontalLimit, Math.min(horizontalLimit, x))
    cardOffsetY = Math.max(-verticalLimit, Math.min(verticalLimit, y))
  }

  function moveCardBy(x, y) {
    moveCardTo(cardOffsetX + x, cardOffsetY + y)
  }

  function centerCard() {
    cardOffsetX = 0
    cardOffsetY = 0
  }

  function constrainCard() {
    if (!opened || keyCatcher.width <= 0 || keyCatcher.height <= 0) return
    moveCardTo(cardOffsetX, cardOffsetY)
  }

  Process {
    id: viewerStatusProc
    command: [root.viewerCommand, "status", "--json"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.status = Model.parseStatus(text) }
  }

  Process {
    id: healthProc
    command: [root.labCommand("omarchy-lab-health"), "--json"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.healthRaw = String(text || "") }
  }

  Process {
    id: branchListProc
    command: [root.labCommand("omarchy-lab-checkout"), "branches", "--json"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.branches = Model.branchOptions(text)
        var selectionFound = false
        for (var i = 0; i < root.branches.length; i++) {
          if (root.branches[i].value === root.selectedBranch) selectionFound = true
        }
        if (root.branches.length === 0) root.selectedBranch = ""
        else if (!selectionFound) root.selectedBranch = root.branches[0].value
      }
    }
  }

  Process {
    id: checkoutStatusProc
    command: [root.labCommand("omarchy-lab-checkout"), "status", "--json"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.deploymentRaw = String(text || "") }
  }

  Process {
    id: checkpointListProc
    command: [root.labCommand("omarchy-lab-checkpoint"), "list", "--json"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.checkpoints = Model.checkpointOptions(text)
        if (root.checkpoints.length === 0) root.selectedCheckpoint = ""
        else if (root.selectedCheckpoint === "") root.selectedCheckpoint = root.checkpoints[0].value
      }
    }
  }

  Process {
    id: networkStatusProc
    command: [root.labCommand("omarchy-lab-network"), "status", "--json"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.networkRaw = String(text || "") }
  }

  Process {
    id: resourceStatusProc
    command: [root.labCommand("omarchy-lab-resource"), "status", "--json"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var parsed = Model.parseResources(text)
        root.resources = parsed
        root.resourceRaw = String(text || "")
        if (parsed.available && !root.customResourcesDirty) {
          root.customResourceCpus = parsed.cpus.configured
          root.customResourceMemoryGiB = Model.memoryGiB(parsed.memory.configuredBytes)
        }
      }
    }
  }

  Process {
    id: goldStatusProc
    command: [root.labCommand("omarchy-lab-gold"), "status", "--json"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.goldRaw = String(text || "") }
  }

  Process {
    id: artifactListProc
    command: [root.labCommand("omarchy-lab-capture"), "list", "--json"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.artifactRaw = String(text || "") }
  }

  Process {
    id: scenarioListProc
    command: [root.labCommand("omarchy-lab-scenario"), "list", "--json"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.scenarios = Model.scenarioOptions(text)
        if (root.scenarios.length > 0 && root.selectedScenario === "") root.selectedScenario = root.scenarios[0].value
      }
    }
  }

  Process {
    id: actionProc
    onRunningChanged: {
      if (!running) Qt.callLater(root.actionFailedToStart)
    }
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.actionOutput = String(text || "").trim() }
    stderr: StdioCollector { waitForEnd: true; onStreamFinished: root.stderrText = String(text || "").trim() }
    onExited: function(exitCode) {
      root.busy = false
      if (exitCode !== 0) root.errorText = root.stderrText || root.actionLabel + " failed"
      else if (root.closeAfterAction) root.dismiss()
      root.closeAfterAction = false
      refreshDelay.restart()
    }
  }

  Timer { id: refreshTimer; interval: 5000; repeat: true; running: root.opened && !root.busy; onTriggered: root.refreshAll() }
  Timer { id: refreshDelay; interval: 600; onTriggered: root.refreshAll() }
  Timer { id: confirmTimer; interval: 5000; onTriggered: root.armedAction = "" }

  PanelWindow {
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "omarchy-lab-controls"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Shortcut { sequence: "Escape"; enabled: root.opened; onActivated: root.dismiss() }
    Shortcut { sequence: "Ctrl+Left"; enabled: root.opened; onActivated: root.pageChanged(root.pageOptions[Math.max(0, root.currentPage - 1)]) }
    Shortcut { sequence: "Ctrl+Right"; enabled: root.opened; onActivated: root.pageChanged(root.pageOptions[Math.min(root.pageOptions.length - 1, root.currentPage + 1)]) }
    Shortcut { sequence: "Ctrl+R"; enabled: root.opened; onActivated: root.refreshAll() }
    Shortcut { sequence: "Alt+Left"; enabled: root.opened; onActivated: root.moveCardBy(-Style.space(40), 0) }
    Shortcut { sequence: "Alt+Right"; enabled: root.opened; onActivated: root.moveCardBy(Style.space(40), 0) }
    Shortcut { sequence: "Alt+Up"; enabled: root.opened; onActivated: root.moveCardBy(0, -Style.space(40)) }
    Shortcut { sequence: "Alt+Down"; enabled: root.opened; onActivated: root.moveCardBy(0, Style.space(40)) }
    Shortcut { sequence: "Alt+Home"; enabled: root.opened; onActivated: root.centerCard() }

    Rectangle {
      anchors.fill: parent
      color: Commons.Color.menu.scrim
      MouseArea { anchors.fill: parent; onClicked: root.dismiss() }
    }

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: true
      onWidthChanged: Qt.callLater(function() { root.constrainCard() })
      onHeightChanged: Qt.callLater(function() { root.constrainCard() })

      BorderSurface {
        id: card
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: root.cardOffsetX
        anchors.verticalCenterOffset: root.cardOffsetY
        width: Math.min(parent.width - Style.space(24), Style.space(960))
        height: Math.min(parent.height - Style.space(24), cardContent.implicitHeight + Style.space(40))
        color: Commons.Color.popups.background
        radius: Style.cornerRadius
        borderSpec: Border.surfaceSpec("popups", "border", Commons.Color.popups.border, Math.max(1, Style.normalBorderWidth))
        MouseArea { anchors.fill: parent; onClicked: {} }

        Behavior on height {
          NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
        }
        onHeightChanged: Qt.callLater(function() { root.constrainCard() })

        ColumnLayout {
          id: cardContent
          anchors.fill: parent
          anchors.margins: Style.space(20)
          spacing: Style.space(12)

          RowLayout {
            id: headerRow
            Layout.fillWidth: true
            spacing: Style.space(12)
            DragHandler {
              target: null
              acceptedButtons: Qt.LeftButton
              onTranslationChanged: function(delta) { root.moveCardBy(delta.x, delta.y) }
            }
            Text { textFormat: Text.PlainText; text: "󰆧"; color: Commons.Color.accent; font.family: Style.font.family; font.pixelSize: Style.font.display }
            ColumnLayout {
              spacing: Style.space(2)
              Text { textFormat: Text.PlainText; text: I18n.t("lab.omarchyLab"); color: root.foreground; font.family: Style.font.family; font.pixelSize: Style.font.title; font.bold: true }
              Text { text: Model.statusText(root.status, root.t); textFormat: Text.PlainText; color: root.dim; font.family: Style.font.family; font.pixelSize: Style.font.bodySmall }
            }
            Item { Layout.fillWidth: true }
            RowLayout {
              spacing: Style.space(4)
              Button {
                iconText: "󰑐"
                tooltipText: I18n.t("lab.refreshLabStatus")
                focusable: true
                foreground: root.foreground
                background: "transparent"
                horizontalPadding: Style.spacing.controlGap
                verticalPadding: Style.spacing.labelGap
                Accessible.role: Accessible.Button
                Accessible.name: tooltipText
                enabled: !root.busy
                onClicked: root.refreshAll()
              }
              Button {
                iconText: "󰅖"
                tooltipText: I18n.t("lab.closeLabControls")
                focusable: true
                foreground: root.foreground
                background: "transparent"
                horizontalPadding: Style.spacing.controlGap
                verticalPadding: Style.spacing.labelGap
                Accessible.role: Accessible.Button
                Accessible.name: tooltipText
                onClicked: root.dismiss()
              }
            }
          }

          ButtonGroup {
            Layout.alignment: Qt.AlignHCenter
            options: root.pageOptions.map(function(value) { return {value: value, label: root.displayText(value)} })
            value: root.pageOptions[root.currentPage]
            foreground: root.foreground
            background: "transparent"
            onChanged: function(value) { root.pageChanged(value) }
          }

          Text { visible: root.errorText !== "" && !root.inlineInstallError; text: root.displayText(root.errorText); textFormat: Text.PlainText; color: Commons.Color.urgent; font.family: Style.font.family; font.pixelSize: Style.font.bodySmall; wrapMode: Text.WordWrap; Layout.fillWidth: true }

          QQC.ScrollView {
            id: pageScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: root.currentPageHeight
            Layout.maximumHeight: root.currentPageHeight
            Layout.minimumHeight: Math.min(root.currentPageHeight, Style.space(120))
            clip: true
            QQC.ScrollBar.horizontal.policy: QQC.ScrollBar.AlwaysOff

            ColumnLayout {
              width: pageScroll.availableWidth
              spacing: Style.space(12)

              ColumnLayout {
                id: consolePage
                visible: root.currentPage === 0
                Layout.fillWidth: true
                spacing: Style.space(12)

                ActionButton {
                  visible: root.status.installed
                  text: root.busy && root.actionLabel === "Opening Lab" ? I18n.t("lab.openingLabLabel") : I18n.t("lab.openLab") // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                  onClicked: root.openLab()
                }

                WorkbenchSection {
                  visible: !root.status.installed
                  title: I18n.t("lab.installTheGuest")
                  subtitle: I18n.t("lab.createsADisposableVMATerminalOpensForSetupAndAuthentication")
                  ActionButton {
                    text: root.installerOpening ? I18n.t("lab.openingInstallerLabel") : I18n.t("lab.installLabVM")
                    onClicked: root.openInstaller()
                  }
                  Text {
                    Layout.fillWidth: true
                    visible: root.inlineInstallError
                    text: root.errorText
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                    color: Commons.Color.urgent
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                  }
                }

                WorkbenchSection {
                  title: I18n.t("lab.aspectRatio")
                  subtitle: I18n.t("lab.resizeTheGuestAndViewerTogether")
                  ButtonGroup { Layout.fillWidth: true; options: root.aspectOptions; value: root.status.aspect; foreground: root.foreground; background: "transparent"; onChanged: function(value) { root.runViewer(["aspect", value], "Aspect ratio") } }
                }

                WorkbenchSection {
                  title: I18n.t("lab.zoom")
                  subtitle: I18n.t("lab.scaleContentWhilePreservingItsShape")
                  ButtonGroup { Layout.fillWidth: true; options: root.zoomOptions.map(function(value) { return { value: value, label: value + "%" } }); value: String(root.status.zoom); foreground: root.foreground; background: "transparent"; onChanged: function(value) { root.runViewer(["set", "zoom", value], I18n.t("lab.zoom")) } }
                }

                WorkbenchSection {
                  title: I18n.t("lab.viewer")
                  subtitle: I18n.t("lab.preferencesPersistBetweenSessions")
                  GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: Style.space(8)
                    rowSpacing: Style.space(8)
                    ActionButton { text: I18n.t("lab.autoResize"); selected: root.status.autoResize; onClicked: root.runViewer(["set", "auto-resize", root.status.autoResize ? "false" : "true"], "Auto resize") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: I18n.t("lab.localCursor"); selected: root.status.cursor === "local"; onClicked: root.runViewer(["set", "cursor", root.status.cursor === "local" ? "auto" : "local"], "Cursor") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: I18n.t("lab.audio"); selected: root.status.audio; onClicked: root.runViewer(["set", "audio", root.status.audio ? "false" : "true"], "Audio") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: I18n.t("lab.uSB"); selected: root.status.usbRedirection; onClicked: root.runViewer(["set", "usb-redirection", root.status.usbRedirection ? "false" : "true"], "USB redirection") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: I18n.t("lab.keepInBar"); selected: root.status.keepInBar; onClicked: root.runViewer(["set", "keep-in-bar", root.status.keepInBar ? "false" : "true"], "Menu bar pin") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                  }
                }

                WorkbenchSection {
                  title: I18n.t("lab.consoleActions")
                  subtitle: I18n.t("lab.resetRequiresASecondConfirmation")
                  GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    columnSpacing: Style.space(8)
                    rowSpacing: Style.space(8)
                    ActionButton { text: I18n.t("lab.fullscreen"); onClicked: root.runViewer(["fullscreen"], "Fullscreen") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: I18n.t("lab.screenshot"); onClicked: root.runViewer(["screenshot"], "Screenshot") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: I18n.t("lab.reboot"); onClicked: root.runViewer(["reboot"], "Reboot") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: I18n.t("lab.stop"); danger: true; onClicked: root.runViewer(["stop"], "Stop", true) } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: root.terminalButtonText("reset", root.armedAction === "reset" ? I18n.t("lab.confirmReset") : I18n.t("lab.reset")); danger: true; onClicked: root.armOrRun("reset", root.viewerCommand, ["reset"], "reset") }
                  }
                }
              }

              ColumnLayout {
                id: developPage
                visible: root.currentPage === 1
                Layout.fillWidth: true
                spacing: Style.space(12)

                WorkbenchSection {
                  title: I18n.t("lab.healthDashboard")
                  subtitle: root.healthSummary
                  RowLayout {
                    Layout.fillWidth: true
                    ActionButton { text: I18n.t("lab.refreshHealth"); onClicked: root.startProcess(healthProc) }
                    ActionButton { text: I18n.t("lab.diagnostics"); onClicked: root.runCommand("omarchy-lab-capture", ["bundle"], "Diagnostic bundle") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                  }
                }

                WorkbenchSection {
                  title: I18n.t("lab.branchDeployment")
                  subtitle: root.deploymentSummary
                  SearchableDropdown {
                    id: branchDropdown
                    Layout.fillWidth: true
                    showLabel: false
                    placeholderText: I18n.t("lab.searchLocalBranches")
                    emptyText: I18n.t("lab.noLocalBranches")
                    triggerLabel: I18n.t("lab.chooseALocalBranch")
                    options: root.branches
                    value: root.selectedBranch
                    foreground: root.foreground
                    background: Commons.Color.popups.background
                    onChanged: function(value) { root.selectedBranch = value }
                  }
                  RowLayout {
                    Layout.fillWidth: true
                    ActionButton { text: I18n.t("lab.deployBranchReboot"); enabled: !root.busy && root.selectedBranch !== ""; onClicked: root.runCommand("omarchy-lab-checkout", ["deploy", "--branch", root.selectedBranch], "Deploy branch") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: I18n.t("lab.syncBranch"); onClicked: root.runCommand("omarchy-lab-checkout", ["sync"], "Sync branch") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                  }
                }

                WorkbenchSection {
                  title: I18n.t("lab.namedCheckpoints")
                  subtitle: I18n.t("lab.savedCheckpoints").arg(root.checkpoints.length)
                  RowLayout {
                    Layout.fillWidth: true
                    TextField { id: checkpointNameField; Layout.fillWidth: true; placeholderText: "checkpoint name"; foreground: root.foreground; accent: Commons.Color.accent }
                    ActionButton { Layout.fillWidth: false; text: I18n.t("lab.create"); onClicked: root.runCommand("omarchy-lab-checkpoint", ["create"].concat(checkpointNameField.text === "" ? [] : [checkpointNameField.text]), "Create checkpoint") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                  }
                  Dropdown { id: checkpointDropdown; Layout.fillWidth: true; showLabel: false; options: root.checkpoints; value: root.selectedCheckpoint; foreground: root.foreground; background: Commons.Color.popups.background; onChanged: function(value) { root.selectedCheckpoint = value } }
                  RowLayout {
                    Layout.fillWidth: true
                    TextField { id: checkpointRenameField; Layout.fillWidth: true; placeholderText: "new name"; foreground: root.foreground; accent: Commons.Color.accent }
                    ActionButton { Layout.fillWidth: false; text: I18n.t("lab.rename"); enabled: !root.busy && root.selectedCheckpoint !== "" && checkpointRenameField.text !== ""; onClicked: root.runCommand("omarchy-lab-checkpoint", ["rename", root.selectedCheckpoint, checkpointRenameField.text], "Rename checkpoint") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { Layout.fillWidth: false; text: root.armedAction === "restore" ? I18n.t("lab.confirmRestore") : I18n.t("lab.restore"); danger: true; enabled: !root.busy && root.selectedCheckpoint !== ""; onClicked: root.armOrRun("restore", "omarchy-lab-checkpoint", ["restore", root.selectedCheckpoint, "--yes"], "restore") }
                    ActionButton { Layout.fillWidth: false; text: root.armedAction === "delete-checkpoint" ? I18n.t("lab.confirmDelete") : I18n.t("lab.delete"); danger: true; enabled: !root.busy && root.selectedCheckpoint !== ""; onClicked: root.armOrRun("delete-checkpoint", "omarchy-lab-checkpoint", ["delete", root.selectedCheckpoint, "--yes"], "delete") }
                  }
                }
              }

              ColumnLayout {
                id: environmentPage
                visible: root.currentPage === 2
                Layout.fillWidth: true
                spacing: Style.space(12)

                WorkbenchSection {
                  title: I18n.t("lab.networkMode")
                  subtitle: root.networkSummary
                  RowLayout {
                    Layout.fillWidth: true
                    ActionButton { text: I18n.t("lab.nAT"); onClicked: root.runCommand("omarchy-lab-network", ["nat"], "NAT network") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: I18n.t("lab.isolated"); onClicked: root.runCommand("omarchy-lab-network", ["isolated"], "Isolated network") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: I18n.t("lab.offline"); danger: true; onClicked: root.runCommand("omarchy-lab-network", ["offline"], "Offline network") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                  }
                }

                WorkbenchSection {
                  title: I18n.t("lab.resourceProfile")
                  subtitle: I18n.t("lab.currentResources").arg(root.resourceSummary)
                  Text {
                    Layout.fillWidth: true
                    text: Model.resourceLimitsText(root.resources, root.t, I18n.formatNumber)
                    textFormat: Text.PlainText
                    color: root.dim
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                  }
                  GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: Style.space(8)
                    rowSpacing: Style.space(8)
                    ActionButton {
                      text: I18n.t("lab.lightResourcesDescription").arg(root.lightResources.cpus).arg(root.lightResources.memoryGiB)
                      tooltipText: I18n.t("lab.forQuickChecksAndLightweightTesting")
                      selected: root.resources.profile === "light"
                      enabled: root.resources.available && !root.busy
                      onClicked: root.setResourceProfile("light", "Light")
                    }
                    ActionButton {
                      text: I18n.t("lab.balancedResourcesDescription").arg(root.balancedResources.cpus).arg(root.balancedResources.memoryGiB)
                      tooltipText: I18n.t("lab.recommendedForMostDevelopmentAndUITesting")
                      selected: root.resources.profile === "balanced"
                      enabled: root.resources.available && !root.busy
                      onClicked: root.setResourceProfile("balanced", "Balanced")
                    }
                    ActionButton {
                      text: I18n.t("lab.performanceResourcesDescription").arg(root.performanceResources.cpus).arg(root.performanceResources.memoryGiB)
                      tooltipText: I18n.t("lab.extraRoomForHeavierBuildsAndMultitasking")
                      selected: root.resources.profile === "performance"
                      enabled: root.resources.available && !root.busy
                      onClicked: root.setResourceProfile("performance", "Performance")
                    }
                    ActionButton {
                      text: I18n.t("lab.fullResourcesDescription").arg(root.fullResources.cpus).arg(root.fullResources.memoryGiB)
                      tooltipText: I18n.t("lab.highPerformanceLabAllocationCustomCanGoHigher")
                      selected: root.resources.profile === "full"
                      enabled: root.resources.available && !root.busy
                      onClicked: root.setResourceProfile("full", "Full")
                    }
                  }
                  RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.space(12)
                    NumberField {
                      id: customCpuField
                      Layout.fillWidth: true
                      Layout.alignment: Qt.AlignBottom
                      fieldWidth: width
                      label: I18n.t("lab.cpuRange").arg(root.maximumResourceCpus)
                      from: 1
                      to: root.maximumResourceCpus
                      value: root.customResourceCpus
                      enabled: root.resources.available && !root.busy
                      foreground: root.foreground
                      accent: Commons.Color.accent
                      fontFamily: Style.font.family
                      onModified: function(value) {
                        root.customResourceCpus = value
                        root.customResourcesDirty = true
                      }
                    }
                    NumberField {
                      id: customMemoryField
                      Layout.fillWidth: true
                      Layout.alignment: Qt.AlignBottom
                      fieldWidth: width
                      label: I18n.t("lab.memoryRange").arg(root.maximumResourceMemoryGiB)
                      from: 1
                      to: root.maximumResourceMemoryGiB
                      value: root.customResourceMemoryGiB
                      enabled: root.resources.available && !root.busy
                      foreground: root.foreground
                      accent: Commons.Color.accent
                      fontFamily: Style.font.family
                      onModified: function(value) {
                        root.customResourceMemoryGiB = value
                        root.customResourcesDirty = true
                      }
                    }
                    ActionButton {
                      Layout.fillWidth: false
                      Layout.alignment: Qt.AlignBottom
                      text: I18n.t("lab.applyCustom")
                      selected: root.resources.profile === "custom" && !root.customResourcesDirty
                      enabled: root.resources.available && !root.busy
                      onClicked: root.applyCustomResources()
                    }
                  }
                }

                WorkbenchSection {
                  title: I18n.t("lab.goldImage")
                  subtitle: root.goldSummary
                  RowLayout {
                    Layout.fillWidth: true
                    ActionButton { text: root.terminalButtonText("promote", root.armedAction === "promote" ? I18n.t("lab.confirmPromote") : I18n.t("lab.promoteCurrent")); danger: true; onClicked: root.armOrRun("promote", "omarchy-lab-gold", ["promote", "--yes"], "promote") }
                    ActionButton { text: root.terminalButtonText("rebuild", root.armedAction === "rebuild" ? I18n.t("lab.confirmRebuild") : I18n.t("lab.rebuildFromISO")); danger: true; onClicked: root.armOrRun("rebuild", "omarchy-lab-gold", ["rebuild", "--yes"], "rebuild") }
                  }
                }
              }

              ColumnLayout {
                id: capturePage
                visible: root.currentPage === 3
                Layout.fillWidth: true
                spacing: Style.space(12)

                WorkbenchSection {
                  title: I18n.t("lab.artifactCapture")
                  subtitle: root.artifactSummary
                  GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    columnSpacing: Style.space(8)
                    rowSpacing: Style.space(8)
                    ActionButton { text: I18n.t("lab.screenshot"); onClicked: root.runCommand("omarchy-lab-capture", ["screenshot", "--copy"], "Screenshot") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: I18n.t("lab.record10s"); onClicked: root.recordViewer() }
                    ActionButton { text: I18n.t("lab.diagnostics"); onClicked: root.runCommand("omarchy-lab-capture", ["bundle", "--copy"], "Diagnostic bundle") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: I18n.t("lab.compareLatest"); onClicked: root.runCommand("omarchy-lab-capture", ["compare", "--copy"], "Screenshot comparison") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                  }
                }

                WorkbenchSection {
                  title: I18n.t("lab.clipboardAndFiles")
                  subtitle: I18n.t("lab.explicitOneShotTransfersNoSharedHostFolders")
                  GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: Style.space(8)
                    rowSpacing: Style.space(8)
                    ActionButton { text: I18n.t("lab.hostClipboardGuest"); onClicked: root.runCommand("omarchy-lab-transfer", ["clipboard-to", "--host"], "Send clipboard") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: I18n.t("lab.guestClipboardHost"); onClicked: root.runCommand("omarchy-lab-transfer", ["clipboard-from", "--copy"], "Receive clipboard") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: I18n.t("lab.chooseFilesGuest"); onClicked: root.runCommand("omarchy-lab-transfer", ["pick-to"], "Send files") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: I18n.t("lab.guestDownloadsHost"); onClicked: root.runCommand("omarchy-lab-transfer", ["pull-downloads"], "Pull Downloads") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                  }
                }
              }

              ColumnLayout {
                id: automatePage
                visible: root.currentPage === 4
                Layout.fillWidth: true
                spacing: Style.space(12)

                WorkbenchSection {
                  title: I18n.t("lab.guestShortcuts")
                  subtitle: I18n.t("lab.driveTheGraphicalSessionWithoutTouchingTheConsole")
                  GridLayout {
                    Layout.fillWidth: true
                    columns: 3
                    columnSpacing: Style.space(8)
                    rowSpacing: Style.space(8)
                    ActionButton { text: I18n.t("lab.terminal"); onClicked: root.runCommand("omarchy-lab-action", ["terminal"], "Open terminal") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: I18n.t("lab.launcher"); onClicked: root.runCommand("omarchy-lab-action", ["launcher"], "Open launcher") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: I18n.t("lab.lock"); onClicked: root.runCommand("omarchy-lab-action", ["lock"], "Lock guest") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: I18n.t("lab.wake"); onClicked: root.runCommand("omarchy-lab-action", ["wake"], "Wake guest") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: I18n.t("lab.restartShell"); onClicked: root.runCommand("omarchy-lab-action", ["restart-shell"], "Restart shell") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                    ActionButton { text: I18n.t("lab.reloadHyprland"); onClicked: root.runCommand("omarchy-lab-action", ["reload-hyprland"], "Reload Hyprland") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                  }
                  RowLayout {
                    Layout.fillWidth: true
                    TextField { id: guestCommandField; Layout.fillWidth: true; placeholderText: "graphical-session command"; foreground: root.foreground; accent: Commons.Color.accent }
                    ActionButton { Layout.fillWidth: false; text: I18n.t("lab.run"); enabled: !root.busy && guestCommandField.text !== ""; onClicked: root.runCommand("omarchy-lab-vm", ["session", guestCommandField.text], "Guest command") } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                  }
                }

                WorkbenchSection {
                  title: I18n.t("lab.scenarioRunner")
                  subtitle: I18n.t("lab.validatedCommandArraysShellStringsAreNeverEvaluated")
                  Dropdown { id: scenarioDropdown; Layout.fillWidth: true; showLabel: false; options: root.scenarios; value: root.selectedScenario; foreground: root.foreground; background: Commons.Color.popups.background; onChanged: function(value) { root.selectedScenario = value } }
                  RowLayout {
                    Layout.fillWidth: true
                    ActionButton { text: I18n.t("lab.runScenario"); enabled: !root.busy && root.selectedScenario !== "" && (root.selectedScenario !== "checkpoint-deploy" || root.selectedBranch !== ""); onClicked: root.runCommand("omarchy-lab-scenario", ["run", root.selectedScenario].concat(root.selectedScenario === "checkpoint-deploy" ? [root.selectedBranch, "--branch"] : []), "Scenario " + root.selectedScenario) } // i18n: ignore — event labels and comparisons are internal English state; display text uses t()
                  }
                }
              }
            }
          }

          Text { visible: root.busy || root.actionOutput !== ""; text: root.busy ? root.displayText(root.actionLabel) + "…" : root.displayText(root.actionOutput); textFormat: Text.PlainText; color: root.busy ? Commons.Color.accent : root.dim; font.family: Style.font.family; font.pixelSize: Style.font.caption; elide: Text.ElideMiddle; maximumLineCount: 2; wrapMode: Text.Wrap; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter }
          Text { textFormat: Text.PlainText; text: I18n.t("lab.dragHeaderAltArrowsMoveAltHomeCentersCtrlPagesEscCloses"); color: root.dim; font.family: Style.font.family; font.pixelSize: Style.font.caption; Layout.alignment: Qt.AlignHCenter }
        }
      }
    }
  }

  component WorkbenchSection: BorderSurface {
    required property string title
    required property string subtitle
    default property alias sectionContent: sectionBody.data
    Layout.fillWidth: true
    implicitHeight: sectionColumn.implicitHeight + Style.space(24)
    color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.035)
    radius: Style.cornerRadius
    borderSpec: Border.flat(Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.10), 1)

    ColumnLayout {
      id: sectionColumn
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.margins: Style.space(12)
      spacing: Style.space(8)

      RowLayout {
        Layout.fillWidth: true
        Text { text: parent.parent.parent.title; textFormat: Text.PlainText; color: root.foreground; font.family: Style.font.family; font.pixelSize: Style.font.subtitle; font.bold: true }
        Text { Layout.fillWidth: true; text: parent.parent.parent.subtitle; textFormat: Text.PlainText; color: root.dim; font.family: Style.font.family; font.pixelSize: Style.font.caption; elide: Text.ElideMiddle; horizontalAlignment: Text.AlignRight }
      }
      ColumnLayout { id: sectionBody; Layout.fillWidth: true; spacing: Style.space(8) }
    }
  }

  component ActionButton: Button {
    property bool danger: false
    Layout.fillWidth: true
    focusable: true
    bordered: true
    foreground: danger ? Commons.Color.urgent : root.foreground
    background: "transparent"
    enabled: !root.busy
  }
}
