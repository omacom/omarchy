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

// Views: Up and Down switch between image sets by running an Omarchy command.
const viewFunctions = ['setViews', 'switchView', 'requestView', 'startView', 'loadView']
  .map(name => imagePickerQml.match(new RegExp(`function ${name}\\([^)]*\\) \\{[\\s\\S]*?\\n  \\}`))[0])
  .join('\n')
const viewRoot = { requestActive: true, requestSerial: 4, filterText: 'x', loaded: null, views: [], viewCommand: [], viewIndex: 0, viewStep: 1,
  showLabels: false, filterable: false, selectedImage: '',
  get hasViews() { return this.views.length > 1 },
  loadRows(rows) { this.loaded = rows } }
const viewProc = { running: false, serial: 0, queuedSerial: 0 }
const viewContext = { root: viewRoot, viewProc }
require('vm').runInNewContext(`with (root) { ${viewFunctions}; root.setViews = setViews; root.switchView = switchView; root.requestView = requestView; root.startView = startView; root.loadView = loadView }`, viewContext)
const views = [{ id: 'theme', title: 't' }, { id: 'all', title: 'a', labels: true, filterable: true }]

viewRoot.setViews({ current: 'all', command: ['sh', '-c', 'id'], views })
assertEqual(viewRoot.views.length, 0, 'views refuse a command that is not an Omarchy command')
viewRoot.setViews({ current: 'all', command: ['omarchy-theme-bg-switcher', '--rows'], views })
assertEqual(viewRoot.viewIndex, 1, 'views open on the current view')

viewRoot.switchView(1)
assertEqual(viewRoot.viewIndex, 0, 'Down wraps past the last view')
assertDeepEqual(viewProc.command, ['omarchy-theme-bg-switcher', '--rows', 'theme'], 'a view runs its command with the view id')
assert(viewProc.running && viewProc.serial === 4, 'switching starts the view command for this opening')
viewRoot.switchView(-1)
assert(viewProc.queuedSerial === 4 && viewRoot.viewIndex === 1, 'a switch while one loads is queued for the latest view')

// The process-exit handler that starts a queued switch.
const restartBody = imagePickerQml.match(/onRunningChanged: \{([\s\S]*?)\n    \}/)[1]
const restart = require('vm').runInNewContext(`(function () { with (viewProc) { ${restartBody} } })`, viewContext)
viewProc.running = false
viewRoot.requestActive = false
restart()
assert(!viewProc.running && viewProc.queuedSerial === 0, 'a switch queued in a picker that has closed never starts')
viewRoot.requestActive = true
viewRoot.requestSerial = 5
viewProc.running = true
viewRoot.switchView(1)
assertEqual(viewProc.serial, 4, 'a running command keeps the opening it started for, so its output is not taken for a later one')
viewProc.running = false
restart()
assert(viewProc.running && viewProc.serial === 5, 'the queued switch starts for the current opening')
viewRoot.switchView(-1)
viewProc.running = false
viewProc.queuedSerial = 0

viewRoot.loadView('theme\n/themes/b.png\n/themes/a.png\t/c/a.jpg')
assertEqual(viewRoot.loaded, null, 'output for a view already moved past is dropped')
viewRoot.loadView('all\n/themes/b.png\n/themes/a.png\t/c/a.jpg\n/themes/b.png\t/c/b.jpg')
assertEqual(viewRoot.selectedImage, '/themes/b.png', 'a view selects the image it names')
assertEqual(viewRoot.loaded, '/themes/a.png\t/c/a.jpg\n/themes/b.png\t/c/b.jpg', 'a view loads the rows after it')
assert(viewRoot.showLabels && viewRoot.filterable && viewRoot.filterText === '', 'a loaded view takes its labels and filter and clears the old filter')

viewRoot.views = [{ id: 'theme' }, { id: 'all' }, { id: 'mine' }]
viewRoot.viewIndex = 2
viewRoot.viewStep = 1
viewProc.running = false
viewRoot.loaded = null
viewRoot.loadView('mine\n\n')
assertDeepEqual(viewRoot.views.map(view => view.id), ['theme', 'all'], 'a view that has emptied since opening is left out')
assert(viewRoot.loaded === null && viewProc.running && viewProc.command.at(-1) === 'theme', 'Down past an emptied view moves on to the next one')
JS
