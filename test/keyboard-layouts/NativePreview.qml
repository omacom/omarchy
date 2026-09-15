import QtQuick
import QtQuick.Controls as Controls
import QtTest
import Quickshell
import qs.Commons
import qs.Ui as Ui
import "plugin" as Plugin

Scope {
  id: preview
  property int step: 0
  property bool capturesComplete: false
  readonly property bool listingMode: Quickshell.env("KEYBOARD_LISTING_PREVIEW") === "1"
  property int dismissCount: 0
  property var pages: ["picker", "editor", "search"]
  property bool guardDone: false
  property bool guardTransportFailure: false
  property string guardOutput: ""
  Plugin.HelperProcess {
    id: guardedProcess
    supervisorPath: Quickshell.env("KEYBOARD_PROCESS_FIXTURE")
    onFinished: function(output, transportFailure, error) {
      preview.guardOutput = output
      preview.guardTransportFailure = transportFailure
      preview.guardDone = true
    }
  }
  TestCase {
    name: "KeyboardPicker"
    when: preview.capturesComplete
    SignalSpy { id: backendActionSpy; target: Plugin.Backend; signalName: "actionFinished" }
    function init() {
      fake.state = Object.assign({}, fake.state, {layouts: fake.baseLayouts, configuredLayouts: fake.baseLayouts,
        shortcut: "both-alt", configuredShortcut: "both-alt", pendingRestart: false, active: 1,
        activeLayouts: [], physicalLayouts: fake.baseLayouts, compatibilityMode: "",
        problem: "", devices: [], device: "preview", revision: "preview"})
      fake.error = ""
      fake.saves = []
      fake.switches = []
      fake.catalog = fake.fixtureCatalog
      fake.animationsEnabled = true
      fake.stateFresh = true
      fake.autoAdvance = true
      fake.nextActionFailure = ""
      fake.nextReadbackFailure = ""
      fake.nextReadbackRevision = ""
      fake.nextReadbackConfiguredLayouts = null
      fake.nextRefreshState = null
      fake.refreshCount = 0
      fake.resetOperation()
      preview.dismissCount = 0
      picker.stagedRemoval = null
      picker.pendingRemoval = null
      picker.heldView = null
      picker.rejectedRemoval = null
      picker.pickerSwitchRequestId = 0
      picker.reset()
      wait(20)
    }
    function cleanup() {
      if (qtest_results.failed) console.log("NATIVE_TEST_FAILED", qtest_results.functionName, qtest_results.dataTag)
    }
    function cleanupTestCase() {
      console.log("NATIVE_TEST_TOTALS", qtest_results.passCount, qtest_results.failCount)
    }
    function test_builtin_entry_point() {
      let component = Qt.createComponent("builtin/KeyboardLayout.qml")
      tryCompare(component, "status", Component.Ready, 2000, component.errorString())
      let entry = component.createObject(window.contentItem, {backend: fake, visible: false})
      verify(entry !== null, component.errorString())
      compare(entry.moduleName, "omarchy.keyboard-layout")
      compare(entry.backend, fake)
      tryVerify(() => entry.implicitWidth > 0)
      entry.destroy()
    }
    function test_helper_location() {
      verify(Plugin.Backend.helper.startsWith("/"), "The helper must resolve to a real filesystem path")
      console.log("NATIVE_HELPER_PATH_OK", Plugin.Backend.helper)
    }
    function test_transport_failures_are_unconfirmed() {
      let backend = Plugin.Backend
      compare(backend.resultOutcome({actionOk: false, actionTransportOk: false}, true), "unconfirmed")
      compare(backend.resultOutcome({actionOk: true, actionTransportOk: true}, false), "unconfirmed")
      compare(backend.resultOutcome({actionOk: false, actionTransportOk: true}, true), "rejected")
      compare(backend.resultOutcome({actionOk: true, actionTransportOk: true}, true), "committed")
    }
    function test_mutation_transport_failure_finishes_only_after_readback() {
      let backend = Plugin.Backend
      tryVerify(() => !backend.busy, 5000)
      backendActionSpy.clear()
      let requestId = 900001
      backend.activeRequest = {id: requestId, name: "save", baseRevision: "fixture",
        requestedLayouts: ["us/"], actionOk: false, actionTransportOk: false,
        actionData: null, actionError: "The mutation timed out."}
      backend.awaitingReadback = true
      backend.startQuery(requestId)
      tryCompare(backendActionSpy, "count", 1, 5000)
      let result = backendActionSpy.signalArguments[0][0]
      compare(result.id, requestId)
      compare(result.outcome, "unconfirmed")
      verify(!result.ok)
      compare(result.error, "The mutation timed out.")
      compare(backend.activeRequest, null)
      verify(!backend.awaitingReadback)
      verify(backend.stateFresh)
    }
    function runGuard(action, timeout) {
      preview.guardDone = false
      preview.guardTransportFailure = false
      preview.guardOutput = ""
      verify(guardedProcess.start(action, {}, timeout))
      tryVerify(() => preview.guardDone, 5000)
    }
    function test_guarded_process_bounds_deadlines_and_reuse() {
      let fixture = guardedProcess.supervisorPath
      guardedProcess.supervisorPath = "/definitely/missing/keyboard-helper.py"
      runGuard("missing", 1000)
      verify(preview.guardTransportFailure)
      guardedProcess.supervisorPath = fixture
      runGuard("stdout-flood", 1000)
      verify(preview.guardTransportFailure)
      runGuard("stderr-flood", 1000)
      verify(preview.guardTransportFailure)
      runGuard("malformed", 1000)
      verify(!preview.guardTransportFailure)
      let malformed = Plugin.Backend.reply(preview.guardOutput, false, "", false)
      verify(!malformed.ok)
      verify(malformed.transportFailure)
      runGuard("hang", 50)
      verify(preview.guardTransportFailure)
      runGuard("after-timeout", 1000)
      verify(!preview.guardTransportFailure)
      compare(JSON.parse(preview.guardOutput).data.fixture, "after-timeout")
      console.log("NATIVE_GUARDED_PROCESS_OK")
    }
    function test_guarded_process_ignores_stale_generation_timers() {
      preview.guardDone = false
      preview.guardTransportFailure = false
      preview.guardOutput = ""
      verify(guardedProcess.start("slow", {}, 1000))
      let stale = guardedProcess.activeGeneration - 1
      guardedProcess.deadline.generation = stale
      guardedProcess.deadline.interval = 20
      guardedProcess.deadline.restart()
      guardedProcess.killer.generation = stale
      guardedProcess.killer.interval = 20
      guardedProcess.killer.restart()
      tryVerify(() => preview.guardDone, 5000)
      guardedProcess.killer.interval = 2000
      verify(!preview.guardTransportFailure)
      compare(JSON.parse(preview.guardOutput).data.fixture, "slow")
    }
    function test_backend_failure_and_refresh_coalescing() {
      let backend = Plugin.Backend
      let oldError = backend.error
      verify(!backend.reply("not json").ok)
      compare(backend.error, "The keyboard did not respond. Try again.")
      backend.error = "Stale refresh error"
      let started = Date.now()
      backend.refresh()
      for (let i = 0; i < 200; i++) backend.refresh()
      if (backend.query.running || backend.action.running) verify(backend.pending)
      tryVerify(() => !backend.query.running && !backend.pending, 3000)
      let elapsed = Date.now() - started
      verify(elapsed <= 500, "Event-storm refresh exceeded 500 ms: " + elapsed)
      verify(backend.stateFresh)
      compare(backend.error, "")
      backend.error = oldError
      console.log("NATIVE_BACKEND_HEALTH_OK", "stormRefreshMs=" + elapsed)
    }
    function visibleButtons(item) {
      let buttons = []
      for (let child of item.children) {
        if (!child.visible) continue
        if (child instanceof Ui.Button) buttons.push(child)
        buttons = buttons.concat(visibleButtons(child))
      }
      return buttons
    }
    function test_menu_tooltips_data() {
      return preview.pages.concat(["devices"]).map(page => ({tag: page, page: page}))
    }
    function test_edit_layouts_separator() {
      let separator = findChild(picker, "editLayoutsSeparator")
      verify(separator)
      compare(separator.visible, true)
      compare(separator.height, 1)
      compare(separator.width, picker.width)
      compare(separator.activeFocusOnTab, false)
      let buttons = visibleButtons(picker)
      compare(buttons.length, 3)
      compare(buttons[2].title, "Edit layouts…")
      let above = buttons[1].mapToItem(picker, 0, buttons[1].height).y
      let line = separator.mapToItem(picker, 0, 0).y
      let below = buttons[2].mapToItem(picker, 0, 0).y
      verify(line - above >= Style.spacing.rowGap)
      verify(below - line - separator.height >= Style.spacing.rowGap)
      for (let page of preview.pages.concat(["devices"]).filter(page => page !== "picker")) {
        picker.go(page)
        wait(20)
        compare(separator.visible, false)
      }
      fake.state = Object.assign({}, fake.state, {device: ""})
      picker.go("picker")
      wait(20)
      compare(separator.visible, false)
      console.log("NATIVE_SEPARATOR_OK")
    }
    function test_editor_layout_limit_hint() {
      let rows = fake.baseLayouts.concat([
        {id: "de/", layout: "de", variant: "", label: "German", variantLabel: "Standard", code: "DE", country: "de"},
        {id: "fr/", layout: "fr", variant: "", label: "French", variantLabel: "Standard", code: "FR", country: "fr"}
      ])
      fake.state = Object.assign({}, fake.state, {layouts: rows, configuredLayouts: rows})
      picker.go("editor")
      let hint = findChild(picker, "layoutLimitHint")
      let add = findChild(picker, "addLayout")
      tryCompare(hint, "visible", true)
      compare(add.enabled, false)
      compare(add.visible, false)
      wait(30)
      let captured = false
      picker.grabToImage(result => {
        verify(result.saveToFile(Quickshell.env("KEYBOARD_PREVIEW_OUTPUT") + "/editor-layout-limit.png"))
        captured = true
      })
      tryVerify(() => captured)
      fake.state = Object.assign({}, fake.state, {layouts: rows.slice(0, 3), configuredLayouts: rows.slice(0, 3)})
      tryCompare(hint, "visible", false)
      compare(add.visible, true)
      compare(add.enabled, true)
    }
    function test_editor_preferences_hierarchy() {
      picker.go("editor")
      wait(20)
      let add = findChild(picker, "addLayout")
      let separator = findChild(picker, "preferencesSeparator")
      let preferences = findChild(picker, "preferences")
      let defaultLayout = findChild(picker, "defaultLayout")
      let shortcut = findChild(picker, "shortcut")
      verify(add && separator && preferences && defaultLayout && shortcut)
      verify(separator.visible)
      compare(separator.height, 1)
      compare(separator.width, picker.width)
      compare(separator.activeFocusOnTab, false)

      let addBottom = add.mapToItem(picker, 0, add.height).y
      let lineTop = separator.mapToItem(picker, 0, 0).y
      let lineBottom = separator.mapToItem(picker, 0, separator.height).y
      let defaultTop = defaultLayout.mapToItem(picker, 0, 0).y
      let defaultBottom = defaultLayout.mapToItem(picker, 0, defaultLayout.height).y
      let shortcutTop = shortcut.mapToItem(picker, 0, 0).y
      verify(lineTop - addBottom >= Style.spacing.rowGap)
      verify(defaultTop - lineBottom >= Style.spacing.rowGap)
      verify(shortcutTop - defaultBottom >= Style.spacing.panelGap)

      picker.go("search")
      wait(20)
      let help = findChild(picker, "searchHelp")
      let field = findChild(picker, "layoutSearch")
      verify(help && field)
      let helpBottom = help.mapToItem(picker, 0, help.height).y
      let fieldTop = field.mapToItem(picker, 0, 0).y
      verify(helpBottom < fieldTop)
      verify(fieldTop - helpBottom >= Style.spacing.rowGap)
      console.log("NATIVE_EDITOR_HIERARCHY_OK")
    }
    function test_direct_editing() {
      picker.go("editor")
      wait(20)
      let remove = findChild(picker, "removeLayout1")
      verify(remove)
      compare(remove.text, "×")
      compare(remove.enabled, true)
      mouseClick(remove)
      tryCompare(fake, "switchCount", 1)
      compare(fake.switches[0].index, 0)
      compare(fake.switches[0].revision, "preview")
      tryCompare(fake, "saveCount", 1)
      compare(fake.saves[0].layouts.join(","), "us/")
      compare(fake.saves[0].shortcut, "both-alt")
      compare(fake.saves[0].revision, "preview")
      compare(fake.saves[0].expectedActiveId, "us/")
      tryVerify(() => picker.editorRows.length === 1)
      let remainingRemove = findChild(picker, "removeLayout0")
      verify(remainingRemove)
      compare(remainingRemove.visible, false)
      compare(remainingRemove.width, 0)
      compare(remainingRemove.enabled, false)
      compare(fake.state.layouts.length, 1)
      compare(fake.state.layouts[0].id, "us/")
      compare(fake.state.active, 0)
      let implicitDefault = findChild(picker, "implicitDefault")
      let implicitDefaultHeader = findChild(picker, "implicitDefaultHeader")
      let implicitDefaultValue = findChild(picker, "implicitDefaultValue")
      verify(implicitDefault)
      compare(implicitDefault.visible, true)
      compare(implicitDefault.activeFocusOnTab, false)
      compare(implicitDefault.Accessible.name,
        "Default at login: English (US). Only layout.")
      compare(implicitDefaultHeader.text, "DEFAULT AT LOGIN")
      compare(implicitDefaultValue.text, "English (US) — only layout")
      let warning = findChild(picker, "pendingRestart")
      compare(warning.visible, false)
      let captured = false
      card.grabToImage(function(result) {
        verify(result.saveToFile(Quickshell.env("KEYBOARD_PREVIEW_OUTPUT") + "/editor-saved.png"))
        captured = true
      })
      tryVerify(() => captured)
      console.log("NATIVE_DIRECT_EDIT_OK")
    }
    function test_active_default_first_removal_keeps_one_confirmed_view() {
      let english = fake.baseLayouts[0]
      let polish = fake.baseLayouts[1]
      let initial = [polish, english]
      fake.state = Object.assign({}, fake.state, {layouts: initial,
        configuredLayouts: initial, physicalLayouts: initial, active: 0,
        activeLayouts: [polish]})
      fake.autoAdvance = false
      // Exercise the reported split defensively: the switch readback's
      // backend snapshot can change independently, but the two visible
      // models must remain on the pre-operation confirmed snapshot.
      fake.nextReadbackConfiguredLayouts = [english]
      picker.go("editor")
      wait(20)

      let remove = findChild(picker, "removeLayout0")
      let selector = findChild(picker, "defaultLayout")
      let implicitDefault = findChild(picker, "implicitDefault")
      verify(remove && selector && implicitDefault)
      compare(selector.value, "pl/")
      compare(selector.visible, true)
      compare(implicitDefault.visible, false)
      mouseClick(remove)

      compare(fake.switchCount, 1)
      compare(fake.switches[0].index, 1)
      compare(fake.switches[0].revision, "preview")
      verify(picker.interactionLocked)
      compare(picker.stagedRemoval.phase, "switching")
      compare(findChild(picker, "operationStatus"), null)
      compare(remove.text, "")
      verify(remove.active)
      let removeActivity = findChild(picker, "removeActivity0")
      verify(removeActivity && removeActivity.visible)
      verify(removeActivity.animated)
      let headerActivity = findChild(picker, "headerActivity")
      verify(headerActivity)
      compare(headerActivity.visible, false)
      let back = findChild(picker, "backButton")
      verify(back.enabled)
      compare(picker.rows.map(row => row.id).join(","), "pl/,us/")
      compare(picker.editorRows.map(row => row.id).join(","), "pl/,us/")
      compare(picker.view.active, 0)

      let captured = false
      card.grabToImage(function(result) {
        verify(result.saveToFile(Quickshell.env("KEYBOARD_PREVIEW_OUTPUT")
          + "/removing.png"))
        captured = true
      })
      tryVerify(() => captured)

      fake.finishAction(true)
      verify(picker.interactionLocked)
      compare(fake.operationPhase, "readback")
      compare(picker.rows.map(row => row.id).join(","), "pl/,us/")
      compare(picker.editorRows.map(row => row.id).join(","), "pl/,us/")

      fake.finishReadback(true)
      compare(fake.state.layouts.map(row => row.id).join(","), "pl/,us/")
      compare(fake.state.configuredLayouts.map(row => row.id).join(","), "us/")
      compare(fake.state.active, 1)
      compare(fake.saveCount, 1)
      compare(fake.saves[0].layouts.join(","), "us/")
      compare(fake.saves[0].expectedActiveId, "us/")
      compare(picker.stagedRemoval.phase, "saving")
      compare(remove.text, "")
      verify(removeActivity.visible)
      verify(removeActivity.animated)
      verify(fake.busy)
      verify(picker.interactionLocked)
      compare(picker.rows.map(row => row.id).join(","), "pl/,us/")
      compare(picker.editorRows.map(row => row.id).join(","), "pl/,us/")
      compare(selector.visible, true)
      compare(implicitDefault.visible, false)

      fake.finishAction(true)
      verify(fake.busy)
      verify(picker.interactionLocked)
      compare(fake.operationPhase, "readback")
      compare(picker.rows.map(row => row.id).join(","), "pl/,us/")
      compare(picker.editorRows.map(row => row.id).join(","), "pl/,us/")

      fake.finishReadback(true)
      tryVerify(() => picker.stagedRemoval === null && !picker.interactionLocked)
      compare(picker.rows.map(row => row.id).join(","), "us/")
      compare(picker.editorRows.map(row => row.id).join(","), "us/")
      compare(picker.view.active, 0)
      compare(selector.visible, false)
      compare(implicitDefault.visible, true)
      compare(implicitDefault.Accessible.name,
        "Default at login: English (US). Only layout.")
      compare(findChild(picker, "implicitDefaultHeader").text, "DEFAULT AT LOGIN")
      compare(findChild(picker, "implicitDefaultValue").text,
        "English (US) — only layout")
      let add = findChild(picker, "addLayout")
      tryVerify(() => add.activeFocus)
      console.log("NATIVE_ACTIVE_DEFAULT_REMOVE_ATOMIC_OK")
    }
    function test_divergent_save_readback_waits_for_plain_confirmation() {
      let english = fake.baseLayouts[0]
      let polish = fake.baseLayouts[1]
      let initial = [polish, english]
      fake.state = Object.assign({}, fake.state, {layouts: initial,
        configuredLayouts: initial, physicalLayouts: initial, active: 0,
        activeLayouts: [polish]})
      fake.autoAdvance = false
      picker.go("editor")
      wait(20)

      let remove = findChild(picker, "removeLayout0")
      mouseClick(remove)
      fake.finishAction(true)
      fake.finishReadback(true)
      compare(picker.stagedRemoval.phase, "saving")

      // The save reports success but its owned readback is split: runtime
      // has the requested survivor while configured state is still old.
      fake.nextReadbackConfiguredLayouts = initial
      fake.nextRefreshState = Object.assign({}, fake.state, {
        layouts: [english], configuredLayouts: [english],
        physicalLayouts: [english, english],
        compatibilityMode: "duplicated-single-layout", active: 0,
        activeLayouts: [english], pendingRestart: false, problem: ""
      })
      fake.finishAction(true)
      fake.finishReadback(true)

      compare(fake.state.layouts.map(row => row.id).join(","), "us/")
      compare(fake.state.configuredLayouts.map(row => row.id).join(","), "pl/,us/")
      compare(fake.refreshCount, 1)
      verify(fake.refreshPending)
      compare(picker.stagedRemoval.phase, "confirming")
      verify(picker.interactionLocked)
      compare(picker.rows.map(row => row.id).join(","), "pl/,us/")
      compare(picker.editorRows.map(row => row.id).join(","), "pl/,us/")

      fake.finishRefresh(true)
      tryVerify(() => picker.stagedRemoval === null && !picker.interactionLocked)
      compare(picker.rows.map(row => row.id).join(","), "us/")
      compare(picker.editorRows.map(row => row.id).join(","), "us/")
      tryVerify(() => findChild(picker, "addLayout").activeFocus)
      console.log("NATIVE_DIVERGENT_SAVE_CONFIRM_OK")
    }
    function test_divergent_save_confirmation_fails_closed() {
      let english = fake.baseLayouts[0]
      let polish = fake.baseLayouts[1]
      let initial = [polish, english]
      fake.state = Object.assign({}, fake.state, {layouts: initial,
        configuredLayouts: initial, physicalLayouts: initial, active: 0,
        activeLayouts: [polish]})
      fake.autoAdvance = false
      picker.go("editor")
      wait(20)

      mouseClick(findChild(picker, "removeLayout0"))
      fake.finishAction(true)
      fake.finishReadback(true)
      fake.nextReadbackConfiguredLayouts = initial
      fake.finishAction(true)
      fake.finishReadback(true)
      compare(picker.stagedRemoval.phase, "confirming")
      verify(fake.refreshPending)

      // The one extra status readback repeats the split. Keep rendering
      // the last coherent snapshot and close every mutation path.
      fake.finishRefresh(true)
      compare(picker.stagedRemoval, null)
      verify(picker.rejectedRemoval !== null)
      verify(picker.heldView !== null)
      verify(picker.interactionLocked)
      compare(picker.rows.map(row => row.id).join(","), "pl/,us/")
      compare(picker.editorRows.map(row => row.id).join(","), "pl/,us/")
      verify(fake.error.indexOf("previous confirmed list remains shown") >= 0)
      let back = findChild(picker, "backButton")
      tryVerify(() => back.activeFocus)
      verify(back.enabled)
      verify(!findChild(picker, "removeLayout0").enabled)
      compare(fake.refreshCount, 1)
      console.log("NATIVE_DIVERGENT_SAVE_FAIL_CLOSED_OK")
    }
    function test_non_active_removal_saves_without_staging() {
      fake.autoAdvance = false
      fake.animationsEnabled = false
      picker.go("editor")
      wait(20)
      let remove = findChild(picker, "removeLayout0")
      verify(remove)
      mouseClick(remove)
      compare(fake.saveCount, 1)
      compare(fake.switchCount, 0)
      compare(fake.saves[0].layouts.join(","), "pl/")
      verify(picker.pendingRemoval !== null)
      compare(picker.pendingRemoval.removed, "us/")
      compare(remove.text, "")
      let activity = findChild(picker, "removeActivity0")
      verify(activity && activity.visible)
      compare(activity.animated, false)
      compare(findChild(picker, "headerActivity").visible, false)
      fake.finishAction(true)
      fake.finishReadback(true)
      compare(picker.pendingRemoval, null)
      compare(fake.state.active, 0)
      compare(fake.current.id, "pl/")
      console.log("NATIVE_NON_ACTIVE_REMOVE_OK")
    }
    function test_action_stays_busy_through_confirmed_readback() {
      fake.autoAdvance = false
      picker.go("editor")
      wait(20)
      let remove = findChild(picker, "removeLayout0")
      mouseClick(remove)
      compare(fake.saveCount, 1)
      verify(fake.busy)
      compare(findChild(picker, "operationStatus"), null)
      compare(picker.editorRows.length, 2)
      fake.finishAction(true)
      verify(fake.busy)
      compare(fake.operationPhase, "readback")
      compare(picker.editorRows.length, 2)
      fake.finishReadback(true)
      verify(!fake.busy)
      compare(picker.editorRows.length, 1)
      console.log("NATIVE_CONFIRMED_READBACK_OK")
    }
    function test_picker_switch_waits_for_confirmed_readback_to_dismiss() {
      fake.autoAdvance = false
      picker.go("picker")
      wait(20)
      picker.switchLayout(0)
      compare(fake.switchCount, 1)
      compare(preview.dismissCount, 0)
      verify(fake.busy)
      fake.finishAction(true)
      compare(preview.dismissCount, 0)
      verify(fake.busy)
      fake.finishReadback(true)
      compare(preview.dismissCount, 1)
      compare(fake.state.active, 0)
      verify(!fake.busy)
      console.log("NATIVE_PICKER_SWITCH_READBACK_OK")
    }
    function test_failed_staged_switch_clears_operation() {
      fake.autoAdvance = false
      picker.go("editor")
      wait(20)
      let remove = findChild(picker, "removeLayout1")
      mouseClick(remove)
      compare(fake.switchCount, 1)
      picker.forceActiveFocus()
      fake.finishAction(false)
      fake.finishReadback(true)
      tryVerify(() => picker.stagedRemoval === null)
      compare(fake.saveCount, 0)
      verify(fake.stateFresh)
      verify(!fake.busy)
      compare(picker.editorRows.length, 2)
      verify(remove.enabled)
      verify(fake.error !== "")
      tryVerify(() => remove.activeFocus)
      console.log("NATIVE_FAILED_STAGE_CLEANUP_OK")
    }
    function test_failed_staged_save_restores_remove_focus() {
      fake.autoAdvance = false
      picker.go("editor")
      wait(20)
      let remove = findChild(picker, "removeLayout1")
      mouseClick(remove)
      compare(fake.switchCount, 1)
      fake.finishAction(true)
      fake.finishReadback(true)
      compare(picker.stagedRemoval.phase, "saving")
      compare(fake.saveCount, 1)
      picker.forceActiveFocus()
      fake.finishAction(false)
      fake.finishReadback(true)
      tryVerify(() => picker.stagedRemoval === null)
      verify(!fake.busy)
      compare(picker.rows.map(row => row.id).join(","), "us/,pl/")
      compare(picker.editorRows.map(row => row.id).join(","), "us/,pl/")
      verify(remove.enabled)
      tryVerify(() => remove.activeFocus)
      console.log("NATIVE_FAILED_SAVE_FOCUS_OK")
    }
    function test_failed_stage_readback_marks_state_stale() {
      fake.nextReadbackFailure = "switch"
      picker.go("editor")
      wait(20)
      let remove = findChild(picker, "removeLayout1")
      mouseClick(remove)
      tryVerify(() => picker.stagedRemoval === null)
      compare(fake.saveCount, 0)
      verify(!fake.stateFresh)
      verify(!remove.enabled)
      let before = fake.switchCount
      picker.remove(1)
      compare(fake.switchCount, before)
      console.log("NATIVE_STALE_STATE_GATE_OK")
    }
    function test_staged_remove_rejects_changed_revision() {
      fake.nextReadbackRevision = "external-change"
      picker.go("editor")
      wait(20)
      let remove = findChild(picker, "removeLayout1")
      mouseClick(remove)
      tryCompare(fake, "switchCount", 1)
      compare(fake.switches[0].revision, "preview")
      tryVerify(() => picker.stagedRemoval === null)
      compare(fake.state.revision, "external-change")
      compare(fake.saveCount, 0)
      compare(picker.editorRows.length, 2)
      verify(fake.error.indexOf("changed before removal") >= 0)
      console.log("NATIVE_STALE_REVISION_OK")
    }
    function test_staged_remove_ignores_unrelated_result() {
      fake.autoAdvance = false
      picker.go("editor")
      wait(20)
      let remove = findChild(picker, "removeLayout1")
      mouseClick(remove)
      verify(picker.stagedRemoval !== null)
      let requestId = picker.stagedRemoval.requestId
      fake.actionFinished({id: requestId + 100, name: "switch", ok: true,
        outcome: "committed", baseRevision: "preview"})
      compare(picker.stagedRemoval.requestId, requestId)
      compare(fake.saveCount, 0)
      fake.finishAction(true)
      fake.finishReadback(true)
      compare(fake.saveCount, 1)
      fake.finishAction(true)
      fake.finishReadback(true)
      compare(picker.stagedRemoval, null)
      console.log("NATIVE_MATCHED_ACTION_RESULT_OK")
    }
    function test_single_layout_compatibility_stays_logical() {
      let polish = fake.baseLayouts[1]
      fake.state = Object.assign({}, fake.state, {layouts: [polish], configuredLayouts: [polish],
        physicalLayouts: [polish, polish], compatibilityMode: "duplicated-single-layout",
        active: 0, activeLayouts: [polish], pendingRestart: false})
      picker.go("editor")
      wait(20)
      compare(picker.rows.length, 1)
      compare(picker.editorRows.length, 1)
      compare(fake.state.physicalLayouts.length, 2)
      compare(fake.current.id, "pl/")
      let remove = findChild(picker, "removeLayout0")
      verify(remove)
      verify(!remove.visible)
      let implicitDefault = findChild(picker, "implicitDefault")
      verify(implicitDefault)
      verify(implicitDefault.visible)
      compare(implicitDefault.Accessible.name,
        "Default at login: Polish. Only layout.")
      compare(implicitDefault.Accessible.role, Accessible.StaticText)
      compare(findChild(picker, "implicitDefaultHeader").text, "DEFAULT AT LOGIN")
      compare(findChild(picker, "implicitDefaultValue").text,
        "Polish — only layout")
      console.log("NATIVE_COMPATIBILITY_VIEW_OK")
    }
    function test_default_layout_selection() {
      fake.autoAdvance = false
      picker.go("editor")
      wait(20)
      let selector = findChild(picker, "defaultLayout")
      verify(selector)
      compare(selector.label, "Default at login")
      compare(selector.value, "us/")
      compare(selector.options.length, 2)
      compare(selector.options[0].label, "English (US)")
      compare(selector.options[1].label, "Polish")
      compare(selector.enabled, true)
      // The shared Dropdown owns and tests its popup navigation. Mirror
      // its selection contract here so this test stays focused on the
      // picker action wired to `changed(value)`.
      selector.value = "pl/"
      selector.changed("pl/")
      compare(fake.saveCount, 1)
      compare(fake.saves[0].layouts.join(","), "pl/,us/")
      compare(fake.saves[0].shortcut, "both-alt")
      compare(selector.value, "pl/")
      let activity = findChild(picker, "headerActivity")
      verify(activity.visible)
      verify(activity.animated)
      let captured = false
      card.grabToImage(function(result) {
        verify(result.saveToFile(Quickshell.env("KEYBOARD_PREVIEW_OUTPUT")
          + "/saving.png"))
        captured = true
      })
      tryVerify(() => captured)
      fake.finishAction(true)
      fake.finishReadback(true)
      compare(activity.visible, false)
      compare(fake.state.layouts.map(row => row.id).join(","), "pl/,us/")
      compare(fake.state.active, 0)
      compare(fake.state.layouts[fake.state.active].id, "pl/")
      verify(!fake.state.pendingRestart)
      console.log("NATIVE_DEFAULT_LAYOUT_OK")
    }
    function test_mouse_add_does_not_highlight_first_result() {
      fake.autoAdvance = false
      picker.go("search")
      let list = findChild(picker, "searchResults")
      tryVerify(() => list.count >= 2)
      wait(30)
      let first = list.itemAtIndex(0)
      let chosen = list.itemAtIndex(1)
      verify(first && chosen)
      mouseMove(chosen, chosen.width / 2, chosen.height / 2)
      mouseClick(chosen, chosen.width / 2, chosen.height / 2, Qt.LeftButton)
      compare(fake.saveCount, 1)
      wait(30)
      verify(!list.itemAtIndex(0).hasCursor)
      let captured = false
      picker.grabToImage(result => {
        verify(result.saveToFile(Quickshell.env("KEYBOARD_PREVIEW_OUTPUT") + "/mouse-adding-layout.png"))
        captured = true
      })
      tryVerify(() => captured)
      fake.finishAction(true)
      fake.finishReadback(true)
      compare(picker.page, "editor")
    }
    function test_addition_waits_for_readback_data() {
      return [{tag: "success", success: true, leave: false},
        {tag: "failure", success: false, leave: false},
        {tag: "navigate-away", success: true, leave: true}]
    }
    function test_addition_waits_for_readback(data) {
      fake.autoAdvance = false
      picker.go("search")
      let previousResults = picker.results()
      picker.add(fake.catalog[2], fake.catalog[2].variants[0])
      compare(picker.page, "search")
      compare(picker.editorRows.length, 2)
      verify(findChild(picker, "headerActivity").visible)
      if (data.success && !data.leave) {
        wait(30)
        let captured = false
        picker.grabToImage(result => {
          verify(result.saveToFile(Quickshell.env("KEYBOARD_PREVIEW_OUTPUT") + "/adding-layout.png"))
          captured = true
        })
        tryVerify(() => captured)
      }
      fake.finishAction(data.success)
      // The status reply can update bindings before actionFinished.
      // Keep the visible results unchanged across that interval.
      if (data.success) {
        fake.applyOperation(fake.activeOperation)
        compare(JSON.stringify(picker.results()), JSON.stringify(previousResults))
      }
      compare(picker.page, "search")
      if (data.leave) picker.go("picker")
      fake.finishReadback(true)
      compare(picker.page, data.leave ? "picker" : data.success ? "editor" : "search")
      compare(picker.editorRows.length, data.success ? 3 : 2)
      compare(picker.additionRequestId, 0)
      compare(picker.additionResults, null)
    }
    function test_added_layout_is_immediately_switchable() {
      picker.go("search")
      wait(20)
      picker.add(fake.catalog[2], fake.catalog[2].variants[0])
      tryCompare(fake, "saveCount", 1)
      tryVerify(() => picker.editorRows.length === 3)
      compare(fake.state.layouts.map(row => row.id).join(","), "us/,pl/,de/")
      compare(fake.state.configuredLayouts.map(row => row.id).join(","), "us/,pl/,de/")
      picker.go("picker")
      wait(20)
      compare(picker.rows.length, 3)
      fake.switchTo(2)
      tryVerify(() => fake.state.active === 2)
      compare(fake.current.id, "de/")
      console.log("NATIVE_IMMEDIATE_ADD_OK")
    }
    function test_menu_tooltips(data) {
      fake.state = Object.assign({}, fake.state, {
        devices: [{id: "preview", label: "Typing keyboard", certain: true},
             {id: "second", label: "Second keyboard", certain: true}]
      })
      picker.go(data.page)
      wait(20)
      let buttons = visibleButtons(picker)
      verify(buttons.length > 0, "The page must contain controls to test")
      if (data.page === "picker") compare(buttons.length, 3)
      for (let button of buttons) {
        compare(button.tooltipText, "")
        let tooltip = Array.from(button.data).find(child => child instanceof Controls.ToolTip)
        verify(tooltip, "Each button must use the shared tooltip")
        if (button.enabled) {
          mouseMove(button, button.width / 2, button.height / 2)
          wait(500)
          verify(button.hot, "Hover highlighting must still work")
        }
        compare(tooltip.visible, false)
      }
      mouseMove(widget, widget.width / 2, widget.height / 2)
      verify(widget.tooltipHovered)
      compare(widget.tooltipText, "Polish")
      console.log("NATIVE_TOOLTIPS_OK", data.page)
    }
    function test_flag_uses_the_same_slot() {
      let before = widget.implicitWidth
      fake.switchTo(0)
      wait(200)
      compare(widget.flagPhase, true)
      compare(widget.implicitWidth, before)
      wait(1100)
      compare(widget.flagPhase, false)
      compare(widget.code, "EN")
      fake.animationsEnabled = false
      fake.switchTo(1)
      compare(widget.flagPhase, false)
      compare(widget.implicitWidth, before)
      console.log("NATIVE_FLAG_OK")
    }
    function test_unresolved_layouts_are_explained() {
      let message = "The typing interfaces report different or unknown layouts. Select a layout above to synchronize them."
      fake.state = Object.assign({}, fake.state, {active: -1, activeLayouts: fake.state.layouts, problem: message})
      wait(20)
      compare(widget.code, "EN/PL")
      compare(widget.tooltipText, message)
      compare(widget.Accessible.name, message)
      verify(widget.implicitWidth >= 34)
      compare(widget.flagPhase, false)
      let captured = 0
      card.grabToImage(function(result) {
        verify(result.saveToFile(Quickshell.env("KEYBOARD_PREVIEW_OUTPUT") + "/unresolved-picker.png"))
        captured++
      })
      widget.grabToImage(function(result) {
        verify(result.saveToFile(Quickshell.env("KEYBOARD_PREVIEW_OUTPUT") + "/unresolved-indicator.png"))
        captured++
      })
      tryVerify(() => captured === 2)
      fake.state = Object.assign({}, fake.state, {activeLayouts: [], problem: ""})
      fake.error = "The desktop did not respond."
      compare(widget.code, "?")
      compare(widget.tooltipText, fake.error)
      console.log("NATIVE_UNRESOLVED_OK")
    }
    function test_navigation_and_text_input() {
      picker.reset()
      wait(20)
      keyClick(Qt.Key_Tab)
      keyClick(Qt.Key_Tab)
      keyClick(Qt.Key_Return)
      compare(picker.page, "editor")
      keyClick(Qt.Key_Escape)
      compare(preview.dismissCount, 1)
      compare(picker.page, "editor")
      picker.reset()
      compare(picker.page, "picker")
      keyClick(Qt.Key_Escape)
      compare(preview.dismissCount, 2)
      compare(picker.page, "picker")
      picker.go("devices")
      wait(20)
      keyClick(Qt.Key_Escape)
      compare(preview.dismissCount, 3)
      compare(picker.page, "devices")
      picker.reset()
      picker.go("search")
      wait(20)
      keyClick(Qt.Key_J)
      keyClick(Qt.Key_K)
      compare(picker.search, "jk")
      keyClick(Qt.Key_Escape)
      compare(preview.dismissCount, 4)
      compare(picker.page, "search")
      picker.reset()
      compare(picker.page, "picker")
      compare(picker.search, "")
      console.log("NATIVE_INTERACTION_OK")
    }
    function test_repeated_navigation_stays_bounded() {
      console.log("NATIVE_LONGEVITY_BASELINE")
      wait(250)
      for (let i = 0; i < 200; i++) {
        picker.go(i % 2 ? "editor" : "search")
        picker.reset()
      }
      wait(50)
      compare(picker.page, "picker")
      compare(picker.search, "")
      compare(preview.dismissCount, 0)
      console.log("NATIVE_LONGEVITY_OK")
      wait(250)
    }
    function test_search_full_catalog_budget() {
      tryVerify(() => Plugin.Backend.catalog.length >= 100, 5000)
      fake.catalog = Plugin.Backend.catalog
      let rowCount = Plugin.Backend.catalog.reduce((total, layout) => total + layout.variants.length, 0)
      verify(rowCount >= 700)
      picker.go("search")
      let samples = []
      let queries = ["international", "polish", "dead keys", "english us", "us intl", "zz-no-match"]
      for (let i = 0; i < 80; i++) {
        let started = Date.now()
        picker.search = queries[i % queries.length]
        picker.results()
        samples.push(Date.now() - started)
      }
      samples.sort((a, b) => a - b)
      let p95 = samples[Math.floor(samples.length * 0.95) - 1]
      verify(p95 <= 50, "Full-catalog search exceeded 50 ms: " + p95)
      console.log("NATIVE_SEARCH_HEALTH_OK", "rows=" + rowCount, "p95Ms=" + p95)
    }
    function test_search_relevance() {
      tryVerify(() => Plugin.Backend.catalog.length >= 100, 5000)
      fake.catalog = Plugin.Backend.catalog
      let polish = fake.baseLayouts[1]
      fake.state = Object.assign({}, fake.state, {layouts: [polish], configuredLayouts: [polish], active: 0})
      picker.go("search")
      wait(20)

      function pair(row) { return row.layout.id + "/" + row.variant.id }
      for (let query of ["english us", "English (US)", "us english", "US"]) {
        picker.search = query
        let ranked = picker.results()
        verify(ranked.length > 0, "Expected results for " + query)
        compare(pair(ranked[0]), "us/")
      }

      picker.search = "us intl"
      compare(pair(picker.results()[0]), "us/intl")

      picker.search = "english"
      let english = picker.results()
      let firstVariant = english.findIndex(row => !!row.variant.id)
      verify(firstVariant > 0)
      verify(english.slice(0, firstVariant).every(row => !row.variant.id))
      verify(english.slice(0, firstVariant).some(row => pair(row) === "us/"))

      picker.search = ""
      let unfiltered = picker.results()
      verify(unfiltered.every(row => !row.variant.id))
      for (let i = 1; i < unfiltered.length; i++)
        verify(picker.normalized(unfiltered[i - 1].layout.label) <= picker.normalized(unfiltered[i].layout.label))

      fake.state = Object.assign({}, fake.state, {layouts: fake.baseLayouts, configuredLayouts: fake.baseLayouts, active: 1})
      picker.search = "english us"
      let selected = picker.results()
      verify(selected.every(row => pair(row) !== "us/"))
      verify(selected.some(row => pair(row) === "us/intl"))

      let help = findChild(picker, "searchHelp")
      let field = findChild(picker, "layoutSearch")
      verify(help && help.visible)
      compare(help.text, "Try “English US” or “US intl”")
      compare(field.placeholderText, "Language, country code, or variant")
      verify(help.mapToItem(picker, 0, help.height).y
        < field.mapToItem(picker, 0, 0).y)

      fake.state = Object.assign({}, fake.state, {layouts: [polish], configuredLayouts: [polish], active: 0})
      picker.search = "english us"
      wait(20)
      field.forceActiveFocus()
      keyClick(Qt.Key_Return)
      tryCompare(fake, "saveCount", 1)
      compare(fake.saves[0].layouts.join(","), "pl/,us/")
      tryCompare(picker, "page", "editor")
      console.log("NATIVE_SEARCH_RELEVANCE_OK")
    }
  }
  QtObject {
    id: fake
    property var baseLayouts: [
      {id: "us/", layout: "us", variant: "", label: "English (US)", variantLabel: "Standard", code: "EN", country: "us"},
      {id: "pl/", layout: "pl", variant: "", label: "Polish", variantLabel: "Standard", code: "PL", country: "pl"}]
    property var state: ({layouts: baseLayouts, configuredLayouts: baseLayouts, configuredShortcut: "both-alt",
      physicalLayouts: baseLayouts, compatibilityMode: "", pendingRestart: false, active: 1,
      devices: [], device: "preview", revision: "preview", shortcut: "both-alt", problem: ""})
    property var fixtureCatalog: [
      {id: "us", label: "English (US)", search: "english us", variants: [{id: "", label: "Standard"}, {id: "intl", label: "English (US, intl., with dead keys)"}]},
      {id: "pl", label: "Polish", search: "polish pl", variants: [{id: "", label: "Standard"}]},
      {id: "de", label: "German", search: "german de", variants: [{id: "", label: "Standard"}]},
      {id: "fr", label: "French", search: "french fr", variants: [{id: "", label: "Standard"}]}]
    property var catalog: fixtureCatalog
    property var shortcuts: [{value: "both-alt", label: "Both Alt keys"}, {value: "bar", label: "The bar only"}]
    property bool stateFresh: true
    property bool autoAdvance: true
    property string nextActionFailure: ""
    property string nextReadbackFailure: ""
    property string nextReadbackRevision: ""
    property var nextReadbackConfiguredLayouts: null
    property var nextRefreshState: null
    property int refreshCount: 0
    property bool refreshPending: false
    property int nextRequestId: 1
    property var activeOperation: null
    readonly property bool busy: activeOperation !== null || refreshPending
    readonly property bool operationActive: activeOperation !== null
    readonly property string operationPhase: activeOperation ? activeOperation.phase
      : (refreshPending ? "refresh" : "")
    property bool animationsEnabled: true
    readonly property var current: state.active >= 0 && state.active < state.layouts.length ? state.layouts[state.active] : null
    property string error: ""
    property var saves: []
    property var switches: []
    readonly property int saveCount: saves.length
    readonly property int switchCount: switches.length
    signal actionFinished(var result)
    signal refreshed(bool ok)
    function resetOperation() {
      fakeAction.stop()
      fakeReadback.stop()
      fakeRefresh.stop()
      activeOperation = null
      refreshPending = false
    }
    function request(name, args, revision) {
      if (busy || !stateFresh) {
        if (!stateFresh) error = "Refresh the keyboard state before changing it."
        return 0
      }
      error = ""
      let id = nextRequestId++
      activeOperation = {id: id, name: name, args: args, revision: revision === undefined ? state.revision : revision,
        phase: "action", actionOk: false}
      if (autoAdvance) fakeAction.restart()
      return id
    }
    function switchTo(index, revision) {
      let id = request("switch", {index: index}, revision)
      if (id) switches = switches.concat([{index: index,
        revision: revision === undefined ? state.revision : revision, requestId: id}])
      return id
    }
    function save(ids, shortcut, revision, expectedActiveId) {
      let copied = ids.slice()
      let args = {layouts: copied, shortcut: shortcut}
      if (expectedActiveId !== undefined) args.expectedActiveId = expectedActiveId
      let id = request("save", args, revision)
      if (id) saves = saves.concat([{layouts: copied, shortcut: shortcut,
        revision: revision === undefined ? state.revision : revision,
        expectedActiveId: expectedActiveId, requestId: id}])
      return id
    }
    function finishAction(ok) {
      if (!activeOperation || activeOperation.phase !== "action") return
      let operation = activeOperation
      operation.actionOk = ok
      operation.phase = "readback"
      activeOperation = Object.assign({}, operation)
      if (!ok) error = "The keyboard rejected the request."
      if (autoAdvance) fakeReadback.restart()
    }
    function applyOperation(operation) {
      if (operation.name === "switch") {
        state = Object.assign({}, state, {active: operation.args.index})
        return
      }
      if (operation.name !== "save") return
      let all = baseLayouts.concat([{id: "de/", layout: "de", variant: "", label: "German", variantLabel: "Standard", code: "DE", country: "de"}])
      let activeId = current ? current.id : ""
      let rows = operation.args.layouts.map(id => all.find(row => row.id === id))
      let active = operation.args.layouts.indexOf(activeId)
      if (active < 0) active = 0
      let physical = rows.length === 1 ? [rows[0], rows[0]] : rows
      state = Object.assign({}, state, {layouts: rows, configuredLayouts: rows, active: active,
        physicalLayouts: physical,
        compatibilityMode: rows.length === 1 ? "duplicated-single-layout" : "",
        shortcut: operation.args.shortcut, configuredShortcut: operation.args.shortcut,
        pendingRestart: false})
    }
    function finishReadback(ok) {
      if (!activeOperation || activeOperation.phase !== "readback") return
      let operation = activeOperation
      if (ok && operation.actionOk) applyOperation(operation)
      if (ok && nextReadbackRevision) {
        state = Object.assign({}, state, {revision: nextReadbackRevision})
        nextReadbackRevision = ""
      }
      if (ok && nextReadbackConfiguredLayouts !== null) {
        state = Object.assign({}, state,
          {configuredLayouts: nextReadbackConfiguredLayouts})
        nextReadbackConfiguredLayouts = null
      }
      stateFresh = ok
      if (!ok) error = "The keyboard state could not be refreshed."
      activeOperation = null
      refreshed(ok)
      actionFinished({id: operation.id, name: operation.name,
        ok: operation.actionOk && ok,
        outcome: operation.actionOk && ok ? "committed" : (!operation.actionOk && ok ? "rejected" : "unconfirmed"),
        error: error, baseRevision: operation.revision})
    }
    function refresh() {
      if (busy) return
      refreshCount++
      refreshPending = true
      if (autoAdvance) fakeRefresh.restart()
    }
    function finishRefresh(ok) {
      if (!refreshPending) return
      if (ok && nextRefreshState !== null) state = nextRefreshState
      nextRefreshState = null
      stateFresh = ok
      error = ok ? "" : "The keyboard state could not be refreshed."
      refreshPending = false
      refreshed(ok)
    }
    property Timer fakeAction: Timer {
      id: fakeAction
      interval: 5
      onTriggered: {
        let name = fake.activeOperation ? fake.activeOperation.name : ""
        let ok = fake.nextActionFailure !== name
        if (!ok) fake.nextActionFailure = ""
        fake.finishAction(ok)
      }
    }
    property Timer fakeReadback: Timer {
      id: fakeReadback
      interval: 5
      onTriggered: {
        let name = fake.activeOperation ? fake.activeOperation.name : ""
        let ok = fake.nextReadbackFailure !== name
        if (!ok) fake.nextReadbackFailure = ""
        fake.finishReadback(ok)
      }
    }
    property Timer fakeRefresh: Timer {
      id: fakeRefresh
      interval: 5
      onTriggered: fake.finishRefresh(true)
    }
  }
  FloatingWindow {
    id: window
    visible: true
    implicitWidth: 390
    implicitHeight: 580
    color: Color.background
    Plugin.Indicator {
      id: widget
      x: 340
      y: 0
      width: implicitWidth
      height: implicitHeight
      backend: fake
    }
    Ui.BorderSurface {
      id: card
      x: 20
      y: 24
      width: picker.page === "picker" ? 272 : 336
      height: picker.implicitHeight + 28
      color: Color.popups.background
      borderSpec: Border.surfaceSpec("popups", "border", Color.popups.border, 2)
      radius: Style.cornerRadius
      Plugin.Picker {
        id: picker
        x: 14
        y: 14
        width: parent.width - 28
        height: implicitHeight
        backend: fake
        onDismiss: preview.dismissCount++
      }
    }
  }
  Loader {
    id: listing
    active: preview.listingMode
    sourceComponent: ListingPreview { backend: fake }
  }
  Timer {
    interval: 300
    repeat: true
    running: true
    onTriggered: {
      if (preview.step >= preview.pages.length * 2) {
        console.log("NATIVE_PREVIEW_OK")
        stop()
        if (preview.listingMode) {
          listing.item.capture(() => {
            console.log("NATIVE_LISTING_OK")
            Qt.quit()
          })
        } else preview.capturesComplete = true
        return
      }
      let name = preview.pages[Math.floor(preview.step / 2)]
      if (preview.step % 2 === 0) {
        picker.page = name
      } else {
        if (picker.implicitHeight > 530 || picker.implicitHeight < 40) throw new Error("Invalid panel height")
        card.grabToImage(function(result) {
          if (!result.saveToFile(Quickshell.env("KEYBOARD_PREVIEW_OUTPUT") + "/" + name + ".png")) throw new Error("Screenshot failed")
        })
        console.log("NATIVE_PAGE", name, picker.implicitHeight)
      }
      preview.step++
    }
  }
}
