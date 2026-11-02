import QtQuick

QtObject {
  property string path
  property bool watchChanges
  property bool printErrors
  signal loaded()
  signal loadFailed()
  signal fileChanged()
  function text() { return "" }
  function reload() {}
}
