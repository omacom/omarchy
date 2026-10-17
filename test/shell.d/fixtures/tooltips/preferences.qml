//@ pragma RespectSystemStyle
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui as Ui

ShellRoot {
  id: test
  property int step: 0
  property int failures: 0
  function check(ok, message) {
    console.log((ok ? "PASS " : "FAIL ") + message)
    if (!ok) failures++
  }
  function replaceFile(raw) {
    writer.command = ["python3", "-c", "import os,sys; from pathlib import Path; p=Path(sys.argv[1]); p.parent.mkdir(parents=True,exist_ok=True); t=p.with_suffix('.tmp'); t.write_text(sys.argv[2]); os.replace(t,p)", ToolTipStyle.path, raw]
    writer.running = true
  }
  Process { id: writer }
  FloatingWindow {
    implicitWidth: 500
    implicitHeight: 300
    Ui.ToolTipSurface { id: surface; text: "Preferences"; width: implicitWidth; height: implicitHeight }
    Item {
      Ui.PanelToolTip { id: plain; text: "Plain"; delay: 0 }
      Ui.HoverCard { id: rich; content: Item { implicitHeight: 50 } }
    }
  }
  Timer {
    interval: 350
    running: true
    repeat: true
    onTriggered: {
      switch (test.step++) {
      case 0:
        Style.reduceMotion = true
        Style.cornerRadius = 13
        test.check(ToolTipStyle.shape === "theme" && ToolTipStyle.borderMode === "theme", "absent preferences follow theme")
        plain.open()
        rich.open()
        test.replaceFile('{"shape":"square","borderMode":"transparent"}')
        break
      case 1:
        test.check(surface.radius === 0 && plain.contentItem.radius === 0 && rich.background.radius === 0, "atomic creation updates all tooltip hosts")
        test.check(Qt.color(Border.color(surface.borderSpec)).a === 0, "transparent border removes color without changing theme files")
        test.replaceFile('{"shape":"rounded","borderMode":"custom","borderColor":"#123456"}')
        break
      case 2:
        test.check(surface.radius === Style.space(8) && surface.radius > 0, "rounded overrides square themes")
        test.check(String(Border.color(surface.borderSpec)) === "#123456", "custom color applies live")
        test.check(String(Border.color(rich.background.borderSpec)) === "#123456", "rich card follows shared color")
        test.replaceFile('{"shape":"theme","borderMode":"theme"}')
        break
      case 3:
        Commons.Color.loadShell('[tooltip]\nborder = "#112233 #445566 90deg"')
        Style.cornerRadius = 17
        break
      case 4:
        test.check(surface.radius === 17, "theme mode keeps live radius binding")
        test.check(surface.borderSpec.gradient.enabled, "theme mode restores themed gradient")
        test.replaceFile('not valid JSON')
        break
      case 5:
        test.check(ToolTipStyle.shape === "theme" && ToolTipStyle.borderMode === "theme", "malformed external edits retain last valid state")
        test.replaceFile('{"shape":"rounded","borderMode":"custom","borderColor":"not a color"}')
        break
      case 6:
        test.check(ToolTipStyle.shape === "theme", "invalid color rejects the entire external update")
        test.replaceFile('{"shape":"square","borderMode":"custom","borderColor":"#abcdef"}')
        break
      case 7:
        test.check(surface.radius === 0 && String(Border.color(surface.borderSpec)) === "#abcdef", "reader recovers after invalid input")
        writer.command = ["python3", "-c", "import os,sys; os.unlink(sys.argv[1])", ToolTipStyle.path]
        writer.running = true
        break
      case 8:
        test.check(ToolTipStyle.shape === "theme" && surface.radius === 17, "deleting preferences restores theme defaults")
        console.log(test.failures ? "PREFERENCES_RESULT fail " + test.failures : "PREFERENCES_RESULT pass")
        Qt.quit()
      }
    }
  }
}
