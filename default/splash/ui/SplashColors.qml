import QtQuick
import Quickshell
import Quickshell.Io

// The theme's colors for the splash and the login screen, as
// omarchy-theme-set-login-colors writes them, with the default theme's (Tokyo
// Night's) for any it leaves out. The boot splash's copy comes off the unencrypted ESP,
// so anything but a known key with a #rrggbb value is ignored.
Scope {
  id: root

  required property string path

  readonly property var colors: {
    const result = {
      background: "#1a1b26",
      foreground: "#a9b1d6",
      accent: "#7aa2f7",
      error: "#f7768e"
    }
    for (const line of file.text().split("\n")) {
      const match = /^(background|foreground|accent|error)=(#[0-9a-fA-F]{6})$/.exec(line.trim())
      if (match) result[match[1]] = match[2]
    }
    return result
  }

  FileView {
    id: file
    path: root.path
    blockLoading: true
    printErrors: false
  }
}
