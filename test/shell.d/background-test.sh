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
    backgroundQml.includes('readonly property string framePath: panel.oriented(root.incomingBackground || root.preparedBackground)'),
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
  /path: panel\.oriented\(root\.displayedBackground\)\s*constrainDecode: true\s*decodeSize: panel\.decodeSize\(path\)/.test(backgroundQml) &&
    mediaQml.includes('source: !root.constrainDecode || root.decodeSize.width > 0 ? root.imageUrl : ""') &&
    mediaQml.includes('sourceSize.width: root.constrainDecode ? root.decodeSize.width : (root.version > 0 ? width : 0)'),
  'the displayed wallpaper waits for and decodes at the same size'
)
assert(
  /function requestNativeSize\(path, refresh\) \{\s*if \(!path \|\| isVideo\(path\)/.test(backgroundQml) &&
    /function prepareBackground[\s\S]*?requestNativeSize\(path\)/.test(backgroundQml),
  'background never probes videos and probes a prepared frame ahead of its transition'
)
JS

# Portrait twins: a theme switch snapshots the twin next to its plain snapshot,
# and the shell picks it per screen only once the probe has found it.
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
source <(awk '/^(is_video_path|snapshot_background_path|remove_background_snapshots)\(\) \{/ { c=1 } c { print } c && /^}$/ { c=0 }' "$ROOT/bin/omarchy-theme-set")
BACKGROUND_TRANSITION_CACHE="$test_tmp/cache/background-transitions"
mkdir -p "$test_tmp/theme/backgrounds/portrait"
printf 'plain\n' >"$test_tmp/theme/backgrounds/1-moonrise.png"
printf 'twin\n' >"$test_tmp/theme/backgrounds/portrait/1-moonrise.png"
printf 'lonely\n' >"$test_tmp/theme/backgrounds/2-lonely.png"
mkdir -p "$test_tmp/config/omarchy/backgrounds/tokyo/portrait" "$test_tmp/Pictures/portrait"
printf 'user\n' >"$test_tmp/config/omarchy/backgrounds/tokyo/3-user.png"
printf 'user twin\n' >"$test_tmp/config/omarchy/backgrounds/tokyo/portrait/3-user.png"
printf 'photo\n' >"$test_tmp/Pictures/beach.png"
printf 'other photo\n' >"$test_tmp/Pictures/portrait/beach.png"
twin_snapshot=$(snapshot_background_path "$test_tmp/theme/backgrounds/1-moonrise.png" next)
lonely_snapshot=$(snapshot_background_path "$test_tmp/theme/backgrounds/2-lonely.png" previous)
[[ $(cat "$BACKGROUND_TRANSITION_CACHE/portrait/${twin_snapshot##*/}" 2>/dev/null) == twin ]] || fail "a theme switch snapshots the portrait twin next to its plain snapshot"
[[ ! -e $BACKGROUND_TRANSITION_CACHE/portrait/${lonely_snapshot##*/} ]] || fail "a background without a twin snapshots no twin"
user_snapshot=$(snapshot_background_path "$test_tmp/config/omarchy/backgrounds/tokyo/3-user.png" user)
[[ $(cat "$BACKGROUND_TRANSITION_CACHE/portrait/${user_snapshot##*/}" 2>/dev/null) == "user twin" ]] || fail "a user background snapshots its portrait twin"
photo_snapshot=$(snapshot_background_path "$test_tmp/Pictures/beach.png" photo)
[[ ! -e $BACKGROUND_TRANSITION_CACHE/portrait/${photo_snapshot##*/} ]] || fail "a picture outside a backgrounds folder snapshots no twin"
remove_background_snapshots "$twin_snapshot" "$lonely_snapshot" "$user_snapshot" "$photo_snapshot"
[[ -z $(find "$BACKGROUND_TRANSITION_CACHE" -type f) ]] || fail "removing snapshots removes their twins"
pass "theme switch snapshots and removes portrait twins with their backgrounds"

run_node_test <<'JS'
const fs = require('fs')

const backgroundQml = fs.readFileSync(path.join(root, 'shell/plugins/background/Background.qml'), 'utf8')
const extract = (name) => backgroundQml.match(new RegExp(`function ${name}\\([^)]*\\) \\{[\\s\\S]*?\\n {2,6}\\}`))[0]
const isVideo = (p) => /\.(mp4|m4v|mov|webm|mkv|avi)$/i.test(p)
const twinPath = new Function('isVideo', `${extract('twinPath')}; return twinPath`)(isVideo)
const oriented = (portrait, nativeSizes, p) =>
  new Function('portrait', 'root', `${extract('oriented')}; return oriented`)(portrait, { twinPath, nativeSizes })(p)

const plain = '/theme/backgrounds/1-moonrise.png'
const twin = '/theme/backgrounds/portrait/1-moonrise.png'
const snapshot = '/cache/background-transitions/next-42.png'
assertEqual(twinPath(plain), twin, 'a theme background has its twin under backgrounds/portrait/')
assertEqual(twinPath(snapshot), '/cache/background-transitions/portrait/next-42.png', 'a theme switch snapshot has its twin under the snapshot folder')
assertEqual(twinPath('/home/me/.config/omarchy/backgrounds/tokyo/3-user.png'), '/home/me/.config/omarchy/backgrounds/tokyo/portrait/3-user.png', 'a user background has its twin under its own portrait/')
assertEqual(twinPath('/home/me/Pictures/beach.png'), '', 'a picture outside a backgrounds folder has no twin')
assertEqual(twinPath('/theme/backgrounds/3-clip.mp4'), '', 'a video has no twin')

const found = { [twin]: { width: 1440, height: 2560, found: true } }
const missing = { [twin]: { width: 0, height: 0, found: false } }
assertEqual(oriented(true, found, plain), twin, 'a portrait screen shows a twin the probe found')
assertEqual(oriented(true, missing, plain), plain, 'a portrait screen keeps the plain file when the twin is missing')
assertEqual(oriented(true, {}, plain), '', 'a portrait screen waits for the twin probe before loading')
assertEqual(oriented(false, found, plain), plain, 'a landscape screen keeps the plain file')
assertEqual(oriented(false, {}, '/home/me/Pictures/portrait/beach.png'), '/home/me/Pictures/portrait/beach.png', 'a landscape screen never rewrites a path')

assert(
  backgroundQml.includes('path: panel.oriented(root.displayedBackground)') &&
    backgroundQml.includes('readonly property string framePath: panel.oriented(root.oldBackground)') &&
    backgroundQml.includes('readonly property string framePath: panel.oriented(root.incomingBackground || root.preparedBackground)'),
  'base, old and incoming frames resolve the portrait twin per screen'
)
assert(
  /function requestNativeSize\(path, refresh\) \{[\s\S]*?queueSizeProbe\(twinPath\(path\), refresh\)/.test(backgroundQml) &&
    backgroundQml.includes('paths = paths.concat(paths.map(twinPath))'),
  'background probes and keeps the twin of every wallpaper in play'
)
// A theme switch keeps the durable path but swaps the file behind it, so the
// twin is probed again instead of trusting the previous theme's answer.
const probes = { nativeSizes: { [twin]: { found: false }, [plain]: {} }, sizeQueue: [], probeNextSize() {}, isVideo, twinPath }
new Function('ctx', `with (ctx) { ${extract('requestNativeSize')}; ${extract('queueSizeProbe')}; requestNativeSize('${plain}', false); requestNativeSize('${plain}', true) }`)(probes)
assertEqual(probes.sizeQueue.join(' '), `${plain} ${twin}`, 'a theme switch probes a known wallpaper and its twin again')
assert(/requestNativeSize\(finalPath, force\)/.test(backgroundQml), 'theme transitions refresh the durable path they land on')

assert(
  /function finishTransition\(\) \{[\s\S]*?panels\[i\]\.sized && !panels\[i\]\.baseReady\) return/.test(backgroundQml),
  'the incoming frame stays up until every screen has its final wallpaper'
)
JS
