import QtQuick

Item {
  objectName: "constructor"
  property var shell: null
  property var manifest: null

  Component.onCompleted: parent.serviceConstructed()
  Component.onDestruction: parent.serviceDestroyed(objectName)
}
