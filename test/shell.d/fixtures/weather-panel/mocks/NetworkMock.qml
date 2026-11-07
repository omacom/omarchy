pragma Singleton
import QtQuick
import Quickshell.Networking

QtObject {
  property int connectivity: NetworkConnectivity.None
}
