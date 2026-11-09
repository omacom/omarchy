import QtQuick
import QtQuick.Controls
import qs.Commons
import qs.Commons as Commons

// A reusable themed context menu: a small list of actions opened from a
// right-click (or any trigger) and dismissed on selection, Escape, or a press
// outside. The surface matches the rest of the kit — Commons.Color.popups for
// the background/border/text and Style.hoverFillFor for the highlighted row —
// so a panel can drop it in without restyling.
//
// The root is a plain, zero-size Item wrapping the Popup (the Dropdown
// pattern), so a parent positions the menu by placing the item beside the row
// that opened it.
//
// `items` is an array of { key, label, danger }. `activated(key)` fires for the
// chosen row; `hovered(index)` reports the row under the keyboard or mouse
// highlight, so an owner can mirror the state elsewhere. A row flagged
// `danger` paints in the urgent color (Forget Network, say).
//
// Keyboard while open: Up/Down or k/j move the highlight, Enter/Space activate,
// Esc closes. The highlight is clamped to the ends rather than wrapping.
Item {
  id: root

  property var items: []
  property color foreground: Commons.Color.popups.text
  property color background: Commons.Color.popups.background
  property color accent: Commons.Color.accent
  property color dangerColor: Commons.Color.urgent
  property string fontFamily: Style.font.family
  property int rowHeight: Style.spacing.popupRowHeight

  // menuWidth 0 fits the widest label; a positive value pins the width. minWidth
  // is the floor for the fitted width.
  property int menuWidth: 0
  property int minWidth: Style.space(180)

  // The row the keyboard or pointer highlights, or -1 when there is none.
  property int highlightIndex: -1

  readonly property bool popupOpen: popup.opened
  readonly property var popupBorderSpec: Border.localOrSurfaceSpec("popups", "border", Commons.Color.popups.border, Commons.Color.popups.border, Style.normalBorderWidth)

  signal activated(string key)
  signal hovered(int index)

  function open() { popup.open() }
  function close() { popup.close() }
  function toggle() { popup.opened ? popup.close() : popup.open() }

  function keyAt(index) {
    if (index < 0 || index >= items.length) return ""
    var item = items[index]
    return item ? String(item.key || "") : ""
  }

  function labelAt(index) {
    if (index < 0 || index >= items.length) return ""
    var item = items[index]
    return item ? String(item.label || "") : ""
  }

  function isDanger(index) {
    if (index < 0 || index >= items.length) return false
    return !!(items[index] && items[index].danger)
  }

  function setHighlight(index) {
    var next = items.length === 0 ? -1 : Math.max(0, Math.min(items.length - 1, index))
    if (next === highlightIndex) return
    highlightIndex = next
    hovered(next)
  }

  function moveHighlight(delta) {
    if (items.length === 0) {
      highlightIndex = -1
      return
    }
    setHighlight((highlightIndex < 0 ? 0 : highlightIndex) + delta)
  }

  function activateHighlighted() {
    if (highlightIndex < 0 || highlightIndex >= items.length) return
    var key = keyAt(highlightIndex)
    close()
    activated(key)
  }

  // The key handling both the Keys handler and the fixture drive, so the test
  // exercises the same path the popup does.
  function handleKey(event) {
    if (!popup.opened || !event) return
    if (event.key === Qt.Key_Escape) {
      close(); event.accepted = true
    } else if (event.key === Qt.Key_Down || event.text === "j") {
      moveHighlight(1); event.accepted = true
    } else if (event.key === Qt.Key_Up || event.text === "k") {
      moveHighlight(-1); event.accepted = true
    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
      activateHighlighted(); event.accepted = true
    }
  }

  Popup {
    id: popup

    width: root.menuWidth > 0
      ? root.menuWidth
      : Math.max(root.minWidth, contentColumn.implicitWidth + leftPadding + rightPadding)
    height: root.items.length * root.rowHeight + Math.max(0, root.items.length - 1) * Style.spacing.labelGap + topPadding + bottomPadding

    padding: Style.spacing.hairline
    leftPadding: Border.left(root.popupBorderSpec) + Style.spacing.hairline
    rightPadding: Border.right(root.popupBorderSpec) + Style.spacing.hairline
    topPadding: Border.top(root.popupBorderSpec) + Style.spacing.hairline
    bottomPadding: Border.bottom(root.popupBorderSpec) + Style.spacing.hairline

    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: BorderSurface {
      color: root.background
      borderSpec: root.popupBorderSpec
      radius: Style.cornerRadius
    }

    onOpened: {
      root.highlightIndex = root.items.length > 0 ? 0 : -1
      contentColumn.forceActiveFocus()
    }

    contentItem: Column {
      id: contentColumn
      spacing: Style.spacing.labelGap
      focus: true

      Keys.priority: Keys.BeforeItem
      Keys.onPressed: function(event) { root.handleKey(event) }

      Repeater {
        model: root.items

        delegate: Rectangle {
          id: row
          required property var modelData
          required property int index

          readonly property bool highlighted: index === root.highlightIndex

          width: contentColumn.width
          height: root.rowHeight
          radius: Style.cornerRadius
          implicitWidth: labelText.implicitWidth + Style.spacing.controlPaddingX * 2
          color: highlighted ? Style.hoverFillFor(root.foreground, root.accent, root.dangerColor) : "transparent"

          Text {
            id: labelText
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Style.spacing.controlPaddingX
            anchors.rightMargin: Style.spacing.controlPaddingX
            text: root.labelAt(row.index)
            color: root.isDanger(row.index) ? root.dangerColor
              : row.highlighted ? Style.hoverStateColor(root.foreground, root.accent) : root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            elide: Text.ElideRight
          }

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onPositionChanged: root.setHighlight(row.index)
            onClicked: {
              root.setHighlight(row.index)
              root.activateHighlighted()
            }
          }
        }
      }
    }
  }
}
