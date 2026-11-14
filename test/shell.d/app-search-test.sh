#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const search = requireFromRoot('shell/services/AppSearch.js')

const entries = [
  {
    name: 'Google Contacts',
    genericName: 'Address Book',
    comment: 'Manage contacts',
    keywords: ['contacts', 'address book', 'people'],
    id: 'google-contacts.desktop'
  },
  {
    name: 'Calculator',
    genericName: 'Calculator',
    comment: 'Perform arithmetic, scientific or financial calculations',
    keywords: ['calculation', 'arithmetic', 'scientific', 'financial'],
    id: 'org.gnome.Calculator.desktop'
  },
  {
    name: 'OBS Studio',
    genericName: 'Streaming/Recording Software',
    comment: 'Free and Open Source Streaming/Recording Software',
    keywords: ['streaming', 'recording', 'capture'],
    id: 'com.obsproject.Studio.desktop'
  },
  {
    name: 'Aether',
    genericName: '',
    comment: 'Minimal internet radio player',
    keywords: ['audio', 'music', 'radio'],
    id: 'io.github.taqi.aether.desktop'
  },
  {
    name: 'Xournal++',
    genericName: 'Notetaking',
    comment: 'Take handwritten notes',
    keywords: ['notes', 'pdf', 'annotation'],
    id: 'com.github.xournalpp.xournalpp.desktop'
  },
  {
    name: 'RustDesk',
    genericName: 'Remote Desktop',
    comment: 'Remote desktop control',
    keywords: ['remote', 'desktop', 'control'],
    id: 'com.rustdesk.RustDesk.desktop'
  }
]

// Keep the packaged launcher when upstream rebuilds register their own entry.
const configuredHides = new Set(fs.readFileSync(path.join(root, 'default/omarchy/launcher.hides'), 'utf8').trim().split(/\n/))
const hermesEntries = [{ name: 'Hermes', id: 'hermes' }, { name: 'Hermes', id: 'hermes-desktop' }]
for (const query of ['', 'hermes']) {
  const visible = search.sortedEntries(hermesEntries, query, entry => configuredHides.has(entry.id))
  assertDeepEqual(visible.map(row => row.entry.id), ['hermes-desktop'], 'only the packaged Hermes launcher is visible')
}

const contactMatches = search.sortedEntries(entries, 'contact').map(row => search.entryName(row.entry))
assertDeepEqual(contactMatches, ['Google Contacts'], 'contact search only returns direct contact matches')

assert(
  search.fuzzyScore(entries[1], 'contact') < 0,
  'calculator does not match contact as a loose subsequence'
)

const acronymMatches = search.sortedEntries(entries, 'gc').map(row => search.entryName(row.entry))
assertEqual(acronymMatches[0], 'Google Contacts', 'short acronym matching still works')

const chineseEntries = [
  { name: '小红书', genericName: '', comment: '', keywords: [], id: 'com.xiaohongshu.app.desktop' },
  { name: '抖音', genericName: '', comment: '', keywords: [], id: 'com.douyin.app.desktop' },
  { name: '微信 Universal', genericName: '', comment: '', keywords: ['wechat', 'weixin'], id: 'wechat-universal.desktop' }
]

const menuModel = requireFromRoot('shell/plugins/menu/MenuModel.js')
assertEqual(menuModel.pinyinInitials('小红书'), 'xhs', 'search computes pinyin initials for Chinese names')
const fieldRuns = menuModel.pinyinFieldInitials(['微信', '', '聊天']).split(' ')
assert(fieldRuns.includes('wx') && fieldRuns.includes('lt') && !fieldRuns.some(run => run.length > 2), 'pinyin initials stay within their field')

for (const [query, name] of [['xhs', '小红书'], ['dy', '抖音'], ['wx', '微信 Universal']]) {
  const hits = search.sortedEntries(chineseEntries, query).map(row => search.entryName(row.entry))
  assertEqual(hits[0], name, 'pinyin initials find ' + name)
}

assert(!search.sortedEntries(chineseEntries, 'dy').some(row => search.entryName(row.entry) === '小红书'), 'unrelated pinyin initials do not match')

// Initials must not run across fields: 微信's name and its 聊天 comment or keyword are not "xl".
const crossField = [
  { name: '微信', genericName: '', comment: '聊天', keywords: ['聊天'], id: 'wechat.desktop' }
]
assert(!search.sortedEntries(crossField, 'xl').length, 'pinyin initials do not span name, comment and keywords')
assertEqual(search.sortedEntries(crossField, 'lt').length, 1, 'a Chinese keyword is found by its own initials')
const qmlListKeywords = { length: 1, 0: '聊天' }
assert(search.entrySearchText({ name: '微信', keywords: qmlListKeywords }).includes(' lt'), 'keywords from a QML list contribute their initials')

const directMatches = search.sortedEntries(entries, 'obs').map(row => search.entryName(row.entry))
assertEqual(directMatches[0], 'OBS Studio', 'direct app-name matching still works')
JS
