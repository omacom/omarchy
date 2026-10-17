#!/bin/bash

set -e

source "$(dirname "$0")/base-test.sh"

run_node_test "dropbox model helpers" <<'JS'
const dropbox = requireFromRoot('shell/plugins/panels/dropbox/Model.js')

assertEqual(dropbox.fileKind('photo.JPG'), 'image', 'dropbox detects image files')
assertEqual(dropbox.fileKind('clip.webm'), 'video', 'dropbox detects video files')
assertEqual(dropbox.fileKind('report.pdf'), 'document', 'dropbox detects document files')
assertEqual(dropbox.fileKind('archive.zip'), 'misc', 'dropbox falls back to misc files')
assertEqual(dropbox.formatBytes(1530), '1.53 KB', 'dropbox formats small byte counts')
assertEqual(dropbox.formatBytes(2_000_000_000), '2 GB', 'dropbox formats gigabytes')
assertEqual(dropbox.formatPercent(7.25), '7.3%', 'dropbox formats small percentages')
assertEqual(dropbox.usageText(1000, 2000, true), '1 KB of 2 KB', 'dropbox formats known quota usage')
assertEqual(dropbox.usageText(1000, 0, false), '1 KB', 'dropbox formats unknown quota usage')

const parsed = dropbox.parseStatus(JSON.stringify({
  installed: true,
  running: true,
  authenticated: true,
  files: [{ name: 'x.txt' }]
}))
assert(parsed.installed && parsed.running && parsed.authenticated, 'dropbox parses status booleans')
assertEqual(parsed.files.length, 1, 'dropbox preserves file rows')

assertEqual(
  dropbox.fileMeta({ modifiedTs: 1000, folder: 'Docs' }, 1000 * 1000 + 3600 * 1000),
  '1h ago · Docs',
  'dropbox file metadata includes relative time and folder'
)
JS

require_command jq
require_command python3

QUOTA_HOME=$(mktemp -d)
trap 'rm -rf "$QUOTA_HOME"' EXIT

quota_dropbox_dir="$QUOTA_HOME/Dropbox"
mkdir -p "$quota_dropbox_dir" "$QUOTA_HOME/.dropbox"
printf 'hello' >"$quota_dropbox_dir/notes.txt"

# Dropbox reports "Pro" for any paid personal plan, so the plan table guesses
# 3 TB whether the account is 2 TB or 3 TB.
cat >"$QUOTA_HOME/.dropbox/info.json" <<JSON
{"personal": {"path": "$quota_dropbox_dir", "host": 1, "is_team": false, "subscription_type": "Pro"}}
JSON

guessed=$(HOME="$QUOTA_HOME" python3 "$ROOT/shell/plugins/panels/dropbox/status.py" 5)

[[ $(jq -r '.quotaBytes' <<<"$guessed") == "3000000000000" ]] ||
  fail "dropbox falls back to the plan quota" "$guessed"
pass "dropbox falls back to the plan quota"

overridden=$(HOME="$QUOTA_HOME" python3 "$ROOT/shell/plugins/panels/dropbox/status.py" 5 2000000000000)

[[ $(jq -r '.quotaBytes' <<<"$overridden") == "2000000000000" ]] ||
  fail "dropbox prefers an explicit quota override" "$overridden"
pass "dropbox prefers an explicit quota override"

[[ $(jq -r '.quotaKnown' <<<"$overridden") == "true" ]] ||
  fail "dropbox reports an overridden quota as known" "$overridden"
pass "dropbox reports an overridden quota as known"

ignored=$(HOME="$QUOTA_HOME" python3 "$ROOT/shell/plugins/panels/dropbox/status.py" 5 0)

[[ $(jq -r '.quotaBytes' <<<"$ignored") == "3000000000000" ]] ||
  fail "dropbox treats a zero override as unset" "$ignored"
pass "dropbox treats a zero override as unset"
