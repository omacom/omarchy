# Omarchy App Layout Patterns

Read this before laying out a window with more than one thing in it. The window below is a two-pane app (a list on the left, the selected item on the right), with a second mode, a dialog that asks for a name, an empty state, and keyboard control. It builds from the scaffold, passes qmllint, and renders as intended; copy the parts you need and rename them for the app. Its data is a `ListModel` so it stands alone; in an app, the list's `model` is a property on `backend`.

The traps it avoids, each of which has cost an agent an hour:

- **Inside a `RowLayout` or `ColumnLayout`, size children only with `Layout.*`** (`Layout.fillWidth`, `Layout.preferredWidth`, `Layout.fillHeight`). `width`, `height`, and `anchors` on a layout's child fight the layout, and panes end up off screen or at zero size.
- **`StackLayout` ignores `Layout.margins` on its pages.** Make each page a plain `Item` and pad what's inside it with `anchors.margins`.
- **Text wraps only inside a width it's given**: `wrapMode: Text.Wrap` together with `Layout.fillWidth: true` or anchors on both sides. There is no `wrapText`.
- **A dialog sizes itself to its content's implicit size.** Give the content `implicitWidth`, not `width`, or it spills over the dialog's edges. Draw the dialog's `background` yourself: Material's leaves the content area see-through with a custom window color.
- **A field takes the keyboard when its dialog opens** (`onOpened: field.forceActiveFocus()`), and single-key shortcuts are disabled while it has it, or typing an N opens another dialog.
- **Show which mode the window is in by binding to one property** (`currentIndex: win.mode`), never by setting `visible` on several panes from different places.
- **An empty list shows a message**, never a blank pane.
- `padding` exists on controls (`Label`, `Popup`, `Control`), not on `Rectangle` or `Item`.
- **A `highlighted` button's label can't be read on every accent** in Material's own color: give it a `contentItem` `Label` in `theme.accentForeground`, as the starter's Count button does.

Check a layout by looking at it in each of its modes: `omarchy agent look app -- ./build/<name>` shows the window as it opens, and `--keys "Down Return"` presses keys through the window's `Shortcut`s first.

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

ApplicationWindow {
    id: win
    width: 960
    height: 680
    minimumWidth: 640
    minimumHeight: 460
    visible: true
    title: "Marks"
    color: theme.background

    Material.theme: theme.light ? Material.Light : Material.Dark
    Material.accent: theme.accent
    Material.background: theme.background
    Material.foreground: theme.foreground

    readonly property bool rightToLeft: Qt.application.layoutDirection === Qt.RightToLeft
    // Which pane fills the right side: 0 shows the selected item, 1 reads it
    // full screen.
    property int mode: 0

    ListModel {
        id: marks
        ListElement { title: "Omarchy manual"; note: "Everything about the desktop, from hotkeys to themes, in one long page that is worth reading once from top to bottom." }
        ListElement { title: "Hyprland wiki"; note: "Window rules, variables and dispatchers." }
        ListElement { title: "Qt Quick Layouts"; note: "RowLayout, ColumnLayout and GridLayout size their children through Layout.* attached properties." }
    }

    // Single-key shortcuts are off while a text field has the keyboard, or
    // typing an N in the dialog would open another dialog.
    readonly property bool typing: nameDialog.opened
    Shortcut { sequence: "N"; enabled: !win.typing; onActivated: nameDialog.open() }
    Shortcut { sequence: "Up"; enabled: !win.typing; onActivated: list.decrementCurrentIndex() }
    Shortcut { sequence: "Down"; enabled: !win.typing; onActivated: list.incrementCurrentIndex() }
    Shortcut { sequence: "Return"; enabled: !win.typing && list.count > 0; onActivated: win.mode = 1 }
    Shortcut { sequence: "Escape"; enabled: !win.typing; onActivated: win.mode = 0 }
    Shortcut { sequence: "Q"; enabled: !win.typing; onActivated: Qt.quit() }

    Item {
        anchors.fill: parent
        LayoutMirroring.enabled: win.rightToLeft
        LayoutMirroring.childrenInherit: true

        // Two panes side by side. Inside a layout, size children with
        // Layout.* properties only: width, height and anchors on a layout's
        // child fight the layout and push panes off screen.
        RowLayout {
            anchors.fill: parent
            spacing: 0

            // The list: a fixed width, the full height.
            Rectangle {
                Layout.preferredWidth: 300
                Layout.fillHeight: true
                color: theme.colors.lighter_background || theme.background

                ListView {
                    id: list
                    objectName: "list"
                    anchors.fill: parent
                    anchors.margins: 8
                    clip: true
                    model: marks
                    spacing: 2
                    delegate: Rectangle {
                        required property int index
                        required property string title
                        width: ListView.view.width
                        height: 44
                        radius: Math.min(4, theme.radius)
                        color: ListView.isCurrentItem ? theme.colors.selection : "transparent"

                        Label {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            verticalAlignment: Text.AlignVCenter
                            text: title
                            elide: Text.ElideRight
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: list.currentIndex = index
                            onDoubleClicked: win.mode = 1
                        }
                    }
                }

                // The empty state is a message in the pane, never a blank one.
                Label {
                    anchors.centerIn: parent
                    visible: list.count === 0
                    text: qsTr("Press N to add one")
                    color: theme.colors.muted || theme.foreground
                }
            }

            // The right side takes the rest, and shows one pane at a time.
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: win.mode

                // StackLayout ignores Layout.margins on its children: give
                // each page a plain Item and pad what's inside it. A long
                // text wraps inside the width its layout gives it.
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 32
                        spacing: 12

                        Label {
                            Layout.fillWidth: true
                            text: list.currentIndex >= 0 ? marks.get(list.currentIndex).title : ""
                            font.pixelSize: 28
                            elide: Text.ElideRight
                        }
                        Label {
                            Layout.fillWidth: true
                            text: list.currentIndex >= 0 ? marks.get(list.currentIndex).note : ""
                            wrapMode: Text.Wrap
                            color: theme.colors.dark_foreground || theme.foreground
                        }
                        Item { Layout.fillHeight: true }
                    }
                }

                // The reading mode: one thing, big and centered.
                Label {
                    objectName: "reading"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    padding: 64
                    text: list.currentIndex >= 0 ? marks.get(list.currentIndex).note : ""
                    font.pixelSize: 24
                }
            }
        }
    }

    // A dialog that asks for a name: the field takes the keyboard when it
    // opens, Enter accepts, Escape cancels.
    Dialog {
        id: nameDialog
        objectName: "nameDialog"
        anchors.centerIn: Overlay.overlay
        modal: true
        title: qsTr("New mark")
        Material.roundedScale: theme.radius
        // Material's own dialog background leaves the content area see-through
        // with a custom window color; draw one, as the template's help does.
        background: Rectangle {
            color: theme.background
            border.color: theme.colors.selection
            radius: theme.radius
        }
        standardButtons: Dialog.Ok | Dialog.Cancel
        onOpened: { nameField.text = ""; nameField.forceActiveFocus() }
        onAccepted: if (nameField.text.trim() !== "") {
            marks.append({ title: nameField.text.trim(), note: "" })
            list.currentIndex = marks.count - 1
        }

        // A dialog sizes itself to its content's implicit size; a plain width
        // on the content spills over the dialog's edges.
        TextField {
            id: nameField
            implicitWidth: 320
            placeholderText: qsTr("Name")
            onAccepted: nameDialog.accept()
        }
    }
}
```
