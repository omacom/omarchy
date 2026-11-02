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

const switcherHome = fs.mkdtempSync(path.join(require('os').tmpdir(), 'image-picker home-'))
try {
  const configFile = path.join(switcherHome, '.config/omarchy/shell.json')
  const current = path.join(switcherHome, '.local/state/omarchy/current')
  const stubBin = path.join(switcherHome, 'bin')
  for (const dir of [path.dirname(configFile), current, stubBin]) fs.mkdirSync(dir, { recursive: true })
  const background = path.join(current, 'winding road.webp')
  fs.writeFileSync(background, '')
  fs.symlinkSync(background, path.join(current, 'background'))
  fs.writeFileSync(path.join(current, 'theme.name'), 'test theme\n')
  fs.writeFileSync(path.join(stubBin, 'omarchy-menu-images'), '#!/bin/bash\nprintf "%s\\0" "$@"\n', { mode: 0o755 })
  const env = { ...process.env, HOME: switcherHome, OMARCHY_PATH: root, PATH: `${stubBin}:${root}/bin:${process.env.PATH}` }
  for (const [description, config, captions] of [
    ['missing config uses canonical defaults', null, false],
    ['missing section', '{}', false],
    ['missing key', '{"imagePicker":{}}', false],
    ['disabled', '{"imagePicker":{"wallpaperCaptions":false}}', false],
    ['enabled', '{"imagePicker":{"wallpaperCaptions":true}}', true],
    ['toggled off', '{"imagePicker":{"wallpaperCaptions":false}}', false],
    ['string is not a boolean', '{"imagePicker":{"wallpaperCaptions":"true"}}', false],
    ['malformed config', '{', false],
    ['empty config uses canonical defaults', '', false]
  ]) {
    if (config !== null) fs.writeFileSync(configFile, config)
    const argv = require('child_process').execFileSync('/bin/bash', [path.join(root, 'bin/omarchy-theme-bg-switcher')], { env, encoding: 'utf8' }).split('\0').slice(0, -1)
    assertDeepEqual(argv, [
      ...(captions ? ['--sentence-labels'] : []), '--filterable', '--selected', background,
      path.join(current, 'theme/backgrounds'), path.join(switcherHome, '.config/omarchy/backgrounds/test theme')
    ], `background switcher ${description}: captions, filtering, and paths`)
  }
} finally {
  fs.rmSync(switcherHome, { recursive: true, force: true })
}

// Execute the QML functions themselves; only compositor and process effects are stubbed.
const preview = '/themes/0-winding-road.webp'
const releasedDoneFiles = []
const context = vm.createContext({
  ImagePickerModel: picker,
  Qt: { Key_Escape: 0x01000000, callLater: callback => callback() },
  revealWhenSettled() {}, startImageScan() {}, enableNeighborsWhenReady() {},
  previewHold: { warm() {} },
  doneFilesToRelease: [],
  releaseNextDoneFile() { releasedDoneFiles.push(...context.doneFilesToRelease.splice(0)) },
  imageDirs: '', imageRows: '', loadedImageRows: '', imageArray: [],
  selectedImage: '', selectedIndex: 0, selectionFile: '', doneFile: '',
  opened: false, requestActive: false, requestSerial: 0, imagesLoaded: false,
  showLabels: false, sentenceLabels: false, filterable: false, filterText: '', layoutSettled: false,
  themeMode: false, themeOpenPending: false, themeRows: preview,
  deleteConfirmOpen: false, pendingDeleteTheme: '', deleteSelectionPath: '', awaitingDeleteRefresh: false,
  themeNameFile: { text: () => '0-winding-road' }, themeRowsProc: { running: false, queued: false },
  extraThemesProc: { running: false, queued: false }, stockThemesProc: { running: false }
})
context.root = context
for (const name of [
  'labelForPath', 'nameForPath', 'itemMatches', 'select', 'indexForSelectedImage', 'selectedImageIndex',
  'loadRows', 'openSelector', 'open', 'preloadRows', 'cancel', 'updateFilter', 'finishDoneFile',
  'currentThemePreview', 'openThemes', 'openThemeRows', 'refreshThemeRows', 'refreshExtraThemes', 'refreshStockThemes'
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
  // Filtering is available only after the previews have been revealed.
  context.layoutSettled = true
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
