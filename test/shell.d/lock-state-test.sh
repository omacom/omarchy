#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A locked binding that missed a change once read locked after an unlock, and
# the lock before suspend took that for done, so the machine resumed unlocked.
# The session lock only changes state under a compositor, so nothing offscreen
# can make it disagree with a binding; this reads the source instead, as the
# one guard on a lock that must hold.
run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

assert(
  /function currentlyLocked\(\) \{\s*return lockRequested \|\| sessionLock\.locked \|\| sessionLock\.secure\s*\}/.test(serviceQml),
  'the lock state is read from the session lock itself, not a cached binding'
)
assert(
  /function lock\(\): string \{[\s\S]*?if \(!root\.currentlyLocked\(\) && !root\.beginLock\(\)\) return "failed"/.test(serviceQml)
    && /function isLocked\(\): string \{\s*return root\.currentlyLocked\(\)/.test(serviceQml)
    && /locked: root\.currentlyLocked\(\),/.test(serviceQml),
  'lock, isLocked and status decide from the current lock state'
)

// Exercise the real password failure settlement handlers: PAM can emit both
// onError and onCompleted for a single attempt, which must count once and
// always scrub pendingPassword.
const handleFailureFn = serviceQml.match(/function handlePasswordFailure\(\) \{[\s\S]*?\n  \}/)[0]
const passwordPamBlock = serviceQml.match(/PamContext \{\s*id: passwordPam[\s\S]*?\n  \}/)[0]
const onCompletedBody = passwordPamBlock.match(/onCompleted: function\(result\) \{([\s\S]*?)\n    \}/)[1]
const onErrorBody = passwordPamBlock.match(/onError: function\(error\) \{([\s\S]*?)\n    \}/)[1]

function runPasswordPam(events, lockRequested = true) {
  const ctx = {
    lockRequested,
    authenticatingPassword: true,
    enteredPassword: 'secret',
    pendingPassword: 'secret',
    failedAttempts: 0,
    failureMessage: '',
    unlocked: false,
    woke: 0,
    PamResult: { Success: 0, Failed: 1 },
    I18n: { t: () => ({ arg: v => `Failed (${v})` }), formatNumber: n => String(n) },
    runWake() { this.woke += 1 },
    finishUnlock() { this.unlocked = true }
  }
  ctx.root = ctx
  require('vm').runInNewContext(
    `${handleFailureFn}\nfunction fireCompleted(result) {${onCompletedBody}}\nfunction fireError(error) {${onErrorBody}}`,
    ctx
  )
  for (const [kind, arg] of events) {
    if (kind === 'error') ctx.fireError(arg)
    else ctx.fireCompleted(arg)
  }
  return ctx
}

let attempt = runPasswordPam([['error', 1], ['completed', 1]])
assertEqual(attempt.failedAttempts, 1, 'password onError followed by onCompleted counts a single failure')
assertEqual(attempt.pendingPassword, '', 'password failure scrubs pendingPassword')

attempt = runPasswordPam([['completed', 1], ['error', 1]])
assertEqual(attempt.failedAttempts, 1, 'password onCompleted followed by onError counts a single failure')

attempt = runPasswordPam([['error', 1]], false)
assertEqual(attempt.failedAttempts, 0, 'password error after unlock does not increment failedAttempts')
assertEqual(attempt.pendingPassword, '', 'password error after unlock still scrubs pendingPassword')
assertEqual(attempt.authenticatingPassword, false, 'password error after unlock clears authenticatingPassword')
// Exercise the real readlinkProc handler, Background.stillCacheEntry/stillPending,
// and lockWallpaperRequest without stubbing the desktop helpers.
const backgroundQml = fs.readFileSync(path.join(root, 'shell/plugins/background/Background.qml'), 'utf8')
const backgroundMediaQml = fs.readFileSync(path.join(root, 'shell/Ui/BackgroundMedia.qml'), 'utf8')
const readlinkBlock = serviceQml.match(/Process \{\s*id: readlinkProc[\s\S]*?\n  \}/)[0]
const streamFinishedBody = readlinkBlock.match(/onStreamFinished: \{([\s\S]*?)\n      \}/)[1]
const panelForScreenFn = backgroundQml.match(/function panelForScreen\(screen\) \{[\s\S]*?\n  \}/)
const stillCacheEntryFn = backgroundQml.match(/function stillCacheEntry\(screen, path, signature\) \{[\s\S]*?\n  \}/)
const stillPendingFn = backgroundQml.match(/function stillPending\(screen, path, signature\) \{[\s\S]*?\n  \}/)
const desktopStillEntryFn = serviceQml.match(/function desktopStillEntry\(screen\) \{[\s\S]*?\n  \}/)
const desktopStillPendingFn = serviceQml.match(/function desktopStillPending\(screen\) \{[\s\S]*?\n  \}/)
const lockRequestFn = serviceQml.match(/function lockWallpaperRequest\(screen, fallbackWidth, fallbackHeight\) \{[\s\S]*?\n  \}/)
const imageUrlExpr = backgroundMediaQml.match(/readonly property url imageUrl:\s*([^\n]+)/)[1]
const lockUrlExpr = serviceQml.match(/readonly property string lockWallpaperUrl:\s*([\s\S]*?\n\s*:\s*"")/)[1]
function evalImageUrl(pathVal, version, versionPrefix) {
  return require('vm').runInNewContext(`(${imageUrlExpr})`, {
    path: pathVal,
    video: false,
    version,
    versionPrefix,
    Util: { fileUrl: (p) => 'file://' + p }
  })
}
function evalLockUrl(lockWallpaperPath, backgroundVersion) {
  return require('vm').runInNewContext(`(${lockUrlExpr})`, {
    lockWallpaperPath,
    backgroundVersion,
    Util: { isVideoPath: () => false, fileUrl: (p) => 'file://' + p }
  })
}
assertEqual(evalImageUrl('/wall/a.webp', 0, 'v'), 'file:///wall/a.webp', 'desktop/shared version 0 uses unversioned URL')
assertEqual(evalImageUrl('/wall/a.webp', 1, 'v'), 'file:///wall/a.webp?v=1', 'desktop/shared BackgroundMedia URL uses ?v=')
assertEqual(evalImageUrl('/wall/a.webp', 0, 'lockv'), 'file:///wall/a.webp?lockv=0', 'unshared lock version 0 uses disjoint ?lockv=0 (never collides with desktop)')
assertEqual(evalImageUrl('/wall/a.webp', 1, 'lockv'), 'file:///wall/a.webp?lockv=1', 'lock overwrite BackgroundMedia URL uses disjoint ?lockv=')
assertEqual(evalLockUrl('/wall/a.webp', 0), 'file:///wall/a.webp?lockv=0', 'lock preload version 0 matches unshared LockView URL')
assertEqual(evalLockUrl('/wall/a.webp', 1), 'file:///wall/a.webp?lockv=1', 'lock preload URL matches lock overwrite BackgroundMedia URL')

function runReadlink(entries) {
  const ctx = {
    backgroundPath: '',
    videoPosterPath: 'old-poster.jpg',
    backgroundSignature: '',
    backgroundVersion: 0,
    posterRefreshes: 0,
    refreshPoster() { this.posterRefreshes += 1 }
  }
  ctx.root = ctx
  require('vm').runInNewContext(`function onFinished(text) {${streamFinishedBody}}`, ctx)
  const history = []
  for (const text of entries) {
    ctx.onFinished(text)
    history.push({ path: ctx.backgroundPath, version: ctx.backgroundVersion })
  }
  return history
}

// Sequence: A -> overwrite A -> B -> return to A (even with identical preserved mtime/size) -> overwrite A.
// Every path switch or overwrite advances lock backgroundVersion monotonically so unshared ?lockv= keys
// never reuse stale pixmaps, while shared desktop requests use desktop's reloadVersion (?v=).
const seq = runReadlink([
  '/wall/a.webp\n2026-11-28 10:00:00.100000000 +0000:256:1001\n',
  '/wall/a.webp\n2026-11-28 10:00:00.200000000 +0000:256:1001\n',
  '/wall/b.webp\n2026-11-28 10:00:00.300000000 +0000:512:1002\n',
  '/wall/a.webp\n2026-11-28 10:00:00.100000000 +0000:256:1001\n',
  '/wall/a.webp\n2026-11-28 10:00:00.500000000 +0000:256:1004\n'
])
assertEqual(seq[0].version, 1, 'initial load of A sets monotonic lock backgroundVersion 1')
assertEqual(seq[1].version, 2, 'in-place overwrite of A bumps lock backgroundVersion to 2')
assertEqual(seq[2].version, 3, 'switching to B advances lock backgroundVersion to 3')
assertEqual(seq[3].version, 4, 'returning to A advances lock backgroundVersion to 4 even if mtime/size matched')
assertEqual(seq[4].version, 5, 'subsequent overwrite of A advances lock backgroundVersion to 5')

// Wire the REAL Background helpers into lock/Service helpers.
const dp1 = { name: 'DP-1' }
const hdmi1 = { name: 'HDMI-A-1' }
const bgCtx = {
  displayedBackground: '/wall/a.webp',
  currentBackground: '/wall/a.webp',
  suspended: false,
  reloadVersion: 1,
  nativeSizes: { '/wall/a.webp': { width: 5120, height: 2880, signature: 'sig-a-1' } },
  readlinkProc: { running: false },
  sizeProbe: { running: false },
  sizeQueue: [],
  isVideo: (p) => /\.mp4$/.test(p),
  backgrounds: {
    instances: [{
      screen: dp1,
      backgroundReady: true,
      backgroundFailed: false,
      decodeSize: (p) => p === '/wall/a.webp' ? { width: 3840, height: 2160 } : { width: 0, height: 0 }
    }]
  }
}
require('vm').runInNewContext(`${panelForScreenFn[0]}\n${stillCacheEntryFn[0]}\n${stillPendingFn[0]}`, bgCtx)

const lockCtx = {
  videoBackground: false,
  readlinkProc: { running: false },
  lockRequested: false,
  backgroundPath: '/wall/a.webp',
  backgroundSignature: 'sig-a-1',
  backgroundVersion: 0,
  backgroundService: bgCtx
}
require('vm').runInNewContext(`${desktopStillEntryFn[0]}\n${desktopStillPendingFn[0]}\n${lockRequestFn[0]}`, lockCtx)

// Output with desktop panel shares desktop's physical size, reloadVersion, and ?v= prefix.
const reqDp1 = lockCtx.lockWallpaperRequest(dp1, 1920, 1080)
assertEqual(reqDp1.shared, true, 'output owned by desktop background shares cache even when reloadVersion > 0')
assertEqual(reqDp1.version, 1, 'shared request matches desktop reloadVersion')
assertEqual(reqDp1.versionPrefix, 'v', 'shared request uses desktop ?v= query prefix')
assertEqual(reqDp1.width, 3840, 'shared request matches desktop physical width')
assertEqual(reqDp1.height, 2160, 'shared request matches desktop physical height')

// In-place overwrite (signature mismatch) uses disjoint ?lockv= prefix so version 1 never collides with desktop ?v=1.
lockCtx.backgroundSignature = 'sig-a-overwritten'
lockCtx.backgroundVersion = 1
const reqOver = lockCtx.lockWallpaperRequest(dp1, 1920, 1080)
assertEqual(reqOver.shared, false, 'in-place overwrite falls back to cache-busted lock version')
assertEqual(reqOver.version, 1, 'in-place overwrite uses monotonic lock backgroundVersion')
assertEqual(reqOver.versionPrefix, 'lockv', 'in-place overwrite uses disjoint ?lockv= prefix')
lockCtx.backgroundSignature = 'sig-a-1'
lockCtx.backgroundVersion = 0

// Animated switch (displayedBackground still shows outgoing wallpaper): preload stays active.
bgCtx.displayedBackground = '/wall/outgoing.webp'
bgCtx.currentBackground = '/wall/a.webp'
assertEqual(lockCtx.desktopStillEntry(dp1), null, 'animated transition does not claim desktop cache before displayedBackground switches')
assertEqual(lockCtx.desktopStillPending(dp1), false, 'animated transition does not suppress lock preload')
bgCtx.displayedBackground = '/wall/a.webp'

// Unsized desktop panel (0x0 decodeSize, no probe running): preload stays active.
const origDecodeSize = bgCtx.backgrounds.instances[0].decodeSize
bgCtx.backgrounds.instances[0].decodeSize = () => ({ width: 0, height: 0 })
assertEqual(lockCtx.desktopStillEntry(dp1), null, '0x0 desktop decodeSize does not suppress lock preload')
assertEqual(lockCtx.desktopStillPending(dp1), false, '0x0 without active probe does not defer lock preload')

// Initial startup sizeProbe in flight: stillPending defers duplicate startup decode.
bgCtx.backgrounds.instances[0].backgroundReady = false
delete bgCtx.nativeSizes['/wall/a.webp']
bgCtx.sizeProbe.running = true
assertEqual(lockCtx.desktopStillEntry(dp1), null, 'stillCacheEntry stays null until decodeSize is non-zero')
assertEqual(lockCtx.desktopStillPending(dp1), true, 'stillPending defers duplicate preload while startup sizeProbe runs')
bgCtx.sizeProbe.running = false
bgCtx.nativeSizes['/wall/a.webp'] = { width: 5120, height: 2880, signature: 'sig-a-1' }
bgCtx.backgrounds.instances[0].backgroundReady = true
bgCtx.backgrounds.instances[0].decodeSize = origDecodeSize

// Suspended desktop background (e.g. OWE active): preload stays active.
bgCtx.suspended = true
assertEqual(lockCtx.desktopStillEntry(dp1), null, 'suspended desktop background does not suppress lock preload')
bgCtx.suspended = false

// Hotplugged output without a desktop panel yet falls back per-output instead of suppressing preload.
const reqHdmi = lockCtx.lockWallpaperRequest(hdmi1, 1920, 1080)
assertEqual(reqHdmi.shared, false, 'output without a desktop panel does not suppress preload')
assertEqual(reqHdmi.width, 1920, 'unowned output falls back to logical width')

// Video wallpaper never suppresses preload.
lockCtx.videoBackground = true
assertEqual(lockCtx.desktopStillEntry(dp1), null, 'video wallpaper keeps lock poster preload active')
lockCtx.videoBackground = false

// Desktop still decoding (backgroundReady: false): stillCacheEntry stays null so an active lock
// never drops a decoded fallback image, while unlocked stillPending avoids duplicate startup decode.
bgCtx.backgrounds.instances[0].backgroundReady = false
assertEqual(lockCtx.desktopStillEntry(dp1), null, 'in-flight desktop decode does not switch LockView before ready')
assertEqual(lockCtx.desktopStillPending(dp1), true, 'unlocked preload defers while desktop base decode is in flight')
lockCtx.lockRequested = true
assertEqual(lockCtx.desktopStillPending(dp1), false, 'active lock never defers to an unready desktop decode')
lockCtx.lockRequested = false
bgCtx.backgrounds.instances[0].backgroundReady = true

// First lock observation after desktop loaded earlier bytes (signature mismatch): never share stale desktop cache.
lockCtx.backgroundSignature = 'sig-a-2'
assertEqual(lockCtx.desktopStillEntry(dp1), null, 'signature mismatch against desktop probed signature rejects stale cache')
assertEqual(lockCtx.desktopStillPending(dp1), false, 'signature mismatch does not suppress lock preload')

// Missing desktop signature never allows blind sharing.
bgCtx.nativeSizes['/wall/a.webp'] = { width: 5120, height: 2880, signature: '' }
assertEqual(lockCtx.desktopStillEntry(dp1), null, 'missing desktop file signature rejects cache sharing')
bgCtx.nativeSizes['/wall/a.webp'] = { width: 5120, height: 2880, signature: 'sig-a-1' }
lockCtx.backgroundSignature = 'sig-a-1'

// Theme transition to wallpaper B with its own probed signature resumes cache sharing immediately.
bgCtx.displayedBackground = '/wall/b.webp'
bgCtx.nativeSizes['/wall/b.webp'] = { width: 5120, height: 2880, signature: 'sig-b-1' }
bgCtx.backgrounds.instances[0].decodeSize = (p) => p === '/wall/b.webp' ? { width: 3840, height: 2160 } : { width: 0, height: 0 }
lockCtx.backgroundPath = '/wall/b.webp'
lockCtx.backgroundSignature = 'sig-b-1'
assertEqual(lockCtx.lockWallpaperRequest(dp1, 1920, 1080).shared, true, 'theme transition shares cache once new still signature matches')

// Failed desktop decode must not suppress the unlocked lock preload.
bgCtx.backgrounds.instances[0].backgroundReady = false
bgCtx.backgrounds.instances[0].backgroundFailed = true
assertEqual(lockCtx.desktopStillPending(dp1), false, 'failed desktop decode does not suppress lock preload')
bgCtx.backgrounds.instances[0].backgroundFailed = false
bgCtx.backgrounds.instances[0].backgroundReady = true

// Returning to an overwritten path after switching away bumps desktop reloadVersion so
// neither desktop nor lock reuses a retained Qt pixmap with stale pixels.
const sizeProbeBlock = backgroundQml.match(/Process \{\s*id: sizeProbe[\s\S]*?\n  \}/)[0]
const sizeProbeExited = sizeProbeBlock.match(/onExited: function\(exitCode\) \{([\s\S]*?)\n    \}/)[1]
const probeCtx = {
  path: '/wall/a.webp',
  nativeSizes: {},
  seenPathSignatures: {},
  reloadVersion: 0,
  sizeQueue: ['/wall/a.webp'],
  sizeProbeOut: { text: '' },
  probeNextSize() {}
}
probeCtx.root = probeCtx
probeCtx.sizeProbe = probeCtx
require('vm').runInNewContext(`function runExited(exitCode) {${sizeProbeExited}}`, probeCtx)
probeCtx.sizeProbeOut.text = '1920 1080\nsig-1\n'
probeCtx.runExited(0)
assertEqual(probeCtx.reloadVersion, 0, 'first sizeProbe of A keeps reloadVersion 0')
probeCtx.nativeSizes = {} // pruned after switching away to B
probeCtx.sizeProbeOut.text = '1920 1080\nsig-2\n'
probeCtx.runExited(0)
assertEqual(probeCtx.reloadVersion, 1, 're-probing overwritten A after switch-away bumps desktop reloadVersion')

// Transient /background-transitions/ snapshots must not grow seenPathSignatures.
probeCtx.path = '/home/user/.cache/omarchy/background-transitions/next-1234'
probeCtx.sizeProbeOut.text = '1920 1080\nsig-tmp\n'
probeCtx.runExited(0)
assertEqual(probeCtx.seenPathSignatures[probeCtx.path], undefined, 'transient transition snapshot is not retained in seenPathSignatures')

// While readlinkProc is refreshing after desktop switched A -> B, unlocked preload defers instead of decoding outgoing A.
bgCtx.displayedBackground = '/wall/c.webp'
lockCtx.backgroundPath = '/wall/b.webp'
lockCtx.readlinkProc.running = true
assertEqual(lockCtx.desktopStillPending(dp1), true, 'readlinkProc refresh after desktop switch defers outgoing still preload')
lockCtx.readlinkProc.running = false

JS
