import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui
import "NightlightModel.js" as NightlightModel

// Night light config. A centered card in the reminders / Wi-Fi QR style: the
// automatic schedule, when the screen warms and when it goes back, and how warm
// night light gets.
//
// Arrows and Tab walk the rows; the current one carries an accent bar and
// ring. Enter activates it (edits a time, flips the switch, saves), and Esc
// leaves a field before it closes the card.
//
// The card edits a draft. Warmth previews live on the screen while night light
// is on, schedule or not; everything else waits for Save, which hands the
// draft to the service and through it to bin/omarchy-nightlight-config.
// Closing without saving puts the saved warmth back.
Item {
  id: root

  property var shell: null
  property var manifest: null
  property var service: null

  property bool opened: false
  property bool firstRun: false
  property bool saved: false

  // Draft, seeded from the service on every open.
  property bool scheduled: true
  property string dayText: NightlightModel.DEFAULT_SCHEDULE.day
  property string nightText: NightlightModel.DEFAULT_SCHEDULE.night
  property int temperature: NightlightModel.DEFAULT_SCHEDULE.temperature

  // Keyboard cursor over the rows, in order: 0 schedule switch, 1 day field,
  // 2 night field, 3 warmth slider, 4 save.
  readonly property var rows: ["schedule", "day", "night", "warmth", "save"]
  property int cursor: 1

  readonly property string fontFamily: Style.font.family
  readonly property color foreground: Color.menu.text
  readonly property color dim: Qt.darker(foreground, 1.4)
  readonly property color accent: Color.accent
  readonly property bool editing: dayField.activeFocus || nightField.activeFocus
  // The theme accent, not the selected-state token: some themes tint selection
  // with the foreground, and the cursor has to stand apart from the text.
  readonly property color cursorColor: root.accent

  readonly property string day: NightlightModel.normalizeTime(dayText)
  readonly property string night: NightlightModel.normalizeTime(nightText)
  readonly property var summary: NightlightModel.describeSchedule(scheduled, day, night)

  function open(payloadJson) {
    var payload = {}
    try { payload = JSON.parse(payloadJson || "{}") || {} } catch (e) { payload = {} }

    var saved = root.service && root.service.schedule ? root.service.schedule : NightlightModel.parseSchedule("")
    root.firstRun = payload.reason === "first-run" || !saved.saved
    // Someone opening this for the first time came here to schedule, so the
    // switch starts on; afterwards it reflects what they saved.
    root.scheduled = saved.saved ? saved.scheduled : true
    root.dayText = saved.day
    root.nightText = saved.night
    root.temperature = saved.temperature
    root.cursor = 0
    root.saved = false
    root.opened = true

    // The surface is created hidden, so focus taken during creation lands
    // nowhere. Take it again once mapped.
    Qt.callLater(function() { if (root.opened) keyCatcher.forceActiveFocus() })
  }

  function close() {
    if (root.opened && !root.saved && root.service) root.service.endPreview()
    root.opened = false
  }

  function dismiss() {
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "omarchy.nightlight")
    else close()
  }

  function leaveField() {
    if (dayField.activeFocus) root.commitField(dayField)
    if (nightField.activeFocus) root.commitField(nightField)
    keyCatcher.forceActiveFocus()
  }

  // Tidies a typed time ("730" -> "07:30") when the field is left, and leaves
  // unreadable text in place so the error line can point at it.
  function commitField(field) {
    var normalized = NightlightModel.normalizeTime(field.text)
    if (normalized !== "") field.text = normalized
  }

  function focusRow(index) {
    root.cursor = Math.max(0, Math.min(root.rows.length - 1, index))
    if (root.rows[root.cursor] === "day") dayField.forceActiveFocus()
    else if (root.rows[root.cursor] === "night") nightField.forceActiveFocus()
    else keyCatcher.forceActiveFocus()
  }

  function activateRow() {
    var row = root.rows[root.cursor]
    if (row === "schedule") root.scheduled = !root.scheduled
    else if (row === "day" || row === "night") root.focusRow(root.cursor)
    else if (row === "save") root.save()
  }

  function setWarmth(value) {
    root.temperature = NightlightModel.clampTemperature(value)
    if (root.service) root.service.previewWarmth(root.temperature)
  }

  function nudgeWarmth(direction) {
    root.setWarmth(root.temperature + direction * NightlightModel.TEMPERATURE_STEP)
  }

  function save() {
    root.leaveField()
    if (!root.summary.valid) {
      root.focusRow(root.day === "" ? 1 : 2)
      return
    }
    if (root.service && root.service.saveConfig(root.scheduled, root.day, root.night, root.temperature)) {
      root.saved = true
      root.dismiss()
    }
  }

  // Shared behavior for the two time fields: arrows step the time, Enter and
  // Tab move on, Esc gives the keys back to the card.
  function fieldKey(event, field, index) {
    if (event.key === Qt.Key_Escape || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
      root.commitField(field)
      if (event.key === Qt.Key_Escape) root.leaveField()
      else root.focusRow(index + 1)
      event.accepted = true
    } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
      root.commitField(field)
      var back = event.key === Qt.Key_Backtab || (event.modifiers & Qt.ShiftModifier)
      root.focusRow(index + (back ? -1 : 1))
      event.accepted = true
    } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Down) {
      var step = (event.modifiers & Qt.ShiftModifier) ? 60 : 15
      field.text = NightlightModel.shiftTime(field.text, event.key === Qt.Key_Up ? step : -step,
        index === 1 ? NightlightModel.DEFAULT_SCHEDULE.day : NightlightModel.DEFAULT_SCHEDULE.night)
      event.accepted = true
    }
  }

  OverlayWindow {
    id: overlay
    shown: root.opened
    WlrLayershell.namespace: "omarchy-nightlight-config"

    Rectangle {
      anchors.fill: parent
      color: Color.menu.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }

    BorderSurface {
      id: card
      anchors.centerIn: parent
      width: Math.min(Style.space(380), overlay.width - Style.gapsOut * 2)
      height: content.implicitHeight + card.contentTopInset + card.contentBottomInset
      radius: Style.cornerRadius
      color: Color.menu.background
      borderSpec: Border.surfaceSpec("menu", "border", Color.menu.border, Math.max(1, Style.space(2)))
      padding: Style.spacing.panelPadding

      // Swallow clicks so only the scrim outside the card dismisses.
      MouseArea { anchors.fill: parent; onClicked: root.leaveField() }

      PanelKeyCatcher {
        id: keyCatcher
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        blocked: root.editing

        onCloseRequested: root.dismiss()
        onTabRequested: function(direction) { root.cursor = (root.cursor + direction + root.rows.length) % root.rows.length }
        onMoveRequested: function(dx, dy) {
          if (dy !== 0) root.cursor = Math.max(0, Math.min(root.rows.length - 1, root.cursor + dy))
          else if (root.rows[root.cursor] === "warmth") root.nudgeWarmth(dx)
          else if (root.rows[root.cursor] === "schedule") root.scheduled = dx > 0
        }
        onActivateRequested: root.activateRow()

        Column {
          id: content
          width: parent.width
          spacing: Style.spacing.panelGap

          PanelHero {
            title: "Night Light"
            meta: "Config"
            foreground: root.foreground
            fontFamily: root.fontFamily
            iconComponent: Component {
              Text {
                textFormat: Text.PlainText
                text: "󰔎"
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.display
              }
            }
          }

          Text {
            textFormat: Text.PlainText
            visible: root.firstRun
            width: parent.width
            wrapMode: Text.WordWrap
            text: "Warm the screen automatically every evening. You can change this later in Setup > Config > Night Light Config."
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
          }

          PanelSeparator { foreground: root.foreground }

          Toggle {
            id: scheduleToggle
            width: parent.width
            label: "Automatic schedule"
            description: root.scheduled ? "Night light follows the clock" : "Night light only changes when you toggle it"
            checked: root.scheduled
            hasCursor: root.cursor === 0
            foreground: root.foreground
            fontFamily: root.fontFamily
            onClicked: { root.cursor = 0; root.scheduled = !root.scheduled }
            onHovered: function(isHovered) { if (isHovered && !root.editing) root.cursor = 0 }
          }

          Column {
            id: daySection
            width: parent.width
            spacing: Style.spacing.labelGap
            opacity: root.scheduled ? 1 : 0.55

            Behavior on opacity { NumberAnimation { duration: Style.duration(120) } }

            PanelSectionHeader {
              text: "DAY LIGHT STARTS"
              foreground: root.cursor === 1 ? root.cursorColor : root.foreground
              fontFamily: root.fontFamily
            }

            TextField {
              id: dayField
              width: parent.width
              text: root.dayText
              onTextEdited: root.dayText = text
              onTextChanged: if (text !== root.dayText) root.dayText = text
              placeholderText: "07:00"
              maximumLength: 5
              inputMethodHints: Qt.ImhPreferNumbers
              foreground: root.day === "" && text !== "" ? Color.urgent : root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.heading
              hasCursor: root.cursor === 1 && !activeFocus
              onActiveFocusChanged: if (activeFocus) { root.cursor = 1; selectAll() }
              onHoveredChanged: if (hovered && !root.editing) root.cursor = 1
              Keys.onPressed: function(event) { root.fieldKey(event, dayField, 1) }
            }
          }

          Column {
            id: nightSection
            width: parent.width
            spacing: Style.spacing.labelGap
            opacity: root.scheduled ? 1 : 0.55

            Behavior on opacity { NumberAnimation { duration: Style.duration(120) } }

            PanelSectionHeader {
              text: "NIGHT LIGHT STARTS"
              foreground: root.cursor === 2 ? root.cursorColor : root.foreground
              fontFamily: root.fontFamily
            }

            TextField {
              id: nightField
              width: parent.width
              text: root.nightText
              onTextEdited: root.nightText = text
              onTextChanged: if (text !== root.nightText) root.nightText = text
              placeholderText: "20:00"
              maximumLength: 5
              inputMethodHints: Qt.ImhPreferNumbers
              foreground: root.night === "" && text !== "" ? Color.urgent : root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.heading
              hasCursor: root.cursor === 2 && !activeFocus
              onActiveFocusChanged: if (activeFocus) { root.cursor = 2; selectAll() }
              onHoveredChanged: if (hovered && !root.editing) root.cursor = 2
              Keys.onPressed: function(event) { root.fieldKey(event, nightField, 2) }
            }
          }

          Column {
            id: warmthSection
            width: parent.width
            spacing: Style.spacing.labelGap

            PanelSectionHeader {
              text: root.service && root.service.enabled ? "WARMTH · LIVE" : "WARMTH"
              foreground: root.cursor === 3 ? root.cursorColor : root.foreground
              fontFamily: root.fontFamily
            }

            CursorSurface {
              id: warmthBox
              width: parent.width
              implicitHeight: warmthRow.implicitHeight + Style.spacing.controlPaddingY * 2
              hasCursor: root.cursor === 3
              foreground: root.foreground

              HoverHandler {
                onHoveredChanged: if (hovered && !root.editing) root.cursor = 3
              }

              Row {
                id: warmthRow
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: Style.spacing.controlPaddingX
                anchors.rightMargin: Style.spacing.controlPaddingX
                spacing: Style.spacing.controlGap

                // What white turns into at this warmth.
                Rectangle {
                  readonly property var tint: NightlightModel.kelvinColor(root.temperature)
                  width: Style.space(14)
                  height: width
                  radius: width / 2
                  anchors.verticalCenter: parent.verticalCenter
                  color: Qt.rgba(tint.r, tint.g, tint.b, 1)
                  border.width: 1
                  border.color: Util.alpha(root.foreground, 0.25)
                }

                PanelSlider {
                  width: parent.width - kelvinText.width - Style.space(14) - parent.spacing * 2
                  anchors.verticalCenter: parent.verticalCenter
                  minimum: NightlightModel.MIN_TEMPERATURE
                  maximum: NightlightModel.MAX_TEMPERATURE
                  step: NightlightModel.TEMPERATURE_STEP
                  integer: true
                  value: root.temperature
                  fillColor: root.cursor === 3 ? root.cursorColor : root.foreground
                  knobColor: root.cursor === 3 ? root.cursorColor : root.foreground
                  trackColor: Style.selectedFillFor(root.foreground, root.accent)
                  tickColor: Color.menu.background
                  onMoved: function(value) { root.cursor = 3; root.setWarmth(value) }
                  onReleased: function(value) { root.setWarmth(value) }
                }

                Text {
                  id: kelvinText
                  textFormat: Text.PlainText
                  anchors.verticalCenter: parent.verticalCenter
                  width: Style.space(48)
                  horizontalAlignment: Text.AlignRight
                  text: root.temperature + "K"
                  color: root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.body
                  font.bold: true
                }
              }
            }
          }

          PanelSeparator { foreground: root.foreground }

          Text {
            textFormat: Text.PlainText
            width: parent.width
            wrapMode: Text.WordWrap
            text: root.summary.text
            color: root.summary.valid ? root.dim : Color.urgent
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
          }

          Item {
            id: saveRow
            width: parent.width
            implicitHeight: saveButton.implicitHeight

            Text {
              textFormat: Text.PlainText
              anchors.left: parent.left
              anchors.right: saveButton.left
              anchors.rightMargin: Style.spacing.controlGap
              anchors.verticalCenter: parent.verticalCenter
              elide: Text.ElideRight
              text: root.editing ? "↑↓ adjust · Enter next · Esc done" : "↑↓ move · ←→ adjust · Esc close"
              color: Qt.darker(root.foreground, 1.6)
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
            }

            Button {
              id: saveButton
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              text: "Save"
              bordered: true
              selected: root.summary.valid
              hasCursor: root.cursor === 4
              foreground: root.foreground
              fontFamily: root.fontFamily
              opacity: root.summary.valid ? 1 : 0.5
              onClicked: { root.cursor = 4; root.save() }
              onHovered: function(isHovered) { if (isHovered && !root.editing) root.cursor = 4 }
            }
          }
        }

        // The cursor: an accent bar in the card's left gutter plus an accent
        // ring around the current control. One pair that glides between rows,
        // so the eye can follow it, instead of a ring per row.
        Item {
          id: cursorMarker
          // Positions as plain bindings (not mapToItem) so the marker follows
          // layout changes, like the first-run note appearing.
          readonly property var rects: [
            [scheduleToggle.x, scheduleToggle.y, scheduleToggle.width, scheduleToggle.height],
            [daySection.x + dayField.x, daySection.y + dayField.y, dayField.width, dayField.height],
            [nightSection.x + nightField.x, nightSection.y + nightField.y, nightField.width, nightField.height],
            [warmthSection.x + warmthBox.x, warmthSection.y + warmthBox.y, warmthBox.width, warmthBox.height],
            [saveRow.x + saveButton.x, saveRow.y + saveButton.y, saveButton.width, saveButton.height]
          ]
          readonly property var rect: rects[root.cursor] || [0, 0, 0, 0]
          readonly property real ringInset: Math.max(2, Style.space(3))
          x: rect[0]
          y: rect[1]
          width: rect[2]
          height: rect[3]

          Behavior on x { enabled: root.opened; NumberAnimation { duration: Style.duration(140); easing.type: Easing.OutCubic } }
          Behavior on width { enabled: root.opened; NumberAnimation { duration: Style.duration(140); easing.type: Easing.OutCubic } }
          Behavior on y { enabled: root.opened; NumberAnimation { duration: Style.duration(140); easing.type: Easing.OutCubic } }
          Behavior on height { enabled: root.opened; NumberAnimation { duration: Style.duration(140); easing.type: Easing.OutCubic } }

          Rectangle {
            width: Math.max(3, Style.space(4))
            radius: width / 2
            // Centered in the card's left padding, whatever the row's own x.
            x: -cursorMarker.x - Style.spacing.panelPadding / 2 - width / 2
            height: parent.height
            color: root.cursorColor
          }

          BorderSurface {
            anchors.fill: parent
            anchors.margins: -cursorMarker.ringInset
            color: "transparent"
            radius: Style.cornerRadius + cursorMarker.ringInset
            borderSpec: Border.flat(root.cursorColor, Math.max(2, Style.space(2)))
          }
        }
      }
    }
  }
}
