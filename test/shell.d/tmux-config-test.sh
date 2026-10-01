#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
export TMUX_TMPDIR=$test_tmp
socket="omarchy-tmux-config-$$"
trap 'for server in "$socket" "packaged-$$" "migrated-$$"; do tmux -L "$server" kill-server 2>/dev/null || true; done; rm -rf "$test_tmp"' EXIT

# Attach a real client and read what tmux writes to its terminal: tmux writes nothing when ncurses cannot expand Ms.
osc52_emitted() {
  local config=$1 name=$2
  local command="stty rows 24 cols 80; tmux -L $name-$$ -f $(printf '%q' "$config") new-session 'sleep 0.5; printf \"\\033]52;p;cHJpbWFyeQ==\\007\"; tmux set-buffer -w hello; sleep 0.5'"
  TERM=xterm-256color timeout 10 script -qfec "$command" "$test_tmp/$name.log" < <(sleep 5) >/dev/null
  grep -aqF $'\e]52;c;aGVsbG8=\a' "$test_tmp/$name.log" &&
    grep -aqF $'\e]52;p;cHJpbWFyeQ==\a' "$test_tmp/$name.log"
}

osc52_emitted "$ROOT/config/tmux/tmux.conf" packaged ||
  fail "tmux sends its own copies to the clipboard selector mosh accepts and keeps an application's selector" "$(cat -v "$test_tmp/packaged.log")"
pass "tmux emits mosh-compatible OSC 52 clipboard sequences"

tmux -L "$socket" -f "$ROOT/config/tmux/tmux.conf" new-session -d

copy_binding=$(tmux -L "$socket" list-keys -T copy-mode-vi | grep -E '^bind-key +-T copy-mode-vi +y ' || true)
[[ $copy_binding == *"copy-selection-and-cancel"* && $copy_binding != *"copy-pipe"* ]] ||
  fail "tmux copies use its own clipboard emitter" "$copy_binding"
pass "tmux copy mode keeps its native clipboard path"

home="$test_tmp/home"
mkdir -p "$home/.config/tmux" "$test_tmp/bin"
printf '%s\n' \
  'set -g mouse on' \
  'set -g set-clipboard on' \
  'setw -g mode-keys vi' \
  'bind -N "Begin selection" -T copy-mode-vi v send -X begin-selection' \
  'bind -N "Copy selection" -T copy-mode-vi y send -X copy-selection-and-cancel' \
  >"$home/.config/tmux/tmux.conf"
printf '%s' 'set -g status off' >>"$home/.config/tmux/tmux.conf"

cat >"$test_tmp/bin/tmux" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TMUX_LOG"
[[ $1 == "list-sessions" ]] || { [[ $1 == "source-file" ]] && exit "${SOURCE_RESULT:-0}"; }
SH

cat >"$test_tmp/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$test_tmp/bin/tmux" "$test_tmp/bin/omarchy-cmd-present"

migration="$ROOT/migrations/1786553531.sh"
tmux_log="$test_tmp/tmux.log"
HOME="$home" TMUX_LOG="$tmux_log" PATH="$test_tmp/bin:$PATH" bash -euo pipefail "$migration" >/dev/null

grep -Fq 'xterm*:Ms=\\E]52;%?%p1%l%t%p1%s%ec%;;%p2%s\\007' "$home/.config/tmux/tmux.conf" ||
  fail "tmux migration adds the mosh selector override"
grep -Fq 'y send -X copy-selection-and-cancel' "$home/.config/tmux/tmux.conf" ||
  fail "tmux migration leaves native copy bindings alone"
grep -Fqx 'set -g status off' "$home/.config/tmux/tmux.conf" ||
  fail "tmux migration preserves a final line without a newline"
grep -Fqx "source-file $home/.config/tmux/tmux.conf" "$tmux_log" ||
  fail "tmux migration reloads a running server"
pass "tmux migration updates existing configs and live servers"

osc52_emitted "$home/.config/tmux/tmux.conf" migrated ||
  fail "migrated tmux override emits like the packaged default" "$(cat -v "$test_tmp/migrated.log")"
pass "tmux migration writes a valid terminal capability"

before=$(sha256sum "$home/.config/tmux/tmux.conf")
HOME="$home" TMUX_LOG="$tmux_log" PATH="$test_tmp/bin:$PATH" bash -euo pipefail "$migration" >/dev/null
[[ $before == $(sha256sum "$home/.config/tmux/tmux.conf") ]] ||
  fail "tmux clipboard migration is idempotent"
pass "tmux clipboard migration is idempotent"

custom_home="$test_tmp/custom-home"
mkdir -p "$custom_home/.config/tmux"
custom_binding='bind -T copy-mode-vi y send -X copy-pipe "custom-copy"'
printf '%s\n' 'set -g mouse on' "$custom_binding" >"$custom_home/.config/tmux/tmux.conf"
HOME="$custom_home" TMUX_LOG="$tmux_log" PATH="$test_tmp/bin:$PATH" bash -euo pipefail "$migration" >/dev/null

grep -Fqx "$custom_binding" "$custom_home/.config/tmux/tmux.conf" ||
  fail "tmux migration preserves a custom copy binding"
pass "tmux migration leaves custom copy bindings alone"

HOME="$home" SOURCE_RESULT=1 TMUX_LOG="$tmux_log" PATH="$test_tmp/bin:$PATH" bash -euo pipefail "$migration" >"$test_tmp/reload-output" 2>&1 || fail "optional live reload failures must not stop migrations"
grep -q 'Could not reload tmux' "$test_tmp/reload-output" || fail "reload failure tells the user to repair the live config"
pass "failed live reloads warn without stopping later migrations"

printf '%s\n' 'set -ag terminal-overrides ",xterm*:RGB:Ms=custom-clipboard"' >>"$custom_home/.config/tmux/tmux.conf"
# Start with only user-owned capabilities, not a previously added Omarchy override.
grep -vF 'xterm*:Ms=\\E]52;' "$custom_home/.config/tmux/tmux.conf" >"$test_tmp/custom-config"
cp "$test_tmp/custom-config" "$custom_home/.config/tmux/tmux.conf"
before=$(sha256sum "$custom_home/.config/tmux/tmux.conf")
HOME="$custom_home" TMUX_LOG="$tmux_log" PATH="$test_tmp/bin:$PATH" bash -euo pipefail "$migration" >/dev/null
[[ $before == $(sha256sum "$custom_home/.config/tmux/tmux.conf") ]] || fail "user Ms overrides remain unchanged"
pass "custom clipboard capabilities are preserved without appending a competing override"

non_xterm="$test_tmp/non-xterm/.config/tmux/tmux.conf"
mkdir -p "${non_xterm%/*}"
printf '%s\n' 'set -ag terminal-overrides ",vt100:Ms=custom-vt-clipboard"' >"$non_xterm"
HOME="$test_tmp/non-xterm" TMUX_LOG="$tmux_log" PATH="$test_tmp/bin:$PATH" bash -euo pipefail "$migration" >/dev/null
grep -Fq 'vt100:Ms=custom-vt-clipboard' "$non_xterm" || fail "unrelated terminal overrides stay intact"
grep -Fq 'xterm*:Ms=\\E]52;' "$non_xterm" || fail "unrelated terminal overrides do not skip the mosh fix"
pass "non-xterm clipboard overrides do not block the xterm mosh capability"

selection_copies() {
  python3 - "$1" "$test_tmp/$2-selection.log" "$2-selection-$$" <<'PYTEST'
import fcntl
import os
import pty
import select
import struct
import subprocess
import sys
import termios
import time

config, output, socket = sys.argv[1:]
command = ["tmux", "-L", socket]

def tmux(*args):
  return subprocess.check_output(command + list(args), stderr=subprocess.STDOUT)

def read_until(expected):
  data = b""
  deadline = time.monotonic() + 5
  while time.monotonic() < deadline:
    ready, _, _ = select.select([master], [], [], 0.1)
    if ready:
      data += os.read(master, 65536)
    if expected in data:
      return data
  raise AssertionError(f"Missing clipboard output {expected!r}: {data!r}")

master, slave = pty.openpty()
fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 80, 0, 0))
client = None
try:
  subprocess.run(command + ["-f", config, "new-session", "-d", "-x", "80", "-y", "24", "printf 'hello\\r\\n'; sleep 30"], check=True)

  def controlling_terminal():
    os.setsid()
    fcntl.ioctl(slave, termios.TIOCSCTTY, 0)

  client = subprocess.Popen(command + ["attach-session"], stdin=slave, stdout=slave, stderr=slave,
    env={**os.environ, "TERM": "xterm-256color"}, preexec_fn=controlling_terminal)
  read_until(b"hello")
  tmux("copy-mode")
  tmux("send-keys", "-X", "history-top")
  tmux("send-keys", "-X", "start-of-line")
  tmux("send-keys", "v")
  for _ in range(4):
    tmux("send-keys", "-X", "cursor-right")
  tmux("send-keys", "y")
  osc52 = b"\x1b]52;c;aGVsbG8=\x07"
  data = read_until(osc52)
  assert tmux("show-buffer") == b"hello"

  while select.select([master], [], [], 0.1)[0]:
    os.read(master, 65536)
  row = int(tmux("display-message", "-p", "#{pane_top}")) + 1
  if tmux("show-options", "-gv", "status-position").strip() == b"top":
    status = tmux("show-options", "-gv", "status").strip()
    row += 1 if status == b"on" else 0 if status == b"off" else int(status)
  for button, column, suffix in [(0, 1, "M"), (32, 5, "M"), (0, 5, "m")]:
    os.write(master, f"\x1b[<{button};{column};{row}{suffix}".encode())
    time.sleep(0.1)
  data += read_until(osc52)
  assert tmux("show-buffer") == b"hello"
  with open(output, "wb") as log:
    log.write(data)
finally:
  subprocess.run(command + ["kill-server"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
  if client is not None:
    try:
      client.wait(timeout=2)
    except subprocess.TimeoutExpired:
      client.kill()
      client.wait()
  os.close(master)
  os.close(slave)
PYTEST
}

for config in packaged migrated; do
  if [[ $config == "packaged" ]]; then
    path="$ROOT/config/tmux/tmux.conf"
  else
    path="$home/.config/tmux/tmux.conf"
  fi
  selection_copies "$path" "$config" || fail "$config copy-mode and mouse selections must emit mosh-compatible OSC 52"
  pass "$config copy-mode and real mouse selections emit OSC 52 through an attached terminal"
done
