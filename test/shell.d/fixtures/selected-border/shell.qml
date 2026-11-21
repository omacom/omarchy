import QtQuick
import QtQuick.Window
import Quickshell
import qs.Commons
import qs.Ui

ShellRoot {
  id: root

  function assert(condition, message) {
    if (!condition) throw new Error(message)
  }

  function surfaces(item, result) {
    if (item.borderSpec !== undefined) result.push(item)
    for (var i = 0; i < item.children.length; i++) surfaces(item.children[i], result)
    return result
  }

  function checkbox() {
    var all = surfaces(window.contentItem, [])
    for (var i = 0; i < all.length; i++) {
      if (all[i].width === Style.space(16) && all[i].height === Style.space(16)) return all[i]
    }
    throw new Error("MultiSelect checkbox delegate was not created")
  }

  function track() {
    var all = surfaces(toggle, [])
    for (var i = 0; i < all.length; i++) {
      if (all[i].visible && all[i].width === toggle.trackWidth && all[i].height === toggle.trackHeight) return all[i]
    }
    throw new Error("ToggleSwitch track was not created")
  }

  function checkSpec(actual, expected, message) {
    assert(JSON.stringify(actual.widths) === JSON.stringify(expected.widths), message + " widths: " + JSON.stringify(actual.widths))
    assert(Border.sameColor(actual.color, expected.color), message + " color")
    assert(JSON.stringify(actual.gradient) === JSON.stringify(expected.gradient), message + " gradient")
  }

  property int step: 0
  property var cases: [
    { name: "default normal border", selectedState: "normal", plainSelected: false, overrides: {} },
    { name: "explicitly borderless normal", selectedState: "normal", plainSelected: false, overrides: { "normal-border-width": 0 } },
    { name: "dedicated selected border", selectedState: "selected", plainSelected: true, overrides: { "selected-border-width": 3, "selected-border": "#ff0000 #0000ff 90deg" } },
    { name: "per-side selected border", selectedState: "selected", plainSelected: true, overrides: { "selected-border-width": 0, "selected-border-width-left": 4 } },
    { name: "normal gradient fallback", selectedState: "normal", plainSelected: false, overrides: { "normal-border-width": "1 2 3 4", "normal-border": "#00ff00 #0000ff 45deg" } }
  ]

  Timer {
    id: checks
    interval: 100
    running: true
    repeat: true
    onTriggered: {
      try {
        if (root.step === 0) {
          multi.open()
        } else if (root.step <= root.cases.length * 3) {
          var index = Math.floor((root.step - 1) / 3)
          var phase = (root.step - 1) % 3
          var test = root.cases[index]
          if (phase === 0) {
            Style.styleOverrides = test.overrides
            Color.shellValues = ({})
            toggle.checked = false
            multi.values = []
            bordered.current = false
            plain.current = false
          } else if (phase === 1) {
            var normal = Border.controlSpec("normal", toggle.foreground, toggle.accent)
            root.checkSpec(root.track().borderSpec, normal, test.name + " unchecked switch")
            root.checkSpec(root.checkbox().borderSpec, Border.controlSpec("normal", multi.foreground, multi.accent), test.name + " unchecked checkbox")
            root.checkSpec(bordered.borderSpec, Border.controlSpec("normal", bordered.foreground, bordered.accent), test.name + " bordered row")
            root.assert(Border.isNone(plain.borderSpec), test.name + " plain row at rest")
            toggle.checked = true
            multi.values = ["test"]
            bordered.current = true
            plain.current = true
          } else {
            var capture = (Quickshell.env("SELECTED_BORDER_CAPTURE") || "")
            if (index === 0 && capture !== "") {
              checks.stop()
              window.contentItem.grabToImage(function(result) {
                if (!result.saveToFile(capture)) console.log("RESULT fail saving capture")
                else console.log("RESULT pass capture")
                Qt.quit()
              })
              return
            }
            var state = test.selectedState
            root.checkSpec(root.track().borderSpec, Border.controlSpec(state, toggle.foreground, toggle.accent), test.name + " checked switch")
            root.checkSpec(root.checkbox().borderSpec, Border.controlSpec(state, multi.foreground, multi.accent), test.name + " checked checkbox")
            root.checkSpec(bordered.borderSpec, Border.controlSpec(state, bordered.foreground, bordered.accent), test.name + " current bordered row")
            root.checkSpec(plain.borderSpec, test.plainSelected ? Border.controlSpec("selected", plain.foreground, plain.accent) : Border.none(), test.name + " current plain row")
            console.log("RESULT pass " + test.name)
          }
        } else if (root.step === root.cases.length * 3 + 1) {
          Style.styleOverrides = ({ "hover-cursor-border-width": 2, "selected-border-width": 3 })
          bordered.hasCursor = true
          plain.hasCursor = true
        } else {
          root.checkSpec(bordered.borderSpec, Border.controlSpec("hover-cursor", bordered.foreground, bordered.accent), "hover precedes selected bordered row")
          root.checkSpec(plain.borderSpec, Border.controlSpec("hover-cursor", plain.foreground, plain.accent), "hover precedes selected plain row")
          console.log("RESULT pass hover precedence")
          checks.stop()
          Qt.quit()
        }
        root.step++
      } catch (error) {
        console.log("RESULT fail " + error.message)
        checks.stop()
        Qt.quit()
      }
    }
  }

  Window {
    id: window
    visible: true
    width: 480
    height: 480
    color: "#202020"
    Column {
      x: 24
      y: 24
      spacing: 12
      ToggleSwitch { id: toggle; interactive: false }
      CursorSurface { id: bordered; width: 260; height: 36; bordered: true }
      CursorSurface { id: plain; width: 260; height: 36 }
      MultiSelect { id: multi; width: 260; showLabel: false; options: ["test"]; rowHeight: 40 }
    }
  }
}
