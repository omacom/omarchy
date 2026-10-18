#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

key="$ROOT/bin/omarchy-face-key"
test_tmp=$(mktemp -d)
pids=()
cleanup() {
  (( ${#pids[@]} == 0 )) || kill "${pids[@]}" 2>/dev/null || true
  rm -rf "$test_tmp"
}
trap cleanup EXIT

copy="$test_tmp/face-key"
log="$test_tmp/calls.log"
service_log="$test_tmp/service.log"
me=$(id -un)
mkdir -p "$test_tmp/dev/input" "$test_tmp/sys/class/input" "$test_tmp/bin"

# The service names root's socket, the kernel's input trees, the face policy
# and the notification tools; a scratch copy retargets each, idles out after a
# second instead of thirty, and gives the key back from the lock's scan and grace
# after a second each.
for literal in 'SOCKET_PATH = "/run/omarchy-face-key.sock"' 'INPUT_DIR = "/dev/input"' 'INPUT_SYSFS = "/sys/class/input"' \
  'FACE_CONF = "/etc/omarchy/face.conf"' 'SETPRIV = "/usr/bin/setpriv"' 'NOTIFY = "/usr/bin/omarchy-notification-send"' 'IDLE_EXIT_S = 30' \
  'LOCK_GRACE_S = 5' 'LOCK_SCAN_S = 15'; do
  (( $(grep -Fxc "$literal" "$key") == 1 )) || fail "the service names $literal exactly once"
done
sed -e "s|^SOCKET_PATH = .*|SOCKET_PATH = \"$test_tmp/key.sock\"|" \
  -e "s|^INPUT_DIR = .*|INPUT_DIR = \"$test_tmp/dev/input\"|" \
  -e "s|^INPUT_SYSFS = .*|INPUT_SYSFS = \"$test_tmp/sys/class/input\"|" \
  -e "s|^FACE_CONF = .*|FACE_CONF = \"$test_tmp/face.conf\"|" \
  -e "s|^SETPRIV = .*|SETPRIV = \"$test_tmp/bin/setpriv\"|" \
  -e "s|^IDLE_EXIT_S = .*|IDLE_EXIT_S = 1|" \
  -e "s|^LOCK_GRACE_S = .*|LOCK_GRACE_S = 1|" \
  -e "s|^LOCK_SCAN_S = .*|LOCK_SCAN_S = 1|" "$key" >"$copy"
pass "the service names its fixed paths once each, and the test drives a retargeted copy"

# The service hands the notifier a clean environment, so the stub logs to a
# path fixed here.
cat >"$test_tmp/bin/setpriv" <<SH
#!/bin/bash
{ printf 'setpriv'; printf ' %s' "\$@"; printf '\n'; } >>"$log"
SH
chmod +x "$test_tmp/bin/setpriv"

# input <event> <device path under sys> <key capabilities>: a sysfs entry and
# a FIFO standing in for its evdev node.
input() {
  mkdir -p "$test_tmp/sys/$2/capabilities" "$test_tmp/sys/class/input/$1"
  printf '%s\n' "$3" >"$test_tmp/sys/$2/capabilities/key"
  ln -s "$test_tmp/sys/$2" "$test_tmp/sys/class/input/$1/device"
  mkfifo "$test_tmp/dev/input/$1"
}
# Bit 193 (F23, the Copilot key) is bit 1 of the fourth long from the right.
input event3 devices/platform/i8042/serio0/input/input3 "2 0 0 0"
input event4 devices/virtual/input/input30 "2 0 0 0"
input event5 devices/platform/i8042/serio1/input/input4 "0 0 0 fffffffe"
# Held read-write, the node always has a writer, as a real keyboard does;
# the processes under test are started without it.
exec 7<>"$test_tmp/dev/input/event3"

# until_true <tries of 0.1s> <command...>
until_true() {
  local tries=$1
  shift
  while (( tries-- > 0 )); do
    "$@" && return 0
    sleep 0.1
  done
  return 1
}

running() {
  kill -0 "$1" 2>/dev/null
}

gone() {
  ! kill -0 "$1" 2>/dev/null
}

# holds <pid> <path>: whether the process has the file open.
holds() {
  local fd
  for fd in /proc/"$1"/fd/*; do
    [[ $(readlink "$fd") == "$2" ]] && return 0
  done
  return 1
}

# reading <event>: whether the service holds the node open.
reading() {
  holds "$service" "$test_tmp/dev/input/$1"
}

not_reading() {
  ! reading "$1"
}

logged_at_least() {
  (( $(grep -c -- "$1" "$service_log") >= $2 ))
}

# event <value> [code]: one evdev record on the keyboard.
event() {
  python3 -c 'import struct, sys; sys.stdout.buffer.write(struct.pack("llHHi", 0, 0, 1, int(sys.argv[2]), int(sys.argv[1])))' "$1" "${2:-193}" >&7
}

# prompt: a process standing in for a PAM conversation (sudo, polkit, the lock).
prompt() {
  sleep 300 &
  prompt_pid=$!
  pids+=("$prompt_pid")
}

# terminal_prompt: a conversation reading a terminal of its own, as sudo reads
# the user's.
terminal_prompt() {
  rm -f "$test_tmp/terminal-prompt"
  python3 -c 'import os, pty, sys
pid, _ = pty.fork()
if pid == 0:
    os.execvp("sleep", ["sleep", "300"])
print(pid, flush=True)
os.waitpid(pid, 0)' >"$test_tmp/terminal-prompt" 7<&- &
  pids+=("$!")
  until_true 30 test -s "$test_tmp/terminal-prompt" || fail "a conversation with a terminal starts"
  prompt_pid=$(<"$test_tmp/terminal-prompt")
  pids+=("$prompt_pid")
  prompt_tty=$(readlink "/proc/$prompt_pid/fd/0")
}

# waiter <pam pid> [args...]: a prompt waiting for the key.
waiter() {
  local pam_pid=$1
  shift
  python3 "$copy" wait --pam-pid "$pam_pid" --user "$me" "$@" >"$test_tmp/waiter-$pam_pid" 2>&1 7<&- &
  waiter_pid=$!
  pids+=("$waiter_pid")
}

exited_with() {
  local status=0
  until_true 30 gone "$1" || return 1
  wait "$1" || status=$?
  (( status == $2 ))
}

key_take() {
  python3 "$copy" take --pam-pid "$1"
}

printf 'LOCK_WINDOW_MINUTES="15"\n' >"$test_tmp/face.conf"
cp /usr/bin/sleep "$test_tmp/sudo"
"$test_tmp/sudo" 300 &
sudo_pid=$!
pids+=("$sudo_pid")
bash -c 'exec -a /usr/lib/polkit-1/polkit-agent-helper-1 sleep 300' &
polkit_pid=$!
pids+=("$polkit_pid")
until_true 30 grep -q polkit-agent-helper-1 "/proc/$polkit_pid/cmdline" || fail "the stand-in polkit helper starts"
# The copy loaded as a module, for the pieces a run cannot reach.
cat >"$test_tmp/load.py" <<'PY'
import importlib.machinery, importlib.util, os, sys
loader = importlib.machinery.SourceFileLoader("face_key", os.environ["TEST_COPY"])
key = importlib.util.module_from_spec(importlib.util.spec_from_loader("face_key", loader))
loader.exec_module(key)
PY
export TEST_COPY="$copy" TEST_LOAD="$test_tmp/load.py"

TEST_TMP="$test_tmp" python3 - "$sudo_pid" "$$" "$polkit_pid" <<'PY' || fail "the service's pieces behave"
import os
exec(open(os.environ["TEST_LOAD"]).read())
conf = os.path.join(os.environ["TEST_TMP"], "face.conf")

def check(condition, description):
    if not condition:
        print(f"not ok - {description}", file=sys.stderr)
        sys.exit(1)

check(key.window_seconds() == 15 * 60, "the lock's wait ends with the policy's window")
for text, minutes in (("", 60), ("LOCK_WINDOW_MINUTES=0\n", 60), ("LOCK_WINDOW_MINUTES=1.5\n", 60), ("LOCK_WINDOW_MINUTES=2\n", 2)):
    open(conf, "w").write(text)
    check(key.window_seconds() == minutes * 60, f"window from {text!r} is {minutes} minutes, as the lock screen reads it")
os.remove(conf)
check(key.window_seconds() == 3600, "without a policy the window is an hour")

sudo_pid, test_pid, polkit_pid = (int(a) for a in sys.argv[1:])
check(key.beyond_sudo(sudo_pid) == test_pid, "the lock's conversation is whoever ran sudo")
check(key.beyond_sudo(test_pid) == test_pid, "a conversation that is not sudo stays itself")
check(key.describe(polkit_pid) == "a polkit dialog", "polkit's helper is described as its dialog")
check(key.has_key("2 0 0 0".split(), 193) and not key.has_key("0 2 0 0".split(), 193) and not key.has_key(["2"], 193),
      "the Copilot key is found in the kernel's capability bitmap")

# pam_exec runs the helper in a session of its own, without a terminal; the
# answer goes to the one the conversation reads, as sudo reads the user's.
import fcntl, subprocess, termios
master, slave = os.openpty()
reading = subprocess.Popen(["sleep", "30"], stdin=slave, start_new_session=True,
                           preexec_fn=lambda: fcntl.ioctl(0, termios.TIOCSCTTY, 0))
alone = subprocess.Popen(["sleep", "30"], stdin=subprocess.DEVNULL, start_new_session=True)
check(key.conversation_tty(reading.pid) == os.ttyname(slave), "the answer goes to the terminal the conversation reads")
check(key.conversation_tty(alone.pid) is None, "a conversation without a terminal, like polkit's helper, gets no typed answer")
real_stat = key.proc_stat
key.proc_stat = lambda pid: ["S", "1", "1", "1", str(os.makedev(136, 999999))]
try:
    key.conversation_tty(reading.pid)
    check(False, "a terminal without a node fails instead of offering a key that cannot answer")
except OSError:
    pass
key.proc_stat = real_stat
reading.kill()
alone.kill()

calls = []
key.fcntl.ioctl = lambda fd, request, arg: calls.append((request, arg))
for kill, typed in ((b"\x15", [b"\x15", b"\n"]), (b"\0", [b"\n"])):
    calls.clear()
    key.termios.tcgetattr = lambda fd, kill=kill: [0] * 6 + [{key.termios.VKILL: kill}]
    key.clear_and_submit(99)
    check([arg for _, arg in calls] == typed and all(request == key.termios.TIOCSTI for request, _ in calls),
          f"the key clears the line with its kill character {kill!r} and submits it empty")
PY
pass "the lock's window, the requester's name and sudo's terminal answer are computed as intended"

# The lock's policy, against a clock of the test's own. While the lock screen
# waits, nothing else is on screen, so the press is the lock's; it stays the
# lock's while the scan runs, gives way at once when the face opened the lock,
# and otherwise holds a few seconds more, as after a password unlock or a check
# a program ended. The lock's window runs from the first check root saw.
python3 - <<'PY' || fail "the lock screen holds the key and its window"
import os, sys
exec(open(os.environ["TEST_LOAD"]).read())

def check(condition, description):
    if not condition:
        print(f"not ok - {description}", file=sys.stderr)
        sys.exit(1)

clock = [0.0]
key.boottime = lambda: clock[0]
key.window_seconds = lambda: 60
key.LOCK_GRACE_S = 5
key.LOCK_SCAN_S = 15
key.log = lambda message: None

# A pipe stands in for the listener, so this runs where Unix sockets cannot.
class Listener:
    def __init__(self):
        self.fd, _ = os.pipe()

    def setblocking(self, flag):
        pass

    def fileno(self):
        return self.fd

class Conn:
    def __init__(self):
        self.sent = []
        self.closed = False

    def sendall(self, data):
        self.sent.append(data.decode().rstrip("\n"))

    def recv(self, size):
        return b""

    def fileno(self):
        return -1

    def close(self):
        self.closed = True

notified = []

def fresh():
    global server
    clock[0] = 1000.0
    server = key.Server(Listener())
    server.open_keyboards = lambda: None
    server.notify = lambda waiting: notified.append(len(waiting))

def connect():
    conn = Conn()
    server.buffers[conn] = b""
    return conn

def wait(kind, pam):
    conn = connect()
    server.handle(conn, ["WAIT", pam, "alice", kind, f"{kind} {pam}"])
    return conn

def done(pam, outcome):
    conn = connect()
    server.handle(conn, ["SCANNED", pam, outcome])
    return conn.sent

def left(conn):
    fields = conn.sent[0].split("\t")
    return fields[0] == "WAITING" and len(fields) == 2 and float(fields[1])

def after(seconds):
    clock[0] += seconds

fresh()
sudo = wait("prompt", "1:1")
check(sudo.sent == ["WAITING"], "a prompt registers without a window")
server.key_pressed()
check(sudo.sent[-1] == "KEY" and "1:1" in server.pressed, "with no lock about, the press releases the one waiting prompt")

fresh()
lock = wait("lock", "2:2")
check(left(lock) == 60, "the lock's first check gets the whole window")
sudo = wait("prompt", "3:3")
server.key_pressed()
check(lock.sent[-1] == "KEY", "with the lock waiting, the press goes to the lock")
check(sudo.sent[-1] == "LOCKED" and not sudo.closed and "3:3" not in server.pressed,
      "a prompt waiting beside the lock gets no press and keeps waiting")
after(3)
server.key_pressed()
check(sudo.sent[-1] == "LOCKED" and "3:3" not in server.pressed, "while the lock's scan runs, a lone prompt still gets no press")
check(done("2:2", "matched") == ["OK"], "the helper reports how the lock's scan ended")
server.key_pressed()
check(sudo.sent[-1] == "KEY", "once the face opened the lock, the key serves prompts at once")

fresh()
lock = wait("lock", "4:4")
sudo = wait("prompt", "5:5")
server.key_pressed()
after(2)
done("4:4", "failed")
after(4)
server.key_pressed()
check(sudo.sent[-1] == "LOCKED", "after a failed scan the key stays the lock's while its check comes back")
again = wait("lock", "6:6")
check(left(again) == 54, "the check that comes back keeps the lock's window")

fresh()
lock = wait("lock", "7:7")
sudo = wait("prompt", "8:8")
server.read_client(lock)
after(4)
server.key_pressed()
check(sudo.sent[-1] == "LOCKED", "for a moment after the lock's check went away, as at a password unlock, a lone prompt gets no press")
after(2)
server.key_pressed()
check(sudo.sent[-1] == "KEY", "a few seconds later the key serves prompts again")

fresh()
lock = wait("lock", "9:9")
sudo = wait("prompt", "10:10")
server.key_pressed()
after(19)
server.key_pressed()
check(sudo.sent[-1] == "LOCKED", "a scan that never reports holds the key for its bound and the grace")
after(2)
server.key_pressed()
check(sudo.sent[-1] == "KEY", "past that bound the key serves prompts again")

# A program ends the lock's check and waits with a check of its own through
# the lock's grant: the press goes to that check, and its match must not hand
# the next press to the program's sudo.
fresh()
real = wait("lock", "11:11")
sudo = wait("prompt", "12:12")
server.read_client(real)
fake = wait("lock", "13:13")
server.key_pressed()
check(fake.sent[-1] == "KEY", "the press goes to the one check of the lock left")
after(1)
done("13:13", "matched")
server.key_pressed()
check(sudo.sent[-1] == "LOCKED", "a match after a check of the lock went away unexplained does not free the key at once")
after(6)
server.key_pressed()
check(sudo.sent[-1] == "KEY", "it frees the key only once the grace has passed")

fresh()
first = wait("lock", "14:14")
after(59)
again = wait("lock", "14:14")
check(left(again) == 1, "a check asking again keeps the lock's window")
after(2)
server.key_pressed()
check(again.sent[-1] == "EXPIRED" and again.closed and "14:14" not in server.pressed,
      "past the lock's window, its check gets no press")
late = wait("lock", "15:15")
check(late.sent == ["EXPIRED"] and late.closed, "a check registering past the window is turned away")
after(6)
fresh_check = wait("lock", "16:16")
check(left(fresh_check) == 60, "once the lock is gone, the next lock's window starts afresh")

other = wait("lock", "17:17")
sudo = wait("prompt", "18:18")
server.key_pressed()
check(fresh_check.sent[-1].startswith("CONFLICT") and other.sent[-1].startswith("CONFLICT") and not fresh_check.closed and not other.closed,
      "two checks claiming the lock both keep waiting and are told why")
check(sudo.sent[-1] == "LOCKED", "the prompt beside them gets nothing either")
check(notified == [2], "the user is told which two waited")
PY
pass "the key is the lock's while it waits and scans, free at once after a face unlock, and a few seconds after anything else"

# The polkit dialog answers on Hyprland's copy of the press, which can reach
# the helper's take before this service has read the press from the keyboard;
# the take then waits a moment for it instead of refusing a real press.
python3 - <<'PY' || fail "a take that comes before the press waits for it"
import os, sys
exec(open(os.environ["TEST_LOAD"]).read())

def check(condition, description):
    if not condition:
        print(f"not ok - {description}", file=sys.stderr)
        sys.exit(1)

clock = [100.0]

class FakeTime:
    @staticmethod
    def monotonic():
        return clock[0]

key.time = FakeTime
key.boottime = lambda: clock[0]
key.log = lambda message: None

class Listener:
    def __init__(self):
        self.fd, _ = os.pipe()

    def setblocking(self, flag):
        pass

    def fileno(self):
        return self.fd

class Conn:
    def __init__(self):
        self.sent = []
        self.closed = False

    def sendall(self, data):
        self.sent.append(data.decode().rstrip("\n"))

    def recv(self, size):
        return b""

    def fileno(self):
        return -1

    def close(self):
        self.closed = True

server = key.Server(Listener())
server.open_keyboards = lambda: None

def connect():
    conn = Conn()
    server.buffers[conn] = b""
    return conn

def wait(pam):
    conn = connect()
    server.handle(conn, ["WAIT", pam, "alice", "prompt", f"a polkit dialog {pam}"])
    return conn

def take(pam):
    conn = connect()
    server.handle(conn, ["TAKE", pam])
    return conn

dialog = wait("1:1")
early = take("1:1")
check(early.sent == [] and not early.closed and not dialog.closed, "a take before the press waits, and so does its prompt")
server.key_pressed()
check(dialog.sent[-1] == "KEY" and early.sent == ["YES"] and early.closed, "the press that follows answers the take")
check("1:1" not in server.pressed, "the press it answered is consumed")

dialog = wait("2:2")
early = take("2:2")
clock[0] += key.TAKE_WAIT_S - 0.1
server.expire_takes()
check(early.sent == [], "the take keeps waiting within its bound")
clock[0] += 0.2
server.expire_takes()
check(early.sent == ["NO"] and early.closed and dialog.closed, "without a press in time the take is refused and its prompt dropped")

check(take("3:3").sent == ["NO"], "a take for a prompt that is not waiting is refused at once")

dialog = wait("4:4")
server.key_pressed()
late = take("4:4")
check(late.sent == ["YES"], "a take after the press is answered at once, as before")
PY
pass "a take that reaches the service before its press waits a moment for it"

# The service speaks over a Unix socket; a sandbox without them cannot run it.
if ! python3 -c 'import socket; socket.socket(socket.AF_UNIX).close()' 2>/dev/null; then
  skip "Unix sockets are unavailable here; the service itself is not exercised"
  exit 0
fi

python3 "$copy" serve 2>"$service_log" 7<&- &
service=$!
pids+=("$service")
until_true 30 test -S "$test_tmp/key.sock" || fail "the service listens" "$(cat "$service_log")"
[[ $(stat -c %a "$test_tmp/key.sock") == 600 ]] || fail "only the service's own account may connect" "$(stat -c %a "$test_tmp/key.sock")"
not_reading event3 || fail "the keyboard stays closed while nothing waits"
pass "the service listens on a private socket and leaves the keyboard alone while nothing waits"

prompt
a=$prompt_pid
waiter "$a"
wa=$waiter_pid
until_true 30 reading event3 || fail "a waiting prompt opens the keyboard" "$(cat "$service_log")"
not_reading event4 || fail "a uinput keyboard under /devices/virtual is never read"
not_reading event5 || fail "a keyboard without the Copilot key is never read"
grep -q 'sleep 300 (from bash) waits for the key' "$service_log" || fail "each waiting prompt is logged with its requester" "$(cat "$service_log")"
event 0
event 2
event 1 28
sleep 0.3
running "$wa" || fail "a release, an autorepeat or another key is no press" "$(cat "$test_tmp/waiter-$a")"
event 1
exited_with "$wa" 0 || fail "the Copilot key releases the one waiting prompt" "$(cat "$test_tmp/waiter-$a" "$service_log")"
key_take "$a" || fail "the prompt the key released may take the press"
key_take "$a" && fail "a press serves one scan only"
until_true 30 not_reading event3 || fail "the keyboard closes again once nothing waits"
pass "only a Copilot key press on a physical keyboard releases a waiting prompt, once"

prompt
b=$prompt_pid
waiter "$b"
wb=$waiter_pid
until_true 30 reading event3 || fail "the next prompt reopens the keyboard"
key_take "$b" && fail "a prompt answered without the key gets no scan"
exited_with "$wb" 1 || fail "an answered prompt stops waiting" "$(cat "$test_tmp/waiter-$b")"
prompt
c=$prompt_pid
waiter "$c"
wc=$waiter_pid
until_true 30 reading event3 || fail "a prompt waits again"
python3 "$copy" drop --pam-pid "$c" || fail "dropping a prompt succeeds"
exited_with "$wc" 1 || fail "a prompt answered with a password stops waiting" "$(cat "$test_tmp/waiter-$c")"
prompt
d=$prompt_pid
waiter "$d"
wd=$waiter_pid
until_true 30 reading event3 || fail "a prompt waits once more"
kill "$d"
exited_with "$wd" 1 || fail "a prompt whose conversation ended stops waiting" "$(cat "$test_tmp/waiter-$d")"
prompt
r=$prompt_pid
waiter "$r"
first=$waiter_pid
until_true 30 reading event3 || fail "a prompt waits before asking again"
waiter "$r"
second=$waiter_pid
exited_with "$first" 1 || fail "a conversation asking again replaces its earlier prompt" "$(cat "$service_log")"
event 1
exited_with "$second" 0 || fail "the prompt that replaced it gets the key alone" "$(cat "$service_log")"
key_take "$r" || fail "the replacing prompt may take the press"
pass "a prompt stops waiting once it is answered, dropped, gone or asked again"

: >"$log"
waits=$(grep -c 'waits for the key' "$service_log")
prompt
e=$prompt_pid
prompt
f=$prompt_pid
waiter "$e"
we=$waiter_pid
waiter "$f"
wf=$waiter_pid
until_true 30 logged_at_least 'waits for the key' $((waits + 2)) || fail "both prompts wait" "$(cat "$service_log")"
event 1
until_true 30 logged_at_least 'key refused' 1 || fail "the press is refused" "$(cat "$service_log")"
{ running "$we" && running "$wf"; } || fail "a press with two prompts waiting releases neither, and both keep waiting" "$(cat "$service_log")"
key_take "$e" && fail "neither of two waiting prompts may take the press"
until_true 30 grep -q 'Face scan refused' "$log" || fail "the user is notified" "$(cat "$log")"
grep -q "setpriv --reuid=$(id -u) --regid=$(id -g) --init-groups /usr/bin/omarchy-notification-send -u critical" "$log" ||
  fail "the notification runs as the user" "$(cat "$log")"
(( $(grep -c '^• sleep 300 (from bash)' "$log") == 2 )) || fail "the notification names both requesters" "$(cat "$log")"
exited_with "$we" 1 || fail "the prompt answered without the key stops waiting"
event 1
exited_with "$wf" 0 || fail "once one prompt is left, the key releases it" "$(cat "$test_tmp/waiter-$f" "$service_log")"
pass "a press with several prompts waiting serves none, keeps them waiting and names them to the user"

terminal_prompt
g=$prompt_pid
presses=$(grep -c 'key pressed for' "$service_log")
start=$(date +%s%N)
setsid -w python3 "$copy" wait --pam-pid "$g" --user "$me" --detach --tty </dev/null >/dev/null 2>&1 7<&- ||
  fail "a detached prompt registers and returns"
(( ($(date +%s%N) - start) < 2000000000 )) || fail "registering does not wait for the key"
until_true 30 reading event3 || fail "the detached prompt waits"
detached=$(pgrep -f -- "wait --pam-pid $g --user") || fail "the detached prompt keeps running"
holds "$detached" "$prompt_tty" ||
  fail "the detached prompt, in a session of its own like pam_exec's child, holds the terminal the conversation reads" "$(ls -l "/proc/$detached/fd")"
event 1
until_true 30 logged_at_least 'key pressed for' $((presses + 1)) || fail "the detached prompt is released" "$(cat "$service_log")"
key_take "$g" || fail "the detached prompt's press is there for the helper to take"
pass "a detached prompt keeps waiting in the background and its press can be taken"

prompt
t=$prompt_pid
waiter "$t"
wt=$waiter_pid
until_true 30 reading event3 || fail "a polkit-like prompt waits" "$(cat "$service_log")"
key_take "$t" &
taker=$!
pids+=("$taker")
sleep 0.3
running "$taker" || fail "a take that comes before the press waits for it"
event 1
exited_with "$taker" 0 || fail "the press that follows answers the take" "$(cat "$service_log")"
exited_with "$wt" 0 || fail "the prompt is released by the same press"
pass "a take that reaches the service before its press, as the polkit dialog's may, still gets it"

prompt
status=0
timeout 5 bash -c "python3 '$copy' wait --lock --pam-pid $prompt_pid --user $me | true" 2>"$test_tmp/closed.err" || status=$?
(( status != 124 )) || fail "a lock prompt whose conversation closed its end stops waiting"
[[ ! -s $test_tmp/closed.err ]] || fail "a lock prompt whose conversation closed its end leaves quietly" "$(cat "$test_tmp/closed.err")"

# The closed check's grace passes first, so the next lock starts clean.
sleep 1.2
prompt
p=$prompt_pid
waiter "$p"
wp=$waiter_pid
prompt
l=$prompt_pid
waiter "$l" --lock
wl=$waiter_pid
until_true 30 grep -qxF "Waiting for the Copilot key" "$test_tmp/waiter-$l" ||
  fail "the lock's check says once root registered it" "$(cat "$test_tmp/waiter-$l" "$service_log")"
event 1
exited_with "$wl" 0 || fail "the press goes to the lock screen's check" "$(cat "$test_tmp/waiter-$l" "$service_log")"
event 1
sleep 0.3
running "$wp" || fail "while the lock's scan runs, a press does not release the prompt beside it" "$(cat "$service_log")"
until_true 30 logged_at_least 'the lock screen holds the key' 1 || fail "the refused press is logged" "$(cat "$service_log")"
python3 "$copy" scanned --lock --pam-pid "$l" --status 0 || fail "the helper reports how the lock's scan ended"
event 1
exited_with "$wp" 0 || fail "once the face opened the lock, the key serves the prompt at once" "$(cat "$service_log")"
pass "the lock screen's check says when it waits, takes the press over any prompt, and gives the key back as soon as the face opened the lock"

prompt
p=$prompt_pid
waiter "$p"
wp=$waiter_pid
prompt
l=$prompt_pid
waiter "$l" --lock
wl=$waiter_pid
until_true 30 grep -qxF "Waiting for the Copilot key" "$test_tmp/waiter-$l" || fail "the lock's check waits again" "$(cat "$service_log")"
kill "$l"
exited_with "$wl" 1 || fail "a check whose conversation ended stops waiting"
event 1
sleep 0.3
running "$wp" || fail "for a moment after the lock's check went away, a press does not release the prompt beside it" "$(cat "$service_log")"
sleep 1.2
event 1
exited_with "$wp" 0 || fail "a moment later the key serves the prompt again" "$(cat "$service_log")"
pass "after the lock's check went away without a scan, the key is the lock's for a moment only"

prompt
q=$prompt_pid
prompt
s=$prompt_pid
waiter "$q" --lock
wq=$waiter_pid
waiter "$s" --lock
ws=$waiter_pid
until_true 30 grep -qxF "Waiting for the Copilot key" "$test_tmp/waiter-$s" || fail "both checks wait" "$(cat "$service_log")"
until_true 30 grep -qxF "Waiting for the Copilot key" "$test_tmp/waiter-$q" || fail "both checks wait" "$(cat "$service_log")"
event 1
until_true 30 grep -qxF "Face refused: another program is waiting for the Copilot key too" "$test_tmp/waiter-$q" ||
  fail "the lock screen is told why its face was refused" "$(cat "$test_tmp/waiter-$q")"
{ running "$wq" && running "$ws"; } || fail "two checks claiming the lock both keep waiting"
kill "$s"
exited_with "$ws" 1 || fail "a check whose conversation ended stops waiting"
event 1
exited_with "$wq" 0 || fail "once one check is left, the key releases it" "$(cat "$service_log")"
pass "two checks claiming the lock screen get no press and are told why"

until_true 100 gone "$service" || fail "the service exits once nothing has waited for a while"
pass "the service idles out, so it only runs while a prompt offers the face"
