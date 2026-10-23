import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

ShellRoot {
  id: root

  property bool opened: false
  property bool closing: false
  property bool fading: false
  property bool anchorLost: false
  property bool anchorReturned: false
  property bool hiddenWhileClosing: false
  property bool reshown: false

  function finish(result, message) {
    console.log("RESULT " + result + " " + message)
    Qt.quit()
  }

  QtObject {
    id: fakeBar
    property string position: "top"
    property var activePopout: null
    function requestPopout(key) { activePopout = key }
    function releasePopout(key) { activePopout = null }
  }

  PanelWindow {
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 30
    color: "transparent"

    Item {
      id: fallback
    }

    Loader {
      id: anchorLoader
      sourceComponent: Item {
        width: 30
        height: 30
      }
    }
  }

  PopupCard {
    id: card
    anchorItem: anchorLoader.item || fallback
    bar: fakeBar

    onAnchorWindowChanged: {
      if (!root.closing) return
      if (!anchorWindow) root.anchorLost = true
      else if (root.anchorLost) root.anchorReturned = true
    }

    onVisibleChanged: {
      if (!root.closing) return
      if (!visible) root.hiddenWhileClosing = true
      else if (root.hiddenWhileClosing) root.reshown = true
    }
  }

  Timer {
    interval: 500
    running: true
    onTriggered: {
      card.open = true
      closeTimer.start()
    }
  }

  // Close the card, then take its anchor out of the window mid-fade, the way a tray
  // icon leaves the bar when its app quits from its own menu.
  Timer {
    id: closeTimer
    interval: 500
    onTriggered: {
      root.opened = card.visible
      root.closing = true
      card.open = false
      root.fading = card.visible
      anchorLoader.item.parent = null
      anchorLoader.active = false
      checkTimer.start()
    }
  }

  Timer {
    id: checkTimer
    interval: 1000
    onTriggered: {
      if (!root.opened) root.finish("fail", "the card did not open")
      else if (Style.reduceMotion) root.finish("skip", "animations are off, so there is no fade to interrupt")
      else if (!root.fading) root.finish("fail", "the card did not fade out")
      else if (!root.anchorLost || !root.anchorReturned) root.finish("fail", "the anchor window did not leave and come back")
      else if (root.reshown || card.visible) root.finish("fail", "the closing card was shown again after its anchor left the window")
      else root.finish("pass", "the closing card stayed hidden after its anchor left the window")
    }
  }
}
