import QtQuick
import Quickshell.Io
import Omarchy.Ttfx as Ttfx

// The Omarchy wordmark played by TTFX (native/ttfx-qml), which Logo.qml loads
// in place of its shape when the optional Omarchy.Ttfx module is installed:
// looping while the splash waits and asks for the password, then once to its
// end after Enter, a little faster, where it holds the whole logo.
//
// The effect and seed come from an optional file of `effect=` and `seed=`
// lines: the boot image's copy of /etc/omarchy/boot-splash-ttfx.conf
// (etc/initcpio/install/omarchy-splash), or the file itself at the login
// screen. Without one, Decrypt with the Plymouth renderer's seed (#18522).
Ttfx.TtfxLogo {
  id: root

  // The Logo.qml that loaded this one.
  property Item host

  readonly property var settings: {
    const result = { effect: "decrypt", seed: "" }
    const text = imageSettings.loaded ? imageSettings.text() : systemSettings.text()
    for (const line of text.split("\n")) {
      const effect = /^effect=([a-z][a-z0-9-]{0,63})$/.exec(line.trim())
      if (effect) result.effect = effect[1]
      const seed = /^seed=(0|[1-9][0-9]{0,19})$/.exec(line.trim())
      if (seed) result.seed = seed[1]
    }
    return result
  }

  effect: settings.effect
  seed: settings.seed
  color: host ? host.color : "white"
  background: host ? host.background : "black"
  mode: host && host.phase === "progress" ? Ttfx.TtfxLogo.OneTime : Ttfx.TtfxLogo.Loop
  stepsPerTick: host && host.phase === "progress" ? 4 : 2

  FileView {
    id: imageSettings
    path: "/usr/lib/omarchy-splash/ttfx.conf"
    blockLoading: true
    printErrors: false
  }

  FileView {
    id: systemSettings
    path: "/etc/omarchy/boot-splash-ttfx.conf"
    blockLoading: true
    printErrors: false
  }
}
