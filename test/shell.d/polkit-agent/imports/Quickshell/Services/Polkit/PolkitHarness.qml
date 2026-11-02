pragma Singleton
import QtQuick

// How the test reaches the agent the dialog creates, which has no id outside it.
QtObject {
  property var agent: null
}
