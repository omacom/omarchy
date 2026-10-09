#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const picker = requireFromRoot('shell/plugins/image-picker/ImagePickerModel.js')

assertEqual(picker.nameForPath('/themes/nord-river.png'), 'nord-river', 'image picker strips directory and extension')
assertEqual(picker.labelForPath('/themes/nord_river.png'), 'Nord River', 'image picker builds display labels')

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

assert(picker.itemMatches(images, 0, 'river'), 'image picker matches file names')
assert(picker.itemMatches(images, 1, 'Gruvbox Dark'), 'image picker matches labels case-insensitively')
assert(!picker.itemMatches(images, 2, 'river'), 'image picker rejects non-matching filters')
assertEqual(picker.firstMatchingIndex(images, 'plain'), 2, 'image picker finds first matching index')
assertEqual(picker.indexForSelectedImage(images, '/themes/a/gruvbox-dark.jpeg'), 1, 'image picker finds selected image')
assertEqual(picker.indexForSelectedImage(images, '/missing.png'), 0, 'image picker defaults selected image to first row')

assertEqual(picker.filteredPosition(images, 2, 'dark'), 1, 'image picker computes filtered position')
assertEqual(picker.selectedFilteredPosition(images, 2, 'dark'), 0, 'image picker selected filtered position falls back when selected is hidden')
assertEqual(picker.nextSelectedIndexForFilter(images, 0, 'dark'), 1, 'image picker moves selection to first match when filter hides current item')

class WindowModel {
  constructor() { this.items = []; this.insertions = 0 }
  get count() { return this.items.length }
  get(i) { return this.items[i] }
  remove(i) { this.items.splice(i, 1) }
  insert(i, item) { this.items.splice(i, 0, { ...item }); this.insertions++ }
  move(from, to) { this.items.splice(to, 0, this.items.splice(from, 1)[0]) }
  setProperty(i, key, value) { this.items[i][key] = value }
}

for (const count of [0, 1, 200, 530, 10000]) {
  const collection = Array.from({ length: count }, (_, i) => ({ filePath: `/themes/theme-${i}.png` }))
  const indices = picker.matchingIndices(collection, '')
  const model = new WindowModel()
  for (const selected of [0, Math.min(1, count - 1), Math.floor(count / 2), count - 1]) {
    const window = picker.visibleWindow(indices, selected, 16)
    picker.syncWindow(model, window)
    assertDeepEqual(model.items, window, `carousel window reconciles ${count} images at ${selected}`)
    assert(model.count <= 33, `carousel bounds delegates for ${count} images`)
    if (count) assert(window.some(item => item.imageIndex === selected && item.relativeIndex === 0), `carousel includes selection in ${count} images`)
  }
  const matches = picker.matchingIndices(collection, 'theme-19')
  picker.syncWindow(model, picker.visibleWindow(matches, matches[0], 16))
  assert(model.items.every(item => collection[item.imageIndex].filePath.includes('theme-19')), `carousel filters ${count} images`)
  picker.syncWindow(model, picker.visibleWindow([], 0, 16))
  assertEqual(model.count, 0, `carousel clears ${count} images when there are no matches`)
}

const windowModel = new WindowModel()
const allIndices = Array.from({ length: 200 }, (_, i) => i)
picker.syncWindow(windowModel, picker.visibleWindow(allIndices, 100, 16))
const retained = windowModel.get(17)
picker.syncWindow(windowModel, picker.visibleWindow(allIndices, 101, 16))
assertEqual(windowModel.get(16), retained, 'carousel retains overlapping delegates when navigating')
assertEqual(windowModel.insertions, 34, 'carousel creates only one new delegate for an adjacent selection')
for (const radius of [1, 8, 16]) {
  assertEqual(picker.visibleWindow(allIndices, 100, radius).length, radius * 2 + 1, `carousel scales its window to radius ${radius}`)
}

const imagePickerQml = fs.readFileSync(path.join(root, 'shell/plugins/image-picker/ImagePicker.qml'), 'utf8')
// Exercise the actual QML refresh handler: model-only filtering tests cannot
// catch a row refresh selecting an image outside the active filter.
const refreshHandler = imagePickerQml.match(/function loadRows\(rows, reveal\) \{[\s\S]*?\n  \}/)[0]
const refreshRoot = {
  filterText: 'dark',
  selectedImage: '/themes/removed-dark.png',
  requestSerial: 1,
  indexForSelectedImage(images) { return picker.indexForSelectedImage(images, this.selectedImage) },
  enableNeighborsWhenReady() {},
  revealWhenSettled() {}
}
const refreshContext = {
  root: refreshRoot,
  ImagePickerModel: picker,
  Qt: { callLater(callback) { callback() } }
}
require('vm').runInNewContext(`${refreshHandler}; loadRows`, refreshContext)
const refreshRows = '/themes/light.png\n/themes/remaining-dark.png\n/themes/other-dark.png'
refreshContext.loadRows(refreshRows, false)
assertEqual(refreshRoot.selectedIndex, 1, 'filtered refresh selects a visible row after the selected theme is removed')
assert(picker.visibleWindow(picker.matchingIndices(refreshRoot.imageArray, 'dark'), refreshRoot.selectedIndex, 8)
  .some(item => item.imageIndex === refreshRoot.selectedIndex), 'filtered refresh has a selected delegate to start preview loading')
refreshRoot.selectedImage = '/themes/other-dark.png'
refreshContext.loadRows(refreshRows, false)
assertEqual(refreshRoot.selectedIndex, 2, 'filtered refresh preserves a selected theme that still matches')
refreshRoot.selectedImage = '/themes/light.png'
refreshContext.loadRows(refreshRows, false)
assertEqual(refreshRoot.selectedIndex, 1, 'filtered refresh moves a hidden selection to the first match')
refreshRoot.filterText = 'missing'
refreshContext.loadRows(refreshRows, false)
assertEqual(refreshRoot.selectedIndex, -1, 'filtered refresh leaves no selection when nothing matches')
refreshRoot.filterText = ''
refreshContext.loadRows(refreshRows, false)
assertEqual(refreshRoot.selectedIndex, 0, 'unfiltered refresh retains its first-row fallback')
refreshContext.loadRows('', false)
assertEqual(refreshRoot.selectedIndex, -1, 'empty refresh has no selected image')

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
  'image picker uses OverlayWindow and takes the keyboard once images load'
)
assert(
  /model: visibleImages/.test(imagePickerQml) &&
    /asynchronous: true\s*cache: false/.test(imagePickerQml),
  'image picker renders its window with bounded asynchronous decoding'
)
const sourceWidth = imagePickerQml.match(/sourceSize\.width: ([^\n]+)/)[1]
const sourceHeight = imagePickerQml.match(/sourceSize\.height: ([^\n]+)/)[1]
const decodeSize = new Function('root', 'Screen', `return [${sourceWidth}, ${sourceHeight}]`)
for (const [scale, expected] of [
  [1, [768, 475]],
  [1.25, [960, 594]],
  [1.5, [1152, 713]],
  [2, [1536, 950]]
]) {
  assertDeepEqual(
    decodeSize({ expandedWidth: 768, expandedHeight: 475 }, { devicePixelRatio: scale }),
    expected,
    `image picker decodes enough physical pixels at ${scale}x display scale`
  )
}
assert(
  imagePickerQml.includes('(item.selected || root.neighborImagesEnabled)') &&
    /onStatusChanged: if \(item.selected && \(status === Image.Ready \|\| status === Image.Error\)\) root.neighborImagesEnabled = true/.test(imagePickerQml),
  'image picker prioritizes the selected preview and releases neighbors on success or failure'
)
assert(
  !/Behavior on (opacity|x|y|width|height)/.test(imagePickerQml) && !imagePickerQml.includes('NumberAnimation'),
  'image picker appears instantly with no fade or geometry transitions'
)
assertEqual((imagePickerQml.match(/layoutSettled = true/g) || []).length, 1, 'image picker settles its layout in exactly one place')
assert(
  /readonly property bool previewSettled: !thumbnailPath \|\| previewReady/.test(imagePickerQml) &&
    /onPreviewSettledChanged: if \(previewSettled\) root\.maybeReveal\(\)/.test(imagePickerQml) &&
    /function allPreviewsSettled\(\) \{[\s\S]*?for \(var i = 0; i < imageCards\.count; i\+\+\) \{[\s\S]*?if \(!item \|\| !item\.previewSettled\) return false[\s\S]*?return true/.test(imagePickerQml) &&
    /function maybeReveal\(\) \{\s*if \(!allPreviewsSettled\(\) \|\| renderedFrames < 2\) return[\s\S]*?Qt\.callLater\(function\(\) \{\s*if \(root\.allPreviewsSettled\(\) && root\.renderedFrames >= 2\) root\.settleReveal\(\)/.test(imagePickerQml) &&
    /function settleReveal\(\) \{\s*if \(!opened \|\| !imagesLoaded \|\| layoutSettled \|\| imageArray\.length === 0\) return\s*layoutSettled = true\s*focusPicker\(\)/.test(imagePickerQml),
  'image picker reveals only once every visible preview has loaded'
)
assert(
  /id: card\s*visible: root\.opened && root\.imagesLoaded && root\.imageArray\.length > 0\s*opacity: root\.layoutSettled \? 1 : 0/.test(imagePickerQml) &&
    /FrameAnimation \{\s*running: root\.opened && !root\.layoutSettled && root\.renderedFrames < 2\s*onTriggered: \{\s*root\.renderedFrames \+= 1\s*root\.maybeReveal\(\)/.test(imagePickerQml) &&
    /if \(!allPreviewsSettled\(\) \|\| renderedFrames < 2\) return/.test(imagePickerQml) &&
    /MouseArea \{ anchors\.fill: parent; enabled: root\.layoutSettled; onClicked: \{\} \}/.test(imagePickerQml),
  'image picker pre-renders hidden for two frames so its first visible frame is complete'
)
assert(
  !imagePickerQml.includes('color: root.scrim') && !/property color scrim:/.test(imagePickerQml),
  'image picker shows no fullscreen scrim wash behind the carousel'
)
const colorQml = fs.readFileSync(path.join(root, 'shell/Commons/Color.qml'), 'utf8')
const shellTpl = fs.readFileSync(path.join(root, 'default/themed/shell.toml.tpl'), 'utf8')
const pickerSection = shellTpl.slice(shellTpl.indexOf('[image-picker]'), shellTpl.indexOf('\n[', shellTpl.indexOf('[image-picker]') + 1))
assert(
  !colorQml.includes('image-picker.scrim') && !pickerSection.includes('scrim'),
  'image picker scrim theme tokens are gone with the backdrop'
)
assert(
  /Timer \{\s*interval: 400\s*running: root\.opened && root\.imagesLoaded && !root\.layoutSettled && root\.imageArray\.length > 0\s*onTriggered: root\.settleReveal\(\)/.test(imagePickerQml),
  'image picker reveals anyway after a short wait if a preview stalls'
)
assert(
  /if \(!root\.layoutSettled\) \{\s*if \(event\.key === Qt\.Key_Escape\) \{\s*root\.cancel\(\)\s*event\.accepted = true\s*\}\s*return\s*\}/.test(imagePickerQml) &&
    imagePickerQml.indexOf('if (!root.layoutSettled) {') < imagePickerQml.indexOf('if (root.filterText) {'),
  'image picker only accepts Escape before it is visible'
)

// Run the QML reveal guards themselves, the way the loadRows handler above
// runs, against mocked delegates in each state the gate must decide.
const revealFns = [
  imagePickerQml.match(/function allPreviewsSettled\(\) \{[\s\S]*?\n  \}/)[0],
  imagePickerQml.match(/function settleReveal\(\) \{[\s\S]*?\n  \}/)[0],
  imagePickerQml.match(/function maybeReveal\(\) \{[\s\S]*?\n  \}/)[0]
].join('\n')
function revealContext(settledFlags, frames) {
  const ctx = {
    opened: true,
    imagesLoaded: true,
    layoutSettled: false,
    renderedFrames: frames,
    imageArray: settledFlags.map(() => ({})),
    focused: 0,
    Qt: { callLater(callback) { callback() } }
  }
  const items = settledFlags.map(previewSettled => ({ previewSettled }))
  ctx.imageCards = { count: items.length, itemAt(i) { return items[i] } }
  ctx.focusPicker = () => { ctx.focused += 1 }
  ctx.root = ctx
  require('vm').runInNewContext(revealFns, ctx)
  return ctx
}
let reveal = revealContext([true, true], 2)
reveal.maybeReveal()
assert(reveal.layoutSettled && reveal.focused === 1, 'reveal settles and focuses once every preview is settled and frames presented')
reveal = revealContext([true, false], 2)
reveal.maybeReveal()
assert(!reveal.layoutSettled, 'an unsettled preview holds the reveal')
reveal = revealContext([true, true], 1)
reveal.maybeReveal()
assert(!reveal.layoutSettled, 'reveal waits for presented frames')
reveal = revealContext([], 2)
reveal.maybeReveal()
assert(!reveal.layoutSettled, 'reveal waits while no cards are rendered')
reveal = revealContext([false], 0)
reveal.settleReveal()
assert(reveal.layoutSettled, 'fallback settle reveals despite a stalled preview')
reveal = revealContext([true], 2)
reveal.opened = false
reveal.settleReveal()
assert(!reveal.layoutSettled, 'settle does nothing once the picker is closed')
JS
