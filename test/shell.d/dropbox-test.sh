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

test_tmp=$(mktemp -d)
daemon_pid=""
trap '[[ -n $daemon_pid ]] && kill "$daemon_pid" 2>/dev/null; rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin" "$test_tmp/home/.dropbox"
cat >"$test_tmp/bin/dropbox-cli" <<'SH'
#!/bin/bash
echo "$*" >>"$HOME/cli.log"
echo "Up to date"
SH
chmod +x "$test_tmp/bin/dropbox-cli"

dropbox_status() {
  HOME="$test_tmp/home" PATH="$test_tmp/bin:$PATH" python3 "$ROOT/shell/plugins/panels/dropbox/status.py" 25
}

# Every `dropbox-cli status` mints a new link URL while unlinked, voiding the one Log in opened.
status=$(dropbox_status)
[[ $(jq -r .running <<<"$status") == "false" && ! -e $test_tmp/home/cli.log ]] ||
  fail "dropbox status reads an unlinked, stopped daemon without asking it for a link" "$status"
pass "dropbox status reads an unlinked, stopped daemon without asking it for a link"

(exec -a dropbox sleep 60) &
daemon_pid=$!
echo "$daemon_pid" >"$test_tmp/home/.dropbox/dropbox.pid"
status=$(dropbox_status)
[[ $(jq -r .running <<<"$status") == "true" && $(jq -r .authenticated <<<"$status") == "false" && ! -e $test_tmp/home/cli.log ]] ||
  fail "dropbox status reads an unlinked, running daemon without asking it for a link" "$status"
pass "dropbox status reads an unlinked, running daemon without asking it for a link"

# info.json can outlive an unlink, so naming an account does not prove the daemon has stopped minting links.
jq -n --arg path "$test_tmp/home/Dropbox" '{personal: {path: $path, subscription_type: "Plus"}}' >"$test_tmp/home/.dropbox/info.json"
status=$(dropbox_status)
[[ $(jq -r .authenticated <<<"$status") == "false" && ! -e $test_tmp/home/cli.log ]] ||
  fail "dropbox status leaves the daemon alone while info.json names a missing folder" "$status"
pass "dropbox status leaves the daemon alone while info.json names a missing folder"

mkdir -p "$test_tmp/home/Dropbox"
jq -n --arg path "$test_tmp/home/Dropbox" '{personal: {path: $path, subscription_type: "Plus"}}' >"$test_tmp/home/.dropbox/info.json"
status=$(dropbox_status)
[[ $(jq -r .running <<<"$status") == "true" && $(jq -r .statusText <<<"$status") == "Up to date" && $(<"$test_tmp/home/cli.log") == "status" ]] ||
  fail "dropbox status asks a linked daemon for its status" "$status"
pass "dropbox status asks a linked daemon for its status"
