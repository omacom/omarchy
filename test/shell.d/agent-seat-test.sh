#!/bin/bash

source "$(dirname "$0")/base-test.sh"

# The seat commands find their sandbox supervisor under $OMARCHY_PATH.
export OMARCHY_PATH="$ROOT"

require_command python3
require_command jq
require_command xkbcli

test_dir=$(mktemp -d)
mkdir -p "$test_dir/bin" "$test_dir/runtime" "$test_dir/home"

# Everything the suite launches gets a home of its own; the user's seat home
# and state must come out of it untouched. Only their top level is compared:
# the user's own seat apps write inside them at any time.
real_seat_dirs() {
  find "$HOME/.local/share/omarchy/agent-seat" "$HOME/.local/state/omarchy/agent-seat" -maxdepth 1 -printf '%i %p\n' 2>/dev/null | sort
}
real_seat_before=$(real_seat_dirs)

cleanup() {
  [[ -n ${silent_pid:-} ]] && kill "$silent_pid" 2>/dev/null
  HOME="$test_dir/home" XDG_RUNTIME_DIR="$test_dir/runtime" PATH="$test_dir/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-agent-seat-stop" >/dev/null 2>&1 || true
  # The broker runs under a subshell of run_broker, so end it by parent too.
  [[ -n ${broker_pid:-} ]] && pkill -P "$broker_pid" 2>/dev/null && kill "$broker_pid" 2>/dev/null
  [[ -n ${compositor_pid:-} ]] && kill "$compositor_pid" 2>/dev/null
  rm -rf "$test_dir"
}
trap cleanup EXIT

# The broker asks Hyprland where agent windows are; there is no Hyprland here.
# A test can make it slow to answer.
printf '#!/bin/bash\n[[ -f %s/hyprctl-delay ]] && sleep "$(<%s/hyprctl-delay)"\necho "[]"\n' "$test_dir" "$test_dir" >"$test_dir/bin/hyprctl"
chmod +x "$test_dir/bin/hyprctl"

cat >"$test_dir/wire.py" <<'EOF'
import array, socket, struct

def string(text):
    data = text.encode() + b"\0"
    return struct.pack("<I", len(data)) + data + b"\0" * (-len(data) % 4)

def message(object_id, opcode, body=b""):
    return struct.pack("<II", object_id, (8 + len(body)) << 16 | opcode) + body

def read_string(body, offset=0):
    length = struct.unpack_from("<I", body, offset)[0]
    return body[offset + 4 : offset + 3 + length].decode()

class Connection:
    def __init__(self, sock):
        self.sock, self.buffer, self.fds = sock, b"", []

    def send(self, data):
        self.sock.sendall(data)

    def read(self, timeout=2):
        """Next message as (object id, opcode, body), or None when the peer hangs up."""
        self.sock.settimeout(timeout)
        while len(self.buffer) < 8 or len(self.buffer) < struct.unpack_from("<II", self.buffer)[1] >> 16:
            data, ancillary, _, _ = self.sock.recvmsg(65536, socket.CMSG_SPACE(4 * 28))
            if not data:
                return None
            for _, _, payload in ancillary:
                fds = array.array("i")
                fds.frombytes(payload[: len(payload) - len(payload) % 4])
                self.fds.extend(fds)
            self.buffer += data
        object_id, word = struct.unpack_from("<II", self.buffer)
        size = word >> 16
        body, self.buffer = self.buffer[8:size], self.buffer[size:]
        return object_id, word & 0xFFFF, body
EOF

# A fake Hyprland: advertises a seat, a compositor, shared memory, subsurfaces,
# xdg_wm_base, the data device manager, and a virtual pointer manager and GPU
# buffers the broker must hide, answers wl_display.sync, plays a user pointer entering every surface
# it can, and logs what reaches it. Each connection gets its own thread, so apps
# can stay connected side by side.
cat >"$test_dir/compositor.py" <<'EOF'
import array, os, socket, struct, subprocess, sys, threading, time
sys.path.insert(0, os.path.dirname(__file__))
from wire import Connection, message, string, read_string

path, log = sys.argv[1], open(sys.argv[2], "a", buffering=1)
server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
server.bind(path)
server.listen(64)

GLOBALS = {1: ("wl_seat", 9), 2: ("wl_compositor", 99), 3: ("xdg_wm_base", 6), 4: ("wl_data_device_manager", 3), 5: ("zwlr_virtual_pointer_manager_v1", 2), 6: ("zwp_linux_dmabuf_v1", 5), 7: ("wl_shm", 1), 8: ("wl_subcompositor", 1)}
SLOW_SYNC = 999  # a sync with this callback is answered late, for tests that need an event in flight
POPUP = (30, 25, 20, 10)  # where every popup opens, relative to its parent

def serve(conn):
    objects = {1: "wl_display"}
    keyboard = surface = None
    while (msg := conn.read(timeout=None)) is not None:
        object_id, opcode, body = msg
        kind = objects.get(object_id, "?")
        if kind == "wl_display" and opcode == 1:
            registry = struct.unpack("<I", body)[0]
            objects[registry] = "wl_registry"
            for name, (interface, version) in GLOBALS.items():
                conn.send(message(registry, 0, struct.pack("<I", name) + string(interface) + struct.pack("<I", version)))
        elif kind == "wl_display" and opcode == 0:
            callback = struct.unpack("<I", body)[0]
            if callback == SLOW_SYNC:
                time.sleep(0.5)
            conn.send(message(callback, 0, struct.pack("<I", 0)) + message(1, 1, struct.pack("<I", callback)))
        elif kind == "wl_registry":
            name = struct.unpack_from("<I", body)[0]
            interface = read_string(body, 4)
            new_id = struct.unpack_from("<I", body, len(body) - 4)[0]
            objects[new_id] = interface
            log.write(f"bind {interface}\n")
            if interface == "wl_seat":
                conn.send(message(new_id, 0, struct.pack("<I", 7)) + message(new_id, 1, string("seat0")))
        elif kind == "wl_seat" and opcode == 0:
            pointer = struct.unpack("<I", body)[0]
            objects[pointer] = "wl_pointer"
            # The user's pointer arrives: this must never reach an agent app.
            conn.send(message(pointer, 2, struct.pack("<Iii", 0, 256, 256)))
        elif kind == "wl_seat" and opcode == 1:
            keyboard = struct.unpack("<I", body)[0]
            objects[keyboard] = "wl_keyboard"
            keymap = subprocess.run(["xkbcli", "compile-keymap", "--layout", "us"], capture_output=True).stdout + b"\0"
            fd = os.memfd_create("keymap")
            os.write(fd, keymap)
            conn.sock.sendmsg([message(keyboard, 0, struct.pack("<II", 1, len(keymap)))], [(socket.SOL_SOCKET, socket.SCM_RIGHTS, array.array("i", [fd]))])
            os.close(fd)
        elif kind == "wl_compositor" and opcode == 0:
            surface = struct.unpack("<I", body)[0]
            objects[surface] = "wl_surface"
        elif kind in ("wl_surface", "wl_subsurface") and opcode == 0:
            conn.send(message(1, 1, struct.pack("<I", object_id)))  # destroyed: the id is free again
        elif kind == "wl_shm" and opcode == 0:
            objects[struct.unpack_from("<I", body)[0]] = "wl_shm_pool"
            os.close(conn.fds.pop(0))
        elif kind == "wl_subcompositor" and opcode == 1:
            objects[struct.unpack_from("<I", body)[0]] = "wl_subsurface"
        elif kind == "xdg_wm_base" and opcode == 2:
            objects[struct.unpack_from("<I", body)[0]] = "xdg_surface"
        elif kind == "xdg_surface" and opcode == 1:
            objects[struct.unpack("<I", body)[0]] = "xdg_toplevel"
        elif kind == "xdg_surface" and opcode == 2:
            popup = struct.unpack_from("<I", body)[0]
            objects[popup] = "xdg_popup"
            conn.send(message(popup, 0, struct.pack("<iiii", *POPUP)))
        elif kind == "xdg_toplevel" and opcode == 3:
            app_id = read_string(body)
            log.write(f"app_id {app_id}\n")
            if "." in app_id and keyboard:
                # The user clicks into the agent window and presses a key.
                conn.send(message(keyboard, 1, struct.pack("<II", 900, surface) + struct.pack("<I", 0)))
                conn.send(message(keyboard, 3, struct.pack("<IIII", 901, 0, 30, 1)) + message(keyboard, 3, struct.pack("<IIII", 902, 0, 30, 0)))
        elif kind == "wl_data_device_manager" and opcode == 0:
            objects[struct.unpack("<I", body)[0]] = "wl_data_source"
        elif kind == "wl_data_device_manager" and opcode == 1:
            device = struct.unpack_from("<I", body)[0]
            objects[device] = "wl_data_device"
            log.write("get_data_device\n")
            # The user has something copied: offer it to the focused app.
            objects[0xFF000001] = "wl_data_offer"
            conn.send(message(device, 0, struct.pack("<I", 0xFF000001)) + message(0xFF000001, 0, string("text/plain")) + message(device, 5, struct.pack("<I", 0xFF000001)))
        elif kind == "wl_data_offer" and opcode == 1:
            log.write("receive\n")
            fd = conn.fds.pop(0)
            os.write(fd, b"clipboard-text")
            os.close(fd)
        elif kind == "wl_data_device" and opcode == 1:
            log.write(f"set_selection {struct.unpack_from('<I', body, 4)[0]}\n")

def run(sock):
    conn = Connection(sock)
    try:
        serve(conn)
    except OSError:
        pass  # the broker dropped this app
    for fd in conn.fds:
        os.close(fd)
    sock.close()

while True:
    threading.Thread(target=run, args=(server.accept()[0],), daemon=True).start()
EOF

# The agent app: connects through the broker and reports what it sees.
cat >"$test_dir/app.py" <<'EOF'
import array, os, select, socket, struct, sys
sys.path.insert(0, os.path.dirname(__file__))
from wire import Connection, message, string, read_string

sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.connect(sys.argv[1])
conn = Connection(sock)
step = sys.argv[2]

def roundtrip(callback):
    conn.send(message(1, 0, struct.pack("<I", callback)))
    events = []
    while (msg := conn.read()) is not None and msg[0] != callback:
        events.append(msg)
    return events

conn.send(message(1, 1, struct.pack("<I", 2)))
globals_ = {}
versions = {}
for object_id, opcode, body in roundtrip(3):
    if object_id == 2 and opcode == 0:
        globals_[read_string(body, 4)] = struct.unpack_from("<I", body)[0]
        versions[read_string(body, 4)] = struct.unpack_from("<I", body, len(body) - 4)[0]

def bind(interface, version, new_id):
    conn.send(message(2, 0, struct.pack("<I", globals_[interface]) + string(interface) + struct.pack("<II", version, new_id)))

if step == "globals":
    print(" ".join(sorted(globals_)))

elif step == "versions":
    print(" ".join(f"{name}:{version}" for name, version in sorted(versions.items())))

elif step == "hidden":
    hidden = next(name for name in range(1, 50) if name not in globals_.values())
    conn.send(message(2, 0, struct.pack("<I", hidden) + string("zwlr_virtual_pointer_manager_v1") + struct.pack("<II", 1, 4)))
    try:
        while conn.read() is not None:
            pass
        print("disconnected")
    except ConnectionResetError:
        print("disconnected")
    except socket.timeout:
        print("connected")

elif step == "vanish":
    # Hang up while Hyprland's answer to this app is on its way, so the broker
    # finds both of the app's sockets ready at once.
    import signal, time
    broker = int(sys.argv[3])
    conn.send(message(1, 0, struct.pack("<I", 999)))  # answered late
    time.sleep(0.2)
    os.kill(broker, signal.SIGSTOP)
    try:
        time.sleep(0.8)
        sock.close()
    finally:
        os.kill(broker, signal.SIGCONT)

elif step in ("fdflood", "poolflood"):
    # Fill the broker's descriptor table: one message with as many
    # descriptors as the kernel allows, or more pools than an app needs.
    try:
        if step == "fdflood":
            fds = [os.open("/dev/null", os.O_RDONLY) for _ in range(253)]
            conn.sock.sendmsg([message(1, 0, struct.pack("<I", 4))], [(socket.SOL_SOCKET, socket.SCM_RIGHTS, array.array("i", fds))])
        else:
            bind("wl_shm", 1, 4)
            memory = os.memfd_create("pool")
            os.ftruncate(memory, 4096)
            for start in range(100, 400, 28):
                data = b"".join(message(4, 0, struct.pack("<Ii", pool, 4096)) for pool in range(start, start + 28))
                conn.sock.sendmsg([data], [(socket.SOL_SOCKET, socket.SCM_RIGHTS, array.array("i", [memory] * 28))])
        conn.send(message(1, 0, struct.pack("<I", 5)))
        while (msg := conn.read()) is not None and msg[0] != 5:
            pass
        print("disconnected" if msg is None else "connected")
    except OSError:
        print("disconnected")

elif step == "truncated":
    # A shared memory pool with its descriptor and new id but no size.
    bind("wl_shm", 1, 4)
    memory = os.memfd_create("truncated")
    try:
        conn.sock.sendmsg([message(4, 0, struct.pack("<I", 100))], [(socket.SOL_SOCKET, socket.SCM_RIGHTS, array.array("i", [memory]))])
        conn.send(message(1, 0, struct.pack("<I", 5)))
        while (msg := conn.read()) is not None and msg[0] != 5:
            pass
        print("disconnected" if msg is None else "connected")
    except OSError:
        print("disconnected")

elif step == "syncflood":
    # Ask for replies as fast as possible and never read one.
    import time
    conn.sock.settimeout(0.5)
    sent, callback = 0, 3
    try:
        while sent < 16 << 20:
            syncs = b"".join(message(1, 0, struct.pack("<I", callback + i)) for i in range(1000))
            conn.sock.sendall(syncs)
            sent, callback = sent + len(syncs), callback + 1000
        print("never blocked", flush=True)
    except socket.timeout:
        print("blocked", flush=True)
    time.sleep(0.5)

elif step == "thief":
    # Set the clipboard with serials of the user's input to another app.
    bind("wl_seat", 7, 4)
    bind("wl_data_device_manager", 3, 5)
    conn.send(message(5, 1, struct.pack("<II", 6, 4)))  # data device
    conn.send(message(5, 0, struct.pack("<I", 7)))  # data source
    for serial in (900, 901, 902):
        conn.send(message(6, 1, struct.pack("<II", 7, serial)))
    roundtrip(8)

elif step == "latency":
    # Round trips through the broker for two seconds: the slowest, in ms.
    # Callbacks start past the one the compositor answers late.
    import time
    print("ready", flush=True)
    slowest, callback, until = 0, 1000, time.monotonic() + 2
    while time.monotonic() < until:
        start = time.monotonic()
        conn.send(message(1, 0, struct.pack("<I", callback)))
        while conn.read(timeout=30)[0] != callback:
            pass
        slowest, callback = max(slowest, time.monotonic() - start), callback + 1
    print(round(slowest * 1000), flush=True)

elif step == "seat":
    bind("wl_seat", 7, 4)
    for object_id, opcode, body in roundtrip(5):
        if object_id == 4 and opcode == 0:
            print("capabilities", struct.unpack("<I", body)[0])
        if object_id == 4 and opcode == 1:
            print("name", read_string(body))
    conn.send(message(4, 1, struct.pack("<I", 7)))
    for object_id, opcode, body in roundtrip(8):
        if object_id == 7 and opcode == 0:
            print("keymap with fd" if conn.fds else "keymap without fd")

elif step == "window":
    bind("wl_seat", 7, 4)
    bind("wl_compositor", 6, 5)
    bind("xdg_wm_base", 6, 6)
    bind("wl_data_device_manager", 3, 7)
    conn.send(message(4, 1, struct.pack("<I", 8)))  # keyboard
    conn.send(message(5, 0, struct.pack("<I", 9)))  # surface
    conn.send(message(6, 2, struct.pack("<II", 10, 9)))  # xdg_surface
    conn.send(message(10, 1, struct.pack("<I", 11)))  # toplevel
    conn.send(message(11, 3, string("foot")))  # set_app_id
    conn.send(message(7, 1, struct.pack("<II", 12, 4)))  # data device
    conn.send(message(7, 0, struct.pack("<I", 20)))  # data source, for copying
    early = roundtrip(13)
    print("ready", flush=True)
    focused, keys, offer, pending = False, [], None, []

    # Pastes the offered clipboard and copies, as the app would on the last
    # key it saw, and reports what came back.
    def paste_and_copy(serial):
        read, write = os.pipe()
        conn.sock.sendmsg([message(offer, 1, string("text/plain"))], [(socket.SOL_SOCKET, socket.SCM_RIGHTS, array.array("i", [write]))])
        os.close(write)
        data = os.read(read, 100) if select.select([read], [], [], 2)[0] else b"timeout"
        os.close(read)
        conn.send(message(12, 1, struct.pack("<II", 20, serial)))
        print(f"pasted:{data.decode()}", flush=True)

    # The app runs until the test has nothing more for it: the broker going
    # quiet for a while ends it as cleanly as the broker hanging up.
    def events():
        yield from early
        try:
            while (msg := conn.read(timeout=5)) is not None:
                yield msg
        except TimeoutError:
            return

    for object_id, opcode, body in events():
        if object_id == 8 and opcode == 1:
            focused = True
        elif object_id == 8 and opcode == 2:
            focused = False
        elif object_id == 8 and opcode == 3:
            serial, _, key, state = struct.unpack("<IIII", body)
            keys.append((serial < 0x40000000, key, state, focused))
            if len(keys) in (2, 4):
                print(" ".join(f"{'user' if user else 'agent'}:{key}:{state}:{'focused' if focus else 'unfocused'}" for user, key, state, focus in keys[-2:]), flush=True)
                pending.append(serial)
        elif object_id == 12 and opcode == 5:
            offer = struct.unpack("<I", body)[0]
        while pending and offer:
            paste_and_copy(pending.pop(0))
EOF

# An agent app that draws: a window with a subsurface and a popup in shared
# memory, or one large window whose pool keeps shrinking and growing under the
# broker. It prints the agent pointer's events and takes commands on stdin.
cat >"$test_dir/draw.py" <<'EOF'
import array, os, select, socket, struct, sys, threading
sys.path.insert(0, os.path.dirname(__file__))
from wire import Connection, message, string, read_string

SEAT, COMPOSITOR, SHM, WM, SUBCOMPOSITOR, POINTER, POOL = 4, 5, 6, 7, 8, 9, 10
ROOT, CHILD, POPUP_SURFACE, XDG, TOPLEVEL, SUBSURFACE, REGION, POSITIONER, POPUP_XDG, POPUP = 20, 21, 22, 23, 24, 25, 26, 27, 28, 29
RED, GREEN, BLUE = b"\x00\x00\xff\xff", b"\x00\xff\x00\xff", b"\xff\x00\x00\xff"  # XRGB8888, little endian

sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.connect(sys.argv[1])
conn = Connection(sock)
scene = sys.argv[2]
callbacks = iter(range(1000, 1 << 30))
reporting = False  # until the window is up: the user's pointer passing by is not the agent's

def out(text):
    print(text, flush=True)

def fixed(body, offset):
    return f"{struct.unpack_from('<i', body, offset)[0] / 256:g}"

def report(object_id, opcode, body):
    if object_id != POINTER or not reporting:
        return
    if opcode == 0:
        out(f"enter {struct.unpack_from('<I', body, 4)[0]} {fixed(body, 8)} {fixed(body, 12)}")
    elif opcode == 1:
        out(f"leave {struct.unpack_from('<I', body, 4)[0]}")
    elif opcode == 2:
        out(f"motion {fixed(body, 4)} {fixed(body, 8)}")
    elif opcode == 3:
        out("button {2} {3}".format(*struct.unpack("<IIII", body)))
    elif opcode == 4:
        out(f"axis {struct.unpack_from('<I', body, 4)[0]} {fixed(body, 8)}")
    elif opcode == 5:
        out("frame")
    elif opcode == 8:
        out("discrete {} {}".format(*struct.unpack("<Ii", body)))

def roundtrip():
    callback = next(callbacks)
    conn.send(message(1, 0, struct.pack("<I", callback)))
    while (msg := conn.read()) is not None and msg[0] != callback:
        report(*msg)

def send_fd(data, fd):
    conn.sock.sendmsg([data], [(socket.SOL_SOCKET, socket.SCM_RIGHTS, array.array("i", [fd]))])

conn.send(message(1, 1, struct.pack("<I", 2)))
globals_ = {}
callback = next(callbacks)
conn.send(message(1, 0, struct.pack("<I", callback)))
while (msg := conn.read())[0] != callback:
    if msg[0] == 2 and msg[1] == 0:
        globals_[read_string(msg[2], 4)] = struct.unpack_from("<I", msg[2])[0]

def bind(interface, version, new_id):
    conn.send(message(2, 0, struct.pack("<I", globals_[interface]) + string(interface) + struct.pack("<II", version, new_id)))

bind("wl_seat", 7, SEAT)
bind("wl_compositor", 6, COMPOSITOR)
bind("wl_shm", 1, SHM)
bind("xdg_wm_base", 6, WM)
bind("wl_subcompositor", 1, SUBCOMPOSITOR)
conn.send(message(SEAT, 0, struct.pack("<I", POINTER)))
roundtrip()

def surface(surface_id, buffer_id, offset, width, height):
    conn.send(message(POOL, 0, struct.pack("<IiiiiI", buffer_id, offset, width, height, width * 4, 1)))
    conn.send(message(COMPOSITOR, 0, struct.pack("<I", surface_id)))
    conn.send(message(surface_id, 1, struct.pack("<Iii", buffer_id, 0, 0)))

def toplevel():
    conn.send(message(WM, 2, struct.pack("<II", XDG, ROOT)))
    conn.send(message(XDG, 1, struct.pack("<I", TOPLEVEL)))
    conn.send(message(TOPLEVEL, 3, string(scene)))

if scene == "scene":
    # A red 40x30 window taking input on its left half, a green 10x10
    # subsurface at (5, 5) and a blue 20x10 popup the compositor puts at (30, 25).
    pixels = RED * 40 * 30 + GREEN * 10 * 10 + BLUE * 20 * 10
    memory = os.memfd_create("draw")
    os.write(memory, pixels)
    send_fd(message(SHM, 0, struct.pack("<Ii", POOL, len(pixels))), memory)
    surface(ROOT, 11, 0, 40, 30)
    surface(CHILD, 12, 4800, 10, 10)
    surface(POPUP_SURFACE, 13, 5200, 20, 10)
    toplevel()
    conn.send(message(SUBCOMPOSITOR, 1, struct.pack("<III", SUBSURFACE, CHILD, ROOT)))
    conn.send(message(SUBSURFACE, 1, struct.pack("<ii", 5, 5)))
    conn.send(message(COMPOSITOR, 1, struct.pack("<I", REGION)))
    conn.send(message(REGION, 1, struct.pack("<iiii", 0, 0, 20, 30)))
    conn.send(message(ROOT, 5, struct.pack("<I", REGION)))
    conn.send(message(WM, 1, struct.pack("<I", POSITIONER)))
    conn.send(message(WM, 2, struct.pack("<II", POPUP_XDG, POPUP_SURFACE)))
    conn.send(message(POPUP_XDG, 2, struct.pack("<III", POPUP, XDG, POSITIONER)))
    for surface_id in (CHILD, POPUP_SURFACE, ROOT):
        conn.send(message(surface_id, 6))
elif scene == "glass":
    # A red 2000x2000 window under a subsurface as large, green at half
    # opacity: every pixel of its screenshot is blended.
    side = 2000
    memory = os.memfd_create("draw")
    os.write(memory, RED * side * side + b"\x00\x80\x00\x80" * side * side)
    send_fd(message(SHM, 0, struct.pack("<Ii", POOL, 2 * side * side * 4)), memory)
    surface(ROOT, 11, 0, side, side)
    conn.send(message(POOL, 0, struct.pack("<IiiiiI", 12, side * side * 4, side, side, side * 4, 0)))
    conn.send(message(COMPOSITOR, 0, struct.pack("<I", CHILD)))
    conn.send(message(CHILD, 1, struct.pack("<Iii", 12, 0, 0)))
    toplevel()
    conn.send(message(SUBCOMPOSITOR, 1, struct.pack("<III", SUBSURFACE, CHILD, ROOT)))
    conn.send(message(CHILD, 6))
    conn.send(message(ROOT, 6))
else:
    # A large window whose pool keeps shrinking and growing again.
    width, height = 2000, 1500
    memory = os.memfd_create("draw")
    os.ftruncate(memory, width * height * 4)
    send_fd(message(SHM, 0, struct.pack("<Ii", POOL, width * height * 4)), memory)
    surface(ROOT, 11, 0, width, height)
    toplevel()
    conn.send(message(ROOT, 6))

    def flicker():
        while True:
            os.ftruncate(memory, 4096)
            os.ftruncate(memory, width * height * 4)

    threading.Thread(target=flicker, daemon=True).start()

roundtrip()
reporting = True
out("ready")

while True:
    ready = select.select([sys.stdin, conn.sock], [], [])[0]
    if conn.sock in ready:
        msg = conn.read()
        if msg is None:
            out("disconnected")
            break
        report(*msg)
        while len(conn.buffer) >= 8 and len(conn.buffer) >= struct.unpack_from("<II", conn.buffer)[1] >> 16:
            report(*conn.read())
    if sys.stdin in ready:
        command = sys.stdin.readline().strip()
        if command in ("", "quit"):
            break
        if command == "unsub":
            # Destroy the subsurface, then reuse its surface's id for a
            # surface that is no part of the window.
            conn.send(message(SUBSURFACE, 0))
            conn.send(message(CHILD, 0))
            roundtrip()
            conn.send(message(COMPOSITOR, 0, struct.pack("<I", CHILD)))
            conn.send(message(CHILD, 1, struct.pack("<Iii", 12, 0, 0)))
            conn.send(message(CHILD, 6))
        if command == "geometry":
            # A window geometry far larger than anything the window draws.
            conn.send(message(XDG, 3, struct.pack("<iiii", 0, 0, 4000, 4000)))
            conn.send(message(ROOT, 6))
        roundtrip()
        out("done")
EOF

# Reads pixels of a PNG the broker wrote: its size, then each x,y as rrggbb.
cat >"$test_dir/pixels.py" <<'EOF'
import struct, sys, zlib

data = open(sys.argv[1], "rb").read()
offset, idat = 8, b""
while offset < len(data):
    length, kind = struct.unpack_from(">I4s", data, offset)
    if kind == b"IHDR":
        width, height = struct.unpack_from(">II", data, offset + 8)
    elif kind == b"IDAT":
        idat += data[offset + 8 : offset + 8 + length]
    offset += 12 + length
rows = zlib.decompress(idat)
print(f"{width}x{height}", end="")
for point in sys.argv[2:]:
    x, y = map(int, point.split(","))
    start = y * (width * 3 + 1) + 1 + x * 3
    print(" " + rows[start : start + 3].hex(), end="")
print()
EOF

# One app making as many connections as its sandbox may have, then one more,
# while another app connects, and making pools over two of its connections
# that together pass its sandbox's limit. It says what the broker did.
cat >"$test_dir/crowd.py" <<'EOF'
import array, importlib.machinery, importlib.util, os, socket, struct, subprocess, sys
sys.path.insert(0, os.path.dirname(__file__))
from wire import Connection, message, string, read_string

loader = importlib.machinery.SourceFileLoader("broker", sys.argv[2])
broker = importlib.util.module_from_spec(importlib.util.spec_from_loader(loader.name, loader))
loader.exec_module(broker)

def connect():
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect(sys.argv[1])
    return Connection(sock)

def served(conn, callback):
    """Whether the broker answers a round trip rather than hanging up."""
    try:
        conn.send(message(1, 0, struct.pack("<I", callback)))
        while (msg := conn.read()) is not None:
            if msg[0] == callback:
                return True
    except OSError:
        pass
    return False

def pools(conn, first, count):
    conn.send(message(1, 1, struct.pack("<I", 2)))
    conn.send(message(1, 0, struct.pack("<I", 3)))
    shm = None
    while (msg := conn.read())[0] != 3:
        if msg[0] == 2 and msg[1] == 0 and read_string(msg[2], 4) == "wl_shm":
            shm = struct.unpack_from("<I", msg[2])[0]
    conn.send(message(2, 0, struct.pack("<I", shm) + string("wl_shm") + struct.pack("<II", 1, 4)))
    memory = os.memfd_create("pool")
    os.ftruncate(memory, 4096)
    try:
        for start in range(first, first + count, 25):
            data = b"".join(message(4, 0, struct.pack("<Ii", pool, 4096)) for pool in range(start, start + 25))
            conn.sock.sendmsg([data], [(socket.SOL_SOCKET, socket.SCM_RIGHTS, array.array("i", [memory] * 25))])
    except OSError:
        return "dropped"
    return "kept" if served(conn, 5) else "dropped"

connections = [connect() for _ in range(broker.MAX_CLIENTS_PER_SANDBOX)]
print("served" if all(served(conn, 3) for conn in connections) else "not served")
print("refused" if not served(connect(), 3) else "served")
other = subprocess.run([sys.executable, os.path.join(os.path.dirname(__file__), "app.py"), sys.argv[1], "globals"], capture_output=True, text=True, start_new_session=True)
print("another app served" if "wl_seat" in other.stdout else "another app refused")
print(pools(connections[0], 100, 200), pools(connections[1], 100, 100))
EOF

# Starts draw.py with a scene; commands go to fd draw_in, its output comes
# from fd draw_out.
start_draw() {
  rm -f "$test_dir/draw.in" "$test_dir/draw.out"
  mkfifo "$test_dir/draw.in" "$test_dir/draw.out"
  exec {draw_in}<>"$test_dir/draw.in" {draw_out}<>"$test_dir/draw.out"
  python3 "$test_dir/draw.py" "$socket" "$1" <"$test_dir/draw.in" >"$test_dir/draw.out" 2>>"$test_dir/draw.err" &
  draw_pid=$!
  local line
  read -r -t 5 line <&"$draw_out"
  [[ $line == "ready" ]] || fail "a drawing agent app maps its window" "$line $(cat "$test_dir/draw.err")"
}

stop_draw() {
  echo quit >&"$draw_in"
  wait "$draw_pid" 2>/dev/null
  exec {draw_in}>&- {draw_out}>&-
}

draw_command() {
  local line
  echo "$1" >&"$draw_in"
  while read -r -t 5 line <&"$draw_out" && [[ $line != "done" ]]; do :; done
  [[ $line == "done" ]] || fail "the drawing app runs $1" "$line"
}

# The agent pointer's events the drawing app saw, up to the given number of
# frames, joined with semicolons.
pointer_events() {
  local frames=0 line events=() IFS=";"
  while (( frames < $1 )) && read -r -t 5 line <&"$draw_out"; do
    events+=("$line")
    [[ $line == "frame" ]] && (( frames++ ))
  done
  echo "${events[*]}"
}

window_of() {
  run_broker omarchy-agent-seat-windows | jq -r --arg app "$1" '[.[] | select(.app_id == $app)][-1].window'
}

run_broker() {
  HOME="$test_dir/home" XDG_RUNTIME_DIR="$test_dir/runtime" WAYLAND_DISPLAY=compositor PATH="$test_dir/bin:$ROOT/bin:$PATH" "$@"
}

python3 "$test_dir/compositor.py" "$test_dir/runtime/compositor" "$test_dir/compositor.log" &
compositor_pid=$!
for _ in {1..50}; do [[ -S $test_dir/runtime/compositor ]] && break; sleep 0.1; done

run_broker omarchy-agent-seat-broker serve 2>"$test_dir/broker.log" &
broker_pid=$!
socket="$test_dir/runtime/omarchy/agent-seat/wayland-0"
for _ in {1..50}; do [[ -S $socket ]] && break; sleep 0.1; done
[[ -S $socket ]] || fail "broker listens for agent apps" "$(cat "$test_dir/broker.log")"

[[ $(stat -c %a "$test_dir/runtime/omarchy/agent-seat/control") == "600" ]] || fail "control socket is private to the user"
pass "control socket is private to the user"

globals=$(python3 "$test_dir/app.py" "$socket" globals)
[[ $globals == "wl_compositor wl_data_device_manager wl_seat wl_shm wl_subcompositor xdg_wm_base" ]] || fail "only allowlisted globals are advertised" "$globals"
pass "only allowlisted globals are advertised"

versions=$(python3 "$test_dir/app.py" "$socket" versions)
[[ " $versions " == *" wl_compositor:7 "* && " $versions " == *" wl_seat:7 "* && " $versions " == *" xdg_wm_base:6 "* ]] || fail "globals are advertised no newer than the broker understands" "$versions"
pass "globals are advertised no newer than the broker understands"

hidden=$(python3 "$test_dir/app.py" "$socket" hidden 2>&1)
[[ $hidden == "disconnected" ]] || fail "binding a hidden global disconnects the app" "$hidden $(cat "$test_dir/broker.log")"
pass "binding a hidden global disconnects the app"

seat=$(python3 "$test_dir/app.py" "$socket" seat)
grep -q "capabilities 3" <<<"$seat" || fail "seat offers the agent's pointer and keyboard" "$seat"
grep -q "name agent" <<<"$seat" || fail "seat is named agent" "$seat"
pass "seat is the agent's"
grep -q "keymap with fd" <<<"$seat" || fail "agent apps get the user's keymap" "$seat"
pass "agent apps get the user's keymap"

coproc APP { python3 "$test_dir/app.py" "$socket" window; }
read -r -t 5 ready <&"${APP[0]}"
[[ $ready == "ready" ]] || fail "agent app maps a window"

grep -q "app_id agent-1.foot" "$test_dir/compositor.log" || fail "agent windows are named for Hyprland rules" "$(cat "$test_dir/compositor.log")"
pass "agent windows are named for Hyprland rules"


windows=$(run_broker omarchy-agent-seat-windows)
[[ $(jq -r '.[0].app_id' <<<"$windows") == "foot" ]] || fail "windows lists the agent window" "$windows"
pass "windows lists the agent window"

# A launcher matches a window to the sandbox it started by the app's pid.
pid=$(jq -r '.[0].pid' <<<"$windows")
[[ $pid =~ ^[0-9]+$ && $(tr '\0' ' ' <"/proc/$pid/cmdline") == *"app.py $socket window"* ]] || fail "windows lists the app's pid" "$windows"
pass "windows lists the app's pid"

read -r -t 5 typed <&"${APP[0]}"
[[ $typed == "user:30:1:focused user:30:0:focused" ]] || fail "the user's keys reach agent apps" "$typed"
pass "the user's keys reach agent apps"

read -r -t 5 pasted <&"${APP[0]}"
[[ $pasted == "pasted:clipboard-text" ]] || fail "the user can paste into an agent app" "$pasted"
grep -q "^set_selection 902$" "$test_dir/compositor.log" || fail "the user can copy out of an agent app" "$(cat "$test_dir/compositor.log")"
pass "the user can paste into and copy out of an agent app"

run_broker omarchy-agent-seat-type 1 "x" || fail "agent can type into its window"
read -r -t 5 typed <&"${APP[0]}"
[[ $typed == "agent:45:1:focused agent:45:0:focused" ]] || fail "agent keystrokes reach the app alongside the user's" "$typed"
pass "agent keystrokes reach the app alongside the user's"

read -r -t 5 pasted <&"${APP[0]}"
[[ $pasted == "pasted:" ]] || fail "the agent can't paste the user's clipboard" "$pasted"
(( $(grep -c "^receive$" "$test_dir/compositor.log") == 1 )) || fail "the agent's paste never reaches Hyprland"
(( $(grep -c "^set_selection" "$test_dir/compositor.log") == 1 )) || fail "the agent can't set the user's clipboard" "$(cat "$test_dir/compositor.log")"
pass "the agent can't read or set the user's clipboard"

python3 "$test_dir/app.py" "$socket" thief
(( $(grep -c "^set_selection" "$test_dir/compositor.log") == 1 )) || fail "an app can't set the clipboard with serials of the user's input to another app" "$(cat "$test_dir/compositor.log")"
pass "an app can't set the clipboard with serials of the user's input to another app"

run_broker omarchy-agent-seat-type 1 "é" 2>/dev/null && fail "untypeable text is refused"
run_broker omarchy-agent-seat-type 1 --key hyper+x 2>/dev/null && fail "unknown modifiers are refused"
pass "bad keys are refused"

# The broker builds a keymap each time the user switches layouts.
growth=$(python3 - "$ROOT/bin/omarchy-agent-seat-broker" <<'EOF'
import importlib.machinery, importlib.util, sys
loader = importlib.machinery.SourceFileLoader("broker", sys.argv[1])
broker = importlib.util.module_from_spec(importlib.util.spec_from_loader(loader.name, loader))
loader.exec_module(broker)
rss = lambda: int(open("/proc/self/status").read().split("VmRSS:")[1].split()[0])
broker.Keymap()
before = rss()
for _ in range(100):
    broker.Keymap()
print(rss() - before)
EOF
)
(( growth < 4096 )) || fail "building keymaps does not leak" "${growth} kB"
pass "building keymaps does not leak"

# Without Wayland's protocol descriptions the broker says what is missing and
# where it comes from, while call still answers.
mkdir -p "$test_dir/empty-share" "$test_dir/no-protocols"
no_protocols=$(XDG_RUNTIME_DIR="$test_dir/no-protocols" WAYLAND_DISPLAY=compositor timeout 10 python3 - "$ROOT/bin/omarchy-agent-seat-broker" "$test_dir/empty-share" 2>&1 <<'EOF'
import importlib.machinery, importlib.util, json, sys
loader = importlib.machinery.SourceFileLoader("broker", sys.argv[1])
broker = importlib.util.module_from_spec(importlib.util.spec_from_loader(loader.name, loader))
loader.exec_module(broker)
broker.PROTOCOLS = broker.load_protocols(sys.argv[2])
for run in (lambda: broker.call(json.dumps({"command": "status"})), lambda: broker.Broker().serve()):
    try:
        run()
    except SystemExit as exit:
        print(f"exit {exit.code}", flush=True)
EOF
)
[[ $no_protocols == *"not running"*"exit 1"*"wl_display in /usr/share/wayland (install the wayland package)"*"xdg_wm_base in /usr/share/wayland-protocols (install the wayland-protocols package)"*"exit 1" ]] || fail "a broker without protocol descriptions names what is missing" "$no_protocols"
[[ ! -e $test_dir/no-protocols/omarchy ]] || fail "a broker without protocol descriptions does not start serving"
pass "a broker without protocol descriptions names what is missing, and call still answers"

# Drives one app connection inside a broker loaded in-process: requests as the
# app sends them, events as Hyprland sends them, and what the broker queued for
# each side since last asked. Each case prints "ok" or what went wrong.
cat >"$test_dir/inproc.py" <<'EOF'
import importlib.machinery, importlib.util, os, socket, struct, sys, time

loader = importlib.machinery.SourceFileLoader("broker", sys.argv[1])
broker = importlib.util.module_from_spec(importlib.util.spec_from_loader(loader.name, loader))
loader.exec_module(broker)

SEAT, COMPOSITOR, WM, SHM, SUBCOMPOSITOR, DATA = 2, 3, 4, 5, 6, 7
KEYBOARD, POINTER, DEVICE, SOURCE, VIEWPORTER, SINGLE_PIXEL, ALPHA_MODIFIER = 8, 9, 10, 11, 12, 13, 14
ARGB, XRGB = 0, 1

class Seat:
    def __init__(self, path):
        self.broker = broker.Broker()
        listener = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        listener.bind(path)
        listener.listen(1)
        self.app, down = socket.socketpair()
        self.client = broker.Client(self.broker, down, path)
        self.hyprland = listener.accept()[0]
        self.client.pid = 0
        self.broker.clients.append(self.client)
        self.client.objects.update({SEAT: ("wl_seat", 7), COMPOSITOR: ("wl_compositor", 6), WM: ("xdg_wm_base", 6), SHM: ("wl_shm", 1), SUBCOMPOSITOR: ("wl_subcompositor", 1), DATA: ("wl_data_device_manager", 3), VIEWPORTER: ("wp_viewporter", 1), SINGLE_PIXEL: ("wp_single_pixel_buffer_manager_v1", 1), ALPHA_MODIFIER: ("wp_alpha_modifier_v1", 1)})
        self.next_pool = 1000

    def send(self, kind, object_id, name, *args):
        table = broker.PROTOCOLS[self.client.objects[object_id][0]][kind]
        opcode = next(i for i, m in enumerate(table) if m[0] == name)
        data, fds = broker.encode(object_id, opcode, table[opcode][1], args)
        if kind == "requests":
            self.client.down.infds.extend(os.dup(fd) for fd in fds)
            self.client.request(object_id, opcode, data)
        else:
            self.client.up.infds.extend(os.dup(fd) for fd in fds)
            self.client.event(object_id, opcode, data)

    def request(self, object_id, name, *args):
        self.send("requests", object_id, name, *args)

    def event(self, object_id, name, *args):
        self.send("events", object_id, name, *args)

    def queued(self, kind):
        """(object, name, args) of every request ("requests") or event ("events") the broker queued."""
        channel = self.client.up if kind == "requests" else self.client.down
        found = []
        for data, fds in channel.out:
            object_id, word = struct.unpack_from("<II", data)
            name, signature, _ = broker.PROTOCOLS[self.client.objects[object_id][0]][kind][word & 0xFFFF]
            found.append((object_id, name, broker.decode(signature, data[8:], list(fds))))
        channel.out.clear()
        channel.pending = 0
        return found

    def window(self, surface, xdg, toplevel):
        self.request(COMPOSITOR, "create_surface", surface)
        self.request(WM, "get_xdg_surface", xdg, surface)
        self.request(xdg, "get_toplevel", toplevel)
        return self.client.toplevels[toplevel]["window"]

    def popup(self, surface, xdg, popup, parent, x, y):
        positioner = self.next_pool = self.next_pool + 1
        self.request(COMPOSITOR, "create_surface", surface)
        self.request(WM, "create_positioner", positioner)
        self.request(WM, "get_xdg_surface", xdg, surface)
        self.request(xdg, "get_popup", popup, parent, positioner)
        self.event(popup, "configure", x, y, 1, 1)

    def subsurface(self, surface, parent, x, y):
        role = self.next_pool = self.next_pool + 1
        self.request(COMPOSITOR, "create_surface", surface)
        self.request(SUBCOMPOSITOR, "get_subsurface", role, surface, parent)
        self.request(role, "set_position", x, y)
        return role

    def draw(self, surface, width, height, pixel, format=XRGB, scale=1, transform=0):
        """Fill a surface with one 4-byte pixel, or with the pixels of a whole
        buffer, as a buffer of width x height at a buffer scale and transform."""
        pool, buffer = self.next_pool + 1, self.next_pool + 2
        self.next_pool += 2
        memory = os.memfd_create("pixels")
        os.write(memory, pixel * width * height if len(pixel) == 4 else pixel)
        self.request(SHM, "create_pool", pool, memory, width * height * 4)
        os.close(memory)
        self.request(pool, "create_buffer", buffer, 0, width, height, width * 4, format)
        self.request(surface, "set_buffer_scale", scale)
        self.request(surface, "set_buffer_transform", transform)
        self.request(surface, "attach", buffer, 0, 0)
        self.request(surface, "commit")

    def pixel(self, toplevel, x, y):
        canvas, width, height, _ = self.client.capture(toplevel)
        return bytes(canvas[(y * width + x) * 4 : (y * width + x) * 4 + 3][::-1]).hex()

    def size(self, toplevel):
        _, width, height, _ = self.client.capture(toplevel)
        return f"{width}x{height}"

    def colours(self, toplevel):
        """Every colour in the window's screenshot."""
        canvas, width, height, _ = self.client.capture(toplevel)
        return sorted({bytes(canvas[i : i + 3][::-1]).hex() for i in range(0, width * height * 4, 4)})

RED, GREEN, BLUE, WHITE = b"\x00\x00\xff\xff", b"\x00\xff\x00\xff", b"\xff\x00\x00\xff", b"\xff\xff\xff\xff"

def check(problems, what, got, want):
    if got != want:
        problems.append(f"{what}: got {got!r}, want {want!r}")

def forwarded(seat, *names):
    """The arguments of each named request the broker passed on to Hyprland, by name."""
    queued = seat.queued("requests")
    found = [[args for _, request, args in queued if request == name] for name in names]
    return found if len(names) > 1 else found[0]

def clipboard(seat, problems):
    # The user types into the app, the agent clicks in it, and the app replays
    # the serial of the user's keypress to replace the clipboard.
    seat.request(SEAT, "get_keyboard", KEYBOARD)
    seat.request(SEAT, "get_pointer", POINTER)
    seat.request(DATA, "get_data_device", DEVICE, SEAT)
    seat.request(DATA, "create_data_source", SOURCE)
    window = seat.window(20, 21, 22)
    seat.draw(20, 40, 30, RED)
    seat.event(KEYBOARD, "enter", 900, 20, b"")
    seat.event(KEYBOARD, "key", 901, 0, 30, 1)
    seat.queued("requests")
    seat.request(DEVICE, "set_selection", SOURCE, 901)
    check(problems, "the user's own keypress sets the clipboard", forwarded(seat, "set_selection"), [[SOURCE, 901]])
    seat.broker.do_click(window, 1, 1)
    seat.request(DEVICE, "set_selection", SOURCE, 901)
    seat.request(DEVICE, "start_drag", SOURCE, 20, 0, 901)
    selection, drag = forwarded(seat, "set_selection", "start_drag")
    check(problems, "a keypress from before the agent clicked sets the clipboard", selection, [])
    check(problems, "a keypress from before the agent clicked starts a drag", drag, [])
    seat.event(KEYBOARD, "key", 902, 0, 30, 0)
    seat.request(DEVICE, "set_selection", SOURCE, 902)
    check(problems, "the user's next keypress sets the clipboard again", forwarded(seat, "set_selection"), [[SOURCE, 902]])

def focus_only(seat, problems):
    # The user's keyboard and pointer enter the app, as when focus follows the
    # mouse across it, and Hyprland sends the modifiers that come with an
    # enter; then the user presses a key.
    offer = 0xFF000001
    seat.request(SEAT, "get_keyboard", KEYBOARD)
    seat.request(SEAT, "get_pointer", POINTER)
    seat.request(DATA, "get_data_device", DEVICE, SEAT)
    seat.request(DATA, "create_data_source", SOURCE)
    seat.window(20, 21, 22)
    seat.draw(20, 40, 30, RED)
    seat.event(DEVICE, "data_offer", offer)
    read, write = os.pipe()

    def attempt(serial):
        seat.queued("requests")
        seat.request(DEVICE, "set_selection", SOURCE, serial)
        seat.request(offer, "receive", "text/plain", write)
        return forwarded(seat, "set_selection", "receive")

    seat.event(KEYBOARD, "enter", 777, 20, b"")
    seat.event(POINTER, "enter", 778, 20, 5, 5)
    check(problems, "the clipboard after the keyboard and pointer only entered", attempt(777) + attempt(778), [[], [], [], []])
    seat.event(KEYBOARD, "modifiers", 779, 0, 0, 0, 0)
    check(problems, "the clipboard after the modifiers sent with an enter", attempt(779), [[], []])
    seat.event(KEYBOARD, "key", 780, 0, 30, 1)
    selection, receive = attempt(780)
    check(problems, "the clipboard after the user's keypress", (selection, len(receive)), ([[SOURCE, 780]], 1))
    os.close(read)
    os.close(write)

def modifiers(seat, problems):
    # The user holds Ctrl and Caps Lock is on, the agent types, and the user
    # presses C without letting go of Ctrl.
    held = (seat.broker.keymap.modifiers["ctrl"], 0, 2, 0)
    seat.request(SEAT, "get_keyboard", KEYBOARD)
    window = seat.window(20, 21, 22)
    seat.event(KEYBOARD, "enter", 900, 20, b"")
    seat.event(KEYBOARD, "modifiers", 901, *held)
    seat.broker.do_type(window, "x")
    seat.queued("events")
    seat.event(KEYBOARD, "key", 902, 0, 46, 1)
    events = [(name, args) for object_id, name, args in seat.queued("events") if object_id == KEYBOARD]
    check(problems, "the user's key reaches the app", [name for name, _ in events][-1:], ["key"])
    check(problems, "the app's modifiers when the user's key arrives", [tuple(args[1:]) for name, args in events if name == "modifiers"][-1:], [held])

def held_keys(seat, problems):
    # The user holds the up arrow in the app, the agent types in its other
    # window, and the user presses another key; then the user lets go of the
    # arrow, the agent types again and the user presses a key.
    up = struct.pack("<I", 103)
    seat.request(SEAT, "get_keyboard", KEYBOARD)
    seat.window(20, 21, 22)
    other = seat.window(30, 31, 32)

    def keyboard_events():
        return [(name, args) for object_id, name, args in seat.queued("events") if object_id == KEYBOARD]

    def enters(events):
        return [(args[1], args[2]) for name, args in events if name == "enter"]

    seat.event(KEYBOARD, "enter", 900, 20, up)
    check(problems, "the app's enter when the user's keyboard enters", enters(keyboard_events()), [(20, up)])
    seat.broker.do_type(other, "x")
    events = keyboard_events()
    check(problems, "the app's enter when the agent types", enters(events), [(30, b"")])
    check(problems, "the agent's keys reach the app", [args[2:] for name, args in events if name == "key"][-2:], [[45, 1], [45, 0]])
    seat.event(KEYBOARD, "key", 901, 0, 46, 1)
    check(problems, "the app's enter when the user's key comes back", enters(keyboard_events()), [(20, up)])
    seat.event(KEYBOARD, "key", 902, 0, 103, 0)
    seat.event(KEYBOARD, "key", 903, 0, 46, 0)
    seat.broker.do_type(other, "x")
    keyboard_events()
    seat.event(KEYBOARD, "key", 904, 0, 46, 1)
    check(problems, "the app's enter after the user let go of the arrow", enters(keyboard_events()), [(20, b"")])
    # The user's keyboard enters the agent's window with the arrow held.
    seat.event(KEYBOARD, "leave", 905, 20)
    seat.broker.do_type(other, "x")
    keyboard_events()
    seat.event(KEYBOARD, "enter", 906, 30, up)
    check(problems, "the app's enter when the user's keyboard enters the agent's window", enters(keyboard_events()), [(30, up)])

def user_click(seat, problems):
    # The user's pointer rests in the app, the agent clicks elsewhere in the
    # same surface, and the user clicks without moving.
    seat.request(SEAT, "get_pointer", POINTER)
    window = seat.window(20, 21, 22)
    seat.draw(20, 40, 30, RED)
    seat.event(POINTER, "enter", 900, 20, 2, 2)
    seat.event(POINTER, "motion", 0, 5, 5)
    seat.broker.do_click(window, 30, 20)
    seat.queued("events")

    def click(serial):
        seat.event(POINTER, "button", serial, 0, 0x110, 1)
        seat.event(POINTER, "frame")
        return [(name, args[1:] if name == "motion" else args) for object_id, name, args in seat.queued("events") if object_id == POINTER]

    check(problems, "the user's click after the agent's", click(901), [("motion", [5, 5]), ("frame", []), ("button", [901, 0, 0x110, 1]), ("frame", [])])
    check(problems, "the user's next click", click(902), [("button", [902, 0, 0x110, 1]), ("frame", [])])
    seat.event(POINTER, "motion", 0, 6, 6)
    seat.queued("events")
    check(problems, "the user's click after moving", click(903), [("button", [903, 0, 0x110, 1]), ("frame", [])])

def drag_grab(seat, problems):
    # A red 40x30 window with a green 10x10 subsurface at 20,10; the agent
    # drags from 5,5 on the window to 25,15 in the subsurface, then moves on.
    seat.request(SEAT, "get_pointer", POINTER)
    window = seat.window(20, 21, 22)
    seat.draw(20, 40, 30, RED)
    seat.subsurface(23, 20, 20, 10)
    seat.draw(23, 10, 10, GREEN)
    seat.request(20, "commit")
    seat.queued("events")

    def pointer_events():
        found = []
        for object_id, name, args in seat.queued("events"):
            if object_id == POINTER and name != "frame":
                found.append((name, args[3:] if name == "button" else args[1:]))
        return found

    seat.broker.do_drag(window, 5, 5, 25, 15, steps=2)
    check(problems, "a drag from the window into its subsurface", pointer_events(), [("enter", [20, 5, 5]), ("button", [1]), ("motion", [15, 10]), ("motion", [25, 15]), ("button", [0])])
    seat.broker.do_move(window, 26, 16)
    check(problems, "a move after the drag's release", pointer_events(), [("leave", [20]), ("enter", [23, 6, 6])])

def translucent(seat, problems):
    # A red window under a green subsurface at half opacity, premultiplied.
    seat.window(20, 21, 22)
    seat.draw(20, 40, 30, RED)
    seat.subsurface(23, 20, 5, 5)
    seat.draw(23, 10, 10, b"\x00\x80\x00\x80", ARGB)
    seat.request(20, "commit")
    check(problems, "a translucent subsurface over red", seat.pixel(22, 6, 6), "7f8000")
    check(problems, "the window beside it", seat.pixel(22, 1, 1), "ff0000")

def alpha_modifier(seat, problems):
    # A white 40x30 window under a red 10x10 subsurface at 5,5 whose alpha
    # multiplier is set to one half, shown once the window commits; then
    # its alpha modifier destroyed.
    seat.window(20, 21, 22)
    seat.draw(20, 40, 30, WHITE)
    seat.subsurface(23, 20, 5, 5)
    seat.draw(23, 10, 10, RED)
    seat.request(20, "commit")
    seat.request(ALPHA_MODIFIER, "get_surface", 24, 23)
    seat.request(24, "set_multiplier", 0x80000000)
    check(problems, "a subsurface's alpha multiplier before it commits", seat.pixel(22, 7, 7), "ff0000")
    seat.request(23, "commit")
    check(problems, "a synchronized subsurface's alpha multiplier before its window commits", seat.pixel(22, 7, 7), "ff0000")
    seat.request(20, "commit")
    check(problems, "a subsurface at half opacity over white", (seat.pixel(22, 7, 7), seat.pixel(22, 1, 1)), ("ff7f7f", "ffffff"))
    seat.request(24, "destroy")
    seat.request(23, "commit")
    seat.request(20, "commit")
    check(problems, "a subsurface once its alpha modifier is destroyed", seat.pixel(22, 7, 7), "ff0000")

def scales(seat, problems):
    # A scale 2 window, 40x30 logical, with a scale 1 popup of 20x10 at 10,10.
    seat.window(20, 21, 22)
    seat.draw(20, 80, 60, RED, scale=2)
    seat.popup(23, 24, 25, 21, 10, 10)
    seat.draw(23, 20, 10, BLUE)
    check(problems, "a scale 2 window's screenshot", seat.size(22), "80x60")
    check(problems, "a scale 1 popup over a scale 2 window", [seat.pixel(22, x, y) for x, y in ((20, 20), (59, 39), (60, 40), (19, 19))], ["0000ff", "0000ff", "ff0000", "ff0000"])
    # And the reverse: a scale 1 window with a scale 2 popup of 20x10 logical.
    seat.window(30, 31, 32)
    seat.draw(30, 40, 30, RED)
    seat.popup(33, 34, 35, 31, 10, 10)
    seat.draw(33, 40, 20, BLUE, scale=2)
    check(problems, "a scale 1 window's screenshot", seat.size(32), "40x30")
    check(problems, "a scale 2 popup over a scale 1 window", [seat.pixel(32, x, y) for x, y in ((10, 10), (29, 19), (30, 20), (35, 25))], ["0000ff", "0000ff", "ff0000", "ff0000"])

def viewport(seat, problems):
    # A 20x20 white window under a subsurface whose 40x30 buffer is four
    # quadrants, red top left, and whose viewport shows the 10x10 top left
    # corner stretched to 20x20.
    seat.window(20, 21, 22)
    seat.draw(20, 20, 20, WHITE)
    seat.subsurface(23, 20, 0, 0)
    quadrants = b"".join((RED if x < 20 else GREEN) if y < 15 else (BLUE if x < 20 else WHITE) for y in range(30) for x in range(40))
    seat.request(VIEWPORTER, "get_viewport", 24, 23)
    seat.request(24, "set_source", 0, 0, 10, 10)
    seat.request(24, "set_destination", 20, 20)
    seat.draw(23, 40, 30, quadrants)
    seat.request(20, "commit")
    check(problems, "a window with a cropped subsurface over it", seat.size(22), "20x20")
    check(problems, "the colours of a viewport's 10x10 red source stretched to 20x20", seat.colours(22), ["ff0000"])

def hole(seat, problems):
    # A red window under a green 20x20 subsurface at 5,5 that takes input
    # everywhere but a 10x10 hole in its middle.
    seat.window(20, 21, 22)
    seat.draw(20, 40, 30, RED)
    seat.subsurface(23, 20, 5, 5)
    seat.request(COMPOSITOR, "create_region", 24)
    seat.request(24, "add", 0, 0, 20, 20)
    seat.request(24, "subtract", 5, 5, 10, 10)
    seat.request(23, "set_input_region", 24)
    seat.draw(23, 20, 20, GREEN)
    seat.request(20, "commit")
    check(problems, "a click on the subsurface around its hole", seat.client.hit(22, 7, 7), (23, 2, 2))
    check(problems, "a click in the subsurface's hole", seat.client.hit(22, 15, 15), (20, 15, 15))

def region_flood(seat, problems):
    # The window and hole of the hole test, whose app then adds the
    # subsurface's whole square and cuts the hole out again 100,000 times
    # over in that one region, which leaves it as it was: kept as requests,
    # that would cost the broker tens of MiB.
    import random
    def peak():
        with open("/proc/self/status") as status:
            return next(int(line.split()[1]) for line in status if line.startswith("VmHWM:"))
    hole(seat, problems)
    before = peak()
    for i in range(100_000):
        seat.request(24, "add", 0, 0, 20, 20)
        seat.request(24, "subtract", 5, 5, 10, 10)
        if i % 1000 == 0:  # as if passed on to Hyprland, which keeps the region itself
            seat.queued("requests")
    seat.request(23, "set_input_region", 24)
    seat.request(23, "commit")
    seat.request(20, "commit")
    check(problems, "the cost in memory of the same region set 100,000 times (KiB)", peak() - before < 4 * 1024, True)
    check(problems, "a click around the hole, then in it, after that", (seat.client.hit(22, 7, 7), seat.client.hit(22, 15, 15)), ((23, 2, 2), (20, 15, 15)))

    # Rectangles that don't touch can't merge, so their count is capped in
    # a region and across the app's regions, and an app past either is dropped.
    def refused(region, *rectangle):
        try:
            seat.request(region, "add", *rectangle)
        except ValueError as error:
            return "rectangles" in str(error)
        return False
    seat.request(COMPOSITOR, "create_region", 25)
    check(problems, "1024 separate rectangles in one region", [refused(25, 2 * i, 0, 1, 1) for i in range(1024)], [False] * 1024)
    check(problems, "one more in that region", refused(25, 3000, 0, 1, 1), True)
    for region, count in ((26, 1024), (27, 1024), (28, 1016)):  # with the hole's 4, and the 4 its subsurface keeps, the app's 4096
        seat.request(COMPOSITOR, "create_region", region)
        for i in range(count):
            seat.request(region, "add", 2 * i, 0, 1, 1)
    check(problems, "one more in the app's regions", refused(28, 3000, 0, 1, 1), True)
    for region in (25, 26, 27, 28):  # as when Hyprland frees their ids
        seat.client.forget(region)
    seat.request(COMPOSITOR, "create_region", 25)
    check(problems, "a rectangle once those regions are gone", refused(25, 0, 0, 1, 1), False)

    # Kept as rectangles, a region still covers what the requests that made
    # it say: each point by the last rectangle added or cut out over it.
    shuffle = random.Random(9)
    for trial in range(200):
        seat.request(COMPOSITOR, "create_region", 30)
        requests = [(shuffle.choice(("add", "subtract")), *(shuffle.randrange(-2, 12) for _ in range(4))) for _ in range(12)]
        for request in requests:
            seat.request(30, *request)
        for x in range(-2, 24):
            for y in range(-2, 24):
                inside = False
                for op, rx, ry, rw, rh in requests:
                    if rx <= x < rx + rw and ry <= y < ry + rh:
                        inside = op == "add"
                if seat.client.accepts_input(seat.client.regions[30], x, y) != inside:
                    problems.append(f"a region made by {requests} at {x},{y}: got {not inside}, want {inside}")
                    return
        seat.client.forget(30)

def object_flood(seat, problems):
    # An app's objects cost the broker memory for as long as they live, a
    # surface most of a KiB. An app making and destroying surfaces 100 at a
    # time, 10,000 over, keeps working; one making 10,000 and destroying none
    # is dropped at 4,096 objects, before its surfaces cost the broker more
    # than a few MiB.
    def peak():
        with open("/proc/self/status") as status:
            return next(int(line.split()[1]) for line in status if line.startswith("VmHWM:"))
    def refused(request, word):
        try:
            request()
        except ValueError as error:
            return word in str(error)
        return False

    # A surface keeps its input region's rectangles after the region is
    # gone, so a full region set on surface after surface, each destroyed
    # once set, counts against the app's 4,096 rectangles too.
    kept = []
    for i in range(5):
        seat.request(COMPOSITOR, "create_surface", 40 + i)
        seat.request(COMPOSITOR, "create_region", 50 + i)
        for x in range(1024):
            seat.request(50 + i, "add", 2 * x, 0, 1, 1)
        kept.append(refused(lambda: seat.request(40 + i, "set_input_region", 50 + i), "rectangles"))
        seat.queued("requests")
        seat.client.forget(50 + i)  # as when Hyprland frees its id
        if kept[-1]:
            break
    check(problems, "full regions set on surfaces, the regions destroyed, until refused", kept, [False, False, False, True])
    for i in range(len(kept) - 1):  # not the refused one's: the app would be gone with it
        seat.client.forget(40 + i)
    check(problems, "rectangles counted once those surfaces are gone", seat.client.region_rectangles, 0)

    made = []
    for _ in range(100):
        made += [refused(lambda: seat.request(COMPOSITOR, "create_surface", 1000 + i), "objects") for i in range(100)]
        for i in range(100):
            seat.request(1000 + i, "destroy")
        seat.queued("requests")
        for i in range(100):
            seat.event(1, "delete_id", 1000 + i)  # as Hyprland frees each id
        seat.queued("events")
    check(problems, "surfaces made and destroyed 100 at a time, 10,000 times over, refused", any(made), False)
    seat.window(20, 21, 22)
    seat.draw(20, 40, 30, RED)
    check(problems, "a window drawn after that", seat.pixel(22, 1, 1), "ff0000")

    before, objects = peak(), None
    for i in range(10_000):
        if refused(lambda: seat.request(COMPOSITOR, "create_surface", 2000 + i), "objects"):
            objects = len(seat.client.objects)
            break
        if i % 1000 == 0:  # as if passed on to Hyprland
            seat.queued("requests")
    check(problems, "the app's objects when a surface is refused", objects, 4096)
    check(problems, "the cost in memory of making 10,000 surfaces (KiB)", peak() - before < 5 * 1024, True)

def stacking(seat, problems):
    # A red 40x30 window with a green 20x20 subsurface at 5,5 and a blue one
    # at 15,10 over it, then the blue one moved below the green one, then
    # the green one below the window.
    seat.window(20, 21, 22)
    seat.draw(20, 40, 30, RED)
    green = seat.subsurface(23, 20, 5, 5)
    seat.draw(23, 20, 20, GREEN)
    blue = seat.subsurface(24, 20, 15, 10)
    seat.draw(24, 20, 20, BLUE)
    seat.request(20, "commit")
    check(problems, "where they overlap, the newer subsurface", (seat.pixel(22, 20, 15), seat.client.hit(22, 20, 15)), ("0000ff", (24, 5, 5)))
    seat.request(blue, "place_below", 23)
    seat.request(20, "commit")
    check(problems, "where they overlap, after the newer one moves below", (seat.pixel(22, 20, 15), seat.client.hit(22, 20, 15)), ("00ff00", (23, 15, 10)))
    seat.request(green, "place_below", 20)
    seat.request(20, "commit")
    check(problems, "a subsurface moved below its window", (seat.pixel(22, 7, 7), seat.client.hit(22, 7, 7)), ("ff0000", (20, 7, 7)))
    check(problems, "where they overlap, after the older one moves below the window", (seat.pixel(22, 20, 15), seat.client.hit(22, 20, 15)), ("0000ff", (24, 5, 5)))

def transform(seat, problems):
    # A 40x30 buffer, red but for a green 10x5 block in its top left corner,
    # turned 90 degrees, then flipped and turned 270.
    corner = b"".join(GREEN if x < 10 and y < 5 else RED for y in range(30) for x in range(40))
    seat.window(20, 21, 22)
    seat.draw(20, 40, 30, corner, transform=1)
    check(problems, "a 40x30 buffer turned 90 degrees", seat.size(22), "30x40")
    check(problems, "its top left corner turned 90 degrees", [seat.pixel(22, x, y) for x, y in ((25, 0), (29, 9), (24, 5), (27, 10), (2, 2), (2, 37))], ["00ff00", "00ff00", "ff0000", "ff0000", "ff0000", "ff0000"])
    check(problems, "a window turned 90 degrees, clicked", (seat.client.size(20), seat.client.hit(22, 29, 39)), ((30.0, 40.0), (20, 29, 39)))
    seat.draw(20, 40, 30, corner, transform=7)
    check(problems, "its top left corner flipped and turned 270 degrees", [seat.pixel(22, x, y) for x, y in ((25, 30), (29, 39), (24, 35), (27, 29), (27, 5))], ["00ff00", "00ff00", "ff0000", "ff0000", "ff0000"])

def wide_buffer(seat, problems):
    # A buffer 50 million pixels wide over a 1 MiB pool that is written
    # nowhere near that far, shrunk by a viewport so that the first pixel
    # shown lies inside the pool and the last far past it, turned and then
    # not: a screenshot must read the pixels it shows, not the buffer's
    # width, or each row would cost 200 MiB.
    def peak():
        with open("/proc/self/status") as status:
            return next(int(line.split()[1]) for line in status if line.startswith("VmHWM:"))
    width = 50_000_000
    seat.window(20, 21, 22)
    seat.request(VIEWPORTER, "get_viewport", 23, 20)
    for transform in (1, 0):
        pool, buffer = seat.next_pool + 1, seat.next_pool + 2
        seat.next_pool += 2
        memory = os.memfd_create("wide")
        os.write(memory, RED * 262144)
        seat.request(SHM, "create_pool", pool, memory, 1048576)
        os.close(memory)
        seat.request(pool, "create_buffer", buffer, 0, width, 2, width * 4, XRGB)
        seat.request(23, "set_destination", *((10, 1024) if transform & 1 else (1024, 10)))
        seat.request(20, "set_buffer_transform", transform)
        seat.request(20, "attach", buffer, 0, 0)
        seat.request(20, "commit")
        before = peak()
        # A pixel from the buffer's first row near its start is red, from
        # inside the pool (turned 90 degrees, that row is the right column
        # of a two pixel wide screenshot); the rest lie past the pool's end
        # and stay black.
        check(problems, f"a screenshot of a buffer {width} wide shrunk by a viewport, transform {transform}", (bool(seat.size(22)), seat.pixel(22, 1 if transform & 1 else 0, 0)), (True, "ff0000"))
        check(problems, f"its cost in memory, transform {transform} (KiB)", peak() - before < 32 * 1024, True)

def single_pixel(seat, problems):
    # A window that is one red pixel stretched to 40x30, under a subsurface
    # that is one half transparent green pixel stretched to 10x10 at 5,5.
    full, half = 0xFFFFFFFF, 0x80000000
    seat.window(20, 21, 22)
    seat.request(VIEWPORTER, "get_viewport", 23, 20)
    seat.request(23, "set_destination", 40, 30)
    seat.request(SINGLE_PIXEL, "create_u32_rgba_buffer", 24, full, 0, 0, full)
    seat.request(20, "attach", 24, 0, 0)
    seat.request(20, "commit")
    check(problems, "a window of one stretched pixel", (seat.size(22), seat.colours(22)), ("40x30", ["ff0000"]))
    seat.subsurface(25, 20, 5, 5)
    seat.request(VIEWPORTER, "get_viewport", 26, 25)
    seat.request(26, "set_destination", 10, 10)
    seat.request(SINGLE_PIXEL, "create_u32_rgba_buffer", 27, 0, half, 0, half)
    seat.request(25, "attach", 27, 0, 0)
    seat.request(25, "commit")
    seat.request(20, "commit")
    check(problems, "a half transparent green pixel over red", [seat.pixel(22, x, y) for x, y in ((5, 5), (14, 14), (15, 15), (4, 4))], ["7f8000", "7f8000", "ff0000", "ff0000"])
    # Drawn in memory at scale 2, the subsurface sets the screenshot's scale.
    seat.draw(25, 20, 20, GREEN, scale=2)
    seat.request(20, "commit")
    check(problems, "a one colour window with a scale 2 subsurface", (seat.size(22), seat.pixel(22, 9, 9), seat.pixel(22, 10, 10)), ("80x60", "ff0000", "00ff00"))

def synchronized(seat, problems):
    # A red 40x30 window with a 10x10 subsurface at 5,5, which shows a new
    # frame only once the window commits, until it is desynchronized; then a
    # 4x4 synchronized subsurface of it at 2,2, under it again synchronized.
    seat.window(20, 21, 22)
    seat.draw(20, 40, 30, RED)
    child = seat.subsurface(23, 20, 5, 5)
    seat.draw(23, 10, 10, GREEN)
    check(problems, "a subsurface's first frame before its window commits", (seat.pixel(22, 6, 6), seat.client.hit(22, 6, 6)), ("ff0000", (20, 6, 6)))
    seat.request(20, "commit")
    check(problems, "a subsurface's first frame once its window commits", (seat.pixel(22, 6, 6), seat.client.hit(22, 6, 6)), ("00ff00", (23, 1, 1)))
    seat.draw(23, 10, 10, BLUE)
    check(problems, "a subsurface's next frame before its window commits", seat.pixel(22, 6, 6), "00ff00")
    seat.request(20, "commit")
    check(problems, "a subsurface's next frame once its window commits", seat.pixel(22, 6, 6), "0000ff")
    seat.request(child, "set_desync")
    seat.draw(23, 10, 10, WHITE)
    check(problems, "a desynchronized subsurface's frame", seat.pixel(22, 6, 6), "ffffff")
    seat.request(child, "set_sync")
    seat.subsurface(24, 23, 2, 2)
    seat.draw(24, 4, 4, BLUE)
    seat.request(23, "commit")
    check(problems, "a nested subsurface's frame after its parent commits", seat.pixel(22, 8, 8), "ffffff")
    seat.request(20, "commit")
    check(problems, "a nested subsurface's frame once the window commits", seat.pixel(22, 8, 8), "0000ff")

def double_buffered(seat, problems):
    # A red 40x30 window with a green 10x10 subsurface at 5,5, moved to
    # 20,10; then a blue one at the same place over it, moved below it.
    # Each change shows only once the window commits.
    seat.window(20, 21, 22)
    seat.draw(20, 40, 30, RED)
    green = seat.subsurface(23, 20, 5, 5)
    seat.draw(23, 10, 10, GREEN)
    seat.request(20, "commit")
    seat.request(green, "set_position", 20, 10)
    check(problems, "a moved subsurface before its window commits", [(seat.pixel(22, x, y), seat.client.hit(22, x, y)) for x, y in ((6, 6), (21, 11))], [("00ff00", (23, 1, 1)), ("ff0000", (20, 21, 11))])
    seat.request(20, "commit")
    check(problems, "a moved subsurface once its window commits", [(seat.pixel(22, x, y), seat.client.hit(22, x, y)) for x, y in ((6, 6), (21, 11))], [("ff0000", (20, 6, 6)), ("00ff00", (23, 1, 1))])
    blue = seat.subsurface(24, 20, 20, 10)
    seat.draw(24, 10, 10, BLUE)
    seat.request(20, "commit")
    seat.request(blue, "place_below", 23)
    check(problems, "a subsurface moved below another before its window commits", (seat.pixel(22, 21, 11), seat.client.hit(22, 21, 11)), ("0000ff", (24, 1, 1)))
    seat.request(20, "commit")
    check(problems, "a subsurface moved below another once its window commits", (seat.pixel(22, 21, 11), seat.client.hit(22, 21, 11)), ("00ff00", (23, 1, 1)))

def unmapped(seat, problems):
    # A red 40x30 window under a subsurface that a viewport makes 40x30 but
    # that has never had a buffer, and a green subsurface of it at 5,5.
    seat.window(20, 21, 22)
    seat.draw(20, 40, 30, RED)
    seat.subsurface(23, 20, 0, 0)
    seat.request(VIEWPORTER, "get_viewport", 24, 23)
    seat.request(24, "set_destination", 40, 30)
    seat.subsurface(25, 23, 5, 5)
    seat.draw(25, 10, 10, GREEN)
    seat.request(23, "commit")
    seat.request(20, "commit")
    check(problems, "a click on a subsurface without a buffer, and on one under it", (seat.client.hit(22, 2, 2), seat.client.hit(22, 6, 6)), ((20, 2, 2), (20, 6, 6)))
    check(problems, "the colours of a window whose subsurface has no buffer", seat.colours(22), ["ff0000"])

def ancestry(seat, problems):
    # This process recorded as a sandbox's supervisor, as the sandbox
    # supervisor records itself, and a process under it that starts a
    # session of its own; then the same record with another start time.
    import subprocess
    records = os.path.join(broker.RUNTIME_DIR, "sandboxes")
    os.makedirs(records, exist_ok=True)
    start = open(f"/proc/{os.getpid()}/stat").read().rsplit(")", 1)[1].split()[19]
    child = subprocess.Popen(["setsid", "sh", "-c", "sleep 5 & wait"])
    try:
        for _ in range(100):
            grandchild = subprocess.run(["pgrep", "-P", str(child.pid)], capture_output=True, text=True).stdout.split()
            if grandchild:
                break
            time.sleep(0.02)
        with open(os.path.join(records, "sandbox.ancestry"), "w") as record:
            record.write(f"{os.getpid()} {start} ancestry 0 0\n")
        check(problems, "a process under a sandbox's supervisor, in a session of its own", broker.sandbox_of(int(grandchild[0])), "sandbox ancestry")
        with open(os.path.join(records, "sandbox.ancestry"), "w") as record:
            record.write(f"{os.getpid()} {int(start) + 1} ancestry 0 0\n")
        session = open(f"/proc/{grandchild[0]}/stat").read().rsplit(")", 1)[1].split()[3]
        check(problems, "a process whose supervisor's pid was reused", broker.sandbox_of(int(grandchild[0])), f"session {session}")
    finally:
        os.unlink(os.path.join(records, "sandbox.ancestry"))
        for pid in grandchild:
            os.kill(int(pid), 9)
        child.kill()
        child.wait()

def uncommitted(seat, problems):
    # A window committed blue, a screenshot, then red committed, and green
    # written over it without a commit; then the green committed.
    seat.window(20, 21, 22)
    memory = os.memfd_create("pixels")
    os.write(memory, BLUE * 40 * 30)
    seat.request(SHM, "create_pool", 100, memory, 40 * 30 * 4)
    seat.request(100, "create_buffer", 101, 0, 40, 30, 40 * 4, XRGB)
    seat.request(20, "attach", 101, 0, 0)
    seat.request(20, "commit")
    check(problems, "the first screenshot", seat.pixel(22, 1, 1), "0000ff")
    os.pwrite(memory, RED * 40 * 30, 0)
    seat.request(20, "commit")
    os.pwrite(memory, GREEN * 40 * 30, 0)
    check(problems, "a screenshot after green is drawn but red was committed", seat.colours(22), ["ff0000"])
    seat.request(20, "commit")
    check(problems, "a screenshot once green is committed", seat.colours(22), ["00ff00"])
    os.close(memory)

def window_geometry(seat, problems):
    # A red 40x30 window, green in its top left 10x10, whose window geometry
    # is 20x10 at 5,5; then set to 30x20 at 10,10 for a frame not committed
    # yet, then committed, then another commit that does not set it.
    corner = b"".join(GREEN if x < 10 and y < 10 else RED for y in range(30) for x in range(40))
    seat.window(20, 21, 22)
    seat.request(21, "set_window_geometry", 5, 5, 20, 10)
    seat.draw(20, 40, 30, corner)
    seat.request(21, "set_window_geometry", 10, 10, 30, 20)
    check(problems, "a window geometry set but not committed", (seat.size(22), seat.pixel(22, 0, 0), seat.client.hit(22, 0, 0)), ("20x10", "00ff00", (20, 5, 5)))
    seat.request(20, "commit")
    check(problems, "a window geometry once committed", (seat.size(22), seat.pixel(22, 0, 0), seat.client.hit(22, 0, 0)), ("30x20", "ff0000", (20, 10, 10)))
    seat.request(20, "commit")
    check(problems, "a window geometry after a commit that does not set it", seat.size(22), "30x20")

def limits(seat, problems):
    # A window one pixel wider than a screenshot can hold, one exactly as
    # wide, and a 400x400 buffer shown 10x10 through a viewport, which would
    # make the screenshot's scale 40.
    seat.window(20, 21, 22)
    seat.draw(20, 4097, 1, RED)
    try:
        seat.size(22)
        check(problems, "a window 4097 pixels wide", "a screenshot", "refused")
    except ValueError as error:
        check(problems, "a window 4097 pixels wide", "more than a screenshot can hold" in str(error), True)
    seat.draw(20, 4096, 1, RED)
    check(problems, "a window 4096 pixels wide", seat.size(22), "4096x1")
    seat.window(30, 31, 32)
    seat.request(VIEWPORTER, "get_viewport", 33, 30)
    seat.request(33, "set_destination", 10, 10)
    seat.draw(30, 400, 400, RED)
    check(problems, "a 400x400 buffer shown 10x10", (seat.size(32), seat.client.scale(32)), ("40x40", 4))

problems = []
globals()[sys.argv[3]](Seat(sys.argv[2]), problems)
print("; ".join(problems) or "ok")
EOF

inproc() {
  rm -f "$test_dir/runtime/inproc"
  run_broker python3 "$test_dir/inproc.py" "$ROOT/bin/omarchy-agent-seat-broker" "$test_dir/runtime/inproc" "$1" 2>&1
}

result=$(inproc clipboard)
[[ $result == "ok" ]] || fail "an app can't set the clipboard with the user's input from before the agent acted" "$result"
pass "an app can't set the clipboard with the user's input from before the agent acted"

result=$(inproc focus_only)
[[ $result == "ok" ]] || fail "focus entering an app without a key or click does not open the clipboard to it" "$result"
pass "focus entering an app without a key or click does not open the clipboard to it"

result=$(inproc modifiers)
[[ $result == "ok" ]] || fail "a modifier the user holds through the agent's typing still applies to the user's next key" "$result"
pass "a modifier the user holds through the agent's typing still applies to the user's next key"

result=$(inproc held_keys)
[[ $result == "ok" ]] || fail "a key the user holds is still down in the app after the agent types elsewhere" "$result"
pass "a key the user holds is still down in the app after the agent types elsewhere"

result=$(inproc user_click)
[[ $result == "ok" ]] || fail "the user's click lands under the user's pointer after the agent pointed elsewhere in the surface" "$result"
pass "the user's click lands under the user's pointer after the agent pointed elsewhere in the surface"

result=$(inproc drag_grab)
[[ $result == "ok" ]] || fail "the agent's drag keeps the pointer on the surface it pressed until the release" "$result"
pass "the agent's drag keeps the pointer on the surface it pressed until the release"

result=$(inproc translucent)
[[ $result == "ok" ]] || fail "a screenshot blends a translucent layer over what is under it" "$result"
pass "a screenshot blends a translucent layer over what is under it"

result=$(inproc alpha_modifier)
[[ $result == "ok" ]] || fail "a screenshot fades a surface by its alpha multiplier" "$result"
pass "a screenshot fades a surface by its alpha multiplier"

result=$(inproc scales)
[[ $result == "ok" ]] || fail "a screenshot draws a popup of another scale at the window's scale" "$result"
pass "a screenshot draws a popup of another scale at the window's scale"

result=$(inproc viewport)
[[ $result == "ok" ]] || fail "a screenshot draws only the part of a buffer a viewport shows" "$result"
pass "a screenshot draws only the part of a buffer a viewport shows"

result=$(inproc hole)
[[ $result == "ok" ]] || fail "a click in a hole cut out of a surface's input region falls through to the surface beneath" "$result"
pass "a click in a hole cut out of a surface's input region falls through to the surface beneath"

result=$(inproc region_flood)
[[ $result == "ok" ]] || fail "an app setting a region over and over does not grow the broker, and too many rectangles drop it" "$result"
pass "an app setting a region over and over does not grow the broker, and too many rectangles drop it"

result=$(inproc object_flood)
[[ $result == "ok" ]] || fail "an app making objects without destroying them is dropped at its share, and one destroying them keeps working" "$result"
pass "an app making objects without destroying them is dropped at its share, and one destroying them keeps working"

result=$(inproc stacking)
[[ $result == "ok" ]] || fail "screenshots and clicks follow subsurfaces moved above or below each other and their window" "$result"
pass "screenshots and clicks follow subsurfaces moved above or below each other and their window"

result=$(inproc transform)
[[ $result == "ok" ]] || fail "a screenshot turns and flips a buffer by its transform" "$result"
pass "a screenshot turns and flips a buffer by its transform"

result=$(inproc wide_buffer)
[[ $result == "ok" ]] || fail "a screenshot of a buffer made very wide and shrunk reads only the pixels it shows" "$result"
pass "a screenshot of a buffer made very wide and shrunk reads only the pixels it shows"

result=$(inproc single_pixel)
[[ $result == "ok" ]] || fail "a screenshot draws single pixel buffers as their colour, stretched and blended" "$result"
pass "a screenshot draws single pixel buffers as their colour, stretched and blended"

result=$(inproc synchronized)
[[ $result == "ok" ]] || fail "a synchronized subsurface's frame shows only once its window commits" "$result"
pass "a synchronized subsurface's frame shows only once its window commits"

result=$(inproc double_buffered)
[[ $result == "ok" ]] || fail "a subsurface's position and stacking change only when its window commits" "$result"
pass "a subsurface's position and stacking change only when its window commits"

result=$(inproc unmapped)
[[ $result == "ok" ]] || fail "a subsurface without a buffer, and what is under it, takes no clicks" "$result"
pass "a subsurface without a buffer, and what is under it, takes no clicks"

result=$(inproc ancestry)
[[ $result == "ok" ]] || fail "an app is counted against the sandbox whose supervisor it runs under" "$result"
pass "an app is counted against the sandbox whose supervisor it runs under"

result=$(inproc uncommitted)
[[ $result == "ok" ]] || fail "a screenshot soon after another shows what the app committed, not what it drew since" "$result"
pass "a screenshot soon after another shows what the app committed, not what it drew since"

result=$(inproc window_geometry)
[[ $result == "ok" ]] || fail "a window geometry changes screenshots and clicks only when the app commits it" "$result"
pass "a window geometry changes screenshots and clicks only when the app commits it"

result=$(inproc limits)
[[ $result == "ok" ]] || fail "a screenshot is at most 4096 pixels a side and 4 pixels per surface unit" "$result"
pass "a screenshot is at most 4096 pixels a side and 4 pixels per surface unit"

broker=$(run_broker omarchy-agent-seat-status --json | jq -r '.pid')

python3 "$test_dir/app.py" "$socket" vanish "$broker"
sleep 0.2
kill -0 "$broker" 2>/dev/null || fail "an app hanging up with an event in flight leaves the broker running" "$(cat "$test_dir/broker.log")"
[[ $(python3 "$test_dir/app.py" "$socket" globals) == *wl_seat* ]] || fail "the broker still serves apps after one hangs up mid-event"
pass "an app hanging up with an event in flight leaves the broker running"

start_draw flicker
window=$(window_of flicker)
for _ in {1..5}; do
  shot=$(run_broker omarchy-agent-seat-screenshot "$window" 2>&1)
  kill -0 "$broker" 2>/dev/null || fail "an app shrinking its pool under a screenshot leaves the broker running" "$(tail -5 "$test_dir/broker.log")"
  [[ $(python3 "$test_dir/pixels.py" "$shot") == "2000x1500" ]] || fail "a window whose pool shrinks still gets a screenshot" "$shot"
done
stop_draw
pass "an app shrinking its pool under a screenshot leaves the broker running"

# Another app keeps being served while a large translucent window's
# screenshot is composed.
start_draw glass
window=$(window_of glass)
python3 "$test_dir/app.py" "$socket" latency >"$test_dir/latency.out" &
latency_pid=$!
for _ in {1..50}; do [[ -s $test_dir/latency.out ]] && break; sleep 0.1; done
shot=$(run_broker omarchy-agent-seat-screenshot "$window" 2>&1) || fail "a large translucent window gets a screenshot" "$shot"
wait "$latency_pid"
slowest=$(tail -1 "$test_dir/latency.out")
[[ $(python3 "$test_dir/pixels.py" "$shot" 0,0 1999,1999) == "2000x2000 7f8000 7f8000" ]] || fail "a large translucent window's screenshot is blended" "$(python3 "$test_dir/pixels.py" "$shot" 0,0)"
(( slowest < 100 )) || fail "a large screenshot does not hold up other apps" "a round trip took ${slowest} ms"
stop_draw
pass "a large screenshot does not hold up other apps"

# The scene: a red 40x30 window (surface 20) taking input on its left half,
# a green 10x10 subsurface (21) at 5,5 and a blue 20x10 popup (22) at 30,25.
start_draw scene
window=$(window_of scene)

shot=$(run_broker omarchy-agent-seat-screenshot "$window") || fail "a window with a subsurface and a popup gets a screenshot"
colors=$(python3 "$test_dir/pixels.py" "$shot" 1,1 6,6 35,27 45,2 2,32)
[[ $colors == "50x35 ff0000 00ff00 0000ff 000000 000000" ]] || fail "a screenshot composes the window, its subsurface and its popup" "$colors"
pass "a screenshot composes the window, its subsurface and its popup"

pointer() {
  run_broker omarchy-agent-seat-pointer "$window" "$@"
}

pointer move 2 2 || fail "the agent pointer moves onto a window"
[[ $(pointer_events 1) == "enter 20 2 2;frame" ]] || fail "the agent pointer moves onto a window" "$(pointer_events 1)"
pointer move 10 10 || fail "the agent pointer moves onto a subsurface"
[[ $(pointer_events 1) == "leave 20;enter 21 5 5;frame" ]] || fail "the agent pointer moves onto a subsurface"
pass "the agent pointer moves between a window and its subsurface"

pointer click 35 27 || fail "the agent clicks in a popup"
events=$(pointer_events 3)
[[ $events == "leave 21;enter 22 5 2;frame;button 272 1;frame;button 272 0;frame" ]] || fail "the agent clicks in a popup" "$events"
pass "the agent clicks in a popup"

pointer drag 2 2 18 2 || fail "the agent drags"
events=$(pointer_events 15)
[[ $events == "leave 22;enter 20 2 2;frame;button 272 1;frame;"*";motion 18 2;frame;button 272 0;frame" ]] || fail "the agent drags" "$events"
pass "the agent drags"

pointer scroll 2 2 3 || fail "the agent scrolls"
events=$(pointer_events 2)
[[ $events == "motion 2 2;frame;discrete 0 3;axis 0 45;frame" ]] || fail "the agent scrolls" "$events"
pass "the agent scrolls"

pointer move 30 10 2>/dev/null && fail "the agent pointer can't point outside a surface's input region"
pass "the agent pointer can't point outside a surface's input region"

# The fifth of twelve steps crosses the subsurface and the eighth leaves the
# window's input region; the window that took the press still gets them all.
pointer drag 2 2 30 10 || fail "a drag past the input region of the surface it pressed succeeds"
events=$(pointer_events 15)
[[ $events == "motion 2 2;frame;button 272 1;frame;"*";motion 30 10;frame;button 272 0;frame" && $events != *enter* && $events != *leave* ]] || fail "a drag stays on the surface it pressed, past its input region and over its subsurface" "$events"
pass "a drag stays on the surface it pressed, past its input region and over its subsurface"

draw_command geometry
shot=$(run_broker omarchy-agent-seat-screenshot "$window") || fail "a window declaring a huge geometry still gets a screenshot"
[[ $(python3 "$test_dir/pixels.py" "$shot") == "50x35" ]] || fail "a screenshot is only as large as what the window draws" "$(python3 "$test_dir/pixels.py" "$shot")"
pass "a screenshot is only as large as what the window draws"

mkdir -p "$test_dir/work/sub"
ln -s "$test_dir/elsewhere.png" "$test_dir/work/link.png"
(
  cd "$test_dir/work/sub" || exit 1
  [[ $(run_broker omarchy-agent-seat-screenshot "$window" --output shot.png) == "$test_dir/work/sub/shot.png" && -f shot.png ]] || fail "a screenshot can go under the current directory"
  for output in ../../outside.png /tmp/agent-seat-test-$$.png shot.txt ../link.png missing/shot.png; do
    run_broker omarchy-agent-seat-screenshot "$window" --output "$output" 2>/dev/null && fail "a screenshot can't go to $output"
  done
  exit 0
) || exit 1
[[ ! -e $test_dir/outside.png && ! -e /tmp/agent-seat-test-$$.png && ! -e $test_dir/elsewhere.png && ! -e $test_dir/work/sub/missing ]] || fail "refused screenshots write nothing"
pass "a screenshot only goes under the current directory or the seat's own"

draw_command unsub
shot=$(run_broker omarchy-agent-seat-screenshot "$window")
[[ $(python3 "$test_dir/pixels.py" "$shot" 1,1 6,6) == "50x35 ff0000 ff0000" ]] || fail "a destroyed subsurface leaves its window's screenshot" "$(python3 "$test_dir/pixels.py" "$shot" 1,1 6,6)"
pointer move 6 6 || fail "a destroyed subsurface leaves its window's hit testing"
[[ $(pointer_events 1) == "motion 6 6;frame" ]] || fail "a destroyed subsurface leaves its window's hit testing"
pass "a destroyed subsurface leaves its window, even when its id comes back"
stop_draw

# A caller that never finishes its request, one that sends too much, and a
# slow Hyprland all leave the broker answering everyone else.
exec {stalled}< <(python3 -c '
import socket, sys, time
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.connect(sys.argv[1])
sock.sendall(b"{\"command\": ")
print("connected", flush=True)
time.sleep(3)
' "$test_dir/runtime/omarchy/agent-seat/control")
stalled_pid=$!
read -r -t 5 line <&"$stalled"
timeout 1 bash -c "HOME='$test_dir/home' XDG_RUNTIME_DIR='$test_dir/runtime' PATH='$test_dir/bin:$ROOT/bin:$PATH' omarchy-agent-seat-status" >/dev/null || fail "a caller that never finishes its request does not hold up the broker"
exec {stalled}<&-
kill "$stalled_pid" 2>/dev/null
oversized=$(python3 -c '
import socket, sys
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.connect(sys.argv[1])
try:
    sock.sendall(b"x" * (4 << 20))
except OSError:
    pass
print(sock.recv(4096).decode().strip())
' "$test_dir/runtime/omarchy/agent-seat/control" 2>&1)
[[ $oversized == *"too large"* ]] || fail "an oversized request is refused" "$oversized"
echo 1 >"$test_dir/hyprctl-delay"
run_broker omarchy-agent-seat-windows >"$test_dir/slow-windows.json" &
slow_windows=$!
sleep 0.3
timeout 1 bash -c "HOME='$test_dir/home' XDG_RUNTIME_DIR='$test_dir/runtime' PATH='$test_dir/bin:$ROOT/bin:$PATH' omarchy-agent-seat-status" >/dev/null || fail "a slow Hyprland does not hold up the broker"
wait "$slow_windows" || fail "windows answers once Hyprland does"
rm "$test_dir/hyprctl-delay"
jq -e 'type == "array"' "$test_dir/slow-windows.json" >/dev/null || fail "windows answers once Hyprland does" "$(cat "$test_dir/slow-windows.json")"
pass "slow or oversized control requests and a slow Hyprland do not hold up the broker"

descriptors() {
  local fds=(/proc/"$broker"/fd/*)
  echo "${#fds[@]}"
}

before=$(descriptors)
[[ $(python3 "$test_dir/app.py" "$socket" fdflood) == "disconnected" ]] || fail "an app sending more descriptors than libwayland would is dropped"
[[ $(python3 "$test_dir/app.py" "$socket" poolflood) == "disconnected" ]] || fail "an app making hundreds of pools is dropped"
sleep 0.2
(( $(descriptors) <= before )) || fail "a dropped app leaves no descriptors behind" "$before -> $(descriptors)"
[[ $(python3 "$test_dir/app.py" "$socket" globals) == *wl_seat* ]] || fail "the broker serves apps after a descriptor flood"
pass "apps flooding the broker with descriptors are dropped without a leak"

before=$(descriptors)
[[ $(python3 "$test_dir/app.py" "$socket" truncated) == "disconnected" ]] || fail "an app sending a malformed request is dropped"
sleep 0.2
(( $(descriptors) <= before )) || fail "a malformed request leaves none of its descriptors behind" "$before -> $(descriptors)"
[[ $(python3 "$test_dir/app.py" "$socket" globals) == *wl_seat* ]] || fail "the broker serves apps after a malformed request"
pass "a malformed request drops only its app and leaves none of its descriptors behind"

crowd=$(setsid -w python3 "$test_dir/crowd.py" "$socket" "$ROOT/bin/omarchy-agent-seat-broker" 2>&1)
[[ $crowd == $'served\nrefused\n'* ]] || fail "an app gets no more connections than its sandbox may have" "$crowd"
grep -q "refusing a connection from pid [0-9]*: session [0-9]* already has" "$test_dir/broker.log" || fail "a refused connection is logged" "$(tail -3 "$test_dir/broker.log")"
[[ $crowd == *$'\nanother app served\n'* ]] || fail "another app still connects while one has all its sandbox may have" "$crowd"
[[ $crowd == *$'\nkept dropped' ]] || fail "an app's pools are counted over all its connections" "$crowd"
pass "an app's connections and pools are capped for its whole sandbox, not each connection"

python3 "$test_dir/app.py" "$socket" syncflood >"$test_dir/flood.out" &
flood_pid=$!
for _ in {1..100}; do [[ -s $test_dir/flood.out ]] && break; sleep 0.1; done
[[ $(<"$test_dir/flood.out") == "blocked" ]] || fail "an app that never reads is held back instead of buffered" "$(<"$test_dir/flood.out") $(tail -3 "$test_dir/broker.log")"
rss=$(awk '/^VmRSS/ { print $2 }' "/proc/$broker/status")
(( rss < 120000 )) || fail "an app that never reads does not grow the broker" "${rss} kB"
run_broker omarchy-agent-seat-status >/dev/null || fail "the broker answers while an app floods it"
wait "$flood_pid"
pass "an app that never reads is held back instead of buffered"

sandbox_pids=()
if bwrap_works; then
  sandbox_marker="agent-seat-test-$$"
  run_broker omarchy-agent-seat-run --no-wait /usr/bin/bash -c '/usr/bin/sleep 300 & /usr/bin/sleep 300' "$sandbox_marker" || fail "a headless sandbox starts"
  records=("$test_dir/runtime/omarchy/agent-seat/sandboxes"/sandbox.*)
  (( ${#records[@]} == 1 )) || fail "a sandbox has one lifecycle record" "${records[*]}"
  for _ in {1..50}; do
    read -r supervisor_pid _ _ bwrap_pid _ <"${records[0]}" || true
    [[ ${bwrap_pid:-0} != 0 ]] && break
    sleep 0.01
  done
  [[ ${supervisor_pid:-} =~ ^[0-9]+$ && ${bwrap_pid:-0} != 0 ]] || fail "a sandbox records its supervisor and bwrap processes" "$(cat "${records[0]}")"
  sandbox_pids=("$supervisor_pid" "$bwrap_pid")
  for _ in {1..50}; do
    known=${#sandbox_pids[@]}
    for pid in "${sandbox_pids[@]}"; do
      while read -r child; do
        [[ " ${sandbox_pids[*]} " == *" $child "* ]] || sandbox_pids+=("$child")
      done < <(pgrep -P "$pid" || true)
    done
    (( ${#sandbox_pids[@]} >= 5 )) && break
    (( known == ${#sandbox_pids[@]} )) && sleep 0.01
  done
  (( ${#sandbox_pids[@]} >= 5 )) || fail "a headless sandbox starts helper processes" "${sandbox_pids[*]}"
  pass "a headless sandbox and its helpers are tracked"
else
  skip "bubblewrap cannot create a sandbox here; skipping the sandbox lifecycle"
fi

/usr/bin/sleep 300 &
unrelated_pid=$!
unrelated_stat=$(<"/proc/$unrelated_pid/stat")
unrelated_stat=${unrelated_stat##*) }
read -ra unrelated_fields <<<"$unrelated_stat"
mkdir -p "$test_dir/runtime/omarchy/agent-seat/sandboxes"
printf '%s %s stale-marker 0 0\n' "$unrelated_pid" "${unrelated_fields[19]}" >"$test_dir/runtime/omarchy/agent-seat/sandboxes/sandbox.stale"

run_broker omarchy-agent-seat-stop >/dev/null
for _ in {1..50}; do kill -0 "$broker_pid" 2>/dev/null || break; sleep 0.1; done
kill -0 "$broker_pid" 2>/dev/null && fail "stop ends the broker"
for pid in "${sandbox_pids[@]}"; do
  [[ ! -e /proc/$pid ]] || fail "stop ends every process in a sandbox" "${sandbox_pids[*]}"
done
if (( ${#sandbox_pids[@]} )); then
  pass "stop ends every process in a sandbox"
fi
kill -0 "$unrelated_pid" 2>/dev/null || fail "a stale lifecycle record does not kill an unrelated process"
kill "$unrelated_pid"
wait "$unrelated_pid" 2>/dev/null || true
pass "stale lifecycle records do not kill unrelated processes"

run_broker omarchy-agent-seat-run --share "$test_dir/missing" foot 2>/dev/null && fail "sharing a missing path is refused"
pass "sharing a missing path is refused"
[[ $(run_broker omarchy-agent-seat-status) == "Agent seat: stopped" ]] || fail "status reports a stopped seat"
pass "stop ends the broker"

# Starts a broker, with at most the given number of open files.
start_broker() {
  (
    ulimit -n "${1:-1024}"
    run_broker omarchy-agent-seat-broker serve
  ) 2>>"$test_dir/broker.log" &
  broker_pid=$!
  for _ in {1..50}; do run_broker omarchy-agent-seat-status >/dev/null && break; sleep 0.1; done
  broker=$(run_broker omarchy-agent-seat-status --json | jq -r '.pid')
}

# A broker that dies leaves its sockets behind.
start_broker
control="$test_dir/runtime/omarchy/agent-seat/control"
kill -KILL "$broker"
wait "$broker_pid" 2>/dev/null
[[ -S $socket && -S $control ]] || fail "a killed broker leaves its sockets behind"
start_broker
[[ $(python3 "$test_dir/app.py" "$socket" globals) == *wl_seat* ]] || fail "a broker starts over the sockets of one that died"
run_broker omarchy-agent-seat-status >/dev/null || fail "a broker answers on the control socket of one that died"
pass "a broker starts over the sockets of one that died"
run_broker omarchy-agent-seat-stop >/dev/null
wait "$broker_pid" 2>/dev/null

# A broker out of file descriptors waits for some to free instead of spinning.
start_broker 40
ticks=$(python3 - "$test_dir/runtime/omarchy/agent-seat/control" "$broker" <<'EOF'
import socket, sys, time
def cpu():
    fields = open(f"/proc/{sys.argv[2]}/stat").read().rsplit(")", 1)[1].split()
    return int(fields[11]) + int(fields[12])
held = []
for _ in range(45):
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.settimeout(0.5)
    try:
        sock.connect(sys.argv[1])
        sock.sendall(b"{")
    except OSError:
        pass  # the queue is full
    held.append(sock)
    time.sleep(0.01)  # time to accept, so the broker runs out rather than its queue
time.sleep(0.5)
before = cpu()
time.sleep(1)
print(cpu() - before)
EOF
)
(( ticks < 30 )) || fail "a broker out of file descriptors does not spin" "$ticks ticks of CPU in a second"
grep -q "out of file descriptors" "$test_dir/broker.log" || fail "a broker out of file descriptors says so"
for _ in {1..50}; do run_broker omarchy-agent-seat-status >/dev/null && break; sleep 0.1; done
run_broker omarchy-agent-seat-status >/dev/null || fail "a broker out of file descriptors recovers once they free"
pass "a broker out of file descriptors waits instead of spinning, then recovers"
run_broker omarchy-agent-seat-stop >/dev/null
wait "$broker_pid" 2>/dev/null

# A broker that accepts the connection and never answers must not hold stop
# up: stop gives up on it, ends whatever listens on the control socket and
# still clears the sandboxes' records.
seat="$test_dir/runtime/omarchy/agent-seat"
rm -f "$seat/control"
python3 -c '
import socket, sys
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.bind(sys.argv[1])
sock.listen()
conns = []
while True:
  conns.append(sock.accept()[0])
' "$seat/control" &
silent_pid=$!
for _ in {1..50}; do [[ -S $seat/control ]] && break; sleep 0.1; done
[[ -S $seat/control ]] || fail "the silent broker listens on the control socket"
/usr/bin/true &
gone_pid=$!
wait "$gone_pid"
mkdir -p "$seat/sandboxes/gonemarker.d"
printf '%s 1 gonemarker 0 0\n' "$gone_pid" >"$seat/sandboxes/sandbox.gone"
/usr/bin/sleep 300 &
unrelated_pid=$!
unrelated_stat=$(<"/proc/$unrelated_pid/stat")
unrelated_stat=${unrelated_stat##*) }
read -ra unrelated_fields <<<"$unrelated_stat"
printf '%s %s stale-marker 0 0\n' "$unrelated_pid" "${unrelated_fields[19]}" >"$seat/sandboxes/sandbox.stale"

start=$SECONDS
code=0
output=$(run_broker timeout 30 omarchy-agent-seat-stop 2>&1) || code=$?
((code != 124)) || fail "stop gives up on a broker that never answers" "$output"
((code == 0)) || fail "stop succeeds when the broker never answers" "$output"
((SECONDS - start <= 8)) || fail "stop gives up on a silent broker within a few seconds" "$((SECONDS - start)) seconds"
[[ $output == *"Agent seat: stopped"* ]] || fail "stop reports the seat stopped when the broker never answers" "$output"
for _ in {1..50}; do kill -0 "$silent_pid" 2>/dev/null || break; sleep 0.1; done
kill -0 "$silent_pid" 2>/dev/null && fail "stop ends a broker that never answers"
wait "$silent_pid" 2>/dev/null
silent_pid=
[[ ! -e $seat/sandboxes/sandbox.gone && ! -e $seat/sandboxes/gonemarker.d ]] || fail "stop clears a sandbox's record when the broker never answers"
[[ ! -e $seat/sandboxes/sandbox.stale ]] || fail "stop clears every record when the broker never answers"
kill -0 "$unrelated_pid" 2>/dev/null || fail "a stale lifecycle record does not kill an unrelated process when the broker never answers"
kill "$unrelated_pid"
wait "$unrelated_pid" 2>/dev/null || true
[[ $(run_broker omarchy-agent-seat-status) == "Agent seat: stopped" ]] || fail "status reports the seat stopped once stop ended a silent broker"
pass "stop ends a broker that never answers and still clears the sandboxes"

# A killed supervisor stays a zombie until its parent reaps it, and a parent
# that never waits leaves it one: stop counts it as ended, not as still alive.
fake_root="$test_dir/fake-omarchy"
mkdir -p "$fake_root/bin"
printf '#!/bin/bash\n/usr/bin/sleep 300\n' >"$fake_root/bin/omarchy-agent-seat-sandbox"
chmod +x "$fake_root/bin/omarchy-agent-seat-sandbox"
fake_supervisor=$(realpath -e "$fake_root/bin/omarchy-agent-seat-sandbox")
record="$seat/sandboxes/sandbox.unreaped"
bash -c '/bin/bash "$1" "$2" unreapedmarker 2>/dev/null & echo "$!" >"$3"; exec /usr/bin/sleep 300' _ "$fake_supervisor" "$record" "$test_dir/unreaped.pid" &
holder_pid=$!
for _ in {1..50}; do
  [[ -s $test_dir/unreaped.pid ]] && unreaped_pid=$(<"$test_dir/unreaped.pid") && grep -qz unreapedmarker "/proc/$unreaped_pid/cmdline" 2>/dev/null && break
  sleep 0.1
done
unreaped_stat=$(<"/proc/$unreaped_pid/stat")
unreaped_stat=${unreaped_stat##*) }
read -ra unreaped_fields <<<"$unreaped_stat"
printf '%s %s unreapedmarker 0 0\n' "$unreaped_pid" "${unreaped_fields[19]}" >"$record"

code=0
output=$(OMARCHY_PATH="$fake_root" run_broker omarchy-agent-seat-stop 2>&1) || code=$?
unreaped_stat=$(<"/proc/$unreaped_pid/stat")
unreaped_stat=${unreaped_stat##*) }
kill "$holder_pid"
wait "$holder_pid" 2>/dev/null || true
[[ ${unreaped_stat:0:1} == "Z" ]] || fail "a killed supervisor whose parent never waits stays a zombie" "$unreaped_stat"
((code == 0)) || fail "stop succeeds when a killed supervisor is left a zombie" "$output"
[[ $output == "Agent seat: stopped" ]] || fail "stop reports the seat stopped when a killed supervisor is left a zombie" "$output"
[[ ! -e $record ]] || fail "stop clears the record of a sandbox left a zombie"
pass "stop counts a killed supervisor left a zombie as ended"

[[ $(real_seat_dirs) == "$real_seat_before" ]] || fail "the suite leaves the user's own seat home and state alone" "$(diff <(echo "$real_seat_before") <(real_seat_dirs))"
