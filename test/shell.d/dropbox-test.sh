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

# Regression for #12638: plan name must not invent a quota.
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/home/.dropbox" "$test_tmp/home/Dropbox" "$test_tmp/bin"
printf 'hello\n' >"$test_tmp/home/Dropbox/note.txt"
python3 -c "
import json, pathlib
home = pathlib.Path(r'$test_tmp/home')
info = home / '.dropbox' / 'info.json'
info.write_text(json.dumps({
  'personal': {
    'path': str(home / 'Dropbox'),
    'subscription_type': 'Basic',
  }
}))
"

# Isolate PATH so a host dropbox-cli cannot change statusText / installed.
PATH="$test_tmp/bin:/usr/bin:/bin" HOME="$test_tmp/home" \
  python3 "$ROOT/shell/plugins/panels/dropbox/status.py" >"$test_tmp/status.json"

python3 - "$test_tmp/status.json" "$ROOT/shell/plugins/panels/dropbox/status.py" <<'PY' || fail "dropbox status does not invent a plan-table quota"
import json, sys
data = json.load(open(sys.argv[1]))
assert data.get("plan") == "Basic", data
assert data.get("quotaBytes") == 0, data
assert data.get("quotaKnown") is False, data
assert data.get("usagePercent") == 0, data
assert data.get("usedBytes", 0) > 0, data
assert data.get("authenticated") is True, data
assert "PLAN_QUOTAS" not in open(sys.argv[2]).read()
print("ok")
PY

pass "dropbox status emits unknown quota instead of a hardcoded plan floor"
