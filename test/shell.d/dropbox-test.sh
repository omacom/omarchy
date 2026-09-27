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
  JSON.stringify(dropbox.statusLines('Syncing "x.tgz" • 1 hour\n  Uploading "x.tgz" (1,617 KB/sec, 1 hour)\n\n')),
  JSON.stringify(['Syncing "x.tgz" • 1 hour', 'Uploading "x.tgz" (1,617 KB/sec, 1 hour)']),
  'dropbox splits status into trimmed lines'
)
assertEqual(dropbox.statusLines('').length, 0, 'dropbox handles empty status')
assert(dropbox.isSyncing('Syncing 7 files • 1 hour\nUploading "x" (1,522 KB/sec, 1 hour)'), 'dropbox detects uploads as syncing')
assert(dropbox.isSyncing('Indexing 517 files...'), 'dropbox detects indexing as syncing')
assert(dropbox.isSyncing('Downloading 3 files (18.5 KB/sec, 2 mins)'), 'dropbox detects downloads as syncing')
assert(!dropbox.isSyncing('Up to date'), 'dropbox treats up to date as idle')
assert(!dropbox.isSyncing('Stopped'), 'dropbox treats stopped as idle')

assertEqual(
  dropbox.fileMeta({ modifiedTs: 1000, folder: 'Docs' }, 1000 * 1000 + 3600 * 1000),
  '1h ago · Docs',
  'dropbox file metadata includes relative time and folder'
)
JS
