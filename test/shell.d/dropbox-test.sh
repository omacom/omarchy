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

run_node_test "dropbox link wait wiring" <<'JS'
const fs = require('fs')
const service = fs.readFileSync(root + '/shell/plugins/panels/dropbox/Service.qml', 'utf8')
const panel = fs.readFileSync(root + '/shell/plugins/panels/dropbox/Panel.qml', 'utf8')

assert(/function openAuthUrlFrom\(text\)[\s\S]*?beginLinkWait\(\)/.test(service), 'opening the account-link page starts the link wait')
assert(/if \(linkPending && authenticated\) finishLink\(\)/.test(service), 'a status poll that reports a linked account ends the link wait')
assert(/function login\(\)[\s\S]*?if \(linkPending && linkUrlKnown\)[\s\S]*?Qt\.openUrlExternally\(_loginUrl\)/.test(service), 'login while a link is pending reopens the page instead of re-running dropbox-cli start')
assert(/else if \(!opened\) \{[\s\S]{0,400}?root\.beginLinkWait\(\)/.test(service), 'a login attempt that yields no URL still starts the link wait')
assert(/Dropbox never confirmed the link[\s\S]{0,200}root\.actionStatus = root\.lastError/.test(service), 'an exhausted link wait surfaces an error that survives the next status poll')
assert(/dropbox\.linkPending \? "Finish linking in your browser"/.test(panel), 'the login button says to finish linking while a link is pending')
JS
