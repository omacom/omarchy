#!/bin/bash

source "$(dirname "$0")/base-test.sh"

# The seat commands find their sandbox supervisor and init under $OMARCHY_PATH.
export OMARCHY_PATH="$ROOT"

require_command python3
require_command jq
require_command bwrap
require_command dbus-daemon
require_command busctl

test_dir=$(mktemp -d)
runtime="$test_dir/runtime"
mkdir -p "$test_dir/bin" "$test_dir/share" "$test_dir/home" "$runtime"

# The live session's compositor, if there is one, as an absolute path: the
# test seat keeps its own runtime directory but draws real windows.
compositor=""
if compositor_reachable; then
  compositor=$WAYLAND_DISPLAY
  [[ $compositor == /* ]] || compositor="$XDG_RUNTIME_DIR/$compositor"
fi

# A home of the test's own: a launch makes the seat's home under it, and moves
# one it finds at the old place, which must never be the developer's own.
seat() {
  HOME="$test_dir/home" XDG_RUNTIME_DIR="$runtime" WAYLAND_DISPLAY="${compositor:-$test_dir/no-compositor}" PATH="$test_dir/bin:$ROOT/bin:$PATH" "$@"
}

cleanup() {
  seat omarchy-agent-seat-stop >/dev/null 2>&1 || true
  [[ -n ${broker_pid:-} ]] && kill "$broker_pid" 2>/dev/null
  [[ -n ${cdp_pid:-} ]] && kill "$cdp_pid" 2>/dev/null
  rm -rf "$test_dir"
}
trap cleanup EXIT

# The test seat must not look the live seat's windows up in Hyprland.
printf '#!/bin/bash\necho "[]"\n' >"$test_dir/bin/hyprctl"
chmod +x "$test_dir/bin/hyprctl"

# Without python-gobject or the Atspi typelib, the reader says what to install
# instead of failing with a traceback.
mkdir -p "$test_dir/no-gi/gi"
echo 'raise ImportError("no gi here")' >"$test_dir/no-gi/gi/__init__.py"
missing=$(PYTHONPATH="$test_dir/no-gi" "$ROOT/bin/omarchy-agent-seat-ui" --atspi-dump "unix:path=$test_dir/no-bus" 2>&1)
(( $? == 3 )) && [[ -z $missing ]] || fail "the AT-SPI reader reports a missing gi quietly" "$missing"
pass "the AT-SPI reader reports a missing python-gobject without a traceback"

# A menu is a window of its own, here 120x200 at scale 2, and may open outside
# the 400x200 window: its items show within its own bounds, in the pixels of a
# screenshot that starts at the menu when it opens above or left of the window.
popups=$(python3 - "$ROOT/bin/omarchy-agent-seat-ui" <<'EOF'
import importlib.machinery, importlib.util, json, sys
loader = importlib.machinery.SourceFileLoader("seat_ui", sys.argv[1])
spec = importlib.util.spec_from_loader("seat_ui", loader)
ui = importlib.util.module_from_spec(spec)
loader.exec_module(ui)

def widget(role, name, extents, children=()):
  return {"role": role, "name": name, "value": None, "states": [], "extents": extents, "children": list(children)}

main = widget("frame", "Popup Test", [0, 0, 400, 200], [widget("push button", "Open", [10, 150, 80, 30]), widget("push button", "Away", [500, 10, 50, 20])])
menu = widget("window", "", [0, 0, 120, 200], [widget("menu", "", [0, 0, 120, 200], [widget("menu item", "First", [4, 4, 112, 30]), widget("menu item", "Second", [4, 140, 112, 30])])])
apps = [{"name": "test", "windows": [main, menu]}]

def read(position, origin, apps=apps, size=(120, 200)):
  state = {"title": "Popup Test", "geometry": [0, 0, 400, 200], "surface": [400, 200], "scale": 2, "origin": origin, "popups": [{"position": position, "size": list(size)}]}
  return {item["name"] or item["role"]: [item["x"], item["y"]] for item in ui.atspi_tree(state, apps, True)}

# GTK lists the items of a menu button's menu under the button instead, in the
# menu's coordinates; their screen coordinates place the menu (here 6 by 5
# inside its shadow) in the window.
def item(name, extents, screen):
  return {**widget("menu item", name, extents), "screen": screen}
button = widget("toggle button", "Choose", [0, 170, 400, 30], [item("Pick One", [6, 9, 115, 27], [6, 164]), item("Pick Two", [6, 36, 115, 27], [6, 191])])
attached = [{"name": "test", "windows": [widget("frame", "Popup Test", [0, 0, 400, 200], [button])]}]

print(json.dumps({"beside": read([400, 100], [0, 0, 2]), "above": read([-130, -50], [-130, -50, 2]), "attached": read([-6, 150], [-6, 0, 2], attached, (127, 128))}))
EOF
) || fail "ui reads a fake tree with a menu" "$popups"

[[ $(jq -c '.beside' <<<"$popups") == '{"Popup Test":[400,200],"Open":[100,330],"window":[920,400],"First":[920,238],"Second":[920,510]}' ]] || fail "ui lists the items of a menu beside the window where they are" "$popups"
pass "ui lists the items of a menu beside the window where they are"
[[ $(jq -c '.above' <<<"$popups") == '{"Popup Test":[660,300],"Open":[360,430],"window":[120,200],"First":[120,38],"Second":[120,310]}' ]] || fail "ui places a window's controls and its menu above it in the screenshot's pixels" "$popups"
pass "ui places a window's controls and its menu above it in the screenshot's pixels"
[[ $(jq -c '.attached' <<<"$popups") == '{"Popup Test":[412,200],"Choose":[412,370],"Pick One":[127,345],"Pick Two":[127,399]}' ]] || fail "ui places the items of a menu listed under its button in the menu" "$popups"
pass "ui places the items of a menu listed under its button in the menu"

# A control scrolled partly out of the 400x200 window, at scale 2, is clicked on
# the part that shows; one showing only 2 pixels is left out.
partial=$(python3 - "$ROOT/bin/omarchy-agent-seat-ui" <<'EOF'
import importlib.machinery, importlib.util, json, sys
loader = importlib.machinery.SourceFileLoader("seat_ui", sys.argv[1])
spec = importlib.util.spec_from_loader("seat_ui", loader)
ui = importlib.util.module_from_spec(spec)
loader.exec_module(ui)

def widget(role, name, extents, children=()):
  return {"role": role, "name": name, "value": None, "states": [], "extents": extents, "children": list(children)}

controls = [widget("push button", "Half right", [300, 50, 200, 40]), widget("push button", "Half below", [10, 190, 80, 40]), widget("push button", "Sliver", [398, 100, 50, 20])]
apps = [{"name": "test", "windows": [widget("frame", "Scroll Test", [0, 0, 400, 200], controls)]}]
state = {"title": "Scroll Test", "geometry": [0, 0, 400, 200], "surface": [400, 200], "scale": 2, "origin": [0, 0, 2], "popups": []}
print(json.dumps({item["name"]: [item["x"], item["y"]] for item in ui.atspi_tree(state, apps, True)}))
EOF
) || fail "ui reads a fake tree with controls scrolled partly away" "$partial"

[[ $(jq -c '.' <<<"$partial") == '{"Scroll Test":[400,200],"Half right":[700,140],"Half below":[100,390]}' ]] || fail "ui places a control scrolled partly away on the part that shows, and leaves out a sliver" "$partial"
pass "ui places a control scrolled partly away on the part that shows, and leaves out a sliver"

# Scroll panes, viewports and tables hide what scrolls past their edges, and a
# table the rows scrolled under its column header, as GTK reports them at
# scale 1: a row under the header and one past the pane's bottom are clicked
# on the part that shows, a button scrolled out of its viewport is left out.
# A page tab is the size of its label, with its page under it, all shown.
clipped=$(python3 - "$ROOT/bin/omarchy-agent-seat-ui" <<'EOF'
import importlib.machinery, importlib.util, json, sys
loader = importlib.machinery.SourceFileLoader("seat_ui", sys.argv[1])
spec = importlib.util.spec_from_loader("seat_ui", loader)
ui = importlib.util.module_from_spec(spec)
loader.exec_module(ui)

def widget(role, name, extents, children=()):
  return {"role": role, "name": name, "value": None, "states": [], "extents": extents, "children": list(children)}

table = widget("scroll pane", "", [0, 71, 400, 120], [widget("table", "", [0, 71, 400, 120], [
  widget("table column header", "Header", [0, 71, 400, 25]),
  widget("table cell", "Row 1", [2, 85, 396, 23]),
  widget("table cell", "Row 2", [2, 110, 396, 23]),
  widget("table cell", "Row 5", [2, 185, 396, 23]),
])])
items = widget("scroll pane", "", [0, 191, 400, 120], [widget("viewport", "", [0, 191, 400, 120], [widget("filler", "", [0, 141, 400, 680], [
  widget("push button", "Item 1", [0, 175, 400, 34]),
  widget("push button", "Item 2", [0, 209, 400, 34]),
  widget("push button", "Item 5", [0, 311, 400, 34]),
])])])
pages = widget("page tab list", "", [0, 311, 400, 89], [widget("page tab", "First", [21, 315, 32, 30], [widget("filler", "", [1, 349, 398, 50], [widget("push button", "First action", [1, 349, 398, 34])])])])
apps = [{"name": "test", "windows": [widget("frame", "Clip Test", [0, 0, 400, 400], [table, items, pages])]}]
state = {"title": "Clip Test", "geometry": [0, 0, 400, 400], "surface": [400, 400], "scale": 1, "origin": [0, 0, 1], "popups": []}
print(json.dumps({item["name"]: [item["x"], item["y"]] for item in ui.atspi_tree(state, apps, True)}))
EOF
) || fail "ui reads a fake tree with scroll panes and a table" "$clipped"

[[ $(jq -c '[."Row 1", ."Row 2", ."Row 5"]' <<<"$clipped") == "[[200,102],[200,121],[200,188]]" ]] || fail "ui places a table's rows on the part that shows below its header and above its edge" "$clipped"
[[ $(jq -c '[."Item 1", ."Item 2"]' <<<"$clipped") == "[[200,200],[200,226]]" && $(jq -r 'has("Item 5")' <<<"$clipped") == "false" ]] || fail "ui places a control on the part its viewport shows, and leaves out one scrolled out of it" "$clipped"
[[ $(jq -c '."First action"' <<<"$clipped") == "[200,366]" ]] || fail "ui lists the page under a page tab the size of its label" "$clipped"
pass "ui clips controls to the scroll panes, viewports and table headers above them"

# An app can show two windows of the same title and size: the one the seat's
# keyboard is in reports itself active. When that does not tell them apart,
# ui refuses and numbers them, and --page picks one.
twins=$(python3 - "$ROOT/bin/omarchy-agent-seat-ui" <<'EOF'
import importlib.machinery, importlib.util, json, sys
loader = importlib.machinery.SourceFileLoader("seat_ui", sys.argv[1])
spec = importlib.util.spec_from_loader("seat_ui", loader)
ui = importlib.util.module_from_spec(spec)
loader.exec_module(ui)

def frame(label, states):
  button = {"role": "push button", "name": label, "value": None, "states": [], "extents": [10, 10, 80, 30], "children": []}
  return {"role": "frame", "name": "Twin", "value": None, "states": states, "extents": [0, 0, 400, 200], "children": [button]}

def read(windows, keyboard, page=None):
  state = {"title": "Twin", "geometry": [0, 0, 400, 200], "surface": [400, 200], "scale": 1, "origin": [0, 0, 1], "popups": [], "focus": {"owner": "agent", "keyboard": keyboard, "user_keyboard": False}}
  try:
    return [item["name"] for item in ui.atspi_tree(state, [{"name": "twin", "windows": windows}], True, *([page] if page else []))][1]
  except ui.Ambiguous as error:
    return f"refused: {error}"

print(json.dumps({
  "focused": read([frame("Alpha", []), frame("Beta", ["active"])], True),
  "unfocused": read([frame("Beta", ["active"]), frame("Alpha", [])], False),
  "both": read([frame("Alpha", ["active"]), frame("Beta", ["active"])], True),
  "second": read([frame("Alpha", ["active"]), frame("Beta", ["active"])], True, "2"),
  "outside": read([frame("Alpha", ["active"]), frame("Beta", ["active"])], True, "3"),
}))
EOF
) || fail "ui reads a fake app with two windows of the same title" "$twins"

[[ $(jq -r '.focused' <<<"$twins") == "Beta" && $(jq -r '.unfocused' <<<"$twins") == "Alpha" ]] || fail "ui reads the window of two alike that has the seat's keyboard focus, or the one that has not" "$twins"
pass "ui reads the window of two alike that has the seat's keyboard focus, or the one that has not"
both=$(jq -r '.both' <<<"$twins")
[[ $both == "refused: 2 windows titled 'Twin' look alike"* ]] && grep -qx '1\. frame "Twin" 400x200 \[active\]: push button "Alpha"' <<<"$both" && grep -qx '2\. frame "Twin" 400x200 \[active\]: push button "Beta"' <<<"$both" && [[ $(tail -n 1 <<<"$both") == "Rerun with --page N to pick one (its number above)." ]] || fail "ui refuses to guess between windows alike, and numbers them" "$both"
pass "ui refuses to guess between windows alike, and numbers them"
[[ $(jq -r '.second' <<<"$twins") == "Beta" ]] || fail "--page picks one of the windows alike by its number" "$twins"
[[ $(jq -r '.outside' <<<"$twins") == "refused: --page 3: there are only 2 windows titled 'Twin'"* ]] || fail "a --page number outside the windows alike refuses" "$twins"
pass "--page picks one of the windows alike by its number"

# The sandbox can write where its bus socket is, and swap it for a link to any
# socket on the host, the user's own buses included. ui reads only a socket
# that is no link, and connects through the descriptor it checked, so a link
# swapped in after the check leads nowhere else.
bus=$(python3 - "$ROOT/bin/omarchy-agent-seat-ui" "$test_dir/bus-check" <<'EOF'
import importlib.machinery, importlib.util, json, os, socket, sys
loader = importlib.machinery.SourceFileLoader("seat_ui", sys.argv[1])
spec = importlib.util.spec_from_loader("seat_ui", loader)
ui = importlib.util.module_from_spec(spec)
loader.exec_module(ui)

root = sys.argv[2]
def listener(path):
  os.makedirs(os.path.dirname(path), exist_ok=True)
  server = socket.socket(socket.AF_UNIX)
  server.bind(path)
  server.listen(1)
  server.settimeout(0.5)
  return server

def address(directory):
  found = ui.bus_address(directory)
  return found[0] if isinstance(found, tuple) else found

def reached(path, servers):
  client = socket.socket(socket.AF_UNIX)
  client.connect(path)
  for name, server in servers.items():
    try:
      server.accept()[0].close()
      return name
    except socket.timeout:
      pass
  return "nothing"

user_bus = listener(f"{root}/user/bus")
os.makedirs(f"{root}/linked/bus")
os.symlink(f"{root}/user/bus", f"{root}/linked/bus/bus")
os.makedirs(f"{root}/linked-dir")
os.symlink(f"{root}/user", f"{root}/linked-dir/bus")

sandbox_bus = listener(f"{root}/sandbox/bus/bus")
found = address(f"{root}/sandbox")
os.rename(f"{root}/sandbox/bus/bus", f"{root}/sandbox/bus/old")
os.symlink(f"{root}/user/bus", f"{root}/sandbox/bus/bus")
print(json.dumps({
  "linked": address(f"{root}/linked"),
  "linked_dir": address(f"{root}/linked-dir"),
  "swapped": reached(found.removeprefix("unix:path="), {"sandbox": sandbox_bus, "user": user_bus}) if found else "no address",
}))
EOF
) || fail "ui opens a fake sandbox's bus" "$bus"

[[ $(jq -r '.linked' <<<"$bus") == "null" && $(jq -r '.linked_dir' <<<"$bus") == "null" ]] || fail "ui refuses a bus socket that is a link, or in a directory that is one" "$bus"
[[ $(jq -r '.swapped' <<<"$bus") == "sandbox" ]] || fail "ui reaches the bus it checked after the socket is swapped for a link" "$bus"
pass "ui refuses a bus socket behind a link, and reaches the one it checked when a link replaces it later"

if ! bwrap_works; then
  skip "bubblewrap cannot create a sandbox here; skipping the agent seat UI"
  exit 0
fi

seat omarchy-agent-seat-broker serve 2>"$test_dir/broker.log" &
broker_pid=$!
for _ in {1..50}; do [[ -S $runtime/omarchy/agent-seat/control ]] && break; sleep 0.1; done
[[ -S $runtime/omarchy/agent-seat/control ]] || fail "test broker starts" "$(cat "$test_dir/broker.log")"

# The private bus ------------------------------------------------------------------

seat omarchy-agent-seat-run --no-wait --share "$test_dir/share" /usr/bin/bash -c '
  report="$1/report"
  echo "address $DBUS_SESSION_BUS_ADDRESS" >"$report.tmp"
  echo "a11y $AT_SPI_BUS_ADDRESS" >>"$report.tmp"
  [[ -e /run/user/'"$UID"'/bus ]] && echo "host bus visible" >>"$report.tmp"
  busctl --user list --no-pager --no-legend 2>&1 | cut -d" " -f1 | sed "s/^/name /" >>"$report.tmp"
  dbus-send --session --print-reply --dest=org.freedesktop.secrets /org/freedesktop/secrets org.freedesktop.DBus.Peer.Ping >/dev/null 2>&1 && echo "keyring reachable" >>"$report.tmp"
  dbus-send --session --print-reply --dest=org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.DBus.Peer.Ping >/dev/null 2>&1 && echo "portal reachable" >>"$report.tmp"
  mv "$report.tmp" "$report"
  sleep 300' bus-check "$test_dir/share" || fail "a sandbox with a private bus starts"

for _ in {1..100}; do [[ -e $test_dir/share/report ]] && break; sleep 0.05; done
report=$(cat "$test_dir/share/report" 2>/dev/null)
grep -q "^address unix:path=$runtime/agent-bus/bus$" <<<"$report" || fail "the sandbox gets a private session bus" "$report"
grep -q "^a11y unix:path=$runtime/agent-bus/bus$" <<<"$report" || fail "the private bus is also the accessibility bus" "$report"
grep -qx "name org.a11y.atspi.Registry" <<<"$report" || fail "the accessibility registry runs on the private bus" "$report"
pass "a sandbox gets a private session bus with the accessibility registry on it"

grep -q "host bus visible\|keyring reachable\|portal reachable" <<<"$report" && fail "the user's bus, keyring and portals stay unreachable" "$report"
pass "the user's session bus, keyring and portals stay unreachable from the sandbox"

bus_dirs=("$runtime"/omarchy/agent-seat/sandboxes/*.d)
bus_socket="${bus_dirs[0]}/bus/bus"
[[ -S $bus_socket ]] || fail "the seat reaches the private bus from outside" "$(ls -laR "$runtime/omarchy/agent-seat/sandboxes")"
[[ $(stat -c %a "${bus_dirs[0]}") == "700" && $(stat -c %a "${bus_dirs[0]}/bus") == "700" ]] || fail "the private bus is the user's alone"
private_id=$(busctl --address="unix:path=$bus_socket" call org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus GetId 2>&1) || fail "the seat reaches the private bus from outside" "$private_id"
host_id=$(busctl --user call org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus GetId 2>/dev/null || true)
[[ $private_id != "$host_id" ]] || fail "the private bus is not the user's bus"
pass "the seat reaches the private bus from outside, and it is not the user's bus"

# The accessibility tree of a GTK app, and clicking by name -----------------------------

if [[ -z $compositor ]] || ! python3 -c 'import gi; gi.require_version("Gtk", "3.0"); gi.require_version("Atspi", "2.0")' 2>/dev/null; then
  skip "no Wayland compositor or GTK 3; skipping the GTK window"
else
  program='
import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk
window = Gtk.Window(title="Seat UI Test")
window.set_default_size(400, 200)
box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8, margin=20)
entry = Gtk.Entry()
button = Gtk.Button(label="Fill")
button.connect("clicked", lambda _: entry.set_text("clicked"))
other = Gtk.Button(label="Fill later")
box.pack_start(entry, False, False, 0)
box.pack_start(button, False, False, 0)
box.pack_start(other, False, False, 0)
window.add(box)
window.connect("destroy", Gtk.main_quit)
window.show_all()
Gtk.main()
'
  window=$(seat omarchy-agent-seat-run /usr/bin/python3 -c "$program") || fail "a GTK app opens on the test seat" "$(cat "$runtime/omarchy/agent-seat/apps.log")"

  for _ in {1..50}; do
    state=$(seat omarchy-agent-seat-state "$window" --json)
    [[ $(jq -r '.[0].drawn' <<<"$state") == "true" ]] && break
    sleep 0.1
  done
  [[ $(jq -r '.[0].title' <<<"$state") == "Seat UI Test" ]] || fail "state reports the window" "$state"
  [[ $(jq -r '.[0].drawn' <<<"$state") == "true" ]] || fail "state reports that the app has drawn" "$state"
  [[ $(jq -r '.[0].pid' <<<"$state") =~ ^[0-9]+$ && $(jq -r '.[0].scale' <<<"$state") != "null" ]] || fail "state reports the app's pid and scale" "$state"
  seat omarchy-agent-seat-state "$window" | grep -q "^window $window: .*\"Seat UI Test\"" || fail "state lists the window for people"
  pass "state reports the window, its scale, and that it has drawn"

  for _ in {1..50}; do
    tree=$(seat omarchy-agent-seat-ui "$window" 2>&1) && grep -q 'button "Fill"' <<<"$tree" && break
    sleep 0.1
  done
  grep -q '^frame "Seat UI Test"' <<<"$tree" || fail "ui lists the window" "$tree"
  grep -q '^  button "Fill" @[0-9]*,[0-9]*' <<<"$tree" || fail "ui lists the button with its position" "$tree"
  grep -q '^  text "" @[0-9]*,[0-9]* \[.*editable' <<<"$tree" || fail "ui lists the entry" "$tree"
  [[ $(seat omarchy-agent-seat-ui "$window" --json | jq -r '.source') == "atspi" ]] || fail "a GTK window is read over AT-SPI"
  pass "ui reads a GTK window's accessibility tree over the private bus"

  # The button's centre, in screenshot pixels, must be on the button.
  button=$(seat omarchy-agent-seat-ui "$window" --find Fill --json)
  jq -e --argjson state "$state" '($state[0].size | map(. * $state[0].scale)) as [$width, $height] | .x > .box[0] and .x < .box[0] + .box[2] and .box[0] + .box[2] <= $width and .box[1] + .box[3] <= $height and .box[2] > $state[0].size[0]' <<<"$button" >/dev/null || fail "ui positions are in screenshot pixels" "$button $state"
  pass "ui positions controls in screenshot pixels"

  seat omarchy-agent-seat-click-ui "$window" "Fill" >/dev/null || fail "click-ui clicks a button by name"
  for _ in {1..30}; do
    value=$(seat omarchy-agent-seat-ui "$window" --find text: --json | jq -r '.value')
    [[ $value == "clicked" ]] && break
    sleep 0.1
  done
  [[ $value == "clicked" ]] || fail "click-ui on the button changes the entry" "$value"
  pass "click-ui on a button changes the entry, and ui shows it"

  [[ $(seat omarchy-agent-seat-state "$window" --json | jq -r '.[0].focus.owner') == "agent" ]] || fail "state reports that the agent acted last"
  pass "state reports whose input the window saw last"

  partial=$(seat omarchy-agent-seat-click-ui "$window" "fill l" 2>&1) && fail "click-ui refuses a name that is only part of a control's"
  grep -q 'button "Fill later"' <<<"$partial" || fail "a partial name lists the control it is part of" "$partial"
  seat omarchy-agent-seat-click-ui "$window" "fill later" >/dev/null || fail "click-ui clicks a full name in any case"
  candidates=$(seat omarchy-agent-seat-click-ui "$window" "button:" 2>&1) && fail "click-ui refuses an ambiguous name"
  grep -q 'button "Fill later"' <<<"$candidates" || fail "an ambiguous name lists the candidates" "$candidates"
  seat omarchy-agent-seat-click-ui "$window" "Nothing here" 2>/dev/null && fail "click-ui refuses a name that matches nothing"
  pass "click-ui matches exact, then in any case, and lists partial and ambiguous candidates"

  # Menus that open outside the window, below and above it, where the screenshot
  # then starts.
  program='
import gi
gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from gi.repository import Gtk, Gdk
window = Gtk.Window(title="Seat Menu Test")
window.set_default_size(400, 200)
box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
entry = Gtk.Entry()
quit_button = Gtk.Button(label="Quit")
quit_button.connect("clicked", lambda _: Gtk.main_quit())
def menu_button(label, widget_anchor, menu_anchor):
  button = Gtk.Button(label=label)
  menu = Gtk.Menu()
  for name in ("First", "Second", "Third"):
    item = Gtk.MenuItem(label=label + " " + name)
    item.connect("activate", lambda item: entry.set_text("chose " + item.get_label()))
    menu.append(item)
  menu.show_all()
  menu.set_property("anchor-hints", 0)
  button.connect("clicked", lambda _: menu.popup_at_widget(button, widget_anchor, menu_anchor, None))
  return button
box.pack_start(menu_button("Above", Gdk.Gravity.NORTH_WEST, Gdk.Gravity.SOUTH_WEST), False, False, 0)
box.pack_start(entry, False, False, 0)
attached = Gtk.Menu()
for name in ("Choose First", "Choose Second", "Choose Third"):
  item = Gtk.MenuItem(label=name)
  item.connect("activate", lambda item: entry.set_text("chose " + item.get_label()))
  attached.append(item)
attached.show_all()
choose = Gtk.MenuButton(label="Choose")
choose.set_use_popover(False)
choose.set_popup(attached)
box.pack_start(choose, False, False, 0)
box.pack_start(quit_button, False, False, 0)
box.pack_end(menu_button("Below", Gdk.Gravity.SOUTH_WEST, Gdk.Gravity.NORTH_WEST), False, False, 0)
window.add(box)
window.connect("destroy", Gtk.main_quit)
window.show_all()
Gtk.main()
'
  menus=$(seat omarchy-agent-seat-run /usr/bin/python3 -c "$program") || fail "a GTK app with menus opens on the test seat" "$(cat "$runtime/omarchy/agent-seat/apps.log")"
  for _ in {1..50}; do
    seat omarchy-agent-seat-ui "$menus" --find Below >/dev/null 2>&1 && break
    sleep 0.1
  done
  for side in Below Above; do
    # The item furthest from the window, which a screenshot shows past its edge.
    [[ $side == "Below" ]] && name="Below Third" || name="Above First"
    seat omarchy-agent-seat-click-ui "$menus" "button:$side" >/dev/null || fail "click-ui opens the menu $side the window"
    for _ in {1..50}; do
      seat omarchy-agent-seat-ui "$menus" --find "$name" >/dev/null 2>&1 && break
      sleep 0.1
    done
    seat omarchy-agent-seat-screenshot "$menus" >/dev/null || fail "a screenshot shows the menu $side the window"
    item=$(seat omarchy-agent-seat-ui "$menus" --find "$name" --json)
    state=$(seat omarchy-agent-seat-state "$menus" --json)
    jq -e --arg side "$side" --argjson state "$state" '$state[0] as $s | if $side == "Below" then .box[1] >= $s.size[1] * $s.scale else $s.origin[1] < 0 and .box[1] + .box[3] <= -$s.origin[1] * $s.scale and .box[1] >= 0 end' <<<"$item" >/dev/null || fail "ui lists the items of a menu $side the window, outside it" "$item $state"
    seat omarchy-agent-seat-click-ui "$menus" "$name" >/dev/null || fail "click-ui clicks an item of a menu $side the window"
    for _ in {1..30}; do
      value=$(seat omarchy-agent-seat-ui "$menus" --find text: --json | jq -r '.value')
      [[ $value == "chose $name" ]] && break
      sleep 0.1
    done
    [[ $value == "chose $name" ]] || fail "click-ui on an item of a menu $side the window activates it" "$value"
  done

  seat omarchy-agent-seat-click-ui "$menus" "toggle button:Choose" >/dev/null || fail "click-ui opens a menu button's menu"
  for _ in {1..50}; do
    seat omarchy-agent-seat-ui "$menus" --find "Choose Second" >/dev/null 2>&1 && break
    sleep 0.1
  done
  sleep 0.5  # GTK ignores a click on a menu that has only just opened
  seat omarchy-agent-seat-click-ui "$menus" "Choose Second" >/dev/null || fail "click-ui clicks an item of a menu button's menu"
  for _ in {1..30}; do
    value=$(seat omarchy-agent-seat-ui "$menus" --find text: --json | jq -r '.value')
    [[ $value == "chose Choose Second" ]] && break
    sleep 0.1
  done
  [[ $value == "chose Choose Second" ]] || fail "click-ui on an item of a menu button's menu activates it" "$value"
  pass "click-ui clicks the items of a menu GTK lists under its button"

  seat omarchy-agent-seat-click-ui "$menus" Quit >/dev/null
  pass "ui lists and click-ui clicks the items of menus that open below and above the window"

  missing=$(PYTHONPATH="$test_dir/no-gi" seat omarchy-agent-seat-ui "$window" 2>&1)
  (( $? == 2 )) && [[ $missing == "Install python-gobject and at-spi2-core to read accessibility trees" ]] || fail "ui without python-gobject says what to install and exits 2" "$missing"
  pass "ui without python-gobject says what to install and exits 2"
fi

# The DevTools route, against a fake DevTools endpoint ------------------------------------

cat >"$test_dir/cdp.py" <<'EOF'
import base64, hashlib, html, json, socket, struct, sys, threading

server = socket.socket()
server.bind(("127.0.0.1", 0))
server.listen(4)
port = server.getsockname()[1]
print(port, flush=True)

NODES = [
  {"nodeId": "1", "ignored": False, "role": {"value": "RootWebArea"}, "name": {"value": "Fake page"}, "childIds": ["2", "3", "5", "6", "7"], "backendDOMNodeId": 1},
  {"nodeId": "2", "parentId": "1", "ignored": False, "role": {"value": "button"}, "name": {"value": "Send"}, "childIds": ["4"], "backendDOMNodeId": 2},
  {"nodeId": "4", "parentId": "2", "ignored": False, "role": {"value": "StaticText"}, "name": {"value": "Send"}, "childIds": [], "backendDOMNodeId": 4},
  {"nodeId": "3", "parentId": "1", "ignored": False, "role": {"value": "textbox"}, "name": {"value": "Message"}, "value": {"value": "hi"}, "properties": [{"name": "focused", "value": {"value": True}}], "childIds": [], "backendDOMNodeId": 3},
  {"nodeId": "5", "parentId": "1", "ignored": False, "role": {"value": "link"}, "name": {"value": "Far away"}, "childIds": [], "backendDOMNodeId": 5},
  {"nodeId": "6", "parentId": "1", "ignored": False, "role": {"value": "link"}, "name": {"value": "Half shown"}, "childIds": [], "backendDOMNodeId": 6},
  {"nodeId": "7", "parentId": "1", "ignored": False, "role": {"value": "link"}, "name": {"value": "Sliver"}, "childIds": [], "backendDOMNodeId": 7},
]
BOXES = {1: [0, 0, 800, 600], 2: [10, 20, 100, 40], 3: [200, 20, 300, 40], 4: [20, 25, 80, 30], 5: [10, 5000, 100, 20], 6: [700, 100, 200, 20], 7: [10, 599, 100, 20]}

# A page may add controls of its own under the root, with their boxes.
def tree(page):
    extra = page.get("nodes", [])
    return [{**NODES[0], "childIds": NODES[0]["childIds"] + [n["nodeId"] for n in extra]}, *NODES[1:], *extra]

def boxes(page):
    return {**BOXES, **{int(b): box for b, box in page.get("boxes", {}).items()}}

def describe(nodes, backend, depth):
    role = next(n["role"]["value"] for n in nodes if n["backendDOMNodeId"] == backend)
    tag = {"link": "a", "button": "button", "textbox": "input", "StaticText": "span"}.get(role, "div")
    children = [n["backendDOMNodeId"] for n in nodes if n.get("parentId") == str(backend)]
    return {"backendNodeId": backend, "nodeType": 1, "nodeName": tag.upper(), "localName": tag, "attributes": ["id", f"n{backend}"], **({"children": [describe(nodes, child, depth - 1) for child in children]} if depth else {})}

def frame(sock, text):
    data = text.encode()
    header = bytes([0x81]) + (bytes([len(data)]) if len(data) < 126 else bytes([126]) + struct.pack(">H", len(data)) if len(data) < 65536 else bytes([127]) + struct.pack(">Q", len(data)))
    sock.sendall(header + data)

def read(sock, buffer, count):
    while len(buffer) < count:
        chunk = sock.recv(65536)
        if not chunk:
            raise ConnectionError
        buffer += chunk
    return buffer[:count], buffer[count:]

# Each connection on its own thread: the reader holds a page's open while it
# asks the browser and DevTools frontends about its window.
def serve(conn):
    request = b""
    while b"\r\n\r\n" not in request:
        request += conn.recv(65536)
    head, rest = request.split(b"\r\n\r\n", 1)
    lines = head.decode().split("\r\n")
    # The pages, each in a browser window of some size and shown or not, are
    # the test's to change between requests.
    with open(sys.argv[2]) as pages_file:
        PAGES = json.load(pages_file)
    if lines[0].startswith("GET /json/list") or lines[0].startswith("GET /json/version"):
        if lines[0].startswith("GET /json/list"):
            body = [{"type": "page", "id": page["id"], "title": page["title"], "url": page.get("url", f"https://example.com/{page['id']}"), "webSocketDebuggerUrl": f"ws://127.0.0.1:{port}/devtools/page/{page['id']}"} for page in PAGES]
        else:
            body = {"webSocketDebuggerUrl": f"ws://127.0.0.1:{port}/devtools/browser/fake"}
        body = json.dumps(body).encode()
        conn.sendall(b"HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: " + str(len(body)).encode() + b"\r\nConnection: close\r\n\r\n" + body)
        conn.close()
        return
    page = next((page for page in PAGES if lines[0].split()[1] == f"/devtools/page/{page['id']}"), None)
    key = next(line.split(":", 1)[1].strip() for line in lines if line.lower().startswith("sec-websocket-key"))
    accept = base64.b64encode(hashlib.sha1((key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11").encode()).digest()).decode()
    conn.sendall(f"HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: {accept}\r\n\r\n".encode())
    buffer = rest
    try:
        while True:
            header, buffer = read(conn, buffer, 2)
            length = header[1] & 0x7F
            if length == 126:
                raw, buffer = read(conn, buffer, 2)
                length = struct.unpack(">H", raw)[0]
            elif length == 127:
                raw, buffer = read(conn, buffer, 8)
                length = struct.unpack(">Q", raw)[0]
            mask, buffer = read(conn, buffer, 4)
            payload, buffer = read(conn, buffer, length)
            message = json.loads(bytes(b ^ mask[i % 4] for i, b in enumerate(payload)))
            method, params = message["method"], message.get("params", {})
            if method == "Runtime.evaluate" and "document.title" in params["expression"]:
                if page.get("busy"):
                    continue  # a page too busy to answer
                # The page's own title is plain.
                result = {"result": {"type": "string", "value": json.dumps(["visible" if page["visible"] else "hidden", html.unescape(page["title"])])}}
            elif method == "Runtime.evaluate":
                # Its viewport, and the browser window around it; a DevTools
                # docked in a window spans the page's part of it too.
                inner, outer = page.get("inner", [800, 600]), page.get("outer") or page["window"]
                values = [*inner, page.get("ratio", float(sys.argv[1]))] +([*outer, "visible" if page["visible"] else "hidden"] if "outerWidth" in params["expression"] else [])
                result = {"result": {"type": "string", "value": json.dumps(values)}}
            elif method == "Browser.getWindowForTarget":
                window = next(page["window"] for page in PAGES if page["id"] == params["targetId"])
                if not window:
                    # Docked DevTools has no window of its own.
                    frame(conn, json.dumps({"id": message["id"], "error": {"code": -32000, "message": "Browser window not found"}}))
                    continue
                width, height = window
                result = {"windowId": width, "bounds": {"left": 0, "top": 0, "width": width, "height": height}}
            elif method == "Accessibility.getFullAXTree":
                result = {"nodes": tree(page)}
            elif method == "DOM.getBoxModel":
                x, y, w, h = boxes(page)[params["backendNodeId"]]
                result = {"model": {"border": [x, y, x + w, y, x + w, y + h, x, y + h]}}
            elif method == "DOM.resolveNode":
                result = {"object": {"type": "object", "objectId": f"node-{params['backendNodeId']}"}}
            elif method == "Runtime.callFunctionOn" and params["objectId"].removeprefix("node-") in page.get("clips", {}):
                # Where the overflow ancestors of a node let it show.
                result = {"result": {"type": "object", "value": page["clips"][params["objectId"].removeprefix("node-")]}}
            elif method == "DOM.getNodeForLocation":
                # The innermost node there, unless the page puts another on top.
                x, y = params["x"], params["y"]
                under = [b for b, (bx, by, bw, bh) in boxes(page).items() if bx <= x < bx + bw and by <= y < by + bh]
                result = {"backendNodeId": page.get("cover") or min(under, key=lambda b: boxes(page)[b][2] * boxes(page)[b][3])}
            elif method == "DOM.describeNode":
                result = {"node": describe(tree(page), params["backendNodeId"], params.get("depth", 1))}
            else:
                result = {}
            frame(conn, json.dumps({"id": message["id"], "result": result}))
    except (ConnectionError, OSError):
        conn.close()

while True:
    threading.Thread(target=serve, args=(server.accept()[0],), daemon=True).start()
EOF

# DevTools escapes titles as HTML; the window's title is plain.
cat >"$test_dir/pages.json" <<'EOF'
[
  {"id": "2", "title": "Fun &amp; games", "visible": true, "window": [800, 600]},
  {"id": "1", "title": "Fake page", "visible": true, "window": [800, 600]}
]
EOF

coproc CDP { exec python3 "$test_dir/cdp.py" 1.5 "$test_dir/pages.json" 2>/dev/null; }
cdp_pid=$CDP_PID
read -r -t 5 cdp_port <&"${CDP[0]}" || fail "the fake DevTools endpoint starts"

# An 800x600 page filling a window at scale 1.5, whose last screenshot started
# at its corner: CSS pixels map to screenshot pixels 1.5 times over.
cdp=$(python3 - "$ROOT/bin/omarchy-agent-seat-ui" "$cdp_port" <<'EOF'
import importlib.machinery, importlib.util, json, sys
loader = importlib.machinery.SourceFileLoader("seat_ui", sys.argv[1])
spec = importlib.util.spec_from_loader("seat_ui", loader)
ui = importlib.util.module_from_spec(spec)
loader.exec_module(ui)
state = {"title": "Fake page - Chromium", "geometry": [0, 0, 800, 600], "origin": [0, 0, 1.5], "scale": 1.5}
nodes = ui.cdp_tree(state, int(sys.argv[2]))
escaped = ui.cdp_target(int(sys.argv[2]), "Fun & games - Chromium") or {}
print(json.dumps({"nodes": nodes, "send": ui.find(nodes, "send"), "box": ui.find(nodes, "textbox:"), "half": ui.find(nodes, "Half shown"), "listing": [ui.describe(n) for n in nodes], "escaped": escaped.get("webSocketDebuggerUrl", "")}))
EOF
) || fail "ui reads a page over DevTools" "$cdp"

[[ $(jq -r '.nodes | map(.name) | join(", ")' <<<"$cdp") == "Fake page, Send, Message, Half shown" ]] || fail "the DevTools route lists the page's controls, skipping repeated text and what is scrolled away" "$cdp"
pass "the DevTools route lists the page's controls, skipping repeated text and what is scrolled away"
# Half of the link lies right of the 800 CSS pixel wide page.
[[ $(jq -c '.half[0] | [.x, .y]' <<<"$cdp") == "[1125,165]" ]] || fail "the DevTools route places a control scrolled partly away on the part that shows" "$cdp"
pass "the DevTools route places a control scrolled partly away on the part that shows"
[[ $(jq -c '.send[0] | [.x, .y, .box]' <<<"$cdp") == "[90,60,[15,30,150,60]]" ]] || fail "the DevTools route positions controls in screenshot pixels" "$cdp"
pass "the DevTools route positions controls in screenshot pixels"
[[ $(jq -r '.box[0].value' <<<"$cdp") == "hi" && $(jq -r '.box[0].states[0]' <<<"$cdp") == "focused" ]] || fail "the DevTools route reports values and focus" "$cdp"
jq -r '.listing[]' <<<"$cdp" | grep -qx 'textbox "Message" = "hi" @525,60 \[focused\]' || fail "the DevTools route lists controls for people" "$cdp"
pass "the DevTools route reports values and focus"
[[ $(jq -r '.escaped' <<<"$cdp") == */devtools/page/2 ]] || fail "the DevTools route finds a tab whose title DevTools escapes" "$cdp"
pass "the DevTools route finds a tab whose title DevTools escapes"

# A scroll pane or any other element whose overflow is not visible hides what
# lies past its edges: here the button shows only above CSS pixel 40, and the
# text box not at all.
echo '[{"id": "1", "title": "Fake page", "visible": true, "window": [800, 600], "clips": {"2": [10, 20, 0, 0, 800, 40], "3": [200, 20, 0, 0, 800, 10]}}]' >"$test_dir/pages.json"
clipped=$(python3 - "$ROOT/bin/omarchy-agent-seat-ui" "$cdp_port" <<'EOF'
import importlib.machinery, importlib.util, json, sys
loader = importlib.machinery.SourceFileLoader("seat_ui", sys.argv[1])
spec = importlib.util.spec_from_loader("seat_ui", loader)
ui = importlib.util.module_from_spec(spec)
loader.exec_module(ui)
state = {"title": "Fake page - Chromium", "geometry": [0, 0, 800, 600], "origin": [0, 0, 1.5], "scale": 1.5}
print(json.dumps({item["name"]: [item["x"], item["y"]] for item in ui.cdp_tree(state, int(sys.argv[2]))}))
EOF
) || fail "ui reads a page with overflow containers over DevTools" "$clipped"
[[ $(jq -c '.Send' <<<"$clipped") == "[90,45]" && $(jq -r 'has("Message")' <<<"$clipped") == "false" ]] || fail "the DevTools route places a control on the part its overflow ancestors show, and leaves out one they hide" "$clipped"
pass "the DevTools route places a control on the part its overflow ancestors show, and leaves out one they hide"

# Tabs and windows alike can share a title: a page is the window's only when it
# is the tab the window shows, in a window of the window's size, and never just
# the first page DevTools lists.
twins=$(python3 - "$ROOT/bin/omarchy-agent-seat-ui" "$cdp_port" "$test_dir/pages.json" <<'EOF'
import importlib.machinery, importlib.util, json, sys
loader = importlib.machinery.SourceFileLoader("seat_ui", sys.argv[1])
spec = importlib.util.spec_from_loader("seat_ui", loader)
ui = importlib.util.module_from_spec(spec)
loader.exec_module(ui)

def pick(pages, size):
  with open(sys.argv[3], "w") as pages_file:
    json.dump(pages, pages_file)
  try:
    return (ui.cdp_target(int(sys.argv[2]), "Twin - Chromium", size) or {}).get("webSocketDebuggerUrl", "none")
  except Exception as error:
    return f"refused: {error}"

print(json.dumps({
  "tabs": pick([{"id": "3", "title": "Twin", "visible": False, "window": [800, 600]}, {"id": "4", "title": "Twin", "visible": True, "window": [800, 600]}], [800, 600]),
  "windows": pick([{"id": "3", "title": "Twin", "visible": True, "window": [800, 600]}, {"id": "4", "title": "Twin", "visible": True, "window": [800, 600]}], [800, 600]),
  "sized": pick([{"id": "3", "title": "Twin", "visible": True, "window": [400, 600]}, {"id": "4", "title": "Twin", "visible": True, "window": [800, 600]}], [800, 600]),
  "hidden": pick([{"id": "3", "title": "Other", "visible": True, "window": [800, 600]}, {"id": "4", "title": "Twin", "visible": False, "window": [800, 600]}], [800, 600]),
  "busy": pick([{"id": "3", "title": "Twin", "visible": True, "busy": True, "window": [800, 600]}, {"id": "4", "title": "Twin", "visible": True, "window": [800, 600]}], [800, 600]),
  "busy_elsewhere": pick([{"id": "3", "title": "Twin", "visible": True, "busy": True, "window": [400, 600]}, {"id": "4", "title": "Twin", "visible": True, "window": [800, 600]}], [800, 600]),
}))
EOF
) || fail "ui picks between pages of the same title" "$twins"

[[ $(jq -r '.tabs' <<<"$twins") == */devtools/page/4 ]] || fail "the DevTools route reads the shown tab of several with the window's title" "$twins"
[[ $(jq -r '.sized' <<<"$twins") == */devtools/page/4 ]] || fail "the DevTools route tells shown pages apart by their window's size" "$twins"
[[ $(jq -r '.hidden' <<<"$twins") == "none" ]] || fail "the DevTools route reads no page when none with the window's title is shown" "$twins"
pass "the DevTools route reads the page the window shows, among others of the same title"
[[ $(jq -r '.windows' <<<"$twins") == "refused: 2 pages are shown in windows titled 'Twin - Chromium'"* ]] || fail "the DevTools route refuses to guess between windows showing the same title" "$twins"
jq -r '.windows' <<<"$twins" | grep -q "https://example.com/3" || fail "a refusal lists the pages it could not tell apart" "$twins"
pass "the DevTools route refuses to guess between windows showing the same title, and lists them"
# A page too busy to say whether it is shown may be the one the window shows:
# it is no reason to read the other.
busy=$(jq -r '.busy' <<<"$twins")
[[ $busy == "refused: 2 pages are shown in windows titled 'Twin - Chromium'"* ]] && grep -q "^1\. Twin — https://example.com/3 (did not say whether it is shown)$" <<<"$busy" && grep -q "^2\. Twin — https://example.com/4$" <<<"$busy" || fail "the DevTools route refuses rather than skip a page that does not answer" "$twins"
[[ $(jq -r '.busy_elsewhere' <<<"$twins") == */devtools/page/4 ]] || fail "the DevTools route tells a page that does not answer apart by its window's size" "$twins"
pass "the DevTools route keeps a page that does not answer as a candidate, and lists it"

# --page picks one of the pages a refusal numbers, in the order of their target
# ids rather than the order DevTools lists them in, by its number or by part of
# its URL.
picked=$(python3 - "$ROOT/bin/omarchy-agent-seat-ui" "$cdp_port" "$test_dir/pages.json" <<'EOF'
import importlib.machinery, importlib.util, json, sys
loader = importlib.machinery.SourceFileLoader("seat_ui", sys.argv[1])
spec = importlib.util.spec_from_loader("seat_ui", loader)
ui = importlib.util.module_from_spec(spec)
loader.exec_module(ui)

twins = [{"id": "7", "title": "Twin", "visible": True, "window": [800, 600]}, {"id": "5", "title": "Twin", "visible": True, "window": [800, 600]}]

def pick(pages, page):
  with open(sys.argv[3], "w") as pages_file:
    json.dump(pages, pages_file)
  try:
    return (ui.cdp_target(int(sys.argv[2]), "Twin - Chromium", [800, 600], page) or {}).get("webSocketDebuggerUrl", "none")
  except ui.Ambiguous as error:
    return f"refused: {error}"

print(json.dumps({
  "refused": pick(twins, None),
  "number": pick(twins, "2"),
  "url": pick(twins, "COM/5"),
  "nowhere": pick(twins, "nowhere"),
  "outside": pick(twins, "5"),
  "single": pick(twins[:1], "1"),
}))
EOF
) || fail "ui picks a page with --page" "$picked"

refusal=$(jq -r '.refused' <<<"$picked")
[[ $(sed -n 2,3p <<<"$refusal") == $'1. Twin — https://example.com/5\n2. Twin — https://example.com/7' ]] || fail "a refusal numbers the pages by their target ids" "$refusal"
[[ $(tail -n 1 <<<"$refusal") == "Rerun with --page N to pick one (its number above, or part of its URL)." ]] || fail "a refusal ends by saying how to pick a page" "$refusal"
pass "a refusal numbers the pages by their target ids and says how to pick one"
[[ $(jq -r '.number' <<<"$picked") == */devtools/page/7 ]] || fail "--page picks a page by its number" "$picked"
pass "--page picks a page by its number"
[[ $(jq -r '.url' <<<"$picked") == */devtools/page/5 ]] || fail "--page picks a page by part of its URL, in any case" "$picked"
pass "--page picks a page by part of its URL, in any case"
nowhere=$(jq -r '.nowhere' <<<"$picked")
[[ $nowhere == "refused: --page 'nowhere' matches none"* ]] && grep -q "^1\. Twin — https://example.com/5$" <<<"$nowhere" && grep -q "^2\. Twin — https://example.com/7$" <<<"$nowhere" || fail "--page matching no page refuses and lists the pages" "$nowhere"
pass "--page matching no page refuses and lists the pages"
# 5 is in a page's URL, but a number only ever counts in the list.
outside=$(jq -r '.outside' <<<"$picked")
[[ $outside == "refused: --page 5: there are only 2 pages"* ]] && grep -q "^2\. Twin — https://example.com/7$" <<<"$outside" || fail "a --page number outside the list refuses and lists the pages" "$outside"
pass "a --page number outside the list refuses and lists the pages, even when a URL holds it"
[[ $(jq -r '.single' <<<"$picked") == */devtools/page/7 ]] || fail "--page 1 reads the only page" "$picked"
pass "--page 1 reads the only page shown"

# DevTools tells a page's size but not where it sits in its window. A page as
# wide as its 800x600 window, here under a 100 pixel toolbar, sits at its
# bottom; beside a side panel, or above docked DevTools, ui lists it as
# unverified and click-ui refuses to click there. An undocked DevTools, or a
# frame of it the size of the page, changes nothing.
cat >"$test_dir/placed.py" <<EOF
import importlib.machinery, importlib.util, json, os, sys
loader = importlib.machinery.SourceFileLoader("seat_ui", "$ROOT/bin/omarchy-agent-seat-ui")
spec = importlib.util.spec_from_loader("seat_ui", loader)
ui = importlib.util.module_from_spec(spec)
loader.exec_module(ui)
ui.window_state = lambda window: {"window": window, "title": "Fake page - Chromium", "pid": 1, "drawn": True, "geometry": [0, 0, 800, 600], "origin": [0, 0, 1.5], "scale": 1.5, **json.loads(os.environ.get("PLACED_STATE", "{}"))}
ui.sandbox_of = lambda pid: "$test_dir/placed"
ui.main(sys.argv[1:])
EOF
mkdir -p "$test_dir/placed/bin"
echo "$cdp_port" >"$test_dir/placed/cdp-port"
printf '#!/bin/bash\nexec python3 "%s" "$@"\n' "$test_dir/placed.py" >"$test_dir/placed/bin/omarchy-agent-seat-ui"
printf '#!/bin/bash\necho "$*" >"%s"\n' "$test_dir/placed/pointer.args" >"$test_dir/placed/bin/omarchy-agent-seat-pointer"
chmod +x "$test_dir/placed/bin/"*

place() {
  echo "$1" >"$test_dir/pages.json"
  rm -f "$test_dir/placed/pointer.args"
  listed=$(PATH="$test_dir/placed/bin:$ROOT/bin:$PATH" omarchy-agent-seat-ui 3 2>&1)
  clicked=$(PATH="$test_dir/placed/bin:$ROOT/bin:$PATH" omarchy-agent-seat-click-ui 3 Send 2>&1)
}

undocked='{"id": "8", "title": "DevTools", "url": "devtools://devtools/bundled/devtools_app.html", "visible": true, "window": [800, 400], "inner": [800, 400]}'
frame='{"id": "9", "title": "", "url": "devtools://devtools/bundled/device_mode_emulation_frame.html", "visible": true, "window": null, "outer": [800, 600], "inner": [800, 500]}'
place '[{"id": "1", "title": "Fake page", "visible": true, "window": [800, 600], "inner": [800, 500]}, '"$undocked, $frame"']'
[[ $clicked == "Clicked button \"Send\" at 90,210" && $(<"$test_dir/placed/pointer.args") == "3 click 90 210" ]] && ! grep -q "guess" <<<"$listed" || fail "click-ui clicks a page under its browser's toolbar where it is" "$listed / $clicked"
pass "click-ui clicks a page under its browser's toolbar where it is"

place '[{"id": "1", "title": "Fake page", "visible": true, "window": [800, 600], "inner": [500, 500]}]'
[[ $clicked == "Not clicking Send in window 3: the page is narrower than its window, beside a side panel or docked DevTools, so where its controls are is a guess."* && ! -e $test_dir/placed/pointer.args ]] || fail "click-ui refuses to click a page beside a side panel" "$clicked"
grep -q "^Window 3: the page is narrower than its window, beside a side panel or docked DevTools, so where the page sits in the window, and the positions below, are a guess" <<<"$listed" && grep -q '^  button "Send"' <<<"$listed" || fail "ui lists a page beside a side panel, warning that its positions are a guess" "$listed"
pass "ui lists a page beside a side panel with a warning, and click-ui refuses to click it"

docked='{"id": "8", "title": "DevTools", "url": "devtools://devtools/bundled/devtools_app.html", "visible": true, "window": null, "outer": [800, 600], "inner": [800, 500]}'
place '[{"id": "1", "title": "Fake page", "visible": true, "window": [800, 600], "inner": [800, 350]}, '"$docked"']'
[[ $clicked == "Not clicking Send in window 3: DevTools is docked below the page"* && ! -e $test_dir/placed/pointer.args ]] || fail "click-ui refuses to click a page above docked DevTools" "$clicked"
pass "click-ui refuses to click a page above docked DevTools"

# A window moved to a monitor of scale 2 since its last screenshot, taken at
# scale 1: the page's devicePixelRatio of 2 is the window's scale now, so its
# CSS pixels are logical ones, placed in the screenshot's pixels at scale 1. It
# is as wide as its window, not narrower.
export PLACED_STATE='{"scale": 2, "origin": [0, 0, 1]}'
place '[{"id": "1", "title": "Fake page", "visible": true, "window": [800, 600], "inner": [800, 500], "ratio": 2}]'
found=$(PATH="$test_dir/placed/bin:$ROOT/bin:$PATH" omarchy-agent-seat-ui 3 --find Send 2>&1)
unset PLACED_STATE
[[ $clicked == "Clicked button \"Send\" at 60,140" && $(<"$test_dir/placed/pointer.args") == "3 click 60 140" && $found == 'button "Send" @60,140' ]] && ! grep -q "guess" <<<"$listed" || fail "click-ui clicks a page whose window changed scale since its last screenshot" "$listed / $found / $clicked"
pass "click-ui clicks a page whose window changed scale since its last screenshot, where it is in that screenshot"

# click-ui acts only on a control's full name, in any case: one that merely
# contains the query is listed for the caller to name in full.
echo '[{"id": "1", "title": "Fake page", "visible": true, "window": [800, 600], "inner": [800, 500]}]' >"$test_dir/pages.json"
rm -f "$test_dir/placed/pointer.args"
partial=$(PATH="$test_dir/placed/bin:$ROOT/bin:$PATH" omarchy-agent-seat-click-ui 3 Sen 2>&1)
(( $? == 1 )) && [[ ! -e $test_dir/placed/pointer.args ]] && grep -q "^No control is named 'Sen' in window 3" <<<"$partial" && grep -q '^  button "Send" @' <<<"$partial" || fail "click-ui refuses a partial name and lists the control it is part of" "$partial"
found=$(PATH="$test_dir/placed/bin:$ROOT/bin:$PATH" omarchy-agent-seat-ui 3 --find Sen 2>&1)
[[ $found == 'button "Send" @'* ]] || fail "ui --find still reads a control by part of its name" "$found"
clicked=$(PATH="$test_dir/placed/bin:$ROOT/bin:$PATH" omarchy-agent-seat-click-ui 3 sEND 2>&1)
[[ $clicked == "Clicked button \"Send\" at 90,210" && $(<"$test_dir/placed/pointer.args") == "3 click 90 210" ]] || fail "click-ui clicks a full name in any case" "$clicked"
pass "click-ui clicks only a full name, in any case, and lists a partial one as a candidate"

# A sticky header or a dialog on top of a control would take the click: ui
# asks the page what is at the control's centre, and click-ui refuses when it
# is not the control or something inside it.
echo '[{"id": "1", "title": "Fake page", "visible": true, "window": [800, 600], "inner": [800, 500], "cover": 5}]' >"$test_dir/pages.json"
rm -f "$test_dir/placed/pointer.args"
clicked=$(PATH="$test_dir/placed/bin:$ROOT/bin:$PATH" omarchy-agent-seat-click-ui 3 Send 2>&1)
(( $? == 1 )) && [[ $clicked == "Not clicking Send in window 3: another element, <a#n5>, is on top of it at its centre."* && ! -e $test_dir/placed/pointer.args ]] || fail "click-ui refuses a control another element covers" "$clicked"
listed=$(PATH="$test_dir/placed/bin:$ROOT/bin:$PATH" omarchy-agent-seat-ui 3 --find Send 2>&1)
grep -q "^Window 3: another element, <a#n5>, is on top of it at its centre" <<<"$listed" && grep -q '^button "Send" @90,210$' <<<"$listed" || fail "ui --find says another element covers a control" "$listed"
pass "click-ui refuses a control another element covers, and ui --find says so"

# An overflow container a transform scales to twice its size shows twice its
# client width: a button in the second half of it shows, and ui places it
# there. Headless Chromium runs ui's own clip on such a page.
if command -v chromium >/dev/null; then
  mkdir -p "$test_dir/scaled"
  scaled=$(python3 - "$ROOT/bin/omarchy-agent-seat-ui" "$test_dir/scaled" <<'EOF'
import importlib.machinery, importlib.util, re, subprocess, sys
loader = importlib.machinery.SourceFileLoader("seat_ui", sys.argv[1])
spec = importlib.util.spec_from_loader("seat_ui", loader)
ui = importlib.util.module_from_spec(spec)
loader.exec_module(ui)
with open(f"{sys.argv[2]}/page.html", "w") as page:
  page.write(f"""<!doctype html><body style="margin: 0">
<div style="position: absolute; left: 10px; top: 10px; width: 100px; height: 50px; overflow: hidden; transform: scale(2); transform-origin: 0 0">
<button id="zoomed" style="position: absolute; left: 60px; top: 5px; width: 30px; height: 20px">Zoomed</button></div>
<pre id="clip"></pre><script>document.getElementById("clip").textContent = JSON.stringify(({ui.CLIP}).call(document.getElementById("zoomed")));</script>""")
dom = subprocess.run(["timeout", "30", "chromium", "--headless", "--disable-gpu", "--no-first-run", f"--user-data-dir={sys.argv[2]}/profile", "--dump-dom", f"file://{sys.argv[2]}/page.html"], capture_output=True, text=True).stdout
print((re.search(r'<pre id="clip">([^<]*)</pre>', dom) or [None, ""])[1])
EOF
  )
  # The button shows at 130,20 to 190,60, the container at 10,10 to 210,110.
  [[ $scaled == "[130,20,10,10,210,110]" ]] || fail "ui's clip scales an overflow container's client size by its transform" "$scaled"
  zoomed='{"nodeId": "8", "parentId": "1", "ignored": false, "role": {"value": "button"}, "name": {"value": "Zoomed"}, "childIds": [], "backendDOMNodeId": 8}'
  place '[{"id": "1", "title": "Fake page", "visible": true, "window": [800, 600], "inner": [800, 500], "nodes": ['"$zoomed"'], "boxes": {"8": [130, 20, 60, 40]}, "clips": {"8": '"$scaled"'}}]'
  found=$(PATH="$test_dir/placed/bin:$ROOT/bin:$PATH" omarchy-agent-seat-ui 3 --find Zoomed 2>&1)
  grep -q '^  button "Zoomed" @240,210$' <<<"$listed" && [[ $found == 'button "Zoomed" @240,210' ]] || fail "ui lists and finds a control in the scaled-up part of an overflow container" "$scaled / $listed / $found"
  pass "ui lists and finds a control in the part of an overflow container a transform scales up"
else
  skip "no Chromium; skipping the clip of a scaled overflow container"
fi

# click-ui hands --page to ui and the rest to the pointer.
mkdir -p "$test_dir/stubs"
cat >"$test_dir/stubs/omarchy-agent-seat-ui" <<EOF
#!/bin/bash
echo "\$*" >"$test_dir/stubs/ui.args"
echo '{"role": "button", "name": "Send", "x": 1, "y": 2}'
EOF
cat >"$test_dir/stubs/omarchy-agent-seat-pointer" <<EOF
#!/bin/bash
echo "\$*" >"$test_dir/stubs/pointer.args"
EOF
chmod +x "$test_dir/stubs/omarchy-agent-seat-ui" "$test_dir/stubs/omarchy-agent-seat-pointer"
clicked=$(PATH="$test_dir/stubs:$ROOT/bin:$PATH" omarchy-agent-seat-click-ui 3 Send --page 2 --double 2>&1) || fail "click-ui runs with --page" "$clicked"
[[ $(<"$test_dir/stubs/ui.args") == "3 --find Send --exact --json --page 2" ]] || fail "click-ui hands --page to ui" "$(<"$test_dir/stubs/ui.args")"
[[ $(<"$test_dir/stubs/pointer.args") == "3 click 1 2 --double" ]] || fail "click-ui keeps --page from the pointer" "$(<"$test_dir/stubs/pointer.args")"
pass "click-ui hands --page to ui and the other options to the pointer"

# Stopping ----------------------------------------------------------------------------

seat omarchy-agent-seat-stop >/dev/null
for _ in {1..50}; do kill -0 "$broker_pid" 2>/dev/null || break; sleep 0.1; done
compgen -G "$runtime/omarchy/agent-seat/sandboxes/*.d" >/dev/null && fail "stop removes the private buses" "$(ls -la "$runtime/omarchy/agent-seat/sandboxes")"
pgrep -f "dbus-daemon --config-file=$runtime/omarchy/agent-seat/sandboxes/" >/dev/null && fail "stop ends the private bus daemons"
pass "stop ends the private buses with their sandboxes"
