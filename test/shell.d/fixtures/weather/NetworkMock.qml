pragma Singleton
import QtQuick
QtObject {
  property var devices: ({ values: [wifi] })
  property QtObject wifi: QtObject {
    property string name: "test-wifi"
    property bool connected: true
    property var networks: ({ values: [network] })
  }
  property QtObject network: QtObject {
    property string name: "First Wi-Fi"
    property bool connected: true
  }
}
