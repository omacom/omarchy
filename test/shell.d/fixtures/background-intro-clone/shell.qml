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
  property bool stillReported: false
  FileView { id: release; path: Quickshell.env("INTRO_TEST_RELEASE"); watchChanges: true; onFileChanged: reload() }
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
    interval: 100
    running: true
    repeat: true
    onTriggered: {
      if (release.text().trim() === "done") {
        Qt.quit()
      } else if (release.text().trim() === "captured" && !intro.cover && !intro.startupPending && !test.stillReported) {
        test.stillReported = true
        result.setText(JSON.stringify({ phase: "still", covered: intro.cover }))
      }
    }
  }
}
