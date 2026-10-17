import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Ui
import qs.Commons
import qs.Commons as Commons
import "ArrangementModel.js" as Model

Column {
  id: root

  property bool active: false
  property int displayCount: 0
  property bool expanded: false
  property bool showPresets: false
  property color foreground: Commons.Color.popups.text
  property string fontFamily: Style.font.family
  property var backendCommand: ["python3", Quickshell.env("OMARCHY_PATH") + "/default/hypr/monitor-position.py"]
  property var monitors: []
  property var preview: []
  property var snapshot: []
  property var pendingPositions: null
  property bool keyboardEditing: false
  property string dragging: ""
  property var dragOrigin: null
  property var dragBounds: null
  property real dragFit: 1
  property real dragX: 0
  property real dragY: 0
  property var dragCandidate: null
  property bool dragMoved: false
  property string moving: ""
  property string reference: ""
  property string side: ""
  property string alignment: "top"
  property string message: "Connect and enable at least two screens to arrange them." // i18n: ignore; IPC stores English state
  property bool error: false
  property bool busy: false
  property bool refreshQueued: false
  property string requestAction: ""
  property bool preserveMessage: false
  property int cursorIndex: -1
  property bool identifying: false
  property bool connected: true
  property var identificationScreens: Quickshell.screens
  readonly property bool popupOpen: movingPicker.popupOpen || referencePicker.popupOpen || alignmentPicker.popupOpen
  readonly property bool coordinateEditing: xField.field.activeFocus || xField.field.contentItem.activeFocus
                                           || yField.field.activeFocus || yField.field.contentItem.activeFocus
  readonly property bool ready: active && visible && expanded && !busy && monitors.length >= 2
  readonly property bool canApply: ready && connected && preview.length > 0 && Model.changed(monitors, preview)
  readonly property var shownMonitors: preview.length ? preview : monitors
  readonly property var selectedMonitor: shownMonitors.filter(function(m) { return m.name === root.moving })[0] || null
  readonly property var layoutBounds: dragging ? dragBounds : Model.bounds(shownMonitors)
  readonly property var screenOptions: monitors.map(function(m) { return m.name })
  readonly property var referenceOptions: screenOptions.filter(function(name) { return name !== root.moving })
  readonly property var presetTranslations: ({
    left: Commons.I18n.t("monitor.arrangementPreviewLeft", "%1 left of %2, aligned %3. Preview only."),
    right: Commons.I18n.t("monitor.arrangementPreviewRight", "%1 right of %2, aligned %3. Preview only."),
    above: Commons.I18n.t("monitor.arrangementPreviewAbove", "%1 above %2, aligned %3. Preview only."),
    below: Commons.I18n.t("monitor.arrangementPreviewBelow", "%1 below %2, aligned %3. Preview only.")
  })
  readonly property var placementLabels: ({left: Commons.I18n.t("monitor.arrangeLeft", "Left"), right: Commons.I18n.t("monitor.arrangeRight", "Right"), above: Commons.I18n.t("monitor.arrangeAbove", "Above"), below: Commons.I18n.t("monitor.arrangeBelow", "Below"), top: Commons.I18n.t("monitor.arrangeTop", "Top"), center: Commons.I18n.t("monitor.arrangeCenter", "Center"), bottom: Commons.I18n.t("monitor.arrangeBottom", "Bottom")})
  readonly property var statusTranslations: ({"Connect and enable at least two screens to arrange them.": Commons.I18n.t("monitor.arrangementTwoScreens", "Connect and enable at least two screens to arrange them."), "Reading screens…": Commons.I18n.t("monitor.arrangementReading", "Reading screens…"), "Applying layout…": Commons.I18n.t("monitor.arrangementSaving", "Applying layout…"), "Choose a position to preview. Apply saves the layout.": Commons.I18n.t("monitor.arrangementChoosePosition", "Choose a position to preview. Apply saves the layout."), "Changes discarded. Drag screens to match your desk.": Commons.I18n.t("monitor.arrangementDiscarded", "Changes discarded. Drag screens to match your desk."), "Place the screen against another edge without overlapping.": Commons.I18n.t("monitor.arrangementTouchEdge", "Place the screen against another edge without overlapping."), "Screens cannot overlap.": Commons.I18n.t("monitor.arrangementOverlap", "Screens cannot overlap."), "Unsaved arrangement. Apply layout to save it.": Commons.I18n.t("monitor.arrangementUnsaved", "Unsaved arrangement. Apply layout to save it."), "Drag screens to match your desk. Apply saves the layout.": Commons.I18n.t("monitor.arrangementDragHint", "Drag screens to match your desk. Apply saves the layout."), "Some screens are disconnected. Move them against the layout before applying.": Commons.I18n.t("monitor.arrangementDisconnected", "Some screens are disconnected. Move them against the layout before applying."), "Some screens are disconnected. Arrange them against a shared edge.": Commons.I18n.t("monitor.arrangementExistingGaps", "Some screens are disconnected. Arrange them against a shared edge."), "Layout saved for next time.": Commons.I18n.t("monitor.arrangementSaved", "Layout saved for next time.")})
  readonly property var sides: ["left", "right", "above", "below"]
  readonly property var alignmentOptions: side === "above" || side === "below"
    ? ["left", "center", "right"] : ["top", "center", "bottom"]

  readonly property var navigationItems: !expanded ? [sectionButton] : [sectionButton, identifyButton, diagram, applyButton, discardButton, refreshButton, presetsButton].concat(
    showPresets ? [movingPicker, referencePicker, xField, yField, directionButtons.itemAt(0), directionButtons.itemAt(1), directionButtons.itemAt(2), directionButtons.itemAt(3), alignmentPicker] : [])
  readonly property int navigationCount: navigationItems.length

  function displayLabel(monitor) {
    return /^(eDP|LVDS|DSI)/.test(monitor.name) ? Commons.I18n.t("monitor.arrangementBuiltin", "Built-in display") : monitor.label
  }

  function displayMessage() {
    var preset = message.match(/^(.+) (left|right|above|below) of (.+), aligned (top|center|bottom|left|right)\. Preview only\.$/)
    return preset ? presetTranslations[preset[2]].arg(preset[1]).arg(preset[3]).arg(placementLabels[preset[4]])
      : statusTranslations[message] || message
  }

  function indexOf(item) { return navigationItems.indexOf(item) }

  signal cursorRequested(int index, var item)
  signal applied()
  signal coordinateEditingFinished()

  spacing: Style.space(10)
  visible: displayCount > 1
  onCursorIndexChanged: {
    var item = navigationItems[cursorIndex]
    if (keyboardEditing && item !== diagram) finishKeyboardEditing()
    if (item) cursorRequested(cursorIndex, item)
  }
  onActiveChanged: {
    if (active && visible && expanded) refresh()
    else closeControls()
  }
  onVisibleChanged: if (!visible) expanded = false
  onExpandedChanged: {
    if (active && visible && expanded) refresh()
    else closeControls()
  }

  function closeControls() {
    movingPicker.close()
    referencePicker.close()
    alignmentPicker.close()
    xField.field.focus = false
    yField.field.focus = false
    xField.field.contentItem.focus = false
    yField.field.contentItem.focus = false
    identifying = false
    identifyTimer.stop()
    keyboardEditing = false
    dragging = ""
  }

  function request(action, preserve) {
    if (busy) return
    requestAction = action
    preserveMessage = !!preserve
    error = preserve ? error : false
    busy = true
    if (!preserve) message = action === "apply" ? "Applying layout…" : "Reading screens…"
    var payload = { action: action }
    if (action !== "state") {
      payload.positions = action === "apply" ? Model.positions(preview) : pendingPositions
      payload.snapshot = snapshot
    }
    backend.command = backendCommand.concat(["--request", JSON.stringify(payload)])
    backend.running = true
  }

  function refresh(preserve) {
    if (!active || !visible || !expanded) return
    if (busy) { refreshQueued = true; return }
    preview = []
    side = ""
    alignment = "top"
    request("state", preserve)
  }

  function invalidate() {
    if (busy) { refreshQueued = true; return }
    preview = []
    side = ""
    alignment = "top"
    dragging = ""
    keyboardEditing = false
    if (active) refresh()
  }

  function selectScreen(name) {
    if (!ready || screenOptions.indexOf(name) < 0) return
    moving = name
    var selected = Model.pair(monitors, moving, reference === name ? "" : reference)
    // Keep the clicked screen as the moving one, even when it was the reference.
    reference = selected.reference === moving ? referenceOptions[0] || "" : selected.reference
    side = ""
    error = false
  }

  function clearPreview() {
    preview = []
    connected = Model.connected(monitors)
    side = ""
    alignment = "top"
    error = false
    message = "Choose a position to preview. Apply saves the layout."
  }

  function discard() {
    if (!ready) return
    clearPreview()
    keyboardEditing = false
    message = "Changes discarded. Drag screens to match your desk."
  }

  function chooseSide(value) {
    if (!ready || sides.indexOf(value) < 0) return
    side = value
    if (alignmentOptions.indexOf(alignment) < 0) alignment = alignmentOptions[0]
    pendingPositions = Model.positions(Model.preset(shownMonitors, moving, reference, side, alignment))
    request("preview")
  }

  function chooseAlignment(value) {
    if (!ready || side === "" || alignmentOptions.indexOf(value) < 0) return
    alignment = value
    chooseSide(side)
  }

  function finishCoordinateEditing() {
    xField.field.contentItem.focus = false
    yField.field.contentItem.focus = false
    coordinateEditingFinished()
  }

  function chooseCoordinate(axis, value) {
    if (!ready || !selectedMonitor) return
    var draft = Model.place(shownMonitors, moving, axis === "x" ? value : selectedMonitor.x,
                            axis === "y" ? value : selectedMonitor.y)
    side = ""
    pendingPositions = Model.positions(draft)
    request("preview")
  }

  function beginDrag(name, x, y) {
    if (!ready) return
    selectScreen(name)
    dragBounds = Model.bounds(shownMonitors)
    dragFit = diagram.fit
    var m = shownMonitors.filter(function(s) { return s.name === name })[0]
    dragOrigin = {x: x, y: y, screenX: m.x, screenY: m.y}
    dragX = m.x
    dragY = m.y
    dragMoved = false
    dragCandidate = null
    dragging = name
    cursorRequested(2, diagram)
  }

  function updateDrag(x, y) {
    if (!dragging) return
    var dx = x - dragOrigin.x, dy = y - dragOrigin.y
    if (Math.hypot(dx, dy) > 4) dragMoved = true
    var wantedX = dragOrigin.screenX + dx / dragFit, wantedY = dragOrigin.screenY + dy / dragFit
    dragCandidate = Model.snap(shownMonitors, dragging, wantedX, wantedY, Style.space(18) / dragFit)
    dragX = dragCandidate ? dragCandidate.x : wantedX
    dragY = dragCandidate ? dragCandidate.y : wantedY
  }

  function endDrag() {
    if (!dragging) return
    var candidate = dragCandidate, moved = dragMoved
    dragging = ""
    if (!moved) return
    if (!candidate) {
      message = "Place the screen against another edge without overlapping."
      error = true
      return
    }
    side = ""
    pendingPositions = Model.positions(candidate.layout)
    request("preview")
  }

  function nudge(dx, dy) {
    if (!ready) return
    var m = shownMonitors.filter(function(s) { return s.name === moving })[0]
    var draft = Model.place(shownMonitors, moving, m.x + dx, m.y + dy)
    if (Model.overlaps(draft)) { error = true; message = "Screens cannot overlap."; return }
    side = ""
    pendingPositions = Model.positions(draft)
    request("preview")
  }

  function finishKeyboardEditing() {
    keyboardEditing = false
    message = connected ? "Drag screens to match your desk. Apply saves the layout."
      : "Some screens are disconnected. Move them against the layout before applying."
  }

  function activate(index) {
    if (!active || !visible) return
    if (keyboardEditing) { finishKeyboardEditing(); return }
    var item = navigationItems[index]
    if (item === sectionButton) expanded = !expanded
    else if (item === identifyButton && expanded) identifyScreens()
    else if (item === diagram && ready) {
      keyboardEditing = true
      message = "Arrow keys move the selected screen one pixel. Enter finishes editing."
    }
    else if (item === presetsButton && ready) showPresets = !showPresets
    else if (item === movingPicker && ready) movingPicker.open()
    else if (item === referencePicker && ready) referencePicker.open()
    else if (item === alignmentPicker && ready && side !== "") alignmentPicker.open()
    else if ((item === xField || item === yField) && ready) { item.field.contentItem.forceActiveFocus(); item.field.contentItem.selectAll() }
    else if (item === applyButton) applyDraft()
    else if (item === discardButton) discard()
    else if (item === refreshButton) refresh()
    else {
      for (var i = 0; i < sides.length; i++)
        if (item === directionButtons.itemAt(i)) chooseSide(sides[i])
    }
  }

  function applyDraft() {
    if (canApply) {
      keyboardEditing = false
      request("apply")
    }
  }

  function identifyScreens() {
    if (!active || !visible || !expanded) return
    identifying = true
    identifyTimer.restart()
  }

  function finish(exitCode) {
    busy = false
    var action = requestAction
    if (exitCode !== 0) {
      var detail = String(backendError.text || "").trim() || "Cannot read or arrange the screens. Try Refresh."
      var keepDraft = false
      try {
        var failure = JSON.parse(detail)
        keepDraft = action === "preview" && failure.code === "invalid-layout"
        detail = failure.message
      } catch (parseError) {}
      if (!keepDraft) preview = []
      side = ""
      alignment = "top"
      if (action === "state") { monitors = []; snapshot = [] }
      if (keepDraft && preview.length > 0) detail += " Earlier draft moves are kept."
      message = preserveMessage ? message + " Refresh failed: " + detail : detail
      error = true
    } else {
      try {
        var response = JSON.parse(backendOutput.text)
        if (action === "apply") {
          message = response.message
          error = false
          preview = []
          side = ""
          alignment = "top"
          refreshQueued = true
          applied()
        } else {
          if (!Array.isArray(response.monitors) || !Array.isArray(response.snapshot)) throw new Error("Invalid display response")
          if (action === "preview") {
            preview = response.monitors
            connected = response.connected !== false
            message = !connected ? "Some screens are disconnected. Move them against the layout before applying."
              : side ? moving + " " + side + " of " + reference + ", aligned " + alignment + ". Preview only." : "Unsaved arrangement. Apply layout to save it."
          } else {
            monitors = response.monitors
            connected = response.connected !== false
            snapshot = response.snapshot
            var selected = Model.pair(monitors, moving, reference)
            moving = selected.moving
            reference = selected.reference
            if (!preserveMessage) message = monitors.length < 2
              ? "Connect and enable at least two screens to arrange them."
              : !connected ? "Some screens are disconnected. Arrange them against a shared edge."
              : "Drag screens to match your desk. Apply saves the layout."
          }
        }
      } catch (failure) {
        preview = []
        side = ""
        alignment = "top"
        monitors = []
        snapshot = []
        message = "Cannot read the display response. Try Refresh."
        error = true
      }
    }
    if (refreshQueued) {
      refreshQueued = false
      refresh(action === "apply" || error)
    }
  }

  Process {
    id: backend
    stdout: StdioCollector { id: backendOutput; waitForEnd: true }
    stderr: StdioCollector { id: backendError; waitForEnd: true }
    onExited: function(exitCode) { root.finish(exitCode) }
    // Failed-to-start emits runningChanged without exited.
    onRunningChanged: if (!running && root.busy) Qt.callLater(function() {
      if (root.busy && !backend.running) root.finish(1)
    })
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (["monitoradded", "monitoraddedv2", "monitorremoved", "configreloaded"].indexOf(event.name) >= 0)
        root.invalidate()
    }
  }

  Loader {
    active: root.identifying && root.identificationScreens.length > 0
    source: "ScreenIdentifiers.qml"
    onLoaded: {
      item.shown = Qt.binding(function() { return root.identifying })
      item.screens = Qt.binding(function() { return root.identificationScreens })
      item.monitors = Qt.binding(function() { return root.monitors })
    }
  }
  Timer { id: identifyTimer; interval: 4000; onTriggered: root.identifying = false }

  Button {
    id: sectionButton
    objectName: "arrangementToggle"
    width: parent.width
    text: Commons.I18n.t("monitor.arrangementHeading", "ARRANGEMENT")
    leftAlign: true
    foreground: root.foreground
    fontFamily: root.fontFamily
    fontSize: Style.font.caption
    hasCursor: root.cursorIndex === 0
    onClicked: root.expanded = !root.expanded
    onHovered: function(hot) { if (hot) root.cursorRequested(0, sectionButton) }
    Text {
      textFormat: Text.PlainText
      anchors.right: parent.right
      anchors.rightMargin: Style.spacing.controlPaddingX
      anchors.verticalCenter: parent.verticalCenter
      text: root.expanded ? "󰅃" : "󰅀"
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.icon
    }
  }

  Column {
    id: arrangementBody
    width: parent.width
    visible: root.expanded
    spacing: root.spacing

    Button {
      id: identifyButton
      objectName: "arrangementIdentify"
      width: parent.width
      text: Commons.I18n.t("monitor.identifyScreens", "Identify screens")
      foreground: root.foreground
      fontFamily: root.fontFamily
      fontSize: Style.font.caption
      verticalPadding: Style.space(4)
      bordered: true
      hasCursor: root.cursorIndex === root.indexOf(identifyButton)
      onClicked: root.identifyScreens()
      onHovered: function(hot) { if (hot) root.cursorRequested(root.indexOf(identifyButton), identifyButton) }
    }

    Rectangle {
      id: diagram
      width: parent.width
      height: Style.space(180)
      objectName: "arrangementDiagram"
      border.width: root.cursorIndex === 2 ? 1 : 0
      border.color: Commons.Color.accent
      color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.04)
      radius: Style.cornerRadius
      readonly property real fit: root.dragging ? root.dragFit : Math.min(
        (width - Style.space(20)) / (root.layoutBounds.width + 2 * Math.max.apply(null, root.shownMonitors.map(function(m) { return m.logicalWidth }).concat([1]))),
        (height - Style.space(20)) / (root.layoutBounds.height + 2 * Math.max.apply(null, root.shownMonitors.map(function(m) { return m.logicalHeight }).concat([1]))))
      clip: true
      Rectangle {
        visible: root.dragging !== "" && root.dragCandidate !== null
        color: Commons.Color.accent
        opacity: 0.7
        z: 3
        readonly property var guide: root.dragCandidate ? root.dragCandidate.guide : {}
        x: guide.x !== undefined ? (diagram.width - root.layoutBounds.width * diagram.fit) / 2 + (guide.x - root.layoutBounds.x) * diagram.fit : 0
        y: guide.y !== undefined ? (diagram.height - root.layoutBounds.height * diagram.fit) / 2 + (guide.y - root.layoutBounds.y) * diagram.fit : 0
        width: guide.x !== undefined ? 1 : diagram.width
        height: guide.y !== undefined ? 1 : diagram.height
      }
      Repeater {
        model: root.shownMonitors
        Rectangle {
          required property var modelData
          objectName: "arrangementScreen" + modelData.name
          z: root.dragging === modelData.name ? 2 : 0
          property real displayX: root.dragging === modelData.name ? root.dragX : modelData.x
          property real displayY: root.dragging === modelData.name ? root.dragY : modelData.y
          x: (diagram.width - root.layoutBounds.width * diagram.fit) / 2 + (displayX - root.layoutBounds.x) * diagram.fit
          y: (diagram.height - root.layoutBounds.height * diagram.fit) / 2 + (displayY - root.layoutBounds.y) * diagram.fit
          width: modelData.logicalWidth * diagram.fit
          height: modelData.logicalHeight * diagram.fit
          color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, modelData.name === root.moving ? 0.16 : 0.06)
          border.width: modelData.name === root.moving ? 2 : 1
          border.color: modelData.name === root.moving ? Commons.Color.accent : root.foreground
          Text {
            anchors.centerIn: parent
            width: Math.max(0, parent.width - Style.space(8))
            textFormat: Text.PlainText
            text: Commons.I18n.formatNumber(modelData.number)
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.displayLarge
          }
          MouseArea {
            anchors.fill: parent
            enabled: root.ready
            preventStealing: true
            cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            onPressed: function(mouse) { var p = mapToItem(diagram, mouse.x, mouse.y); root.beginDrag(modelData.name, p.x, p.y) }
            onPositionChanged: function(mouse) { if (pressed) { var p = mapToItem(diagram, mouse.x, mouse.y); root.updateDrag(p.x, p.y) } }
            onReleased: root.endDrag()
            onCanceled: root.dragging = ""
          }
        }
      }
    }

    Text {
      width: parent.width
      textFormat: Text.PlainText
      text: {
        var m = root.shownMonitors.filter(function(s) { return s.name === root.moving })[0]
        return m ? Commons.I18n.formatNumber(m.number) + " · " + root.displayLabel(m) + " (" + m.name + ")" : ""
      }
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.Wrap
    }

    Text {
      width: parent.width
      textFormat: Text.PlainText
      text: root.keyboardEditing ? Commons.I18n.t("monitor.arrangementKeyboardHint", "Arrow keys move the selected screen one pixel. Enter finishes editing.") : root.displayMessage()
      color: root.error ? Commons.Color.urgent : root.foreground
      opacity: root.error ? 1 : 0.7
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.Wrap
    }

    Row {
      width: parent.width
      spacing: Style.space(6)
      Button {
        id: applyButton
        objectName: "arrangementApply"
        width: (parent.width - parent.spacing) / 2
        text: root.busy && root.requestAction === "apply" ? Commons.I18n.t("monitor.arrangementApplying", "Applying…") : Commons.I18n.t("monitor.applyLayout", "Apply layout")
        foreground: root.foreground
        fontFamily: root.fontFamily
        bordered: true
        enabled: root.canApply
        opacity: enabled ? 1 : 0.45
        hasCursor: root.cursorIndex === root.indexOf(applyButton)
        onClicked: root.applyDraft()
        onHovered: function(hot) { if (hot) root.cursorRequested(root.indexOf(applyButton), applyButton) }
      }
      Button {
        id: discardButton
        objectName: "arrangementDiscard"
        width: (parent.width - parent.spacing) / 2
        text: Commons.I18n.t("monitor.discardLayout", "Discard changes")
        foreground: root.foreground
        fontFamily: root.fontFamily
        enabled: root.ready && root.preview.length > 0
        opacity: enabled ? 1 : 0.45
        hasCursor: root.cursorIndex === root.indexOf(discardButton)
        onClicked: root.discard()
        onHovered: function(hot) { if (hot) root.cursorRequested(root.indexOf(discardButton), discardButton) }
      }
    }
    Button {
      id: refreshButton
      objectName: "arrangementRefresh"
      width: parent.width
      text: Commons.I18n.t("monitor.refreshScreens", "Refresh")
      foreground: root.foreground
      fontFamily: root.fontFamily
      enabled: !root.busy
      opacity: enabled ? 1 : 0.45
      hasCursor: root.cursorIndex === root.indexOf(refreshButton)
      onClicked: root.refresh()
      onHovered: function(hot) { if (hot) root.cursorRequested(root.indexOf(refreshButton), refreshButton) }
    }
    Button {
      id: presetsButton
      objectName: "arrangementPresets"
      width: parent.width
      text: Commons.I18n.t("monitor.positionControls", "Position controls")
      leftAlign: true
      foreground: root.foreground
      fontFamily: root.fontFamily
      fontSize: Style.font.caption
      enabled: root.ready
      hasCursor: root.cursorIndex === root.indexOf(presetsButton)
      onClicked: root.showPresets = !root.showPresets
      onHovered: function(hot) { if (hot) root.cursorRequested(root.indexOf(presetsButton), presetsButton) }
      Text {
        textFormat: Text.PlainText
        anchors.right: parent.right
        anchors.rightMargin: Style.spacing.controlPaddingX
        anchors.verticalCenter: parent.verticalCenter
        text: root.showPresets ? "󰅃" : "󰅀"
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.icon
      }
    }
    Column {
      width: parent.width
      spacing: root.spacing
      visible: root.showPresets
      Row {
        width: parent.width
        spacing: Style.space(10)
        Dropdown {
          id: movingPicker
          objectName: "arrangementMoving"
          width: (parent.width - parent.spacing) / 2
          label: Commons.I18n.t("monitor.moveScreen", "Move screen")
          value: root.moving
          options: root.monitors.map(function(m) { return {value: m.name, label: Commons.I18n.formatNumber(m.number) + " · " + root.displayLabel(m)} })
          enabled: root.ready
          foreground: root.foreground
          fontFamily: root.fontFamily
          hasCursor: root.cursorIndex === root.indexOf(movingPicker)
          onChanged: function(value) {
            root.selectScreen(value)
            movingPicker.value = Qt.binding(function() { return root.moving })
          }
          onHovered: function(hot) { if (hot) root.cursorRequested(root.indexOf(movingPicker), movingPicker) }
        }
        Dropdown {
          id: referencePicker
          objectName: "arrangementReference"
          width: (parent.width - parent.spacing) / 2
          label: Commons.I18n.t("monitor.relativeTo", "Relative to")
          value: root.reference
          options: root.monitors.filter(function(m) { return m.name !== root.moving }).map(function(m) { return {value: m.name, label: Commons.I18n.formatNumber(m.number) + " · " + root.displayLabel(m)} })
          enabled: root.ready
          foreground: root.foreground
          fontFamily: root.fontFamily
          hasCursor: root.cursorIndex === root.indexOf(referencePicker)
          onChanged: function(value) {
            root.reference = value; root.side = ""
            referencePicker.value = Qt.binding(function() { return root.reference })
          }
          onHovered: function(hot) { if (hot) root.cursorRequested(root.indexOf(referencePicker), referencePicker) }
        }
      }

      Row {
        width: parent.width
        spacing: Style.space(8)
        NumberField {
          id: xField
          objectName: "arrangementX"
          label: "X"
          width: (parent.width - parent.spacing) / 2
          fieldWidth: width
          from: -1000000
          to: 1000000
          value: root.selectedMonitor ? root.selectedMonitor.x : 0
          enabled: root.ready
          foreground: root.foreground
          fontFamily: root.fontFamily
          hasCursor: root.cursorIndex === root.indexOf(xField)
          onModified: function(value) {
            root.chooseCoordinate("x", value)
            xField.field.value = Qt.binding(function() { return xField.value })
            Qt.callLater(root.finishCoordinateEditing)
          }
          onHovered: function(hot) { if (hot) root.cursorRequested(root.indexOf(xField), xField) }
          Keys.onReleased: function(event) {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Escape) {
              xField.field.contentItem.text = Qt.binding(function() { return xField.field.displayText })
              Qt.callLater(root.finishCoordinateEditing)
              event.accepted = true
            }
          }
        }
        NumberField {
          id: yField
          objectName: "arrangementY"
          label: "Y"
          width: (parent.width - parent.spacing) / 2
          fieldWidth: width
          from: -1000000
          to: 1000000
          value: root.selectedMonitor ? root.selectedMonitor.y : 0
          enabled: root.ready
          foreground: root.foreground
          fontFamily: root.fontFamily
          hasCursor: root.cursorIndex === root.indexOf(yField)
          onModified: function(value) {
            root.chooseCoordinate("y", value)
            yField.field.value = Qt.binding(function() { return yField.value })
            Qt.callLater(root.finishCoordinateEditing)
          }
          onHovered: function(hot) { if (hot) root.cursorRequested(root.indexOf(yField), yField) }
          Keys.onReleased: function(event) {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Escape) {
              yField.field.contentItem.text = Qt.binding(function() { return yField.field.displayText })
              Qt.callLater(root.finishCoordinateEditing)
              event.accepted = true
            }
          }
        }
      }

      Row {
        width: parent.width
        spacing: Style.space(4)
        Repeater {
          id: directionButtons
          model: root.sides
          Button {
            id: directionButton
            required property string modelData
            required property int index
            objectName: "arrangement" + ["Left", "Right", "Above", "Below"][index]
            width: (parent.width - parent.spacing * 3) / 4
            text: root.placementLabels[modelData]
            bordered: true
            foreground: root.foreground
            fontFamily: root.fontFamily
            enabled: root.ready
            opacity: enabled ? 1 : 0.45
            active: root.side === root.sides[index] && root.preview.length > 0
            hasCursor: root.cursorIndex === root.indexOf(directionButton)
            onClicked: root.chooseSide(root.sides[index])
            onHovered: function(hot) { if (hot) root.cursorRequested(root.indexOf(directionButton), directionButton) }
          }
        }
      }

      Dropdown {
        id: alignmentPicker
        objectName: "arrangementAlignment"
        width: parent.width
        label: Commons.I18n.t("monitor.alignScreens", "Align screens")
        value: root.alignment
        options: root.alignmentOptions.map(function(value) {
          return {value: value, label: root.placementLabels[value]}
        })
        enabled: root.ready && root.side !== ""
        foreground: root.foreground
        fontFamily: root.fontFamily
        hasCursor: root.cursorIndex === root.indexOf(alignmentPicker)
        onChanged: function(value) {
          root.chooseAlignment(value)
          alignmentPicker.value = Qt.binding(function() { return root.alignment })
        }
        onHovered: function(hot) { if (hot) root.cursorRequested(root.indexOf(alignmentPicker), alignmentPicker) }
      }
    }
  }
}
