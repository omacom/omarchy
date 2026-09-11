#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# A plugin folder with whatever kinds and entry points the case needs. Every
# entry point named gets a file, so a rejection is about the manifest and not a
# missing QML file.
write_plugin() {
  local name="$1" kinds="$2" entry_points="$3" bar_widget="${4:-null}"
  local dir="$TMPDIR/$name"
  local entry

  mkdir -p "$dir"
  cat >"$dir/manifest.json" <<JSON
{
  "schemaVersion": 1,
  "id": "acme.$name",
  "name": "Acme $name",
  "version": "1.0.0",
  "kinds": $kinds,
  "entryPoints": $entry_points,
  "barWidget": $bar_widget
}
JSON

  while IFS= read -r entry; do
    [[ -n $entry ]] || continue
    touch "$dir/$entry"
  done < <(jq -r '.[]' <<<"$entry_points")

  printf '%s\n' "$dir"
}

validate() {
  OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-plugin-validate" "$1" 2>&1
}

# Every kind the shell knows how to load names the entry point it loads from.
# Declaring the kind without it installs a plugin that does nothing at all.
while IFS=: read -r kind entry_point; do
  dir=$(write_plugin "wants-$kind" "[\"$kind\"]" "{\"$entry_point\": \"Entry.qml\"}")
  validate "$dir" >/dev/null || fail "validate accepts $kind with its $entry_point entry point"
  pass "validate accepts $kind with its $entry_point entry point"

  # Swap in an entry point the kind does not read, so the manifest is otherwise
  # complete and only the promised one is missing.
  other_key="service"
  [[ $entry_point == "service" ]] && other_key="panel"
  dir=$(write_plugin "missing-$kind" "[\"$kind\"]" "{\"$other_key\": \"Entry.qml\"}")
  output=$(validate "$dir") && fail "validate refuses $kind without its $entry_point entry point" "$output"
  grep -qF "kind '$kind' requires an 'entryPoints.$entry_point' to load" <<<"$output" \
    || fail "validate names the entry point $kind is missing" "$output"
  pass "validate refuses $kind without its $entry_point entry point"
done <<'KINDS'
bar:bar
bar-widget:barWidget
menu:menu
overlay:overlay
panel:panel
service:service
KINDS

# A plugin that is both a bar and a widget owes an entry point for each.
dir=$(write_plugin "both" '["bar","bar-widget"]' '{"bar": "Bar.qml", "barWidget": "Widget.qml"}')
validate "$dir" >/dev/null || fail "validate accepts a plugin that satisfies every kind it declares"
pass "validate accepts a plugin that satisfies every kind it declares"

dir=$(write_plugin "half" '["bar","bar-widget"]' '{"bar": "Bar.qml"}')
output=$(validate "$dir") && fail "validate refuses a plugin that satisfies only one of its kinds" "$output"
grep -qF "kind 'bar-widget' requires" <<<"$output" \
  || fail "validate names the unsatisfied kind" "$output"
pass "validate refuses a plugin that satisfies only one of its kinds"

# A widget can choose its default bar section, but no other section name.
for section in left center right; do
  dir=$(write_plugin "defaults-$section" '["bar-widget"]' '{"barWidget": "Widget.qml"}' "{\"defaultSection\": \"$section\"}")
  validate "$dir" >/dev/null || fail "validate accepts $section as a default bar widget section"
  pass "validate accepts $section as a default bar widget section"
done

dir=$(write_plugin "defaults-bottom" '["bar-widget"]' '{"barWidget": "Widget.qml"}' '{"defaultSection": "bottom"}')
output=$(validate "$dir") && fail "validate refuses an invalid default bar widget section" "$output"
grep -qF "'barWidget.defaultSection' must be left, center, or right" <<<"$output" \
  || fail "validate explains the default bar widget section contract" "$output"
pass "validate refuses an invalid default bar widget section"

# A kind the table does not cover is left alone rather than guessed at, so an
# unknown kind is not turned into a demand for an entry point nobody reads.
dir=$(write_plugin "unknown" '["future-thing"]' '{"service": "Entry.qml"}')
validate "$dir" >/dev/null || fail "validate leaves a kind it does not know alone"
pass "validate leaves a kind it does not know alone"

# The check reports the manifest, so a path that does not resolve still gets the
# more specific complaint it had before.
dir="$TMPDIR/ghost"
mkdir -p "$dir"
cat >"$dir/manifest.json" <<'JSON'
{
  "schemaVersion": 1,
  "id": "acme.ghost",
  "name": "Acme Ghost",
  "version": "1.0.0",
  "kinds": ["bar"],
  "entryPoints": { "bar": "Missing.qml" }
}
JSON
output=$(validate "$dir") && fail "validate refuses an entry point file that is not there" "$output"
grep -qF "entry point file not found" <<<"$output" \
  || fail "validate reports a missing file as a missing file" "$output"
pass "validate refuses an entry point file that is not there"

# Pre-remove metadata is checked by the CLI without executing trusted plugin
# code. Use a real executable whose only effect would be an external marker.
hook_dir=$(write_plugin "cleanup-hook" '["service"]' '{"service": "Service.qml"}')
mkdir -p "$hook_dir/bin"
cat >"$hook_dir/bin/cleanup" <<'HOOK'
#!/bin/bash
touch "$HOME/cleanup-ran"
HOOK
chmod +x "$hook_dir/bin/cleanup"
hook_home="$TMPDIR/hook-home"
mkdir -p "$hook_home"

set_hooks() {
  jq --argjson hooks "$1" '.hooks = $hooks' "$hook_dir/manifest.json" >"$TMPDIR/hook-manifest"
  mv "$TMPDIR/hook-manifest" "$hook_dir/manifest.json"
}

validate_hook() {
  HOME="$hook_home" validate "$hook_dir"
}

set_hooks '{"preRemove":"bin/cleanup"}'
output=$(validate_hook) || fail "validate accepts executable pre-remove hook" "$output"
[[ ! -e $hook_home/cleanup-ran ]] || fail "validate must not execute pre-remove hook"
pass "validate accepts executable pre-remove metadata without executing code"

# A caller may have dot in PATH. Validating another directory must not turn its
# jq into a host utility just because the hook checker inspects that checkout.
cat >"$hook_dir/jq" <<'HOOK'
#!/bin/bash
printf 'executed\n' >"$HOME/plugin-jq-ran"
exit 99
HOOK
chmod +x "$hook_dir/jq"
output=$(cd "$hook_home" && PATH=".:$PATH" validate_hook) \
  || fail "validate safely accepts caller PATH containing dot" "$output"
[[ ! -e $hook_home/plugin-jq-ran && ! -e $hook_home/cleanup-ran ]] \
  || fail "validate never executes plugin-owned jq or cleanup"
pass "validate does not resolve host utilities inside the plugin checkout"

set_hooks '{}'
output=$(validate_hook) || fail "validate accepts empty hook declarations" "$output"
pass "validate accepts empty hooks"

# These files really exist, so rejection must not depend on a missing file.
for suffix in $'\n' $'\t' $'\177'; do
  cp "$hook_dir/bin/cleanup" "$hook_dir/bin/cleanup$suffix"
done

while IFS= read -r hooks; do
  set_hooks "$hooks"
  output=$(validate_hook) && fail "validate rejects invalid hook declaration: $hooks" "$output"
  [[ ! -e $hook_home/cleanup-ran ]] || fail "invalid hook validation must not execute code"
done <<'JSON'
null
[]
"bin/cleanup"
{"preRemove":null}
{"preRemove":7}
{"preRemove":false}
{"preRemove":[]}
{"preRemove":{}}
{"preRemove":""}
{"preRemove":"/bin/true"}
{"preRemove":"../bin/cleanup"}
{"preRemove":"bin/../bin/cleanup"}
{"preRemove":"bin/clean\u0000up"}
{"preRemove":"bin/cleanup\n"}
{"preRemove":"bin/cleanup\t"}
{"preRemove":"bin/cleanup\u007f"}
JSON
pass "validate rejects invalid hook types, traversal, absolute paths, NUL, and control characters"

set_hooks '{"preRemove":"bin/missing"}'
output=$(validate_hook) && fail "validate rejects missing hook executable" "$output"
set_hooks '{"preRemove":"bin/cleanup"}'
chmod -x "$hook_dir/bin/cleanup"
output=$(validate_hook) && fail "validate rejects nonexecutable hook" "$output"
chmod +x "$hook_dir/bin/cleanup"
pass "validate rejects hooks that are missing or nonexecutable"

mv "$hook_dir/bin/cleanup" "$TMPDIR/outside-cleanup"
ln -s "$TMPDIR/outside-cleanup" "$hook_dir/bin/cleanup"
output=$(validate_hook) && fail "validate rejects symlink hook executable" "$output"
rm "$hook_dir/bin/cleanup"
mv "$TMPDIR/outside-cleanup" "$hook_dir/bin/cleanup"
mv "$hook_dir/bin" "$TMPDIR/outside-bin"
ln -s "$TMPDIR/outside-bin" "$hook_dir/bin"
output=$(validate_hook) && fail "validate rejects symlink parent escape" "$output"
[[ ! -e $hook_home/cleanup-ran ]] || fail "filesystem hook validation must not execute code"
pass "validate rejects symlink executables and symlink parent escapes without executing code"
