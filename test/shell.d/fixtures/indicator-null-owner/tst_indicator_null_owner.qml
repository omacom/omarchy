import QtQuick
import QtTest

TestCase {
  name: "IndicatorNullOwner"
  when: windowShown
  width: 320
  height: 48

  property var indicatorsComponent: null

  function initTestCase() {
    indicatorsComponent = Qt.createComponent(Qt.resolvedUrl("../../../../shell/plugins/bar/widgets/Indicators.qml"))
    compare(indicatorsComponent.status, Component.Ready, indicatorsComponent.errorString())
  }

  function findNamed(item, moduleName) {
    if (!item) return null
    if (item.moduleName === moduleName) return item
    var kids = item.children || []
    for (var i = 0; i < kids.length; i++) {
      var found = findNamed(kids[i], moduleName)
      if (found) return found
    }
    return null
  }

  function waitNamed(bar, moduleName) {
    var found = null
    for (var i = 0; i < 40 && !found; i++) {
      wait(25)
      found = findNamed(bar, moduleName)
    }
    return found
  }

  // The bar hosts the indicators and is the object they read as `bar`.
  // Destroying that host is what leaves injectProps running with a null root.
  function test_loadedIndicatorsKeepTheirBarUntilTheHostIsGone() {
    var bar = barComponent.createObject(this, { indicatorsComponent: indicatorsComponent })
    verify(bar)

    var stayAwake = waitNamed(bar, "StayAwake")
    var dnd = waitNamed(bar, "Dnd")
    verify(stayAwake, "StayAwake loaded under a live bar")
    verify(dnd, "Dnd loaded under a live bar")
    compare(stayAwake.bar, bar, "a live owner injects itself as StayAwake's bar")
    compare(dnd.bar, bar, "a live owner injects itself as Dnd's bar")
    compare(stayAwake.indicatorHost.moduleName, "omarchy.indicators", "indicator host stays the indicators widget")

    failOnWarning(/Cannot read property 'bar' of null/)
    bar.destroy()
    wait(150)
  }

  Component {
    id: barComponent
    Item {
      id: barRoot
      property var indicatorsComponent: null
      property bool vertical: false
      property int barSize: 26
      property string fontFamily: "monospace"
      property color barForeground: "white"
      property color urgent: "red"
      property bool foregroundAnimationEnabled: false
      property bool centerSectionRevealHeld: false
      property bool centerHoverRevealSuppressed: false
      property var shell: null
      function run(command) {}
      function showTooltip(target, text) {}
      function hideTooltip(target) {}
      function registerClickTarget(target) {}
      function unregisterClickTarget(target) {}

      Loader {
        anchors.fill: parent
        sourceComponent: barRoot.indicatorsComponent
        onLoaded: {
          item.bar = barRoot
          item.settings = { items: ["StayAwake", "Dnd"] }
        }
      }
    }
  }
}
