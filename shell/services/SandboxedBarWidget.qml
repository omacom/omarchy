import QtQuick
import Quickshell

// Host-owned layout spacer. No plugin source or worker QObject enters the bar.
Item {
  id: root
  required property var manager
  property var bar: null
  property string moduleName: ""
  property var settings: ({})
  readonly property var instance: manager.instances[moduleName] || null
  readonly property var window: QsWindow.window
  property int viewId: 0
  property var registeredInstance: null
  readonly property bool hosted: instance && window && instance.outputFor(window.screen) !== null
  readonly property bool opened: instance && instance.opened && instance.activeViewId === viewId
  function open() { return manager.show(moduleName, "", root) }
  function close() { return manager.hide(moduleName) }
  function closeForPopoutSwitch() { close() }
  implicitWidth: hosted && viewId ? instance.widgetSize(viewId).width : 0
  implicitHeight: hosted && viewId ? instance.widgetSize(viewId).height : 0

  TransformWatcher {
    id: positionWatcher
    a: root.window ? root.window.contentItem : null
    b: root
  }
  readonly property var placement: {
    positionWatcher.transform
    if (!hosted || !bar) return null
    const local = mapToItem(window.contentItem, 0, 0)
    const screen = window.screen
    const margins = "margins" in window ? window.margins : null
    // Layer-shell does not expose global window positions. Derive the host
    // window origin from its allocation, then map into the private edge bar.
    const anchors = window.anchors
    const left = margins ? margins.left : 0, right = margins ? margins.right : 0
    const top = margins ? margins.top : 0, bottom = margins ? margins.bottom : 0
    const x = local.x + (anchors.left ? left : anchors.right ? screen.width - window.width - right : (screen.width - window.width + left - right) / 2)
    const y = local.y + (anchors.top ? top : anchors.bottom ? screen.height - window.height - bottom : (screen.height - window.height + top - bottom) / 2)
    const parked = margins && ((bar.position === "top" && margins.top <= -bar.barSize)
      || (bar.position === "bottom" && margins.bottom <= -bar.barSize)
      || (bar.position === "left" && margins.left <= -bar.barSize)
      || (bar.position === "right" && margins.right <= -bar.barSize))
    return {
      x: x - (bar.position === "right" ? screen.width - bar.barSize : 0),
      y: y - (bar.position === "bottom" ? screen.height - bar.barSize : 0),
      width: Math.min(1024, width), height: Math.min(1024, height),
      size: bar.barSize, position: bar.position,
      visible: visible && window.visible && !parked && x + width > 0 && y + height > 0
        && x < screen.width && y < screen.height
    }
  }
  onPlacementChanged: Qt.callLater(publish)
  function publish() {
    if (registeredInstance && registeredInstance !== instance) {
      registeredInstance.removePlacement(root)
      registeredInstance = null
      viewId = 0
    }
    if (hosted && placement) {
      viewId = instance.updatePlacement(root, window.screen, placement)
      registeredInstance = instance
    }
  }
  onInstanceChanged: Qt.callLater(publish)
  onHostedChanged: Qt.callLater(publish)
  Component.onCompleted: Qt.callLater(publish)
  Component.onDestruction: {
    if (registeredInstance) registeredInstance.removePlacement(root)
  }
}
