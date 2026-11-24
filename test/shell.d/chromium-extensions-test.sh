#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Chromium derives an extension's id from its public key: the first 128 bits of
# its SHA-256, each hex digit spelled a-p.
extension_id() {
  jq -r .key "$1" | base64 -d | sha256sum | cut -c1-32 | tr '0-9a-f' 'a-p'
}

# --- Bundled extensions ---

# A keyless unpacked extension gets a path-derived id, so its settings, shortcut
# registrations and native host grants would go stale whenever its load path
# changed. The pinned key keeps the id stable everywhere, and a regenerated key
# would orphan the same things, so the ids that shipped stay pinned here.
declare -A shipped_id=(
  [copy-url]=bgpiichlckmfanooecilcjemknkcpngb
  [whatsapp-slim]=amhpgjbcfakkmkeojmoaoiochhifohdi
  [yt-dlp]=dedjgknigfeelejglamclffonmophnfl
)
declare -A extension_manifest
for manifest in "$ROOT"/default/chromium/extensions/*/manifest.json; do
  extension_dir=${manifest%/manifest.json}
  name=${extension_dir##*/}
  jq -e '.key | type == "string"' "$manifest" >/dev/null || fail "the $name extension pins its id with a manifest key"
  id=$(extension_id "$manifest")
  [[ $id =~ ^[a-p]{32}$ ]] || fail "the $name extension's key decodes to an extension id" "got: $id"
  [[ -z ${shipped_id[$name]:-} || $id == "${shipped_id[$name]}" ]] ||
    fail "the $name extension keeps the id it shipped with" "got: $id"
  extension_manifest[$id]=$manifest

  while read -r file; do
    [[ -f $extension_dir/$file ]] || fail "the $name extension ships $file, which its manifest loads"
  done < <(jq -r '[.background.service_worker, (.content_scripts[]? | .js[]?, .css[]?), (.icons // {} | .[])] | .[] | strings' "$manifest")
done
pass "each bundled Chromium extension pins its id and ships the files its manifest loads"

# --- Google Chrome CRXs ---

# Chrome ignores --load-extension, so policy installs each extension from a
# signed CRX under its own id. A CRX left behind its source would give Chrome
# users the old extension, and one whose version didn't move would never update.
require_command bsdtar
crx_dir=$ROOT/default/chromium/crx
crx_policy=$ROOT/default/chromium/policies/chrome-extensions.json
for extension_dir in "$ROOT"/default/chromium/extensions/*/; do
  name=$(basename "$extension_dir")
  crx=$crx_dir/$name.crx
  [[ -f $crx ]] || fail "the $name extension ships a CRX for Chrome" "run omarchy-dev-pack-chrome-extensions"

  expected=$test_tmp/crx-expected/$name
  shipped=$test_tmp/crx-shipped/$name
  mkdir -p "$(dirname "$expected")" "$shipped"
  cp -rL "$extension_dir" "$expected"
  jq 'del(.key)' "$extension_dir/manifest.json" >"$expected/manifest.json"
  # A CRX is a signed header and then a zip, which bsdtar finds from the
  # central directory at its end. Streamed through a pipe, libarchive 3.8.10
  # fails on the zip instead.
  bsdtar -xf "$crx" -C "$shipped"
  diff -r "$expected" "$shipped" >/dev/null ||
    fail "$name.crx matches its source" "run omarchy-dev-pack-chrome-extensions after bumping the version in $name/manifest.json"

  app=$(grep -F "/$name.crx'" "$crx_dir/updates.xml") || fail "updates.xml offers $name.crx"
  [[ $app =~ appid=\'([a-p]{32})\'.*codebase=\'file:///usr/share/omarchy/default/chromium/crx/$name\.crx\'\ version=\'([^\']+)\' ]] ||
    fail "updates.xml offers $name.crx from the installed Omarchy tree" "$app"
  id=${BASH_REMATCH[1]}
  [[ ${BASH_REMATCH[2]} == "$(jq -r .version "$expected/manifest.json")" ]] ||
    fail "updates.xml offers $name at its manifest version"
  jq -e --arg id "$id" '.ExtensionSettings[$id] | .installation_mode == "force_installed" and .update_url == "file:///usr/share/omarchy/default/chromium/crx/updates.xml"' "$crx_policy" >/dev/null ||
    fail "Chrome's policy installs $name from updates.xml"
  extension_manifest[$id]=$extension_dir/manifest.json
done
[[ $(jq '.ExtensionSettings | length' "$crx_policy") == "$(ls "$ROOT"/default/chromium/extensions | wc -l)" ]] ||
  fail "Chrome's policy installs only the bundled extensions"
pass "each bundled extension ships as a current CRX that Chrome's policy installs"

# --- Native messaging hosts ---

# Each host admits exactly the bundled extensions whose scripts message it, and
# each extension that asks for native messaging has a host admitting its id.
declare -A hosted
for template in "$ROOT"/default/chromium/native-messaging-hosts/*.json; do
  host=$(basename "$template" .json)
  [[ $(jq -r .name "$template") == "$host" ]] || fail "native host $host is named after its manifest file"
  senders=$(
    for id in "${!extension_manifest[@]}"; do
      if grep -rqF -e "sendNativeMessage('$host'" -e "sendNativeMessage(\"$host\"" \
        -e "connectNative('$host'" -e "connectNative(\"$host\"" "$(dirname "${extension_manifest[$id]}")"; then
        printf 'chrome-extension://%s/\n' "$id"
      fi
    done | sort
  )
  [[ -n $senders && $(jq -r '.allowed_origins[]' "$template" | sort) == "$senders" ]] ||
    fail "native host $host admits exactly the extensions that message it" "admits: $(jq -c .allowed_origins "$template"), messaged by: ${senders:-none}"
  while read -r origin; do
    id=${origin#chrome-extension://}
    id=${id%/}
    [[ $origin == "chrome-extension://$id/" && -v extension_manifest[$id] ]] ||
      fail "native host $host admits only bundled extensions" "origin: $origin"
    jq -e '.permissions | index("nativeMessaging")' "${extension_manifest[$id]}" >/dev/null ||
      fail "native host $host admits an extension that asks for native messaging" "origin: $origin"
    hosted[$id]=1
  done < <(jq -r '.allowed_origins[]' "$template")
done
for id in "${!extension_manifest[@]}"; do
  if jq -e '.permissions | index("nativeMessaging")' "${extension_manifest[$id]}" >/dev/null; then
    [[ -v hosted[$id] ]] || fail "a native host admits the $(basename "$(dirname "${extension_manifest[$id]}")") extension's id $id"
  fi
done
pass "each native messaging host admits exactly the bundled extension that talks to it"

# Chromium ships in the base packages, so fresh installs do not go through
# omarchy-install-browser and mark every migration as already applied. The user
# install has to register the hosts itself.
home="$test_tmp/home"
HOME="$home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
  bash -euo pipefail -c 'source "$ROOT/install/user/chromium.sh"' ||
  fail "the user install registers the Chromium native messaging hosts"

for template in "$ROOT"/default/chromium/native-messaging-hosts/*.json; do
  host=$(basename "$template" .json)
  for profile in chromium BraveSoftware/Brave-Origin; do
    installed="$home/.config/$profile/NativeMessagingHosts/$host.json"
    [[ -f $installed ]] || fail "a fresh install registers native host $host for $profile"
    path=$(jq -r .path "$installed")
    [[ $path == "$ROOT/bin/"* && -x $path ]] ||
      fail "native host $host for $profile runs an Omarchy host command" "path: $path"
    [[ $(jq -c .allowed_origins "$installed") == "$(jq -c .allowed_origins "$template")" ]] ||
      fail "native host $host for $profile admits the bundled extension"
  done
done
pass "a fresh install registers every native messaging host for Chromium and Brave Origin"

# Switching to a browser repairs its copies of the bundled extensions: the
# flags file gains the extensions it lacks without losing the user's own flags
# and extensions, and its native hosts admit the current ids.
home="$test_tmp/repair-home"
flags_file=$home/.config/brave-origin-flags.conf
mkdir -p "$home/.config"
printf -- '--force-dark-mode\n--load-extension=/home/me/my-extension,/usr/share/omarchy/default/chromium/extensions/copy-url --ozone-platform=wayland' >"$flags_file"
repair() {
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-install-browser-extensions" "$@"
}
if repair --check brave-origin; then
  fail "a browser missing bundled extensions is reported stale"
fi
repair brave-origin || fail "a browser's bundled extensions can be repaired without root"
repair --check brave-origin || fail "a repaired browser's bundled extensions are reported current"
grep -Fxq -- '--force-dark-mode' "$flags_file" || fail "the repair keeps the user's own flags"
[[ $(grep -c -- '--load-extension=' "$flags_file") == 1 ]] || fail "the repair keeps a single --load-extension switch"
[[ $(grep -o -- '--ozone-platform=[^[:space:]]*' "$flags_file") == "--ozone-platform=wayland" ]] ||
  fail "the repair leaves other switches on the --load-extension line alone" "$(<"$flags_file")"
loaded=$(grep -o -- '--load-extension=[^[:space:]]*' "$flags_file" | sed 's/^--load-extension=//' | tr ',' '\n')
grep -Fxq /home/me/my-extension <<<"$loaded" || fail "the repair keeps the user's own extensions"
while read -r extension; do
  [[ $(grep -cFx -- "$extension" <<<"$loaded") == 1 ]] || fail "the repair loads $extension exactly once"
done < <(sed -n 's/^--load-extension=//p' "$ROOT/config/chromium-flags.conf" | tr ',' '\n')

# A switch inside a trailing comment loads nothing, so it is stale and the
# repair adds a live switch rather than extending the comment.
printf -- '--force-dark-mode # --load-extension=/old\n' >"$flags_file"
if repair --check brave-origin; then
  fail "a --load-extension switch inside a comment is reported stale"
fi
repair brave-origin || fail "a commented-out --load-extension switch can be repaired"
[[ $(head -n1 "$flags_file") == "--force-dark-mode # --load-extension=/old" ]] ||
  fail "the repair leaves the comment alone" "$(<"$flags_file")"
[[ $(sed -n 2p "$flags_file") == "--load-extension=$(sed -n 's/^--load-extension=//p' "$ROOT/config/chromium-flags.conf")" ]] ||
  fail "the repair adds a live --load-extension switch" "$(<"$flags_file")"
pass "switching to a browser repairs the bundled extensions it lacks and keeps the user's own"

# --- WhatsApp Slim ---

# The content script switches WhatsApp Web to its system theme mode, which it
# only reads at startup, so it reloads once; with the mode already set it must
# not reload again, or the page would never finish loading.
if command -v node >/dev/null; then
  reloads=$(node - "$ROOT/default/chromium/extensions/whatsapp-slim/system-theme.js" <<'JS'
const fs = require("fs")
const source = fs.readFileSync(process.argv[2], "utf8")
const values = new Map()
const reloads = []
global.localStorage = {
  getItem: key => values.get(key),
  setItem: (key, value) => values.set(key, value),
}
for (const run of [1, 2]) {
  global.location = { reload: () => reloads.push(run) }
  eval(source)
}
process.stdout.write(`${values.get("system-theme-mode")}:${reloads.join(",")}`)
JS
  )
  [[ $reloads == "true:1" ]] || fail "WhatsApp selects its system theme mode and reloads only once" "$reloads"
  pass "WhatsApp follows the system theme through its slim extension"
else
  skip "node is not installed; skipping the WhatsApp Slim content script check"
fi

# --- Copy URL profile repair ---

(
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

# Quiet login repair skips without gum and without failing while a profile
# is running.
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
rm -f "$preferences.omarchy-copy-url-repair.pending.bak"
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
rm -f "$profile_root/SingletonSocket" "$preferences.omarchy-copy-url-repair.pending.bak"
close_browser
pass "abandoned socket does not block repair"

# An interrupted backup must not block all future migrations if its profile
# was removed or became unreadable. Keep the backup for manual recovery.
write_stale_preferences
cp "$preferences" "$preferences.omarchy-copy-url-repair.pending.bak"
backup_hash=$(sha256sum "$preferences.omarchy-copy-url-repair.pending.bak" | cut -d' ' -f1)
rm "$preferences"
open_browser
run_migration || fail "missing profile does not hold unrelated migrations"
printf '{broken json' >"$preferences"
run_migration || fail "corrupt profile does not hold unrelated migrations"
[[ $(cat "$preferences") == '{broken json' ]] || fail "corrupt preferences remain untouched"
[[ $(sha256sum "$preferences.omarchy-copy-url-repair.pending.bak" | cut -d' ' -f1) == "$backup_hash" ]] ||
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
rm -f "$fixture_home/.config/google-chrome/SingletonLock" "$preferences.omarchy-copy-url-repair.pending.bak"

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
rm -f "$preferences.omarchy-copy-url-repair.pending.bak"

# With the affected profile closed the ghost registration moves to the pinned id.
printf '#!/bin/bash\nexit 1\n' >"$stub_bin/gum"
close_browser
write_stale_preferences
run_migration || fail "migration repairs the shortcut when no browser is running"

assert_repaired || fail "migration rebinds the Copy URL shortcut to the pinned extension id"
[[ ! -e $preferences.omarchy-copy-url-repair.pending.bak ]] ||
  fail "verified repair clears its pending backup"
assert_no_tmp || fail "repair leaves no Preferences temp file after a successful write"
pass "migration rebinds the Copy URL shortcut to the pinned extension id"

# Install-time stamping must not prevent the command from repairing a profile
# that arrived later.
mkdir -p "$fixture_home/.local/state/omarchy/migrations"
touch "$fixture_home/.local/state/omarchy/migrations/1786643346.sh"

rm -f "$preferences.omarchy-copy-url-repair.pending.bak"
write_stale_preferences
run_repair || fail "repair command runs even when the migrations are stamped complete"
assert_repaired || fail "stamped migrations still leave the command able to repair"
pass "repair command is independent of install-time migration stamps"
rm -f "$preferences.omarchy-copy-url-repair.pending.bak"
rm -rf "$fixture_home/.local/state/omarchy/migrations"

# A repaired profile has no ghost registration left, so nothing is pending —
# even while that same profile is open.
repaired_hash=$(sha256sum "$preferences" | cut -d' ' -f1)
open_browser
run_migration || fail "migration reruns cleanly after the repair"
[[ $(sha256sum "$preferences" | cut -d' ' -f1) == "$repaired_hash" && ! -e $preferences.omarchy-copy-url-repair.pending.bak ]] ||
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
rm -f "$preferences.omarchy-copy-url-repair.pending.bak"
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
rm -f "$stub_bin/python3" "$preferences.omarchy-copy-url-repair.pending.bak"
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
rm -f "$preferences.omarchy-copy-url-repair.pending.bak"

# A backup from an interrupted repair stays pending while the profile is open,
# then disappears after a closed-profile verification. Later browser sessions
# must not trigger another prompt for that already verified repair.
write_stale_preferences
cp "$preferences" "$test_dir/original-preferences"
run_migration || fail "repair run before the verification scenario"
cp "$test_dir/original-preferences" "$preferences.omarchy-copy-url-repair.pending.bak"
open_browser
run_migration && fail "an interrupted repair stays pending while a browser runs"
close_browser
run_migration || fail "repair verifies with the profile closed"
[[ ! -e $preferences.omarchy-copy-url-repair.pending.bak ]] || fail "verification retires the backup"
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
rm -f "$preferences.omarchy-copy-url-repair.pending.bak"

# An installed third-party extension with a command that happens to be named
# copy-url keeps its own registration.
jq -n '{extensions: {commands: {"linux:Alt+Shift+L": {command_name: "copy-url", extension: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", global: false}}, settings: {aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa: {path: "/home/user/.config/some-extension", commands: {}}}}}' >"$preferences"
untouched_hash=$(sha256sum "$preferences" | cut -d' ' -f1)
run_migration || fail "migration leaves installed third-party extensions alone"
[[ $(sha256sum "$preferences" | cut -d' ' -f1) == "$untouched_hash" ]] ||
  fail "migration does not steal a third-party copy-url command registration"
pass "migration leaves installed third-party extensions alone"

# Shipped migrations left recovery copies even after a successful repair.
write_stale_preferences
run_repair || fail "repair before the legacy recovery scenario succeeds"
legacy_backup="$preferences.omarchy-copy-url-repair.bak"
cp "$preferences" "$legacy_backup"
open_browser
run_migration || fail "a legacy recovery backup does not prompt for an already repaired profile"
[[ -f $legacy_backup ]] || fail "legacy recovery backups remain available"
close_browser
pass "legacy recovery backups do not become pending repairs"

# A profile restored after install is repaired by the login entry point even
# though the original migration has already been stamped complete.
write_stale_preferences
mkdir -p "$fixture_home/.local/state/omarchy/migrations"
touch "$fixture_home/.local/state/omarchy/migrations/1786643346.sh"
printf '#!/bin/bash\nexit 1\n' >"$stub_bin/omarchy-migrate"
chmod +x "$stub_bin/omarchy-migrate"
HOME="$fixture_home" XDG_RUNTIME_DIR="$test_dir/runtime" PATH="$stub_bin:$ROOT/bin:$PATH" \
  bash "$ROOT/bin/omarchy-migrate-notify" || fail "login repair runs with no pending migrations"
assert_repaired || fail "login repairs the restored profile despite the migration stamp"
pass "login repairs a profile missed by install-time migration stamping"

# Run the real first-run orchestrator with its other setup leaves inert,
# so the profile is the only state it can change.
write_stale_preferences
first_root="$test_dir/first-run-root"
mkdir -p "$first_root/install/user/first-run"
for leaf in "$ROOT"/install/user/first-run/*.sh; do
  printf 'exit 0\n' >"$first_root/install/user/first-run/${leaf##*/}"
done
cp "$ROOT/install/user/first-run/chromium-copy-url.sh" "$first_root/install/user/first-run/"
printf '#!/bin/bash\n[[ $1 != "check" ]]\n' >"$stub_bin/omarchy-done"
for helper in omarchy-provision-user omarchy-lifecycle-dispatch omarchy-notification-wait; do
  printf '#!/bin/bash\nexit 0\n' >"$stub_bin/$helper"
done
chmod +x "$stub_bin"/*
HOME="$fixture_home" OMARCHY_PATH="$first_root" PATH="$stub_bin:$ROOT/bin:$PATH" \
  bash "$ROOT/bin/omarchy-provision-first-run" || fail "first-run orchestrator runs the repair leaf"
assert_repaired || fail "first-run orchestrator repairs the stale shortcut"
pass "first-run orchestrator repairs a stale Copy URL shortcut"

# All Brave Origin channels use distinct roots and must reach the shared repair.
for browser in Brave-Origin Brave-Origin-Beta Brave-Origin-Nightly; do
  original_root=$profile_root
  original_preferences=$preferences
  profile_root="$fixture_home/.config/BraveSoftware/$browser"
  preferences="$profile_root/Default/Preferences"
  mkdir -p "${preferences%/*}"
  write_stale_preferences
  run_repair || fail "$browser repair command succeeds"
  assert_repaired || fail "$browser receives the shortcut repair"
  profile_root=$original_root
  preferences=$original_preferences
done
pass "all Brave Origin channels receive the Copy URL repair"
)
