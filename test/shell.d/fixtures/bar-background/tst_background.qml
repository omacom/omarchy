import QtQuick
import QtTest

TestCase {
  name: "BarBackground"
  when: windowShown
  width: 400
  height: 100

  Component {
    id: material
    Rectangle {
      property color themeColor: parent.backgroundColor
      property string position: parent.barPosition
      property bool vertical: parent.barVertical
      color: themeColor
    }
  }

  BackgroundHarness { id: first; width: 300; height: 30 }
  BackgroundHarness { id: second; width: 30; height: 100; position: "left"; vertical: true }

  function cleanup() {
    first.backgroundComponent = null
    second.backgroundComponent = null
    first.transparent = false
  }

  function test_defaultAndRemoval() {
    compare(first.color, first.background)
    compare(first.painted, null)
    first.backgroundComponent = material
    verify(first.painted !== null)
    compare(first.color, "#00000000")
    first.backgroundComponent = null
    compare(first.painted, null)
    compare(first.color, first.background)
  }

  function test_inputsAndIndependentInstances() {
    first.backgroundComponent = material
    second.backgroundComponent = material
    verify(first.painted !== second.painted)
    compare(first.painted.width, 300)
    compare(second.painted.width, 30)
    compare(second.painted.position, "left")
    compare(second.painted.vertical, true)
    first.background = "#123456"
    compare(first.painted.themeColor, "#123456")
    first.width = 250
    compare(first.painted.width, 250)
    verify(!first.painted.enabled)
  }

  function test_transparencyUnloads() {
    first.backgroundComponent = material
    first.transparent = true
    compare(first.painted, null)
    compare(first.color, "#00000000")
    first.transparent = false
    verify(first.painted !== null)
  }
}
