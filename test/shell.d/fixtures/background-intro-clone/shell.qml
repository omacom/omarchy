import QtQuick
import Quickshell
import Quickshell.Io
import "services"
import "clone" as Clone

ShellRoot {
  id: test
  property var services: ({ "intro-test.background": background })
  function firstPartyServiceFor(id) { return id === "omarchy.background" ? background : null }

  PluginShellApi { id: facade; pluginId: "intro-test.background" }
  Clone.Background { id: background; shell: facade }
  BackgroundIntro { id: intro; host: test }
  FileView { id: result; path: Quickshell.env("INTRO_TEST_RESULT"); atomicWrites: true }

  Timer {
    interval: 600
    running: true
    onTriggered: result.setText(JSON.stringify({
      phase: "cover",
      scoped: background.shell.pluginId === "intro-test.background",
      privateCoordinator: background.shell.bootIntro === undefined,
      selected: background.displayedBackground.endsWith("still.png"),
      covered: intro.cover
    }))
  }
  Timer {
    interval: 2200
    running: true
    onTriggered: {
      intro.cover = false
      result.setText(JSON.stringify({ phase: "still", covered: intro.cover }))
    }
  }
  Timer { interval: 4000; running: true; onTriggered: Qt.quit() }
}
