import QtQuick
import Quickshell
import Quickshell.Io
import "services"

ShellRoot {
  id: test
  property var services: ({})
  property var pluginRegistry: null
  property var bar: null
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
  FileView { id: cursorLog; path: Quickshell.env("STARTUP_CURSOR_LOG"); printErrors: false }

  Timer {
    interval: 400
    running: true
    onTriggered: {
      test.check(!intro.backgroundActive, "the plugin has not loaded yet")
      test.check(intro.cover && !intro.themeBackground, "fresh startup does not prepare an outgoing still image")
      test.check(intro.startupSettled, "the launcher has finished without an intro")
      test.check(intro.startupPending && intro.startupOpacity === 1, "a fresh login hides the desktop until its media and bar are ready")
      cursorLog.reload()
      cursorLog.waitForJob()
      test.check(!cursorLog.text().trim(), "startup does not restore the cursor while media is loading")
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
      test.check(intro.startupPending && intro.startupOpacity === 1, "a ready background alone cannot reveal an unready bar")
      cursorLog.reload()
      cursorLog.waitForJob()
      test.check(!cursorLog.text().trim(), "startup does not restore the cursor before the bar is ready")
      test.bar = ({})
    }
  }
  Timer {
    interval: 1400
    running: true
    onTriggered: {
      test.check(!intro.startupPending && intro.startupOpacity === 0, "the desktop fades in after both the media and bar are ready")
      cursorLog.reload()
      cursorLog.waitForJob()
      test.check(cursorLog.text().includes("omarchy_startup_cursor_restore()"), "the opening fade restores the cursor")
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
