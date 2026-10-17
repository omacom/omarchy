#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command bwrap
if ! bwrap_works; then
  skip "bubblewrap cannot create a sandbox here; skipping the agent seat sandbox"
  exit 0
fi
require_command jq
require_command python3

# The seat commands find their sandbox supervisor under $OMARCHY_PATH.
export OMARCHY_PATH="$ROOT"

real_home=$HOME
real_runtime=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
test_dir=$(mktemp -d)
home="$test_dir/home"
runtime="$test_dir/runtime"
seat="$runtime/omarchy/agent-seat"
mkdir -p "$test_dir/bin" "$test_dir/out" "$test_dir/scratch" "$runtime" "$home/vault/ssh" \
  "$home/.gnupg" "$home/.config/app" "$home/.local/share/keyrings"
# A private directory kept elsewhere and linked into place.
ln -s vault/ssh "$home/.ssh"
# What the user, their session or an agent runs outside the sandbox, with one
# startup file kept in a dotfiles directory.
mkdir -p "$home/.local/bin" "$home/.local/share/applications" "$home/.local/share/systemd/user" "$home/.local/share/mise/shims" \
  "$home/.local/share/omarchy/bin" "$home/.local/state/omarchy/toggles" "$home/.claude/hooks" "$home/.codex" "$home/.pi" \
  "$home/.grok" "$home/.gemini" "$home/.cursor" "$home/dotfiles"
touch "$home/.claude.json" "$home/.profile" "$home/.bashrc" "$home/.bash_profile" "$home/.zshenv" "$home/.zshrc" "$home/.gitconfig" "$home/dotfiles/zprofile"
ln -s dotfiles/zprofile "$home/.zprofile"
echo "canary" >"$home/canary"
echo "scratch" >"$test_dir/scratch/file"
echo "secret" >"$test_dir/secret"

cleanup() {
  local record pid

  # Only the sandboxes this test started: their records live in its own runtime.
  for record in "$seat"/sandboxes/sandbox.*; do
    [[ -e $record ]] || continue
    read -r pid _ <"$record" || continue
    [[ $pid =~ ^[0-9]+$ ]] && kill "$pid" 2>/dev/null
  done
  [[ -n ${launcher_pid:-} ]] && kill "$launcher_pid" 2>/dev/null
  [[ -n ${swapper_pid:-} ]] && kill "$swapper_pid" 2>/dev/null
  [[ -n ${silent_pid:-} ]] && kill "$silent_pid" 2>/dev/null
  [[ -n ${broker_pid:-} ]] && kill "$broker_pid" 2>/dev/null
  [[ -n ${compositor_pid:-} ]] && kill "$compositor_pid" 2>/dev/null
  # A broker a launch started; the shim execs it, so its pid is the broker's.
  [[ -s $test_dir/slow-broker/pid ]] && kill "$(<"$test_dir/slow-broker/pid")" 2>/dev/null
  wait 2>/dev/null
  chmod -R u+w "$test_dir" 2>/dev/null
  rm -rf "$test_dir"
}
trap cleanup EXIT

# The broker asks Hyprland where agent windows are; there is no Hyprland here.
printf '#!/bin/bash\necho "[]"\n' >"$test_dir/bin/hyprctl"
chmod +x "$test_dir/bin/hyprctl"

# A fake Hyprland for the broker to forward windows to: it advertises a
# compositor and xdg_wm_base and answers wl_display.sync, nothing more.
cat >"$test_dir/compositor.py" <<'EOF'
import socket, struct, sys, threading

def string(text):
    data = text.encode() + b"\0"
    return struct.pack("<I", len(data)) + data + b"\0" * (-len(data) % 4)

def message(object_id, opcode, body=b""):
    return struct.pack("<II", object_id, (8 + len(body)) << 16 | opcode) + body

def serve(sock):
    buffer = b""
    try:
        while data := sock.recv(65536):
            buffer += data
            while len(buffer) >= 8 and len(buffer) >= struct.unpack_from("<II", buffer)[1] >> 16:
                object_id, word = struct.unpack_from("<II", buffer)
                body, buffer = buffer[8 : word >> 16], buffer[word >> 16 :]
                if object_id == 1 and word & 0xFFFF == 1:
                    registry = struct.unpack("<I", body)[0]
                    for name, interface, version in ((1, "wl_compositor", 4), (2, "xdg_wm_base", 2)):
                        sock.sendall(message(registry, 0, struct.pack("<I", name) + string(interface) + struct.pack("<I", version)))
                elif object_id == 1 and word & 0xFFFF == 0:
                    callback = struct.unpack("<I", body)[0]
                    sock.sendall(message(callback, 0, struct.pack("<I", 0)) + message(1, 1, struct.pack("<I", callback)))
    except OSError:
        pass  # the broker dropped this app
    sock.close()

server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
server.bind(sys.argv[1])
server.listen(16)
while True:
    threading.Thread(target=serve, args=(server.accept()[0],), daemon=True).start()
EOF
python3 "$test_dir/compositor.py" "$runtime/compositor" 2>"$test_dir/compositor.log" &
compositor_pid=$!
for _ in {1..50}; do [[ -S $runtime/compositor ]] && break; sleep 0.1; done
[[ -S $runtime/compositor ]] || fail "the fake compositor starts" "$(cat "$test_dir/compositor.log")"

# env execs the command, so a background launch's $! is the command itself.
on_seat=(env HOME="$home" XDG_RUNTIME_DIR="$runtime" WAYLAND_DISPLAY=compositor PATH="$test_dir/bin:$ROOT/bin:$PATH")

# A share that slipped through must not start a broker this test can't end,
# so these launches find a broker that refuses to serve.
mkdir -p "$test_dir/no-broker"
printf '#!/bin/bash\nexit 1\n' >"$test_dir/no-broker/omarchy-agent-seat-broker"
chmod +x "$test_dir/no-broker/omarchy-agent-seat-broker"

refused() {
  local output

  output=$("${on_seat[@]}" PATH="$test_dir/no-broker:$ROOT/bin:$PATH" omarchy-agent-seat-run "$@" /usr/bin/true 2>&1) && return 1
  [[ $output == "Refusing "* ]]
}

for path in / "$home" /tmp "$runtime" "$real_runtime" "$home/.ssh" "$home/.gnupg" "$home/.config/app" "$home/.local/share/keyrings" "$home/.local" /proc/self /dev; do
  refused --share "$path" || fail "sharing $path is refused"
  refused --share-ro "$path" || fail "sharing $path read-only is refused"
done
[[ ! -e $seat ]] || fail "a refused share starts nothing"
pass "shares of the root, home, /tmp, runtime directories, /proc, /dev and private config are refused"

ran_outside=("$home/.local/bin" "$home/.local/share/applications" "$home/.local/share/systemd/user" "$home/.local/share/mise/shims"
  "$home/.local/share/omarchy" "$home/.local/state/omarchy/toggles" "$home/.claude" "$home/.claude/hooks" "$home/.claude.json"
  "$home/.codex" "$home/.pi" "$home/.grok" "$home/.gemini" "$home/.cursor" "$home/.profile" "$home/.bashrc" "$home/.bash_profile"
  "$home/.zshenv" "$home/.zshrc" "$home/.zprofile" "$home/dotfiles" "$home/dotfiles/zprofile" "$home/.gitconfig")
[[ -e /run/dbus ]] && ran_outside+=(/run/dbus)
for path in "${ran_outside[@]}"; do
  refused --share "$path" || fail "sharing $path is refused"
  refused --share-ro "$path" || fail "sharing $path read-only is refused"
done
[[ ! -e $seat ]] || fail "a refused share starts nothing"
pass "shares of startup files, ~/.local/bin, desktop entries, Omarchy's trees, the agents' homes and the system bus are refused"

for path in "$home/.ssh" "$home/.ssh/" "$home/vault/ssh" "$home/vault"; do
  refused --share "$path" || fail "a linked private directory is refused: $path"
  refused --share-ro "$path" || fail "a linked private directory is refused read-only: $path"
done
pass "a linked private directory is refused by its link, its target and the directory holding it"

printf '#!/bin/bash\n' >"$home/.config/app/tool"
chmod +x "$home/.config/app/tool"
output=$("${on_seat[@]}" PATH="$test_dir/no-broker:$ROOT/bin:$PATH" omarchy-agent-seat-run "$home/.config/app/tool" 2>&1) && fail "a program inside ~/.config is refused"
[[ $output == "Refusing "* ]] || fail "a program inside ~/.config is refused" "$output"
pass "a program inside ~/.config is refused"

printf '#!/bin/bash\n' >"$home/.claude/hooks/tool"
chmod +x "$home/.claude/hooks/tool"
output=$("${on_seat[@]}" PATH="$test_dir/no-broker:$ROOT/bin:$PATH" omarchy-agent-seat-run "$home/.claude/hooks/tool" 2>&1) && fail "a program inside an agent's home is refused"
[[ $output == "Refusing "* ]] || fail "a program inside an agent's home is refused" "$output"
pass "a program inside an agent's home is refused"

output=$("${on_seat[@]}" omarchy-agent-seat-windows 2>/dev/null) && fail "windows fails while no broker runs" "$output"
[[ -z $output ]] || fail "windows prints nothing while no broker runs" "$output"
pass "windows fails while no broker runs"

"${on_seat[@]}" omarchy-agent-seat-broker serve 2>"$test_dir/broker.log" &
broker_pid=$!
for _ in {1..50}; do [[ -S $seat/wayland-0 ]] && break; sleep 0.1; done
[[ -S $seat/wayland-0 ]] || fail "the broker starts" "$(cat "$test_dir/broker.log")"

output=$("${on_seat[@]}" omarchy-agent-seat-windows) || fail "windows succeeds on a seat with no apps" "$output"
[[ $(jq -c . <<<"$output") == "[]" ]] || fail "windows lists no windows on a seat with no apps" "$output"
pass "windows lists no windows on a seat with no apps"

# Runs a headless command on the seat and waits for its sandbox to end.
run_headless() {
  "${on_seat[@]}" omarchy-agent-seat-run --no-wait "$@" || return 1
  for _ in {1..100}; do
    compgen -G "$seat/sandboxes/sandbox.*" >/dev/null || return 0
    sleep 0.05
  done
  return 1
}

# Lives in the test directory under /tmp, beside the fake home and runtime, so
# binding its directory would hand all of that to the sandbox.
cat >"$test_dir/probe" <<'EOF'
#!/bin/bash
out=$1 scratch=$2 test_dir=$3 real_home=$4 real_runtime=$5 signature=$6
{
  [[ -e $HOME/canary || -e $test_dir/home/canary ]] && echo "home visible"
  [[ -e $real_home ]] && echo "user home visible"
  [[ -e /run/user ]] && echo "/run/user visible"
  [[ -e $real_runtime ]] && echo "real runtime visible"
  [[ -e /tmp/.X11-unix ]] && echo "X11 visible"
  [[ -e $XDG_RUNTIME_DIR/hypr || -e $real_runtime/hypr ]] && echo "hypr visible"
  [[ -e $XDG_RUNTIME_DIR/bus || -e $real_runtime/bus ]] && echo "D-Bus visible"
  [[ -e $XDG_RUNTIME_DIR/keyring || -e $real_runtime/keyring/control ]] && echo "keyring visible"
  [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] && echo "Hyprland signature set"
  if [[ -n $signature ]] && HYPRLAND_INSTANCE_SIGNATURE=$signature XDG_RUNTIME_DIR=$real_runtime hyprctl -j monitors >/dev/null 2>&1; then
    echo "hyprctl reaches Hyprland"
  fi
  echo "runtime: $(ls -A "$XDG_RUNTIME_DIR" | tr '\n' ' ')"
  [[ -e $(dirname "$0")/secret ]] && echo "probe directory visible"
  echo "scratch: $(cat "$scratch/file")"
  touch "$scratch/new" 2>/dev/null && echo "scratch writable"
  echo "done"
} >"$out/result" 2>&1
EOF
chmod +x "$test_dir/probe"

run_headless --share "$test_dir/out" --share-ro "$test_dir/scratch" "$test_dir/probe" \
  "$test_dir/out" "$test_dir/scratch" "$test_dir" "$real_home" "$real_runtime" "${HYPRLAND_INSTANCE_SIGNATURE:-}" ||
  fail "a headless probe runs in the sandbox" "$(cat "$seat/apps.log" 2>/dev/null)"
result=$(cat "$test_dir/out/result" 2>/dev/null)
[[ $result == *"done"* ]] || fail "the probe reports back through a shared directory" "$result $(cat "$seat/apps.log" 2>/dev/null)"
pass "a shared directory is writable from the sandbox"

for leak in "home visible" "user home visible" "/run/user visible" "real runtime visible" "X11 visible" \
  "hypr visible" "D-Bus visible" "keyring visible" "Hyprland signature set" "hyprctl reaches Hyprland"; do
  [[ $result != *"$leak"* ]] || fail "the sandbox hides the user's session: $leak" "$result"
done
grep -qx "runtime: agent-bus wayland-0 " <<<"$result" || fail "the sandbox's runtime directory holds only the broker socket and its private bus" "$result"
pass "the sandbox sees no home, X11, Hyprland, D-Bus or keyring, and only the broker socket and its private bus"

[[ $result != *"probe directory visible"* ]] || fail "a program outside /usr gets only its own file" "$result"
pass "a program outside /usr gets only its own file, not its directory"

# ~/.local/bin cannot be shared, but a program in it still runs.
printf '#!/bin/bash\necho "ran" >"$1/local-bin"\n' >"$home/.local/bin/tool"
chmod +x "$home/.local/bin/tool"
run_headless --share "$test_dir/out" "$home/.local/bin/tool" "$test_dir/out" ||
  fail "a program in ~/.local/bin runs on the seat" "$(cat "$seat/apps.log" 2>/dev/null)"
[[ $(cat "$test_dir/out/local-bin" 2>/dev/null) == "ran" ]] || fail "a program in ~/.local/bin runs on the seat" "$(cat "$seat/apps.log" 2>/dev/null)"
pass "a program in ~/.local/bin runs on the seat, though the directory cannot be shared"

# The private bus runs outside the sandbox, which gets its socket alone, read-only:
# no directory of the user's runtime to write in, and no socket to swap for a
# link the seat's own reader would follow to another bus.
if [[ -x /usr/bin/dbus-daemon ]]; then
  rm -f "$test_dir/out/bus" "$test_dir/out/bus-go"
  "${on_seat[@]}" omarchy-agent-seat-run --no-wait --share "$test_dir/out" /usr/bin/bash -c '
    bus=$XDG_RUNTIME_DIR/agent-bus
    {
      [[ -S $bus/bus ]] && echo "socket"
      echo "beside: $(ls -A "$bus" | tr "\n" " ")"
      echo "mount: $(findmnt -T "$bus/bus" -no TARGET,OPTIONS | cut -d, -f1)"
      echo "directory mount: $(findmnt -T "$bus" -no TARGET)"
      dbus-send --session --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.GetId >/dev/null 2>&1 && echo "bus answers"
      touch "$bus/planted" 2>/dev/null
      mv "$bus/bus" "$bus/moved" 2>/dev/null && ln -s /elsewhere "$bus/bus" 2>/dev/null && echo "socket replaced"
    } >"$1/bus.tmp" 2>&1
    mv "$1/bus.tmp" "$1/bus"
    until [[ -e $1/bus-go ]]; do sleep 0.05; done' _ "$test_dir/out" ||
    fail "an app with a private bus starts" "$(cat "$seat/apps.log" 2>/dev/null)"
  for _ in {1..100}; do [[ -e $test_dir/out/bus ]] && break; sleep 0.05; done
  bus_report=$(cat "$test_dir/out/bus" 2>/dev/null)
  sessions=("$seat"/sandboxes/*.d)
  host_side=$(ls -A "${sessions[0]}/bus" 2>&1 | tr '\n' ' ')
  supervisor=$(cat "$seat"/sandboxes/sandbox.* 2>/dev/null | cut -d" " -f1)
  daemons=$(pgrep -P "$supervisor" -x 'dbus-daemon|at-spi2-registr' | tr '\n' ' ')
  touch "$test_dir/out/bus-go"
  for _ in {1..100}; do
    compgen -G "$seat/sandboxes/sandbox.*" >/dev/null || break
    sleep 0.05
  done
  grep -qx "socket" <<<"$bus_report" && grep -qx "beside: bus " <<<"$bus_report" && grep -qx "bus answers" <<<"$bus_report" ||
    fail "the app reaches its private bus through the socket alone" "$bus_report"
  grep -qx "mount: $runtime/agent-bus/bus ro" <<<"$bus_report" ||
    fail "the private bus's socket is bound read-only, by itself" "$bus_report"
  grep -q "^directory mount: .*agent-bus$" <<<"$bus_report" && fail "no directory of the user's runtime is bound into the sandbox" "$bus_report"
  [[ $bus_report != *"socket replaced"* && $host_side == "bus " ]] ||
    fail "the app can neither replace the socket nor write beside it" "$bus_report host: $host_side"
  [[ $(wc -w <<<"$daemons") == 2 ]] || fail "the bus and the registry run outside the sandbox, under its supervisor" "$daemons"
  for pid in $daemons; do
    kill -0 "$pid" 2>/dev/null && fail "the bus and the registry end with their sandbox" "$(ps -o pid,cmd -p "$pid")"
  done
  pass "the private bus runs outside the sandbox, which gets its socket alone, read-only"
fi

grep -qx "scratch: scratch" <<<"$result" || fail "a read-only share is readable" "$result"
[[ $result != *"scratch writable"* && ! -e $test_dir/scratch/new ]] || fail "a read-only share is not writable" "$result"
pass "a read-only share of a scratch directory is readable and not writable"

# An app bundle keeps its libraries and resources beside the executable.
mkdir -p "$test_dir/opt/app/lib" "$test_dir/opt/tool"
printf '#!/bin/bash\nls -A "$(dirname "$0")" >"%s/bundle"\n' "$test_dir/out" >"$test_dir/opt/app/app"
cp "$test_dir/opt/app/app" "$test_dir/opt/tool/tool"
sed -i 's|/bundle"|/plain"|' "$test_dir/opt/tool/tool"
touch "$test_dir/opt/tool/data"
chmod +x "$test_dir/opt/app/app" "$test_dir/opt/tool/tool"
run_headless --share "$test_dir/out" "$test_dir/opt/app/app" || fail "a bundled app runs"
run_headless --share "$test_dir/out" "$test_dir/opt/tool/tool" || fail "a lone program runs"
[[ $(tr '\n' ' ' <"$test_dir/out/bundle") == "app lib " ]] || fail "an app bundle gets its directory" "$(cat "$test_dir/out/bundle")"
[[ $(tr '\n' ' ' <"$test_dir/out/plain") == "tool " ]] || fail "a directory that is no bundle stays hidden" "$(cat "$test_dir/out/plain")"
pass "an app bundle gets its directory, other programs only their file"

# An app with a writable share of a projects directory can swap an approved
# project in it for a link to ~/.ssh while a launch sharing that project waits
# its turn. The sandbox still gets the directory that was checked, and none of
# the files the launcher holds open reaches the app.
mkdir -p "$test_dir/projects/site"
echo "site" >"$test_dir/projects/site/index.html"
echo "note" >"$test_dir/note"
echo "key" >"$home/vault/ssh/id_ed25519"
cat >"$test_dir/peek" <<'EOF'
#!/bin/bash
{
  echo "site: $(ls -A "$2" | tr '\n' ' ')"
  echo "note: $(cat "$3")"
  echo "fds: $(ls /proc/self/fd | sort -n | tr '\n' ' ')"
} >"$1/peek" 2>&1
EOF
chmod +x "$test_dir/peek"
exec {held}>"$seat/launch.lock"
flock "$held"
# The launch gets none of this test's own descriptors, so any the app holds
# are the launcher's.
"${on_seat[@]}" omarchy-agent-seat-run --no-wait --share "$test_dir/out" --share "$test_dir/projects/site" --share-ro "$test_dir/note" \
  "$test_dir/peek" "$test_dir/out" "$test_dir/projects/site" "$test_dir/note" >"$test_dir/race" 2>&1 {held}>&- &
launcher_pid=$!
# The launch opens the lock right after checking its shares, then waits on it.
for _ in {1..100}; do
  [[ -e /proc/$launcher_pid/fd/8 ]] && break
  sleep 0.05
done
[[ -e /proc/$launcher_pid/fd/8 ]] || fail "a launch waits for the launch lock" "$(cat "$test_dir/race")"
mv "$test_dir/projects/site" "$test_dir/projects/site.checked"
ln -s "$home/.ssh" "$test_dir/projects/site"
flock -u "$held"
exec {held}>&-
wait "$launcher_pid" || fail "a launch whose share was swapped while it waited goes ahead" "$(cat "$test_dir/race")"
launcher_pid=
for _ in {1..100}; do
  compgen -G "$seat/sandboxes/sandbox.*" >/dev/null || break
  sleep 0.05
done
result=$(cat "$test_dir/out/peek" 2>/dev/null)
grep -qx "site: index.html " <<<"$result" || fail "a share swapped for a link after its check mounts the checked directory, not the link's target" "$result $(cat "$seat/apps.log" 2>/dev/null)"
grep -qx "note: note" <<<"$result" || fail "a shared file is readable" "$result"
grep -qx "fds: 0 1 2 3 " <<<"$result" || fail "the app inherits no descriptor the launcher opened" "$result"
pass "a share swapped for a link to ~/.ssh after its check still mounts the checked directory, and its descriptor stays out of the app"

# A FIFO with no writer would hold a plain open, and so the launch, forever.
# One shared outright is refused at once. One an app swaps in for a shared
# file between the launcher's check and its open is refused too: the
# launcher's own pin, run here while a file and a FIFO take turns at one path
# as fast as they can, is refused or pins the file but never blocks.
mkfifo "$test_dir/pipe"
started=${EPOCHREALTIME/./}
output=$(timeout 10 "${on_seat[@]}" PATH="$test_dir/no-broker:$ROOT/bin:$PATH" omarchy-agent-seat-run --share-ro "$test_dir/pipe" /usr/bin/true 2>&1) &&
  fail "sharing a FIFO is refused"
[[ $output == "Refusing "* ]] || fail "sharing a FIFO is refused" "$output"
((${EPOCHREALTIME/./} - started < 2000000)) || fail "sharing a FIFO is refused at once" "$output"
mkdir -p "$test_dir/swaps"
echo "pinned" >"$test_dir/swaps/file"
mkfifo "$test_dir/swaps/pipe"
python3 - "$test_dir/swaps" <<'EOF' &
import os, sys
os.chdir(sys.argv[1])
while True:
    for kind in ("pipe", "file"):
        os.link(kind, "next")
        os.rename("next", "share")
EOF
swapper_pid=$!
for _ in {1..100}; do [[ -e $test_dir/swaps/share ]] && break; sleep 0.05; done
output=$(timeout 10 bash -c '
  eval "$(sed -n "/^pinned=()\$/,/^}\$/p; /^unpin() {\$/,/^}\$/p" "$1")"
  tries=0
  until ((SECONDS >= 2)); do
    if pin "$2"; then
      [[ $(<"/proc/self/fd/$pinned_fd") == "pinned" ]] || echo "pinned something else"
    fi
    unpin
    tries=$((tries + 1))
  done
  echo "tries: $tries"' _ "$ROOT/bin/omarchy-agent-seat-run" "$test_dir/swaps/share" 2>&1)
status=$?
kill "$swapper_pid"
wait "$swapper_pid" 2>/dev/null
swapper_pid=
((status == 0)) || fail "a FIFO swapped in for a shared file after its check never blocks the launch" "status $status: $output"
[[ $output =~ ^tries:\ [1-9] ]] || fail "a FIFO swapped in for a shared file after its check is refused or the file is pinned" "$output"
pass "a FIFO shared or swapped in for a shared file after its check is refused at once, never waited on"

# A descriptor the caller leaves open does not reach the app.
cat >"$test_dir/fds" <<'EOF'
#!/bin/bash
echo "fds: $(ls /proc/self/fd | sort -n | tr '\n' ' ')" >"$1/fds"
EOF
chmod +x "$test_dir/fds"
run_headless --share "$test_dir/out" "$test_dir/fds" "$test_dir/out" 7<"$test_dir/note" ||
  fail "a launch with an inherited descriptor runs" "$(cat "$seat/apps.log" 2>/dev/null)"
result=$(cat "$test_dir/out/fds" 2>/dev/null)
grep -qx "fds: 0 1 2 3 " <<<"$result" || fail "the app inherits no descriptor the caller left open" "$result"
pass "a descriptor the caller leaves open does not reach the app"

# A file shared read-write is changed in place, and the files beside it stay
# hidden.
echo "draft" >"$test_dir/draft"
run_headless --share "$test_dir/draft" /usr/bin/bash -c '
  if [[ -e ${1%/*}/note ]]; then
    echo "note visible" >>"$1"
  else
    echo "written" >>"$1"
  fi' _ "$test_dir/draft" ||
  fail "an app with a shared file runs" "$(cat "$seat/apps.log" 2>/dev/null)"
[[ $(<"$test_dir/draft") == $'draft\nwritten' ]] || fail "a file shared read-write is written through, alone in its directory" "$(cat "$test_dir/draft")"
pass "a file shared read-write is written through from the sandbox, and the files beside it stay hidden"

# A repository shared read-write keeps its .git read-only, so the app edits
# the work tree but plants no hook git would run later; a worktree's .git file
# cannot be pointed elsewhere either.
mkdir -p "$test_dir/repo/.git/hooks" "$test_dir/worktree"
echo "draft" >"$test_dir/repo/file"
echo "gitdir: $test_dir/repo/.git" >"$test_dir/worktree/.git"
run_headless --share "$test_dir/repo" --share "$test_dir/worktree" /usr/bin/bash -c '
  echo "edited" >>"$1/file"
  echo "planted" >"$1/.git/hooks/pre-commit"
  mv "$1/.git" "$1/moved"
  rm -rf "$1/.git"
  mkdir -p "$1/.git/hooks" && echo "planted" >"$1/.git/hooks/post-checkout"
  echo "gitdir: /tmp/elsewhere" >"$2/.git"
  mv "$2/.git" "$2/moved"' _ "$test_dir/repo" "$test_dir/worktree" ||
  fail "an app with a repository shared runs" "$(cat "$seat/apps.log" 2>/dev/null)"
[[ $(<"$test_dir/repo/file") == $'draft\nedited' ]] || fail "an app edits a repository shared read-write" "$(cat "$test_dir/repo/file")"
[[ -d $test_dir/repo/.git/hooks && ! -e $test_dir/repo/moved && -z $(ls -A "$test_dir/repo/.git/hooks") ]] ||
  fail "an app plants nothing in the .git of a repository shared read-write" "$(ls -laR "$test_dir/repo")"
[[ $(<"$test_dir/worktree/.git") == "gitdir: $test_dir/repo/.git" && ! -e $test_dir/worktree/moved ]] ||
  fail "an app cannot repoint a worktree's .git file" "$(ls -la "$test_dir/worktree"; cat "$test_dir/worktree/.git")"
for path in "$test_dir/repo/.git" "$test_dir/repo/.git/hooks"; do
  refused --share "$path" || fail "sharing $path read-write is refused"
done
pass "a repository shared read-write is editable, but its .git stays read-only and cannot be shared read-write"

# The seat's home lives in Omarchy's state. One made under
# ~/.local/share/omarchy before that moved comes along once.
seat_home="$home/.local/state/omarchy/agent-seat/home"
old_seat_home="$home/.local/share/omarchy/agent-seat/home"
rm -rf "$home/.local/state/omarchy/agent-seat"
mkdir -p "$old_seat_home"
echo "cookie" >"$old_seat_home/cookie"
run_headless --share "$test_dir/out" /usr/bin/bash -c 'cat "$HOME/cookie" >"$1/cookie"' _ "$test_dir/out" ||
  fail "an app runs with a home made at the old place" "$(cat "$seat/apps.log" 2>/dev/null)"
[[ $(cat "$test_dir/out/cookie" 2>/dev/null) == "cookie" ]] || fail "the app sees the home made at the old place" "$(cat "$seat/apps.log" 2>/dev/null)"
[[ -f $seat_home/cookie && ! -e $old_seat_home ]] || fail "a home made at the old place moves to Omarchy's state" "$(ls -laR "$home/.local" 2>&1)"
pass "a home made under ~/.local/share/omarchy moves once to ~/.local/state/omarchy"

# An upgrade to Omarchy 4 turns ~/.local/share/omarchy into a link to the
# read-only /usr/share/omarchy. Launches still work, and a home found behind
# that link is not the user's to move.
rm -rf "$home/.local/share/omarchy" "$test_dir/out/upgraded"
mkdir -p "$test_dir/system-omarchy"
chmod a-w "$test_dir/system-omarchy"
ln -s "$test_dir/system-omarchy" "$home/.local/share/omarchy"
output=$("${on_seat[@]}" omarchy-agent-seat-run --no-wait --share "$test_dir/out" /usr/bin/bash -c 'echo "upgraded" >"$1/upgraded"' _ "$test_dir/out" 2>&1) ||
  fail "a launch works with ~/.local/share/omarchy linked to a read-only tree" "$output"
for _ in {1..100}; do [[ -s $test_dir/out/upgraded ]] && break; sleep 0.05; done
[[ $(cat "$test_dir/out/upgraded" 2>/dev/null) == "upgraded" ]] ||
  fail "an app runs with ~/.local/share/omarchy linked to a read-only tree" "$output $(cat "$seat/apps.log" 2>/dev/null)"
chmod u+w "$test_dir/system-omarchy"
mkdir -p "$test_dir/system-omarchy/agent-seat/home"
chmod -R a-w "$test_dir/system-omarchy"
rm -rf "$home/.local/state/omarchy/agent-seat"
run_headless /usr/bin/true || fail "a launch works beside a home behind the upgrade's link" "$(cat "$seat/apps.log" 2>/dev/null)"
[[ -d $test_dir/system-omarchy/agent-seat/home && -d $seat_home ]] || fail "a home behind the upgrade's link stays where it is" "$(ls -laR "$home/.local" 2>&1)"
chmod -R u+w "$test_dir/system-omarchy"
pass "a launch works with ~/.local/share/omarchy linked to a read-only tree, and leaves what is behind the link"

# A home that cannot be made fails the launch at once, with the reason.
mv "$home/.local/state" "$home/.local/state.real"
mkdir -p "$test_dir/readonly-state"
chmod a-w "$test_dir/readonly-state"
ln -s "$test_dir/readonly-state" "$home/.local/state"
output=$("${on_seat[@]}" omarchy-agent-seat-run --no-wait /usr/bin/true 2>&1) && fail "a launch whose home cannot be made fails" "$output"
[[ $output == "Could not create the agent seat's home at $seat_home: "*"Permission denied" ]] ||
  fail "a launch whose home cannot be made says why" "$output"
rm "$home/.local/state"
mv "$home/.local/state.real" "$home/.local/state"
chmod u+w "$test_dir/readonly-state"
pass "a launch whose home cannot be made fails at once and says why"

# A launch that waits for its window keeps other launches from diffing the
# window list until it has one, without holding up stop.
"${on_seat[@]}" omarchy-agent-seat-run /usr/bin/sleep 30 >/dev/null 2>&1 &
launcher_pid=$!
for _ in {1..50}; do
  compgen -G "$seat/sandboxes/sandbox.*" >/dev/null && break
  sleep 0.05
done
sleep 0.2
flock -n "$seat/launch.lock" true && fail "a waiting launch holds the launch lock"
flock -n "$seat/sandboxes.lock" true || fail "a waiting launch does not hold up stop"
"${on_seat[@]}" omarchy-agent-seat-run --no-wait /usr/bin/true &
second_pid=$!
sleep 0.5
kill -0 "$second_pid" 2>/dev/null || fail "a second launch waits for the first to find its window"
kill "$launcher_pid"
wait "$launcher_pid" 2>/dev/null
launcher_pid=
for _ in {1..50}; do kill -0 "$second_pid" 2>/dev/null || break; sleep 0.1; done
kill -0 "$second_pid" 2>/dev/null && fail "the second launch goes ahead once the first is done"
wait "$second_pid" || fail "the second launch succeeds"
pass "launches find their windows one at a time, and stop is not held up"

# An app with one window: it connects, reports <name>-ready in a shared
# directory, opens its window once <name>-go appears there, reports
# <name>-mapped and stays until the broker hangs up. Self-contained, since the
# sandbox gets only this file.
cat >"$test_dir/toplevel" <<'EOF'
#!/usr/bin/python3
import os, socket, struct, sys, time

name, shared = sys.argv[1:3]
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.connect(os.environ["XDG_RUNTIME_DIR"] + "/wayland-0")
buffer = b""

def send(object_id, opcode, body=b""):
    sock.sendall(struct.pack("<II", object_id, (8 + len(body)) << 16 | opcode) + body)

def string(text):
    data = text.encode() + b"\0"
    return struct.pack("<I", len(data)) + data + b"\0" * (-len(data) % 4)

def read():
    global buffer
    while len(buffer) < 8 or len(buffer) < struct.unpack_from("<II", buffer)[1] >> 16:
        data = sock.recv(65536)
        if not data:
            sys.exit(0)
        buffer += data
    object_id, word = struct.unpack_from("<II", buffer)
    body, buffer = buffer[8 : word >> 16], buffer[word >> 16 :]
    return object_id, word & 0xFFFF, body

def roundtrip(callback):
    send(1, 0, struct.pack("<I", callback))
    events = []
    while (event := read())[0] != callback:
        events.append(event)
    return events

def report(state):
    open(f"{shared}/{name}-{state}", "w").close()

send(1, 1, struct.pack("<I", 2))
names = {}
for object_id, opcode, body in roundtrip(3):
    if object_id == 2 and opcode == 0:
        length = struct.unpack_from("<I", body, 4)[0]
        names[body[8 : 7 + length].decode()] = struct.unpack_from("<I", body)[0]
for interface, new_id in (("wl_compositor", 4), ("xdg_wm_base", 5)):
    send(2, 0, struct.pack("<I", names[interface]) + string(interface) + struct.pack("<II", 1, new_id))
roundtrip(6)
report("ready")

while not os.path.exists(f"{shared}/{name}-go"):
    time.sleep(0.02)
send(4, 0, struct.pack("<I", 7))      # wl_compositor.create_surface
send(5, 2, struct.pack("<II", 8, 7))  # xdg_wm_base.get_xdg_surface
send(8, 1, struct.pack("<I", 9))      # xdg_surface.get_toplevel
send(9, 3, string(name))              # xdg_toplevel.set_app_id
send(7, 6)                            # wl_surface.commit
roundtrip(10)
report("mapped")

while read():
    pass
EOF
chmod +x "$test_dir/toplevel"

# Waits for an app on the seat to report a state through the shared directory.
reported() {
  for _ in {1..100}; do
    [[ -e $test_dir/out/$1 ]] && return 0
    sleep 0.05
  done
  return 1
}

# Another seat app's window (a dialog, say) that opens while a launch waits for
# its own is not the launch's window.
"${on_seat[@]}" omarchy-agent-seat-run --no-wait --share "$test_dir/out" "$test_dir/toplevel" first "$test_dir/out" ||
  fail "a first windowed app starts" "$(cat "$seat/apps.log" 2>/dev/null)"
reported first-ready || fail "the first windowed app connects" "$(cat "$seat/apps.log" 2>/dev/null)"
# Its sandbox starts only after the launch has listed the windows before it.
"${on_seat[@]}" omarchy-agent-seat-run --share "$test_dir/out" "$test_dir/toplevel" second "$test_dir/out" >"$test_dir/second-window" 2>&1 &
second_pid=$!
reported second-ready || fail "the second windowed app connects" "$(cat "$seat/apps.log" 2>/dev/null)"
touch "$test_dir/out/first-go"
reported first-mapped || fail "the first app opens its window" "$(cat "$seat/apps.log" 2>/dev/null)"
# Give the waiting launch time to see the first app's window on its own.
sleep 0.5
touch "$test_dir/out/second-go"
wait "$second_pid" || fail "the launch of the second app finds a window" "$(cat "$test_dir/second-window")"
second_window=$(<"$test_dir/second-window")
app=$("${on_seat[@]}" omarchy-agent-seat-windows | jq -r --arg window "$second_window" '.[] | select((.window | tostring) == $window) | .app_id')
[[ $app == "second" ]] || fail "a launch returns its own app's window, not another app's" "window $second_window is ${app:-unknown}: $("${on_seat[@]}" omarchy-agent-seat-windows)"
pass "a launch returns its own app's window, not one another app opens meanwhile"

# Reports whether the sandbox's wayland-0 has a broker behind it.
cat >"$test_dir/connect" <<'EOF_CONNECT'
#!/bin/bash
if python3 -c 'import os, socket; socket.socket(socket.AF_UNIX).connect(os.environ["XDG_RUNTIME_DIR"] + "/wayland-0")' 2>/dev/null; then
  echo "connected" >"$1"
else
  echo "refused" >"$1"
fi
EOF_CONNECT
chmod +x "$test_dir/connect"

# A broker that dies leaves its sockets behind.
kill -KILL "$broker_pid"
wait "$broker_pid" 2>/dev/null
broker_pid=
[[ -S $seat/control && -S $seat/wayland-0 ]] || fail "a killed broker leaves its sockets behind"

output=$("${on_seat[@]}" PATH="$test_dir/no-broker:$ROOT/bin:$PATH" omarchy-agent-seat-run --no-wait --share "$test_dir/out" "$test_dir/connect" "$test_dir/out/dead" 2>&1) &&
  fail "a launch over a dead broker's sockets fails while no broker answers" "$output"
[[ $output == "The agent seat broker did not start within 10 seconds"* ]] || fail "a launch with no broker says so" "$output"
sleep 0.5
[[ ! -e $test_dir/out/dead ]] || fail "no app starts over a dead broker's sockets" "$(cat "$test_dir/out/dead")"
pass "a launch over a dead broker's sockets fails clearly while no broker answers"

# The launch starts a broker over the dead one's sockets and hands the app the
# new wayland-0, not the dead one, even when that broker is slow to start.
mkdir -p "$test_dir/slow-broker"
printf '#!/bin/bash\nif [[ $1 == "serve" ]]; then\n  echo $$ >"%s/slow-broker/pid"\n  sleep 1\nfi\nexec "%s/bin/omarchy-agent-seat-broker" "$@"\n' "$test_dir" "$ROOT" >"$test_dir/slow-broker/omarchy-agent-seat-broker"
chmod +x "$test_dir/slow-broker/omarchy-agent-seat-broker"
"${on_seat[@]}" PATH="$test_dir/slow-broker:$test_dir/bin:$ROOT/bin:$PATH" omarchy-agent-seat-run --no-wait --share "$test_dir/out" "$test_dir/connect" "$test_dir/out/restarted" ||
  fail "a launch over a dead broker's sockets starts a new broker" "$(cat "$seat/broker.log" 2>/dev/null)"
for _ in {1..50}; do [[ -s $test_dir/out/restarted ]] && break; sleep 0.1; done
[[ $(cat "$test_dir/out/restarted" 2>/dev/null) == "connected" ]] ||
  fail "an app launched over a dead broker's sockets reaches the new broker" "$(cat "$test_dir/out/restarted" 2>/dev/null) $(cat "$seat/apps.log" 2>/dev/null)"
"${on_seat[@]}" omarchy-agent-seat-stop >/dev/null || fail "stop ends the restarted broker"
rm -f "$test_dir/slow-broker/pid"
pass "a launch over a dead broker's sockets starts a new broker and reaches it"

# A broker that accepts the connection and never answers is alive, only hung,
# and its apps are still connected to it: the launch neither waits on it
# forever nor starts a second broker over its sockets, which would orphan
# those apps and reuse their window numbers. It fails and names stop. The
# shim's serve only records that it ran.
mkdir -p "$test_dir/silent-broker"
printf '#!/bin/bash\nif [[ $1 == "serve" ]]; then\n  echo started >>"%s/silent-broker/served"\n  exit 1\nfi\nexec "%s/bin/omarchy-agent-seat-broker" "$@"\n' "$test_dir" "$ROOT" >"$test_dir/silent-broker/omarchy-agent-seat-broker"
chmod +x "$test_dir/silent-broker/omarchy-agent-seat-broker"
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
control_inode=$(stat -c %i "$seat/control")
start=$SECONDS
code=0
output=$(timeout 30 "${on_seat[@]}" PATH="$test_dir/silent-broker:$test_dir/bin:$ROOT/bin:$PATH" omarchy-agent-seat-run --no-wait /usr/bin/true 2>&1) || code=$?
((code != 124)) || fail "a launch gives up on a broker that never answers"
((code != 0)) || fail "a launch fails when the broker never answers" "$output"
[[ $output == *"did not answer"*"omarchy agent seat stop"* ]] || fail "a launch on a silent broker names stop as the way to end it" "$output"
((SECONDS - start <= 10)) || fail "a launch gives up on a silent broker within its deadline" "$((SECONDS - start)) seconds"
[[ ! -e $test_dir/silent-broker/served ]] || fail "a launch starts no second broker over a live one's sockets"
kill -0 "$silent_pid" 2>/dev/null || fail "a launch leaves a silent broker running"
[[ $(stat -c %i "$seat/control" 2>/dev/null) == "$control_inode" ]] || fail "a launch leaves a silent broker's control socket in place"
kill "$silent_pid" 2>/dev/null
wait "$silent_pid" 2>/dev/null
silent_pid=
pass "a launch on a broker that never answers fails, names stop and starts no second broker"
