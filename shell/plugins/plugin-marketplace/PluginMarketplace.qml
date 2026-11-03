import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "MarketplaceModel.js" as MarketplaceModel

Item {
  id: root

  property bool opened: false
  property string selectionFile: ""
  property string doneFile: ""
  property var plugins: []
  property string query: ""
  property string category: ""
  property string kind: ""
  property bool installable: false
  property bool verified: false
  property string installed: ""
  property string sort: "relevance"
  property int selectedIndex: 0
  property int previewIndex: 0
  property bool previewExpanded: false
  property color background: Commons.Color.menu.background
  property color foreground: Commons.Color.menu.text
  property color border: Commons.Color.menu.border
  property color scrim: Commons.Color.menu.scrim
  property color accent: Commons.Color.accent

  readonly property var visiblePlugins: MarketplaceModel.filtered(plugins, {
    query: query, category: category, kind: kind, installable: installable,
    verified: verified, installed: installed, sort: sort
  })
  readonly property var categoryOptions: MarketplaceModel.options(plugins, "category")
  readonly property var kindOptions: MarketplaceModel.options(plugins, "kind")
  readonly property var selectedPlugin: selectedIndex >= 0 && selectedIndex < visiblePlugins.length ? visiblePlugins[selectedIndex] : null
  readonly property string metadataLine: {
    if (!selectedPlugin) return ""
    return [
      selectedPlugin.kind,
      selectedPlugin.category,
      selectedPlugin.author ? Commons.I18n.t("marketplace.by").arg(selectedPlugin.author) : "",
      selectedPlugin.version ? Commons.I18n.t("marketplace.version").arg(selectedPlugin.version) : "",
      selectedPlugin.stars != null ? Commons.I18n.t("marketplace.stars").arg(Commons.I18n.formatNumber(selectedPlugin.stars, 0)) : ""
    ].filter(Boolean).join(" · ")
  }
  readonly property var selectedPreviewImages: selectedPlugin ? selectedPlugin.previewImages : []
  readonly property string selectedPreview: selectedPreviewImages.length > 0 ? selectedPreviewImages[Math.max(0, Math.min(previewIndex, selectedPreviewImages.length - 1))] : (selectedPlugin ? selectedPlugin.previewPath : "")

  function loadPlugins(value) {
    var rows = Array.isArray(value) ? value : []
    plugins = MarketplaceModel.normalize({ plugins: rows }, [])
  }
  function optionRows(values, allLabel) {
    var rows = [{ value: "", label: allLabel }]
    for (var index = 0; index < values.length; index++) {
      rows.push({ value: values[index], label: values[index] })
    }
    return rows
  }

  FileView {
    id: catalogFile
    watchChanges: false
    printErrors: false
    onLoaded: {
      try { root.loadPlugins(JSON.parse(text())) } catch (e) { root.loadPlugins([]) }
    }
  }
  function finishRequest(path) {
    if (path) Quickshell.execDetached(["bash", "-c", ": > " + Util.shellQuote(path)])
  }
  function open(payloadJson) {
    if (opened && doneFile) finishRequest(doneFile)
    var payload = {}
    try { payload = JSON.parse(payloadJson || "{}") } catch (e) { payload = {} }
    var catalogPath = String(payload.catalogFile || "")
    if (catalogPath) {
      catalogFile.path = catalogPath
      catalogFile.reload()
    } else {
      root.loadPlugins(payload.plugins)
    }
    selectionFile = String(payload.selectionFile || "")
    doneFile = String(payload.doneFile || "")
    query = ""; category = ""; kind = ""; installable = false; verified = false; installed = ""; sort = "relevance"; selectedIndex = 0
    opened = true
    Qt.callLater(function() { search.forceActiveFocus() })
  }

  function close() { cancel() }
  function cancel() {
    var done = doneFile
    selectionFile = ""; doneFile = ""; opened = false
    if (done) finishRequest(done)
  }
  // Badges and the primary action travel from the model as catalog keys, since
  // it has no translator. Each is spelled out here so the shell catalog stays
  // fully referenced, and a language change re-runs these lookups with the
  // rest of the card.
  function marketplaceText(key) {
    switch (key) {
    case "marketplace.badgeInstalled": return Commons.I18n.t("marketplace.badgeInstalled")
    case "marketplace.badgeInstallable": return Commons.I18n.t("marketplace.badgeInstallable")
    case "marketplace.badgeManualSetup": return Commons.I18n.t("marketplace.badgeManualSetup")
    case "marketplace.badgeVerified": return Commons.I18n.t("marketplace.badgeVerified")
    case "marketplace.viewDetails": return Commons.I18n.t("marketplace.viewDetails")
    case "marketplace.installPlugin": return Commons.I18n.t("marketplace.installPlugin")
    case "marketplace.setupInstructions": return Commons.I18n.t("marketplace.setupInstructions")
    }
    return ""
  }
  function choose(action) {
    if (!selectedPlugin || !selectionFile || !doneFile) return
    var selected = selectedPlugin.id
    var operation = String(action || "")
    var file = selectionFile
    var done = doneFile
    selectionFile = ""; doneFile = ""; opened = false
    result.command = ["bash", "-c", "printf '%s\\t%s\\n' " + Util.shellQuote(operation) + " " + Util.shellQuote(selected) + " > " + Util.shellQuote(file) + "; : > " + Util.shellQuote(done)]
    result.running = true
  }
  function move(delta) {
    if (visiblePlugins.length === 0) { selectedIndex = 0; return }
    selectedIndex = Math.max(0, Math.min(visiblePlugins.length - 1, selectedIndex + delta))
  }
  function resetSelection() { selectedIndex = 0 }
  function resetPreview() { previewIndex = 0; previewExpanded = false }
  function previousPreview() {
    if (selectedPreviewImages.length > 1) previewIndex = (previewIndex + selectedPreviewImages.length - 1) % selectedPreviewImages.length
  }
  function nextPreview() {
    if (selectedPreviewImages.length > 1) previewIndex = (previewIndex + 1) % selectedPreviewImages.length
  }

  onQueryChanged: resetSelection()
  onCategoryChanged: resetSelection()
  onKindChanged: resetSelection()
  onInstallableChanged: resetSelection()
  onVerifiedChanged: resetSelection()
  onInstalledChanged: resetSelection()
  onSelectedIndexChanged: {
    resetPreview()
    list.currentIndex = selectedIndex
  }

  Process { id: result }

  PanelWindow {
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-plugin-marketplace"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle { anchors.fill: parent; color: root.scrim }
    MouseArea { anchors.fill: parent; onClicked: root.cancel() }

    BorderSurface {
      id: card
      anchors.centerIn: parent
      width: Math.min(parent.width, Style.space(780))
      height: Math.min(parent.height - Style.gapsOut * 2, Style.space(560))
      color: root.background
      borderSpec: Border.surfaceSpec("menu", "border", root.border, Math.max(1, Style.space(2)))
      radius: Style.cornerRadius
      padding: Style.spacing.panelPadding
      MouseArea { anchors.fill: parent; onClicked: {} }

      Keys.priority: Keys.AfterItem
      Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) { if (root.query) root.query = ""; else root.cancel(); event.accepted = true }
        else if (event.key === Qt.Key_Down) { root.move(1); event.accepted = true }
        else if (event.key === Qt.Key_Up) { root.move(-1); event.accepted = true }
        else if (event.key === Qt.Key_Left) { root.previousPreview(); event.accepted = true }
        else if (event.key === Qt.Key_Right) { root.nextPreview(); event.accepted = true }
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { root.choose(); event.accepted = true }
      }

      Column {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: Style.spacing.md
        Text { text: Commons.I18n.t("marketplace.title"); color: root.foreground; font.family: Style.font.family; font.pixelSize: Style.font.title; font.bold: true }
        TextField {
          id: search
          width: parent.width
          placeholderText: Commons.I18n.t("marketplace.search")
          text: root.query
          onTextEdited: root.query = text
          onAccepted: root.choose()
        }
        Flow {
          width: parent.width
          spacing: Style.spacing.sm
          Dropdown { width: Style.space(150); showLabel: false; value: root.category; options: root.optionRows(root.categoryOptions, Commons.I18n.t("marketplace.allCategories")); onChanged: function(value) { root.category = value } }
          Dropdown { width: Style.space(140); showLabel: false; value: root.kind; options: root.optionRows(root.kindOptions, Commons.I18n.t("marketplace.allKinds")); onChanged: function(value) { root.kind = value } }
          Button { text: Commons.I18n.t("marketplace.installable"); selected: root.installable; onClicked: root.installable = !root.installable }
          Button { text: Commons.I18n.t("marketplace.verified"); selected: root.verified; onClicked: root.verified = !root.verified }
          Dropdown { width: Style.space(130); showLabel: false; value: root.installed; options: [{value:"",label:Commons.I18n.t("marketplace.allPlugins")},{value:"available",label:Commons.I18n.t("marketplace.notInstalled")},{value:"installed",label:Commons.I18n.t("marketplace.installed")}]; onChanged: function(value) { root.installed = value } }
          Dropdown { width: Style.space(120); showLabel: false; value: root.sort; options: [{value:"relevance",label:Commons.I18n.t("marketplace.relevance")},{value:"stars",label:Commons.I18n.t("marketplace.mostStars")},{value:"newest",label:Commons.I18n.t("marketplace.newest")}]; onChanged: function(value) { root.sort = value } }
        }
        Row {
          width: parent.width
          height: parent.height - y
          spacing: Style.spacing.md
          ListView {
            id: list
            width: Math.round(parent.width * 0.45)
            height: parent.height
            model: root.visiblePlugins
            clip: true
            spacing: Style.spacing.xs
            currentIndex: root.selectedIndex
            onCurrentIndexChanged: if (currentIndex >= 0 && currentIndex !== root.selectedIndex) root.selectedIndex = currentIndex
            delegate: Item {
              required property var modelData
              required property int index
              width: list.width
              height: Style.space(72)
              id: pluginRow
              property int rowIndex: index
              Rectangle {
                anchors.fill: parent
                color: root.selectedIndex == pluginRow.rowIndex ? Util.alpha(root.accent, 0.50) : "transparent"
                border.width: root.selectedIndex == pluginRow.rowIndex ? Math.max(1, Style.space(1)) : 0
                border.color: root.accent
                radius: Style.cornerRadius
              }
              Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: root.selectedIndex == pluginRow.rowIndex ? Style.space(5) : 0
                color: root.accent
                radius: Style.cornerRadius
              }
              Text {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: Style.spacing.controlPaddingX
                anchors.topMargin: Style.spacing.xs
                visible: root.selectedIndex == pluginRow.rowIndex
                text: Commons.I18n.t("marketplace.selected").toUpperCase()
                color: root.accent
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: true
              }
              Text {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: Style.spacing.controlPaddingX
                anchors.bottomMargin: Style.spacing.xs
                visible: modelData.installed
                text: Commons.I18n.t("marketplace.installedBadge").toUpperCase()
                color: root.accent
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: true
              }
              Column {
                anchors.left: parent.left; anchors.right: parent.right; anchors.leftMargin: Style.spacing.controlPaddingX + (root.selectedIndex == pluginRow.rowIndex ? Style.space(5) : 0); anchors.rightMargin: modelData.installed ? Style.space(80) : Style.spacing.controlPaddingX; anchors.verticalCenter: parent.verticalCenter
                Text { width: parent.width; text: modelData.name; textFormat: Text.PlainText; color: root.foreground; font.family: Style.font.family; font.pixelSize: Style.font.body; font.bold: true; elide: Text.ElideRight }
                Text { width: parent.width; text: modelData.description || (modelData.kind + " · " + modelData.category); textFormat: Text.PlainText; color: Qt.darker(root.foreground, 1.35); font.family: Style.font.family; font.pixelSize: Style.font.caption; elide: Text.ElideRight }
              }
              MouseArea {
                anchors.fill: parent
                onClicked: {
                  var alreadySelected = root.selectedIndex == pluginRow.rowIndex
                  root.selectedIndex = pluginRow.rowIndex
                  if (alreadySelected) root.choose()
                }
              }
            }
          }
          Rectangle { width: 1; height: parent.height; color: Util.alpha(root.border, 0.55) }
          Item {
            width: parent.width - list.width - Style.spacing.md * 2 - 1
            height: parent.height
            visible: !!root.selectedPlugin
            ScrollView {
              anchors.fill: parent
              clip: true
              contentWidth: availableWidth
              Column {
                width: parent.width
                spacing: Style.spacing.sm
                Text { width: parent.width; text: root.selectedPlugin ? root.selectedPlugin.name : ""; textFormat: Text.PlainText; color: root.foreground; font.family: Style.font.family; font.pixelSize: Style.font.title; font.bold: true; elide: Text.ElideRight }
              Item {
                id: previewArea
                width: parent.width
                height: Style.space(240)
                Image {
                  id: preview
                  anchors.fill: parent
                  source: root.selectedPreview
                  fillMode: Image.PreserveAspectFit
                  visible: status === Image.Ready
                }
                Rectangle {
                  anchors.fill: parent
                  visible: !preview.visible
                  color: Util.alpha(root.foreground, 0.06)
                  Text { anchors.centerIn: parent; text: Commons.I18n.t("marketplace.noPreview"); color: Qt.darker(root.foreground, 1.4); font.family: Style.font.family }
                }
                MouseArea { anchors.fill: parent; enabled: preview.visible; cursorShape: Qt.PointingHandCursor; onClicked: root.previewExpanded = true }
                Button { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; visible: root.selectedPreviewImages.length > 1; focusable: true; text: "‹"; onClicked: root.previousPreview() }
                Button { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; visible: root.selectedPreviewImages.length > 1; focusable: true; text: "›"; onClicked: root.nextPreview() }
                Text {
                  anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: Style.spacing.xs
                  visible: root.selectedPreviewImages.length > 1
                  text: (root.previewIndex + 1) + " / " + root.selectedPreviewImages.length
                  textFormat: Text.PlainText; color: root.foreground; font.family: Style.font.family; font.pixelSize: Style.font.caption
                }
              }
              Text { width: parent.width; text: root.selectedPlugin ? root.selectedPlugin.description : ""; textFormat: Text.PlainText; color: root.foreground; font.family: Style.font.family; font.pixelSize: Style.font.body; wrapMode: Text.Wrap; maximumLineCount: 3; elide: Text.ElideRight }
              Text { width: parent.width; text: root.metadataLine; textFormat: Text.PlainText; color: Qt.darker(root.foreground, 1.35); font.family: Style.font.family; font.pixelSize: Style.font.caption; wrapMode: Text.Wrap }
              Text { width: parent.width; text: root.selectedPlugin ? MarketplaceModel.badges(root.selectedPlugin).map(function(key) { return root.marketplaceText(key) }).join(" · ") : ""; textFormat: Text.PlainText; color: root.accent; font.family: Style.font.family; font.pixelSize: Style.font.body; font.bold: true }
              property var primaryAction: root.selectedPlugin ? MarketplaceModel.primaryAction(root.selectedPlugin) : ({ labelKey: "", operation: "" })
              Button { text: root.marketplaceText(parent.primaryAction.labelKey); bordered: true; focusable: true; onClicked: root.choose(parent.primaryAction.operation) }
              Button { visible: root.selectedPlugin && root.selectedPlugin.installed; focusable: true; text: Commons.I18n.t("marketplace.uninstall"); onClicked: root.choose("remove") }
              }
            }
          }
        }
      }
    }
    Rectangle {
      anchors.fill: parent
      visible: root.previewExpanded
      color: root.scrim
      z: 1
      MouseArea { anchors.fill: parent; onClicked: root.previewExpanded = false }
      BorderSurface {
        anchors.centerIn: parent
        width: Math.min(parent.width - Style.gapsOut * 2, Style.space(1120))
        height: Math.min(parent.height - Style.gapsOut * 2, Style.space(760))
        color: root.background
        borderSpec: Border.surfaceSpec("menu", "border", root.border, Math.max(1, Style.space(2)))
        radius: Style.cornerRadius
        padding: Style.spacing.panelPadding
        MouseArea { anchors.fill: parent; onClicked: {} }
        Image {
          id: expandedPreview
          anchors.fill: parent
          source: root.selectedPreview
          fillMode: Image.PreserveAspectFit
        }
        Button { anchors.top: parent.top; anchors.right: parent.right; focusable: true; text: Commons.I18n.t("marketplace.close"); onClicked: root.previewExpanded = false }
        Button { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; visible: root.selectedPreviewImages.length > 1; text: "‹"; onClicked: root.previousPreview() }
        Button { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; visible: root.selectedPreviewImages.length > 1; text: "›"; onClicked: root.nextPreview() }
        Text {
          anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: Style.spacing.sm
          visible: root.selectedPreviewImages.length > 1
          text: (root.previewIndex + 1) + " / " + root.selectedPreviewImages.length
          textFormat: Text.PlainText; color: root.foreground; font.family: Style.font.family; font.pixelSize: Style.font.caption
        }
      }
    }
  }
}