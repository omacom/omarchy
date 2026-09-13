import QtQuick
import QtQuick.Controls as Controls
import qs.Ui as Ui
import qs.Commons

FocusScope {
  id: root
  component ActivityIndicator: Item {
    id: activity
    property color foreground: Color.popups.text
    property bool running: true
    readonly property bool animated: visible && running
    implicitWidth: Style.space(12)
    implicitHeight: Style.space(12)
    width: implicitWidth
    height: implicitHeight
    activeFocusOnTab: false
    Canvas {
      id: arc
      anchors.fill: parent
      onPaint: {
        let context = getContext("2d")
        let inset = Math.max(1, Style.space(1))
        context.clearRect(0, 0, width, height)
        context.strokeStyle = activity.foreground
        context.lineWidth = inset
        context.lineCap = "round"
        context.beginPath()
        context.arc(width / 2, height / 2,
          Math.max(1, Math.min(width, height) / 2 - inset),
          -Math.PI * 0.45, Math.PI * 1.25)
        context.stroke()
      }
      Component.onCompleted: requestPaint()
    }
    onForegroundChanged: arc.requestPaint()
    RotationAnimator on rotation {
      running: activity.animated
      from: 0
      to: 360
      duration: 800
      loops: Animation.Infinite
    }
  }
  required property var backend
  signal dismiss()
  property string page: "picker"
  property string search: ""
  property var stagedRemoval: null
  property var pendingRemoval: null
  property var heldView: null
  property var rejectedRemoval: null
  property int pickerSwitchRequestId: 0
  property int additionRequestId: 0
  property var additionResults: null
  // Active removal is one user operation even though it uses two helper
  // actions. Keep both pages on the same confirmed snapshot until the final
  // save readback is available; backend.state can still verify the staged
  // switch without exposing an intermediate saved/runtime split.
  readonly property var view: stagedRemoval && stagedRemoval.confirmedView
    ? stagedRemoval.confirmedView : (heldView || backend.state)
  readonly property var rows: view.layouts || []
  readonly property var editorRows: view.configuredLayouts && view.configuredLayouts.length ? view.configuredLayouts : rows
  readonly property string editorShortcut: view.configuredShortcut || view.shortcut || "custom"
  readonly property string editorDefault: editorRows.length ? editorRows[0].id : ""
  readonly property var defaultOptions: editorRows.map(row => ({
    value: row.id,
    label: row.label + (row.variant ? " — " + row.variantLabel : "")
  }))
  readonly property bool stateFresh: backend.stateFresh
  readonly property bool interactionLocked: backend.busy || stagedRemoval !== null
    || rejectedRemoval !== null || !stateFresh
  implicitHeight: body.implicitHeight
  activeFocusOnTab: true

  function reset() {
    additionRequestId = 0
    additionResults = null
    page = "picker"
    search = ""
    Qt.callLater(function() { root.focusFirst() })
  }
  function focusFirst() {
    if (page === "search") searchField.forceActiveFocus()
    else if (page === "picker" && layoutRepeater.count) layoutRepeater.itemAt(0).forceActiveFocus()
    else backButton.forceActiveFocus()
  }
  function go(where) {
    if (where !== "search") additionRequestId = 0
    additionResults = null
    page = where
    Qt.callLater(function() { root.focusFirst() })
  }
  function layoutLabel(row) {
    if (!row) return "layout"
    return row.label + (row.variant ? " — " + row.variantLabel : "")
  }
  function focusRemove(identity) {
    if (page !== "editor") {
      focusFirst()
      return
    }
    let index = editorRows.findIndex(row => row.id === identity)
    let item = index >= 0 ? editorRepeater.itemAt(index) : null
    if (item) item.focusRemove()
  }
  function focusAfterRemoval() {
    if (page === "editor") addLayout.forceActiveFocus()
    else focusFirst()
  }
  function focusBack() {
    if (page === "picker") focusFirst()
    else backButton.forceActiveFocus()
  }
  function removalPending(identity) {
    return (stagedRemoval && stagedRemoval.removed === identity)
      || (pendingRemoval && pendingRemoval.removed === identity)
  }
  function sameIds(rows, expected) {
    if (!rows || rows.length !== expected.length) return false
    for (let i = 0; i < expected.length; i++)
      if (!rows[i] || rows[i].id !== expected[i]) return false
    return true
  }
  function removalConfirmed(removal) {
    let confirmed = backend.state
    let confirmedRows = confirmed.layouts || []
    let configuredRows = confirmed.configuredLayouts || []
    let active = confirmed.active >= 0 && confirmed.active < confirmedRows.length
      ? confirmedRows[confirmed.active].id : ""
    return stateFresh && sameIds(confirmedRows, removal.layouts)
      && sameIds(configuredRows, removal.layouts)
      && active === removal.survivor && !confirmed.problem
      && !confirmed.pendingRestart
  }
  function finishRemoval(removal) {
    stagedRemoval = null
    heldView = null
    rejectedRemoval = null
    Qt.callLater(root.focusAfterRemoval)
  }
  function rejectRemovalView(removal, message) {
    // A successful helper response is not enough to publish a split model.
    // Retain the last coherent view and keep mutations closed until a later
    // ordinary refresh proves the complete requested state.
    heldView = removal.confirmedView
    rejectedRemoval = removal
    stagedRemoval = null
    backend.error = message
    Qt.callLater(root.focusBack)
  }
  function back() {
    if (page === "picker") root.dismiss()
    else go(page === "editor" || page === "devices" ? "picker" : "editor")
  }
  function ids() { return editorRows.map(row => row.id) }
  function save(next, shortcutValue, revision) {
    if (interactionLocked) return 0
    return backend.save(next, shortcutValue || editorShortcut, revision)
  }
  function switchLayout(index) {
    if (interactionLocked) return
    let requestId = backend.switchTo(index, view.revision)
    if (requestId) pickerSwitchRequestId = requestId
  }
  function remove(index) {
    if (editorRows.length <= 1 || interactionLocked) return
    let next = ids()
    let removed = next[index]
    let removedLabel = layoutLabel(editorRows[index])
    next.splice(index, 1)
    let active = view.active >= 0 && view.active < rows.length ? rows[view.active].id : ""
    if (removed !== active) {
      let requestId = save(next, editorShortcut)
      if (requestId)
        pendingRemoval = {requestId: requestId, removed: removed}
      return
    }

    // Make an active removal two separate compositor operations. A fresh
    // status readback gives the shell time to consume the ordinary layout
    // switch before the later save replaces the live keymap.
    let adjacent = index < editorRows.length - 1 ? index + 1 : index - 1
    let survivor = editorRows[adjacent].id
    let survivorLabel = layoutLabel(editorRows[adjacent])
    let liveIndex = rows.findIndex(row => row.id === survivor)
    if (liveIndex < 0) {
      backend.error = "Switch to a layout that will remain before removing this one."
      return
    }
    let confirmedView = view
    let baseRevision = confirmedView.revision
    stagedRemoval = {phase: "switching", requestId: 0, layouts: next,
      shortcut: editorShortcut, survivor: survivor, baseRevision: baseRevision,
      confirmedView: confirmedView, removed: removed, removedLabel: removedLabel,
      survivorLabel: survivorLabel}
    let requestId = backend.switchTo(liveIndex, baseRevision)
    if (!requestId) {
      stagedRemoval = null
      Qt.callLater(function() { root.focusRemove(removed) })
      return
    }
    stagedRemoval = Object.assign({}, stagedRemoval, {requestId: requestId})
  }
  function makeDefault(id) {
    let next = ids()
    let index = next.indexOf(id)
    if (index <= 0) return
    let selected = next.splice(index, 1)[0]
    next.unshift(selected)
    save(next, editorShortcut)
  }
  function add(layout, variant) {
    let id = layout.id + "/" + variant.id
    if (ids().indexOf(id) >= 0) return
    let next = ids()
    next.push(id)
    let snapshot = results()
    let requestId = save(next, editorShortcut)
    if (requestId) {
      additionResults = snapshot
      additionRequestId = requestId
    }
  }
  function normalized(value) {
    return String(value || "").toLowerCase()
      .replace(/[_(),.\/+–—-]+/g, " ").replace(/\s+/g, " ").trim()
  }
  function matchesTerms(terms, text) {
    return terms.every(term => text.indexOf(term) === 0 || text.indexOf(" " + term) >= 0)
  }
  function resultRank(query, layoutId, layoutLabel, variantId, variantLabel, layoutMatch) {
    if (!query) return 0
    let pair = (layoutId + " " + variantId).trim()

    if (variantId && query === pair) return 600
    if (query === layoutId || query === layoutLabel) return 500
    if (layoutLabel.indexOf(query) === 0) return 400
    if (layoutMatch) return 300
    if (variantId && (query === variantId || query === variantLabel)) return 250
    if (variantId && variantLabel.indexOf(query) === 0) return 200
    return 100
  }
  function results() {
    if (additionResults !== null) return additionResults
    let query = normalized(search)
    let terms = query ? query.split(" ") : []
    let selected = ids()
    let list = []
    let order = 0
    backend.catalog.forEach(layout => {
      let layoutId = normalized(layout.id)
      let layoutLabel = normalized(layout.label)
      let layoutText = normalized(layout.id + " " + layout.label + " " + layout.search)
      let layoutMatch = !query || matchesTerms(terms, layoutText)
      layout.variants.forEach(variant => {
        if (selected.indexOf(layout.id + "/" + variant.id) >= 0) return
        if (!query && variant.id) return
        let variantId = normalized(variant.id)
        let variantLabel = normalized(variant.label)
        let candidateText = layoutText + " " + normalized(variant.id + " " + variant.label)
        if (query && !matchesTerms(terms, candidateText)) return
        list.push({layout: layout, variant: variant,
          rank: resultRank(query, layoutId, layoutLabel, variantId, variantLabel,
            layoutMatch),
          layoutKey: layoutLabel, variantKey: variantLabel, order: order++})
      })
    })
    list.sort(function(a, b) {
      if (a.rank !== b.rank) return b.rank - a.rank
      let aStandard = a.variant.id ? 1 : 0
      let bStandard = b.variant.id ? 1 : 0
      if (aStandard !== bStandard) return aStandard - bStandard
      if (a.layoutKey < b.layoutKey) return -1
      if (a.layoutKey > b.layoutKey) return 1
      if (a.variantKey < b.variantKey) return -1
      if (a.variantKey > b.variantKey) return 1
      return a.order - b.order
    })
    return list
  }
  onViewChanged: {
    // Shared dropdowns own their value while selecting. Resynchronize
    // after the derived editor state has followed a fresh helper reply.
    Qt.callLater(function() {
      defaultLayout.value = root.editorDefault
      shortcut.value = root.editorShortcut
    })
  }
  Keys.priority: Keys.AfterItem
  Keys.onPressed: function(event) {
    if (event.key === Qt.Key_Escape) { root.dismiss(); event.accepted = true }
    else if (event.key === Qt.Key_Down || event.key === Qt.Key_Up) {
      let item = root.Window.window ? root.Window.window.activeFocusItem : null
      if (item) {
        let next = item.nextItemInFocusChain(event.key === Qt.Key_Down)
        if (next) next.forceActiveFocus()
        event.accepted = true
      }
    }
  }
  Connections {
    target: root.backend
    function onActionFinished(result) {
      if (result.id === root.additionRequestId) {
        root.additionRequestId = 0
        if (result.ok && root.page === "search") root.go("editor")
        root.additionResults = null
        return
      }
      if (root.stagedRemoval && result.id === root.stagedRemoval.requestId) {
        let removal = root.stagedRemoval
        if (!result.ok) {
          root.stagedRemoval = null
          Qt.callLater(function() { root.focusRemove(removal.removed) })
          return
        }
        if (removal.phase === "saving") {
          if (root.removalConfirmed(removal)) {
            root.finishRemoval(removal)
          } else {
            root.stagedRemoval = Object.assign({}, removal,
              {phase: "confirming"})
            root.backend.refresh()
          }
          return
        }
        let confirmed = root.backend.state
        let confirmedRows = confirmed.layouts || []
        let active = confirmed.active >= 0 && confirmed.active < confirmedRows.length
          ? confirmedRows[confirmed.active].id : ""
        if (!root.stateFresh || active !== removal.survivor || confirmed.problem
            || confirmed.revision !== removal.baseRevision) {
          if (!root.backend.error)
            root.backend.error = "The keyboard setup changed before removal. Nothing was removed."
          root.stagedRemoval = null
          Qt.callLater(function() { root.focusRemove(removal.removed) })
          return
        }
        let requestId = root.backend.save(removal.layouts, removal.shortcut,
          removal.baseRevision, removal.survivor)
        if (!requestId) {
          if (!root.backend.error)
            root.backend.error = "The layout removal could not be started."
          root.stagedRemoval = null
          Qt.callLater(function() { root.focusRemove(removal.removed) })
          return
        }
        root.stagedRemoval = Object.assign({}, removal,
          {phase: "saving", requestId: requestId})
        return
      }
      if (result.name === "switch" && result.id === root.pickerSwitchRequestId) {
        root.pickerSwitchRequestId = 0
        if (result.ok) root.dismiss()
        return
      }
      if (root.pendingRemoval && result.id === root.pendingRemoval.requestId) {
        let removal = root.pendingRemoval
        root.pendingRemoval = null
        Qt.callLater(function() {
          if (result.ok) root.focusAfterRemoval()
          else root.focusRemove(removal.removed)
        })
      }
    }
    function onRefreshed(ok) {
      if (root.stagedRemoval && root.stagedRemoval.phase === "confirming") {
        let removal = root.stagedRemoval
        if (ok && root.removalConfirmed(removal)) {
          root.finishRemoval(removal)
        } else {
          root.rejectRemovalView(removal, ok
            ? "The layout removal did not read back consistently. The previous confirmed list remains shown."
            : "The layout removal completed, but its final state could not be confirmed. The previous confirmed list remains shown.")
        }
        return
      }
      if (root.rejectedRemoval) {
        let rejected = root.rejectedRemoval
        if (ok && root.removalConfirmed(rejected)) {
          root.finishRemoval(rejected)
        } else if (!root.backend.error) {
          root.backend.error = "The layout removal is still unconfirmed. The previous confirmed list remains shown."
        }
      }
    }
  }

  Flickable {
    id: scroll
    anchors.fill: parent
    contentHeight: body.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    Controls.ScrollBar.vertical: Controls.ScrollBar {}
    Column {
      id: body
      width: parent.width
      spacing: Style.spacing.rowGap

      Item {
        visible: root.page !== "picker"
        width: parent.width
        height: Style.spacing.controlHeight
        Ui.Button {
          id: backButton
          objectName: "backButton"
          anchors.left: parent.left
          text: "←"
          focusable: true
          width: Style.spacing.controlHeight
          height: parent.height
          Accessible.name: "Back"
          onClicked: root.back()
        }
        Text {
          anchors.left: backButton.right
          anchors.leftMargin: Style.spacing.controlGap
          anchors.right: headerActivity.left
          anchors.rightMargin: Style.spacing.controlGap
          anchors.verticalCenter: parent.verticalCenter
          text: root.page === "editor" ? "Layouts" : root.page === "search" ? "Add layout" : "Typing keyboard"
          textFormat: Text.PlainText
          elide: Text.ElideRight
          font.family: Style.font.family
          font.pixelSize: Style.font.body
          color: Color.popups.text
        }
        ActivityIndicator {
          id: headerActivity
          objectName: "headerActivity"
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          visible: root.backend.operationActive
            && root.stagedRemoval === null && root.pendingRemoval === null
          running: root.backend.animationsEnabled
          foreground: Color.popups.text
          opacity: 0.7
        }
      }

      Text {
        visible: root.backend.error !== ""
        width: parent.width
        text: root.backend.error
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
        font.family: Style.font.family
        font.pixelSize: Style.font.bodySmall
        color: Color.popups.text
      }

      Column {
        visible: root.page === "picker"
        width: parent.width
        spacing: Style.spacing.rowGap
        Repeater {
          id: layoutRepeater
          model: root.rows
          LayoutRow {
            required property var modelData
            required property int index
            width: body.width
            title: modelData.label
            subtitle: modelData.variant ? modelData.variantLabel : ""
            marked: index === root.view.active
            enabled: !root.interactionLocked && root.view.revision !== ""
            onClicked: root.switchLayout(index)
          }
        }
      }

      Text {
        visible: root.view.problem !== ""
        width: parent.width
        text: root.view.problem || ""
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
        font.family: Style.font.family
        font.pixelSize: Style.font.bodySmall
        color: Color.popups.text
        opacity: 0.7
      }
      Ui.PanelSeparator {
        objectName: "editLayoutsSeparator"
        visible: root.page === "picker" && !!root.view.device
        foreground: Color.popups.text
      }
      LayoutRow {
        visible: root.page === "picker" && !!root.view.device
        width: parent.width
        title: "Edit layouts…"
        enabled: !root.interactionLocked
        onClicked: root.go("editor")
      }
      LayoutRow {
        visible: (root.page === "picker" && !root.view.device) || (root.page === "editor" && root.view.devices.length > 1)
        width: parent.width
        title: "Choose keyboard…"
        enabled: !root.interactionLocked
        onClicked: root.go("devices")
      }

      Column {
        visible: root.page === "editor"
        width: parent.width
        spacing: Style.spacing.rowGap
        Repeater {
          id: editorRepeater
          model: root.editorRows
          Item {
            id: editorRow
            required property var modelData
            required property int index
            readonly property bool removalPending: root.removalPending(modelData.id)
            width: body.width
            height: Math.max(Style.spacing.controlHeight, editorLabels.implicitHeight + Style.spacing.controlPaddingY * 2)
            function focusRemove() {
              if (removeButton.visible && removeButton.enabled)
                removeButton.forceActiveFocus()
            }
            Column {
              id: editorLabels
              anchors.left: parent.left
              anchors.right: removeButton.visible ? removeButton.left : parent.right
              anchors.rightMargin: removeButton.visible ? Style.spacing.controlGap : 0
              anchors.verticalCenter: parent.verticalCenter
              Text {
                width: parent.width
                text: modelData.label
                textFormat: Text.PlainText
                elide: Text.ElideRight
                font.family: Style.font.family
                font.pixelSize: Style.font.body
                color: Color.popups.text
              }
              Text {
                width: parent.width
                visible: !!modelData.variant
                text: modelData.variant ? modelData.variantLabel : ""
                textFormat: Text.PlainText
                elide: Text.ElideRight
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                color: Color.popups.text
                opacity: 0.65
              }
            }
            Ui.Button {
              id: removeButton
              objectName: "removeLayout" + index
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              text: editorRow.removalPending ? "" : "×"
              active: editorRow.removalPending
              focusable: true
              visible: root.editorRows.length > 1
              width: visible ? Style.spacing.controlHeight : 0
              height: Style.spacing.controlHeight
              foreground: Color.popups.text
              enabled: visible && !root.interactionLocked && !root.view.problem
              Accessible.name: "Remove " + modelData.label
              onClicked: root.remove(index)
            }
            ActivityIndicator {
              objectName: "removeActivity" + index
              anchors.centerIn: removeButton
              visible: editorRow.removalPending
              running: root.backend.animationsEnabled
              foreground: Color.popups.text
              opacity: 0.7
            }
          }
        }
        LayoutRow {
          id: addLayout
          objectName: "addLayout"
          width: parent.width
          title: "+ Add layout"
          visible: root.editorRows.length < 4
          enabled: root.editorRows.length < 4 && !root.view.problem && !root.interactionLocked
          onClicked: root.go("search")
        }
        Text {
          objectName: "layoutLimitHint"
          visible: root.editorRows.length >= 4
          width: parent.width
          text: "Maximum of 4 layouts. Remove one to add another."
          textFormat: Text.PlainText
          wrapMode: Text.Wrap
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
          color: Color.popups.text
          opacity: 0.7
          Accessible.role: Accessible.StaticText
          Accessible.name: text
        }
        Ui.PanelSeparator {
          id: preferencesSeparator
          objectName: "preferencesSeparator"
          width: parent.width
          foreground: Color.popups.text
        }
        Column {
          id: preferences
          objectName: "preferences"
          width: parent.width
          spacing: Style.spacing.panelGap
          Ui.Dropdown {
            id: defaultLayout
            objectName: "defaultLayout"
            width: parent.width
            label: "Default at login"
            value: root.editorDefault
            options: root.defaultOptions
            visible: root.editorRows.length > 1
            enabled: !root.view.problem && !root.interactionLocked
            onChanged: function(value) { root.makeDefault(value) }
          }
          Column {
            id: implicitDefault
            objectName: "implicitDefault"
            visible: root.editorRows.length === 1
            width: parent.width
            spacing: Style.spacing.labelGap
            activeFocusOnTab: false
            Accessible.role: Accessible.StaticText
            Accessible.name: visible
              ? "Default at login: " + root.defaultOptions[0].label + ". Only layout." : ""
            Ui.PanelSectionHeader {
              objectName: "implicitDefaultHeader"
              width: parent.width
              text: "DEFAULT AT LOGIN"
              foreground: Color.popups.text
            }
            Text {
              objectName: "implicitDefaultValue"
              width: parent.width
              text: root.editorRows.length === 1
                ? root.defaultOptions[0].label + " — only layout" : ""
              textFormat: Text.PlainText
              wrapMode: Text.Wrap
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              color: Color.popups.text
            }
          }
          Ui.Dropdown {
            id: shortcut
            objectName: "shortcut"
            width: parent.width
            label: "Switch with"
            value: root.editorShortcut
            options: root.editorShortcut === "custom" ? [{value: "custom", label: "Your current shortcut"}].concat(root.backend.shortcuts) : root.backend.shortcuts
            enabled: !root.view.problem && !root.interactionLocked
            onChanged: function(value) { root.save(root.ids(), value) }
          }
        }
        Text {
          objectName: "pendingRestart"
          visible: root.view.pendingRestart || false
          width: parent.width
          text: "Saved and active layouts differ. Your next edit will apply this list immediately."
          textFormat: Text.PlainText
          wrapMode: Text.Wrap
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
          color: Color.popups.text
          opacity: 0.7
        }
      }

      Column {
        visible: root.page === "search"
        width: parent.width
        spacing: Style.spacing.rowGap
        Text {
          objectName: "searchHelp"
          width: parent.width
          text: "Try “English US” or “US intl”"
          textFormat: Text.PlainText
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
          color: Color.popups.text
          opacity: 0.65
        }
        Ui.TextField {
          id: searchField
          objectName: "layoutSearch"
          width: parent.width
          placeholderText: "Language, country code, or variant"
          text: root.search
          onTextEdited: root.search = text
          onAccepted: if (searchResults.count) searchResults.currentItem.clicked()
          Keys.onDownPressed: { searchResults.forceActiveFocus(); searchResults.currentIndex = 0 }
          Keys.onEscapePressed: root.dismiss()
          Accessible.name: "Search keyboard layouts and variants"
        }
        ListView {
          id: searchResults
          objectName: "searchResults"
          width: parent.width
          height: Style.space(280)
          clip: true
          boundsBehavior: Flickable.StopAtBounds
          model: root.results()
          spacing: Style.spacing.rowGap
          currentIndex: 0
          keyNavigationEnabled: true
          Controls.ScrollBar.vertical: Controls.ScrollBar {}
          Keys.onReturnPressed: if (currentItem) currentItem.clicked()
          Keys.onEnterPressed: if (currentItem) currentItem.clicked()
          delegate: LayoutRow {
            required property var modelData
            required property int index
            width: searchResults.width
            title: modelData.layout.label
            subtitle: modelData.variant.id ? modelData.variant.label : ""
            hasCursor: !root.interactionLocked && searchResults.activeFocus
              && index === searchResults.currentIndex
            enabled: !root.interactionLocked
            onClicked: {
              searchResults.currentIndex = index
              root.add(modelData.layout, modelData.variant)
            }
          }
        }
        Text {
          visible: searchResults.count === 0
          text: "No layouts found"
          color: Color.popups.text
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
        }
      }

      Column {
        width: parent.width
        visible: root.page === "devices"
        spacing: Style.spacing.rowGap
        Repeater {
          model: root.view.devices
          LayoutRow {
            required property var modelData
            width: body.width
            title: modelData.label
            subtitle: modelData.certain ? "" : "Cannot identify safely"
            marked: modelData.id === root.view.device
            enabled: modelData.certain && !root.interactionLocked
            onClicked: {
              if (root.backend.request("choose", {device: modelData.id}, root.view.revision))
                root.go("picker")
            }
          }
        }
      }
    }
  }
}
