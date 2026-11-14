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

# ------------------------------------------------------------ agent harnesses
# A harness is optional metadata on an ordinary manifest, so it is validated
# with the rest of the manifest: what a plugin may declare, and what the catalog
# accepts from what is already installed.
harness_home="$TMPDIR/harness-home"
harness_plugin="$harness_home/.config/omarchy/plugins/acme.integration"
mkdir -p "$harness_plugin"
cat >"$harness_plugin/manifest.json" <<'JSON'
{"schemaVersion":1,"id":"acme.integration","name":"Acme integration","version":"1.0.0","description":"Acme agent integration","kinds":[],"entryPoints":{},"agentHarness":{"id":"acme-agent","name":"Acme Agent","aliases":["acme"],"install":{"type":"mise","package":"npm:@acme/agent","command":"acme-agent"},"launch":{"mode":"browser","command":["acme-agent","open","--project","{project}"],"promptCommand":["acme-agent","open","--project","{project}","{prompt}"]}}}
JSON
harness_validate() { HOME="$harness_home" OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-plugin-validate" "$harness_plugin" 2>&1; }
harness_catalog() { HOME="$harness_home" OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-agent-catalog" "$@"; }
harness_rewrite() {
  jq "$1" "$harness_plugin/manifest.json" >"$harness_plugin/next.json"
  mv "$harness_plugin/next.json" "$harness_plugin/manifest.json"
}

harness_validate >/dev/null || fail "validate accepts a harness-only manifest"
pass "plugin validation accepts a harness-only manifest"

harness_catalog | jq -e '.[] | select(.id == "acme-agent" and .firstParty == false and .aliases == ["acme"])' >/dev/null ||
  fail "agent catalog discovers harness metadata from an installed plugin"
pass "agent catalog discovers harness metadata from an installed plugin"

mkdir -p "$harness_home/.config/omarchy/plugins/broken.integration"
printf '%s\n' '"not a manifest object"' >"$harness_home/.config/omarchy/plugins/broken.integration/manifest.json"
harness_catalog | jq -e '.[] | select(.id == "acme-agent")' >/dev/null ||
  fail "agent catalog ignores a non-object installed manifest"
pass "agent catalog ignores non-object installed manifests"

harness_rewrite '.agentHarness.install.type = "shell"'
harness_validate >/dev/null && fail "validate accepts an unsupported harness installation hook"
pass "plugins cannot declare arbitrary harness installation hooks"

harness_rewrite '.agentHarness.install.type = "mise" | .agentHarness.install.package = "--remove=node"'
harness_validate >/dev/null && fail "validate accepts mise package options"
pass "plugins cannot pass options to mise"

harness_rewrite '.agentHarness.install.type = "mise" | .agentHarness.launch.command = ["acme-agent", "{unknown}"]'
harness_validate >/dev/null && fail "validate accepts an unknown harness placeholder"
pass "plugins may use only documented harness placeholders"

harness_rewrite '.agentHarness.install = {type: "mise", package: "npm:@acme/agent", command: "acme-agent"} | .agentHarness.launch.command = ["different-agent", "{project}"] | .agentHarness.launch.promptCommand = ["different-agent", "{project}", "{prompt}"]'
harness_validate >/dev/null && fail "validate accepts a launch command other than its installed command"
pass "plugins launch the command their harness installs"

harness_rewrite '.agentHarness.install.package = "npm:@acme/agent" | .agentHarness.launch.command = ["acme-agent", "{project}"] | .agentHarness.launch.promptCommand = ["acme-agent", "{project}", "{prompt}"] | .agentHarness.aliases = ["afk"]'
harness_catalog "$harness_plugin/manifest.json" >/dev/null 2>&1 && fail "agent catalog accepts an alias that conflicts with a built-in id"
pass "agent catalog rejects harness identity collisions"

for harness_alias in 'bad..alias' $'bad\nalias'; do
  harness_rewrite ".agentHarness.aliases = [$(jq -Rn --arg alias "$harness_alias" '$alias')]"
  harness_validate >/dev/null && fail "validate accepts an invalid harness alias" "$harness_alias"
  harness_catalog | jq -e '.[] | select(.id == "acme-agent")' >/dev/null &&
    fail "agent catalog accepts an invalid harness alias" "$harness_alias"
done
pass "harness aliases use the same identity rules as ids"

harness_rewrite '.agentHarness.aliases = ["acme"]'
harness_second="$harness_home/.config/omarchy/plugins/example.integration"
mkdir -p "$harness_second"
jq '.id = "example.integration" | .agentHarness.id = "example-agent" | .agentHarness.aliases = ["acme"]' "$harness_plugin/manifest.json" >"$harness_second/manifest.json"
harness_catalog >"$TMPDIR/harness-catalog.json" 2>"$TMPDIR/harness-catalog.stderr"
jq -e '[.[] | select(.id == "acme-agent" or .id == "example-agent")] | length == 1' "$TMPDIR/harness-catalog.json" >/dev/null ||
  fail "agent catalog does not resolve an existing harness alias collision deterministically"
grep -Fq 'ignoring conflicting installed harness' "$TMPDIR/harness-catalog.stderr" ||
  fail "agent catalog does not warn about an existing harness collision"
pass "agent catalog warns while deterministically resolving existing collisions"
