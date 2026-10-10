#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

export PATH="$ROOT/bin:$PATH"
require_command node
require_command python3

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
home="$work/home"
mkdir -p "$home/.config"
extension="$ROOT/default/chromium/extensions/webapp-links"

# The setting is opt-in and must survive browser config replacement without
# imposing the extension on profiles that the user hasn't enabled.
cp "$ROOT/config/chromium-flags.conf" "$home/.config/chromium-flags.conf"
printf '%s\n' '--user-data-dir=/some/profile' >"$home/.config/chrome-flags.conf"
printf '%s\n' '--load-extension=/other/extension' '--other-brave-flag' >"$home/.config/brave-origin-flags.conf"
printf '%s\n' '--some-edge-flag' >"$home/.config/microsoft-edge-stable-flags.conf"
for file in chromium-flags.conf chrome-flags.conf brave-origin-flags.conf microsoft-edge-stable-flags.conf; do
  cp "$home/.config/$file" "$work/$file.original"
done
[[ ! -e $home/.local/state/omarchy/toggles/webapp-links ]] || fail "web app routing starts disabled"
HOME="$home" OMARCHY_PATH="$ROOT" omarchy-toggle-webapp-links on >/dev/null
HOME="$home" OMARCHY_PATH="$ROOT" omarchy-toggle-webapp-links on >/dev/null
for file in chromium-flags.conf chrome-flags.conf brave-origin-flags.conf microsoft-edge-stable-flags.conf; do
  count=$(grep -oF "$extension" "$home/.config/$file" | wc -l)
  (( count == 1 )) || fail "enabling web app links adds extension exactly once: $file" "$count"
done
grep -qF '/other/extension' "$home/.config/brave-origin-flags.conf" || fail "toggle preserves other Brave extensions"
grep -qF -- '--some-edge-flag' "$home/.config/microsoft-edge-stable-flags.conf" || fail "toggle preserves other Edge flags"
pass "opt-in enables Chromium, Chrome, Brave Origin, and Edge without changing other flags"
cp "$ROOT/config/chromium-flags.conf" "$home/.config/chromium-flags.conf"
HOME="$home" OMARCHY_PATH="$ROOT" omarchy-toggle-webapp-links on >/dev/null
count=$(grep -oF "$extension" "$home/.config/chromium-flags.conf" | wc -l)
(( count == 1 )) || fail "refresh reapplies opted-in extension" "$count"
pass "browser configuration replacement can restore enabled routing"

node - "$extension/manifest.json" "$home/.config/chromium/NativeMessagingHosts/com.omarchy.webapp_links.json" "$ROOT/bin/omarchy-chromium-webapp-links-host" <<'JS'
const fs = require('fs'), crypto = require('crypto'), assert = require('assert/strict')
const manifest = JSON.parse(fs.readFileSync(process.argv[2]))
const host = JSON.parse(fs.readFileSync(process.argv[3]))
const hash = crypto.createHash('sha256').update(Buffer.from(manifest.key, 'base64')).digest()
const id = [...hash.subarray(0, 16)].map(n => String.fromCharCode(97 + (n >> 4), 97 + (n & 15))).join('')
assert.equal(host.allowed_origins[0], `chrome-extension://${id}/`)
assert.equal(host.path, process.argv[4])
assert.deepEqual(manifest.content_scripts[0].js, ['policy.js', 'links.js'])
console.log('ok - registered native host belongs to the actual bundled extension')
JS
[[ -f $home/.config/google-chrome/NativeMessagingHosts/com.omarchy.webapp_links.json ]] || fail "Chrome host not registered"
[[ -f $home/.config/BraveSoftware/Brave-Origin/NativeMessagingHosts/com.omarchy.webapp_links.json ]] || fail "Brave Origin host not registered"
[[ -f $home/.config/microsoft-edge/NativeMessagingHosts/com.omarchy.webapp_links.json ]] || fail "Edge host not registered"
pass "Chromium-family profiles receive native host registration"

HOME="$home" OMARCHY_PATH="$ROOT" omarchy-toggle-webapp-links off >/dev/null
[[ ! -e $home/.config/chromium/NativeMessagingHosts/com.omarchy.webapp_links.json ]] || fail "disabling removes native host"
[[ ! -e $home/.local/state/omarchy/toggles/webapp-links ]] || fail "disabling clears opt-in state"
for file in chromium-flags.conf chrome-flags.conf brave-origin-flags.conf microsoft-edge-stable-flags.conf; do
  cmp -s "$home/.config/$file" "$work/$file.original" || fail "disabling restores unrelated browser flags: $file"
done
pass "disabling removes only web app routing"

ROOT="$ROOT" node <<'JS'
const fs = require('fs'), vm = require('vm'), assert = require('assert/strict')
const dir = `${process.env.ROOT}/default/chromium/extensions/webapp-links`
const policyCode = fs.readFileSync(`${dir}/policy.js`, 'utf8')
const clickCode = fs.readFileSync(`${dir}/links.js`, 'utf8')
const backgroundCode = fs.readFileSync(`${dir}/background.js`, 'utf8')

const allowed = { 'https://app.example.com': ['https://cdn.example.com', 'https://login.identity.net'] }
function click({ source = 'https://app.example.com/home', destination = 'https://news.other.net/story', standalone = true, target = '', opened = true, missing = false, policyMissing = false, download = false, modified = false }) {
  let listener, prevented = false, stopped = false, assigned = '', sent = []
  const link = { href: destination, target, hasAttribute: name => name === 'download' && download, matches: () => true }
  const context = {
    URL, location: { href: source, assign: url => { assigned = url } },
    matchMedia: () => ({ matches: standalone }), Element: class {},
    document: { addEventListener: (_type, callback) => { listener = callback } },
    chrome: { runtime: { lastError: null,
      sendMessage: (message, done) => {
        if (message.action === 'policy') {
          context.chrome.runtime.lastError = policyMissing ? { message: 'missing host' } : null
          done(policyMissing ? null : { origins: allowed })
        } else {
          sent.push(message.url)
          context.chrome.runtime.lastError = missing ? { message: 'host vanished' } : null
          done(opened)
        }
      } } }
  }
  Object.setPrototypeOf(link, context.Element.prototype)
  vm.createContext(context)
  vm.runInContext(policyCode + '\n' + clickCode, context)
  listener({ button: 0, defaultPrevented: false, ctrlKey: modified, metaKey: false,
    shiftKey: false, altKey: false, composedPath: () => [link],
    preventDefault: () => { prevented = true }, stopImmediatePropagation: () => { stopped = true } })
  return { prevented, stopped, assigned, sent }
}
assert.deepEqual(click({ standalone: false }).sent, [])
assert.equal(click({ standalone: false }).prevented, false)
assert.equal(click({ policyMissing: true }).prevented, false)
assert.equal(click({ destination: 'https://app.example.com/about' }).prevented, false)
assert.equal(click({ destination: 'https://cdn.example.com/image' }).prevented, false)
assert.equal(click({ destination: 'https://login.identity.net/authorize?client_id=a' }).prevented, false)
assert.equal(click({ source: 'https://login.identity.net/oauth2/auth', destination: 'https://app.example.com/callback' }).prevented, false)
assert.equal(click({ destination: 'javascript:alert(1)' }).prevented, false)
assert.equal(click({ target: '_blank' }).prevented, false)
assert.equal(click({ modified: true }).prevented, false)
assert.equal(click({ download: true }).prevented, false)
assert.deepEqual(click({ destination: 'https://www.example.com/about' }).sent, ['https://www.example.com/about'])
assert.deepEqual(click({}).sent, ['https://news.other.net/story'])
assert.equal(click({}).stopped, true)
assert.equal(click({ missing: true }).assigned, 'https://news.other.net/story')
assert.equal(click({ opened: false }).assigned, 'https://news.other.net/story')
console.log('ok - app clicks respect exact-origin allowances and recover from unavailable host')

async function popup({ source = 'https://app.example.com/home', destination = 'https://news.other.net/story', standalone = true, opened = true, missing = false, frameId = 0 }) {
  let popupListener, removed = [], sent = [], framesRequested
  const chrome = {
    runtime: { lastError: null, onMessage: { addListener: () => {} },
      sendNativeMessage: (_name, message, done) => {
        sent.push(message)
        chrome.runtime.lastError = missing ? { message: 'host unavailable' } : null
        done({ opened: opened && !['https://login.identity.net', 'https://cdn.example.com'].includes(new URL(message.url).origin) })
      } },
    webNavigation: { onCreatedNavigationTarget: { addListener: fn => { popupListener = fn } } },
    scripting: { executeScript: async ({ target }) => {
      framesRequested = target.frameIds
      return target.frameIds.map(id => ({ frameId: id, result: { standalone, url: source } }))
    } },
    tabs: { remove: async id => { removed.push(id) } }
  }
  const context = { URL, chrome, importScripts: () => vm.runInContext(policyCode, context) }
  vm.createContext(context)
  vm.runInContext(backgroundCode, context)
  await popupListener({ url: destination, sourceTabId: 1, sourceFrameId: frameId, tabId: 2 })
  return { removed, sent, framesRequested }
}
;(async () => {
  assert.deepEqual((await popup({ standalone: false })).sent, [])
  assert.deepEqual((await popup({ destination: 'https://app.example.com/callback' })).sent, [])
  assert.deepEqual((await popup({ destination: 'about:blank' })).sent, [])
  assert.deepEqual((await popup({})).removed, [2])
  assert.equal((await popup({})).sent[0].source, 'https://app.example.com/home')
  assert.deepEqual(Array.from((await popup({ frameId: 5 })).framesRequested), [0, 5])
  assert.deepEqual((await popup({ destination: 'https://login.identity.net/authorize?client_id=app' })).removed, [])
  assert.deepEqual((await popup({ destination: 'https://cdn.example.com/assets' })).removed, [])
  assert.deepEqual((await popup({ opened: false })).removed, [])
  assert.deepEqual((await popup({ missing: true })).removed, [])
  console.log('ok - popup routing preserves ordinary tabs, configured auth and failed native launches')
})().catch(error => { console.error(error); process.exitCode = 1 })
JS

# Drive the actual native-message framing/URL checks with an isolated xdg-open
# boundary; no real browser or active user configuration is touched.
mkdir -p "$home/.config/omarchy"
cat >"$home/.config/omarchy/webapp-links.json" <<'JSON'
{
  "https://app.example.com": ["https://cdn.example.com", "https://login.identity.net"]
}
JSON

HOME="$home" python3 - "$ROOT/bin/omarchy-chromium-webapp-links-host" <<'PY'
import importlib.machinery
import io
import json
import os
import struct
import sys
from unittest.mock import Mock

module = importlib.machinery.SourceFileLoader('webapp_links_host', sys.argv[1]).load_module()
original_stdin, original_stdout, original_run = sys.stdin, sys.stdout, module.subprocess.run

class Stream:
    def __init__(self, buffer):
        self.buffer = buffer

allowed = {'https://app.example.com': ['https://cdn.example.com', 'https://login.identity.net']}
source = 'https://app.example.com/home'
try:
    for message, expected, launches in [
        ({'action': 'policy'}, {'origins': allowed}, 0),
        ({'url': 'https://news.other.net/watch?a=1&b=2', 'source': source}, {'opened': True}, 1),
        ({'url': 'https://app.example.com/about', 'source': source}, {'opened': False, 'allowed': True}, 0),
        ({'url': 'https://cdn.example.com/assets', 'source': source}, {'opened': False, 'allowed': True}, 0),
        ({'url': 'https://login.identity.net/authorize', 'source': source}, {'opened': False, 'allowed': True}, 0),
        ({'url': 'https://app.example.com/callback', 'source': 'https://login.identity.net/oauth2/auth'}, {'opened': False, 'allowed': True}, 0),
        ({'url': 'https://www.example.com/about', 'source': source}, {'opened': True}, 1),
        ({'url': 'javascript:alert(1)', 'source': source}, {'opened': False}, 0),
        ({'url': 'https://evil.com\n--flag', 'source': source}, {'opened': False}, 0),
        ({'url': 'https://user:password@example.com/', 'source': source}, {'opened': False}, 0),
        ({'url': 3, 'source': source}, {'opened': False}, 0),
        ({'url': 'https://example.com/path', 'source': source}, {'opened': False}, 1),
        ({'url': 'https://example.com/path'}, {'opened': False}, 0),
        ([], {'opened': False}, 0),
    ]:
        payload = json.dumps(message).encode()
        input_bytes = struct.pack('<I', len(payload)) + payload
        sys.stdin, sys.stdout = Stream(io.BytesIO(input_bytes)), Stream(io.BytesIO())
        calls = []
        def run(args, **kwargs):
            calls.append((args, kwargs))
            if isinstance(message, dict) and isinstance(message.get('url'), str) and message['url'].endswith('/path'):
                return Mock(returncode=1)
            return Mock(returncode=0)
        module.subprocess.run = run
        os.environ['BROWSER'] = 'a-different-browser'
        module.main()
        response = sys.stdout.buffer.getvalue()
        size, = struct.unpack('<I', response[:4])
        assert len(response[4:]) == size
        assert json.loads(response[4:]) == expected, message
        assert len(calls) == launches
        if calls:
            assert calls[0][0] == ['/usr/bin/xdg-open', message['url']]
            assert 'BROWSER' not in calls[0][1]['env']
    print('ok - native host validates URLs, honors desktop default, and reports launcher failure', file=sys.stderr)
finally:
    sys.stdin, sys.stdout, module.subprocess.run = original_stdin, original_stdout, original_run
    os.environ.pop('BROWSER', None)
PY
