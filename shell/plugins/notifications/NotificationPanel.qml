// The notification panel: held-back and recent notifications, history and
// preferences. Hosted per monitor by bar/indicators/Dnd.qml; the
// service decides everything, this only draws it and asks for changes.

import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "Store.js" as Store

Item {
  id: root

  required property Item anchorItem
  property QtObject bar: null
  property var service: null

  readonly property bool opened: controller.open
  property bool settingsView: false

  function open() {
    settingsView = false
    controller.show()
  }
  function close() { controller.hide() }
  function toggle() {
    if (controller.open) controller.hide()
    else open()
  }

  PanelController { id: controller }
  Component.onDestruction: if (service) service.notePanel(root, false)

  // ------------------------------------------------------------- state
  readonly property int heldRevision: service ? service.heldRevision : 0
  readonly property int historyRevision: service ? service.historyRevision : 0
  readonly property bool silenced: service ? service.doNotDisturb : false
  readonly property bool codesLetThrough: service ? service.codesBypassQuiet : true
  readonly property var preferences: service ? service.preferences : ({})

  readonly property var recent: service ? service.recentForPanel(service.recentCount) : []
  readonly property var history: { historyRevision; return service ? service.historyRows : [] }
  readonly property var sources: { heldRevision; return service ? service.quietSources(service.sourceLimit) : [] }

  property string expandedKey: ""
  property bool recentExpanded: false
  property bool historyExpanded: false
  property int cursorAt: 0
  property bool cursorLive: false

  onSilencedChanged: if (silenced) recentExpanded = false
  onOpenedChanged: {
    if (service) service.notePanel(root, opened)
    cursorAt = 0; cursorLive = false; expandedKey = ""
    recentExpanded = false
    historyExpanded = false
    if (!opened) settingsView = false
    // Read on opening: the panel is the only thing that asks.
    if (opened && service) {
      service.refreshHeld()
      service.refreshHistory()
    }
  }
  onSettingsViewChanged: {
    // The panel focuses its content only when it opens; a view switch moves
    // focus itself once bindings settle.
    Qt.callLater(function() {
      if (root.opened && panel.loadedContent) panel.loadedContent.forceActiveFocus()
    })
  }

  // ------------------------------------------------------------- looks
  readonly property color panelFg: Commons.Color.popups.text
  readonly property color dim: Qt.darker(panelFg, 1.4)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property color silencedColour: Commons.Color.urgent

  readonly property string bell: "\u{f009a}"
  readonly property string bellOff: "\u{f009b}"
  readonly property string keyGlyph: "\u{f0306}"
  readonly property string keyOff: "\u{f0308}"
  readonly property string chevronDown: "\u{f0140}"
  readonly property string chevronUp: "\u{f0143}"

  // ------------------------------------------------------------- words
  function clockTime(when) {
    var locale = Qt.locale(I18n.formatLocale)
    return locale.toString(when, locale.timeFormat(Locale.ShortFormat))
  }
  readonly property string stateLine: silenced ? I18n.t("notifications.dndOn") : I18n.t("notifications.enabled")

  // ------------------------------------------------------------- preferences
  readonly property var availableScreens: Quickshell.screens || []
  readonly property string configuredDisplayMode: preferences.displayMode || "active"
  readonly property string configuredDisplayName: preferences.displayName || ""
  readonly property bool configuredDisplayPresent: {
    if (configuredDisplayName === "") return false
    for (var i = 0; i < availableScreens.length; i++)
      if (availableScreens[i] && String(availableScreens[i].name || "") === configuredDisplayName) return true
    return false
  }
  readonly property string displayChoice: configuredDisplayMode === "specific"
    ? "output:" + configuredDisplayName : configuredDisplayMode
  readonly property var displayOptions: {
    var options = [
      { value: "active", label: I18n.t("notifications.displayActive") },
      { value: "all", label: I18n.t("notifications.displayAll") }
    ]
    for (var i = 0; i < availableScreens.length; i++) {
      var name = String(availableScreens[i].name || "")
      if (name) options.push({ value: "output:" + name, label: name })
    }
    if (configuredDisplayMode === "specific" && !configuredDisplayPresent)
      options.push({ value: displayChoice, label: configuredDisplayName
        ? I18n.t("notifications.displayDisconnected").arg(configuredDisplayName)
        : I18n.t("notifications.displaySelect") })
    return options
  }
  readonly property string displayExplanation: configuredDisplayMode === "all"
    ? I18n.t("notifications.displayAllHint")
    : configuredDisplayMode === "specific" && configuredDisplayPresent
      ? I18n.t("notifications.displaySpecificHint").arg(configuredDisplayName)
      : configuredDisplayMode === "specific"
        ? I18n.t("notifications.displayMissingHint")
        : I18n.t("notifications.displayActiveHint")

  function selectDisplay(value) {
    if (!service) return
    if (value === "active" || value === "all") {
      service.setSetting("displayMode", value)
      return
    }
    if (value.indexOf("output:") !== 0) return
    var name = value.slice(7)
    // One write, so it never passes through specific-without-a-name.
    if (name) service.setSettings({ displayName: name, displayMode: "specific" })
  }

  // ------------------------------------------------------------- the panel
  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight, Style.space(520))

    content: PanelKeyCatcher {
      anchors.fill: parent
      implicitHeight: column.implicitHeight
      onCloseRequested: controller.hide()
      onMoveRequested: function(dx, dy) {
        if (root.settingsView || dy === 0 || root.sources.length === 0) return
        root.cursorAt = Math.max(0, Math.min(root.sources.length - 1, root.cursorAt + dy))
        root.cursorLive = true
      }
      // Keys act only on a keyboard-armed cursor row.
      onActivateRequested: {
        if (root.settingsView || !root.cursorLive || root.cursorAt >= root.sources.length) return
        var key = root.sources[root.cursorAt].key
        root.expandedKey = root.expandedKey === key ? "" : key
      }

      Flickable {
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
          width: parent.width
          spacing: Style.space(12)

          // --------------------------------------------------- preferences
          Column {
            visible: root.settingsView
            width: parent.width
            spacing: Style.spacing.huge

            PanelHero {
              width: parent.width
              title: I18n.t("notifications.title")
              meta: I18n.t("notifications.preferences")
              foreground: root.panelFg
              fontFamily: root.fontFamily
              trailingControl: Component {
                ActionButton {
                  iconText: "\u{f00d}"
                  tooltipText: I18n.t("notifications.closePreferences")
                  onClicked: root.settingsView = false
                }
              }
            }

            Column {
              width: parent.width
              spacing: Style.spacing.lg

              Picker {
                width: parent.width
                label: I18n.t("notifications.display")
                value: root.displayChoice
                options: root.displayOptions
                foreground: root.panelFg
                fontFamily: root.fontFamily
                onPicked: function(value) { root.selectDisplay(value) }
              }

              Hint { text: root.displayExplanation }
            }

            PanelSeparator { foreground: root.panelFg }

            SwitchRow {
              label: I18n.t("notifications.stepAside")
              hint: I18n.t("notifications.stepAsideHint")
              checked: root.preferences.fullscreenOverlay !== "off"
              onToggled: if (root.service) root.service.setSetting("fullscreenOverlay", root.preferences.fullscreenOverlay === "off" ? "all" : "off")
            }

          }

          // --------------------------------------------------- notifications
          Column {
            visible: !root.settingsView
            width: parent.width
            spacing: Style.space(12)

            PanelHero {
              id: hero
              width: parent.width
              title: I18n.t("notifications.title")
              meta: root.stateLine
              foreground: root.panelFg
              fontFamily: root.fontFamily
              iconOpacity: root.silenced ? 1.0 : 0.5
              // A fixed square: the two bells differ in width.
              iconComponent: Component {
                Item {
                  implicitWidth: hero.iconSize
                  implicitHeight: hero.iconSize

                  Text {
                    textFormat: Text.PlainText
                    anchors.centerIn: parent
                    text: root.silenced ? root.bellOff : root.bell
                    color: root.silenced ? root.silencedColour : root.panelFg
                    font.family: root.fontFamily
                    font.pixelSize: hero.iconSize
                  }
                }
              }

              trailingControl: Component {
                Row {
                  spacing: Style.space(6)

                  // Whether verification codes get through Do Not Disturb.
                  ActionButton {
                    visible: root.silenced
                    anchors.verticalCenter: parent.verticalCenter
                    iconText: root.codesLetThrough ? root.keyGlyph : root.keyOff
                    tooltipText: root.codesLetThrough
                      ? I18n.t("notifications.blockCodes")
                      : I18n.t("notifications.allowCodes")
                    foreground: root.codesLetThrough ? root.panelFg : root.dim
                    onClicked: if (root.service) root.service.setCodesBypassQuiet(!root.codesLetThrough)
                  }

                  ActionButton {
                    anchors.verticalCenter: parent.verticalCenter
                    iconText: "\u{f0493}"
                    tooltipText: I18n.t("notifications.settings")
                    onClicked: root.settingsView = true
                  }

                  // On means notifications are coming through.
                  ToggleSwitch {
                    anchors.verticalCenter: parent.verticalCenter
                    checked: !root.silenced
                    foreground: root.panelFg
                    onToggled: if (root.service) root.service.setDoNotDisturb(!root.silenced)
                  }
                }
              }
            }

            // --------------------------------------------------- recent
            PanelSeparator { visible: !root.silenced; foreground: root.panelFg }

            SectionToggle {
              visible: !root.silenced
              text: I18n.t("notifications.recentHeader").arg(I18n.formatNumber(root.recent.length))
              expanded: root.recentExpanded
              showTooltip: I18n.t("notifications.showRecent")
              hideTooltip: I18n.t("notifications.hideRecent")
              onToggled: root.recentExpanded = !root.recentExpanded
            }

            Hint {
              visible: !root.silenced && root.recentExpanded && root.recent.length === 0
              text: I18n.t("notifications.noneRecent")
            }

            Column {
              visible: !root.silenced && root.recentExpanded
              width: parent.width
              spacing: Style.spacing.md

              Repeater {
                model: !root.settingsView && !root.silenced && root.recentExpanded ? root.recent : []

                EntryCard {
                  required property var modelData
                  entry: modelData
                }
              }
            }

            // --------------------------------------------------- held back
            PanelSeparator { visible: root.silenced; foreground: root.panelFg }

            PanelSectionHeader {
              visible: root.silenced
              text: I18n.t("notifications.heldBack")
              foreground: root.panelFg
              fontFamily: root.fontFamily
            }

            Hint {
              visible: root.silenced && root.sources.length === 0
              text: I18n.t("notifications.noneHeld")
            }

            Column {
              visible: root.silenced
              width: parent.width
              spacing: Style.spacing.sm

              Repeater {
                model: root.sources

                Column {
                  id: line
                  required property var modelData
                  required property int index
                  readonly property bool expanded: root.expandedKey === modelData.key
                  width: parent.width
                  spacing: 0

                  CursorSurface {
                    width: parent.width
                    height: Math.max(label.implicitHeight, controls.implicitHeight, Style.spacing.controlHeight)
                    hasCursor: root.cursorLive && root.cursorAt === line.index
                    foreground: root.panelFg

                    Column {
                      id: label
                      anchors.left: parent.left
                      anchors.verticalCenter: parent.verticalCenter
                      width: parent.width - controls.width - Style.spacing.xl

                      Text {
                        textFormat: Text.PlainText
                        width: parent.width
                        text: line.modelData.label
                        color: root.panelFg
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.bodySmall
                        elide: Text.ElideRight
                      }

                      // What it has held so far.
                      Caption {
                        readonly property int count: line.modelData.held.length
                        width: parent.width
                        text: I18n.tn("notifications.heldCount", count).arg(I18n.formatNumber(count))
                        elide: Text.ElideRight
                      }
                    }

                    MouseArea {
                      anchors.fill: label
                      enabled: line.modelData.held.length > 0
                      hoverEnabled: true
                      cursorShape: Qt.PointingHandCursor
                      onContainsMouseChanged: if (containsMouse) {
                        root.cursorAt = line.index
                        root.cursorLive = false
                      }
                      onClicked: root.expandedKey = line.expanded ? "" : line.modelData.key
                    }

                    ActionButton {
                      id: controls
                      anchors.right: parent.right
                      anchors.verticalCenter: parent.verticalCenter
                      iconText: line.expanded ? root.chevronUp : root.chevronDown
                      tooltipText: line.expanded ? I18n.t("notifications.hideHeld") : I18n.t("notifications.showHeld")
                      onClicked: root.expandedKey = line.expanded ? "" : line.modelData.key
                    }
                  }

                  // What it held, one line each.
                  Item {
                    width: parent.width
                    height: line.expanded ? heldList.implicitHeight + Style.spacing.lg : 0
                    visible: height > 0
                    clip: true
                    Behavior on height { NumberAnimation { duration: Style.duration(170); easing.type: Easing.OutCubic } }

                    Column {
                      id: heldList
                      width: parent.width - Style.spacing.xxl
                      x: LayoutMirroring.enabled ? 0 : Style.spacing.xxl
                      y: Style.spacing.sm
                      spacing: Style.spacing.hairline

                      Repeater {
                        model: line.expanded ? line.modelData.held : []

                        Caption {
                          required property var modelData
                          width: parent.width
                          text: {
                            var when = root.clockTime(new Date(Number(modelData.ts) * 1000))
                            var redacted = Store.redacted(modelData)
                            var head = redacted ? I18n.t("notifications.redactedSummary") : String(modelData.summary || "")
                            var rest = redacted ? I18n.t("notifications.redactedBody") : String(modelData.bodyLine || "")
                            if (head && rest) return when + "  " + head + " · " + rest
                            return when + "  " + (head || rest)
                          }
                          elide: Text.ElideRight
                        }
                      }
                    }
                  }
                }
              }
            }

            // --------------------------------------------------- history
            PanelSeparator { foreground: root.panelFg }

            SectionToggle {
              text: I18n.t("notifications.historyHeader").arg(I18n.formatNumber(root.history.length))
              expanded: root.historyExpanded
              showTooltip: I18n.t("notifications.showHistory")
              hideTooltip: I18n.t("notifications.hideHistory")
              onToggled: root.historyExpanded = !root.historyExpanded
            }

            Hint {
              visible: root.historyExpanded && root.history.length === 0
              text: I18n.t("notifications.noneHistory")
            }

            Column {
              visible: root.historyExpanded
              width: parent.width
              spacing: Style.spacing.md

              // Collapsed instantiates nothing.
              Repeater {
                model: !root.settingsView && root.historyExpanded ? root.history : []

                EntryCard {
                  required property var modelData
                  entry: modelData
                  expandable: true
                }
              }
            }
          }
        }
      }
    }
  }

  // ------------------------------------------------------------- pieces
  component Hint: Text {
    width: parent ? parent.width : 0
    textFormat: Text.PlainText
    color: root.dim
    font.family: root.fontFamily
    font.pixelSize: Style.font.bodySmall
    wrapMode: Text.WordWrap
  }

  component Caption: Text {
    textFormat: Text.PlainText
    color: root.dim
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
  }

  component ActionButton: PanelActionButton {
    foreground: root.panelFg
    fontFamily: root.fontFamily
  }

  component SwitchRow: Column {
    id: switchRow
    property string label: ""
    property string hint: ""
    property bool checked: false
    signal toggled()
    width: parent ? parent.width : 0
    spacing: Style.spacing.lg

    Row {
      width: parent.width
      spacing: Style.spacing.controlGap

      Text {
        width: parent.width - toggle.width - parent.spacing
        anchors.verticalCenter: parent.verticalCenter
        text: switchRow.label
        textFormat: Text.PlainText
        color: root.panelFg
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        wrapMode: Text.WordWrap
      }

      ToggleSwitch {
        id: toggle
        anchors.verticalCenter: parent.verticalCenter
        checked: switchRow.checked
        foreground: root.panelFg
        onToggled: switchRow.toggled()
      }
    }

    Hint { text: switchRow.hint }
  }

  component SectionToggle: Item {
    id: section
    property string text: ""
    property bool expanded: false
    property string showTooltip: ""
    property string hideTooltip: ""
    signal toggled()
    width: parent ? parent.width : 0
    height: Math.max(heading.implicitHeight, chevron.implicitHeight)

    PanelSectionHeader {
      id: heading
      anchors.left: parent.left
      anchors.right: chevron.left
      anchors.verticalCenter: parent.verticalCenter
      text: section.text
      foreground: root.panelFg
      fontFamily: root.fontFamily
    }

    MouseArea {
      anchors { left: parent.left; right: chevron.left; top: parent.top; bottom: parent.bottom }
      cursorShape: Qt.PointingHandCursor
      onClicked: section.toggled()
    }

    ActionButton {
      id: chevron
      anchors.right: parent.right
      // The scrollbar owns the right-edge hit area even over this row.
      anchors.rightMargin: Style.space(8)
      anchors.verticalCenter: parent.verticalCenter
      iconText: section.expanded ? root.chevronUp : root.chevronDown
      tooltipText: section.expanded ? section.hideTooltip : section.showTooltip
      focusable: true
      onClicked: section.toggled()
    }
  }

  // A notification that already left the screen.
  component EntryCard: BorderSurface {
    id: entryCard
    property var entry: ({})
    property bool expandable: false
    property bool open: false
    width: parent ? parent.width : 0
    leftPadding: Style.spacing.controlPaddingX
    rightPadding: Style.spacing.controlPaddingX
    topPadding: Style.spacing.md
    bottomPadding: Style.spacing.md
    height: entryText.implicitHeight + contentTopInset + contentBottomInset
    radius: Style.cornerRadius
    color: Style.normalFillFor(root.panelFg, Commons.Color.accent)
    borderSpec: Border.controlSpec("normal", root.panelFg, Commons.Color.accent)

    MouseArea {
      anchors.fill: parent
      enabled: entryCard.expandable
      cursorShape: entryCard.expandable ? Qt.PointingHandCursor : Qt.ArrowCursor
      onClicked: entryCard.open = !entryCard.open
    }

    Column {
      id: entryText
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.leftMargin: entryCard.contentLeftInset
      anchors.rightMargin: entryCard.contentRightInset
      anchors.topMargin: entryCard.contentTopInset
      spacing: Style.spacing.xs

      Caption {
        width: parent.width
        text: (entryCard.entry.source || entryCard.entry.app || "") + " · "
              + root.clockTime(new Date(Number(entryCard.entry.ts) * 1000))
        elide: Text.ElideRight
      }

      Text {
        width: parent.width
        text: Store.redacted(entryCard.entry) ? I18n.t("notifications.redactedSummary") : (entryCard.entry.summary || "")
        textFormat: Text.PlainText
        color: root.panelFg
        font.family: "Liberation Sans"
        font.pixelSize: Style.font.title
        font.bold: true
        elide: Text.ElideRight
      }

      Text {
        visible: text !== ""
        width: parent.width
        text: Store.redacted(entryCard.entry) ? I18n.t("notifications.redactedBody") : (entryCard.entry.bodyLine || "")
        textFormat: Text.PlainText
        color: Qt.darker(root.panelFg, 1.15)
        font.family: "Liberation Sans"
        font.pixelSize: Style.font.title
        wrapMode: Text.WordWrap
        maximumLineCount: entryCard.open ? 2147483647 : 2
        elide: entryCard.open ? Text.ElideNone : Text.ElideRight
      }
    }
  }
}
