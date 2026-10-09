#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'default/vivaldi/omarchy-theme-loader.js'), 'utf8')
const channels = new Map()
const channelPath = home => home + '/.local/state/omarchy/vivaldi/theme.json'
const palette = (bg, radius = -1) => JSON.stringify({
  colors: {bg, fg: '#ffffff', accent: '#00aaff', lighterBg: '#555555'},
  radius, dimBlurred: false, blur: 0, contrast: 0, alpha: null
})
const flush = () => new Promise(resolve => setImmediate(resolve))

function startLoader(home) {
  const state = {
    'vivaldi.themes.user': [],
    'vivaldi.theme.schedule.o_s': {}
  }
  const errors = []
  const reads = []
  const style = {textContent: ''}
  let poll, failSave = false, saves = 0, envReads = 0
  const api = {
    utilities: {
      async getEnvVars() { envReads++; return {HOME: home} }
    },
    mailPrivate: {
      async readFileToText(file) {
        reads.push(file)
        if (!channels.has(file)) throw new Error('Error reading file')
        return channels.get(file)
      }
    },
    prefs: {
      async get(key) { return {value: structuredClone(state[key])} },
      async set({path, value}) {
        if (failSave) throw new Error('Preference write rejected')
        saves++
        state[path] = structuredClone(value)
      }
    }
  }
  vm.runInNewContext(source, {
    window: {vivaldi: api, crypto: {randomUUID: () => 'theme-' + home}},
    document: {getElementById: () => style},
    console: {error: (...args) => errors.push(args.map(String).join(' '))},
    fetch: () => { throw new Error('The loader must never fetch a shared resource') },
    setInterval: fn => { poll = fn }
  })
  return {
    state, errors, reads, style, api,
    async tick() { await poll(); await flush() },
    failSave(value) { failSave = value },
    saves: () => saves,
    envReads: () => envReads
  }
}

;(async () => {
  const homeA = '/home/user-a'
  const homeB = '/home/user-b'
  channels.set(channelPath(homeA), palette('#123456'))
  channels.set(channelPath(homeB), palette('#abcdef', 7))
  const a = startLoader(homeA)
  const b = startLoader(homeB)
  await flush()
  assert(a.style.textContent.includes('--colorBg: #123456 !important'),
    'the first loader applies its private channel to CSS')
  assert(b.style.textContent.includes('--colorBg: #abcdef !important'),
    'the second loader applies its private channel to CSS')
  assertEqual(a.state['vivaldi.themes.user'][0].colorBg, '#123456',
    'the first loader persists its own theme')
  assertEqual(b.state['vivaldi.themes.user'][0].colorBg, '#abcdef',
    'the second loader persists its own theme')
  const id = a.state['vivaldi.themes.user'][0].id
  channels.set(channelPath(homeA), palette('#654321', 9))
  await a.tick()
  await b.tick()
  assertEqual(a.state['vivaldi.themes.user'][0].radius, 9,
    'appearance changes reach the running browser')
  assertEqual(a.state['vivaldi.themes.user'][0].id, id,
    'live updates reuse the existing native theme')
  assertEqual(b.state['vivaldi.themes.user'][0].colorBg, '#abcdef',
    'one user changing themes does not change another user')
  assert(a.reads.every(file => file === channelPath(homeA)) &&
    b.reads.every(file => file === channelPath(homeB)), 'loaders only read their own channel')
  assertEqual(a.envReads(), 1, 'the loader resolves its home once, not on every poll')

  const saved = a.saves()
  await a.tick()
  assertEqual(a.saves(), saved, 'unchanged channel data does not rewrite preferences')
  channels.delete(channelPath(homeA))
  await a.tick()
  await a.tick()
  assertEqual(a.errors.length, 1, 'a missing channel logs once while retries continue')
  assertEqual(a.state['vivaldi.themes.user'][0].colorBg, '#654321',
    'a missing channel leaves the user theme intact instead of importing another palette')
  channels.set(channelPath(homeA), palette('#112233'))
  await a.tick()
  channels.delete(channelPath(homeA))
  await a.tick()
  assertEqual(a.errors.length, 2, 'a successful channel read resets the read-error marker')

  channels.set(channelPath(homeA), palette('#445566'))
  a.failSave(true)
  await a.tick()
  await a.tick()
  assert(a.style.textContent.includes('--colorBg: #445566 !important'),
    'CSS still updates when native preference saving fails')
  assertEqual(a.state['vivaldi.themes.user'][0].colorBg, '#112233',
    'failed preference saving does not pretend the native theme was updated')
  const saveErrors = () => a.errors.filter(error => error.includes('Vivaldi theme save failed'))
  assertEqual(saveErrors().length, 1,
    'a preference save failure logs once, independently of successful channel reads')
  a.failSave(false)
  await a.tick()
  assertEqual(a.state['vivaldi.themes.user'][0].colorBg, '#445566',
    'a failed save is retried and persists after recovery')
  channels.set(channelPath(homeA), palette('#778899'))
  a.failSave(true)
  await a.tick()
  assertEqual(saveErrors().length, 2, 'a successful save resets the save-error marker')

  const noHome = startLoader('')
  await flush()
  await noHome.tick()
  assertEqual(noHome.reads.length, 0, 'missing HOME never falls back to a shared file')
  assertEqual(noHome.errors.length, 1, 'missing HOME is reported without repeated console noise')
  const fileApi = b.api.mailPrivate
  delete b.api.mailPrivate
  await b.tick()
  await b.tick()
  assertEqual(b.errors.length, 1, 'an unavailable file API is reported without a global fallback')
  b.api.mailPrivate = fileApi
  channels.set(channelPath(homeB), palette('#aabbcc'))
  await b.tick()
  assertEqual(b.state['vivaldi.themes.user'][0].colorBg, '#aabbcc',
    'the loader recovers when the native file API becomes available')
})().catch(error => fail('Vivaldi loader checks complete', error.stack))
JS
