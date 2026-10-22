import QtQuick

// Register the lifetime and visibility of one monitor's widget. Do not expose
// the authentication service as a property on this host-parented object.
QtObject {
  id: root
  property bool opened: false
  property var settings: ({})
  Component.onCompleted: SharedService.attach(root)
  Component.onDestruction: SharedService.detach(root)
}
