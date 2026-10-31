"""Find a shell control in the AT-SPI accessibility tree.

  atspi.py <role> <name>   exit 0 when the shell shows that control

Exits 1 when the shell's tree lacks the control, and 2 when the shell
publishes no tree (accessibility switched off, or a Quickshell before 0.3.2).
With no accessibility bus at all, libatspi aborts the process.
"""

import sys

import gi

gi.require_version("Atspi", "2.0")
from gi.repository import Atspi


def shell_apps():
  desktop = Atspi.get_desktop(0)
  for index in range(desktop.get_child_count()):
    app = desktop.get_child_at_index(index)
    # The GTK platform theme registers empty extra apps under the same name;
    # only the Qt one carries the tree.
    if app and app.get_name() == "quickshell" and app.get_toolkit_name() == "Qt":
      yield app


def find(node, role, name):
  if (node.get_role_name() == role and node.get_name() == name
      and node.get_state_set().contains(Atspi.StateType.SHOWING)):
    return node
  for index in range(node.get_child_count()):
    child = node.get_child_at_index(index)
    found = child and find(child, role, name)
    if found:
      return found
  return None


role, name = sys.argv[1:3]
apps = [app for app in shell_apps() if app.get_child_count() > 0]
if not apps:
  print("the shell publishes no accessibility tree", file=sys.stderr)
  sys.exit(2)
if not any(find(app, role, name) for app in apps):
  print(f"no {role} named {name!r} in the shell's accessibility tree", file=sys.stderr)
  sys.exit(1)
