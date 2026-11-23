import QtQuick

// Stands in for the SDDM greeter: the theme reads userModel, sessionModel and
// sddm from the context it is loaded in.
Item {
  id: greeter
  width: 640
  height: 480

  property string lastUser: ""
  property var users: []
  property var logins: []
  property alias theme: loader.item

  property QtObject userModel: QtObject {
    property string lastUser: greeter.lastUser
    function rowCount() { return greeter.users.length }
    function index(row, column) { return row }
    function data(index, role) { return role === Qt.UserRole + 1 ? greeter.users[index] : undefined }
  }

  property QtObject sessionModel: QtObject {
    property int lastIndex: 0
    function rowCount() { return 0 }
  }

  property QtObject sddm: QtObject {
    signal loginFailed()
    signal loginSucceeded()
    function login(user, password, session) { greeter.logins = greeter.logins.concat([user]) }
  }

  Loader {
    id: loader
    anchors.fill: parent
    source: Qt.resolvedUrl("../../../../default/sddm/omarchy/Main.qml")
  }
}
