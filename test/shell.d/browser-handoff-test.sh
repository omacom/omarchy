#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command socat

# Edge's own second process sends two fields after the directory, and takes
# them from the message once there is more than one argument. The packaged path
# is what selects that profile, so stand in for it where Edge is not installed.
edge_tmp=$(mktemp -d)
edge_socket="$edge_tmp/config/microsoft-edge/SingletonSocket"
edge_received="$edge_tmp/received"
mkdir -p "${edge_socket%/*}"

stop_edge_server() {
  kill "$edge_server" 2>/dev/null || true
  wait "$edge_server" 2>/dev/null || true
  rm -rf "$edge_tmp"
}

python3 - "$edge_socket" "$edge_received" >/dev/null <<'PY' &
import socket, sys
server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
server.bind(sys.argv[1])
server.listen(1)
while True:
    connection, _ = server.accept()
    message = b""
    while chunk := connection.recv(4096):
        message += chunk
    open(sys.argv[2], "wb").write(message)
    connection.sendall(b"ACK")
    connection.close()
PY
edge_server=$!
trap stop_edge_server EXIT

for _ in $(seq 100); do
  [[ -S $edge_socket ]] && break
  sleep 0.02
done

type() {
  if [[ ${1:-} == "-P" && ${2:-} == "microsoft-edge-stable" ]]; then
    printf '/usr/bin/microsoft-edge-stable\n'
  else
    builtin type "$@"
  fi
}
export -f type

(cd "$edge_tmp" && XDG_CONFIG_HOME="$edge_tmp/config" \
  "$ROOT/bin/omarchy-cmd-browser-handoff" microsoft-edge-stable --app=https://example.test --ignore-certificate-errors) ||
  fail "the running Edge acknowledges a handed off command line"

unset -f type

mapfile -d '' -t fields <"$edge_received"
((${#fields[@]} == 7)) ||
  fail "the Edge handoff sends the two fields, the browser and both arguments" "$(od -c <"$edge_received")"
((fields[2] > 11644473600000000)) ||
  fail "the Edge handoff dates its message from 1601, as Edge's own client does" "$(od -c <"$edge_received")"
[[ ${fields[0]} == "START" && ${fields[1]} == "$edge_tmp" && ${fields[3]} == "0" && ${fields[4]} == "browser" &&
  ${fields[5]} == "--app=https://example.test" && ${fields[6]} == "--ignore-certificate-errors" ]] ||
  fail "the Edge handoff keeps every argument behind the two fields Edge expects" "$(od -c <"$edge_received")"
pass "the Edge handoff sends the two fields Edge's own second process sends, keeping every argument"
stop_edge_server
trap - EXIT

# The handoff only stands in for the packaged browser itself.
if [[ $(type -P chromium) != "/usr/bin/chromium" ]]; then
  skip "browser handoff needs /usr/bin/chromium"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export XDG_CONFIG_HOME="$test_tmp/config"
socket="$XDG_CONFIG_HOME/chromium/SingletonSocket"
received="$test_tmp/received"
mkdir -p "${socket%/*}"
flags_file="$XDG_CONFIG_HOME/chromium-flags.conf"
cp "$ROOT/config/chromium-flags.conf" "$flags_file"
echo "# A comment of the user's" >>"$flags_file"

# A running browser's side of the singleton socket: take each command line and
# acknowledge it, as Chromium does.
python3 - "$socket" "$received" <<'PY' &
import socket, sys
server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
server.bind(sys.argv[1])
server.listen(1)
while True:
    connection, _ = server.accept()
    message = b""
    while chunk := connection.recv(4096):
        message += chunk
    open(sys.argv[2], "wb").write(message)
    connection.sendall(b"ACK")
    connection.close()
PY
server=$!
trap 'kill "$server" 2>/dev/null || true; rm -rf "$test_tmp"' EXIT

for _ in $(seq 100); do
  [[ -S $socket ]] && break
  sleep 0.02
done

(cd "$test_tmp" && "$ROOT/bin/omarchy-cmd-browser-handoff" chromium --app="https://example.test/a b") ||
  fail "the running browser acknowledges a handed off command line"

expected=$(printf 'START\0%s\0browser\0--app=https://example.test/a b' "$test_tmp" | od -c)
[[ $(od -c <"$received") == "$expected" ]] ||
  fail "the handoff sends the working directory and arguments as Chromium's singleton expects" "$(od -c <"$received")"
pass "a command line is handed to the running browser over its singleton socket"

! "$ROOT/bin/omarchy-cmd-browser-handoff" chromium --user-data-dir=/elsewhere https://example.test ||
  fail "another data directory is left to a browser of its own"
mkdir -p "$test_tmp/wrapper"
printf '#!/bin/bash\nexec /usr/bin/chromium --profile-directory=Work "$@"\n' >"$test_tmp/wrapper/chromium"
chmod +x "$test_tmp/wrapper/chromium"
! PATH="$test_tmp/wrapper:$PATH" "$ROOT/bin/omarchy-cmd-browser-handoff" chromium https://example.test ||
  fail "a wrapper standing in for the browser is left to run"
! CHROME_USER_DATA_DIR=/elsewhere "$ROOT/bin/omarchy-cmd-browser-handoff" chromium https://example.test ||
  fail "a data directory from the environment is left to a browser of its own"

# The handoff forwards no flags file, so any flag beyond Omarchy's own, which
# may be meant for each launch, needs the launcher.
for flag in '--new-window' '--enable-features=A --profile-directory="Profile 1"'; do
  cp "$ROOT/config/chromium-flags.conf" "$flags_file"
  echo "$flag" >>"$flags_file"
  ! "$ROOT/bin/omarchy-cmd-browser-handoff" chromium https://example.test ||
    fail "a flags file with $flag is left to the launcher"
done

# The browser is gone but its socket file is left, as after a crash.
kill "$server"
wait "$server" 2>/dev/null || true
! "$ROOT/bin/omarchy-cmd-browser-handoff" chromium --app=https://example.test ||
  fail "a socket no browser answers on fails the handoff"
! "$ROOT/bin/omarchy-cmd-browser-handoff" firefox https://example.test ||
  fail "a browser without a singleton socket fails the handoff"
pass "the handoff fails when no Chromium-based browser answers, so the caller launches one"
