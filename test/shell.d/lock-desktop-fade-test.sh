#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

// Pull a top-level QML function out of the service so it can run against a
// stand-in for the service's properties.
function extractFunction(name) {
  const start = serviceQml.indexOf(`  function ${name}(`)
  if (start < 0) fail(`Service.qml defines ${name}`)
  const end = serviceQml.indexOf('\n  }\n', start)
  const source = serviceQml.slice(start, end + 4)
  const params = source.slice(source.indexOf('(') + 1, source.indexOf(')'))
  const body = source.slice(source.indexOf('{') + 1, source.lastIndexOf('}'))
  return { params, body }
}

// Unlock fade: the session lock is held until the fade completes, a blank
// display skips it, and a lock request during it keeps the screen locked.
const finish = extractFunction('finishUnlock')
const cancel = extractFunction('cancelUnlockTransition')

function makeUnlockService(displaysBlank) {
  const calls = []
  const svc = {
    root: { locked: true },
    lockRequested: true,
    unlocking: false,
    displaysBlank,
    calls,
    idleBlankTimer: { stop() { calls.push('blank-stop') } },
    unlockTransitionTimer: { restart() { calls.push('fade-start') }, stop() { calls.push('fade-stop') } },
    completeUnlock() { calls.push('release') },
    resetAuthenticationState() { calls.push('reset') },
    armBlankTimer() {},
    startFingerprint() { calls.push('fingerprint') },
    unlockSeeThrough: false,
    lockFadingIn: false,
    xrayPurpose: '',
    finishLockFadeIn() { svc.lockFadingIn = false; calls.push('lock-opaque') },
    setSessionLockXray(enabled) { calls.push(enabled ? 'xray-on' : 'xray-off') },
    logEvent() {}
  }
  svc.finish = new Function('svc', `with (svc) {${finish.body}}`).bind(null, svc)
  svc.cancel = new Function('svc', `with (svc) {${cancel.body}}`).bind(null, svc)
  return svc
}

const awake = makeUnlockService(false)
awake.finish()
assert(awake.unlocking && awake.calls.includes('fade-start') && !awake.calls.includes('release'),
  'a successful unlock fades first and keeps the session locked meanwhile')
assert(awake.calls.includes('xray-on') && !awake.unlockSeeThrough,
  'the unlock asks for the desktop under the lock but stays opaque until Hyprland confirms')
awake.finish()
assertEqual(awake.calls.filter(c => c === 'fade-start').length, 1, 'a second success during the fade does not restart it')
awake.unlockSeeThrough = true
awake.cancel()
assert(!awake.unlockSeeThrough && awake.calls.lastIndexOf('xray-off') > awake.calls.indexOf('xray-on'),
  'cancelling the fade turns the lock opaque again and stops rendering the desktop under it')
assert(!awake.unlocking && awake.calls.includes('fade-stop') && awake.calls.includes('fingerprint') && !awake.calls.includes('release'),
  'cancelling the fade stays locked and re-arms fingerprint auth')

const blank = makeUnlockService(true)
blank.finish()
assert(!blank.unlocking && blank.calls.includes('release'), 'with the display off the lock is released without a fade')

assert(
  /if \(purpose === "unlock" && root\.unlocking\)/.test(serviceQml)
    && /if \(!root\.unlockSeeThrough && !root\.lockFadingIn\) root\.setSessionLockXray\(false\)/.test(serviceQml),
  'xray confirmed after the unlock was cancelled or finished is switched straight back off'
)
assert(
  /lockRevealed = false\s*unlockSeeThrough = false\s*lockFadingIn = false/.test(serviceQml),
  'every lock starts opaque until Hyprland confirms the desktop renders underneath'
)
assert(
  /sessionLock\.locked = false\s*\/\/[^\n]*\n\s*unlockSeeThrough = false/.test(serviceQml),
  'the view stays see-through only until the lock is released'
)
assert(
  /if \(root\.unlocking\) root\.cancelUnlockTransition\(\)/.test(serviceQml),
  'a lock request during the unlock fade cancels it'
)
assert(
  /inputEnabled: root\.lockRequested && !root\.unlocking/.test(serviceQml),
  'password input is disabled during the unlock fade'
)

// Lock reveal: hidden from the lock request, revealed only once the session
// lock is secure, so the fade-in never runs ahead of the actual lock.
assert(
  /lockRequested = true\s*lockRevealed = false/.test(serviceQml),
  'a lock request hides the lock content until the lock is up'
)
assert(
  /if \(secure\) \{[\s\S]*?lockRevealTimer\.restart\(\)/.test(serviceQml),
  'the reveal starts only after the session lock is secure'
)
assert(
  /id: lockRevealTimer[\s\S]*?onTriggered: root\.lockRevealed = true/.test(serviceQml),
  'the reveal timer shows the lock content'
)

// Lock fade-in over the desktop: never reported secure until opaque (the
// sleep path waits on that), and only for surfaces created after Hyprland
// confirmed it renders the desktop underneath.
assert(
  /secure: sessionLock\.secure && !root\.lockFadingIn && !root\.unlocking,/.test(serviceQml),
  'the lock is not reported secure while fading in or out over the desktop'
)
assert(
  /id: xrayOffProc[\s\S]*?if \(xrayOffRetry\.attempts < 3\) xrayOffRetry\.restart\(\)/.test(serviceQml),
  'a failed request to stop rendering the desktop under the lock is retried, a bounded number of times'
)
assert(
  /if \(enabled\) \{\s*(?:\/\/.*\s*)?xrayOffRetry\.stop\(\)/.test(serviceQml) &&
    /id: xrayOffRetry[\s\S]*?onTriggered: \{\s*if \(root\.xrayPurpose !== "" \|\| root\.unlockSeeThrough \|\| root\.lockFadingIn\) return/.test(serviceQml),
  'a pending retry never stops rendering the desktop under a later fade'
)
assert(
  /purpose === "lock" && confirmed && root\.lockRequested && !sessionLock\.locked/.test(serviceQml),
  'the desktop fade-in only applies to a lock whose surfaces do not exist yet'
)
assert(
  /if \(xrayPurpose === "lock"\) \{\s*xrayPurpose = ""\s*setSessionLockXray\(false\)\s*\}\s*sessionLock\.locked = true/.test(serviceQml),
  'an unconfirmed fade-in request is dropped before the lock surfaces are created'
)
const fadeDone = extractFunction('finishLockFadeIn')
assert(/lockFadingIn = false[\s\S]*setSessionLockXray\(false\)/.test(fadeDone.body),
  'once the lock is opaque the desktop stops rendering under it')
assert(
  /id: lockFadeInFallback[\s\S]*?onTriggered: root\.finishLockFadeIn\(\)/.test(serviceQml),
  'a fade-in that never reports back is forced opaque'
)
const viewFaded = extractFunction('lockViewFadedIn')
function makeFadeService(screens) {
  const calls = []
  const svc = {
    lockFadingIn: true,
    lockFadedScreens: {},
    calls,
    realScreenCount() { return screens },
    finishLockFadeIn() { svc.lockFadingIn = false; calls.push('lock-opaque') }
  }
  svc.viewFadedIn = new Function('svc', viewFaded.params, `with (svc) {${viewFaded.body}}`).bind(null, svc)
  return svc
}
const twoScreens = makeFadeService(2)
twoScreens.viewFadedIn('DP-1')
twoScreens.viewFadedIn('DP-1')
assert(twoScreens.lockFadingIn, 'one screen finishing its fade leaves the others fading')
twoScreens.viewFadedIn('eDP-1')
assert(!twoScreens.lockFadingIn && twoScreens.calls.length === 1, 'the lock turns opaque once every screen has faded in')
assert(
  /if \(secure\) \{[\s\S]*?if \(root\.lockFadingIn\) lockFadeInFallback\.restart\(\)/.test(serviceQml),
  'the see-through window is bounded from the moment the lock is secure'
)
assert(
  /root\.lockFadedScreens = \(\{\}\)\s*root\.lockFadingIn = true/.test(serviceQml),
  'every fade-in starts with no screen counted as faded'
)
const viewQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/LockView.qml'), 'utf8')
assert(
  /onRevealedChanged: syncDesktopFade\(\)/.test(viewQml) && !/lockShown/.test(viewQml),
  'the fade-in over the desktop starts on reveal, without waiting for the wallpaper'
)
assert(
  /color: root\.unlockSeeThrough \|\| root\.lockFadingIn \? "transparent" : Color\.background/.test(serviceQml),
  'the lock surface is transparent only while fading over the desktop'
)
JS
