import QtQuick
import Quickshell
import qs.Commons
import qs.Commons as Commons
import qs.Ui

ShellRoot {
  id: root
  property int stage: 0

  function fail(message) {
    console.log("RESULT fail " + message)
    Qt.quit()
  }

  Timer {
    interval: 100
    running: true
    repeat: true
    onTriggered: {
      if (root.stage === 0) {
        Commons.Color.loadUserShell('[menu]\nbackground = "#11223380 #445566 25deg"\nbackground-alpha = 0.5\nselected-background = "#11223380 foreground 0deg"\nselected-background-alpha = 0.35')
      } else if (root.stage === 1) {
        var background = Commons.Color.menu.backgroundSpec
        var selected = Commons.Color.menu.selectedBackgroundSpec
        if (!background.gradient.enabled || background.gradient.colors.length !== 2 || background.gradient.angle !== 25
            || Math.abs(background.gradient.colors[0].a - 128 / 255 * 0.5) > 0.01
            || Math.abs(Commons.Color.menu.background.a - background.gradient.colors[0].a) > 0.01
            || !selected.gradient.enabled || Math.abs(selected.gradient.colors[0].a - 128 / 255 * 0.35) > 0.01
            || Math.abs(Commons.Color.menu.selectedBackground.a - selected.gradient.colors[0].a) > 0.01) {
          root.fail("gradient values and color-only fallbacks differ")
          return
        }
        if (!card.usesGradientFill || !card.usesOverlayBorder || !selection.usesGradientFill || card.color.a > 0.01 || selection.color.a > 0.01) {
          root.fail("gradient surfaces did not replace their solid fallbacks")
          return
        }
        Commons.Color.loadUserShell('[menu]\nbackground = "#11223380"\nbackground-alpha = 0.5\nselected-background = "#445566"\nselected-background-alpha = 0.35')
      } else if (root.stage === 2) {
        if (card.usesGradientFill || selection.usesGradientFill || Math.abs(card.color.a - 0.5) > 0.01) {
          root.fail("solid values did not restore native rendering")
          return
        }
        Commons.Color.loadUserShell('[menu]\nbackground = "fill.alias"\n[fill]\nalias = "menu.background"')
      } else {
        if (Math.abs(Commons.Color.menu.background.r - Commons.Color.background.r) > 0.01
            || Math.abs(Commons.Color.menu.background.g - Commons.Color.background.g) > 0.01
            || Math.abs(Commons.Color.menu.background.b - Commons.Color.background.b) > 0.01) {
          root.fail("cyclic references did not fall back")
          return
        }
        console.log("RESULT pass")
        Qt.quit()
      }
      root.stage++
    }
  }

  BorderSurface {
    id: card
    width: 160
    height: 100
    radius: 12
    fillColor: Commons.Color.menu.background
    fillSpec: Commons.Color.menu.backgroundSpec
    borderSpec: Border.flat("white", 1)
  }
  BorderSurface {
    id: selection
    width: 120
    height: 40
    radius: 8
    fillColor: Commons.Color.menu.selectedBackground
    fillSpec: Commons.Color.menu.selectedBackgroundSpec
  }
}
