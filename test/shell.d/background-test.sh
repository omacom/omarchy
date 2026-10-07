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
  backgroundQml.includes('property int readyPanels: 0') &&
    backgroundQml.includes('id: revealWaitTimer') &&
    /function panelReady\(panel\)[\s\S]*readyPanels \+= 1[\s\S]*if \(readyPanels >= Quickshell\.screens\.length\) startReveal\(\)/.test(backgroundQml),
  'background waits for all screen panels to load before starting reveal animation'
)
assert(
  /function maybeStartReveal\(\)[\s\S]*root\.revealProgress >= 1[\s\S]*root\.panelReady\(panel\)/.test(backgroundQml),
  'late screens set maskReady and join running reveal animation'
)
JS
