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

assertEqual(typeof picker.parseThemeNames, 'function', 'image picker model parses extra theme listings')
assertDeepEqual(picker.parseThemeNames('fjord\ngiants\n\nspace\n'), ['fjord', 'giants', 'space'], 'image picker parses extra theme names one per line')
assertDeepEqual(picker.parseThemeNames(''), [], 'image picker parses an empty extra theme listing')
assert(picker.canDeleteTheme('fjord', ['fjord', 'giants']), 'an extra theme can be deleted from the picker')
assert(!picker.canDeleteTheme('nord', ['fjord', 'giants']), 'a stock theme cannot be deleted from the picker')
assert(!picker.canDeleteTheme('', ['fjord']), 'no selection cannot be deleted from the picker')
assert(!picker.canDeleteTheme('fjord', []), 'nothing can be deleted before extra themes are known')
assert(!picker.canDeleteTheme('nord', ['nord', 'fjord'], ['nord']), 'a user override of a stock theme is not deleted from the picker')
assert(picker.canDeleteTheme('fjord', ['fjord'], ['nord']), 'an extra theme beside the stock list can be deleted from the picker')
assert(
  /command: \["find", root\.userThemesPath, "-mindepth", "1", "-maxdepth", "1", "-type", "d", "!", "-xtype", "l", "-printf", "%f\\n"\]/.test(imagePickerQml) &&
    /root\.extraThemeNames = ImagePickerModel\.parseThemeNames\(String\(text \|\| ""\)\)/.test(imagePickerQml) &&
    /function openThemes\(\) \{[\s\S]*?refreshExtraThemes\(\)/.test(imagePickerQml),
  'image picker learns extra themes the way theme remove lists them'
)
assert(
  /ConfirmDialog \{\s*id: deleteConfirm\s*anchors\.fill: parent\s*opened: root\.deleteConfirmOpen\s*z: 10\s*message: "Do you want to delete " \+ \(root\.pendingDeleteTheme \? root\.labelForPath\(root\.pendingDeleteTheme\) : ""\) \+ "\?"\s*confirmText: "Delete"/.test(imagePickerQml) &&
    /onCanceled: root\.cancelDeleteTheme\(\)\s*onConfirmed: root\.confirmDeleteTheme\(\)/.test(imagePickerQml),
  'image picker confirms theme deletion in a faded centered dialog'
)
assert(
  /if \(root\.deleteConfirmOpen\) \{\s*if \(deleteConfirm\.handleKey\(event\)\) event\.accepted = true\s*return\s*\}/.test(imagePickerQml) &&
    imagePickerQml.indexOf('if (root.deleteConfirmOpen) {') < imagePickerQml.indexOf('if (!root.layoutSettled) {') &&
    /else if \(event\.key === Qt\.Key_Delete && !\(event\.modifiers & \(Qt\.ControlModifier \| Qt\.AltModifier \| Qt\.MetaModifier\)\)\) \{\s*root\.requestDeleteSelectedTheme\(\)\s*event\.accepted = true/.test(imagePickerQml),
  'image picker routes keys to the delete confirmation first and maps Delete to it'
)
assert(
  /onOpenedChanged: if \(!opened\) \{ layoutSettled = false; renderedFrames = 0; deleteConfirmOpen = false; pendingDeleteTheme = ""; deleteSelectionPath = ""; awaitingDeleteRefresh = false \}/.test(imagePickerQml) &&
    /id: deleteThemeProc\s*onExited: function\(exitCode\) \{\s*if \(exitCode === 0\) root\.awaitingDeleteRefresh = true\s*else root\.deleteSelectionPath = ""\s*root\.refreshExtraThemes\(\)\s*root\.refreshThemeRows\(\)/.test(imagePickerQml),
  'image picker drops a pending deletion on close and refreshes after one runs'
)

// Run the delete flow itself against a mocked selection and remove process.
const deleteFns = [
  imagePickerQml.match(/function selectedThemeName\(\) \{[\s\S]*?\n  \}/)[0],
  imagePickerQml.match(/function canDeleteSelectedTheme\(\) \{[\s\S]*?\n  \}/)[0],
  imagePickerQml.match(/function requestDeleteSelectedTheme\(\) \{[\s\S]*?\n  \}/)[0],
  imagePickerQml.match(/function cancelDeleteTheme\(\) \{[\s\S]*?\n  \}/)[0],
  imagePickerQml.match(/function confirmDeleteTheme\(\) \{[\s\S]*?\n  \}/)[0]
].join('\n')
function deleteContext(path, extras, inThemeMode) {
  const ctx = {
    themeMode: inThemeMode,
    extraThemeNames: extras,
    stockThemeNames: [],
    stockThemesKnown: true,
    awaitingDeleteRefresh: false,
    pendingDeleteTheme: '',
    deleteSelectionPath: '',
    deleteConfirmOpen: false,
    imageArray: [{ filePath: path }],
    selectedIndex: 0,
    filterText: '',
    deleteThemeProc: { running: false, command: [] },
    deleteConfirm: { selectedIndex: 0 },
    ImagePickerModel: picker,
    nameForPath: picker.nameForPath,
    currentPath() { return path }
  }
  ctx.root = ctx
  require('vm').runInNewContext(deleteFns, ctx)
  return ctx
}
let deletion = deleteContext('/cache/previews/fjord.jpg', ['fjord', 'giants'], true)
deletion.requestDeleteSelectedTheme()
assert(deletion.deleteConfirmOpen && deletion.pendingDeleteTheme === 'fjord', 'Delete asks to confirm the selected extra theme')
deletion.cancelDeleteTheme()
assert(!deletion.deleteConfirmOpen && deletion.pendingDeleteTheme === '' && deletion.deleteThemeProc.command.length === 0, 'canceling deletion removes nothing')
deletion.requestDeleteSelectedTheme()
deletion.confirmDeleteTheme()
assertDeepEqual(deletion.deleteThemeProc.command, ['omarchy-theme-remove', 'fjord'], 'confirming deletion removes exactly the selected theme')
assert(deletion.deleteThemeProc.running && !deletion.deleteConfirmOpen, 'confirming deletion runs the removal and closes the dialog')
deletion = deleteContext('/cache/previews/nord.png', ['fjord'], true)
deletion.requestDeleteSelectedTheme()
assert(!deletion.deleteConfirmOpen, 'Delete does nothing on a stock theme')
deletion = deleteContext('/cache/previews/fjord.jpg', ['fjord'], false)
deletion.requestDeleteSelectedTheme()
assert(!deletion.deleteConfirmOpen, 'Delete does nothing in the background picker')
deletion = deleteContext('/cache/previews/fjord.jpg', ['fjord'], true)
deletion.requestDeleteSelectedTheme()
deletion.deleteThemeProc.running = true
deletion.confirmDeleteTheme()
assertEqual(deletion.deleteThemeProc.command.length, 0, 'a second removal cannot start while one is running')

assertEqual(typeof picker.replacementSelectionPath, 'function', 'image picker model finds where to land after a deletion')
const siblings = ['/p/alpha.png', '/p/bravo.png', '/p/charlie.png'].map(filePath => ({ filePath }))
assertEqual(picker.replacementSelectionPath(siblings, 1, ''), '/p/alpha.png', 'deleting a theme lands on the one before it')
assertEqual(picker.replacementSelectionPath(siblings, 2, ''), '/p/bravo.png', 'deleting the last theme lands on the one before it')
assertEqual(picker.replacementSelectionPath(siblings, 0, ''), '/p/bravo.png', 'deleting the first theme lands on the new first theme')
assertEqual(picker.replacementSelectionPath(siblings.slice(0, 1), 0, ''), '', 'deleting the only theme has nowhere to land')
assertEqual(picker.replacementSelectionPath(siblings, 9, ''), '', 'a stale selection has nowhere to land')
const mixed = ['/p/dark-a.png', '/p/light-b.png', '/p/dark-c.png', '/p/dark-d.png'].map(filePath => ({ filePath }))
assertEqual(picker.replacementSelectionPath(mixed, 2, 'dark'), '/p/dark-a.png', 'deleting a filtered theme lands on the previous match')
assertEqual(picker.replacementSelectionPath(mixed, 0, 'dark'), '/p/dark-c.png', 'deleting the first match lands on the next match')
assert(
  /function confirmDeleteTheme\(\) \{[\s\S]*?if \(name === selectedThemeName\(\)\) deleteSelectionPath = ImagePickerModel\.replacementSelectionPath\(imageArray, selectedIndex, filterText\)/.test(imagePickerQml) &&
    /selectedImage = deleteSelectionPath \|\| currentPath\(\) \|\| currentThemePreview\(\)\s*deleteSelectionPath = ""\s*awaitingDeleteRefresh = false/.test(imagePickerQml),
  'image picker retains its place by selecting the previous theme after a deletion'
)

function retentionContext(paths, selected, filter) {
  const ctx = deleteContext(paths[selected], paths.map(filePath => picker.nameForPath(filePath)), true)
  ctx.imageArray = paths.map(filePath => ({ filePath }))
  ctx.selectedIndex = selected
  ctx.filterText = filter
  ctx.deleteSelectionPath = ''
  return ctx
}
const trio = ['/p/alpha.png', '/p/bravo.png', '/p/charlie.png']
let retention = retentionContext(trio, 1, '')
retention.requestDeleteSelectedTheme()
retention.confirmDeleteTheme()
assertEqual(retention.deleteSelectionPath, '/p/alpha.png', 'confirming a deletion remembers the theme before it')
retention = retentionContext(trio, 0, '')
retention.requestDeleteSelectedTheme()
retention.confirmDeleteTheme()
assertEqual(retention.deleteSelectionPath, '/p/bravo.png', 'confirming the first theme remembers the one after it')
retention = retentionContext(trio, 1, '')
retention.requestDeleteSelectedTheme()
retention.currentPath = () => '/p/charlie.png'
retention.confirmDeleteTheme()
assertEqual(retention.deleteSelectionPath, '', 'no landing is remembered when the selection moved off the deleted theme')
assertDeepEqual(retention.deleteThemeProc.command, ['omarchy-theme-remove', 'bravo'], 'the confirmed theme is still the one removed')

assert(
  /id: stockThemesProc\s*command: \["find", root\.omarchyPath \+ "\/themes", "-mindepth", "1", "-maxdepth", "1", "-type", "d", "-printf", "%f\\n"\]/.test(imagePickerQml) &&
    /root\.stockThemeNames = ImagePickerModel\.parseThemeNames\(String\(text \|\| ""\)\)/.test(imagePickerQml) &&
    /canDeleteTheme\(selectedThemeName\(\), extraThemeNames, stockThemeNames\)/.test(imagePickerQml),
  'image picker knows stock theme names so overrides stay undeletable'
)
assert(
  /function refreshThemeRows\(\) \{\s*if \(themeRowsProc\.running\) \{ themeRowsProc\.queued = true; return \}/.test(imagePickerQml) &&
    /function refreshExtraThemes\(\) \{\s*if \(extraThemesProc\.running\) \{ extraThemesProc\.queued = true; return \}/.test(imagePickerQml) &&
    (imagePickerQml.match(/property bool queued: false/g) || []).length === 2 &&
    (imagePickerQml.match(/onExited: \{\s*if \(queued\) \{\s*queued = false\s*running = true\s*\}\s*\}/g) || []).length === 2,
  'theme row and extra theme refreshes queue behind a running refresh'
)
assert(
  /function applySelected\(\) \{\s*if \(themeMode && \(deleteThemeProc\.running \|\| awaitingDeleteRefresh\)\) return/.test(imagePickerQml) &&
    /function canDeleteSelectedTheme\(\) \{\s*return themeMode && !deleteThemeProc\.running && !awaitingDeleteRefresh && stockThemesKnown && ImagePickerModel\.canDeleteTheme/.test(imagePickerQml) &&
    /function requestDeleteSelectedTheme\(\) \{[\s\S]*?deleteConfirm\.selectedIndex = 1\s*deleteConfirmOpen = true/.test(imagePickerQml) &&
    /function openSelector\([^)]*\) \{\s*deleteConfirmOpen = false\s*pendingDeleteTheme = ""\s*deleteSelectionPath = ""\s*awaitingDeleteRefresh = false/.test(imagePickerQml),
  'image picker cannot apply or re-ask mid-removal and resets delete state per open'
)

deletion = deleteContext('/cache/previews/nord.png', ['nord', 'fjord'], true)
deletion.stockThemeNames = ['nord']
deletion.requestDeleteSelectedTheme()
assert(!deletion.deleteConfirmOpen, 'Delete does nothing on a stock theme override')
deletion = deleteContext('/cache/previews/fjord.jpg', ['fjord'], true)
deletion.stockThemeNames = ['nord']
deletion.deleteThemeProc.running = true
deletion.requestDeleteSelectedTheme()
assert(!deletion.deleteConfirmOpen, 'Delete does not ask while a removal is running')

const refreshFn = imagePickerQml.match(/function refreshThemeRows\(\) \{[\s\S]*?\n  \}/)[0]
const refreshCtx = { themeRowsProc: { running: true, queued: false } }
require('vm').runInNewContext(refreshFn, refreshCtx)
refreshCtx.refreshThemeRows()
assert(refreshCtx.themeRowsProc.queued && refreshCtx.themeRowsProc.running, 'a refresh asked mid-refresh queues behind it')
refreshCtx.themeRowsProc.running = false
refreshCtx.themeRowsProc.queued = false
refreshCtx.refreshThemeRows()
assert(refreshCtx.themeRowsProc.running, 'a refresh asked while idle starts at once')

const updateFn = imagePickerQml.match(/function updateThemeRows\(rows\) \{[\s\S]*?\n  \}/)[0]
const updateCtx = {
  themeRows: 'old', themeOpenPending: false, themeMode: true, opened: true,
  deleteSelectionPath: '/p/alpha.png', selectedImage: '', imageRows: '', loaded: null,
  currentPath() { return '/p/bravo.png' },
  currentThemePreview() { return '' },
  openThemeRows() {},
  loadRows(rows, reveal) { updateCtx.loaded = [rows, reveal] }
}
require('vm').runInNewContext(updateFn, updateCtx)
updateCtx.updateThemeRows('new-rows')
assertEqual(updateCtx.selectedImage, '/p/alpha.png', 'a row refresh after deletion selects the remembered previous theme')
assertEqual(updateCtx.deleteSelectionPath, '', 'the remembered landing is spent by the refresh using it')
assertDeepEqual(updateCtx.loaded, ['new-rows', false], 'the refresh reloads rows without reopening the picker')
updateCtx.themeRows = 'new-rows'
updateCtx.loaded = null
updateCtx.updateThemeRows('new-rows')
assertEqual(updateCtx.selectedImage, '/p/alpha.png', 'an unchanged refresh leaves the selection alone')

assert(
  /property bool stockThemesKnown: false/.test(imagePickerQml) &&
    /id: stockThemesProc[\s\S]*?onExited: function\(exitCode\) \{ if \(exitCode === 0\) root\.stockThemesKnown = true \}/.test(imagePickerQml),
  'deletion stays disabled until the stock listing finishes successfully'
)
deletion = deleteContext('/cache/previews/nord.png', ['nord', 'fjord'], true)
deletion.stockThemeNames = []
deletion.stockThemesKnown = false
deletion.requestDeleteSelectedTheme()
assert(!deletion.deleteConfirmOpen, 'Delete does nothing before stock themes are known')
deletion = deleteContext('/cache/previews/fjord.jpg', ['fjord'], true)
deletion.stockThemeNames = ['nord']
deletion.awaitingDeleteRefresh = true
deletion.requestDeleteSelectedTheme()
assert(!deletion.deleteConfirmOpen, 'Delete does not ask while the post-delete refresh is pending')

const applyFn = imagePickerQml.match(/function applySelected\(\) \{[\s\S]*?\n  \}/)[0]
function applyContext(awaiting) {
  const ctx = {
    themeMode: true, opened: true, awaitingDeleteRefresh: awaiting,
    deleteThemeProc: { running: false },
    currentPath() { return '/p/fjord.jpg' },
    nameForPath: picker.nameForPath,
    Util: { execArgv(argv) { ctx.applied = argv } }
  }
  ctx.root = ctx
  require('vm').runInNewContext(applyFn, ctx)
  return ctx
}
let application = applyContext(true)
application.applySelected()
assert(application.applied === undefined && application.opened, 'Enter cannot apply a deleted theme before rows reload')
application = applyContext(false)
application.applySelected()
assertDeepEqual(application.applied, ['omarchy-theme-set', 'fjord'], 'Enter applies the selected theme once no deletion is pending')

updateCtx.awaitingDeleteRefresh = true
updateCtx.deleteSelectionPath = '/p/alpha.png'
updateCtx.themeRows = 'new-rows'
updateCtx.updateThemeRows('after-delete-rows')
assertEqual(updateCtx.awaitingDeleteRefresh, false, 'the post-delete refresh loading rows releases the apply guard')
JS
