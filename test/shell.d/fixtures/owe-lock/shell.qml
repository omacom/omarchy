import QtQuick
import Quickshell

ShellRoot {
  id: root
  property var view
  property var wallpaper
  property var feed
  property int step: 0

  Item { id: host; width: 1000; height: 700 }

  function findItem(item, name) {
    if (item.objectName === name) return item
    for (var i = 0; i < item.children.length; i++) {
      var found = findItem(item.children[i], name)
      if (found) return found
    }
    return null
  }

  function check(condition, message) {
    if (!condition) throw new Error(message)
  }

  Timer {
    interval: 150
    repeat: true
    running: true
    onTriggered: {
      try {
        if (root.step === 0) {
          var component = Qt.createComponent("file://" + Quickshell.env("OMARCHY_PATH") + "/shell/plugins/lock/LockView.qml")
          check(component.status === Component.Ready, component.errorString())
          root.view = component.createObject(host, {width: 1000, height: 700, backgroundPath: "/still.png", loadBackground: false})
          check(root.view !== null, component.errorString())
          root.wallpaper = findItem(root.view, "lockWallpaper")
          root.feed = findItem(root.view, "lockFeedLoader")
          check(root.wallpaper.path === "", "hidden still must not decode")
          root.view.backgroundPath = "/video.mp4"
          root.view.videoPosterPath = "/poster.jpg"
        } else if (root.step === 1) {
          check(!root.feed.active && root.feed.item === null, "hidden video must not load a feed client")
          root.view.loadBackground = true
          root.view.powerSaverActive = true
        } else if (root.step === 2) {
          check(root.wallpaper.path === "/poster.jpg", "power saver keeps the video poster")
          check(!root.feed.active, "power saver must not connect to the feed")
          root.view.powerSaverActive = false
        } else if (root.step === 3) {
          check(root.feed.active, "visible video enables the isolated feed loader")
          check(root.wallpaper.path === "/poster.jpg", "poster stays beneath the feed before its first frame")
          root.view.displaysBlank = true
        } else if (root.step === 4) {
          check(!root.feed.active && root.feed.item === null, "blanking releases the feed client")
          root.view.loadBackground = false
        } else {
          check(root.wallpaper.path === "", "unlock releases the poster image")
          console.log("OWE_LOCK_TEST_PASS")
          Qt.quit()
        }
        root.step++
      } catch (error) {
        console.error("OWE_LOCK_TEST_FAIL: " + error)
        Qt.quit()
      }
    }
  }
}
