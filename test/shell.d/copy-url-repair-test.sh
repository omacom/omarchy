#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command jq
require_command python3

repair_cmd="$ROOT/bin/omarchy-cmd-repair-chromium-copy-url"
test_dir=$(mktemp -d)
socket_pid=""
cleanup() {
  if [[ -n $socket_pid ]]; then
    kill "$socket_pid" 2>/dev/null || true
    wait "$socket_pid" 2>/dev/null || true
  fi
  rm -rf "$test_dir"
}
trap cleanup EXIT

fixture_home="$test_dir/home"
profile_root="$fixture_home/.config/chromium"
preferences="$profile_root/Default/Preferences"
mkdir -p "$(dirname "$preferences")"

# Any id Chromium once derived from the extension's keyless load path; the
# repair keys off the registered command name, not the id.
ghost_id="ikkebdkaanlebnifjnbeiaklodhbjcci"
pinned_id="bgpiichlckmfanooecilcjemknkcpngb"

write_stale_preferences() {
  jq -n --arg ghost "$ghost_id" --arg pinned "$pinned_id" '{
    extensions: {
      commands: {"linux:Alt+Shift+L": {command_name: "copy-url", extension: $ghost, global: false}},
      settings: {
        ($ghost): {commands: {"copy-url": {suggested_key: "Alt+Shift+L", was_assigned: true}}},
        ($pinned): {commands: {"copy-url": {suggested_key: "Alt+Shift+L"}}}
      }
    },
    protection: {macs: {extensions: {commands: "stale-command-mac", settings: {($ghost): "stale-settings-mac"}}}}
  }' >"$preferences"
}

stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

REAL_PYTHON=$(command -v python3)
export REAL_PYTHON

run_repair() {
  HOME="$fixture_home" PATH="$stub_bin:$ROOT/bin:$PATH" "$repair_cmd" >/dev/null 2>&1
}

run_migration() {
  HOME="$fixture_home" PATH="$stub_bin:$ROOT/bin:$PATH" bash -euo pipefail "$repair_cmd" --prompt >/dev/null 2>&1
}

# A running Chromium-family browser marks its profile root with a SingletonLock
# symlink to <hostname>-<pid>. Only a live PID counts as attached; a lock left
# by SIGTERM still points at a dead pid and must not block the repair.
open_browser() {
  mkdir -p "$profile_root"
  ln -sfn "test-host-$$" "$profile_root/SingletonLock"
}
stale_browser_lock() {
  mkdir -p "$profile_root"
  ln -sfn "test-host-999999999" "$profile_root/SingletonLock"
}
close_browser() {
  rm -f "$profile_root/SingletonLock"
}

assert_repaired() {
  jq -e --arg ghost "$ghost_id" --arg pinned "$pinned_id" '
    .extensions.commands["linux:Alt+Shift+L"].extension == $pinned and
    (.extensions.settings | has($ghost) | not) and
    .extensions.settings[$pinned].commands["copy-url"].was_assigned == true and
    .protection.macs.extensions.commands == "stale-command-mac"
  ' "$preferences" >/dev/null
}

assert_no_tmp() {
  local leftover
  leftover=$(find "$profile_root/Default" -maxdepth 1 \( -name '.Preferences.*' -o -name 'Preferences.tmp*' \))
  [[ -z $leftover ]]
}

# A running Chromium-family browser marks its profile root with a SingletonLock
# symlink to <hostname>-<pid>, a target that never exists on disk. That lock —
# not the mere presence of a browser process — is what the repair waits on.
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

# Quiet callers skip without gum and without failing — login and browser launch
# must not block on a running profile.
run_repair || fail "quiet repair skips while the affected profile is open"
[[ $(sha256sum "$preferences" | cut -d' ' -f1) == "$before_hash" ]] ||
  fail "quiet repair leaves preferences alone while the affected profile is open"
pass "quiet repair skips while the affected profile is open"

# A dangling SingletonLock whose pid is dead is not an attached browser; SIGTERM
# leaves that symlink behind and the repair must still persist.
stale_browser_lock
run_repair || fail "quiet repair proceeds past a stale SingletonLock"
assert_repaired || fail "quiet repair rewrites preferences behind a stale lock"
assert_no_tmp || fail "repair leaves no Preferences temp file behind a stale lock"
pass "stale SingletonLock does not block the repair"
rm -f "$preferences.omarchy-copy-url-repair.bak"
close_browser

# A lock whose PID is not locally visible can still have a browser socket.
write_stale_preferences
stale_browser_lock
python3 - "$profile_root/SingletonSocket" "$test_dir/socket-ready" <<'PY_SOCKET' &
from pathlib import Path
import signal
import socket
import sys
with socket.socket(socket.AF_UNIX) as sock:
    sock.bind(sys.argv[1])
    sock.listen(5)
    Path(sys.argv[2]).touch()
    signal.pause()
PY_SOCKET
socket_pid=$!
for attempt in {1..100}; do
  [[ -f $test_dir/socket-ready ]] && break
  sleep 0.01
done
[[ -f $test_dir/socket-ready ]] || fail "fixture socket starts listening"
before_hash=$(sha256sum "$preferences" | cut -d' ' -f1)
run_migration && fail "socket prevents repair when the lock PID is unavailable"
[[ $(sha256sum "$preferences" | cut -d' ' -f1) == "$before_hash" ]] ||
  fail "socket-protected preferences remain untouched"
pass "browser socket protects a profile with an unavailable lock PID"

kill "$socket_pid"
wait "$socket_pid" 2>/dev/null || true
socket_pid=""
[[ -S $profile_root/SingletonSocket ]] || fail "fixture leaves an abandoned socket"
run_migration || fail "abandoned socket does not block migration"
assert_repaired || fail "repair proceeds after the socket listener exits"
rm -f "$profile_root/SingletonSocket" "$preferences.omarchy-copy-url-repair.bak"
close_browser
pass "abandoned socket does not block repair"

# An interrupted backup must not block all future migrations if its profile
# was removed or became unreadable. Keep the backup for manual recovery.
write_stale_preferences
cp "$preferences" "$preferences.omarchy-copy-url-repair.bak"
backup_hash=$(sha256sum "$preferences.omarchy-copy-url-repair.bak" | cut -d' ' -f1)
rm "$preferences"
open_browser
run_migration || fail "missing profile does not hold unrelated migrations"
printf '{broken json' >"$preferences"
run_migration || fail "corrupt profile does not hold unrelated migrations"
[[ $(cat "$preferences") == '{broken json' ]] || fail "corrupt preferences remain untouched"
[[ $(sha256sum "$preferences.omarchy-copy-url-repair.bak" | cut -d' ' -f1) == "$backup_hash" ]] ||
  fail "unreadable profile retains its recovery backup"
close_browser
write_stale_preferences
run_migration || fail "restored profile can be repaired later"
assert_repaired || fail "restored profile receives the shortcut repair"
pass "missing and corrupt profiles keep backups without blocking migrations"

# gum paints its prompt on stderr, so that stream has to stay attached:
# suppressing it leaves gum reading keys behind an unpainted screen, which
# reads as a hung update.
cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
echo "gum-prompt-painted" >&2
exit 1
STUB
write_stale_preferences
open_browser
prompt_stderr="$test_dir/prompt-stderr"
HOME="$fixture_home" PATH="$stub_bin:$ROOT/bin:$PATH" bash -euo pipefail "$repair_cmd" --prompt >/dev/null 2>"$prompt_stderr" &&
  fail "migration defers when the browser prompt is declined"
grep -q "gum-prompt-painted" "$prompt_stderr" || fail "migration keeps the browser prompt visible"
pass "migration keeps the browser prompt visible"

# A browser holding a different profile root cannot revert this repair, so it
# must not hold the update: the repair goes through without ever reaching the
# prompt, which the still-declining gum stub would otherwise fail.
close_browser
mkdir -p "$fixture_home/.config/google-chrome"
ln -sfn "test-host-$$" "$fixture_home/.config/google-chrome/SingletonLock"
write_stale_preferences
run_migration || fail "migration repairs while a different profile root is open"
assert_repaired || fail "migration repairs the shortcut while a different profile root is open"
pass "migration ignores a browser on a different profile root"
rm -f "$fixture_home/.config/google-chrome/SingletonLock" "$preferences.omarchy-copy-url-repair.bak"

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
  HOME="$fixture_home" PATH="$stub_bin:$ROOT/bin:$PATH" bash -euo pipefail "$repair_cmd" --prompt >/dev/null 2>&1 ||
  fail "migration proceeds once the profile is closed and the prompt confirmed"
[[ -e $test_dir/gum-called ]] || fail "migration asks before repairing under a running browser"
assert_repaired || fail "migration repairs after the browser prompt is confirmed"
pass "migration asks to close the browser and repairs on confirmation"
rm -f "$preferences.omarchy-copy-url-repair.bak"

# With the affected profile closed the ghost registration moves to the pinned id.
printf '#!/bin/bash\nexit 1\n' >"$stub_bin/gum"
close_browser
write_stale_preferences
run_migration || fail "migration repairs the shortcut when no browser is running"

assert_repaired || fail "migration rebinds the Copy URL shortcut to the pinned extension id"
[[ ! -e $preferences.omarchy-copy-url-repair.bak ]] ||
  fail "verified repair clears its pending backup"
assert_no_tmp || fail "repair leaves no Preferences temp file after a successful write"
pass "migration rebinds the Copy URL shortcut to the pinned extension id"

# Install-time stamping must not prevent the command from repairing a profile
# that arrived later.
mkdir -p "$fixture_home/.local/state/omarchy/migrations"
touch "$fixture_home/.local/state/omarchy/migrations/1786643346.sh"

rm -f "$preferences.omarchy-copy-url-repair.bak"
write_stale_preferences
run_repair || fail "repair command runs even when the migrations are stamped complete"
assert_repaired || fail "stamped migrations still leave the command able to repair"
pass "repair command is independent of install-time migration stamps"
rm -f "$preferences.omarchy-copy-url-repair.bak"
rm -rf "$fixture_home/.local/state/omarchy/migrations"

# A repaired profile has no ghost registration left, so nothing is pending —
# even while that same profile is open.
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
[[ ${5:-} == "repair" ]] && ln -sfn "test-host-${LIVE_PID:?}" "$HOME/.config/chromium/SingletonLock"
exit $status
STUB
chmod +x "$stub_bin/python3"
if HOME="$fixture_home" PATH="$stub_bin:$ROOT/bin:$PATH" LIVE_PID=$$ bash -euo pipefail "$repair_cmd" --prompt >/dev/null 2>&1; then
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
if HOME="$fixture_home" PATH="$stub_bin:$ROOT/bin:$PATH" STALE_PREFERENCES="$test_dir/stale-preferences" \
  REPAIRED_PREFERENCES="$preferences" bash -euo pipefail "$repair_cmd" --prompt >/dev/null 2>&1; then
  fail "migration stays pending when a briefly-lived browser undoes the repair"
fi
pass "migration stays pending when a briefly-lived browser undoes the repair"
rm -f "$stub_bin/python3"
close_browser
write_stale_preferences
run_migration || fail "migration recovers after a reverted repair"
rm -f "$preferences.omarchy-copy-url-repair.bak"

# A backup from an interrupted repair stays pending while the profile is open,
# then disappears after a closed-profile verification. Later browser sessions
# must not trigger another prompt for that already verified repair.
write_stale_preferences
cp "$preferences" "$test_dir/original-preferences"
run_migration || fail "repair run before the verification scenario"
cp "$test_dir/original-preferences" "$preferences.omarchy-copy-url-repair.bak"
open_browser
run_migration && fail "an interrupted repair stays pending while a browser runs"
close_browser
run_migration || fail "repair verifies with the profile closed"
[[ ! -e $preferences.omarchy-copy-url-repair.bak ]] || fail "verification retires the backup"
open_browser
run_migration || fail "a verified repair must not prompt on a later browser session"
close_browser
pass "verified repairs stop prompting on later browser sessions"

# First-run invokes the quiet command, so a profile already present at first
# login is repaired without going through omarchy-migrate.
write_stale_preferences
HOME="$fixture_home" PATH="$stub_bin:$ROOT/bin:$PATH" bash "$ROOT/install/user/first-run/chromium-copy-url.sh" ||
  fail "first-run Copy URL hook repairs a present profile"
assert_repaired || fail "first-run Copy URL hook rebinds the pinned extension id"
pass "first-run hook repairs Copy URL when Preferences already exists"
rm -f "$preferences.omarchy-copy-url-repair.bak"

# An installed third-party extension with a command that happens to be named
# copy-url keeps its own registration.
jq -n '{extensions: {commands: {"linux:Alt+Shift+L": {command_name: "copy-url", extension: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", global: false}}, settings: {aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa: {path: "/home/user/.config/some-extension", commands: {}}}}}' >"$preferences"
untouched_hash=$(sha256sum "$preferences" | cut -d' ' -f1)
run_migration || fail "migration leaves installed third-party extensions alone"
[[ $(sha256sum "$preferences" | cut -d' ' -f1) == "$untouched_hash" ]] ||
  fail "migration does not steal a third-party copy-url command registration"
pass "migration leaves installed third-party extensions alone"
