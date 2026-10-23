import QtQuick

// An Item standing in for the layer-shell window, so the dialog's content is
// laid out and takes keys inside the test window.
Item {
  property Item contentItem: this
  property color color
  width: 800
  height: 600
}
