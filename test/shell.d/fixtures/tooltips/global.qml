//@ pragma RespectSystemStyle
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

// No qs.Commons or qs.Ui supplied by this independent application.
ShellRoot {
  id: root
  property int step: 0
  property int failures: 0
  property string configHome: Quickshell.env("XDG_CONFIG_HOME")
  property string themeHome: Quickshell.env("HOME") + "/.local/state/omarchy/current/theme"
  function check(ok, message) {
    console.log((ok ? "PASS " : "FAIL ") + message)
    if (!ok) failures++
  }
  function replaceFile(path, raw) {
    writer.command = ["python3", "-c", "import os,sys; from pathlib import Path; p=Path(sys.argv[1]); t=p.with_suffix('.tmp'); t.write_text(sys.argv[2]); os.replace(t,p)", path, raw]
    writer.running = true
  }
  Process { id: writer }
  FloatingWindow {
    implicitWidth: 400
    implicitHeight: 200
    Button { id: button; text: "Independent"; ToolTip.text: "Hint" }
  }
  Timer {
    running: true
    repeat: true
    interval: 350
    onTriggered: {
      const tip = button.ToolTip.toolTip
      switch (root.step++) {
      case 0:
        root.check(tip.maximumWidth !== undefined, "global module styles unchanged independent consumer")
        root.replaceFile(root.configHome + "/omarchy/tooltips.json", '{"shape":"rounded","borderMode":"custom","borderColor":"#abcdef"}')
        break
      case 1:
        root.check(tip.contentItem.radius > 0 && String(tip.contentItem.borderSpec.color) === "#abcdef", "global provider follows shared preferences")
        root.replaceFile(root.themeHome + "/shell.toml", '[tooltip]\nbackground = "#eeeeee"\nborder = "#123456 #654321 90deg"')
        break
      case 2:
        root.check(String(tip.contentItem.color) === "#eeeeee", "independent tooltip follows live theme file update")
        root.check(String(tip.contentItem.borderSpec.color) === "#abcdef", "theme update preserves custom color")
        root.replaceFile(root.configHome + "/omarchy/tooltips.json", '{"shape":"theme","borderMode":"theme"}')
        break
      case 3:
        root.check(tip.contentItem.borderSpec.gradient.enabled, "theme mode restores independent provider gradient")
        console.log(root.failures ? "GLOBAL_RESULT fail" : "GLOBAL_RESULT pass")
        Qt.quit()
      }
    }
  }
}
