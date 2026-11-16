import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "OsdModel.js" as OsdModel
import "../panels/audio/Model.js" as AudioModel

Item {
  id: root

  property bool opened: false
  property string icon: ""
  property string message: ""
  property string iconKey: ""
  property int value: 0
  property int maxValue: 100
  property bool hasProgress: true
  property int duration: 1200
  // Snapshot of the applications playing audio, rebuilt on every volume OSD.
  // Rows hold primitives only; delegates resolve the live PipeWire nodes.
  property var sourceRows: []
  property bool cardHovered: false
  // The mixer is closed on every volume notification; the APPS row in the
  // card opens it explicitly.
  property bool mixerOpen: false
  // Latches once the pointer reaches the card or the mixer opens. Until then
  // the surface stays click-through, so a volume key does not steal the next
  // click from the window below; after that, a click anywhere outside closes.
  property bool pointerEngaged: false

  readonly property bool mediaOsd: iconKey.indexOf("media") === 0 || iconKey.indexOf("player") === 0
  readonly property var mprisPlayers: Mpris.players ? Mpris.players.values : []
  readonly property var nodes: Pipewire.nodes ? Pipewire.nodes.values : []
  // The expanded app rows name the workspace their window is on. Hyprland is
  // the source of that; the projection keeps the lookup out of each delegate.
  readonly property var workspaceWindows: AudioModel.workspaceWindows(Hyprland.toplevels ? Hyprland.toplevels.values : [])
  readonly property bool volumeOsd: OsdModel.isVolumeIcon(iconKey)
  readonly property bool mixerMenu: volumeOsd && sourceRows.length > 0
  readonly property bool showSources: mixerMenu && mixerOpen
  readonly property bool dismissOnOutsideClick: root.opened && root.mixerMenu && root.pointerEngaged

  // The card is built out of measured columns instead of fixed widths, so it
  // keeps exactly `pad` between border and content on every side whatever
  // glyph or message it carries. Messages grow with their text up to
  // `maxMessageWidth` and elide beyond it.
  readonly property int pad: Style.space(16)
  readonly property int gap: Style.space(16)
  // A glyph next to a message reads airier than it measures: the icon outline
  // and the letterforms both fall away from their ink extremes, so the space
  // between them opens up well past the nominal gap. Text takes two thirds of
  // it; the progress bar's hard edge keeps the full gap.
  readonly property int messageGap: Math.round(root.gap * 2 / 3)
  readonly property int barWidth: Style.space(142)
  readonly property int maxMessageWidth: root.mediaOsd ? Style.space(325) : Style.space(190)

  // Nerd Font glyphs draw well outside their monospace cell, so the icon
  // column is measured by ink rather than by advance width. Progress OSDs pin
  // it to the widest glyph the model can return, so the bar doesn't shift when
  // volume crosses an icon threshold.
  readonly property int iconInkWidth: Math.ceil(iconMetrics.tightBoundingRect.width)
  readonly property int iconWidth: root.hasProgress
    ? Math.max(root.iconInkWidth, Math.ceil(widestIconMetrics.tightBoundingRect.width))
    : root.iconInkWidth
  // Same idea for the readout: it is as wide as the longest percentage so the
  // digits don't jitter between 9% and 100%.
  readonly property int valueWidth: Math.ceil(Math.max(valueMetrics.advanceWidth, messageMetrics.advanceWidth))
  readonly property int messageWidth: Math.min(Math.ceil(messageMetrics.advanceWidth), root.maxMessageWidth)
  readonly property int mainContentWidth: root.hasProgress
    ? root.iconWidth + root.gap + root.barWidth + root.gap + root.valueWidth
    : (root.message === "" ? root.iconWidth : root.iconWidth + root.messageGap + root.messageWidth)
  readonly property int sourcesWidth: Style.space(320)
  readonly property int mainRowHeight: Style.font.displayLarge
  // The expanded mixer shows five app cards before it scrolls. The row height
  // comes from a real delegate so theme scaling and font changes cannot leave
  // a clipped row; the fallback is the same measurement before the first row
  // exists.
  readonly property int maxSourceRows: 5
  readonly property int sourceListSpacing: Style.space(8)
  readonly property real sourceRowHeight: {
    var row = sourceRepeater && sourceRepeater.count > 0 ? sourceRepeater.itemAt(0) : null
    return row && row.height > 0 ? row.height : Style.space(70)
  }
  readonly property real sourceListMaxHeight: sourceRowHeight * maxSourceRows
    + root.sourceListSpacing * (maxSourceRows - 1)
  readonly property int contentWidth: root.mixerMenu
    ? Math.max(root.mainContentWidth, root.sourcesWidth)
    : root.mainContentWidth

  function iconFor(name, percent) {
    return OsdModel.iconFor(name, percent)
  }

  function iconSourceFor(name) {
    var value = String(name || "").trim()
    if (!value) return ""
    if (value.charAt(0) === "/") return Util.fileUrl(value)

    var entry = DesktopEntries.heuristicLookup(value)
    if (entry && entry.icon) {
      var icon = String(entry.icon)
      if (icon.charAt(0) === "/") return Util.fileUrl(icon)
      var themed = Quickshell.iconPath(icon, true)
      if (themed) return themed
    }
    return Quickshell.iconPath(value, true)
  }

  function sourceIcon(streams) {
    for (var i = 0; i < streams.length; i++) {
      var names = AudioModel.streamAppIconCandidates(streams[i])
      for (var j = 0; j < names.length; j++) {
        var source = iconSourceFor(names[j])
        if (source) return source
      }
    }
    return ""
  }

  // Snapshot the live mixer into rows a Repeater can hold safely. Nothing in a
  // row is a QObject, so a stream ending while the OSD is up cannot leave a
  // delegate holding a deleted node.
  function buildSources() {
    var nodes = root.nodes
    var names = []
    for (var i = 0; i < nodes.length; i++)
      if (nodes[i] && nodes[i].name) names.push(String(nodes[i].name))

    var streams = []
    for (var j = 0; j < nodes.length; j++) {
      var node = nodes[j]
      if (!node || !node.isStream || !node.audio) continue
      if (!AudioModel.isPlaybackStream(node)) continue
      if (String(node.name || "").indexOf("omarchy_speaker_tuning") === 0) continue
      if (AudioNodes.platformHides(node.name, names)) continue
      streams.push(node)
    }

    var groups = AudioModel.groupStreamsByApp(streams)
    var rows = []
    for (var g = 0; g < groups.length; g++) {
      var group = groups[g]
      var label = AudioModel.streamLabel(group.streams[0], mprisPlayers, streams, Commons.I18n.t)
      rows.push({
        key: group.key,
        label: label,
        rows: AudioModel.rowSnapshot(group.streams),
        icon: sourceIcon(group.streams),
        initial: label ? label.charAt(0).toUpperCase() : "?"
      })
    }
    return rows
  }

  // Rows are kept stable while their streams stay the same; assigning an
  // identical list would rebuild every delegate and interrupt a slider drag.
  function sameSources(left, right) {
    if (!left || !right || left.length !== right.length) return false
    for (var i = 0; i < left.length; i++) {
      var a = left[i]
      var b = right[i]
      if (!a || !b || a.key !== b.key || a.label !== b.label || a.icon !== b.icon) return false
      if (!a.rows || !b.rows || a.rows.length !== b.rows.length) return false
      for (var j = 0; j < a.rows.length; j++)
        if (a.rows[j].id !== b.rows[j].id || a.rows[j].name !== b.rows[j].name) return false
    }
    return true
  }

  function refreshSources() {
    if (!root.opened || !root.volumeOsd) return
    var rows = buildSources()
    if (sameSources(rows, root.sourceRows)) return
    root.sourceRows = rows
    if (rows.length === 0) {
      root.mixerOpen = false
      return
    }
    root.duration = Math.max(root.duration, root.mixerOpen ? 4000 : 3000)
    if (!root.cardHovered) hideTimer.restart()
  }

  function nodesForSource(row) {
    var list = []
    if (!row || !row.rows) return list

    var nodes = root.nodes
    for (var i = 0; i < row.rows.length; i++) {
      for (var j = 0; j < nodes.length; j++) {
        var node = nodes[j]
        if (node && node.id === row.rows[i].id && String(node.name || "") === row.rows[i].name) {
          list.push(node)
          break
        }
      }
    }
    return list
  }

  function setSourceVolume(row, volume) {
    var nodes = nodesForSource(row)
    var level = Math.max(0, Math.min(1, volume))
    for (var i = 0; i < nodes.length; i++)
      if (nodes[i].audio) nodes[i].audio.volume = level
  }

  function toggleSourceMuted(row) {
    var nodes = nodesForSource(row)
    var mute = !AudioModel.groupMuted(nodes)
    for (var i = 0; i < nodes.length; i++)
      if (nodes[i].audio) nodes[i].audio.muted = mute
  }

  function setMixerOpen(open) {
    if (!root.mixerMenu) return
    root.mixerOpen = open
    root.duration = Math.max(root.duration, open ? 4000 : 3000)
    if (root.opened && !root.cardHovered) hideTimer.restart()
  }

  function show(iconName, rawMessage, rawValue, rawMax, rawProgressText, rawDuration) {
    var next = OsdModel.stateForShow(iconName, rawMessage, rawValue, rawMax, rawProgressText, rawDuration, Commons.I18n.formatNumber)
    // Update before opening so a fresh OSD starts at its new value; only
    // subsequent updates while it remains open animate the progress bar.
    iconKey = next.iconKey
    maxValue = next.maxValue
    hasProgress = next.hasProgress
    value = next.value
    message = next.message
    icon = next.icon
    duration = next.duration
    // A volume key must not rebuild the app list: an unchanged list would
    // destroy the SourceRow whose slider is being dragged.
    var rows = OsdModel.isVolumeIcon(next.iconKey) ? buildSources() : []
    if (!sameSources(rows, sourceRows)) sourceRows = rows
    // A fresh card starts closed; while the card stays up, a volume update
    // must not fold the mixer the user just opened.
    if (!opened || sourceRows.length === 0) mixerOpen = false
    if (sourceRows.length > 0) duration = Math.max(duration, mixerOpen ? 4000 : 3000)
    opened = true
    if (duration > 0) hideTimer.restart()
    else hideTimer.stop()
  }

  onOpenedChanged: {
    if (opened) return
    sourceRows = []
    cardHovered = false
    mixerOpen = false
    pointerEngaged = false
  }

  onCardHoveredChanged: if (cardHovered) pointerEngaged = true
  onMixerOpenChanged: if (mixerOpen) pointerEngaged = true

  // Streams come and go while the card is up (a player closes, a tab starts),
  // and the mixer should follow them without waiting for the next volume key.
  onNodesChanged: if (root.opened && root.volumeOsd) sourceRefreshTimer.restart()
  onMprisPlayersChanged: if (root.opened && root.volumeOsd) sourceRefreshTimer.restart()

  function open(payloadJson) {
    try {
      var p = JSON.parse(payloadJson || "{}")
      show(p.icon || "", p.message || "", p.value === undefined ? "" : String(p.value), p.max === undefined ? "100" : String(p.max), p.progressText || "", p.duration === undefined ? "1200" : String(p.duration))
    } catch (e) {}
  }

  function close() { opened = false }

  Timer {
    id: hideTimer
    interval: root.duration
    onTriggered: {
      if (root.mixerMenu && root.cardHovered) {
        hideTimer.restart()
        return
      }
      root.opened = false
    }
  }

  // A burst of node changes should rebuild the rows once, not per node.
  Timer {
    id: sourceRefreshTimer
    interval: 120
    onTriggered: root.refreshSources()
  }

  TextMetrics {
    id: messageMetrics
    font.family: Style.font.family
    font.bold: true
    font.pixelSize: Style.font.title
    text: root.message
  }

  TextMetrics {
    id: valueMetrics
    font: messageMetrics.font
    text: Commons.I18n.formatNumber(100) + "%"
  }

  TextMetrics {
    id: sourcePctMetrics
    font.family: Style.font.family
    font.bold: true
    font.pixelSize: Style.font.caption
    text: Commons.I18n.formatNumber(100) + "%"
  }

  TextMetrics {
    id: iconMetrics
    font.family: Style.font.family
    font.pixelSize: Style.font.displayLarge
    text: root.icon
  }

  TextMetrics {
    id: widestIconMetrics
    font: iconMetrics.font
    text: OsdModel.widestIcon
  }

  ShellIpc {
    target: "osd"
    function show(payloadJson: string): string {
      root.open(payloadJson)
      return "ok"
    }
    function close(): string { root.close(); return "ok" }
    function state(): string { return root.opened ? "open" : "closed" }
    function ping(): string { return "ok" }
  }

  OverlayWindow {
    id: panel
    shown: root.opened
    shownKeyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "omarchy-osd"
    // Visual-only until the pointer reaches the card: a transient notification
    // stays click-through so the click after a volume key still lands in the
    // window below. Once engaged, the whole screen catches the click that
    // dismisses the card.
    mask: Region {
      item: root.dismissOnOutsideClick ? dismissArea : (root.mixerMenu ? card : null)
    }

    MouseArea {
      id: dismissArea
      anchors.fill: parent
      enabled: root.dismissOnOutsideClick
      acceptedButtons: Qt.AllButtons
      onPressed: root.close()
    }

    BorderSurface {
      id: card
      width: card.borderLeft + root.pad + root.contentWidth + root.pad + card.borderRight
      height: card.borderTop + root.pad + contentColumn.implicitHeight + root.pad + card.borderBottom
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: Style.space(67)
      color: Util.alpha(Commons.Color.background, 0.97)
      borderSpec: Border.surfaceSpec("popups", "border", Commons.Color.popups.border, Math.max(1, Style.space(2)))
      radius: Style.cornerRadius
      opacity: root.opened ? 1 : 0

      // Swallow clicks on the card so they cannot reach the dismissal area
      // behind it. Controls inside the card are later siblings and stay on top.
      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
      }

      Column {
        id: contentColumn
        anchors.fill: parent
        anchors.topMargin: card.borderTop + root.pad
        anchors.rightMargin: card.borderRight + root.pad
        anchors.bottomMargin: card.borderBottom + root.pad
        anchors.leftMargin: card.borderLeft + root.pad
        spacing: root.gap

        // ---- The notification itself: icon, level bar, readout ----
        Row {
          id: mainRow
          width: root.hasProgress ? parent.width : implicitWidth
          height: root.mainRowHeight
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: root.hasProgress ? root.gap : root.messageGap
          Item {
            width: root.iconWidth
            height: parent.height
            Text {
              textFormat: Text.PlainText
              // Sit the glyph's ink flush in the column, centered when the
              // column is wider than this particular glyph.
              x: Math.round((root.iconWidth - root.iconInkWidth) / 2 - iconMetrics.tightBoundingRect.x)
              anchors.verticalCenter: parent.verticalCenter
              text: root.icon
              font: iconMetrics.font
              color: Commons.Color.popups.text
            }
          }
          Rectangle {
            visible: root.hasProgress
            width: root.hasProgress
              ? Math.max(0, mainRow.width - root.iconWidth - root.valueWidth - mainRow.spacing * 2)
              : root.barWidth
            height: Math.max(Style.space(6), Style.spacing.sm)
            anchors.verticalCenter: parent.verticalCenter
            color: Util.alpha(Commons.Color.popups.text, 0.45)
            Rectangle {
              // Anchored so a right-to-left layout fills from the right.
              anchors.left: parent.left
              height: parent.height
              width: parent.width * (root.hasProgress ? root.value / root.maxValue : 0)
              color: Commons.Color.accent

              Behavior on width {
                enabled: root.opened
                NumberAnimation { duration: Style.duration(140); easing.type: Easing.OutCubic }
              }
            }
          }
          Text {
            textFormat: Text.PlainText
            visible: root.message !== ""
            width: root.hasProgress ? root.valueWidth : root.messageWidth
            // The readout hugs the card edge so a short percentage doesn't leave
            // a hole in the padding; the slack lands in the gap after the bar.
            horizontalAlignment: root.hasProgress ? Text.AlignRight : Text.AlignLeft
            anchors.verticalCenter: parent.verticalCenter
            text: root.message
            font: messageMetrics.font
            color: Commons.Color.popups.text
            elide: Text.ElideRight
            maximumLineCount: 1
          }
        }

        // ---- The mixer: one disclosure row, then app cards ----
        Rectangle {
          id: mixerButton
          visible: root.mixerMenu
          width: parent.width
          height: Style.space(36)
          radius: Style.cornerRadius
          color: Util.alpha(Commons.Color.popups.text,
            mixerHover.hovered ? 0.12 : (root.mixerOpen ? 0.08 : 0.06))

          Item {
            anchors.fill: parent
            anchors.leftMargin: Style.space(12)
            anchors.rightMargin: Style.space(12)

            Row {
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(8)

              Text {
                textFormat: Text.PlainText
                text: "󰒓"
                color: Commons.Color.accent
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                textFormat: Text.PlainText
                text: Commons.I18n.t("audio.apps")
                color: Commons.Color.popups.text
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                font.bold: true
                font.letterSpacing: 1.2
                anchors.verticalCenter: parent.verticalCenter
              }

              Rectangle {
                width: Math.max(Style.space(16), countLabel.implicitWidth + Style.space(8))
                height: Style.space(16)
                radius: height / 2
                color: Util.alpha(Commons.Color.accent, 0.16)
                anchors.verticalCenter: parent.verticalCenter

                Text {
                  id: countLabel
                  anchors.centerIn: parent
                  textFormat: Text.PlainText
                  text: Commons.I18n.formatNumber(root.sourceRows.length)
                  color: Commons.Color.accent
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  font.bold: true
                }
              }
            }

            Text {
              textFormat: Text.PlainText
              text: root.mixerOpen ? "󰅃" : "󰅀"
              color: Util.alpha(Commons.Color.popups.text, 0.55)
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          HoverHandler { id: mixerHover }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.setMixerOpen(!root.mixerOpen)
          }
        }

        // The app list scrolls once a sixth card would exceed the cap. The
        // scrollbar is thin and only appears when there is more to reach.
        ScrollView {
          id: sourceScroll
          visible: root.showSources
          width: parent.width
          height: visible ? Math.min(sourceList.implicitHeight, root.sourceListMaxHeight) : 0
          clip: true

          // A row slider owns its drag; the view only steals drags when there
          // is actually more content to scroll.
          Binding {
            target: sourceScroll.contentItem
            property: "interactive"
            value: sourceList.implicitHeight > sourceScroll.height
          }

          ScrollBar.horizontal: ScrollBar {
            policy: ScrollBar.AlwaysOff
          }

          ScrollBar.vertical: ScrollBar {
            id: sourceScrollBar
            policy: sourceList.implicitHeight > sourceScroll.height
              ? ScrollBar.AlwaysOn
              : ScrollBar.AlwaysOff
            width: Style.space(3)
            padding: 0

            contentItem: Rectangle {
              implicitWidth: Style.space(3)
              radius: width / 2
              color: Util.alpha(Commons.Color.popups.text, sourceScrollBar.pressed ? 0.45 : 0.2)
            }

            background: Item {}
          }

          Column {
            id: sourceList
            width: sourceScroll.availableWidth
            spacing: root.sourceListSpacing

            Repeater {
              id: sourceRepeater
              model: root.sourceRows

              SourceRow {
                required property var modelData
                source: modelData
              }
            }
          }
        }
      }

      HoverHandler {
        id: cardHover
        onHoveredChanged: {
          root.cardHovered = hovered
          if (hovered) {
            // Only the app mixer is meant to stay while the pointer is inside;
            // brightness, microphone and media notifications keep their own
            // duration.
            if (root.mixerMenu) hideTimer.stop()
          } else if (root.opened && root.mixerMenu) {
            hideTimer.restart()
          }
        }
      }
    }
  }

  // One controllable application in the volume OSD. The row keeps only the
  // stream ids and names from the snapshot; every binding resolves the live
  // nodes again, so dragging a slider does not fight the snapshot it came from.
  component SourceRow: Rectangle {
    id: sourceRow
    required property var source

    readonly property var sourceNodes: root.nodesForSource(source)
    readonly property real sourceVolume: AudioModel.groupVolume(sourceNodes)
    readonly property bool sourceMuted: AudioModel.groupMuted(sourceNodes)
    readonly property string sourceWorkspaceLabel: AudioModel.workspaceShortLabel(
      AudioModel.groupWorkspaces(sourceNodes, root.workspaceWindows), Commons.I18n.formatNumber)

    width: parent ? parent.width : 0
    implicitHeight: sourceInner.implicitHeight + Style.space(20)
    height: implicitHeight
    radius: Style.cornerRadius
    color: Util.alpha(Commons.Color.popups.text, sourceHover.hovered ? 0.08 : 0.05)

    Behavior on color {
      ColorAnimation { duration: Style.duration(120); easing.type: Easing.InOutQuad }
    }

    HoverHandler { id: sourceHover }

    Column {
      id: sourceInner
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(10)
      spacing: Style.space(4)

      Row {
        width: parent.width
        spacing: Style.space(4)
        opacity: sourceRow.sourceMuted ? 0.55 : 1.0

        Item {
          id: sourceIcon
          width: Style.space(24)
          height: Style.space(24)
          anchors.verticalCenter: parent.verticalCenter

          Image {
            id: sourceImage
            anchors.fill: parent
            source: sourceRow.source ? sourceRow.source.icon : ""
            visible: !!sourceRow.source && String(sourceRow.source.icon || "") !== ""
            fillMode: Image.PreserveAspectFit
            sourceSize.width: Math.round(Style.space(24) * 2)
            sourceSize.height: Math.round(Style.space(24) * 2)
            smooth: true
          }

          Rectangle {
            anchors.fill: parent
            visible: !sourceImage.visible
            radius: Style.spacing.labelGap
            color: Util.alpha(Commons.Color.popups.text, 0.12)

            Text {
              anchors.centerIn: parent
              textFormat: Text.PlainText
              text: sourceRow.source ? sourceRow.source.initial : "?"
              color: Commons.Color.popups.text
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: true
            }
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleSourceMuted(sourceRow.source)
          }
        }

        Column {
          width: parent.width - sourceIcon.width - sourcePct.width - sourceMute.width - Style.space(12)
          anchors.verticalCenter: parent.verticalCenter
          spacing: 0

          Row {
            width: parent.width
            spacing: Style.space(4)

            Text {
              textFormat: Text.PlainText
              text: sourceRow.source ? sourceRow.source.label : ""
              color: Commons.Color.popups.text
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              elide: Text.ElideRight
              width: parent.width - (sourceWorkspace.visible ? sourceWorkspace.width + parent.spacing : 0)
            }

            // The workspace the application's window is on, so two players of
            // the same name stay tellable apart in the notification too.
            Item {
              id: sourceWorkspace
              visible: sourceRow.sourceWorkspaceLabel !== ""
              width: visible ? sourceWorkspaceRow.implicitWidth + Style.space(10) : 0
              height: Style.space(16)
              anchors.verticalCenter: parent.verticalCenter

              Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Util.alpha(Commons.Color.popups.text, 0.08)
              }

              Row {
                id: sourceWorkspaceRow
                anchors.centerIn: parent
                spacing: Style.space(3)

                Text {
                  textFormat: Text.PlainText
                  text: "󱂬"
                  color: Util.alpha(Commons.Color.popups.text, 0.5)
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                  textFormat: Text.PlainText
                  text: sourceRow.sourceWorkspaceLabel
                  color: Util.alpha(Commons.Color.popups.text, 0.7)
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  font.bold: true
                  anchors.verticalCenter: parent.verticalCenter
                }
              }
            }
          }

        }

        Text {
          id: sourcePct
          textFormat: Text.PlainText
          text: Commons.I18n.formatNumber(Math.round(sourceRow.sourceVolume * 100)) + "%"
          color: Util.alpha(Commons.Color.popups.text, 0.7)
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          font.bold: true
          width: Math.ceil(sourcePctMetrics.advanceWidth)
          horizontalAlignment: Text.AlignLeft
          anchors.verticalCenter: parent.verticalCenter
        }

        Text {
          id: sourceMute
          textFormat: Text.PlainText
          text: sourceRow.sourceMuted ? "󰝟" : "󰕾"
          color: Commons.Color.popups.text
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
          width: Style.space(16)
          horizontalAlignment: Text.AlignHCenter
          anchors.verticalCenter: parent.verticalCenter

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleSourceMuted(sourceRow.source)
          }
        }
      }

      PanelSlider {
        bar: null
        width: parent.width
        minimum: 0
        maximum: 1
        step: 0.05
        value: sourceRow.sourceVolume
        opacity: sourceRow.sourceMuted ? 0.5 : 1.0
        fillColor: Commons.Color.accent
        trackColor: Util.alpha(Commons.Color.popups.text, 0.18)
        knobColor: Commons.Color.popups.text

        onMoved: function(v) { root.setSourceVolume(sourceRow.source, v) }
        onRightClicked: root.toggleSourceMuted(sourceRow.source)
      }
    }
  }
}
