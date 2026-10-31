pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// One event-driven preference reader per QML engine. Theme mode keeps bindings
// to the active palette/geometry; user overrides never rewrite theme files.
QtObject {
  id: root
  property var preferences: ({})
  readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")
  readonly property string path: configHome + "/omarchy/tooltips.json"
  readonly property string shape: preferences.shape || "theme"
  readonly property string borderMode: preferences.borderMode || "theme"
  readonly property string borderColor: preferences.borderColor || "#ffffff"

  function load(raw) {
    if (!String(raw || "").trim()) {
      preferences = ({})
      return
    }
    try {
      var next = JSON.parse(raw)
      if (!next || typeof next !== "object" || Array.isArray(next)) return
      if (next.shape !== undefined && ["theme", "square", "rounded"].indexOf(next.shape) < 0) return
      if (next.borderMode !== undefined && ["theme", "transparent", "custom"].indexOf(next.borderMode) < 0) return
      if (next.borderColor !== undefined && !/^#[0-9a-fA-F]{6}$/.test(next.borderColor)) return
      preferences = next
    } catch (error) {
      // A malformed external edit retains the last valid appearance.
    }
  }

  function radius(themeRadius) {
    if (shape === "square") return 0
    if (shape === "rounded") return Style.space(8)
    return themeRadius
  }

  function borderSpec(themeSpec) {
    if (borderMode === "theme") return themeSpec
    return {
      color: borderMode === "transparent" ? "transparent" : borderColor,
      widths: themeSpec.widths,
      gradient: { colors: [], angle: 0, enabled: false }
    }
  }

  property FileView settings: FileView {
    path: root.path
    watchChanges: true
    printErrors: false
    onLoaded: root.load(text())
    onFileChanged: reload()
    onLoadFailed: root.load("")
  }
}
