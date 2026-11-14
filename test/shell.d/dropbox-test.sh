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

assert(dropbox.isSyncing('Syncing 9,007 files • 1 hour\nDownloading 9,007 files (34,839 KB/sec, 1 hour)'), 'dropbox recognizes live transfers')
assert(dropbox.isSyncing('Uploading 1 file (250 KB/sec)'), 'dropbox recognizes uploads')
assert(!dropbox.isSyncing('Up to date'), 'dropbox clears activity when finished')
assert(!dropbox.isSyncing('Stopped'), 'dropbox clears activity when stopped')

const transfer = dropbox.syncDetails('Syncing 7,697 files • 25 mins\nDownloading 7,697 files (101,984 KB/sec, 25 mins)', n => n.toLocaleString('en-US'))
assertEqual(transfer.label, 'Downloading 7,697 files', 'dropbox avoids duplicate transfer counts')
assertEqual(transfer.detail, '102 MB/s · 25 mins', 'dropbox condenses speed and ETA')
assertEqual(transfer.remaining, 7697, 'dropbox parses remaining files for progress')
assertEqual(dropbox.syncDetails('Syncing 4 files • 1 min\nUploading 1 file...\nDownloading 3 files (1,500 KB/sec, 1 min)').detail, '1.5 MB/s · 1 min', 'dropbox keeps the transfer rate during simultaneous uploads and downloads')
assertEqual(dropbox.syncDetails('Syncing...').detail, '', 'dropbox handles startup without transfer data')
assertEqual(dropbox.syncDetails('Uploading 1 file (250 KB/sec)').detail, '250 KB/s', 'dropbox formats upload speed without ETA')

const mixed = dropbox.syncDetails('Syncing 4 files • 1 min\nUploading 1 file...\nDownloading 3 files (500 B/sec, 1 min)')
assertEqual(mixed.remaining, 4, 'dropbox progress uses the overall count for mixed transfers')
assertEqual(mixed.label, 'Syncing 4 files', 'dropbox labels mixed transfers with the total')
assertEqual(mixed.detail, '500 B/s · 1 min', 'dropbox preserves byte-per-second rates')
const translated = dropbox.syncDetails('Syncing 4 files • 2+ days\nDownloading 4 files (500 B/sec)', n => `[${n}]`, (key, english) => `translated:${english}`)
assertEqual(translated.label, 'translated:Downloading [4] files', 'dropbox translates and formats transfer counts')
assertEqual(translated.detail, '[500] B/s · translated:[2]+ days', 'dropbox translates and formats ETA with plus estimates')
assertEqual(dropbox.syncDetails('Uploading 1 file (500 B/sec)').label, 'Uploading 1 file', 'dropbox uses singular transfer labels')

// Exercise the real refresh method with a status poll already in flight.
const fs = require('fs')
const vm = require('vm')
const service = fs.readFileSync(`${process.env.ROOT}/shell/plugins/panels/dropbox/Service.qml`, 'utf8')
const refreshSource = service.match(/  function refresh\(statusOnly\) \{[\s\S]*?\n  \}/)[0]
const state = { statusProcess: { running: true }, helperPath: '/checkout/status.py', _fullRefreshPending: false }
vm.createContext(state)
vm.runInContext(refreshSource, state)
state.refresh()
assert(state._fullRefreshPending, 'dropbox queues a full refresh when a status poll is running')
state.statusProcess.running = false
state.refresh()
assertEqual(state.statusProcess.command.length, 3, 'dropbox queued refresh includes the full scan')
assert(!state._fullRefreshPending, 'dropbox consumes the pending full refresh')

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

const day = 86400 * 1000
assertEqual(dropbox.relativeTime(1, 1000 + 359 * day), '11mo ago', 'dropbox shows months just under a year')
assertEqual(dropbox.relativeTime(1, 1000 + 360 * day), '11mo ago', 'dropbox never shows zero years at 360 days')
assertEqual(dropbox.relativeTime(1, 1000 + 364 * day), '11mo ago', 'dropbox never shows zero years at 364 days')
assertEqual(dropbox.relativeTime(1, 1000 + 365 * day), '1y ago', 'dropbox shows one year at 365 days')
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

# Cache writes must not crowd real files out of the recent list or inflate storage.
mkdir -p "$test_tmp/home/Dropbox/.dropbox.cache/new_files"
printf 'metadata' >"$test_tmp/home/Dropbox/.dropbox"
printf 'cache' >"$test_tmp/home/Dropbox/.dropbox.cache/new_files/staged"
printf 'doc' >"$test_tmp/home/Dropbox/document.txt"
printf 'hi' >"$test_tmp/home/Dropbox/.notes"
status=$(dropbox_status)
jq -e '.usedBytes == 5 and ([.files[].name] | sort) == [".notes", "document.txt"]' <<<"$status" >/dev/null ||
  fail "dropbox excludes internal metadata and cache while retaining ordinary hidden files" "$status"
pass "dropbox excludes internal metadata and cache while retaining ordinary hidden files"
