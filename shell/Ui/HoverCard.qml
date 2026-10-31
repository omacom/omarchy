import QtQuick
import QtQuick.Window
import QtQuick.Templates as T
import "../Commons"
import "../Commons" as Commons

// Optional rich content; ordinary tooltip consumers never create this host.
T.Popup {
  id: root
  property bool sourceHovered: false
  property Component content: null
  property real preferredWidth: Style.space(300)
  property int delay: 400
  property int closeDelay: 180
  readonly property Item loadedContent: body.item
  readonly property bool containsMouse: hover.hovered
  property bool keyboardOpened: false
  property bool dismissed: false

  function openForKeyboard() {
    dismissed = false
    keyboardOpened = true
    showTimer.stop()
    closeTimer.stop()
    open()
  }

  function syncHover() {
    if (sourceHovered || containsMouse || (visible && activeFocus)) {
      closeTimer.stop()
      if (!visible && !dismissed && sourceHovered) showTimer.restart()
    } else {
      showTimer.stop()
      if (visible) closeTimer.restart()
    }
  }

  onSourceHoveredChanged: {
    if (!sourceHovered) dismissed = false
    syncHover()
  }
  onContainsMouseChanged: syncHover()
  onActiveFocusChanged: syncHover()
  x: parent ? Math.round((parent.width - width) / 2) : 0
  y: parent ? parent.height + margins : 0
  margins: Style.spacing.sm
  padding: Style.spacing.controlPaddingX
  leftPadding: padding + Border.left(card.borderSpec)
  rightPadding: padding + Border.right(card.borderSpec)
  topPadding: padding + Border.top(card.borderSpec)
  bottomPadding: padding + Border.bottom(card.borderSpec)
  implicitWidth: Math.min(preferredWidth, parent && parent.Window.window ? Math.max(1, parent.Window.window.width - margins * 2) : preferredWidth)
  implicitHeight: body.implicitHeight + topPadding + bottomPadding
  focus: keyboardOpened
  modal: false
  closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent

  background: BorderSurface {
    id: card
    color: Commons.Color.tooltip.background
    borderSpec: ToolTipStyle.borderSpec(Border.surfaceSpec("tooltip", "border", Commons.Color.tooltip.border, Style.normalBorderWidth))
    radius: ToolTipStyle.radius(Style.cornerRadius)
  }
  contentItem: Loader {
    id: body
    active: root.visible
    sourceComponent: root.content
    Accessible.role: Accessible.Dialog
    onLoaded: if (root.keyboardOpened && item) item.forceActiveFocus()
    HoverHandler { id: hover }
    Keys.onEscapePressed: root.close()
  }
  onOpened: if (keyboardOpened && body.item) body.item.forceActiveFocus()
  onAboutToHide: {
    dismissed = sourceHovered
    showTimer.stop()
    closeTimer.stop()
  }
  onClosed: {
    // Popup restores keyboard focus itself and preserves a new outside target.
    keyboardOpened = false
  }
  Timer { id: showTimer; interval: root.delay; onTriggered: if (root.sourceHovered && !root.dismissed) root.open() }
  Timer { id: closeTimer; interval: root.closeDelay; onTriggered: root.close() }
  enter: Transition {
    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Style.duration(120) }
  }
  exit: Transition {
    NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Style.duration(80) }
  }
}
