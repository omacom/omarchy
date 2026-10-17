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

# Dropbox status.py must not call dropbox-cli when the user is not linked,
# because `dropbox-cli status` mints a new cli_link_nonce on every call and
# invalidates the login URL while the user is authenticating in a browser.
TMP_HOME=$(mktemp -d)
TMP_BIN="$TMP_HOME/bin"
CALL_LOG="$TMP_HOME/dropbox-cli-calls.txt"
trap 'rm -rf "$TMP_HOME"' EXIT

mkdir -p "$TMP_BIN"
cat > "$TMP_BIN/dropbox-cli" <<'FAKE'
#!/bin/bash
printf '%s\n' "$*" >> "${DROPBOX_CLI_LOG:?}"
exit 0
FAKE
chmod +x "$TMP_BIN/dropbox-cli"

HOME="$TMP_HOME" PATH="$TMP_BIN:$PATH" DROPBOX_CLI_LOG="$CALL_LOG" \
  python3 "$ROOT/shell/plugins/panels/dropbox/status.py" >/dev/null

if [[ -e $CALL_LOG ]]; then
  fail "status.py called dropbox-cli for an unlinked account"
fi
pass "status.py avoids dropbox-cli status when unauthenticated"
