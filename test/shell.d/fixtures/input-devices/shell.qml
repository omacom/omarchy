import QtQuick
import Quickshell
import qs.Commons

ShellRoot {
  Connections {
    target: InputDevices
    function onChanged() { console.log("CHANGED " + Date.now()) }
  }
}
