import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import qs.plugins.bar as BarParts

ShellRoot {
  id: test

  property var failures: []
  property int stage: 0
  property var first: null
  property var retained: null
  property var retainedApi: null

  function check(condition, message) {
    if (!condition) failures.push(message)
  }

  function config(entries, clear) {
    return { background: clear ? "none" : "opaque", transparentForegroundPerMonitor: clear,
             layout: { left: entries, center: [], right: [] } }
  }

  function entries(twoCopies) {
    var result = [{ id: "test.first" }, { id: "test.third" }]
    if (twoCopies) result.push({ id: "test.third" })
    return result
  }

  Component {
    id: widget
    WidgetButton { text: "test" }
  }

  QtObject {
    id: registry
    property var widgets: ({ "test.first": { component: widget }, "test.third": { component: widget } })
    property int revision: 0
    function metadataFor(id) { return { firstParty: id === "test.first" } }
  }

  BarParts.Bar {
    id: bar
    barConfig: test.config(test.entries(true), false)
    barWidgetRegistry: registry
    glassSyncedLook: "opaque"
    barHidden: true
  }

  FileView {
    id: result
    path: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  }

  Timer {
    interval: 500
    running: true
    repeat: true
    onTriggered: {
      if (test.stage === 0) {
        var firstCopies = bar.moduleWidgets("test.first")
        var thirdCopies = bar.moduleWidgets("test.third")
        test.check(firstCopies.length > 0 && thirdCopies.length >= 2, "real widget hosts are instantiated")
        if (firstCopies.length && thirdCopies.length >= 2) {
          test.first = firstCopies[0]
          test.retained = thirdCopies[0]
          test.retainedApi = test.retained.bar
          var surface = test.first.bar
          test.check(bar.barSurfaces.indexOf(surface) !== -1, "first-party widget receives its real monitor surface")
          test.check(surface.clickTargets === bar.clickTargets, "surface forwards click targets for one-click panel switching")
          test.check(typeof surface.notePopoutCard === "function" && typeof surface.popoutCardFor === "function", "surface forwards panel handoff geometry")
          test.check(typeof surface.barSizeFor === "function" && surface.barSizeFor(surface.screen.name) === bar.barSizeFor(surface.screen.name), "surface forwards notch-aware panel anchoring")
          test.check(surface.barHidden === bar.barHidden, "surface forwards the hidden state")
          test.check(surface.traySectionDragActive === bar.traySectionDragActive && surface.traySectionPopoutOpen === bar.traySectionPopoutOpen, "surface forwards tray drawer state")
          test.check(test.retainedApi !== surface && test.retainedApi !== bar, "third-party widget receives a restricted facade")
          test.check(test.retainedApi !== thirdCopies[1].bar, "duplicate widget hosts keep separate presentation facades")
          test.retainedApi.requestPopout(test.retained)
          test.check(test.retainedApi.activePopout === test.retained, "requesting a popout updates its facade immediately")
          test.retainedApi.releasePopout(test.retained)
          test.check(test.retainedApi.activePopout === null, "releasing a popout updates its facade immediately")
          bar.barConfig = test.config(test.entries(true), true)
        }
      } else if (test.stage === 1 && test.retained) {
        test.check(test.first.bar.transparent, "ordinary clear background activates after sampling")
        test.check(test.retainedApi.transparent === test.first.bar.transparent, "third-party transparency follows its own surface")
        test.check(String(test.retainedApi.barForeground) === String(test.first.bar.barForeground), "third-party foreground follows its own surface")
        test.check(String(test.first.bar.foreground) === String(Commons.Color.popups.text), "popup text never inherits wallpaper contrast")
        bar.barConfig = test.config(test.entries(false), false)
      } else {
        if (test.retained) {
          test.check(bar.moduleWidgets("test.third").indexOf(test.retained) !== -1, "surviving widget host is retained after removing a duplicate")
          test.check(test.retained.bar === test.retainedApi, "surviving facade keeps its identity")
          test.check(!test.retainedApi.transparent, "returning to opaque updates the surviving facade")
          test.check(bar.clickTargets.indexOf(test.retained) !== -1, "pruning a duplicate preserves the survivor's click target")
        }
        result.setText(JSON.stringify({ ok: test.failures.length === 0, failures: test.failures }))
        stop()
      }
      test.stage++
    }
  }
}
