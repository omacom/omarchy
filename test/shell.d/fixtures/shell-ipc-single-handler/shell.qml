import QtQuick
import Quickshell
import qs.Commons

ShellRoot {
  id: root

  // Three copies of one target. The bar makes a copy of a widget for each
  // screen.
  ListModel {
    id: copies
    ListElement { name: "first" }
    ListElement { name: "second" }
    ListElement { name: "third" }
  }

  Instantiator {
    model: copies

    delegate: ShellIpc {
      required property string name

      target: "test.copy"

      function who(): string { return name }
    }
  }

  // A Ui/Panel with manageIpc false registers first. It must not block the
  // handler that addPanel() makes later.
  ShellIpc {
    active: false
    target: "test.panel"

    function who(): string { return "inactive" }
  }

  Instantiator {
    id: panels
    model: 0

    delegate: ShellIpc {
      target: "test.panel"

      function who(): string { return "active" }
    }
  }

  ShellIpc {
    target: "test.control"

    // Remove the copy that holds test.copy, as when a monitor disconnects.
    function drop(): void { copies.remove(0) }
    function addPanel(): void { panels.model = 1 }
  }
}
