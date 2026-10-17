#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

home="$TMPDIR/home"
stubs="$TMPDIR/stubs"
log="$TMPDIR/events"
mkdir -p "$home/.config/omarchy/hooks/plugin-added.d" \
  "$home/.config/omarchy/hooks/plugin-removed.d" "$stubs"

# The hooks record their arguments and the on-disk state they observe. The event
# must fire at the filesystem transition, so the add hook sees the clone present
# and the remove hook sees the plugin gone.
cat >"$home/.config/omarchy/hooks/plugin-added.d/record" <<'SH'
#!/bin/bash
printf 'hook plugin-added id=%s url=%s present=%s\n' "$1" "$2" \
  "$([[ -e $HOME/.config/omarchy/plugins/$1 ]] && echo yes || echo no)" >>"$EVENT_LOG"
SH
cat >"$home/.config/omarchy/hooks/plugin-removed.d/record" <<'SH'
#!/bin/bash
printf 'hook plugin-removed id=%s present=%s\n' "$1" \
  "$([[ -e $HOME/.config/omarchy/plugins/$1 ]] && echo yes || echo no)" >>"$EVENT_LOG"
SH
chmod +x "$home/.config/omarchy/hooks/plugin-added.d/record" \
  "$home/.config/omarchy/hooks/plugin-removed.d/record"

# Model the real omarchy-shell contract: -q is best-effort success even when no
# shell answers. Non-quiet calls fail when the shell is down, and a rescan can
# fail after the plugin list already answered when the shell dies mid-command.
cat >"$stubs/omarchy-shell" <<'SH'
#!/bin/bash
printf 'shell %s\n' "$*" >>"$EVENT_LOG"
quiet=0
if [[ ${1:-} == -q ]]; then
  quiet=1
  shift
fi
if (( quiet )); then
  exit 0
fi
if [[ ${FAKE_NO_SHELL:-0} == 1 ]]; then
  echo "omarchy-shell is not running" >&2
  exit 1
fi
if [[ ${FAKE_RESCAN_DOWN:-0} == 1 && "${1:-} ${2:-}" == "shell rescanPlugins" ]]; then
  echo "omarchy-shell is not running" >&2
  exit 1
fi
if [[ "${1:-} ${2:-}" == "shell listPlugins" ]]; then
  printf '[]\n'
fi
exit 0
SH
chmod +x "$stubs/omarchy-shell"

cat >"$stubs/omarchy-plugin-list" <<'SH'
#!/bin/bash
printf 'plugin-list %s\n' "$*" >>"$EVENT_LOG"
find "$HOME/.config/omarchy/plugins" -mindepth 2 -maxdepth 2 -name manifest.json -print0 |
  xargs -0 -r jq -s 'map({id: .id, enabled: true})'
SH
chmod +x "$stubs/omarchy-plugin-list"

cat >"$stubs/omarchy-plugin-enable" <<'SH'
#!/bin/bash
printf 'enable %s\n' "$*" >>"$EVENT_LOG"
SH
chmod +x "$stubs/omarchy-plugin-enable"

write_plugin() {
  local dir="$1"
  local id="$2"

  mkdir -p "$dir"
  cat >"$dir/manifest.json" <<JSON
{
  "schemaVersion": 1,
  "id": "$id",
  "name": "Demo",
  "version": "1.0.0",
  "kinds": ["bar-widget"],
  "entryPoints": { "barWidget": "Widget.qml" },
  "barWidget": {
    "displayName": "Demo",
    "category": "Test",
    "allowMultiple": false
  }
}
JSON
  printf 'import QtQuick\nItem {}\n' >"$dir/Widget.qml"
}

make_repo() {
  local dir="$1"
  local id="$2"

  write_plugin "$dir" "$id"
  git -C "$dir" init -q
  git -C "$dir" add .
  git -C "$dir" -c user.name=Test -c user.email=test@example.com commit -qm Initial
}

log_line() {
  grep -nF "$1" "$log" | head -n1 | cut -d: -f1 || true
}

# --- add fires plugin-added at the filesystem transition ----------------------

repo="$TMPDIR/incoming-demo"
make_repo "$repo" "acme.demo"

: >"$log"
output=$(HOME="$home" OMARCHY_PATH="$ROOT" EVENT_LOG="$log" PATH="$stubs:$ROOT/bin:$PATH" \
  omarchy-plugin-add "$repo" --yes 2>&1) ||
  fail "plugin add succeeds" "$output"
grep -qF "hook plugin-added id=acme.demo url=$repo present=yes" "$log" ||
  fail "plugin add fires plugin-added with the id, URL, and the installed clone" "$(cat "$log")"
pass "plugin add fires plugin-added once the clone is in place"

hook_line=$(log_line 'hook plugin-added')
rescan_line=$(log_line 'shell -q shell rescanPlugins')
[[ -n $hook_line && -n $rescan_line && $hook_line -lt $rescan_line ]] ||
  fail "plugin-added fires before the shell rescan" "$(cat "$log")"
pass "plugin-added fires before the shell rescan"

# --- add fires no event when it fails ----------------------------------------

: >"$log"
output=$(HOME="$home" OMARCHY_PATH="$ROOT" EVENT_LOG="$log" PATH="$stubs:$ROOT/bin:$PATH" \
  omarchy-plugin-add "$repo" --yes 2>&1) &&
  fail "plugin add refuses an already installed plugin id" "$output"
grep -qF "already used by" <<<"$output" ||
  fail "plugin add explains the duplicate install" "$output"
! grep -qF 'hook plugin-added' "$log" ||
  fail "plugin add fires plugin-added when the add fails" "$(cat "$log")"
pass "plugin add fires no plugin-added when the add fails"

# --- plugin-added fires before the optional enable ---------------------------

repo2="$TMPDIR/incoming-enabled"
make_repo "$repo2" "acme.enabled"

: >"$log"
output=$(HOME="$home" OMARCHY_PATH="$ROOT" EVENT_LOG="$log" PATH="$stubs:$ROOT/bin:$PATH" \
  omarchy-plugin-add "$repo2" --enable --yes 2>&1) ||
  fail "plugin add --enable succeeds" "$output"
grep -qF 'enable acme.enabled' "$log" ||
  fail "plugin add --enable still enables the plugin" "$(cat "$log")"
hook_line=$(log_line 'hook plugin-added id=acme.enabled')
rescan_line=$(log_line 'shell -q shell rescanPlugins')
enable_line=$(log_line 'enable acme.enabled')
[[ -n $hook_line && -n $rescan_line && -n $enable_line && $hook_line -lt $rescan_line && $rescan_line -lt $enable_line ]] ||
  fail "plugin-added fires before the rescan and the enable" "$(cat "$log")"
pass "plugin-added fires before the rescan and the optional enable"

# --- remove fires plugin-removed at the filesystem transition ----------------

mkdir -p "$home/.config/omarchy/plugins/acme.gone"
printf '{"id":"acme.gone"}\n' >"$home/.config/omarchy/plugins/acme.gone/manifest.json"

: >"$log"
output=$(HOME="$home" OMARCHY_PATH="$ROOT" EVENT_LOG="$log" PATH="$stubs:$ROOT/bin:$PATH" \
  omarchy-plugin-remove acme.gone --yes 2>&1) ||
  fail "plugin remove succeeds" "$output"
grep -qF 'hook plugin-removed id=acme.gone present=no' "$log" ||
  fail "plugin remove fires plugin-removed with the id and the plugin gone" "$(cat "$log")"
[[ ! -e $home/.config/omarchy/plugins/acme.gone ]] ||
  fail "plugin remove leaves the plugin directory behind"
pass "plugin remove fires plugin-removed once the plugin is gone"

hook_line=$(log_line 'hook plugin-removed')
rescan_line=$(log_line 'shell -q shell rescanPlugins')
[[ -n $hook_line && -n $rescan_line && $hook_line -lt $rescan_line ]] ||
  fail "plugin-removed fires before the shell rescan" "$(cat "$log")"
pass "plugin-removed fires before the shell rescan"

# --- remove fires no event when it fails -------------------------------------

: >"$log"
output=$(HOME="$home" OMARCHY_PATH="$ROOT" EVENT_LOG="$log" PATH="$stubs:$ROOT/bin:$PATH" \
  omarchy-plugin-remove acme.missing --yes 2>&1) &&
  fail "plugin remove refuses a plugin that is not installed" "$output"
grep -qF "is not installed" <<<"$output" ||
  fail "plugin remove explains the missing plugin" "$output"
! grep -qF 'hook plugin-removed' "$log" ||
  fail "plugin remove fires plugin-removed when the remove fails" "$(cat "$log")"
pass "plugin remove fires no plugin-removed when the remove fails"

# --- the rescan is best-effort so the transition is never reported as failed --

repo3="$TMPDIR/incoming-headless"
make_repo "$repo3" "acme.headless"

: >"$log"
output=$(HOME="$home" OMARCHY_PATH="$ROOT" EVENT_LOG="$log" FAKE_NO_SHELL=1 \
  PATH="$stubs:$ROOT/bin:$PATH" omarchy-plugin-add "$repo3" --yes 2>&1) ||
  fail "plugin add succeeds with no running shell" "$output"
grep -qF 'shell -q shell rescanPlugins' "$log" ||
  fail "plugin add still asks for a best-effort rescan" "$(cat "$log")"
grep -qF 'hook plugin-added id=acme.headless' "$log" ||
  fail "plugin add records the plugin with no running shell" "$(cat "$log")"
pass "plugin add records the plugin and succeeds with no running shell"

mkdir -p "$home/.config/omarchy/plugins/acme.race"
printf '{"id":"acme.race"}\n' >"$home/.config/omarchy/plugins/acme.race/manifest.json"

: >"$log"
output=$(HOME="$home" OMARCHY_PATH="$ROOT" EVENT_LOG="$log" FAKE_RESCAN_DOWN=1 \
  PATH="$stubs:$ROOT/bin:$PATH" omarchy-plugin-remove acme.race --yes 2>&1) ||
  fail "plugin remove survives a shell that dies before the rescan" "$output"
grep -qF 'shell -q shell rescanPlugins' "$log" ||
  fail "plugin remove still asks for a best-effort rescan" "$(cat "$log")"
grep -qF 'hook plugin-removed id=acme.race' "$log" ||
  fail "plugin remove records the removal when the shell dies before the rescan" "$(cat "$log")"
[[ ! -e $home/.config/omarchy/plugins/acme.race ]] ||
  fail "plugin remove leaves the plugin behind when the rescan fails"
pass "plugin remove records the removal and succeeds when the shell dies before the rescan"
