#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const backgroundQml = fs.readFileSync(path.join(root, 'shell/plugins/background/Background.qml'), 'utf8')
const resolverQml = fs.readFileSync(path.join(root, 'shell/Ui/BackgroundResolver.qml'), 'utf8')
const wallpaperQml = fs.readFileSync(path.join(root, 'shell/Ui/WallpaperImage.qml'), 'utf8')
function blockAfter(source, marker, description) {
  const start = source.indexOf(marker)
  if (start < 0) fail(description, `marker not found: ${marker}`)
  const indent = source.slice(source.lastIndexOf('\n', start) + 1, start)
  const closerIndent = marker.startsWith('function') ? indent : indent.slice(0, -2)
  const rest = source.slice(start)
  const end = rest.indexOf('\n' + closerIndent + '}')
  if (end < 0) fail(description, `unterminated block for marker: ${marker}`)
  return rest.slice(0, end)
}

const startBlock = blockAfter(resolverQml, 'function startResolve', 'resolver entry point')
const lockBlock = blockAfter(backgroundQml, 'function lockIncoming', 'incoming frame lock')
const settledBlock = blockAfter(backgroundQml, 'function baseSettled', 'settlement state')
const context = vm.createContext({
  Commons: { Color: { background: 'fallback' } },
  Qt: { rgba: (...channels) => channels },
  canonicalPath: '/theme/art.svg', screenWidth: 1920, screenHeight: 1080,
  devicePixelRatio: 2, canonicalOnly: false, metadataOnly: false, requestSeq: 1, resolveProc: {}, resolvePending: false
})
vm.runInContext(blockAfter(resolverQml, 'function parseFillColor', 'color parser exists') + '\n}', context)
assertDeepEqual(Array.from(context.parseFillColor('#ff000080')), [1, 0, 0, 128 / 255], 'RGBA metadata renders translucent red')
assertDeepEqual(Array.from(context.parseFillColor('#12345600')), [18 / 255, 52 / 255, 86 / 255, 0], 'zero alpha remains transparent')
assertDeepEqual(Array.from(context.parseFillColor('#abcdef')), [171 / 255, 205 / 255, 239 / 255, 1], 'six-digit colors remain opaque')
assertEqual(context.parseFillColor('#bad'), 'fallback', 'invalid colors retain the theme fallback')
vm.runInContext(startBlock + '\n}', context)
context.startResolve()
assertEqual(context.resolveProc.command[context.resolveProc.command.indexOf('--screen') + 1], '3840x2160', 'scale 2 resolves SVGs at physical output resolution')
context.devicePixelRatio = 1.25
context.startResolve()
assertEqual(context.resolveProc.command[context.resolveProc.command.indexOf('--screen') + 1], '2400x1350', 'fractional scale resolves at physical output resolution')
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
const outgoing = vm.createContext({
  currentBackground: '/old/art.svg', displayedBackground: '/old/art.svg',
  displayedVersion: 3, backgroundVersion: 3, preparedBackground: '', lastTransitionPath: '',
  isVideo: () => false,
  revealAnimation: { stop() {} },
  preparedBackgroundTimer: { stop() {} }, requestNativeSize() {}
})
outgoing.root = outgoing
vm.runInContext(blockAfter(backgroundQml, 'function transitionBackground(', 'transition function exists') + '\n}', outgoing)
outgoing.transitionBackground('/snapshots/canonical.svg', '/snapshots/new.png', '/new/art.svg', false, true)
assertEqual(outgoing.displayedBackground, '/old/art.svg', 'theme snapshots leave the per-panel base source intact during reveal')
assertEqual(outgoing.displayedVersion, 3, 'arming a theme transition never requests a fresh decode of the outgoing wallpaper')

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
  incomingLockedVersion: -1, incomingAbandoned: false,
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

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const resolver = fs.readFileSync(path.join(root, 'shell/Ui/BackgroundResolver.qml'), 'utf8')
const body = resolver.match(/  function retryCanonical\(failedPath\) \{[^]*?\n  }/)[0]
const context = {ready: true, canonicalOnly: false, resolvedPath: '/variant.png'}
vm.createContext(context)
vm.runInContext(body, context)
context.retryCanonical('/obsolete.png')
assertEqual(context.canonicalOnly, false, 'stale image failures cannot change the current lock resolution')
context.retryCanonical('/variant.png')
assertEqual(context.canonicalOnly, true, 'a failed current variant requests the canonical wallpaper')
context.canonicalOnly = false; context.ready = false
context.retryCanonical('/variant.png')
assertEqual(context.canonicalOnly, false, 'in-flight resolution does not retry an obsolete decode')
JS

# Canonical background enumeration.
(
  require_command magick
  require_command jq

  test_tmp=$(mktemp -d)
  trap 'rm -rf "$test_tmp"' EXIT

  stubs="$test_tmp/stubs"
  mkdir -p "$stubs"

  cat >"$stubs/omarchy-shell" <<'STUB'
#!/bin/bash
exit 0
STUB
  cat >"$stubs/omarchy-notification-send" <<'STUB'
#!/bin/bash
exit 0
STUB
  chmod +x "$stubs"/*

  write_fixture_backgrounds() {
    local dir="$1"

    mkdir -p "$dir"
    magick -size 4x2 xc:red "$dir/1-a.png"
    magick -size 8x2 xc:blue "$dir/1-a@ultrawide.png"
    cat >"$dir/2-b.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="4" height="4"><rect width="4" height="4" fill="#00ff00"/></svg>
SVG
  }

  # omarchy-theme-bg-next cycles over canonical files only, including SVG.
  home_next="$test_tmp/home-next"
  state_next="$home_next/.local/state/omarchy/current"
  mkdir -p "$state_next"
  printf 'bgtest\n' >"$state_next/theme.name"
  write_fixture_backgrounds "$state_next/theme/backgrounds"

  bg_next() {
    HOME="$home_next" PATH="$stubs:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
      bash "$ROOT/bin/omarchy-theme-bg-next"
  }

  current_background_name() {
    local link="$1"
    local target

    target=$(readlink "$link") || fail "the current background symlink exists"
    printf '%s' "${target##*/}"
  }

  bg_next || fail "omarchy-theme-bg-next runs against the fixture state"
  [[ $(current_background_name "$state_next/background") == "1-a.png" ]] ||
    fail "omarchy-theme-bg-next starts the cycle at the first canonical file"

  bg_next || fail "omarchy-theme-bg-next advances the cycle"
  [[ $(current_background_name "$state_next/background") == "2-b.svg" ]] ||
    fail "omarchy-theme-bg-next includes SVG backgrounds and skips variants"

  bg_next || fail "omarchy-theme-bg-next wraps the cycle"
  [[ $(current_background_name "$state_next/background") == "1-a.png" ]] ||
    fail "omarchy-theme-bg-next wraps back to the first canonical file"

  pass "omarchy-theme-bg-next cycles over canonical files and SVGs, never variants"

  # The theme-set background chooser never links a variant either.
  home_set="$test_tmp/home-set"
  state_set="$home_set/.local/state/omarchy/current"
  themes_set="$home_set/.config/omarchy/themes"
  mkdir -p "$state_set" "$themes_set/bgtest"
  write_fixture_backgrounds "$themes_set/bgtest/backgrounds"

  cat >"$themes_set/bgtest/colors.toml" <<'TOML'
accent = "#7aa2f7"
selection = "#292e42"
muted = "#414868"

background = "#1a1b26"
foreground = "#a9b1d6"

color0 = "#1a1b26"
color1 = "#f7768e"
color2 = "#9ece6a"
color3 = "#e0af68"
color4 = "#7aa2f7"
color5 = "#bb9af7"
color6 = "#7dcfff"
color7 = "#a9b1d6"
TOML

  set_theme() {
    HOME="$home_set" OMARCHY_PATH="$ROOT" PATH="$stubs:$ROOT/bin:$PATH" \
      OMARCHY_THEME_HEADLESS=1 XDG_RUNTIME_DIR="$test_tmp" \
      bash "$ROOT/bin/omarchy-theme-set" bgtest 2>"$test_tmp/stderr" || return $?
  }

  for expected in 1-a.png 2-b.svg 1-a.png; do
    set_theme || fail "omarchy-theme-set applies the fixture theme headlessly" "$(cat "$test_tmp/stderr")"
    chosen=$(current_background_name "$state_set/background")
    [[ $chosen != *@* ]] || fail "the theme-set chooser never links a variant"
    [[ $chosen == "$expected" ]] ||
      fail "the theme-set chooser cycles canonical files including SVG" "expected: $expected, chosen: $chosen"
  done

  pass "the theme-set chooser cycles canonical files and never links a variant"

  # The image picker list feed applies the same whitelist.
  list_rows=$(HOME="$home_next" bash "$ROOT/shell/plugins/image-picker/list.sh" "$state_next/theme/backgrounds")
  grep -q '1-a\.png' <<<"$list_rows" || fail "list.sh lists canonical raster backgrounds"
  grep -q '2-b\.svg' <<<"$list_rows" || fail "list.sh lists SVG backgrounds"
  ! grep -q '@ultrawide' <<<"$list_rows" || fail "list.sh excludes aspect-ratio variants"

  pass "the image picker list feed matches the enumeration whitelist"

  # omarchy-theme-bg-current strips a variant label when it shows one defensively.
  ln -nsf "$state_next/theme/backgrounds/1-a@ultrawide.png" "$state_next/background"
  name=$(HOME="$home_next" bash "$ROOT/bin/omarchy-theme-bg-current")
  [[ $name == "A" ]] || fail "omarchy-theme-bg-current strips the variant label" "got: $name"

  pass "omarchy-theme-bg-current prints a variant path cleanly"

  # omarchy-bar-text-color samples the path the resolver picks and honors its
  # fill metadata; a failing resolver falls back to the state symlink.
  magick -size 8x8 xc:white "$test_tmp/white.png"
  magick -size 8x8 xc:black "$test_tmp/black.png"
  magick -size 1x1 xc:black "$test_tmp/dot.png"

  resolver_fields() {
    local path="$1"
    local fill="$2"
    local fill_color="$3"

    cat >"$stubs/omarchy-theme-bg-resolve" <<STUB
#!/bin/bash
printf '%s\n' "\$*" >"$test_tmp/resolver-args"
printf 'path\t%s\n' "$path"
printf 'canonical\t%s\n' "$path"
printf 'fill\t%s\n' "$fill"
printf 'fill_color\t%s\n' "$fill_color"
printf 'focal_x\t0.5\nfocal_y\t0.5\n'
STUB
    chmod +x "$stubs/omarchy-theme-bg-resolve"
  }

  bar_text_color() {
    HOME="$home_next" PATH="$stubs:$ROOT/bin:$PATH" \
      bash "$ROOT/bin/omarchy-bar-text-color" top 2 '#ffffff' '#000000' --screen 8x8
  }

  resolver_fields "$test_tmp/white.png" crop '#ffffff'
  [[ $(bar_text_color) == "#000000" ]] ||
    fail "omarchy-bar-text-color samples the resolver's path in crop mode"

  resolver_fields "$test_tmp/dot.png" center '#ffffff'
  [[ $(bar_text_color) == "#000000" ]] ||
    fail "omarchy-bar-text-color composites center fills over the fill color"

  resolver_fields "$test_tmp/black.png" fit '#000000'
  [[ $(bar_text_color) == "#ffffff" ]] ||
    fail "omarchy-bar-text-color composites fit fills over the fill color"

  resolver_fields "$test_tmp/white.png" tile '#ffffff'
  [[ $(bar_text_color) == "#000000" ]] ||
    fail "omarchy-bar-text-color tiles the resolved image"

  # The shell paints fill_color under tiles too: a transparent tile over a white
  # fill must sample white, not the transparent pixels' black.
  magick -size 4x4 xc:none "$test_tmp/transparent.png"
  resolver_fields "$test_tmp/transparent.png" tile '#ffffff'
  [[ $(bar_text_color) == "#000000" ]] ||
    fail "omarchy-bar-text-color composites tile fills over the fill color"

  # A rotated monitor (odd transform) reports its raw mode resolution through
  # hyprctl; the derived --screen must use the swapped, logical dimensions.
  cat >"$stubs/hyprctl" <<'STUB'
#!/bin/bash
printf '[{"width":2560,"height":1440,"transform":1}]\n'
STUB
  chmod +x "$stubs/hyprctl"

  resolver_fields "$test_tmp/white.png" crop '#ffffff'
  rotated=$(HOME="$home_next" PATH="$stubs:$ROOT/bin:$PATH" \
    bash "$ROOT/bin/omarchy-bar-text-color" top 2 '#ffffff' '#000000')
  [[ $rotated == "#000000" ]] ||
    fail "omarchy-bar-text-color samples with the hyprctl-derived screen size"
  grep -q -- '--screen 1440x2560' "$test_tmp/resolver-args" ||
    fail "omarchy-bar-text-color swaps width/height for odd monitor transforms" "$(cat "$test_tmp/resolver-args")"

  cat >"$stubs/omarchy-theme-bg-resolve" <<'STUB'
#!/bin/bash
exit 1
STUB
  chmod +x "$stubs/omarchy-theme-bg-resolve"

  ln -nsf "$test_tmp/black.png" "$state_next/background"
  [[ $(bar_text_color) == "#ffffff" ]] ||
    fail "omarchy-bar-text-color falls back to the state symlink when the resolver fails"

  pass "omarchy-bar-text-color follows the resolver and keeps its fallback"
)

# Resolver and transition recovery.
(
  run_node_test <<'JS'
const fs = require('fs'), vm = require('vm')
const qml = fs.readFileSync(path.join(root, 'shell/plugins/background/Background.qml'), 'utf8')
const resolver = fs.readFileSync(path.join(root, 'shell/Ui/BackgroundResolver.qml'), 'utf8')
function load(name, context, source = qml, indent = '      ') {
  const fn = source.match(new RegExp('function '+name+'\\([^]*?\\n'+indent+'}'))
  assert(fn, name+' exists')
  vm.runInContext(fn[0], context)
}
const recovery = vm.createContext({panel:{lastDisplayedPath:'/image@wide.png'}, displayedResolver:{canonicalOnly:false}, root:{displayedBackground:'/image.png', recoverBackground(path) { this.recovered=path }}})
load('recoverDisplayedImage', recovery)
recovery.recoverDisplayedImage()
assert(recovery.displayedResolver.canonicalOnly && !recovery.root.recovered, 'a failed variant retries the canonical on that panel')
recovery.recoverDisplayedImage()
assertEqual(recovery.root.recovered, '/image.png', 'a failed canonical uses the ordinary missing-background recovery')
const displayed = qml.slice(qml.indexOf('id: displayedResolver'), qml.indexOf('id: snapshotResolver'))
const resolvedHandler = displayed.match(/onResolveVersionChanged: \{([^]*?)\n        \}/)[1]
const missing = vm.createContext({canonicalPath:'/deleted.svg', requestSeq:1, resolveVersion:0,
  ready:false, resolvedPath:'', screenWidth:1920, screenHeight:1080,
  displayedBackground:'/deleted.svg', backgroundVersion:3, recoverProc:{running:false},
  panel:{lastDisplayedPath:'/previous.png'}, Commons:{Color:{background:'#000000'}},
  requestNativeSize(){}, maybeFinishTransition(){}})
missing.root = missing
load('recoverBackground', missing, qml, '  ')
load('publishFallback', missing, resolver, '  ')
vm.runInContext(resolvedHandler, missing)
assert(!missing.recoverProc.running, 'an unresolved SVG does not start recovery')
missing.publishFallback(1)
missing.screenWidth = 0
vm.runInContext(resolvedHandler, missing)
assert(!missing.recoverProc.running, 'an unsized screen does not mistake a pending SVG for a missing file')
missing.screenWidth = 1920
vm.runInContext(resolvedHandler, missing)
assert(missing.recoverProc.running, 'a completed empty SVG resolution starts missing-background recovery')
assertEqual(missing.failedBackground, '/deleted.svg', 'recovery receives the failed SVG canonical')
assertEqual(missing.panel.lastDisplayedPath, '/previous.png', 'recovery retains already displayed pixels')
for (const event of ['CanonicalPath', 'ScreenWidth', 'ScreenHeight', 'DevicePixelRatio', 'RefreshToken']) {
  const choice = vm.createContext({canonicalOnly:true, requests:0, requestResolve(){this.requests++}})
  load('resetChoice', choice, resolver, '  ')
  const handler = resolver.match(new RegExp('on'+event+'Changed: ([^\\n]+)'))[1]
  vm.runInContext(handler, choice)
  assert(!choice.canonicalOnly, event+' permits selecting a repaired or different variant')
}
const state = vm.createContext({incomingBackground:'/snapshot.png', currentBackground:'/final.png', displayedBackground:'/old.png', backgroundVersion:9, displayedVersion:1, oldBackground:'/old.png', preparedBackground:'', finishingTransition:true, revealProgress:1, panelVariants:{instances:[]}, revealAnimation:{stop(){this.stopped=true}}, applyPendingTheme(){}, pruneNativeSizes(){}, requestNativeSize(){}})
for (const name of ['finishTransitionWithoutReveal', 'maybeFinishTransition']) load(name, state, qml, '  ')
function panel() {
  const c = vm.createContext({root:state, maskReady:false, incomingFallbackTried:false, incomingAbandoned:false, incomingLockedVersion:-1, incomingPath:'', incomingFill:'crop', incomingBackdrop:'solid', lastDisplayedFill:'crop', snapshotResolver:{ready:false, usedFallback:false, fill:'fit', backdrop:'blur', fillColor:'#234567', focalX:.2, focalY:.8}, incomingFallbackTimer:{restart(){this.restarted=true}}, maybeStartReveal(){}, baseSettled(){return false}})
  for (const name of ['lockIncoming', 'tryIncomingFallback', 'lockSnapshotFallback']) load(name,c)
  return c
}
const ready = panel(), slow = panel()
state.panelVariants.instances = [ready,slow]
ready.lockIncoming('/ready.png','fit','blur','#234567',.2,.8)
ready.maskReady = true
slow.tryIncomingFallback()
assertEqual(slow.incomingPath, '', 'a snapshot never borrows outgoing metadata while new metadata is pending')
slow.snapshotResolver.ready = true
slow.lockSnapshotFallback()
assertEqual(slow.incomingPath, '/snapshot.png', 'a cold image resolver can reveal a snapshot after its fast metadata arrives')
assertEqual(slow.incomingFill, 'fit', 'the snapshot uses the incoming fill rather than outgoing crop')
assertEqual(slow.incomingBackdrop, 'blur', 'the snapshot uses the incoming backdrop')
assertEqual(slow.incomingFocalY, .8, 'the snapshot uses the incoming focal position')
assert(slow.incomingFallbackTimer.restarted, 'snapshot decoding has a second bounded deadline')
slow.tryIncomingFallback()
assert(slow.incomingAbandoned && slow.incomingPath === '', 'an undecodable snapshot abandons only its own panel')
assertEqual(state.incomingBackground, '/snapshot.png', 'one slow panel cannot clear the other panels shared transition source')
assertEqual(ready.incomingPath, '/ready.png', 'a ready panel retains decoded incoming pixels while its base is loading')
assert(!state.revealAnimation.stopped, 'one failed panel cannot interrupt another panels reveal')
slow.lockIncoming('/late.png','crop','solid','#000000',.5,.5)
assertEqual(slow.incomingPath, '', 'a late resolver cannot revive an abandoned panel transition')
ready.baseSettled = () => true
state.maybeFinishTransition()
assertEqual(state.incomingBackground, '', 'shared sources release after the remaining panel base settles')
const a = panel(), b = panel()
state.panelVariants.instances = [a,b]
state.incomingBackground = '/broken.png'
state.finishingTransition = false
for (const p of [a,b]) { p.tryIncomingFallback(); p.tryIncomingFallback() }
assertEqual(state.incomingBackground, '', 'all failed panels can terminate a transition without an image reveal')
assertEqual(state.displayedBackground, '/final.png', 'all failed panels advance their base to the final canonical')
JS

  task_tmp=$(mktemp -d)
  trap 'rm -rf "$task_tmp"' EXIT
  mkdir -p "$task_tmp/bin" "$task_tmp/home" "$task_tmp/backgrounds"
  cat >"$task_tmp/backgrounds/image.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="160" height="90"><rect width="160" height="90" fill="red"/></svg>
SVG
  cp "$task_tmp/backgrounds/image.svg" "$task_tmp/backgrounds/image@wide.svg"
  printf '[defaults]\nfill = "fit"\nbackdrop = "edge"\nfill_color = "#123456"\nfocal = "0.2 0.8"\n' >"$task_tmp/backgrounds/backgrounds.toml"
  for command in magick rsvg-convert; do
    printf '#!/bin/bash\ntouch "$UNEXPECTED_RENDER"\nexit 99\n' >"$task_tmp/bin/$command"
    chmod +x "$task_tmp/bin/$command"
  done
  result=$(HOME="$task_tmp/home" UNEXPECTED_RENDER="$task_tmp/rendered" PATH="$task_tmp/bin:$ROOT/bin:$PATH" timeout 2 "$ROOT/bin/omarchy-theme-bg-resolve" --metadata-only --screen 5120x1440 --canonical "$task_tmp/backgrounds/image.svg")
  [[ ! -e $task_tmp/rendered ]] || fail "metadata-only resolution invoked image probing, rendering or sampling"
  jq -e '.fill == "fit" and .backdrop == "edge" and .fill_color == "#123456" and .focal_x == 0.2 and .focal_y == 0.8' <<<"$result" >/dev/null || fail "metadata-only resolution lost incoming framing"
  pass "incoming framing is available without waiting for probing, SVG rendering or edge sampling"

  run_node_test <<'JS'
const fs = require('fs'), vm = require('vm'), os = require('os'), cp = require('child_process')
const qml = fs.readFileSync(path.join(root,'shell/plugins/background/Background.qml'),'utf8')
const temporary = fs.mkdtempSync(path.join(os.tmpdir(),'omarchy-svg-recovery-'))
try {
  const backgrounds = path.join(temporary,'backgrounds')
  fs.mkdirSync(backgrounds)
  const svg = path.join(backgrounds,'only.svg')
  fs.writeFileSync(svg,'<svg xmlns="http://www.w3.org/2000/svg" width="160" height="90"><rect width="160" height="90" fill="red"/></svg>')
  fs.copyFileSync(svg,path.join(backgrounds,'0-art@wide.svg'))
  const link = path.join(temporary,'background')
  fs.symlinkSync(path.join(temporary,'missing.png'),link)
  const expression = qml.match(/id: recoverProc\s+command: (\[[^]*?\n    \])/)[1]
  const args = vm.runInNewContext(expression,{root:{currentBackgroundLink:link,currentThemeBackgrounds:backgrounds}})
  const recovered = cp.execFileSync(args[0],Array.from(args.slice(1)),{encoding:'utf8'}).trim()
  assertEqual(recovered,svg,'a dangling background recovers the active themes remaining SVG')
  const env = {...process.env,HOME:temporary,PATH:path.join(root,'bin')+':'+process.env.PATH}
  const metadata = JSON.parse(cp.execFileSync(path.join(root,'bin/omarchy-theme-bg-resolve'),['--screen','640x480','--canonical',recovered],{env,encoding:'utf8'}))
  assert(metadata.path.endsWith('.png') && fs.existsSync(metadata.path),'the recovered SVG reaches Qt through the bounded raster resolver')
} finally { fs.rmSync(temporary,{recursive:true,force:true}) }
JS
)

# A current SVG theme keeps its selected row in the theme picker.
(
  task_tmp=$(mktemp -d)
  trap 'rm -rf "$task_tmp"' EXIT
  mkdir -p "$task_tmp/home/.config/omarchy/themes/zeta/backgrounds" "$task_tmp/home/.local/state/omarchy/current" "$task_tmp/bin" "$task_tmp/source/themes"
  printf '<svg xmlns="http://www.w3.org/2000/svg" width="1" height="1"/>\n' >"$task_tmp/home/.config/omarchy/themes/zeta/backgrounds/art.svg"
  printf 'zeta\n' >"$task_tmp/home/.local/state/omarchy/current/theme.name"
  cat >"$task_tmp/bin/omarchy-menu-images" <<'STUB'
#!/bin/bash
while (( $# )); do
  if [[ $1 == "--selected" ]]; then printf '%s' "$2" >"$SELECTED_LOG"; break; fi
  shift
done
STUB
  chmod +x "$task_tmp/bin/omarchy-menu-images"
  HOME="$task_tmp/home" OMARCHY_PATH="$task_tmp/source" PATH="$task_tmp/bin:$PATH" SELECTED_LOG="$task_tmp/selected" bash "$ROOT/bin/omarchy-theme-switcher"
  [[ $(<"$task_tmp/selected") == "$task_tmp/home/.cache/omarchy/theme-selector/previews/zeta.svg" ]] || fail "the picker loses its current SVG theme selection"
  pass "the theme picker selects the current SVG preview"
)
