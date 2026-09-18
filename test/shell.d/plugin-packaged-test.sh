#!/bin/bash

# Plugins pacman installs under /usr/share/omarchy/plugins (the atreyu package)
# sit between the bundled tree and ~/.config/omarchy/plugins: the catalog lists
# them as packaged, a bundled copy shadows them, they shadow a user copy, and
# the commands that pull or delete a checkout refuse them by naming the package.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

system_dir="$TMPDIR/system"
home="$TMPDIR/home"
user_dir="$home/.config/omarchy/plugins"
stub_dir="$TMPDIR/bin"
mkdir -p "$stub_dir"
export FAKE_CALLS="$TMPDIR/calls"

write_plugin() {
  local dir="$1" id="$2" kind="$3" entry="$4"
  mkdir -p "$dir"
  jq -n --arg id "$id" --arg kind "$kind" --arg entry "$entry" '{
    schemaVersion: 1, id: $id, name: $id, version: "1.0.0", kinds: [$kind],
    entryPoints: (if $kind == "bar-widget" then {barWidget: $entry} else {panel: $entry} end),
    barWidget: (if $kind == "bar-widget" then {displayName: $id, category: "Test", allowMultiple: false, defaultSection: "right"} else null end)
  } | with_entries(select(.value != null))' >"$dir/manifest.json"
  printf 'import QtQuick\nItem {}\n' >"$dir/$entry"
}

write_plugin "$system_dir/omarchy.packaged" omarchy.packaged bar-widget Widget.qml
write_plugin "$system_dir/vendor.packaged" vendor.packaged panel Panel.qml
write_plugin "$system_dir/omarchy.clock" omarchy.clock bar-widget Widget.qml
write_plugin "$system_dir/.staging" hidden.staging panel Panel.qml
write_plugin "$user_dir/vendor.packaged" vendor.packaged panel Panel.qml
write_plugin "$user_dir/acme.user" acme.user bar-widget Widget.qml

# pacman answers ownership for the packaged root only; PACMAN_UNOWNED makes it
# disown everything, the way a hand-copied tree would look.
cat >"$stub_dir/pacman" <<'SH'
#!/bin/bash
[[ $1 == "-Qqo" && ${PACMAN_UNOWNED:-0} == 0 && $2 == "$FAKE_SYSTEM_DIR"/* ]] || exit 1
echo atreyu
SH
cat >"$stub_dir/omarchy-shell" <<'SH'
#!/bin/bash
printf 'omarchy-shell %s\n' "$*" >>"$FAKE_CALLS"
if [[ $* == *listPlugins* ]]; then
  printf '%s\n' "${FAKE_PLUGINS:-[]}"
else
  echo ok
fi
SH
chmod +x "$stub_dir"/*

run() {
  HOME="$home" OMARCHY_PATH="$ROOT" OMARCHY_SYSTEM_PLUGINS_DIR="$system_dir" FAKE_SYSTEM_DIR="$system_dir" \
    PATH="$stub_dir:$ROOT/bin:$PATH" "$@"
}

# ---------------------------------------------------------------- catalog
catalog=$(run omarchy-plugin-catalog)

jq -e --arg dir "$system_dir" '
  map(select(.id == "omarchy.packaged"))[0]
  | .system == true and .firstParty == true
    and .sourceDir == $dir + "/omarchy.packaged"
    and .barWidgetPath == $dir + "/omarchy.packaged/Widget.qml"
' <<<"$catalog" >/dev/null || fail "catalog lists a packaged omarchy plugin as packaged and first-party" "$catalog"
pass "catalog lists a packaged omarchy plugin as packaged and first-party"

jq -e --arg dir "$system_dir" '
  map(select(.id == "vendor.packaged")) | length == 1 and
  (.[0] | .system == true and .firstParty == false and .sourceDir == $dir + "/vendor.packaged")
' <<<"$catalog" >/dev/null || fail "a packaged plugin shadows a user plugin with the same id" "$catalog"
pass "a packaged plugin shadows a user plugin with the same id"

jq -e --arg root "$ROOT" '
  map(select(.id == "omarchy.clock")) | length == 1 and
  (.[0] | .system == false and (.sourceDir | startswith($root + "/shell/plugins/")))
' <<<"$catalog" >/dev/null || fail "a bundled plugin shadows a packaged plugin with the same id" "$catalog"
pass "a bundled plugin shadows a packaged plugin with the same id"

jq -e '
  (map(.id) | index("hidden.staging")) == null and
  (map(select(.id == "acme.user"))[0] | .system == false and .firstParty == false)
' <<<"$catalog" >/dev/null || fail "catalog skips hidden packaged dirs and keeps user plugins unpackaged" "$catalog"
pass "catalog skips hidden packaged dirs and keeps user plugins unpackaged"

absent=$(run env OMARCHY_SYSTEM_PLUGINS_DIR="$TMPDIR/no-such-root" omarchy-plugin-catalog)
jq -e 'all(.[]; .system == false) and (map(.id) | index("omarchy.clock") != null)' <<<"$absent" >/dev/null ||
  fail "catalog works without a packaged root" "$absent"
pass "catalog works without a packaged root"

# ----------------------------------------------------------------- remove
: >"$FAKE_CALLS"
output=$(run omarchy-plugin-remove omarchy.packaged --yes 2>&1) &&
  fail "plugin remove refuses a packaged plugin" "$output"
grep -qF "plugin 'omarchy.packaged' is installed by the atreyu package; remove it with: sudo pacman -Rns atreyu" <<<"$output" ||
  fail "plugin remove names the package and the pacman command" "$output"
[[ -f $system_dir/omarchy.packaged/manifest.json && ! -s $FAKE_CALLS ]] ||
  fail "plugin remove leaves a packaged plugin and the shell alone" "$output"
pass "plugin remove refuses a packaged plugin and names its package"

output=$(run env PACMAN_UNOWNED=1 omarchy-plugin-remove omarchy.packaged --yes 2>&1) &&
  fail "plugin remove refuses a packaged plugin pacman does not own" "$output"
grep -qF "is installed system-wide in $system_dir/omarchy.packaged and is managed by pacman" <<<"$output" ||
  fail "plugin remove explains an unowned packaged plugin" "$output"
pass "plugin remove explains a packaged plugin no package claims"

output=$(run omarchy-plugin-remove nothing.here --yes 2>&1) &&
  fail "plugin remove still rejects an unknown id" "$output"
grep -qF "plugin 'nothing.here' is not installed" <<<"$output" ||
  fail "plugin remove still says an unknown id is not installed" "$output"
pass "plugin remove still says an unknown id is not installed"

# The user's copy is the one this command manages, even under a packaged id.
output=$(run omarchy-plugin-remove vendor.packaged --yes 2>&1) ||
  fail "plugin remove removes the user copy of a shadowed plugin" "$output"
[[ ! -e $user_dir/vendor.packaged && -f $system_dir/vendor.packaged/manifest.json ]] ||
  fail "plugin remove takes out the user copy and not the packaged one" "$output"
pass "plugin remove takes out the user copy and leaves the packaged one"

# ----------------------------------------------------------------- update
output=$(run omarchy-plugin-update omarchy.packaged --yes 2>&1) &&
  fail "plugin update refuses a packaged plugin" "$output"
grep -qF "plugin 'omarchy.packaged' is installed by the atreyu package and is updated by omarchy update" <<<"$output" ||
  fail "plugin update points at omarchy update" "$output"
pass "plugin update refuses a packaged plugin and points at omarchy update"

output=$(run omarchy-plugin-update --yes 2>&1) || fail "plugin update passes over packaged plugins" "$output"
[[ $output == "No git-managed plugins installed." ]] ||
  fail "plugin update passes over packaged plugins" "$output"
pass "plugin update passes over packaged plugins"

# ------------------------------------------------------------------- list
FAKE_PLUGINS='[
  {"id": "omarchy.atreyu", "name": "Atreyu", "kinds": ["bar-widget", "overlay"], "enabled": true, "active": false, "canDisable": true, "firstParty": true, "system": true, "clonedFrom": ""},
  {"id": "omarchy.clock", "name": "Clock", "kinds": ["bar-widget"], "enabled": true, "active": false, "canDisable": true, "firstParty": true, "system": false, "clonedFrom": ""},
  {"id": "acme.user", "name": "User", "kinds": ["bar-widget"], "enabled": false, "active": false, "canDisable": true, "firstParty": false, "system": false, "clonedFrom": ""}
]'
listing=$(FAKE_PLUGINS="$FAKE_PLUGINS" run omarchy-plugin-list)
grep -qE '^omarchy\.atreyu +enabled +packaged ' <<<"$listing" &&
  grep -qE '^omarchy\.clock +enabled +first-party ' <<<"$listing" &&
  grep -qE '^acme\.user +disabled +third-party ' <<<"$listing" ||
  fail "plugin list shows packaged plugins as packaged" "$listing"
pass "plugin list shows packaged plugins as packaged"
