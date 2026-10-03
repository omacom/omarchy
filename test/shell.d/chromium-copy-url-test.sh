#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

export PATH="$ROOT/bin:$PATH"

TMPDIR=""

cleanup() {
  if [[ -n $TMPDIR && -d $TMPDIR ]]; then
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT

require_command jq
require_command node

copy_url_id=$(node - <<'JS' "$ROOT/default/chromium/extensions/copy-url/manifest.json"
const crypto = require('crypto')
const fs = require('fs')

const manifest = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'))
const hash = crypto.createHash('sha256').update(Buffer.from(manifest.key, 'base64')).digest()
const alphabet = 'abcdefghijklmnop'
let id = ''

for (const byte of hash.subarray(0, 16)) {
  id += alphabet[byte >> 4]
  id += alphabet[byte & 0x0f]
}

process.stdout.write(id)
JS
)

[[ $copy_url_id == "bgpiichlckmfanooecilcjemknkcpngb" ]] ||
  fail "copy-url extension manifest has the stable id" "$copy_url_id"
pass "copy-url extension manifest has the stable id"

jq -e '
  .manifest_version == 3 and
  (.permissions | index("nativeMessaging")) and
  (.permissions | index("webNavigation")) and
  (.permissions | index("notifications") | not) and
  (.permissions | index("clipboardWrite") | not) and
  (.permissions | index("offscreen") | not) and
  .background.service_worker == "background-5.js"
' "$ROOT/default/chromium/extensions/copy-url/manifest.json" >/dev/null ||
  fail "copy-url extension uses its native messaging host"
grep -q "sendNativeMessage('com.omarchy.copy_url'" \
  "$ROOT/default/chromium/extensions/copy-url/background-5.js" ||
  fail "copy-url extension sends URLs to its native messaging host"
pass "copy-url extension uses its native messaging host"

jq -e '.action != null' "$ROOT/default/chromium/extensions/copy-url/manifest.json" >/dev/null &&
  grep -q 'action.onClicked' "$ROOT/default/chromium/extensions/copy-url/"background-*.js ||
  fail "copy-url extension is clickable from the toolbar"
pass "copy-url extension is clickable from the toolbar"

ROOT="$ROOT" node <<'JS'
const path = require('path')

const listeners = {}
const removedTabs = []
const nativeMessages = []
let sourceWindowType = 'normal'
let nativeResponse = { opened: true }
let nativeError

global.chrome = {
  action: { onClicked: { addListener(listener) { listeners.action = listener } } },
  commands: { onCommand: { addListener(listener) { listeners.command = listener } } },
  runtime: {
    sendNativeMessage(host, message, callback) {
      nativeMessages.push({ host, message })
      callback(nativeResponse)
    },
    get lastError() { return nativeError },
  },
  tabs: {
    async get() { return { windowId: 7 } },
    query() {},
    async remove(tabId) { removedTabs.push(tabId) },
  },
  webNavigation: {
    onCreatedNavigationTarget: {
      addListener(listener) { listeners.navigationTarget = listener },
    },
  },
  windows: {
    async get() { return { type: sourceWindowType } },
  },
}

require(path.join(process.env.ROOT, 'default/chromium/extensions/copy-url/background-5.js'))

function assert(condition, message) {
  if (!condition) throw new Error(message)
}

;(async () => {
  sourceWindowType = 'app'
  await listeners.navigationTarget({ sourceTabId: 1, tabId: 2, url: 'https://example.test/path?q=one' })
  assert(removedTabs.length === 1 && removedTabs[0] === 2, 'web app target tab was not removed')
  assert(nativeMessages.length === 1, 'web app target was not sent to the native host')
  assert(nativeMessages[0].host === 'com.omarchy.copy_url', 'unexpected native host')
  assert(nativeMessages[0].message.action === 'open', 'native message did not request an open')
  assert(nativeMessages[0].message.url === 'https://example.test/path?q=one', 'native message changed the URL')

  sourceWindowType = 'normal'
  await listeners.navigationTarget({ sourceTabId: 3, tabId: 4, url: 'https://example.test/ordinary' })
  assert(removedTabs.length === 1 && nativeMessages.length === 1, 'ordinary browser target was intercepted')

  sourceWindowType = 'app'
  await listeners.navigationTarget({ sourceTabId: 5, tabId: 6, url: 'mailto:hello@example.test' })
  assert(removedTabs.length === 1 && nativeMessages.length === 1, 'non-http target was intercepted')

  nativeResponse = undefined
  nativeError = { message: 'native host is missing' }
  await listeners.navigationTarget({ sourceTabId: 7, tabId: 8, url: 'https://example.test/fallback' })
  assert(removedTabs.length === 1, 'target was removed after a failed native handoff')
  assert(nativeMessages.length === 2, 'failed native handoff was not attempted')
})().catch((error) => {
  console.error(error.message)
  process.exit(1)
})
JS
pass "copy-url extension hands new web app targets to the default browser"

TMPDIR=$(mktemp -d)
test_home="$TMPDIR/home"
native_manifest="$test_home/.config/chromium/NativeMessagingHosts/com.omarchy.copy_url.json"

HOME="$test_home" OMARCHY_PATH="$ROOT" omarchy-install-chromium-copy-url

[[ -f $native_manifest ]] || fail "copy-url native host installer creates fresh Chromium profile root"
jq -e --arg path "$ROOT/bin/omarchy-chromium-copy-url-host" '
  .name == "com.omarchy.copy_url" and
  .path == $path and
  (.allowed_origins | index("chrome-extension://bgpiichlckmfanooecilcjemknkcpngb/"))
' "$native_manifest" >/dev/null || fail "copy-url native host manifest uses Omarchy host path and extension id"
pass "copy-url native host installer registers the stable extension id"

[[ -f $test_home/.config/BraveSoftware/Brave-Origin/NativeMessagingHosts/com.omarchy.copy_url.json ]] ||
  fail "copy-url native host installer covers Brave Origin"
pass "copy-url native host installer covers Brave Origin"

# Chromium ships in the base packages, so fresh installs do not go through
# omarchy-install-browser, and they mark every migration as already applied.
# The user install still has to register the host itself.
grep -q 'user/chromium.sh' "$ROOT/install/user/all.sh" ||
  fail "user install runs the Chromium native messaging host setup"

fresh_home="$TMPDIR/fresh-install"
HOME="$fresh_home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
  bash -euo pipefail -c 'source "$ROOT/install/user/chromium.sh"'

[[ -f $fresh_home/.config/chromium/NativeMessagingHosts/com.omarchy.copy_url.json ]] ||
  fail "fresh install registers the copy-url native messaging host"
pass "fresh install registers the copy-url native messaging host"

copied_url=$(bash -c '
  source "$1"
  wl-copy() { cat; }
  omarchy-notification-send() { :; }
  copy_url "$2"
' bash "$ROOT/bin/omarchy-chromium-copy-url-host" 'https://example.test/path?q=one&name=two')

[[ $copied_url == "https://example.test/path?q=one&name=two" ]] ||
  fail "copy-url native host writes the complete URL" "$copied_url"
pass "copy-url native host writes the complete URL"

open_log="$TMPDIR/open-log"
OPEN_LOG="$open_log" bash -c '
  source "$1"
  omarchy-launch-browser() { printf "%s\n" "$1" >"$OPEN_LOG"; }
  open_url "$2"
' bash "$ROOT/bin/omarchy-chromium-copy-url-host" 'https://example.test/path?q=one&name=two'

[[ $(<"$open_log") == "https://example.test/path?q=one&name=two" ]] ||
  fail "copy-url native host opens the complete URL in the default browser" "$(<"$open_log")"
pass "copy-url native host opens the complete URL in the default browser"

for invalid_url in 'javascript:alert(1)' 'https://example.test/a b'; do
  : >"$open_log"
  if OPEN_LOG="$open_log" bash -c '
    source "$1"
    omarchy-launch-browser() { printf "%s\n" "$1" >"$OPEN_LOG"; }
    open_url "$2"
  ' bash "$ROOT/bin/omarchy-chromium-copy-url-host" "$invalid_url"; then
    fail "copy-url native host rejects unsafe open URL $invalid_url"
  fi
  [[ ! -s $open_log ]] || fail "copy-url native host does not launch unsafe URL $invalid_url"
done
pass "copy-url native host only opens HTTP URLs"

native_reply=$(bash -c '
  source "$1"
  reply_copied true
' bash "$ROOT/bin/omarchy-chromium-copy-url-host" | od -An -v -tx1 | tr -d ' \n')

[[ $native_reply == "0f0000007b22636f70696564223a747275657d" ]] ||
  fail "copy-url native host returns a framed success response" "$native_reply"
pass "copy-url native host returns a framed success response"

native_reply=$(bash -c '
  source "$1"
  reply_opened true
' bash "$ROOT/bin/omarchy-chromium-copy-url-host" | od -An -v -tx1 | tr -d ' \n')

[[ $native_reply == "0f0000007b226f70656e6564223a747275657d" ]] ||
  fail "copy-url native host returns a framed open response" "$native_reply"
pass "copy-url native host returns a framed open response"

: >"$open_log"
native_reply=$(node - <<'JS' | OPEN_LOG="$open_log" bash -c '
  source "$1"
  omarchy-launch-browser() { printf "%s\n" "$1" >"$OPEN_LOG"; }
  main
' bash "$ROOT/bin/omarchy-chromium-copy-url-host" | od -An -v -tx1 | tr -d ' \n'
const payload = Buffer.from(JSON.stringify({ action: 'open', url: 'https://example.test/from-message' }))
const length = Buffer.alloc(4)
length.writeUInt32LE(payload.length)
process.stdout.write(Buffer.concat([length, payload]))
JS
)

[[ $(<"$open_log") == "https://example.test/from-message" ]] ||
  fail "copy-url native host dispatches open messages" "$(<"$open_log")"
[[ $native_reply == "0f0000007b226f70656e6564223a747275657d" ]] ||
  fail "copy-url native host acknowledges open messages" "$native_reply"
pass "copy-url native host dispatches framed open messages"
