pragma Singleton
import QtQuick
import Quickshell.Services.UPower

QtObject {
  property bool onBattery: false
  property QtObject displayDevice: QtObject {
    property bool isPresent: true
    property real percentage: 0.8
    property int state: UPowerDeviceState.Discharging
  }
}
