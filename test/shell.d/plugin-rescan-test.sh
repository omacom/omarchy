#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command git
require_command jq

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

git_quiet() {
  git -c user.name=Test -c user.email=test@example.com -c init.defaultBranch=main "$@"
}

write_plugin() {
  local dir="$1"
  local id="$2"
  local name="$3"

  mkdir -p "$dir"
  cat >"$dir/manifest.json" <<JSON
{
  "schemaVersion": 1,
  "id": "$id",
  "name": "$name",
  "version": "1.0.0",
  "kinds": ["bar-widget"],
  "entryPoints": { "barWidget": "Widget.qml" },
  "barWidget": {
    "displayName": "$name",
    "category": "Test",
    "allowMultiple": false
  }
}
JSON
  printf 'import QtQuick\nItem {}\n' >"$dir/Widget.qml"
}

# A shell that answers everything except rescanPlugins, which fails the way a
# real one does when the reload outruns the 2s IPC timeout: a message on stderr
# and exit 1, unless -q asks for best effort. The plugin commands must survive
# that, because they run under `set -e` and the rescan is the last thing they
# need from the shell, not something their own work depends on.
stub_dir="$TMPDIR/stubs"
mkdir -p "$stub_dir"
cat >"$stub_dir/omarchy-shell" <<'STUB'
#!/bin/bash

quiet=0
if [[ ${1:-} == "-q" ]]; then
  quiet=1
  shift
fi

if [[ ${2:-} == "rescanPlugins" ]]; then
  printf 'rescanPlugins\n' >>"$RESCAN_LOG"
  if (( quiet )); then
    exit 0
  fi
  echo "omarchy-shell is not responding" >&2
  exit 1
fi

if [[ ${2:-} == "listPlugins" ]]; then
  if [[ -n ${STUB_PLUGINS:-} ]]; then
    printf '%s\n' "$STUB_PLUGINS"
  else
    find "$HOME/.config/omarchy/plugins" -mindepth 2 -maxdepth 2 -name manifest.json -print0 |
      xargs -0 -r jq -s 'map({id: .id, enabled: true})'
  fi
fi

if [[ ${2:-} == "listShellConfig" ]]; then
  printf '%s\n' "${STUB_SHELL_CONFIG:-\{\}}"
fi

exit 0
STUB
chmod +x "$stub_dir/omarchy-shell"

export RESCAN_LOG="$TMPDIR/rescans"
: >"$RESCAN_LOG"

run_plugin_cmd() {
  local home="$1"
  shift

  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" "$@"
}

# --- update ---------------------------------------------------------------
#
# The rescan is the very last statement, so a failure there can only change the
# exit code, never the outcome: every plugin is already fast forwarded when it
# runs. Reporting failure for work that succeeded is what breaks callers, and
# #10021 and #10326 both want to run this from `omarchy update`.

update_home="$TMPDIR/update-home"
mkdir -p "$update_home/.config/omarchy/plugins"

origin="$TMPDIR/origin"
write_plugin "$origin" "acme.updatable" "Updatable"
git_quiet -C "$origin" init -q
git_quiet -C "$origin" add .
git_quiet -C "$origin" commit -qm "Initial"

installed="$update_home/.config/omarchy/plugins/acme.updatable"
git_quiet clone -q "$origin" "$installed"

printf 'import QtQuick\nItem { objectName: "second" }\n' >"$origin/Widget.qml"
git_quiet -C "$origin" add .
git_quiet -C "$origin" commit -qm "Second"
want=$(git -C "$origin" rev-parse HEAD)

output=$(run_plugin_cmd "$update_home" omarchy-plugin-update --yes 2>&1) ||
  fail "plugin update survives a rescan that times out" "$output"
grep -qF "Updated acme.updatable." <<<"$output" ||
  fail "plugin update reports the update it performed" "$output"
[[ $(git -C "$installed" rev-parse HEAD) == "$want" ]] ||
  fail "plugin update fast forwards the checkout" "$output"
pass "plugin update exits 0 when the closing rescan times out"

grep -qF "is not responding" <<<"$output" &&
  fail "plugin update leaks the best-effort rescan failure to the user" "$output"
pass "plugin update stays quiet about the best-effort rescan"

# --- remove ---------------------------------------------------------------

remove_home="$TMPDIR/remove-home"
mkdir -p "$remove_home/.config/omarchy/plugins"
write_plugin "$remove_home/.config/omarchy/plugins/acme.removable" "acme.removable" "Removable"

output=$(STUB_PLUGINS='[]' run_plugin_cmd "$remove_home" \
  omarchy-plugin-remove acme.removable --yes 2>&1) ||
  fail "plugin remove survives a rescan that times out" "$output"
[[ ! -e $remove_home/.config/omarchy/plugins/acme.removable ]] ||
  fail "plugin remove deletes the plugin directory" "$output"
pass "plugin remove exits 0 when the closing rescan times out"

# --- add ------------------------------------------------------------------
#
# Here the rescan is not the last statement. An abort there skips the enable
# decision that follows it, which is how a plugin ends up installed but
# disabled with no word about how to enable it.

add_home="$TMPDIR/add-home"
mkdir -p "$add_home/.config/omarchy/plugins"

source_repo="$TMPDIR/source-repo"
write_plugin "$source_repo" "acme.addable" "Addable"
git_quiet -C "$source_repo" init -q
git_quiet -C "$source_repo" add .
git_quiet -C "$source_repo" commit -qm "Initial"

output=$(run_plugin_cmd "$add_home" omarchy-plugin-add "$source_repo" --yes 2>&1) ||
  fail "plugin add survives a rescan that times out" "$output"
[[ -f $add_home/.config/omarchy/plugins/acme.addable/manifest.json ]] ||
  fail "plugin add installs the plugin" "$output"
grep -qF "omarchy plugin enable acme.addable" <<<"$output" ||
  fail "plugin add still reaches the enable decision after the rescan" "$output"
pass "plugin add reaches the enable decision when the rescan times out"

# --- clone ----------------------------------------------------------------
#
# Same shape as add: the clone is on disk when the rescan runs, but discovery,
# enable and the closing message all come after it.

clone_home="$TMPDIR/clone-home"
mkdir -p "$clone_home/.config/omarchy" "$TMPDIR/clone-stubs"
cp "$stub_dir/omarchy-shell" "$TMPDIR/clone-stubs/omarchy-shell"
for command in omarchy-plugin-enable omarchy-notification-send; do
  printf '#!/bin/bash\nexit 0\n' >"$TMPDIR/clone-stubs/$command"
done
chmod +x "$TMPDIR/clone-stubs/"*

output=$(HOME="$clone_home" USER=tester OMARCHY_PATH="$ROOT" \
  PATH="$TMPDIR/clone-stubs:$ROOT/bin:$PATH" \
  STUB_SHELL_CONFIG='{"bar":{"layout":{"left":[{"id":"omarchy.clock"}],"center":[],"right":[]}}}' \
  omarchy-plugin-clone omarchy.clock 2>&1) ||
  fail "plugin clone survives a rescan that times out" "$output"
[[ -f $clone_home/.config/omarchy/plugins/tester.clock/manifest.json ]] ||
  fail "plugin clone writes the clone" "$output"
grep -qF "switched to tester.clock" <<<"$output" ||
  fail "plugin clone reaches its closing message after the rescan" "$output"
pass "plugin clone completes when the rescan times out"

# --- the rescan is still attempted ----------------------------------------
#
# Best effort must not become no effort: -q swallows the failure, it does not
# skip the call.

(( $(grep -c 'rescanPlugins' "$RESCAN_LOG") == 4 )) ||
  fail "each command still asks the shell to rescan" "$(cat "$RESCAN_LOG")"
pass "update, remove, add and clone all still request a rescan"
