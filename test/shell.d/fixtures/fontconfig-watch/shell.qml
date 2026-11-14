import QtQuick
import Quickshell
import "Commons"

ShellRoot {
  property string family: Style.resolvedFontFamily
  onFamilyChanged: console.log("FONT_RESOLVED:" + family)
}
