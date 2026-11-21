import QtQuick

// The test plays polkit: it sets isActive and flow, then emits
// authenticationRequestStarted, as the real agent does when a request arrives.
QtObject {
  property string path
  property bool isActive: false
  property bool isRegistered: true
  property var flow: null
  signal authenticationRequestStarted()
  Component.onCompleted: PolkitHarness.agent = this
}
