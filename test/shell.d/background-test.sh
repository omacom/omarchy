#!/bin/bash
source "$(dirname "$0")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const backgroundQml = fs.readFileSync(path.join(root, 'shell/plugins/background/Background.qml'), 'utf8')
const mediaQml = fs.readFileSync(path.join(root, 'shell/Ui/BackgroundMedia.qml'), 'utf8')

// Extract one block by taking everything from the marker to the line whose
// closing brace sits at the block's own indentation: a `function ...` marker
// opens its brace on the marker line, while an `id: ...` marker is the first
// line inside a brace opened two spaces shallower. Keeps the assertions
// below tolerant of formatting inside the block.
function blockAfter(source, marker, description) {
  const start = source.indexOf(marker)
  if (start < 0) fail(description, `marker not found: ${marker}`)
  const indent = source.slice(source.lastIndexOf('\n', start) + 1, start)
  const closerIndent = marker.startsWith('function') ? indent : indent.slice(0, -2)
  const rest = source.slice(start)
  const end = rest.indexOf('\n' + closerIndent + '}')
  if (end < 0) fail(description, `unterminated block for marker: ${marker}`)
  pass(description)
  return rest.slice(0, end)
}

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

assert(
  (backgroundQml.match(/BackgroundResolver\s*\{/g) || []).length === 2,
  'each background panel resolves displayed and incoming layers with its own resolvers'
)

const displayedResolver = blockAfter(backgroundQml, 'id: displayedResolver', 'displayed resolver block exists')
const incomingResolver = blockAfter(backgroundQml, 'id: incomingResolver', 'incoming resolver block exists')

assert(
  /canonicalPath:\s*root\.displayedBackground\b/.test(displayedResolver),
  'displayed resolver keys on the displayed canonical'
)

assert(
  /canonicalPath:\s*root\.currentBackground\s*!==\s*""\s*\?\s*root\.currentBackground\s*:\s*root\.incomingBackground/.test(incomingResolver),
  'incoming layer resolves against the final canonical, not the transition snapshot'
)

assert(
  (backgroundQml.match(/screenWidth:\s*panel\.modelData\.width/g) || []).length === 2 &&
    (backgroundQml.match(/screenHeight:\s*panel\.modelData\.height/g) || []).length === 2,
  'every resolver uses its own panel screen dimensions'
)

assert(
  /refreshToken:\s*root\.backgroundVersion/.test(incomingResolver) &&
    /refreshToken:\s*root\.displayedVersion/.test(displayedResolver),
  'a forced transition with an unchanged canonical path still re-resolves both layers'
)

assert(
  (backgroundQml.match(/displayedVersion\s*\+=\s*1/g) || []).length >= 2,
  'displayed re-resolution is requested on every displayedBackground assignment (instant set and reveal end)'
)

const baseBlock = blockAfter(backgroundQml, 'id: base', 'base layer block exists')
const incomingFrameBlock = blockAfter(backgroundQml, 'id: incomingFrame', 'incoming frame block exists')

assert(
  /^\s*BackgroundMedia\s*\{\s*$/m.test(backgroundQml) &&
    /^\s*WallpaperImage\s*\{\s*$/m.test(backgroundQml) &&
    baseBlock.startsWith('id: base') &&
    incomingFrameBlock.startsWith('id: incomingFrame') &&
    !/\bImage\s*\{/.test(backgroundQml) &&
    /^\s*WallpaperImage\s*\{\s*$/m.test(mediaQml),
  'still backgrounds render responsively through the shared still media wrapper'
)

// Per-panel incoming source lock: pixels and incoming metadata commit once
// per transition and remain fixed for the whole reveal.
const lockBlock = blockAfter(backgroundQml, 'function lockIncoming', 'incoming lock function exists')
assert(
  /if\s*\(incomingLockedVersion\s*===\s*root\.backgroundVersion\)\s*return/.test(lockBlock) &&
    /incomingLockedVersion\s*=\s*root\.backgroundVersion/.test(lockBlock),
  'a panel locks its incoming source at most once per backgroundVersion'
)

assert(
  /framePath:\s*panel\.incomingPath \|\| root\.preparedBackground/.test(incomingFrameBlock) &&
    /fill:\s*panel\.incomingFill\b/.test(incomingFrameBlock) &&
    /backdrop:\s*panel\.incomingBackdrop\b/.test(incomingFrameBlock),
  'incoming pixels and meta come from the per-panel lock, not live resolver bindings'
)

assert(
  /backdrop:\s*panel\.lastDisplayedBackdrop\b/.test(baseBlock) &&
    /lastDisplayedBackdrop\s*=\s*backdrop/.test(displayedResolver) &&
    /property string backdrop:\s*"solid"/.test(mediaQml) &&
    /backdrop:\s*root\.backdrop/.test(mediaQml),
  'displayed and transition layers preserve the resolved backdrop mode'
)

assert(
  /usedFallback \|\| resolvedPath === canonicalPath \? root\.incomingBackground : resolvedPath/.test(incomingResolver),
  'a failed incoming resolve falls back to the handed-down snapshot pixels'
)

assert(
  !backgroundQml.includes('incomingFallbackTimer') &&
    /lockIncoming\([\s\S]*fill, backdrop, fillColor, focalX, focalY/.test(incomingResolver),
  'a slow resolve retains the outgoing image until incoming metadata is available'
)

assert(
  /incomingLockedVersion\s*=\s*-1/.test(backgroundQml),
  'arming a transition resets the per-panel lock'
)

// Join tolerance: a panel whose incoming frame lands mid-animation still
// raises its mask instead of being excluded for the rest of the reveal.
const maybeStart = blockAfter(backgroundQml, 'function maybeStartReveal', 'maybeStartReveal exists')
assert(
  /root\.revealProgress\s*>=\s*1/.test(maybeStart) &&
    !/revealProgress\s*!==\s*0/.test(maybeStart),
  'a panel becoming ready mid-animation still joins the reveal at the current mask spread'
)

// Source continuity: the shared incoming/old sources are only cleared once
// every panel base has settled on the final background.
const finishBlock = blockAfter(backgroundQml, 'function maybeFinishTransition', 'maybeFinishTransition exists')
assert(
  /panelVariants\.instances/.test(finishBlock) &&
    /baseSettled\(\)/.test(finishBlock) &&
    /incomingBackground\s*=\s*""/.test(finishBlock) &&
    /oldBackground\s*=\s*""/.test(finishBlock),
  'the global transition clear waits for every panel base to settle'
)

assert(
  /onStatusChanged:\s*root\.maybeFinishTransition\(\)/.test(baseBlock) &&
    /root\.maybeFinishTransition\(\)/.test(displayedResolver) &&
    !/root\.incomingBackground\s*=\s*""/.test(baseBlock),
  'no single panel base clears the shared sources on its own'
)

const settledBlock = blockAfter(backgroundQml, 'function baseSettled', 'baseSettled exists')
assert(
  /displayedResolver\.ready/.test(settledBlock) &&
    /lastDisplayedCanonical\s*!==\s*root\.displayedBackground/.test(settledBlock) &&
    /base\.status === Image\.Ready \|\| base\.status === Image\.Error/.test(settledBlock),
  'a panel settles only once its own resolve published for the final canonical and the decode is done'
)

const resolverQml = fs.readFileSync(path.join(root, 'shell/Ui/BackgroundResolver.qml'), 'utf8')

assert(
  /"omarchy-theme-bg-resolve",\s+"--screen",\s*Math\.round\(screenWidth \* devicePixelRatio\)\s*\+\s*"x"\s*\+\s*Math\.round\(screenHeight \* devicePixelRatio\),\s+"--canonical",\s*canonicalPath/.test(resolverQml),
  'background resolver asks omarchy-theme-bg-resolve for the per-screen resolution'
)

assert(
  /property int refreshToken/.test(resolverQml) &&
    /onRefreshTokenChanged:\s*requestResolve\(\)/.test(resolverQml),
  'resolvers re-resolve when their refresh token bumps even if inputs are string-identical'
)

assert(
  /property string backdrop:\s*"solid"/.test(resolverQml) &&
    /\["solid",\s*"edge",\s*"blur"\]\.indexOf\(meta\.backdrop\)/.test(resolverQml),
  'background resolver defaults backdrop metadata safely and accepts the documented modes'
)

const requestBlock = blockAfter(resolverQml, 'function requestResolve', 'requestResolve exists')
const startBlock = blockAfter(resolverQml, 'function startResolve', 'startResolve exists')
const invalidGuard = /if\s*\(!canonicalPath\s*\|\|\s*screenWidth\s*<=\s*0\s*\|\|\s*screenHeight\s*<=\s*0\)/

assert(
  invalidGuard.test(requestBlock) &&
    /resolvePending\s*=\s*false[\s\S]*publishFallback\(requestSeq\)/.test(requestBlock),
  'invalid resolver inputs clear any queued relaunch before publishing the fallback'
)

assert(
  invalidGuard.test(startBlock) &&
    /publishFallback\(requestSeq\)/.test(startBlock),
  'a relaunch re-validates inputs instead of spawning a resolve with an empty canonical'
)

const wallpaperQml = fs.readFileSync(path.join(root, 'shell/Ui/WallpaperImage.qml'), 'utf8')

assert(
  wallpaperQml.includes('return Image.PreserveAspectCrop') &&
    /property string fill:\s*"crop"/.test(wallpaperQml) &&
    /property string backdrop:\s*"solid"/.test(wallpaperQml),
  'wallpaper image defaults to the historical centered crop rendering'
)

assert(
  /backdrop\s*===\s*"blur"/.test(wallpaperQml) &&
    /fillMode:\s*Image\.PreserveAspectCrop/.test(wallpaperQml) &&
    /blurEnabled:\s*true/.test(wallpaperQml) &&
    /opacity:\s*0\.35/.test(wallpaperQml),
  'blur backdrop paints a quiet cover copy beneath the unchanged foreground image'
)

assert(
  /capActive:\s*root\.useSourceSizeCap\s*&&\s*root\.fill\s*!==\s*"center"\s*&&\s*root\.fill\s*!==\s*"tile"/.test(wallpaperQml),
  'the source-size cap never applies to center or tile, which paint at natural size'
)

const sourceSizeWidth = (wallpaperQml.match(/sourceSize\.width:\s*\{[\s\S]*?\n\s*\}/) || [''])[0]
assert(
  /naturalAspect\s*>\s*image\.physWidth\s*\/\s*image\.physHeight\s*\?\s*Math\.round\(image\.physHeight\s*\*\s*image\.naturalAspect\)\s*:\s*image\.physWidth/.test(wallpaperQml) &&
    /root\.manualCrop/.test(sourceSizeWidth),
  'the manual focal crop decodes at the cover dimensions instead of fit-within'
)

assert(
  /onSourceChanged:\s*naturalAspect\s*=\s*0/.test(wallpaperQml),
  'a new source relearns the natural aspect before re-deriving the cover decode size'
)

// Execute the production QML functions to cover channel order and physical
// resolver arguments, including fractional scale and a scale-only change.
const vm = require('vm')
const context = vm.createContext({
  Color: { background: 'fallback' },
  Qt: { rgba: (...channels) => channels },
  canonicalPath: '/theme/art.svg', screenWidth: 1920, screenHeight: 1080,
  devicePixelRatio: 2, requestSeq: 1, resolveProc: {}, resolvePending: false
})
vm.runInContext(blockAfter(resolverQml, 'function parseFillColor', 'color parser exists') + '\n}', context)
assertDeepEqual(Array.from(context.parseFillColor('#ff000080')), [1, 0, 0, 128 / 255], 'RGBA metadata renders translucent red')
assertDeepEqual(Array.from(context.parseFillColor('#12345600')), [18 / 255, 52 / 255, 86 / 255, 0], 'zero alpha remains transparent')
assertDeepEqual(Array.from(context.parseFillColor('#abcdef')), [171 / 255, 205 / 255, 239 / 255, 1], 'six-digit colors remain opaque')
assertEqual(context.parseFillColor('#bad'), 'fallback', 'invalid colors retain the theme fallback')
vm.runInContext(startBlock + '\n}', context)
context.startResolve()
assertEqual(context.resolveProc.command[2], '3840x2160', 'scale 2 resolves SVGs at physical output resolution')
context.devicePixelRatio = 1.25
context.startResolve()
assertEqual(context.resolveProc.command[2], '2400x1350', 'fractional scale resolves at physical output resolution')
assert(/property real devicePixelRatio:\s*Screen.devicePixelRatio/.test(resolverQml) &&
  /onDevicePixelRatioChanged:\s*requestResolve\(\)/.test(resolverQml),
  'every resolver follows its window screen scale and re-resolves on scale changes')

const blurActive = wallpaperQml.match(/blurBackdropActive: (.*)/)[1]
const backdropSource = wallpaperQml.match(/source: (.*)/)[1]
for (const fill of ['crop', 'fit', 'center', 'tile']) {
  for (const backdrop of ['solid', 'edge', 'blur']) {
    const surface = { fill, backdrop, path: '/art.png', renderPath: '/art.png', sourceVersion: 0, decodeReady: true }
    const scope = vm.createContext({ ...surface, root: surface, Util: { fileUrl: p => 'file://' + p } })
    surface.blurBackdropActive = vm.runInContext(blurActive, scope)
    assertEqual(vm.runInContext(backdropSource, scope) !== '', fill !== 'crop' && backdrop === 'blur',
      `${fill}/${backdrop} only loads the backdrop when needed`)
  }
}
assert(/sourceSize.width:\s*root.useSourceSizeCap \? image.physWidth : 0/.test(wallpaperQml) &&
  /sourceSize.height:\s*root.useSourceSizeCap \? image.physHeight : 0/.test(wallpaperQml),
  'active lock blur backdrops also cap their decode to the physical screen')
assert(!backgroundQml.includes('id: oldResolver') && !backgroundQml.includes('id: oldFrame') &&
  /path:\s*panel.lastDisplayedPath/.test(baseBlock) && /cached:\s*true/.test(baseBlock),
  'outgoing transitions retain the decoded panel variant without loading the canonical snapshot')

const outgoing = vm.createContext({
  currentBackground: '/old/art.svg', displayedBackground: '/old/art.svg',
  displayedVersion: 3, backgroundVersion: 3, preparedBackground: '', lastTransitionPath: '',
  isVideo: () => false,
  revealAnimation: { stop() {} },
  preparedBackgroundTimer: { stop() {} }, requestNativeSize() {}
})
vm.runInContext(blockAfter(backgroundQml, 'function transitionBackground(', 'transition function exists') + '\n}', outgoing)
outgoing.transitionBackground('/snapshots/canonical.svg', '/snapshots/new.png', '/new/art.svg', false, true)
assertEqual(outgoing.displayedBackground, '/old/art.svg', 'theme snapshots leave the per-panel base source intact during reveal')
assertEqual(outgoing.displayedVersion, 3, 'arming a theme transition never requests a fresh decode of the outgoing wallpaper')

const lockQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/LockView.qml'), 'utf8')
assert(
  /backdrop:\s*root\.resolution\.backdrop/.test(lockQml),
  'lock screen renders the same resolved backdrop as the desktop'
)
const themeSet = fs.readFileSync(path.join(root, 'bin/omarchy-theme-set'), 'utf8')

// The next background decodes while the theme stages, rather than after the
// transition arrives: WebP decodes take as long at screen size as at native.
assert(
  /function prepare\(path: string\): void \{\s*root\.prepareBackground\(path\)/.test(backgroundQml) &&
    backgroundQml.includes('readonly property string framePath: panel.incomingPath || root.preparedBackground'),
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
assert(
  /constrainDecode: true\s*decodeSize: panel\.decodeSize\(panel\.lastDisplayedPath\)/.test(baseBlock) &&
    /constrainDecode: true\s*decodeSize: panel\.decodeSize\(framePath\)/.test(incomingFrameBlock) &&
    wallpaperQml.includes('root.renderPath && root.decodeReady ? Util.fileUrl'),
  'both wallpaper layers wait for the screen and native sizes before decoding'
)
assert(
  /function requestNativeSize\(path\) \{\s*if \(!path \|\| isVideo\(path\)/.test(backgroundQml) &&
    /function prepareBackground[\s\S]*?requestNativeSize\(path\)/.test(backgroundQml),
  'background never probes videos and probes a prepared frame ahead of its transition'
)

const decode = vm.createContext({
  sized: true, decodeWidth: 3840, decodeHeight: 2160,
  root: { nativeSizes: { '/small.png': { width: 640, height: 480 }, '/large.png': { width: 7680, height: 4320 } } },
  Qt: { size: (width, height) => ({width, height}) }
})
vm.runInContext(blockAfter(backgroundQml, 'function decodeSize', 'decode size function exists') + '\n}', decode)
assertEqual(decode.decodeSize('/small.png').width, 640, 'a small wallpaper keeps its native decode size')
assertEqual(decode.decodeSize('/large.png').width, 3840, 'a large wallpaper decodes only at the screen size')
assertEqual(decode.decodeSize('/pending.png').width, 0, 'an unprobed wallpaper waits instead of decoding at full size')
decode.sized = false
assertEqual(decode.decodeSize('/large.png').width, 0, 'an unsized panel waits before decoding')

const locked = vm.createContext({
  incomingLockedVersion: -1,
  root: { backgroundVersion: 9, requestNativeSize() {} },
  incomingFallbackTimer: { stop() {} },
  starts: 0
})
vm.runInContext('function maybeStartReveal() { starts += 1 }\n' + lockBlock + '\n}', locked)
locked.lockIncoming('/prepared.png', 'fit', 'blur', '#123456', 0.6, 0.4)
assertEqual(locked.starts, 1, 'a frame decoded during prepare starts the reveal when its metadata locks')
locked.lockIncoming('/late.png', 'crop', 'solid', '#ffffff', 0.5, 0.5)
assertEqual(locked.incomingPath, '/prepared.png', 'a late resolution cannot replace a locked transition source')
assertEqual(locked.starts, 1, 'a locked transition is only started once')

const settling = vm.createContext({
  root: { displayedBackground: '/final.png' },
  displayedResolver: { ready: true }, lastDisplayedCanonical: '/final.png',
  base: { status: 0 }, Image: { Null: 0, Loading: 1, Ready: 2, Error: 3 }
})
vm.runInContext(settledBlock + '\n}', settling)
assertEqual(settling.baseSettled(), false, 'a final frame awaiting its header keeps the incoming layer visible')
settling.base.status = settling.Image.Loading
assertEqual(settling.baseSettled(), false, 'a decoding final frame keeps the incoming layer visible')
settling.base.status = settling.Image.Ready
assertEqual(settling.baseSettled(), true, 'a decoded final frame can release its incoming layer')
const renderPathExpression = wallpaperQml.match(/renderPath: (.*)/)[1]
for (const filename of ['/prepare.svg', '/FAILED.SVG']) {
  assertEqual(vm.runInNewContext(renderPathExpression, {path: filename}), '', 'raw SVG cannot enter Qt image loading: ' + filename)
}
assertEqual(vm.runInNewContext(renderPathExpression, {path: '/cache/render.png'}), '/cache/render.png', 'bounded SVG raster enters Qt image loading')

JS
