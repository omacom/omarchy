import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui
import "Services"

// A placement owns only UI. Its service and durable state belong to runtime.
QtObject {
  id: root
  required property var runtime
  required property var allocation
  property bool legacy: false
  readonly property var placement: allocation.bar
  readonly property var screen: legacy ? (Quickshell.screens[0] || null)
    : Quickshell.screens.find(screen => screen.name === "ward-" + allocation.output) || null
  readonly property var item: widgetLoader.item
  readonly property bool opened: item && item.opened === true
  onOpenedChanged: if (opened) runtime.claimView(root)
  readonly property int widgetWidth: item && item.visible ? Math.max(0, Math.min(1024, Math.ceil(item.implicitWidth))) : 0
  readonly property int widgetHeight: item && item.visible ? Math.max(0, Math.min(1024, Math.ceil(item.implicitHeight))) : 0
  readonly property string widgetSize: widgetWidth + ":" + widgetHeight
  property string sentWidgetSize: ""
  onWidgetSizeChanged: widgetSizeTimer.restart()

  function syncSettings() {
    if (item) item.settings = JSON.parse(JSON.stringify(runtime.context.settings))
  }
  function close() { if (item && typeof item.close === "function") item.close() }
  function reportWidgetSize() {
    if (!item || widgetSizeProcess.running || sentWidgetSize === widgetSize) return
    sentWidgetSize = widgetSize
    widgetSizeProcess.command = legacy
      ? ["/bootstrap", "--widget-size", String(widgetWidth), String(widgetHeight)]
      : ["/bootstrap", "--widget-size", String(allocation.id), String(widgetWidth), String(widgetHeight)]
    widgetSizeProcess.running = true
  }
  property Timer sizeTimer: Timer { id: widgetSizeTimer; interval: 100; onTriggered: root.reportWidgetSize() }
  property Process sizeProcess: Process {
    id: widgetSizeProcess
    onExited: function(code) {
      if (code !== 0) root.sentWidgetSize = ""
      widgetSizeTimer.restart()
    }
  }

  property PluginShellApi shell: PluginShellApi {
    readonly property var desktopGeometry: root.runtime.api.desktopGeometry
    pluginId: root.runtime.api.pluginId
    _serviceLookup: id => root.runtime.api.serviceFor(id)
    _summon: (id, payload) => {
      if (id !== pluginId) return false
      root.runtime.claimView(root)
      return root.runtime.api._summon(id, payload)
    }
    _hide: id => root.runtime.api._hide(id)
    _toggle: (id, payload) => root.opened ? _hide(id) : _summon(id, payload)
    _isOpen: id => id === pluginId && root.opened
    _updateSettings: (id, settings) => root.runtime.api._updateSettings(id, settings)
  }
  property PluginBarApi api: PluginBarApi {
    id: barApi
    pluginId: root.runtime.api.pluginId
    moduleName: pluginId
    shell: root.shell
    foreground: Color.bar.text
    barForeground: Color.bar.text
    background: Color.bar.background
    urgent: Color.urgent
    fontFamily: Style.font.family
    position: root.placement ? root.placement.position : "top"
    vertical: position === "left" || position === "right"
    barSize: root.placement ? root.placement.size : Style.bar.sizeHorizontal
    _showTooltip: (target, text) => tooltip.showFor(target, text)
    _hideTooltip: target => { if (tooltip.target === target) tooltip.clear() }
    _registerClickTarget: target => { clickTargets = clickTargets.concat([target]) }
    _unregisterClickTarget: target => { clickTargets = clickTargets.filter(value => value !== target) }
    _requestPopout: owner => { root.runtime.claimView(root); activePopout = owner }
    _releasePopout: owner => { if (activePopout === owner) activePopout = null }
    _switchPanelFrom: (owner, direction) => root.runtime.switchPanel(direction)
    _targetBelongsToWindow: (target, window) => target.QsWindow.window === window
    _moduleWidgets: id => id === pluginId && root.item ? [root.item] : []
    _setCenterHoverRevealSuppressed: value => { _centerHoverRevealSuppressed = value }
  }

  property PanelWindow window: PanelWindow {
    id: privateBar
    screen: root.screen
    visible: root.screen !== null && !!root.runtime.manifest.entryPoints.barWidget
    anchors {
      top: barApi.position === "top" || barApi.vertical
      bottom: barApi.position === "bottom" || barApi.vertical
      left: barApi.position === "left" || !barApi.vertical
      right: barApi.position === "right" || !barApi.vertical
    }
    implicitWidth: barApi.vertical ? barApi.barSize : 0
    implicitHeight: barApi.vertical ? 0 : barApi.barSize
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "omarchy-private-bar-" + root.allocation.id
    mask: Region { item: !root.placement || root.placement.visible ? widgetLoader : null }

    Loader {
      id: widgetLoader
      x: root.placement ? root.placement.x : root.runtime.section === "left" ? Style.gapsOut
        : root.runtime.section === "right" ? parent.width - width - Style.gapsOut : (parent.width - width) / 2
      y: root.placement ? root.placement.y : (parent.height - height) / 2
      width: root.placement ? root.placement.width : root.widgetWidth
      height: root.placement ? root.placement.height : root.widgetHeight
      opacity: !root.placement || root.placement.visible ? 1 : 0
      clip: true
      onLoaded: {
        root.runtime.inject(item)
        if ("shell" in item) item.shell = root.shell
        widgetSizeTimer.restart()
        Qt.callLater(root.runtime.applyPanel)
      }
      onStatusChanged: root.runtime.checkLoader(this)
      Component.onCompleted: if (root.runtime.manifest.entryPoints.barWidget) setSource(root.runtime.entryUrl(root.runtime.manifest.entryPoints.barWidget), {
        bar: barApi, settings: JSON.parse(JSON.stringify(root.runtime.context.settings))
      })
    }
    BarToolTip {
      id: tooltip
      ownerWindow: privateBar
      position: barApi.position
      readonly property bool hovered: target !== null && target.visible !== false
        && target.opacity !== 0 && target.tooltipHovered === true && (!root.placement || root.placement.visible)
      property bool shown: false
      visible: shown && hovered && text !== ""
      onHoveredChanged: if (!hovered) clear()
      function clear() { tooltipTimer.stop(); shown = false; target = null; text = "" }
      function showFor(item, value) {
        clear()
        if (!item || item.QsWindow.window !== privateBar || !value) return
        target = item
        text = value
        Qt.callLater(function() { if (tooltip.target === item && tooltip.hovered) tooltipTimer.restart() })
      }
    }
  }
  property Timer tooltipDelay: Timer { id: tooltipTimer; interval: 400; onTriggered: tooltip.shown = tooltip.hovered }
}
