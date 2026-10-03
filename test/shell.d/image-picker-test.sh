#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const picker = requireFromRoot('shell/plugins/image-picker/ImagePickerModel.js')

assertEqual(picker.nameForPath('/themes/nord-river.png'), 'nord-river', 'image picker strips directory and extension')
assertEqual(picker.labelForPath('/themes/nord_river.png'), 'Nord River', 'image picker builds title-case display labels')
assertEqual(picker.labelForPath('/themes/nord_river.png', true), 'Nord river', 'image picker sentence labels replace separators and capitalize the first letter')
assertEqual(picker.labelForPath('/themes/soft_BLUE-sky.jpeg', true), 'Soft BLUE sky', 'image picker sentence labels preserve remaining filename casing')
assertEqual(picker.labelForPath('/themes/0-winding-road.webp', true), '0 Winding road', 'image picker sentence labels capitalize the first letter after a number')
assertEqual(picker.labelForPath('/themes/0-winding-road.webp', false), '0 Winding Road', 'image picker explicit false retains title case')
assertEqual(picker.labelForPath('/themes/é-winding-road.webp', true), 'É winding road', 'image picker sentence labels preserve non-ASCII capitalization')
assertEqual(picker.labelForPath('/themes/night__SKY-loop.mp4', true), 'Night SKY loop', 'image picker sentence labels support video paths and repeated separators')
assertEqual(picker.labelForPath('/themes/123.webp', true), '123', 'image picker sentence labels leave names without letters unchanged')
for (const [filename, caption] of [
  ['(sunset).jpg', '(Sunset)'],
  ['[01]-éclair_BLUE.png', '[01] Éclair BLUE'],
  ['(Sunset)_moon.jpg', '(Sunset) moon'],
  ['🌅-sunset.jpg', '🌅 Sunset'],
  ['(𐐨)_sky.png', '(𐐀) sky'],
  ['(123).jpg', '(123)']
]) {
  assertEqual(picker.labelForPath('/themes/' + filename, true), caption, `image picker capitalizes the first cased letter in ${filename}`)
}
for (const sentenceCase of [true, false, undefined]) {
  assertEqual(picker.labelForPath('', sentenceCase), '', `image picker handles empty labels with sentenceCase=${sentenceCase}`)
}

const rows = [
  '/themes/a/nord-river.png\t/cache/nord-river.jpg',
  '/themes/b/nord-river.png\t/cache/duplicate.jpg',
  '/themes/a/gruvbox-dark.jpeg',
  '',
  '\t/cache/no-path.jpg',
  '/themes/a/plain'
].join('\n')

const images = picker.loadRows(rows)
assertDeepEqual(
  images,
  [
    { filePath: '/themes/a/nord-river.png', fileName: 'nord-river.png', thumbnailPath: '/cache/nord-river.jpg' },
    { filePath: '/themes/a/gruvbox-dark.jpeg', fileName: 'gruvbox-dark.jpeg', thumbnailPath: '/themes/a/gruvbox-dark.jpeg' },
    { filePath: '/themes/a/plain', fileName: 'plain', thumbnailPath: '/themes/a/plain' }
  ],
  'image picker parses rows and dedupes by file name'
)

assert(picker.itemMatches(images, 0, 'RIVER'), 'image picker substring filter matches mid-name text case-insensitively')
assert(picker.itemMatches(images, 1, 'Gruvbox Dark'), 'image picker matches labels case-insensitively')
assert(!picker.itemMatches(images, 2, 'river'), 'image picker rejects non-matching filters')
assertEqual(picker.firstMatchingIndex(images, 'plain'), 2, 'image picker finds first matching index')
assertEqual(picker.indexForSelectedImage(images, '/themes/a/gruvbox-dark.jpeg'), 1, 'image picker finds selected image')
assertEqual(picker.indexForSelectedImage(images, '/missing.png'), 0, 'image picker defaults selected image to first row')

assertEqual(picker.filteredPosition(images, 2, 'dark'), 1, 'image picker computes filtered position')
assertEqual(picker.selectedFilteredPosition(images, 2, 'dark'), 0, 'image picker selected filtered position falls back when selected is hidden')
assertEqual(picker.nextSelectedIndexForFilter(images, 0, 'dark'), 1, 'image picker moves selection to first match when filter hides current item')

const backgroundSwitcher = fs.readFileSync(path.join(root, 'bin/omarchy-theme-bg-switcher'), 'utf8')
assert(
  /omarchy-menu-images\s+\\\n\s+--sentence-labels\s+\\/.test(backgroundSwitcher),
  'background switcher shows filename captions'
)
assert(
  /--filterable\s+\\/.test(backgroundSwitcher),
  'background switcher filters filename substrings'
)

const imagePickerQml = fs.readFileSync(path.join(root, 'shell/plugins/image-picker/ImagePicker.qml'), 'utf8')
// Execute the QML functions themselves; only compositor and process effects are stubbed.
const preview = '/themes/0-winding-road.webp'
const releasedDoneFiles = []
const context = vm.createContext({
  ImagePickerModel: picker,
  Qt: { Key_Escape: 0x01000000, callLater: callback => callback() },
  revealWhenSettled() {}, startImageScan() {},
  doneFilesToRelease: [],
  releaseNextDoneFile() { releasedDoneFiles.push(...context.doneFilesToRelease.splice(0)) },
  imageDirs: '', imageRows: '', loadedImageRows: '', imageArray: [],
  selectedImage: '', selectedIndex: 0, selectionFile: '', doneFile: '',
  opened: false, requestActive: false, requestSerial: 0, imagesLoaded: false,
  showLabels: false, sentenceLabels: false, filterable: false, filterText: '', layoutSettled: false,
  themeMode: false, themeOpenPending: false, themeRows: preview,
  themeNameFile: { text: () => '0-winding-road' }, themeRowsProc: { running: false }
})
context.root = context
for (const name of [
  'labelForPath', 'nameForPath', 'itemMatches', 'select', 'indexForSelectedImage', 'selectedImageIndex',
  'loadRows', 'openSelector', 'open', 'preloadRows', 'cancel', 'updateFilter', 'finishDoneFile',
  'currentThemePreview', 'openThemes', 'openThemeRows', 'refreshThemeRows'
]) {
  const fn = imagePickerQml.match(new RegExp(`  function ${name}\\([^]*?\\n  }`))
  if (!fn) fail(`ImagePicker.qml provides ${name}`)
  vm.runInContext(fn[0], context)
}

function checkLabels(showLabels, sentenceLabels, description) {
  assertDeepEqual(
    [context.showLabels, context.sentenceLabels, context.labelForPath(preview)],
    [showLabels, sentenceLabels, sentenceLabels ? '0 Winding road' : '0 Winding Road'],
    description
  )
}

const entryPoints = {
  'open(payload)': labels => context.open(JSON.stringify({ imageRows: preview, showLabels: labels })),
  openSelector: labels => context.openSelector('', preview, '', '', '', labels, false),
  preloadRows: labels => context.preloadRows(preview, '', labels, false)
}
for (const [name, invoke] of Object.entries(entryPoints)) {
  for (const [labels, visible] of [[true, true], ['true', true], [false, false], ['false', false], [undefined, false]]) {
    context.cancel()
    invoke('sentence')
    checkLabels(true, true, `${name} enables sentence labels before ${typeof labels} ${labels}`)
    context.cancel()
    invoke(labels)
    checkLabels(visible, false, `${name} resets sentence mode for ${typeof labels} ${labels}`)
  }
}

for (const active of ['opened', 'requestActive']) {
  context.cancel()
  context.preloadRows(preview, '', 'sentence', false)
  context[active] = true
  context.preloadRows(preview, '', false, false)
  checkLabels(true, true, `preloadRows preserves sentence labels while ${active}`)
  context[active] = false
}
context.openSelector('', preview, '', '', '', 'sentence', false)
context.open(JSON.stringify({ source: 'themes' }))
checkLabels(true, false, 'open themes via openThemeRows resets sentence labels to title case')
assert(context.themeMode && context.filterable && context.themeRowsProc.running,
  'theme open preserves theme mode, filtering, and background refresh')
assertEqual(context.selectedImage, preview, 'theme open still selects the current theme preview')

const keyHandler = imagePickerQml.match(/Keys\.onPressed: (function\(event\) \{[^]*?\n          })/)
if (!keyHandler) fail('ImagePicker.qml provides Keys.onPressed')
const onPressed = vm.runInContext(`(${keyHandler[1]})`, context)
for (const [filter, matches] of [['winding', true], ['no-such-image', false]]) {
  releasedDoneFiles.length = 0
  context.openSelector('', preview, '', '/test/selection', '/test/done', true, true)
  context.updateFilter(filter)
  assertEqual(context.itemMatches(context.selectedIndex), matches, `Escape fixture has matches=${matches}`)

  const clearEvent = { key: context.Qt.Key_Escape, accepted: false }
  onPressed(clearEvent)
  assertDeepEqual(
    [context.filterText, context.opened, context.requestActive, context.selectionFile, context.doneFile, clearEvent.accepted],
    ['', true, true, '/test/selection', '/test/done', true],
    `Escape clears ${filter} and accepts the key without closing the active request`
  )
  assertDeepEqual(releasedDoneFiles, [], `Escape with ${filter} does not complete the request`)

  const cancelEvent = { key: context.Qt.Key_Escape, accepted: false }
  onPressed(cancelEvent)
  assertDeepEqual(
    [context.opened, context.requestActive, context.selectionFile, context.doneFile, cancelEvent.accepted],
    [false, false, '', '', true],
    `Escape after clearing ${filter} cancels, closes, and accepts the key`
  )
  assertDeepEqual(releasedDoneFiles, ['/test/done'], `Escape after clearing ${filter} releases the done file`)
  onPressed({ key: context.Qt.Key_Escape, accepted: false })
  assertDeepEqual(releasedDoneFiles, ['/test/done'], `repeated Escape after ${filter} releases the done file only once`)
}
assert(
  /function preloadRows[\s\S]*if \(opened \|\| requestActive\) return/.test(imagePickerQml),
  'image picker ignores cache preloads while a request is visible'
)
assert(
  /if \(args\.source === "themes"\) \{\s*openThemes\(\)/.test(imagePickerQml) &&
    /function openThemes\(\) \{\s*if \(themeRows\) \{\s*openThemeRows\(\)[\s\S]*refreshThemeRows\(\)/.test(imagePickerQml),
  'image picker opens themes from held rows before refreshing them'
)
assert(
  /command: \[root\.omarchyPath \+ "\/bin\/omarchy-theme-switcher", "--print-rows"\]/.test(imagePickerQml),
  'image picker refreshes theme rows from the theme switcher'
)
assert(
  /if \(themeMode\) \{[\s\S]*Util\.execArgv\(\["omarchy-theme-set", nameForPath\(path\)\]\)/.test(imagePickerQml),
  'image picker applies a chosen theme itself'
)
assert(
  /function cancel\(\) \{\s*themeOpenPending = false/.test(imagePickerQml) &&
    /function closeSelector\(nextDoneFile\) \{\s*requestSerial \+= 1\s*themeOpenPending = false/.test(imagePickerQml),
  'image picker drops a pending theme open once dismissed'
)
assert(
  /function openSelector[\s\S]*?themeMode = false/.test(imagePickerQml),
  'image picker leaves theme mode when another caller opens it'
)
assert(
  /OverlayWindow \{\s*id: panel\s*shown: root\.opened\s*shownKeyboardFocus: root\.imagesLoaded \? WlrKeyboardFocus\.Exclusive : WlrKeyboardFocus\.None/.test(imagePickerQml),
  'image picker parks on OverlayWindow and takes the keyboard once images load'
)
assert(
  /source: item\.sourceActivated && item\.thumbnailPath \? Util\.fileUrl\(item\.thumbnailPath\) : ""[\s\S]*asynchronous: false/.test(imagePickerQml),
  'image picker loads activated thumbnails synchronously to avoid carousel flicker'
)
JS
