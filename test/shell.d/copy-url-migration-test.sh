#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command python3

migration="$ROOT/migrations/1786643346.sh"
test_dir=$(mktemp -d)

home="$test_dir/home"
profile_root="$home/.config/chromium"
preferences="$profile_root/Default/Preferences"
mkdir -p "$(dirname "$preferences")"

# Any id Chromium once derived from the extension's keyless load path; the
# repair keys off the registered command name, not the id.
ghost_id="ikkebdkaanlebnifjnbeiaklodhbjcci"
pinned_id="bgpiichlckmfanooecilcjemknkcpngb"
ghost_preferences_json='{"extensions":{"commands":{"linux:Alt+Shift+L":{"command_name":"copy-url","extension":"fpogfhkjagaffemmbnnnoklcppehefdo"}},"settings":{"fpogfhkjagaffemmbnnnoklcppehefdo":{"path":"/usr/share/omarchy/default/chromium/extensions/copy-url"}}}}'

write_stale_preferences() {
  jq -n --arg ghost "$ghost_id" --arg pinned "$pinned_id" '{extensions: {commands: {"linux:Alt+Shift+L": {command_name: "copy-url", extension: $ghost, global: false}}, settings: {($ghost): {commands: {"copy-url": {suggested_key: "Alt+Shift+L", was_assigned: true}}}, ($pinned): {commands: {"copy-url": {suggested_key: "Alt+Shift+L"}}}}}}' >"$preferences"
}

stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

REAL_PYTHON=$(command -v python3)
export REAL_PYTHON

run_migration() {
  HOME="$home" PATH="$stub_bin:$PATH" bash -euo pipefail "$migration" >/dev/null 2>&1
}

# A running Chromium-family browser marks its profile root with a SingletonLock
# symlink to <hostname>-<pid>, a target that never exists on disk. That lock —
# not the mere presence of a browser process — is what the migration waits on,
# and it holds only while the pid it names is still a live browser. A copy of
# sleep under a browser's name is one, as far as /proc/<pid>/exe is concerned.
cp "$(command -v sleep)" "$stub_bin/chromium"
"$stub_bin/chromium" 600 &
browser_pid=$!

# Every stand-in has to go on the way out, including a failing exit: one left
# running holds this test's output pipe open long after the run.
holder_pid=""
zombie_parent=""
socket_pid=""
profile_pid=""
cleanup() {
  kill $browser_pid ${holder_pid:-} ${zombie_parent:-} ${socket_pid:-} ${profile_pid:-} 2>/dev/null || true
  rm -rf "$test_dir"
}
trap cleanup EXIT

LIVE_LOCK="$(uname -n)-$browser_pid"
export LIVE_LOCK

open_browser() {
  mkdir -p "$profile_root"
  ln -sfn "$LIVE_LOCK" "$profile_root/SingletonLock"
}
close_browser() {
  rm -f "$profile_root/SingletonLock"
}

# The affected profile being open prompts for the windows to be closed;
# declining (or having no terminal to ask in) defers the repair so a
# rewrite-on-exit cannot revert it.
printf '#!/bin/bash\nexit 1\n' >"$stub_bin/gum"
chmod +x "$stub_bin/gum"
write_stale_preferences
open_browser

before_hash=$(sha256sum "$preferences" | cut -d' ' -f1)

run_migration && fail "migration defers while the affected profile is open"
[[ $(sha256sum "$preferences" | cut -d' ' -f1) == "$before_hash" ]] ||
  fail "migration leaves preferences alone while the affected profile is open"
pass "migration defers the repair while the affected profile is open"

# gum paints its prompt on stderr, so that stream has to stay attached:
# suppressing it leaves gum reading keys behind an unpainted screen, which
# reads as a hung update.
cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
echo "gum-prompt-painted" >&2
exit 1
STUB
prompt_stderr="$test_dir/prompt-stderr"
HOME="$home" PATH="$stub_bin:$PATH" bash -euo pipefail "$migration" >/dev/null 2>"$prompt_stderr" &&
  fail "migration defers when the browser prompt is declined"
grep -q "gum-prompt-painted" "$prompt_stderr" || fail "migration keeps the browser prompt visible"
pass "migration keeps the browser prompt visible"

# A browser holding a different profile root cannot revert this repair, so it
# must not hold the update: the repair goes through without ever reaching the
# prompt, which the still-declining gum stub would otherwise fail.
close_browser
mkdir -p "$home/.config/google-chrome"
ln -sfn "$LIVE_LOCK" "$home/.config/google-chrome/SingletonLock"
write_stale_preferences
run_migration || fail "migration repairs while a different profile root is open"
jq -e --arg pinned "$pinned_id" '.extensions.commands["linux:Alt+Shift+L"].extension == $pinned' "$preferences" >/dev/null ||
  fail "migration repairs the shortcut while a different profile root is open"
pass "migration ignores a browser on a different profile root"
rm -f "$home/.config/google-chrome/SingletonLock" "$preferences.omarchy-copy-url-repair.bak"

# A crash or a reboot leaves the lock behind naming a pid that is gone. Waiting
# on that profile can never end — no keypress makes a dead browser exit — so a
# stale lock has to read as closed.
write_stale_preferences
(exit) &
stale_pid=$!
wait "$stale_pid"
ln -sfn "$(uname -n)-$stale_pid" "$profile_root/SingletonLock"
run_migration || fail "migration repairs through a stale singleton lock"
jq -e --arg pinned "$pinned_id" '.extensions.commands["linux:Alt+Shift+L"].extension == $pinned' "$preferences" >/dev/null ||
  fail "migration repairs the shortcut through a stale singleton lock"
pass "migration repairs through a stale singleton lock"
close_browser
rm -f "$preferences.omarchy-copy-url-repair.bak"

# The kernel hands a dead browser's pid on to whatever starts next, and this
# test's own shell stands in for that unrelated process: the number matches,
# but nothing about it is a browser.
write_stale_preferences
ln -sfn "$(uname -n)-$$" "$profile_root/SingletonLock"
run_migration || fail "migration repairs through a lock whose pid was reused"
jq -e --arg pinned "$pinned_id" '.extensions.commands["linux:Alt+Shift+L"].extension == $pinned' "$preferences" >/dev/null ||
  fail "migration repairs the shortcut through a lock whose pid was reused"
pass "migration repairs through a lock whose pid was reused"
close_browser
rm -f "$preferences.omarchy-copy-url-repair.bak"

# Browsers this migration has never heard of still hold their profile open, so
# a lock whose pid keeps a file open in there counts however it is named.
write_stale_preferences
bash -c "exec 9<\"$preferences\"; sleep 600" >/dev/null 2>&1 &
holder_pid=$!
for _ in {1..50}; do
  [[ -e /proc/$holder_pid/fd/9 ]] && break
  sleep 0.1
done
[[ -e /proc/$holder_pid/fd/9 ]] || fail "the profile-holding process opens the preferences file"
ln -sfn "$(uname -n)-$holder_pid" "$profile_root/SingletonLock"
run_migration && fail "migration defers to a lock whose pid holds the profile open"
[[ $(jq -r '.extensions.commands["linux:Alt+Shift+L"].extension' "$preferences") == "$ghost_id" ]] ||
  fail "migration leaves preferences alone while the lock's pid holds the profile open"
pass "migration defers to a lock whose pid holds the profile open"

# A descriptor closing between the glob and the read fails readlink for that
# one alone, and what it did read still places the browser in the profile.
cat >"$stub_bin/readlink" <<STUB
#!/bin/bash
[[ \$1 == -- ]] && set -- "\$@" /proc/$holder_pid/fd/closed
exec $(command -v readlink) "\$@"
STUB
chmod +x "$stub_bin/readlink"
run_migration && fail "migration defers when one of the lock pid's descriptors closes mid-read"
rm "$stub_bin/readlink"
[[ $(jq -r '.extensions.commands["linux:Alt+Shift+L"].extension' "$preferences") == "$ghost_id" ]] ||
  fail "migration leaves preferences alone when one of the lock pid's descriptors closes mid-read"
pass "migration defers when one of the lock pid's descriptors closes mid-read"
kill "$holder_pid" 2>/dev/null || true
holder_pid=""
close_browser

# A pid that answers nothing about itself is no proof of a dead browser, and a
# deferred repair beats one made under a live one. Pid 1 is that process on a
# normal system, being root-owned; inside a container that hands the test user
# its own pid 1, nothing here is unreadable to point at.
if readlink /proc/1/exe >/dev/null 2>&1; then
  pass "pid 1 is readable here; skipping the unreadable lock pid case"
else
  write_stale_preferences
  ln -sfn "$(uname -n)-1" "$profile_root/SingletonLock"
  run_migration && fail "migration defers to a lock whose pid it cannot read"
  [[ $(jq -r '.extensions.commands["linux:Alt+Shift+L"].extension' "$preferences") == "$ghost_id" ]] ||
    fail "migration leaves preferences alone while the lock's pid is unreadable"
  pass "migration defers to a lock whose pid it cannot read"
  close_browser
fi

# A browser that crashed while its parent was not watching leaves a zombie: an
# entry in /proc with no files and no binary behind it, which is a dead browser
# however much of the pid survives.
python3 -c "
import os, sys, time
pid = os.fork()
if pid == 0:
    os._exit(0)
open(sys.argv[1], 'w').write(str(pid))
time.sleep(600)
" "$test_dir/zombie-pid" &
zombie_parent=$!
for _ in {1..50}; do
  [[ -s $test_dir/zombie-pid ]] && break
  sleep 0.1
done
zombie_pid=$(cat "$test_dir/zombie-pid" 2>/dev/null) || zombie_pid=""
zombie_state=$(awk '{print $3}' "/proc/${zombie_pid:-0}/stat" 2>/dev/null) || zombie_state=""

if [[ $zombie_state == "Z" ]]; then
  write_stale_preferences
  ln -sfn "$(uname -n)-$zombie_pid" "$profile_root/SingletonLock"
  run_migration || fail "migration repairs through a lock naming a zombie"
  jq -e --arg pinned "$pinned_id" '.extensions.commands["linux:Alt+Shift+L"].extension == $pinned' "$preferences" >/dev/null ||
    fail "migration repairs the shortcut through a lock naming a zombie"
  pass "migration repairs through a lock naming a zombie"
  close_browser
  rm -f "$preferences.omarchy-copy-url-repair.bak"
else
  pass "no zombie to point a lock at; skipping the zombie lock pid case"
fi
kill "$zombie_parent" 2>/dev/null || true
zombie_parent=""

# Closing the affected profile and confirming the prompt lets the repair
# proceed.
write_stale_preferences
open_browser
cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
"$CLOSE_BROWSER"
touch "${GUM_CALLED:?}"
exit 0
STUB
cat >"$stub_bin/close-browser" <<'STUB'
#!/bin/bash
rm -f "$HOME/.config/chromium/SingletonLock"
STUB
chmod +x "$stub_bin/gum" "$stub_bin/close-browser"
GUM_CALLED="$test_dir/gum-called" CLOSE_BROWSER="$stub_bin/close-browser" \
  HOME="$home" PATH="$stub_bin:$PATH" bash -euo pipefail "$migration" >/dev/null 2>&1 ||
  fail "migration proceeds once the profile is closed and the prompt confirmed"
[[ -e $test_dir/gum-called ]] || fail "migration asks before repairing under a running browser"
jq -e --arg pinned "$pinned_id" '.extensions.commands["linux:Alt+Shift+L"].extension == $pinned' "$preferences" >/dev/null ||
  fail "migration repairs after the browser prompt is confirmed"
pass "migration asks to close the browser and repairs on confirmation"
rm -f "$preferences.omarchy-copy-url-repair.bak"

# With the affected profile closed the ghost registration moves to the pinned id.
printf '#!/bin/bash\nexit 1\n' >"$stub_bin/gum"
close_browser
write_stale_preferences
run_migration || fail "migration repairs the shortcut when no browser is running"

jq -e --arg ghost "$ghost_id" --arg pinned "$pinned_id" '
  .extensions.commands["linux:Alt+Shift+L"].extension == $pinned and
  (.extensions.settings | has($ghost) | not) and
  .extensions.settings[$pinned].commands["copy-url"].was_assigned == true
' "$preferences" >/dev/null || fail "migration rebinds the Copy URL shortcut to the pinned extension id"
[[ -f $preferences.omarchy-copy-url-repair.bak ]] ||
  fail "migration backs up preferences before the repair"
pass "migration rebinds the Copy URL shortcut to the pinned extension id"

# A repaired profile has no ghost registration left, so nothing is pending —
# even while that same profile is open.
rm "$preferences.omarchy-copy-url-repair.bak"
repaired_hash=$(sha256sum "$preferences" | cut -d' ' -f1)
open_browser
run_migration || fail "migration reruns cleanly after the repair"
[[ $(sha256sum "$preferences" | cut -d' ' -f1) == "$repaired_hash" && ! -e $preferences.omarchy-copy-url-repair.bak ]] ||
  fail "migration is idempotent after the repair"
pass "migration is idempotent after the repair"
close_browser

# A remapped shortcut keeps the user's chosen key while moving to the pinned id.
jq -n --arg ghost "$ghost_id" '{extensions: {commands: {"linux:Ctrl+Alt+P": {command_name: "copy-url", extension: $ghost, global: false}}, settings: {}}}' >"$preferences"
run_migration || fail "migration repairs remapped shortcuts"
jq -e --arg pinned "$pinned_id" '.extensions.commands["linux:Ctrl+Alt+P"].extension == $pinned' "$preferences" >/dev/null ||
  fail "migration keeps the remapped key while rebinding to the pinned id"
pass "migration keeps remapped shortcut keys"

# When the pinned extension already holds a copy-url binding (the user fixed
# it by hand), the ghost is dropped rather than doubled into a second binding.
jq -n --arg ghost "$ghost_id" --arg pinned "$pinned_id" '{extensions: {commands: {"linux:Ctrl+Alt+P": {command_name: "copy-url", extension: $pinned, global: false}, "linux:Alt+Shift+L": {command_name: "copy-url", extension: $ghost, global: false}}, settings: {}}}' >"$preferences"
run_migration || fail "migration cleans ghosts alongside a manual repair"
jq -e --arg pinned "$pinned_id" '
  (.extensions.commands | has("linux:Alt+Shift+L") | not) and
  .extensions.commands["linux:Ctrl+Alt+P"].extension == $pinned
' "$preferences" >/dev/null || fail "migration drops the ghost instead of double-binding the pinned extension"
pass "migration never double-binds the pinned extension"

# A browser starting mid-repair may write stale Preferences back on exit, so
# the migration must stay pending for a later browser-free run to verify. A
# stub hands the repair call through and opens the profile right after it.
write_stale_preferences
close_browser
rm -f "$preferences.omarchy-copy-url-repair.bak"
cat >"$stub_bin/python3" <<'STUB'
#!/bin/bash
# Called as `python3 -c <script> <preferences> <pinned_id> <check|repair>`, and
# the check calls report a surviving ghost through their exit status.
"${REAL_PYTHON}" "$@"
status=$?
[[ ${5:-} == "repair" ]] && ln -sfn "${LIVE_LOCK:?}" "$HOME/.config/chromium/SingletonLock"
exit $status
STUB
chmod +x "$stub_bin/python3"
if HOME="$home" PATH="$stub_bin:$PATH" bash -euo pipefail "$migration" >/dev/null 2>&1; then
  fail "migration stays pending when a browser starts mid-repair"
fi
jq -e --arg pinned "$pinned_id" '.extensions.commands["linux:Alt+Shift+L"].extension == $pinned' "$preferences" >/dev/null ||
  fail "migration still repairs preferences before deferring on a late browser"
pass "migration stays pending when a browser starts mid-repair"
rm -f "$stub_bin/python3" "$preferences.omarchy-copy-url-repair.bak"
close_browser

# A browser that started and exited mid-repair restores stale Preferences
# before the final profile check; the post-repair file verification catches it.
write_stale_preferences
cp "$preferences" "$test_dir/stale-preferences"
cat >"$stub_bin/python3" <<'STUB'
#!/bin/bash
"${REAL_PYTHON}" "$@"
status=$?
[[ ${5:-} == "repair" ]] && cp "${STALE_PREFERENCES:?}" "${REPAIRED_PREFERENCES:?}"
exit $status
STUB
chmod +x "$stub_bin/python3"
if HOME="$home" PATH="$stub_bin:$PATH" STALE_PREFERENCES="$test_dir/stale-preferences" \
  REPAIRED_PREFERENCES="$preferences" bash -euo pipefail "$migration" >/dev/null 2>&1; then
  fail "migration stays pending when a briefly-lived browser undoes the repair"
fi
pass "migration stays pending when a briefly-lived browser undoes the repair"
rm -f "$stub_bin/python3"
close_browser
write_stale_preferences
run_migration || fail "migration recovers after a reverted repair"
rm -f "$preferences.omarchy-copy-url-repair.bak"

# A repair attempted while the affected profile was open leaves its backup
# behind. A rerun that sees a clean disk while that profile still runs must
# stay pending — the browser can restore the ghost on exit — and only a
# browser-free rerun verifies the repair and completes.
write_stale_preferences
run_migration || fail "repair run before the verification scenario"
[[ -f $preferences.omarchy-copy-url-repair.bak ]] || fail "verification scenario has a repair backup"
open_browser
run_migration && fail "migration must not complete an unverified repair while a browser runs"
pass "migration keeps an unverified repair pending while a browser runs"
close_browser
run_migration || fail "migration completes once the repair is verified with browsers closed"
pass "migration verifies an attempted repair on a browser-free rerun"
rm -f "$preferences.omarchy-copy-url-repair.bak"

# An installed third-party extension with a command that happens to be named
# copy-url keeps its own registration.
jq -n '{extensions: {commands: {"linux:Alt+Shift+L": {command_name: "copy-url", extension: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", global: false}}, settings: {aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa: {path: "/home/user/.config/some-extension", commands: {}}}}}' >"$preferences"
untouched_hash=$(sha256sum "$preferences" | cut -d' ' -f1)
run_migration || fail "migration leaves installed third-party extensions alone"
[[ $(sha256sum "$preferences" | cut -d' ' -f1) == "$untouched_hash" ]] ||
  fail "migration does not steal a third-party copy-url command registration"
pass "migration leaves installed third-party extensions alone"

# Confirming a prompt that changes nothing must end the wait rather than ask
# again forever: this loop runs inside omarchy-update, so an unbounded one
# hangs the update with nothing the user can do about it.
write_stale_preferences
open_browser
cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
echo asked >>"${GUM_CALLS:?}"
exit 0
STUB
give_up_stderr="$test_dir/give-up-stderr"
gum_calls="$test_dir/gum-calls"
: >"$gum_calls"
status=0
HOME="$home" PATH="$stub_bin:$PATH" GUM_CALLS="$gum_calls" timeout 30 bash -euo pipefail "$migration" \
  >/dev/null 2>"$give_up_stderr" || status=$?
(( $(wc -l <"$gum_calls") == 3 )) || fail "migration asks three times before giving up"
(( status != 124 )) || fail "migration gives up instead of asking forever about a profile that stays open"
(( status != 0 )) || fail "migration defers while the profile stays open"
grep -q "$profile_root" "$give_up_stderr" || fail "migration names the profile it gave up on"
grep -q "Singleton" "$give_up_stderr" || fail "migration says how to clear a leftover lock"
[[ $(jq -r '.extensions.commands["linux:Alt+Shift+L"].extension' "$preferences") == "$ghost_id" ]] ||
  fail "migration leaves preferences alone when it gives up"
pass "migration gives up instead of asking forever about a profile that stays open"
close_browser

# Working through open profiles one prompt at a time is progress, not a stuck
# wait: the budget for a profile that never closes must not run out on someone
# closing four of them in a row.
multi_roots=("$home/.config/chromium" "$home/.config/google-chrome" "$home/.config/vivaldi" "$home/.config/opera")
for root in "${multi_roots[@]}"; do
  mkdir -p "$root/Default"
  jq -n --arg ghost "$ghost_id" '{extensions: {commands: {"linux:Alt+Shift+L": {command_name: "copy-url", extension: $ghost, global: false}}, settings: {}}}' >"$root/Default/Preferences"
  ln -sfn "$LIVE_LOCK" "$root/SingletonLock"
done
cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
# One window closed per prompt, in the order the migration asks about them.
for root in "$HOME/.config/chromium" "$HOME/.config/google-chrome" "$HOME/.config/vivaldi" "$HOME/.config/opera"; do
  [[ -L $root/SingletonLock ]] || continue
  rm -f "$root/SingletonLock"
  break
done
exit 0
STUB
chmod +x "$stub_bin/gum"
status=0
HOME="$home" PATH="$stub_bin:$PATH" timeout 60 bash -euo pipefail "$migration" >/dev/null 2>&1 || status=$?
(( status == 0 )) || fail "migration works through profiles closed one prompt at a time"
for root in "${multi_roots[@]}"; do
  jq -e --arg pinned "$pinned_id" '.extensions.commands["linux:Alt+Shift+L"].extension == $pinned' \
    "$root/Default/Preferences" >/dev/null || fail "migration repairs every profile once it closes"
done
pass "migration works through profiles closed one prompt at a time"

# --- extras from the user's branch: Brave, leftover sockets, --user-data-dir ---

printf '#!/bin/bash\nexit 1\n' >"$stub_bin/gum"
chmod +x "$stub_bin/gum"

stale_home="$test_dir/stale-lock-home"
stale_profiles=(
  "$stale_home/.config/chromium"
  "$stale_home/.config/BraveSoftware/Brave-Browser"
  "$stale_home/.config/google-chrome"
)
stale_socket_paths=(
  "$stale_home/.config/chromium/SingletonSocket"
  "$stale_home/.config/BraveSoftware/Brave-Browser/SingletonSocket"
)
dead_pid=$(($(</proc/sys/kernel/pid_max) + 1))
uname_host=$(uname -n)

for profile in "${stale_profiles[@]}"; do
  stale_prefs="$profile/Default/Preferences"
  mkdir -p "$(dirname "$stale_prefs")"
  printf '%s\n' "$ghost_preferences_json" >"$stale_prefs"
  lock_pid=$dead_pid
  if [[ $profile == "$stale_home/.config/google-chrome" ]]; then
    lock_pid=$$
  fi
  ln -s "$uname_host-$lock_pid" "$profile/SingletonLock"
done

python3 - "${stale_socket_paths[@]}" <<'PY'
import socket
import sys

for path in sys.argv[1:]:
    stale_socket = socket.socket(socket.AF_UNIX)
    stale_socket.bind(path)
    stale_socket.close()
PY

HOME="$stale_home" PATH="$stub_bin:$PATH" \
  bash -euo pipefail "$migration" >"$test_dir/stale-lock.out" 2>&1 ||
  fail "the migration completes with stale Chromium and Brave singleton files" "$(cat "$test_dir/stale-lock.out")"

python3 - "$stale_home/.config/chromium/Default/Preferences" \
  "$stale_home/.config/BraveSoftware/Brave-Browser/Default/Preferences" <<'PY' || fail "the stale Chromium and Brave profiles' Copy URL shortcuts are repaired"
import json
import sys

for path in sys.argv[1:]:
    with open(path) as preferences_file:
        preferences = json.load(preferences_file)
    assert preferences["extensions"]["commands"]["linux:Alt+Shift+L"]["extension"] == "bgpiichlckmfanooecilcjemknkcpngb"
PY
for profile in "${stale_profiles[@]}"; do
  [[ -f $profile/Default/Preferences.omarchy-copy-url-repair.bak ]] ||
    fail "the stale profile $profile gets a repair backup"
done
pass "stale singleton files and a reused PID do not block the shortcut repair"

# A live Unix socket still blocks even when the lock names a foreign host.
active_home="$test_dir/active-lock-home"
active_profile="$active_home/.config/BraveSoftware/Brave-Browser"
socket_path="$test_dir/brave-SingletonSocket"
ready="$test_dir/socket-ready"
active_preferences="$active_profile/Default/Preferences"
mkdir -p "$(dirname "$active_preferences")"
printf '%s\n' "$ghost_preferences_json" >"$active_preferences"

python3 - "$socket_path" "$ready" <<'PY' &
import socket
import sys
import time

server = socket.socket(socket.AF_UNIX)
server.bind(sys.argv[1])
server.listen()
open(sys.argv[2], "w").close()
time.sleep(30)
PY
socket_pid=$!
for attempt in {1..50}; do
  [[ -S $socket_path && -f $ready ]] && break
  sleep 0.1
done
[[ -S $socket_path && -f $ready ]] || fail "the test Brave socket starts"
ln -s "foreign-$uname_host-123" "$active_profile/SingletonLock"
ln -s "$socket_path" "$active_profile/SingletonSocket"

if HOME="$active_home" PATH="$stub_bin:$PATH" \
  bash -euo pipefail "$migration" >"$test_dir/active-lock.out" 2>&1; then
  fail "the migration remains pending when the browser socket is live"
fi
grep -q "A running browser would undo the Copy URL shortcut repair" "$test_dir/active-lock.out" ||
  fail "the active-profile failure explains why the repair is deferred" "$(cat "$test_dir/active-lock.out")"
[[ ! -e $active_preferences.omarchy-copy-url-repair.bak ]] ||
  fail "the migration does not edit the active profile"
pass "a live Brave SingletonSocket blocks repair with a foreign-host lock"

# Same-host dead pid plus a socket that still answers: the connect() fallback.
dead_socket_home="$test_dir/dead-pid-live-socket-home"
dead_socket_profile="$dead_socket_home/.config/chromium"
dead_socket_prefs="$dead_socket_profile/Default/Preferences"
mkdir -p "$(dirname "$dead_socket_prefs")"
printf '%s\n' "$ghost_preferences_json" >"$dead_socket_prefs"
ln -s "$uname_host-$dead_pid" "$dead_socket_profile/SingletonLock"
ln -s "$socket_path" "$dead_socket_profile/SingletonSocket"

if HOME="$dead_socket_home" PATH="$stub_bin:$PATH" \
  bash -euo pipefail "$migration" >"$test_dir/dead-pid-socket.out" 2>&1; then
  fail "the migration remains pending when a leftover lock has a live socket"
fi
[[ ! -e $dead_socket_prefs.omarchy-copy-url-repair.bak ]] ||
  fail "the migration does not edit a profile whose singleton socket is live"
pass "a live SingletonSocket blocks repair through a dead same-host lock"

kill "$socket_pid" 2>/dev/null || true
wait "$socket_pid" 2>/dev/null || true
socket_pid=""

# --user-data-dir is an extra open signal, not the only one.
pid_home="$test_dir/active-pid-home"
pid_profile="$pid_home/.config/chromium"
pid_preferences="$pid_profile/Default/Preferences"
pid_ready="$test_dir/profile-process-ready"
mkdir -p "$(dirname "$pid_preferences")"
printf '%s\n' "$ghost_preferences_json" >"$pid_preferences"

python3 -c 'import sys, time; open(sys.argv[-1], "w").close(); time.sleep(30)' \
  --user-data-dir "$pid_profile" "$pid_ready" &
profile_pid=$!
for attempt in {1..50}; do
  [[ -f $pid_ready ]] && break
  sleep 0.1
done
[[ -f $pid_ready ]] || fail "the process for the same-host lock starts"
ln -s "$uname_host-$profile_pid" "$pid_profile/SingletonLock"

if HOME="$pid_home" PATH="$stub_bin:$PATH" \
  bash -euo pipefail "$migration" >"$test_dir/active-pid.out" 2>&1; then
  fail "the migration remains pending when the same-host profile process is live"
fi
grep -q "A running browser would undo the Copy URL shortcut repair" "$test_dir/active-pid.out" ||
  fail "the same-host PID failure explains why the repair is deferred" "$(cat "$test_dir/active-pid.out")"
[[ ! -e $pid_preferences.omarchy-copy-url-repair.bak ]] ||
  fail "the migration does not edit the profile identified by the live PID"
[[ ! -e $pid_profile/SingletonSocket ]] ||
  fail "the same-host PID case has no socket to trigger the fallback"
pass "a live same-host PID using the profile blocks repair"
