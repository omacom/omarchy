import QtQuick

Item {
  objectName: "injection"
  property var shell: null
  property var manifest: null

  onManifestChanged: if (manifest && shell) shell.serviceInjected()
  Component.onDestruction: parent.serviceDestroyed(objectName)
}
