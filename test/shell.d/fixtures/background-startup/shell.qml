import QtQuick
import Quickshell
import "services"

ShellRoot {
  id: test
  property var services: ({})
  property var pluginRegistry: null
  property bool failed: false
  function firstPartyServiceFor(id) { return services[id] || null }
  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  QtObject {
    id: registry
    property var installedPlugins: ({ "omarchy.background": {} })
    signal pluginsChanged()
    function resolveEnabledId(id) { return id }
    function isEnabled(id) { return false }
  }
  QtObject {
    id: background
    property bool suspended: false
    property bool ready: false
  }
  BackgroundIntro { id: intro; host: test }

  Timer {
    interval: 400
    running: true
    onTriggered: {
      test.check(!intro.backgroundActive, "the plugin has not loaded yet")
      test.check(intro.cover && intro.themeCoverStatus("") === "ready", "the startup wallpaper has already decoded and reached the compositor")
      test.check(intro.startupSettled, "the launcher has finished without an intro")
      test.services = ({ "omarchy.background": background })
    }
  }
  Timer {
    interval: 600
    running: true
    onTriggered: {
      test.check(intro.cover, "a loading plugin does not release the startup wallpaper")
      background.ready = true
    }
  }
  Timer {
    interval: 800
    running: true
    onTriggered: {
      test.check(!intro.cover && !intro.themeBackground, "a ready plugin releases the startup cover and its image")
      test.services = ({})
      intro.cover = true
      test.pluginRegistry = registry
      registry.pluginsChanged()
      test.check(!intro.cover, "a disabled background plugin does not leave a startup cover on screen")
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    }
  }
}
