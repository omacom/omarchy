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

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

dropbox_dir="$TEST_HOME/Dropbox"
mkdir -p "$dropbox_dir/Documents" "$dropbox_dir/.dropbox.cache/new_files" "$TEST_HOME/.dropbox"
cat >"$TEST_HOME/.dropbox/info.json" <<JSON
{"personal": {"path": "$dropbox_dir", "host": 1, "is_team": false, "subscription_type": "Basic"}}
JSON

# A real file, and the staging copy Dropbox writes while syncing it. The cache
# entry is larger and newer, so an unfiltered scan would report it first.
printf 'hello' >"$dropbox_dir/Documents/notes.txt"
head -c 4096 /dev/zero >"$dropbox_dir/.dropbox.cache/new_files/abc123"
printf 'metadata' >"$dropbox_dir/.dropbox"
touch -d '2020-01-01' "$dropbox_dir/Documents/notes.txt"

result=$(HOME="$TEST_HOME" python3 "$ROOT/shell/plugins/panels/dropbox/status.py" 10)

[[ $(jq -r '.files | length' <<<"$result") == "1" ]] ||
  fail "dropbox lists only user files" "$result"
pass "dropbox lists only user files"

[[ $(jq -r '.files[0].name' <<<"$result") == "notes.txt" ]] ||
  fail "dropbox skips .dropbox.cache staging files" "$result"
pass "dropbox skips .dropbox.cache staging files"

[[ $(jq -r '.usedBytes' <<<"$result") == "5" ]] ||
  fail "dropbox usage excludes internal directories" "$result"
pass "dropbox usage excludes internal directories"
