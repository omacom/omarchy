import QtQuick
import QtTest

// The theme has no username field, so the name it hands to sddm.login() is the
// only account anyone can log in to.
TestCase {
  id: testCase
  name: "SddmLoginUser"
  when: windowShown
  width: 640
  height: 480
  visible: true

  Component {
    id: greeterComponent
    Greeter {}
  }

  function test_login_user_data() {
    return [
      { tag: "no remembered user", lastUser: "", users: ["alice"], expected: "alice" },
      { tag: "no remembered user, several accounts", lastUser: "", users: ["alice", "bob"], expected: "alice" },
      { tag: "remembered user", lastUser: "bob", users: ["alice", "bob"], expected: "bob" },
      { tag: "no accounts", lastUser: "", users: [], expected: "" }
    ]
  }

  function test_login_user(data) {
    var greeter = createTemporaryObject(greeterComponent, testCase, { lastUser: data.lastUser, users: data.users })
    verify(greeter.theme, "the theme loads")
    keyClick(Qt.Key_Return)
    compare(greeter.logins.length, 1, "Enter submits one login")
    compare(greeter.logins[0], data.expected)
  }
}
