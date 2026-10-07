#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const background = fs.readFileSync(path.join(root, 'shell/plugins/background/Background.qml'), 'utf8')
const media = fs.readFileSync(path.join(root, 'shell/Ui/BackgroundMedia.qml'), 'utf8')

// Run the actual QML function bodies, with only the process and animation
// objects mocked. Completing a probe also runs the real onExited handler.
function state(displayed = 'a.png') {
  const ctx = {
    currentBackground: displayed, displayedBackground: displayed,
    pendingInstantBackground: '', incomingBackground: '', oldBackground: '',
    preparedBackground: '', lastTransitionPath: '', sizeQueue: [],
    finishingTransition: false, backgroundVersion: 0, revealStartedVersion: -1,
    revealProgress: 1, sizeProbe: { running: false, path: '' },
    sizeProbeOut: { text: '' },
    preparedBackgroundTimer: { stop() {}, restart() {} },
    revealAnimation: { stop() {} },
    Util: { isVideoPath: value => /\.(mp4|m4v|mov|webm|mkv|avi)$/i.test(value) },
  }
  ctx.root = ctx
  vm.createContext(ctx)
  for (const name of ['isVideo', 'setBackground', 'transitionBackground', 'applyPendingInstantBackground', 'prepareBackground', 'requestNativeSize', 'probeNextSize', 'pruneNativeSizes']) {
    const match = background.match(new RegExp(`^  function ${name}\\([^]*?^  }`, 'm'))
    // The original source has no pending helper; still execute its transition
    // so the first regression fails on the premature displayed-path change.
    if (match) vm.runInContext(match[0], ctx)
  }
  let sizes = displayed ? { [displayed]: { width: 2560, height: 1440 } } : {}
  Object.defineProperty(ctx, 'nativeSizes', {
    get: () => sizes,
    set(value) {
      sizes = value
      if (background.includes('onNativeSizesChanged: applyPendingInstantBackground()')) ctx.applyPendingInstantBackground()
    },
  })
  Object.defineProperty(ctx, 'path', { get: () => ctx.sizeProbe.path })
  const handler = background.match(/onExited: function\(exitCode\) \{([^]*?)^    }/m)[1]
  ctx.completeProbe = (text = '2560 1440', exitCode = 0) => {
    ctx.sizeProbeOut.text = text
    ctx.sizeProbe.running = false
    ctx.exitCode = exitCode
    vm.runInContext(handler, ctx)
  }
  return ctx
}

let s = state()
s.setBackground('b.png', true)
assertEqual(s.displayedBackground, 'a.png', 'cold instant switch keeps the old path while the header is read')
assertEqual(s.currentBackground, 'b.png', 'the requested background is tracked while its header is pending')
assertEqual(s.incomingBackground, '', 'instant switch does not start a wipe')
s.completeProbe()
assertEqual(s.displayedBackground, 'b.png', 'the new path is displayed once its size is known')
assertEqual(s.pendingInstantBackground, '', 'the completed instant request releases its pending path')

s = state()
s.setBackground('b.png', true)
// Keep a completed size result if pruning runs before the pending switch has
// consumed it. A stale wallpaper should still be removed from the cache.
s.nativeSizes['b.png'] = { width: 1280, height: 720 }
s.nativeSizes['stale.png'] = { width: 640, height: 480 }
s.pruneNativeSizes()
assertDeepEqual(s.nativeSizes['b.png'], { width: 1280, height: 720 }, 'pruning retains the size of a pending instant wallpaper')
assertEqual(s.displayedBackground, 'b.png', 'pruning lets a sized pending instant wallpaper become displayed')
assertEqual(s.pendingInstantBackground, '', 'pruning releases the pending path after its size becomes available')
assertEqual(s.nativeSizes['stale.png'], undefined, 'pruning still drops wallpaper sizes that are no longer in use')

s = state()
s.nativeSizes['b.png'] = { width: 1280, height: 720 }
s.setBackground('b.png', true)
assertEqual(s.displayedBackground, 'b.png', 'known-size instant switch does not wait for another probe')
assertEqual(s.sizeProbe.running, false, 'known-size instant switch starts no header process')

s = state()
s.setBackground('b.png', true)
s.setBackground('c.png', true)
s.completeProbe()
assertEqual(s.displayedBackground, 'a.png', 'rapid A to B to C ignores B when its earlier probe finishes')
assertEqual(s.sizeProbe.path, 'c.png', 'the newer instant request is still probed')
s.completeProbe()
assertEqual(s.displayedBackground, 'c.png', 'rapid switching displays only the latest requested path')

s = state()
s.setBackground('b.png', true)
s.setBackground('a.png', true)
s.completeProbe()
assertEqual(s.displayedBackground, 'a.png', 'returning to A cancels a pending B even after B finishes probing')

s = state()
s.setBackground('b.png', true)
s.setBackground('c.png', false)
s.completeProbe()
assertEqual(s.displayedBackground, 'a.png', 'a wipe cancels an older pending instant request')
assertEqual(s.incomingBackground, 'c.png', 'the new wipe retains its incoming frame')
assertEqual(s.revealProgress, 0, 'the new wipe still waits for its frame to become ready')

s = state()
s.setBackground('b.png', false)
s.setBackground('c.png', true)
s.completeProbe()
assertEqual(s.displayedBackground, 'a.png', 'an instant request interrupting a wipe retains the base during its probe')
assertEqual(s.incomingBackground, '', 'an instant request clears the interrupted wipe')
s.completeProbe()
assertEqual(s.displayedBackground, 'c.png', 'an instant request interrupting a wipe displays its own result')

s = state()
s.setBackground('b.png', true)
s.setBackground('movie.mp4', true)
s.completeProbe()
assertEqual(s.displayedBackground, 'movie.mp4', 'switching to video is immediate and cancels a pending still')
assertEqual(s.sizeQueue.length, 0, 'videos do not enter the image-size probe queue')

s = state('movie.mp4')
s.setBackground('b.png', false)
assertEqual(s.incomingBackground, '', 'switching from video still bypasses the wipe')
s.completeProbe()
assertEqual(s.displayedBackground, 'b.png', 'switching from video displays the still after its probe')

s = state('')
s.setBackground('a.png', true)
s.completeProbe()
assertEqual(s.displayedBackground, 'a.png', 'the first wallpaper is displayed after its probe')

s = state()
s.setBackground('b.png', true)
s.completeProbe('', 1)
assertEqual(s.displayedBackground, 'b.png', 'a failed header probe releases the request to the existing screen-size fallback')
assertDeepEqual(s.nativeSizes['b.png'], { width: 0, height: 0 }, 'a failed probe remains a known zero size rather than waiting forever')

s = state()
s.prepareBackground('b.png')
s.setBackground('b.png', true)
s.completeProbe()
assertEqual(s.displayedBackground, 'b.png', 'an instant switch reuses an in-flight prepare probe')
assertEqual(s.sizeQueue.length, 0, 'a prepared instant path is probed only once')

s = state()
s.transitionBackground('a.png', 'snapshot.png', 'final.png', true, true)
s.completeProbe()
assertEqual(s.displayedBackground, 'a.png', 'an instant theme transition waits for the durable path as well as its snapshot')
s.completeProbe()
assertEqual(s.displayedBackground, 'final.png', 'an instant theme transition displays its durable final path')

assert(
  /retainWhileLoading: root\.retainWhileLoading/.test(media) &&
    /path: root\.displayedBackground\s*retainWhileLoading: true/.test(background),
  'the desktop retains the old decoded frame while its replacement loads'
)
assert(media.includes('property bool retainWhileLoading: false'), 'retention is opt-in so the lock keeps its existing loading and blur behavior')
assert(/active: root\.path !== "" && !root\.video/.test(media), 'empty paths and videos still unload the shared image')
JS
