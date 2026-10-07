#!/bin/bash
source "$(dirname "$0")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const backgroundQml = fs.readFileSync(path.join(root, 'shell/plugins/background/Background.qml'), 'utf8')
const samplerQml = fs.readFileSync(path.join(root, 'shell/plugins/background/BarStripSampler.qml'), 'utf8')

// The bar's strip is read from an image already decoded for display: never
// from a video, matched by the image's own source, and a theme switch's
// snapshot frame stands for its final path. Anything else answers "" so the
// bar decodes the file instead.
assert(
  /function sampleBarStrip\(position, barSize, callback\) \{[\s\S]*?if \(!currentBackground \|\| isVideo\(currentBackground\)\) \{\s*callback\(""\)/.test(backgroundQml) &&
    /if \(root\.currentBackground === path && shows\(incomingFrame, root\.incomingBackground\)\) return incomingFrame/.test(backgroundQml) &&
    /decodeURIComponent\(String\(image\.source\)\) === decodeURIComponent\(root\.imageUrl\(path\)\)/.test(backgroundQml) &&
    /id: stripRequestTimer[\s\S]*?root\.finishStripRequest\(root\.stripRequest, ""\)/.test(backgroundQml),
  'background samples the bar strip only from decoded stills, with a timeout'
)

// The grab arrives in physical pixels, and the software renderer cannot grab.
assert(
  /ctx\.drawImage\(current\.url, 0, 0, w, h\)/.test(samplerQml) &&
    /available: GraphicsInfo\.api !== GraphicsInfo\.Software/.test(samplerQml),
  'bar strip sampler scales the grab to the strip and skips the software renderer'
)

// A resized canvas only has a buffer of its new size once it paints; reading
// before that returned black. Nothing it drew may stay visible over a video.
assert(
  /onPaint: root\.average\(\)/.test(samplerQml) &&
    /getImageData\(0, 0, w, h\)\.data\s*(\/\/[^\n]*\s*)*ctx\.clearRect\(0, 0, w, h\)/.test(samplerQml),
  'bar strip sampler reads the canvas only when it paints, then clears it'
)

// ImageMagick flattens a transparent wallpaper over white; the sampler must
// weigh transparency the same way or the two paths choose differently.
assert(
  /var alpha = data\[i \+ 3\] \/ 255\s*var white = 255 \* \(1 - alpha\)\s*red \+= data\[i\] \* alpha \+ white/.test(samplerQml),
  'bar strip sampler counts transparent pixels as white, like the file path'
)

// transitionBackground() moves currentBackground before incomingBackground; a
// waiting strip request must not sample in between, or it takes the previous
// transition's incoming frame for the new wallpaper.
assert(
  /function onCurrentBackgroundChanged\(\) \{\s*Qt\.callLater\(panel\.maybeSampleStrip\)/.test(backgroundQml),
  'background samples a waiting strip request only once the transition state has moved'
)

// Run the sampler's own functions against stand-ins for the strip grab and the
// canvas, so the order in which grabs and image loads land can be controlled.
function samplerFunctions() {
  const names = ['barRect', 'sample', 'average', 'finish']
  const sources = names.map(name => {
    const start = samplerQml.indexOf(`function ${name}(`)
    let depth = 0
    for (let i = samplerQml.indexOf('{', start); i < samplerQml.length; i++) {
      if (samplerQml[i] === '{') depth++
      if (samplerQml[i] === '}' && --depth === 0) return samplerQml.slice(start, i + 1)
    }
  })
  const grabs = []
  const requested = new Set()
  const loaded = new Set()
  const colours = {}
  const strip = {
    scheduleUpdate() {},
    grabToImage(callback) { grabs.push(callback); return true }
  }
  let drawn = ''
  const canvas = {
    loadImage: url => requested.add(url),
    isImageLoaded: url => loaded.has(url),
    // As in Qt, unloading also cancels a load still in progress.
    unloadImage: url => { requested.delete(url); loaded.delete(url) },
    requestPaint: () => fns.average(),
    getContext: () => ({
      clearRect() {},
      drawImage(url) { drawn = url },
      getImageData(x, y, w, h) {
        const data = new Uint8ClampedArray(w * h * 4)
        for (let i = 0; i < data.length; i += 4) data.set([...colours[drawn], 255], i)
        return { data }
      }
    })
  }
  const root = { request: null, available: true }
  const Qt = { rect: (x, y, width, height) => ({ x, y, width, height }) }
  const fns = new Function('root', 'strip', 'canvas', 'Qt',
    `with (root) { ${sources.join('\n')}\nreturn { sample, average, finish } }`)(root, strip, canvas, Qt)
  // The grab for request i returns, then its image finishes loading; the
  // canvas paints either way.
  fns.grab = (i, url, colour) => { colours[url] = colour; grabs[i]({ url }) }
  fns.load = url => { if (requested.has(url)) loaded.add(url); canvas.requestPaint() }
  fns.requested = requested
  return fns
}

{
  const sampler = samplerFunctions()
  const image = { width: 100, height: 50 }
  const answers = []
  sampler.sample(image, 'top', 10, value => answers.push(['A', value]))
  sampler.grab(0, 'grab-a', [255, 255, 255])
  sampler.sample(image, 'top', 10, value => answers.push(['B', value]))
  sampler.load('grab-a')
  assertDeepEqual(answers, [], 'bar strip sampler ignores the image of a request it replaced')
  assert(!sampler.requested.has('grab-a'), 'bar strip sampler unloads the grab of a request it replaced')
  sampler.grab(1, 'grab-b', [0, 0, 0])
  sampler.load('grab-b')
  assertDeepEqual(answers, [['B', '#000000']], 'bar strip sampler answers the newer request from its own grab')
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
JS
