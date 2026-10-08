import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "Model.js" as Model

// Touchpad settings window, summoned from Setup > Config > Touchpad
// (omarchy-setup-touchpad) or directly:
//   omarchy-shell shell summon omarchy.touchpad '{"page":"gestures"}'
//
// Every change is saved to ~/.config/omarchy/touchpad.json and applied to the
// running session at once through omarchy-touchpad-apply; Hyprland reads the
// same file through default/hypr/touchpad.lua on every reload. The window
// only writes keys the user changed, so everything else keeps tracking
// Omarchy's defaults.
Item {
  id: root

  property var shell: null
  property var manifest: null

  readonly property string pluginId: (manifest && manifest.id) || "omarchy.touchpad"
  readonly property string home: Quickshell.env("HOME")
  readonly property string settingsPath: home + "/.config/omarchy/touchpad.json"
  readonly property string userInputPath: home + "/.config/hypr/input.lua"

  readonly property color foreground: Commons.Color.foreground
  readonly property color background: Commons.Color.background
  readonly property color accent: Commons.Color.accent
  readonly property color dim: Qt.darker(foreground, 1.5)

  // The saved document, the running Hyprland values, and what the status
  // helper found on this machine.
  property var doc: Model.normalize({})
  property var live: ({})
  property var devices: []
  property var clients: []
  property string disabledName: ""
  property var overrides: Model.userOverrides("")

  property string page: "scrolling"
  property var customDevices: ({})
  property bool closingFromHost: false
  property bool reloadPending: false
  property bool applyQueued: false
  property string applyError: ""
  property bool confirmingReset: false

  readonly property bool hasOverrides: Object.keys(overrides.touchpad).length > 0
    || Object.keys(overrides.gestureSettings).length > 0
    || overrides.gestures > 0
    || overrides.appScroll
  readonly property var apps: Model.appsOrDefault(doc.apps)
  readonly property var gestureProblems: Model.gestureProblems(doc.gestures.bindings)
  readonly property var pageIds: Model.PAGES.map(function(p) { return p.id })

  // ---- lifecycle ----------------------------------------------------------

  function open(payloadJson) {
    closingFromHost = false
    var payload = {}
    try { payload = JSON.parse(payloadJson || "{}") || {} } catch (e) {}
    if (typeof payload.page === "string" && pageIds.indexOf(payload.page) >= 0) page = payload.page

    confirmingReset = false
    applyError = ""
    customApp.text = ""
    settingsFile.reload()
    inputFile.reload()
    refreshStatus()
    window.visible = true
    Qt.callLater(function() { if (window.visible) navigation.focusCurrent() })
  }

  // Host-initiated close (`shell hide`): the host already knows.
  function close() {
    closingFromHost = true
    window.visible = false
    closingFromHost = false
  }

  // User-initiated close: tell the host so `toggle` keeps working.
  function requestClose() {
    if (shell && typeof shell.hide === "function") shell.hide(pluginId)
    else window.visible = false
  }

  // ---- saving and applying ------------------------------------------------

  // Pointer speed and acceleration can only target a touchpad by name, so
  // every touchpad this machine has gets an entry, even without overrides.
  function withDevices(next) {
    for (var i = 0; i < devices.length; i++) {
      if (!next.devices[devices[i]]) next.devices[devices[i]] = {}
    }
    return next
  }

  function commit(next, needsReload) {
    doc = withDevices(next)
    settingsFile.setText(Model.serialize(doc))
    if (needsReload) reloadPending = true
    applyTimer.restart()
  }

  function runApply() {
    if (applyProc.running) {
      applyQueued = true
      return
    }
    applyQueued = false
    applyProc.command = reloadPending ? ["omarchy-touchpad-apply", "--reload"] : ["omarchy-touchpad-apply"]
    reloadPending = false
    applyProc.running = true
  }

  // A touchpad the file does not name yet only gets the shared pointer
  // settings once it has an entry, so add it as soon as one shows up.
  function adoptDevices() {
    var pointer = Object.keys(doc.touchpad).some(function(key) { return Model.SETTINGS[key] && Model.SETTINGS[key].pointer })
    var missing = devices.some(function(name) { return !doc.devices[name] })
    if (pointer && missing) commit(edited(), false)
  }

  function refreshStatus() {
    if (!statusProc.running) statusProc.running = true
  }

  function edited() {
    return Model.copy(doc)
  }

  function setTouchpad(key, value) {
    var next = edited()
    next.touchpad[key] = value
    commit(next, false)
  }

  function resetTouchpad(key) {
    var next = edited()
    delete next.touchpad[key]
    commit(next, true)
  }

  function setDevice(name, key, value) {
    var next = edited()
    if (!next.devices[name]) next.devices[name] = {}
    next.devices[name][key] = value
    commit(next, false)
  }

  function resetDevice(name, key) {
    var next = edited()
    if (next.devices[name]) delete next.devices[name][key]
    commit(next, true)
  }

  function deviceCustomized(name) {
    return customDevices[name] === true || Object.keys(doc.devices[name] || {}).length > 0
  }

  function setDeviceCustom(name, on) {
    var map = Model.copy(customDevices)
    map[name] = on
    customDevices = map
    if (!on && Object.keys(doc.devices[name] || {}).length > 0) {
      var next = edited()
      next.devices[name] = {}
      commit(next, true)
    }
  }

  function setGestureSetting(key, value) {
    var next = edited()
    next.gestures.settings[key] = value
    commit(next, false)
  }

  function resetGestureSetting(key) {
    var next = edited()
    delete next.gestures.settings[key]
    commit(next, true)
  }

  function addGesture(binding) {
    var next = edited()
    next.gestures.bindings.push(Model.copy(binding))
    commit(next, false)
  }

  function editGesture(index, field, value) {
    var next = edited()
    var binding = next.gestures.bindings[index]
    if (!binding) return
    if (field === "mods" && value === "") delete binding.mods
    else binding[field] = value
    commit(next, field !== "action")
  }

  // A saved gesture unsets any input.lua gesture on the same swipe, and only a
  // reload brings that one back once the saved gesture moves or goes away.
  function removeGesture(index) {
    var next = edited()
    next.gestures.bindings.splice(index, 1)
    commit(next, true)
  }

  // Window rules only apply as windows open, so app edits reload Hyprland to
  // reach the windows that are already up.
  function setApps(list) {
    var next = edited()
    next.apps = Model.sameApps(list, Model.DEFAULT_APPS) ? null : list
    commit(next, true)
  }

  function editApp(index, field, value) {
    var list = Model.copy(apps)
    if (!list[index]) return
    list[index][field] = value
    setApps(list)
  }

  function removeApp(index) {
    var list = Model.copy(apps)
    list.splice(index, 1)
    setApps(list)
  }

  function addApp(match) {
    var text = String(match || "").trim()
    if (text === "") return
    var list = Model.copy(apps)
    for (var i = 0; i < list.length; i++) {
      if (list[i].match === text) return
    }
    list.push({ match: text, scroll: 1.0 })
    setApps(list)
  }

  function resetAll() {
    confirmingReset = false
    customDevices = ({})
    commit(Model.normalize({}), true)
  }

  function setEnabled(on) {
    toggleProc.command = ["omarchy-toggle-touchpad", on ? "on" : "off"]
    toggleProc.running = true
  }

  function editUserInput() {
    Quickshell.execDetached(["omarchy-launch-config-editor", userInputPath])
  }

  function nextPage(delta) {
    var index = pageIds.indexOf(page)
    page = pageIds[(index + delta + pageIds.length) % pageIds.length]
    navigation.focusCurrent()
  }

  // This window is itself an org.quickshell client; leave it out.
  readonly property var unusedClients: clients.filter(function(name) {
    return name !== "org.quickshell" && !apps.some(function(app) { return app.match === name })
  })

  // ---- processes and files ------------------------------------------------

  FileView {
    id: settingsFile
    path: root.settingsPath
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: root.doc = Model.parse(text())
    onLoadFailed: root.doc = Model.normalize({})
    onFileChanged: reload()
  }

  FileView {
    id: inputFile
    path: root.userInputPath
    watchChanges: true
    printErrors: false
    onLoaded: root.overrides = Model.userOverrides(text())
    onLoadFailed: root.overrides = Model.userOverrides("")
    onFileChanged: reload()
  }

  Timer {
    id: applyTimer
    interval: 150
    onTriggered: root.runApply()
  }

  Process {
    id: applyProc
    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyError = String(text || "").trim()
    }
    onExited: function(exitCode) {
      if (exitCode !== 0 && root.applyError === "") root.applyError = "Hyprland did not accept the touchpad settings"
      if (exitCode === 0) root.applyError = ""
      if (root.applyQueued) root.runApply()
      else root.refreshStatus()
    }
  }

  Process {
    id: statusProc
    command: ["omarchy-touchpad-status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var status = {}
        try { status = JSON.parse(text) || {} } catch (e) { return }
        root.live = status.options || {}
        root.devices = Array.isArray(status.devices) ? status.devices : []
        root.clients = Array.isArray(status.clients) ? status.clients : []
        root.disabledName = String(status.disabled || "")
        root.adoptDevices()
      }
    }
  }

  Process {
    id: toggleProc
    onExited: root.refreshStatus()
  }

  // ---- window -------------------------------------------------------------

  FloatingWindow {
    id: window
    title: "Touchpad"
    color: root.background
    implicitWidth: Style.space(1040)
    implicitHeight: Style.space(700)
    minimumSize: Qt.size(Style.space(820), Style.space(520))
    visible: false

    onVisibleChanged: {
      if (!visible && !root.closingFromHost && root.shell && typeof root.shell.hide === "function")
        root.shell.hide(root.pluginId)
    }

    FocusScope {
      id: scope
      anchors.fill: parent
      focus: true

      // Keys nothing inside used: page switching, j/k walking, and Esc.
      Keys.onPressed: function(event) {
        var focused = scope.Window.activeFocusItem
        var editing = focused && focused.hasOwnProperty("selectByMouse")
        // A row that removed itself took the focused control with it; walk on
        // from the current page's navigation entry instead of going nowhere.
        if (!focused || focused === scope) {
          if (event.key === Qt.Key_J || event.key === Qt.Key_K || event.key === Qt.Key_Down || event.key === Qt.Key_Up) {
            navigation.focusCurrent()
            event.accepted = true
            return
          }
        }
        if (event.key === Qt.Key_Escape) {
          if (root.confirmingReset) root.confirmingReset = false
          else root.requestClose()
          event.accepted = true
        } else if (event.key === Qt.Key_Tab && (event.modifiers & Qt.ControlModifier)) {
          root.nextPage(1)
          event.accepted = true
        } else if (event.key === Qt.Key_Backtab && (event.modifiers & Qt.ControlModifier)) {
          root.nextPage(-1)
          event.accepted = true
        } else if (!editing && (event.key === Qt.Key_J || event.key === Qt.Key_Down)) {
          var next = scope.Window.activeFocusItem ? scope.Window.activeFocusItem.nextItemInFocusChain(true) : null
          if (next) next.forceActiveFocus(Qt.TabFocusReason)
          event.accepted = true
        } else if (!editing && (event.key === Qt.Key_K || event.key === Qt.Key_Up)) {
          var previous = scope.Window.activeFocusItem ? scope.Window.activeFocusItem.nextItemInFocusChain(false) : null
          if (previous) previous.forceActiveFocus(Qt.BacktabFocusReason)
          event.accepted = true
        } else if (!editing && event.key >= Qt.Key_1 && event.key < Qt.Key_1 + root.pageIds.length) {
          root.page = root.pageIds[event.key - Qt.Key_1]
          navigation.focusCurrent()
          event.accepted = true
        }
      }

      RowLayout {
        anchors.fill: parent
        spacing: 0

        // ---- navigation ----
        Rectangle {
          Layout.fillHeight: true
          Layout.preferredWidth: Style.space(200)
          color: Util.alpha(root.foreground, 0.03)

          Rectangle {
            anchors.right: parent.right
            width: 1
            height: parent.height
            color: Util.alpha(root.foreground, 0.08)
          }

          ColumnLayout {
            id: navigation
            anchors.fill: parent
            anchors.margins: Style.spacing.panelPadding
            spacing: Style.spacing.xs

            function focusCurrent() {
              var index = root.pageIds.indexOf(root.page)
              var item = navRepeater.itemAt(index)
              if (item) item.forceActiveFocus()
            }

            RowLayout {
              spacing: Style.spacing.md
              Layout.bottomMargin: Style.spacing.xxl

              Text {
                text: "󰟸"
                color: root.accent
                font.family: Style.font.family
                font.pixelSize: Style.font.heading
              }

              Text {
                textFormat: Text.PlainText
                text: "Touchpad"
                color: root.foreground
                font.family: Style.font.family
                font.pixelSize: Style.font.heading
                font.bold: true
              }
            }

            Repeater {
              id: navRepeater
              model: Model.PAGES

              Button {
                required property var modelData
                required property int index
                Layout.fillWidth: true
                text: modelData.label
                iconText: modelData.icon
                leftAlign: true
                focusable: true
                selected: root.page === modelData.id
                foreground: root.foreground
                accent: root.accent
                tooltipText: "Ctrl+Tab or " + (index + 1)
                onClicked: root.page = modelData.id
              }
            }

            Item { Layout.fillHeight: true }

            Button {
              Layout.fillWidth: true
              text: root.confirmingReset ? "Really reset?" : "Reset all"
              iconText: "󰑓"
              leftAlign: true
              focusable: true
              bordered: root.confirmingReset
              foreground: root.confirmingReset ? Commons.Color.urgent : root.dim
              accent: root.accent
              tooltipText: root.confirmingReset ? "Click again to restore every Omarchy default" : "Restore every Omarchy default"
              onClicked: {
                if (root.confirmingReset) root.resetAll()
                else root.confirmingReset = true
              }
            }
          }
        }

        // ---- pages ----
        ColumnLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: 0

          // Header: the page title plus the master on/off switch.
          RowLayout {
            Layout.fillWidth: true
            Layout.margins: Style.spacing.panelPadding
            Layout.bottomMargin: 0
            spacing: Style.spacing.xxl

            ColumnLayout {
              Layout.fillWidth: true
              spacing: Style.spacing.xs

              Text {
                textFormat: Text.PlainText
                text: Model.PAGES[Math.max(0, root.pageIds.indexOf(root.page))].label
                color: root.foreground
                font.family: Style.font.family
                font.pixelSize: Style.font.title
                font.bold: true
              }

              Text {
                textFormat: Text.PlainText
                text: root.devices.length === 0 ? "No touchpad detected"
                  : root.devices.map(Model.deviceLabel).join(", ")
                color: root.dim
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                elide: Text.ElideRight
                Layout.fillWidth: true
              }
            }

            Text {
              visible: root.devices.length > 0
              textFormat: Text.PlainText
              text: root.disabledName === "" ? "On" : "Off"
              color: root.dim
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
            }

            Item {
              id: enableControl
              visible: root.devices.length > 0
              implicitWidth: enableSwitch.implicitWidth
              implicitHeight: enableSwitch.implicitHeight
              activeFocusOnTab: visible
              Keys.onSpacePressed: root.setEnabled(root.disabledName !== "")
              Keys.onReturnPressed: root.setEnabled(root.disabledName !== "")

              ToggleSwitch {
                id: enableSwitch
                anchors.fill: parent
                checked: root.disabledName === ""
                busy: toggleProc.running
                hasCursor: enableControl.activeFocus
                foreground: root.foreground
                accent: root.accent
                onToggled: root.setEnabled(!checked)
              }
            }
          }

          // input.lua owns some of these settings.
          BorderSurface {
            visible: root.hasOverrides
            Layout.fillWidth: true
            Layout.leftMargin: Style.spacing.panelPadding
            Layout.rightMargin: Style.spacing.panelPadding
            Layout.topMargin: Style.spacing.xxl
            implicitHeight: bannerRow.implicitHeight + Style.spacing.lg * 2
            color: Util.alpha(root.accent, 0.10)
            radius: Style.cornerRadius
            borderSpec: Border.flat(Util.alpha(root.accent, 0.35), 1)

            RowLayout {
              id: bannerRow
              anchors.fill: parent
              anchors.leftMargin: Style.spacing.rowPaddingX
              anchors.rightMargin: Style.spacing.md
              spacing: Style.spacing.xxl

              Text {
                textFormat: Text.PlainText
                text: "Your ~/.config/hypr/input.lua also sets some of these; they are marked here. Anything you change in this window overrides it, and resetting a setting hands it back to input.lua."
                color: root.foreground
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
              }

              Button {
                text: "Edit input.lua"
                bordered: true
                focusable: true
                foreground: root.foreground
                accent: root.accent
                onClicked: root.editUserInput()
              }
            }
          }

          Text {
            visible: root.applyError !== ""
            textFormat: Text.PlainText
            text: root.applyError
            color: Commons.Color.urgent
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.leftMargin: Style.spacing.panelPadding
            Layout.rightMargin: Style.spacing.panelPadding
            Layout.topMargin: Style.spacing.md
          }

          StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: Math.max(0, root.pageIds.indexOf(root.page))

            // ---- Scrolling ----
            Page {
              id: scrollingPage

              Section {
                title: "Scrolling"
                foreground: root.foreground

                Repeater {
                  model: Model.PAGE_SETTINGS.scrolling
                  delegate: settingDelegate
                }
              }

              Text {
                textFormat: Text.PlainText
                text: "Terminals scroll at their own speed on top of this one; adjust them under App Scrolling."
                color: root.dim
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
              }
            }

            // ---- Tap & Click ----
            Page {
              id: clickingPage

              Section {
                title: "Tapping and clicking"
                foreground: root.foreground

                Repeater {
                  model: Model.PAGE_SETTINGS.clicking
                  delegate: settingDelegate
                }
              }
            }

            // ---- Pointer ----
            Page {
              id: pointerPage

              Section {
                title: "Pointer"
                subtitle: "These apply to touchpads only, so a mouse keeps its own speed."
                foreground: root.foreground

                Repeater {
                  model: Model.PAGE_SETTINGS.pointer
                  delegate: settingDelegate
                }
              }
            }

            // ---- Gestures ----
            Page {
              id: gesturesPage

              Section {
                title: "Gestures"
                subtitle: "Swipe or pinch with several fingers. Pick how many, which way, and an optional key to hold so one swipe can do two things."
                foreground: root.foreground

                Text {
                  visible: root.doc.gestures.bindings.length === 0
                  textFormat: Text.PlainText
                  text: "No gestures yet. Add one, or start from a suggestion below."
                  color: root.dim
                  font.family: Style.font.family
                  font.pixelSize: Style.font.bodySmall
                  Layout.fillWidth: true
                  Layout.topMargin: Style.spacing.lg
                  Layout.bottomMargin: Style.spacing.lg
                }

                // A count model, so saving (which replaces the bindings array)
                // updates rows in place instead of rebuilding them and dropping
                // keyboard focus from the control just used.
                Repeater {
                  model: root.doc.gestures.bindings.length

                  GestureRow {
                    required property int index
                    Layout.fillWidth: true
                    binding: root.doc.gestures.bindings[index] || ({})
                    number: index + 1
                    divided: index > 0
                    problem: root.gestureProblems[index] || ""
                    foreground: root.foreground
                    accent: root.accent
                    onEdited: function(field, value) { root.editGesture(index, field, value) }
                    onRemoved: {
                      // Removing destroys this row mid-handler, so move focus first.
                      var removed = index
                      addGestureButton.forceActiveFocus()
                      root.removeGesture(removed)
                    }
                  }
                }
              }

              Flow {
                Layout.fillWidth: true
                spacing: Style.spacing.md

                Button {
                  id: addGestureButton
                  text: "Add gesture"
                  iconText: "󰐕"
                  bordered: true
                  focusable: true
                  foreground: root.foreground
                  accent: root.accent
                  onClicked: root.addGesture(Model.nextBinding(root.doc.gestures.bindings))
                }

                Repeater {
                  model: Model.GESTURE_PRESETS.filter(function(preset) {
                    return !Model.presetActive(root.doc.gestures.bindings, preset)
                  })

                  Button {
                    required property var modelData
                    text: modelData.label
                    bordered: true
                    focusable: true
                    foreground: root.dim
                    accent: root.accent
                    // The suggestion disappears once added, destroying this
                    // button mid-handler, so hand focus to the add button first.
                    onClicked: {
                      var binding = modelData.binding
                      addGestureButton.forceActiveFocus()
                      root.addGesture(binding)
                    }
                  }
                }
              }

              Text {
                visible: root.overrides.gestures > 0
                textFormat: Text.PlainText
                text: "Your input.lua adds " + root.overrides.gestures + (root.overrides.gestures === 1 ? " gesture" : " gestures")
                  + " of its own. A gesture here replaces any of those that use the same swipe."
                color: root.accent
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
              }

              Section {
                title: "Workspace swipe"
                subtitle: "How the Workspaces gesture feels as it follows your fingers."
                foreground: root.foreground

                Repeater {
                  model: Object.keys(Model.GESTURE_SETTINGS)

                  Setting {
                    required property string modelData
                    required property int index
                    Layout.fillWidth: true
                    divided: index > 0
                    spec: Model.GESTURE_SETTINGS[modelData]
                    external: root.overrides.gestureSettings[modelData] === true
                    value: Model.effective(modelData, root.doc.gestures.settings, root.live, Model.GESTURE_SETTINGS)
                    saved: root.doc.gestures.settings[modelData] !== undefined
                    scroller: gesturesPage
                    foreground: root.foreground
                    accent: root.accent
                    background: root.background
                    onChanged: function(v) { root.setGestureSetting(modelData, v) }
                    onReset: root.resetGestureSetting(modelData)
                  }
                }
              }
            }

            // ---- App scrolling ----
            Page {
              id: appsPage

              Section {
                title: "Per-app scroll speed"
                subtitle: "Multiplies the scroll speed inside matching windows. The match is a regular expression on the window class."
                foreground: root.foreground

                Text {
                  visible: root.apps.length === 0
                  textFormat: Text.PlainText
                  text: "Every app scrolls at the global speed."
                  color: root.dim
                  font.family: Style.font.family
                  font.pixelSize: Style.font.bodySmall
                  Layout.topMargin: Style.spacing.lg
                  Layout.bottomMargin: Style.spacing.lg
                }

                Repeater {
                  model: root.apps.length

                  AppRow {
                    required property int index
                    Layout.fillWidth: true
                    app: root.apps[index] || ({ match: "", scroll: 1 })
                    divided: index > 0
                    scroller: appsPage
                    foreground: root.foreground
                    accent: root.accent
                    background: root.background
                    onEdited: function(field, value) { root.editApp(index, field, value) }
                    onRemoved: {
                      var removed = index
                      navigation.focusCurrent()
                      root.removeApp(removed)
                    }
                  }
                }
              }

              RowLayout {
                Layout.fillWidth: true
                spacing: Style.spacing.md

                Dropdown {
                  id: runningApps
                  visible: root.unusedClients.length > 0
                  showLabel: false
                  value: ""
                  options: [{ value: "", label: "Add a running app…" }].concat(root.unusedClients)
                  Layout.fillWidth: true
                  Layout.preferredWidth: Style.space(240)
                  Layout.minimumWidth: Style.space(120)
                  onChanged: function(v) {
                    root.addApp(v)
                    value = ""
                  }
                }

                TextField {
                  id: customApp
                  placeholderText: "Or type a window class"
                  foreground: root.foreground
                  accent: root.accent
                  Layout.fillWidth: true
                  Layout.preferredWidth: Style.space(220)
                  Layout.minimumWidth: Style.space(120)
                  onAccepted: {
                    root.addApp(text)
                    text = ""
                  }
                }

                Button {
                  text: "Add"
                  iconText: "󰐕"
                  bordered: true
                  focusable: true
                  enabled: customApp.text.trim() !== ""
                  foreground: root.foreground
                  accent: root.accent
                  onClicked: {
                    root.addApp(customApp.text)
                    customApp.text = ""
                  }
                }
              }

              Button {
                visible: root.doc.apps !== null
                text: "Restore defaults"
                iconText: "󰑓"
                focusable: true
                foreground: root.dim
                accent: root.accent
                onClicked: root.setApps(Model.copy(Model.DEFAULT_APPS))
              }

              Text {
                visible: root.overrides.appScroll
                textFormat: Text.PlainText
                text: "Your input.lua also sets scroll_touchpad rules. For an app listed here, the speed here wins."
                color: root.accent
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
              }
            }

            // ---- Devices ----
            Page {
              id: devicesPage

              Text {
                visible: root.devices.length === 0
                textFormat: Text.PlainText
                text: "No touchpad is connected right now. Settings saved here apply when one appears."
                color: root.dim
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
              }

              // The status refresh after every save replaces this list too.
              Repeater {
                model: root.devices.length

                Section {
                  id: deviceSection
                  required property int index
                  readonly property string deviceName: root.devices[index] || ""
                  readonly property bool customized: root.deviceCustomized(deviceName)
                  title: Model.deviceLabel(deviceName)
                  subtitle: deviceName
                  foreground: root.foreground

                  Setting {
                    Layout.fillWidth: true
                    spec: ({ type: "bool", label: "Custom settings for this touchpad", description: "Override the shared settings on this device only", fallback: false })
                    value: deviceSection.customized
                    scroller: devicesPage
                    foreground: root.foreground
                    accent: root.accent
                    background: root.background
                    onChanged: function(v) { root.setDeviceCustom(deviceSection.deviceName, v) }
                  }

                  Repeater {
                    model: deviceSection.customized ? Model.DEVICE_SETTINGS : []

                    Setting {
                      required property string modelData
                      Layout.fillWidth: true
                      divided: true
                      spec: Model.SETTINGS[modelData]
                      value: Model.deviceEffective(modelData, root.doc, deviceSection.deviceName, root.live)
                      saved: (root.doc.devices[deviceSection.deviceName] || {})[modelData] !== undefined
                      scroller: devicesPage
                      foreground: root.foreground
                      accent: root.accent
                      background: root.background
                      onChanged: function(v) { root.setDevice(deviceSection.deviceName, modelData, v) }
                      onReset: root.resetDevice(deviceSection.deviceName, modelData)
                    }
                  }
                }
              }

              Section {
                title: "Troubleshooting"
                foreground: root.foreground

                RowLayout {
                  Layout.fillWidth: true
                  Layout.topMargin: Style.spacing.lg
                  Layout.bottomMargin: Style.spacing.lg
                  spacing: Style.spacing.xxl

                  ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Style.spacing.xs

                    Text {
                      textFormat: Text.PlainText
                      text: "Touchpad stopped responding?"
                      color: root.foreground
                      font.family: Style.font.family
                      font.pixelSize: Style.font.subtitle
                      font.bold: true
                    }

                    Text {
                      textFormat: Text.PlainText
                      text: "Reload its driver. Asks for your password."
                      color: root.dim
                      font.family: Style.font.family
                      font.pixelSize: Style.font.caption
                      wrapMode: Text.WordWrap
                      Layout.fillWidth: true
                    }
                  }

                  Button {
                    text: "Reset driver"
                    bordered: true
                    focusable: true
                    foreground: root.foreground
                    accent: root.accent
                    onClicked: Quickshell.execDetached(["omarchy-launch-floating-terminal-with-presentation", "omarchy-restart-trackpad"])
                  }
                }

                RowLayout {
                  Layout.fillWidth: true
                  Layout.topMargin: Style.spacing.lg
                  Layout.bottomMargin: Style.spacing.lg
                  spacing: Style.spacing.xxl

                  ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Style.spacing.xs

                    Text {
                      textFormat: Text.PlainText
                      text: "Settings file"
                      color: root.foreground
                      font.family: Style.font.family
                      font.pixelSize: Style.font.subtitle
                      font.bold: true
                    }

                    Text {
                      textFormat: Text.PlainText
                      text: "~/.config/omarchy/touchpad.json holds everything changed here."
                      color: root.dim
                      font.family: Style.font.family
                      font.pixelSize: Style.font.caption
                      wrapMode: Text.WordWrap
                      Layout.fillWidth: true
                    }
                  }

                  Button {
                    text: "Open"
                    bordered: true
                    focusable: true
                    foreground: root.foreground
                    accent: root.accent
                    onClicked: Quickshell.execDetached(["omarchy-launch-config-editor", root.settingsPath])
                  }
                }
              }
            }
          }
        }

        // ---- test area ----
        Rectangle {
          Layout.fillHeight: true
          Layout.preferredWidth: Style.space(280)
          color: Util.alpha(root.foreground, 0.03)

          Rectangle {
            anchors.left: parent.left
            width: 1
            height: parent.height
            color: Util.alpha(root.foreground, 0.08)
          }

          TestPad {
            anchors.fill: parent
            anchors.margins: Style.spacing.panelPadding
            foreground: root.foreground
            accent: root.accent
          }
        }
      }
    }
  }

  // Rows for the plain touchpad settings, shared by the first three pages.
  Component {
    id: settingDelegate

    Setting {
      required property string modelData
      required property int index
      Layout.fillWidth: true
      divided: index > 0
      spec: Model.SETTINGS[modelData]
      external: root.overrides.touchpad[modelData] === true
      value: Model.effective(modelData, root.doc.touchpad, root.live)
      saved: root.doc.touchpad[modelData] !== undefined
      scroller: parent ? pageOf(this) : null
      foreground: root.foreground
      accent: root.accent
      background: root.background
      onChanged: function(v) { root.setTouchpad(modelData, v) }
      onReset: root.resetTouchpad(modelData)

      function pageOf(item) {
        for (var node = item.parent; node; node = node.parent) {
          if (node.scrollBy !== undefined && node.ensureVisible !== undefined) return node
        }
        return null
      }
    }
  }
}
