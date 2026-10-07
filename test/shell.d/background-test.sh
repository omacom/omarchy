#!/bin/bash
source "$(dirname "$0")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const backgroundQml = fs.readFileSync(path.join(root, 'shell/plugins/background/Background.qml'), 'utf8')

assert(
  /function openThemeSwitcher\(\) \{[\s\S]*if \(!root\.shell \|\| !root\.shell\.summon\("omarchy\.image-picker", payload\)\)\s*Util\.execArgv\(\["omarchy-shell", "shell", "summon", "omarchy\.image-picker", payload\]\)/.test(backgroundQml) &&
    !backgroundQml.includes('omarchy-theme-switcher'),
  'background opens the in-shell theme picker instead of spawning the switcher script'
)

assert(
  backgroundQml.includes('pendingThemeFallbackTimer.restart()') &&
    backgroundQml.includes('pendingThemeFallbackTimer.stop()') &&
    backgroundQml.includes('id: pendingThemeFallbackTimer') &&
    !backgroundQml.includes('pendingThemeVersion !== backgroundVersion'),
  'background theme transition applies pending colors even if image reveal stalls'
)

const themeSet = fs.readFileSync(path.join(root, 'bin/omarchy-theme-set'), 'utf8')

// The next background decodes while the theme stages, rather than after the
// transition arrives: WebP decodes take as long at screen size as at native.
assert(
  /function prepare\(path: string\): void \{\s*root\.prepareBackground\(path\)/.test(backgroundQml) &&
    backgroundQml.includes('readonly property string framePath: root.incomingBackground || root.preparedBackground'),
  'background decodes a prepared theme background in the hidden incoming frame'
)
assert(
  /path === lastTransitionPath/.test(backgroundQml) &&
    /id: preparedBackgroundTimer[\s\S]*?onTriggered: root\.preparedBackground = ""/.test(backgroundQml),
  'background ignores a late prepare and drops an unclaimed one'
)
assert(
  themeSet.indexOf('shell_ipc background prepare') !== -1 &&
    themeSet.indexOf('shell_ipc background prepare') < themeSet.indexOf('\nomarchy-theme-set-templates\n'),
  'theme set hands the shell its next background before rendering templates'
)
assert(
  themeSet.includes('shell_ipc background prepare "$PREPARED_BACKGROUND_SNAPSHOT" 9>&- &'),
  'theme set sends the prepare without holding the theme lock or waiting on it'
)

// The wallpaper is decoded at the screen's physical size, never at the size
// it was shipped at, unless it is smaller than the screen: then it is decoded
// at its own size instead of being scaled up to cover the screen.
const mediaQml = fs.readFileSync(path.join(root, 'shell/Ui/BackgroundMedia.qml'), 'utf8')
assert(
  backgroundQml.includes('readonly property bool sized: width > 0 && height > 0') &&
    backgroundQml.includes('readonly property int decodeWidth: sized ? Math.ceil(width * screen.devicePixelRatio) : 0') &&
    backgroundQml.includes('readonly property int decodeHeight: sized ? Math.ceil(height * screen.devicePixelRatio) : 0'),
  'background derives its decode size from the screen in physical pixels'
)
assert(
  backgroundQml.includes('["magick", "identify", "-ping", "-format", "%w %h", sizeProbe.path]') &&
    backgroundQml.includes('if (native.width > 0 && (native.width < decodeWidth || native.height < decodeHeight)) return Qt.size(native.width, native.height)'),
  'background reads the wallpaper header and never decodes larger than the native size'
)
const count = (needle) => backgroundQml.split(needle).length - 1
assertEqual(count('sourceSize.width: decode.width'), 2, 'both transition frames bind their decode width')
assertEqual(count('sourceSize.height: decode.height'), 2, 'both transition frames bind their decode height')
assertEqual(count('source: decode.width > 0 ? root.imageUrl('), 2, 'both transition frames wait for the screen and native sizes before loading')
assert(
  /constrainDecode: true\s*decodeSize: panel\.decodeSize\(root\.displayedBackground\)/.test(backgroundQml) &&
    mediaQml.includes('source: !root.constrainDecode || root.decodeSize.width > 0 ? root.imageUrl : ""') &&
    mediaQml.includes('sourceSize.width: root.constrainDecode ? root.decodeSize.width : (root.version > 0 ? width : 0)'),
  'the displayed wallpaper waits for and decodes at the same size'
)
assert(
  /function requestNativeSize\(path\) \{\s*if \(!path \|\| isVideo\(path\)/.test(backgroundQml) &&
    /function prepareBackground[\s\S]*?requestNativeSize\(path\)/.test(backgroundQml),
  'background never probes videos and probes a prepared frame ahead of its transition'
)
assert(
  /BackgroundMedia\s*\{[\s\S]*id: base[\s\S]*version: root\.backgroundVersion/.test(backgroundQml),
  'displayed wallpaper binds backgroundVersion to bust cache across same-name theme switches'
)
// Execute the QML JavaScript with process and panel state controlled by the test.
const vm = require('vm')
function blockAfter(marker) {
  const start = backgroundQml.indexOf(marker)
  assert(start !== -1, 'background contains ' + marker)
  const open = backgroundQml.indexOf('{', start)
  let depth = 1
  let end = open + 1
  while (depth && end < backgroundQml.length) {
    if (backgroundQml[end] === '{') depth++
    if (backgroundQml[end] === '}') depth--
    end++
  }
  return backgroundQml.slice(open + 1, end - 1)
}

const state = {
  nativeSizes: {}, sizeQueue: [], sizeGenerations: {},
  sizeProbe: { running: false }, sizeProbeOut: { text: '' },
  currentBackground: 'wallpaper', displayedBackground: 'wallpaper',
  incomingBackground: '', oldBackground: '', preparedBackground: '',
  backgroundVersion: 0, finishingTransition: false,
  preparedBackgroundTimer: { stop() {} }, revealAnimation: { stop() {} },
  isVideo() { return false },
  panels: { instances: [{ baseReady: true }, { baseReady: false }] },
  Qt: { callLater(callback) { deferred.push(callback) } }
}
const deferred = []
state.root = state
const context = vm.createContext(state)
for (const name of ['transitionBackground', 'requestNativeSize', 'probeNextSize', 'pruneNativeSizes', 'finishTransition']) {
  vm.runInContext('function ' + name + backgroundQml.slice(
    backgroundQml.indexOf('(', backgroundQml.indexOf('function ' + name)),
    backgroundQml.indexOf('{', backgroundQml.indexOf('function ' + name))
  ) + '{' + blockAfter('function ' + name + '(') + '}', context)
}
const completeProbe = vm.runInContext('(function(exitCode) {' +
  blockAfter('onExited: function(exitCode)') + '})', context)
function complete(width, height) {
  state.sizeProbeOut.text = width + ' ' + height
  state.sizeProbe.running = false
  context.path = state.sizeProbe.path
  context.generation = state.sizeProbe.generation
  completeProbe(0)
}

state.requestNativeSize('wallpaper')
state.transitionBackground('old-snapshot', 'new-snapshot', 'wallpaper', false, true)
complete(640, 480)
assertEqual(state.nativeSizes.wallpaper, undefined, 'stale probe cannot restore invalidated dimensions')
assert(state.sizeQueue.includes('wallpaper'), 'stale completion preserves the replacement request')
assertEqual(state.sizeProbe.path, 'new-snapshot', 'stale completion advances the probe queue')
complete(3840, 2160)
complete(1920, 1080)
assertEqual(state.sizeProbe.path, 'wallpaper', 'replacement probe starts after snapshot probes')
complete(3840, 2160)
assertDeepEqual(state.nativeSizes.wallpaper, { width: 3840, height: 2160 }, 'fresh probe caches the replacement dimensions')
assertEqual(state.sizeQueue.length, 0, 'fresh completion removes its queued request')

state.requestNativeSize('unrelated')
state.transitionBackground('old-snapshot', 'new-snapshot', 'wallpaper', false, true)
complete(800, 600)
assertDeepEqual(state.nativeSizes.unrelated, { width: 800, height: 600 }, 'invalidation leaves unrelated in-flight probes valid')
complete(4096, 2304)

const revealFinished = vm.runInContext('(function() {' + blockAfter('onFinished:') + '})', context)
const readyChanged = backgroundQml.match(/onReadyChanged: ([^\n]+)/)[1]
revealFinished()
deferred.shift()()
assertEqual(state.incomingBackground, 'new-snapshot', 'deferred cleanup retains incoming frame while any base is loading')
assertEqual(state.finishingTransition, true, 'transition waits for all panel bases')
vm.runInContext(readyChanged, context)
assertEqual(state.incomingBackground, 'new-snapshot', 'one ready panel cannot clear the shared incoming frame')
state.panels.instances[1].baseReady = true
vm.runInContext(readyChanged, context)
assertEqual(state.incomingBackground, '', 'base readiness clears incoming frame once all panels are ready')
assertEqual(state.oldBackground, '', 'base readiness clears old frame')
assertEqual(state.preparedBackground, '', 'base readiness clears prepared frame')
assertEqual(state.finishingTransition, false, 'base readiness finishes transition')
assertDeepEqual(state.nativeSizes, { wallpaper: { width: 4096, height: 2304 } }, 'cleanup prunes unused native sizes')

state.incomingBackground = 'cached-snapshot'
state.oldBackground = 'old-snapshot'
state.preparedBackground = 'cached-snapshot'
revealFinished()
assertEqual(state.incomingBackground, 'cached-snapshot', 'reveal defers cleanup of an already-ready base')
deferred.shift()()
assertEqual(state.incomingBackground, '', 'deferred check cleans up an already-ready base')
state.incomingBackground = 'next-snapshot'
vm.runInContext(readyChanged, context)
assertEqual(state.incomingBackground, 'next-snapshot', 'readiness outside transition completion preserves incoming frame')
JS
