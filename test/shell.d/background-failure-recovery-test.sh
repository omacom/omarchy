#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
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
for (const event of ['CanonicalPath', 'ScreenWidth', 'ScreenHeight', 'DevicePixelRatio', 'RefreshToken']) {
  const choice = vm.createContext({canonicalOnly:true, requests:0, requestResolve(){this.requests++}})
  load('resetChoice', choice, resolver, '  ')
  const handler = resolver.match(new RegExp('on'+event+'Changed: ([^\\n]+)'))[1]
  vm.runInContext(handler, choice)
  assert(!choice.canonicalOnly, event+' permits selecting a repaired or different variant')
}
assert(resolver.includes('"timeout", "--kill-after=2", "45",'), 'resolver execution is bounded even if a helper hangs')
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
