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
for section in left centerBegin center centerEnd tray right; do
  dir=$(write_plugin "defaults-$section" '["bar-widget"]' '{"barWidget": "Widget.qml"}' "{\"defaultSection\": \"$section\"}")
  validate "$dir" >/dev/null || fail "validate accepts $section as a default bar widget section"
  pass "validate accepts $section as a default bar widget section"
done

dir=$(write_plugin "defaults-bottom" '["bar-widget"]' '{"barWidget": "Widget.qml"}' '{"defaultSection": "bottom"}')
output=$(validate "$dir") && fail "validate refuses an invalid default bar widget section" "$output"
grep -qF "'barWidget.defaultSection' must be left, centerBegin, center, centerEnd, tray, or right" <<<"$output" \
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

# Validate the effective plugin on disk before fast-forwarding.
fixture=$(mktemp -d "$TMPDIR/update.XXXXXX")
upstream="$fixture/upstream"
test_home="$fixture/home"
installed="$test_home/.config/omarchy/plugins/acme.widget"
mkdir -p "$upstream" "$(dirname "$installed")" "$fixture/bin"

cat >"$fixture/bin/omarchy-shell" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$fixture/bin/omarchy-shell"

commit() {
  git -C "$upstream" add .
  git -C "$upstream" -c user.name=Test -c user.email=test@example.invalid commit -qm "$1"
}

manifest='{"schemaVersion":1,"id":"acme.widget","name":"Test widget","version":"1","kinds":["bar-widget"],"entryPoints":{"barWidget":"Widget.qml"}}'
git -C "$upstream" init -q
printf '%s\n' "$manifest" >"$upstream/manifest.json"
printf 'Item {}\n' >"$upstream/Widget.qml"
printf 'Item {}\n' >"$upstream/Custom.qml"
printf 'original\n' >"$upstream/notes"
commit initial
git clone -q "$upstream" "$installed"
base=$(git -C "$installed" rev-parse HEAD)
printf 'staged\n' >"$installed/notes"
git -C "$installed" add notes
printf 'unstaged\n' >"$installed/notes"

run_update() {
  HOME="$test_home" PATH="$fixture/bin:$ROOT/bin:$PATH" omarchy-plugin-update acme.widget --yes
}

printf 'broken manifest\n' >"$upstream/manifest.json"
commit invalid
if run_update >"$fixture/invalid.log" 2>&1; then
  fail "plugin update refuses an invalid upstream manifest"
fi
[[ $(git -C "$installed" rev-parse HEAD) == "$base" ]] ||
  fail "an invalid plugin update leaves the installed revision unchanged"
[[ $(git -C "$installed" show :notes) == staged && $(<"$installed/notes") == unstaged ]] ||
  fail "an invalid plugin update preserves staged and unstaged edits"
pass "an invalid plugin update preserves both the working tree and staging area"


# Upstream's own manifest remains valid, but the local manifest needs the
# file that the update deletes. The failed update must leave both copies.
jq '.entryPoints.barWidget = "Custom.qml"' <<<"$manifest" >"$installed/manifest.json"
git -C "$installed" add manifest.json
printf '%s\n' "$manifest" >"$upstream/manifest.json"
rm "$upstream/Custom.qml"
commit removes-custom
if run_update >"$fixture/retained.log" 2>&1; then
  fail "plugin update refuses to remove an entry point used by a retained manifest"
fi
grep -qF "entry point file not found: 'Custom.qml'" "$fixture/retained.log" ||
  fail "the update validates the retained manifest" "$(cat "$fixture/retained.log")"
[[ $(git -C "$installed" rev-parse HEAD) == "$base" && -f $installed/Custom.qml ]] ||
  fail "the rejected update leaves the installed revision and its entry point"
[[ $(git -C "$installed" show :manifest.json) == "$(<"$installed/manifest.json")" ]] ||
  fail "the rejected update keeps the staged manifest"
[[ $(git -C "$installed" show :notes) == staged && $(<"$installed/notes") == unstaged ]] ||
  fail "the rejected update keeps staged and unstaged notes"
pass "an update validates the retained local manifest before removing a file"

printf 'Item {}\n' >"$upstream/Custom.qml"
printf 'Item { visible: false }\n' >"$upstream/Widget.qml"
commit valid
run_update >"$fixture/valid.log" 2>&1 || fail "plugin update accepts a valid fast-forward" "$(cat "$fixture/valid.log")"
[[ $(git -C "$installed" rev-parse HEAD) == "$(git -C "$upstream" rev-parse HEAD)" ]] ||
  fail "the valid revision reaches the installed plugin"
[[ $(git -C "$installed" show :notes) == staged && $(<"$installed/notes") == unstaged ]] ||
  fail "a valid plugin update preserves unrelated edits"
[[ $(git -C "$installed" worktree list --porcelain | grep -c '^worktree ') == 1 ]] ||
  fail "the plugin updater cleans up its temporary checkouts"
pass "a valid plugin update fast-forwards and preserves unrelated edits"
