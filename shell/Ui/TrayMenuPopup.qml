import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Commons
import qs.Commons as Commons

PopupCard {
  id: root

  property var trayItem: null
  property color foreground: bar ? bar.foreground : Commons.Color.foreground
  property string fontFamily: bar ? bar.fontFamily : Style.font.family

  // Submenu drill-down state. QsMenuEntry.display() renders a *platform* menu,
  // which Quickshell refuses unless the shell root sets `//@ pragma
  // UseQApplication` - omarchy's shell.qml does not, so every submenu click was
  // a silent no-op ("Cannot display PlatformMenuEntry as quickshell was not
  // started in QApplication mode" in the shell log) and apps whose whole UI is
  // submenus, e.g. radiotray-ng's station list, were unusable. QsMenuEntry
  // inherits QsMenuHandle, so a child entry can feed a nested QsMenuOpener and
  // render inside this popup instead of going through the platform. Each level
  // keeps its own live opener: a child entry is owned by its parent opener's
  // model, so collapsing the stack to a single opener would destroy the very
  // entry being displayed (submenu turns up empty).
  property var submenuStack: []
  readonly property int submenuDepth: submenuStack.length
  readonly property string currentTitle: submenuDepth > 0 ? submenuStack[submenuDepth - 1].title : ""
  readonly property var currentChildren: submenuDepth > 0
    ? submenuStack[submenuDepth - 1].opener.children
    : trayMenuOpener.children

  // Changing level rebuilds the row delegates synchronously, so the next
  // row lands under a cursor that hasn't moved. Submenu clicks used to be
  // silent no-ops, which trained users to click them twice, and that second
  // click would now fire whatever entry took the spot. Ignore row clicks for
  // a beat after each level change; a deliberate follow-up click is slower.
  property bool menuLevelSettling: false

  // Column skips invisible children but keeps reporting their height, so
  // read the header's extent through its own visibility.
  readonly property int menuHeaderHeight: menuHeader.visible ? menuHeader.implicitHeight : 0

  // The card fades out over 120ms (visible stays true for that whole time --
  // see PopupCard's own visible: open || card.opacity > 0), so resetting on
  // "open" would swap a live submenu for the root menu mid-fade: a visible
  // flash, and a resize/reposition if the two have different geometry. Wait
  // for the fade to actually finish. Switching to a different tray item
  // still resets immediately, from openFor() itself.
  onVisibleChanged: if (!visible) root.resetMenu()
  onTrayItemChanged: if (!trayItem && open) root.close()

  padding: Style.space(8)
  borderColor: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.45)
  contentWidth: root.fittedContentWidth(Style.space(232))
  contentHeight: root.fittedContentHeight(menuHeaderHeight + trayMenuColumn.implicitHeight, Style.space(420))

  function settleMenuLevel() {
    menuLevelSettling = true
    menuLevelSettleTimer.restart()
  }

  function resetMenu() {
    menuLevelSettling = false
    menuLevelSettleTimer.stop()
    // Flickable keeps its offset across a model swap whenever the new content
    // is still tall enough to hold it, so a menu dismissed while scrolled
    // would otherwise reopen part-way down with its first entries off screen.
    trayMenuFlick.contentY = 0
    // Clear the reactive stack before tearing anything down, so no binding can
    // read a partially-destroyed opener while this runs. Then destroy deepest
    // first: an inner opener's menu entry is owned by its parent's children
    // model, so destroying a parent first would invalidate an entry a still-
    // live child opener references.
    var openers = submenuStack
    submenuStack = []
    for (var i = openers.length - 1; i >= 0; i--) openers[i].opener.destroy()
  }

  function enterSubmenu(entry, title) {
    var opener = submenuOpenerComponent.createObject(menuState, { menu: entry })
    if (!opener) return
    var stack = submenuStack.slice()
    stack.push({ opener: opener, title: title })
    submenuStack = stack
    settleMenuLevel()
  }

  function leaveSubmenu() {
    if (submenuStack.length === 0) return
    var stack = submenuStack.slice()
    var top = stack.pop()
    submenuStack = stack
    top.opener.destroy()
    settleMenuLevel()
  }

  function openFor(item, anchor, mouse) {
    if (!item) return false
    var target = anchor || root.anchorItem
    if (!item.menu) {
      if (!target || !target.QsWindow || !target.QsWindow.window) return false
      var mx = mouse && mouse.x !== undefined ? mouse.x : target.width / 2
      var my = mouse && mouse.y !== undefined ? mouse.y : target.height / 2
      var point = target.QsWindow.contentItem.mapFromItem(target, mx, my)
      item.display(target.QsWindow.window, point.x, point.y)
      return true
    }

    // Reset before switching items: trayMenuOpener.menu binds to
    // trayItem.menu, so assigning a new item invalidates the old root's
    // children immediately, before any nested opener referencing them would
    // otherwise get torn down.
    resetMenu()
    trayItem = item
    open = true
    return true
  }

  Item {
    id: menuState
    anchors.fill: parent

    Component {
      id: submenuOpenerComponent
      QsMenuOpener {}
    }

    Timer {
      id: menuLevelSettleTimer
      interval: 250
      onTriggered: root.menuLevelSettling = false
    }

    QsMenuOpener {
      id: trayMenuOpener
      menu: root.trayItem ? root.trayItem.menu : null
    }

    Column {
      id: trayMenuLayout
      anchors.fill: parent
      spacing: 0

      // Header for a drilled-into submenu: names where we are and walks back
      // out. Pinned above the Flickable rather than scrolling with the rows,
      // so the way back stays reachable in a submenu taller than the card.
      // Only present below the root level, so the root menu is unchanged.
      Column {
        id: menuHeader
        visible: root.submenuDepth > 0
        width: trayMenuLayout.width
        spacing: 0

        Item {
          id: menuBackRow
          width: menuHeader.width
          implicitHeight: Style.space(30)

          Rectangle {
            anchors.fill: parent
            radius: Math.max(2, Style.cornerRadius)
            color: backMouse.containsMouse ? Style.hoverFillFor(root.foreground, root.foreground) : "transparent"
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            width: Style.space(22)
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.PlainText
            // Back points against the reading direction.
            text: Commons.I18n.rightToLeft ? "\u203a" : "\u2039"
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
          }

          Text {
            textFormat: Text.PlainText
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Style.space(28)
            anchors.right: parent.right
            anchors.rightMargin: Style.space(10)
            text: root.currentTitle
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
            elide: Text.ElideRight
          }

          MouseArea {
            id: backMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (root.menuLevelSettling) return
              // Reset before the model swap so the parent level shows from
              // the top (same ordering as the row delegate below).
              trayMenuFlick.contentY = 0
              root.leaveSubmenu()
            }
          }
        }

        Item {
          width: menuHeader.width
          implicitHeight: Style.space(11)

          Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: Style.space(10)
            anchors.right: parent.right
            anchors.rightMargin: Style.space(10)
            anchors.verticalCenter: parent.verticalCenter
            height: 1
            color: Commons.Color.popups.border
            opacity: 0.45
          }
        }
      }

      Flickable {
        id: trayMenuFlick
        width: trayMenuLayout.width
        height: trayMenuLayout.height - root.menuHeaderHeight
        contentWidth: width
        contentHeight: trayMenuColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        interactive: contentHeight > height

        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Column {
          id: trayMenuColumn
          width: trayMenuFlick.width
          spacing: 0

          Repeater {
            model: root.currentChildren

            delegate: Item {
              id: menuRow
              required property var modelData
              required property int index

              readonly property string rowText: String(modelData.text || "")
              readonly property string activeTitle: root.trayItem ? String(root.trayItem.title || root.trayItem.id || "") : ""
              // Both only ever describe the root menu; inside a submenu the first
              // rows are real entries and must not be swallowed.
              readonly property bool atRoot: root.submenuDepth === 0
              readonly property bool rootTitleEntry: atRoot && index === 0 && modelData.hasChildren && rowText.toLowerCase() === activeTitle.toLowerCase()
              readonly property bool leadingSeparator: atRoot && modelData.isSeparator && index <= 1
              readonly property bool hiddenRow: rootTitleEntry || leadingSeparator

              visible: !hiddenRow
              width: trayMenuColumn.width
              implicitHeight: hiddenRow ? 0 : (modelData.isSeparator ? Style.space(11) : Style.space(30))
              opacity: modelData.enabled ? 1.0 : 0.45

              Rectangle {
                visible: menuRow.modelData.isSeparator
                anchors.left: parent.left
                anchors.leftMargin: Style.space(10)
                anchors.right: parent.right
                anchors.rightMargin: Style.space(10)
                anchors.verticalCenter: parent.verticalCenter
                height: 1
                color: Commons.Color.popups.border
                opacity: 0.45
              }

              Rectangle {
                visible: !menuRow.modelData.isSeparator
                anchors.fill: parent
                radius: Math.max(2, Style.cornerRadius)
                color: rowMouse.containsMouse && menuRow.modelData.enabled ? Style.hoverFillFor(root.foreground, root.foreground) : "transparent"
              }

              Text {
                textFormat: Text.PlainText
                visible: !menuRow.modelData.isSeparator && menuRow.modelData.buttonType !== QsMenuButtonType.None
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                width: Style.space(22)
                horizontalAlignment: Text.AlignHCenter
                text: menuRow.modelData.checkState === Qt.Checked ? "\uf00c" : ""
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.bodySmall
              }

              Image {
                id: menuIcon
                visible: !menuRow.modelData.isSeparator && String(menuRow.modelData.icon || "") !== ""
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Style.space(24)
                width: Style.space(16)
                height: Style.space(16)
                fillMode: Image.PreserveAspectFit
                // Decode at physical pixels: IconImage uses the logical size,
                // which leaves PNG icons upscaled and blurry on HiDPI displays.
                sourceSize.width: width * Screen.devicePixelRatio
                sourceSize.height: height * Screen.devicePixelRatio
                source: menuRow.modelData.icon
              }

              Text {
                textFormat: Text.PlainText
                visible: !menuRow.modelData.isSeparator
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: menuIcon.visible ? Style.space(46) : Style.space(28)
                anchors.right: submenuGlyph.left
                anchors.rightMargin: Style.space(8)
                text: menuRow.rowText
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.bodySmall
                elide: Text.ElideRight
              }

              Text {
                id: submenuGlyph
                visible: !menuRow.modelData.isSeparator && menuRow.modelData.hasChildren
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Style.space(10)
                textFormat: Text.PlainText
                text: Commons.I18n.rightToLeft ? "\u2039" : "\u203a"
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.bodySmall
              }

              MouseArea {
                id: rowMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: !menuRow.modelData.isSeparator && menuRow.modelData.enabled
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                  if (root.menuLevelSettling) return
                  if (menuRow.modelData.hasChildren) {
                    // Reset scroll BEFORE swapping the model: the swap destroys
                    // this delegate synchronously and ids stop resolving after.
                    trayMenuFlick.contentY = 0
                    root.enterSubmenu(menuRow.modelData, menuRow.rowText)
                  } else {
                    menuRow.modelData.triggered()
                    root.close()
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
