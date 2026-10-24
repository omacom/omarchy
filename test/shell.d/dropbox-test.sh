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

assertEqual(
  dropbox.fileUri('/home/me/Dropbox/Q1 "final" #2.pdf'),
  'file:///home/me/Dropbox/Q1%20%22final%22%20%232.pdf',
  'dropbox encodes each path segment into a file URI'
)

const reveal = dropbox.revealCommand("/home/me/Dropbox/it's here.txt")
assertEqual(reveal.slice(0, 3).join(' '), 'gdbus call --session', 'dropbox reveals files over D-Bus')
assertEqual(reveal[reveal.indexOf('--dest') + 1], 'org.freedesktop.FileManager1', 'dropbox asks whichever file manager owns FileManager1')
assertEqual(reveal[reveal.indexOf('--object-path') + 1], '/org/freedesktop/FileManager1', 'dropbox calls the FileManager1 object')
assertEqual(reveal[reveal.indexOf('--method') + 1], 'org.freedesktop.FileManager1.ShowItems', 'dropbox selects the file rather than opening its folder')
assertEqual(reveal[reveal.length - 2], '["file:///home/me/Dropbox/it\'s%20here.txt"]', 'dropbox passes the URI as a GVariant string array')
assertEqual(reveal[reveal.length - 1], '', 'dropbox passes an empty startup id')
JS
