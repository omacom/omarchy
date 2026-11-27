import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
  SocketServer {
    active: true
    path: Quickshell.env("OMARCHY_TEST_SOCKET")
    handler: Socket {
      id: connection
      parser: SplitParser {
        splitMarker: "\u001e"
        onRead: function(data) {
          console.log("delayed-ipc-request")
          reply.start()
        }
      }
      property Timer responseTimer: Timer {
        id: reply
        interval: 100
        onTriggered: {
          connection.write("OK\u001fdeferred\u001e")
          connection.flush()
          connection.connected = false
        }
      }
    }
  }
}
