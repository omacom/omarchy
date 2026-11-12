#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command magick
require_command ffmpeg

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

export PATH="$ROOT/bin:$PATH"

light_top="$TMPDIR/light-top.png"
dark_top="$TMPDIR/dark-top.png"

magick -size 100x100 xc:'#202020' -fill '#f5f5f5' -draw 'rectangle 0,0 99,19' "$light_top"
magick -size 100x100 xc:'#f5f5f5' -fill '#202020' -draw 'rectangle 0,0 99,19' "$dark_top"

result=$(HOME="$TMPDIR" omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$light_top" --screen 100x100)
[[ $result == "#101010" ]] || fail "transparent bar text switches to background color on light wallpaper" "expected #101010, got $result"
pass "transparent bar text switches to background color on light wallpaper"

result=$(HOME="$TMPDIR" omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$dark_top" --screen 100x100)
[[ $result == "#ffffff" ]] || fail "transparent bar text keeps text color on dark wallpaper" "expected #ffffff, got $result"
pass "transparent bar text keeps text color on dark wallpaper"

result=$(HOME="$TMPDIR" omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$TMPDIR/missing.png" --screen 100x100)
[[ $result == "#ffffff" ]] || fail "transparent bar text falls back to text color when sampling fails" "expected #ffffff, got $result"
pass "transparent bar text falls back to text color when sampling fails"

# Fine detail must be averaged, not point-sampled. On a quarter-white stripe
# pattern at four times screen size, point sampling lands on the white stripes
# and keeps dark text on a dark bar. The dark text color is also the fallback, so
# only a finished, averaged sample switches to the light background color.
dark_stripes="$TMPDIR/dark-stripes.png"
magick -size 4x1 xc:black -fill white -draw 'point 1,0' "$TMPDIR/stripe.png"
magick -size 400x100 tile:"$TMPDIR/stripe.png" "$dark_stripes"

result=$(HOME="$TMPDIR" omarchy-bar-text-color top 10 '#101010' '#ffffff' --background "$dark_stripes" --screen 100x25)
[[ $result == "#ffffff" ]] || fail "transparent bar text averages fine wallpaper detail" "expected #ffffff, got $result"
pass "transparent bar text averages fine wallpaper detail"

# A video background must be sampled one frame at a time. Reading the whole file
# emits a value per frame, which parses as nothing and silently falls back —
# and decodes the entire wallpaper to find that out.
light_top_video="$TMPDIR/light-top.mp4"
ffmpeg -y -f lavfi -i "testsrc=size=640x360:rate=10:duration=2" \
  -vf "drawbox=x=0:y=0:w=640:h=40:color=0xf5f5f5:t=fill" \
  -c:v libx264 -preset ultrafast -pix_fmt yuv420p "$light_top_video" -loglevel error

result=$(HOME="$TMPDIR" omarchy-bar-text-color top 40 '#ffffff' '#101010' --background "$light_top_video" --screen 640x360)
[[ $result == "#101010" ]] || fail "transparent bar text samples one frame of a video wallpaper" "expected #101010, got $result"
pass "transparent bar text samples one frame of a video wallpaper"

# Responsive background sampling.
(
  require_command magick

  test_tmp=$(mktemp -d)
  trap 'rm -rf "$test_tmp"' EXIT
  home="$test_tmp/home"
  backgrounds="$home/.local/state/omarchy/current/theme/backgrounds"
  mkdir -p "$backgrounds"

  sample() {
    HOME="$home" PATH="$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-bar-text-color" \
      top 10 '#ffffff' '#000000' --background "$backgrounds/test.png" --screen 100x100 "$@"
  }

  # Focal extremes select entirely different cover windows, so a centered
  # approximation would choose the wrong foreground on one of them.
  magick -size 300x100 xc:black -fill white -draw 'rectangle 0,0 99,99' "$backgrounds/test.png"
  printf '[defaults]\nfocal = "0 0.5"\n' >"$backgrounds/backgrounds.toml"
  [[ $(sample) == "#000000" ]] || fail "left focal samples the white crop"
  printf '[defaults]\nfocal = "1 0.5"\n' >"$backgrounds/backgrounds.toml"
  [[ $(sample) == "#ffffff" ]] || fail "right focal samples the black crop"
  magick -size 100x300 xc:black -fill white -draw 'rectangle 0,0 99,99' "$backgrounds/test.png"
  printf '[defaults]\nfocal = "0.5 0"\n' >"$backgrounds/backgrounds.toml"
  [[ $(sample) == "#000000" ]] || fail "top focal samples the white crop"
  printf '[defaults]\nfocal = "0.5 1"\n' >"$backgrounds/backgrounds.toml"
  [[ $(sample) == "#ffffff" ]] || fail "bottom focal samples the black crop"
  pass "bar sampling follows horizontal and vertical focal windows"

  # The fit foreground leaves the top bar in a letterbox. A white cover at 35%
  # opacity lightens the configured gray enough to change the contrast winner.
  magick -size 200x20 xc:white "$backgrounds/test.png"
  printf '[defaults]\nfill = "fit"\nfill_color = "#555555"\n' >"$backgrounds/backgrounds.toml"
  [[ $(sample) == "#ffffff" ]] || fail "solid letterbox samples its declared fill"
  printf 'backdrop = "blur"\n' >>"$backgrounds/backgrounds.toml"
  [[ $(sample) == "#000000" ]] || fail "blur letterbox samples the subdued cover"
  pass "bar sampling includes the blurred cover behind fitted images"

  # Resolver colors use CSS RGBA, including transparent padding over the
  # compositor's black background. Alpha must affect the sampled brightness.
  while read -r color expected; do
    printf '[defaults]\nfill = "fit"\nfill_color = "%s"\n' "$color" >"$backgrounds/backgrounds.toml"
    [[ $(sample) == $expected ]] || fail "RGBA padding $color selects $expected"
  done <<'COLORS'
#ffffffff #000000
#000000ff #ffffff
#ff0000ff #000000
#ffffff40 #ffffff
#ffffff00 #ffffff
COLORS
  pass "bar sampling respects RGBA channel order and padding opacity"

  # Focal affects crop foregrounds, but the shell centers its blurred cover.
  # Its black center keeps the padded bar dark even when the left edge is white.
  magick -size 1000x100 xc:black -fill white -draw 'rectangle 0,0 199,99' "$backgrounds/test.png"
  for focal in "0 0.5" "1 0.5"; do
    printf '[defaults]\nfill = "fit"\nbackdrop = "blur"\nfill_color = "#555555"\nfocal = "%s"\n' "$focal" >"$backgrounds/backgrounds.toml"
    [[ $(sample) == "#ffffff" ]] || fail "blurred letterbox keeps its centered crop with focal $focal"
  done
  pass "blurred bar sampling stays centered independently of the foreground focal"

  # Same canonical, two geometries, independent variants and contrast results.
  magick -size 100x100 xc:black "$backgrounds/test.png"
  magick -size 200x100 xc:white "$backgrounds/test@wide.png"
  printf '[defaults]\nfill = "crop"\n' >"$backgrounds/backgrounds.toml"
  [[ $(sample) == "#ffffff" ]] || fail "square display samples the black canonical"
  wide=$(HOME="$home" PATH="$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-bar-text-color" top 20 '#ffffff' '#000000' --background "$backgrounds/test.png" --screen 200x100 --scale 2)
  [[ $wide == "#000000" ]] || fail "wide display samples its white variant"
  pass "each display samples its own geometry and variant"

  run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/plugins/bar/Bar.qml'), 'utf8')
function productionFunction(name) {
  const start = source.indexOf('  function ' + name + '(')
  assert(start >= 0, name + ' exists')
  return source.slice(start, source.indexOf('\n  }', start) + 4)
}
const context = vm.createContext({
  useTransparentForeground: true, screenForegrounds: { square: '#ffffff', wide: '#000000' },
  barForeground: '#aaaaaa', shell: null, pluginBarApis: {}, pluginBarApiScreens: {},
  pluginBarApiComponent: { createObject(parent, properties) { return properties } },
  targetWindow(item) { return { screen: item.screen } },
  bindPluginBarApi(api, screen) { api.sampleScreen = screen },
  pluginBarApiUsed() { return false }, releasePluginObjects(id) { this.released.push(id) },
  released: []
})
context.root = context
for (const name of ['foregroundForScreen', 'foregroundForItem', 'pluginBarApiFor', 'prunePluginBarApis']) {
  vm.runInContext(productionFunction(name), context)
}
const square = { name: 'square' }, wide = { name: 'wide' }
assertEqual(context.foregroundForItem({screen: square}), '#ffffff', 'square widget gets its light foreground')
assertEqual(context.foregroundForItem({screen: wide}), '#000000', 'wide widget gets its dark foreground')
context.useTransparentForeground = false
assertEqual(context.foregroundForItem({screen: wide}), '#aaaaaa', 'opaque bars use the theme foreground')
const a = context.pluginBarApiFor('example.widget', 'example.widget', false, square)
const b = context.pluginBarApiFor('example.widget', 'example.widget', false, wide)
assert(a !== b, 'third-party widgets receive distinct presentation facades per screen')
assertEqual(a.pluginId, b.pluginId, 'per-screen presentation retains the original plugin authority scope')
assertEqual(b.sampleScreen.name, 'wide', 'wide facade binds to the correct screen')
// Widgets now live in a per-bar pool. Exercise its real host injection so a
// layout refactor cannot silently reconnect both screens to one facade.
const widgetHost = source.slice(source.indexOf('component WidgetHost'), source.indexOf('component ModuleSlot'))
const injectStart = widgetHost.indexOf('    function injectProps(')
assert(injectStart >= 0, 'pooled widget host exposes property injection')
vm.runInContext(widgetHost.slice(injectStart, widgetHost.indexOf('\n    }', injectStart) + 6), context)
Object.assign(context, {firstParty: false, pluginApiId: 'example.widget', moduleName: 'example.widget', registered: false, fixedEdge: 'end', moduleSettings: {value: 1}})
for (const screen of [square, wide]) {
  context.activeItem = {screen, bar: null, fixedEdge: null, moduleName: '', settings: null}
  context.injectProps()
  assertEqual(context.activeItem.bar.sampleScreen.name, screen.name, 'pooled widget inherits its own display facade')
  assertEqual(context.activeItem.fixedEdge, 'end', 'screen binding preserves upstream widget anchoring')
}
context.prunePluginBarApis()
assertDeepEqual(Array.from(context.released), ['example.widget', 'example.widget'], 'facade pruning releases by plugin ID rather than presentation cache key')

const liveScreen = {name:'live'}, removedScreen = {name:'removed'}
const liveTarget = {screen:liveScreen}, removedTarget = {screen:removedScreen}, retired = []
const prune = vm.createContext({shell:null,widgetHosts:[{pluginApiId:'example.widget',activeItem:liveTarget}],pluginBarApis:{},pluginBarApiScreens:{},pluginObjectOwners:new Map(),
  pluginBarApiComponent:{createObject(parent,properties){return {...properties,destroy(){retired.push(this)}}}},
  bindPluginBarApi(){}, targetWindow(item){return item ? {screen:item.screen} : null},unregisterClickTarget(target){this.unregistered=target},activePopout:null})
prune.root=prune
for (const name of ['pluginBarApiFor','pluginObjectRecord','markPluginObject','pluginBarApiUsed','releasePluginObjects','prunePluginBarApis']) vm.runInContext(productionFunction(name),prune)
const liveApi=prune.pluginBarApiFor('example.widget','example.widget',false,liveScreen)
const removedApi=prune.pluginBarApiFor('example.widget','example.widget',false,removedScreen)
prune.markPluginObject('example.widget',liveTarget,'clickTarget')
prune.markPluginObject('example.widget',removedTarget,'clickTarget')
prune.prunePluginBarApis()
assertDeepEqual(Object.keys(prune.pluginBarApis),['example.widget@live'],'disconnecting a screen destroys only that screens facade')
assertEqual(retired[0],removedApi,'the removed facade is destroyed even when the plugin remains visible')
assertEqual(prune.pluginBarApis['example.widget@live'],liveApi,'the live screen retains its original facade')
assert(prune.pluginObjectOwners.has(liveTarget) && !prune.pluginObjectOwners.has(removedTarget),'removed-screen cleanup preserves the other screens registrations')
assertDeepEqual(Object.keys(prune.pluginBarApiScreens),['example.widget@live'],'screen metadata is retired together with its facade')

JS

  # The bounded canvas must shrink native center/tile geometry too. Without
  # that ratio, centering crops a different part of a HiDPI wallpaper.
  magick -size 1000x2000 xc:black -fill white -draw 'rectangle 0,0 999,599' "$backgrounds/native.png"
  printf '[defaults]\nfill = "center"\nfill_color = "#000000"\n' >"$backgrounds/backgrounds.toml"
  result=$(HOME="$home" PATH="$ROOT/bin:$PATH" omarchy-bar-text-color top 60 '#ffffff' '#000000' \
    --background "$backgrounds/native.png" --screen 4000x2000 --scale 2)
  [[ $result == "#000000" ]] || fail "bounded HiDPI sampling keeps the native center framing" "got $result"
  pass "bounded HiDPI sampling keeps the native center framing"

  for flag in --background --screen --scale; do
    rc=0
    HOME="$home" PATH="$ROOT/bin:$PATH" timeout 2 bash "$ROOT/bin/omarchy-bar-text-color" top 10 '#ffffff' '#000000' "$flag" >/dev/null || rc=$?
    (( rc != 124 )) || fail "missing $flag value must not hang"
  done
  pass "missing bar sampling arguments cannot hang"
)

bounded_bin="$TMPDIR/bounded-bin"
mkdir -p "$bounded_bin"
cat >"$bounded_bin/timeout" <<'SH'
#!/bin/bash
printf '%s\t%s\t%s\n' "$1" "$2" "$3" >"$TIMEOUT_LOG"
shift 2
exec "$@"
SH
cat >"$bounded_bin/magick" <<'SH'
#!/bin/bash
printf '%s\t%s\t%s\t%s\t%s\n' \
  "$MAGICK_MEMORY_LIMIT" "$MAGICK_MAP_LIMIT" "$MAGICK_DISK_LIMIT" "$MAGICK_TIME_LIMIT" "$MAGICK_THREAD_LIMIT" >"$LIMIT_LOG"
printf '%s\n' "$*" >"$ARGS_LOG"
printf '245,245,245'
SH
chmod +x "$bounded_bin/timeout" "$bounded_bin/magick"

result=$(HOME="$TMPDIR" LIMIT_LOG="$TMPDIR/limits" TIMEOUT_LOG="$TMPDIR/timeout" ARGS_LOG="$TMPDIR/args" PATH="$bounded_bin:$PATH" \
  omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$light_top" --screen 100x100)
[[ $result == "#101010" ]] || fail "bounded wallpaper sample still chooses the contrasting color" "expected #101010, got $result"
[[ $(<"$TMPDIR/limits") == $'512MiB\t0\t0\t5\t2' ]] || fail "wallpaper sampling bounds ImageMagick resources" "$(<"$TMPDIR/limits")"
[[ $(<"$TMPDIR/timeout") == $'--kill-after=1s\t5s\tmagick' ]] || fail "wallpaper sampling has a hard timeout" "$(<"$TMPDIR/timeout")"
pass "transparent bar wallpaper sampling is resource bounded"

# Only the bar strip's mean color is needed, so a high-resolution screen is sampled
# on a canvas at most 1920 px wide, and JPEG decodes at about that size. Otherwise
# a 6K or 8K wallpaper exceeds the pixel-cache limit and silently falls back.
HOME="$TMPDIR" LIMIT_LOG="$TMPDIR/limits" TIMEOUT_LOG="$TMPDIR/timeout" ARGS_LOG="$TMPDIR/args" PATH="$bounded_bin:$PATH" \
  omarchy-bar-text-color bottom 64 '#ffffff' '#101010' --background "$light_top" --screen 6016x3384 >/dev/null
args=$(<"$TMPDIR/args")
[[ $args == "-define jpeg:size=1920x1080 "* ]] || fail "high-resolution screen decodes JPEG at canvas size" "$args"
[[ $args == *" -scale 1920x1080^ "* && $args == *" -crop 1920x21+0+1059 "* ]] ||
  fail "high-resolution screen samples a scaled canvas" "$args"
pass "high-resolution screen samples a scaled canvas"

# An existing wallpaper whose bounded sample fails (ImageMagick refuses it at a
# resource limit) or runs out of time must keep the configured text color, even
# on a light wallpaper where a finished sample would switch it.
failing_bin="$TMPDIR/failing-bin"
mkdir -p "$failing_bin"
cat >"$failing_bin/magick" <<'SH'
#!/bin/bash
echo "magick: cache resources exhausted" >&2
exit 1
SH
chmod +x "$failing_bin/magick"

result=$(HOME="$TMPDIR" PATH="$failing_bin:$PATH" \
  omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$light_top" --screen 100x100)
[[ $result == "#ffffff" ]] || fail "failed wallpaper sample falls back to text color" "expected #ffffff, got $result"
pass "failed wallpaper sample falls back to text color"

expired_bin="$TMPDIR/expired-bin"
mkdir -p "$expired_bin"
cat >"$expired_bin/timeout" <<'SH'
#!/bin/bash
exit 124
SH
chmod +x "$expired_bin/timeout"

result=$(HOME="$TMPDIR" PATH="$expired_bin:$PATH" \
  omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$light_top" --screen 100x100)
[[ $result == "#ffffff" ]] || fail "timed-out wallpaper sample falls back to text color" "expected #ffffff, got $result"
pass "timed-out wallpaper sample falls back to text color"
