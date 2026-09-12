#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command node

EXT_DIR="$ROOT/default/chromium/extensions/teams-join"
MANIFEST="$EXT_DIR/manifest.json"
FLAGS="$ROOT/config/chromium-flags.conf"

HOSTS=(
  "https://teams.microsoft.com/*"
  "https://teams.cloud.microsoft/*"
  "https://teams.live.com/*"
  "https://gov.teams.microsoft.us/*"
  "https://dod.teams.microsoft.us/*"
  "https://teams.microsoftonline.cn/*"
)

[[ -f $MANIFEST ]] || fail "teams-join manifest exists"

jq -e --argjson hosts "$(printf '%s\n' "${HOSTS[@]}" | jq -R . | jq -s .)" '
  .manifest_version == 3
  and .version == "0.2"
  and .content_scripts[0].matches == $hosts
  and .host_permissions == $hosts
  and .content_scripts[0].run_at == "document_start"
  and .content_scripts[0].js == ["content.js"]
  and (has("background") | not)
  and ((.permissions // []) | index("webNavigation") | not)
  and ((.permissions // []) | index("tabs") | not)
  and ((.optional_permissions // []) | index("webNavigation") | not)
  and ((.optional_permissions // []) | index("tabs") | not)
  and (.browser_specific_settings.gecko.id | type == "string" and length > 0)
' "$MANIFEST" >/dev/null || fail "teams-join manifest is MV3 content-script only"

matches_json=$(jq -c '.content_scripts[0].matches' "$MANIFEST")
echo "$matches_json" | jq -e 'index("http://teams.microsoft.com/*") or index("<all_urls>")' >/dev/null &&
  fail "teams-join matches are https hosts only, no http:// or <all_urls>" "$matches_json"

hosts_json=$(jq -c '.host_permissions' "$MANIFEST")
echo "$hosts_json" | jq -e 'index("http://teams.microsoft.com/*") or index("<all_urls>")' >/dev/null &&
  fail "teams-join host_permissions are https hosts only, no http:// or <all_urls>" "$hosts_json"

pass "teams-join manifest is MV3 content-script only for the listed https hosts"

load_line=$(grep '^--load-extension=' "$FLAGS" || true)
[[ -n $load_line ]] || fail "chromium-flags.conf has a --load-extension= line"

[[ $load_line == *extensions/teams-join* ]] ||
  fail "chromium-flags.conf loads teams-join" "$load_line"

shopt -s nullglob
for manifest in "$ROOT/default/chromium/extensions"/*/manifest.json; do
  ext_id=$(basename "$(dirname "$manifest")")
  [[ $load_line == *"/extensions/$ext_id"* ]] ||
    fail "chromium-flags.conf loads $ext_id" "$load_line"
done
shopt -u nullglob

IFS=',' read -ra flag_paths <<< "${load_line#--load-extension=}"
for flag_path in "${flag_paths[@]}"; do
  ext_id=$(basename "$flag_path")
  [[ -f $ROOT/default/chromium/extensions/$ext_id/manifest.json ]] ||
    fail "chromium-flags.conf lists $ext_id but the extension is missing"
done

pass "chromium-flags.conf --load-extension= matches the shipped extension dirs"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')

const contentPath = path.join(root, 'default/chromium/extensions/teams-join/content.js')
let contentJs
try {
  contentJs = fs.readFileSync(contentPath, 'utf8')
} catch (error) {
  fail('content.js exists', String(error))
}

function runScript(href, options = {}) {
  const store = options.store || new Map()
  const state = {
    href,
    stopCalls: 0,
    standalone: options.standalone === true,
    lastMatchMediaQuery: null,
  }
  const sandbox = {
    URL,
    sessionStorage: {
      getItem(key) {
        return store.has(key) ? store.get(key) : null
      },
      setItem(key, value) {
        store.set(key, String(value))
      },
    },
    window: {},
  }
  sandbox.window.location = {
    get href() {
      return state.href
    },
    set href(value) {
      state.href = value
    },
  }
  sandbox.window.matchMedia = (query) => {
    state.lastMatchMediaQuery = query
    return { matches: state.standalone }
  }
  sandbox.window.stop = () => {
    state.stopCalls += 1
  }
  vm.runInNewContext(contentJs, sandbox, { filename: 'content.js' })
  return { state, store }
}

const hosts = [
  'teams.microsoft.com',
  'teams.cloud.microsoft',
  'teams.live.com',
  'gov.teams.microsoft.us',
  'dod.teams.microsoft.us',
  'teams.microsoftonline.cn',
]
const context = 'context=%7B%22Tid%22%3A%22t%22%7D'
const meetingColon = '/l/meetup-join/19:meeting_abc@thread.v2'
const meetingEncoded = '/l/meetup-join/19%3ameeting_abc@thread.v2'
const channelPath = '/l/meetup-join/19%3ax@thread.tacv2/1788865197722'
const expectedColon = `msteams://teams.microsoft.com${meetingColon}`
const expectedEncoded = `msteams://teams.microsoft.com${meetingEncoded}`
const expectedWithContext = `msteams://teams.microsoft.com${meetingColon}?${context}`

function assertFires(href, expected, description) {
  const { state } = runScript(href)
  assertEqual(state.href, expected, `${description} rewrites to msteams://<page host>`)
  assertEqual(state.stopCalls, 1, `${description} calls window.stop after a fire`)
}

function assertNoFire(href, description) {
  const { state, store } = runScript(href)
  assertEqual(state.href, href, `${description} does not fire`)
  assertEqual(state.stopCalls, 0, `${description} does not call window.stop`)
  assertEqual(store.size, 0, `${description} does not latch`)
}

function launcherHref(pageHost, inner, extra = {}) {
  const url = new URL(`https://${pageHost}/dl/launcher/launcher.html`)
  url.searchParams.set('url', inner)
  for (const [key, value] of Object.entries(extra)) {
    url.searchParams.set(key, value)
  }
  return url.href
}

for (const host of hosts) {
  const expectedColonHost = `msteams://${host}${meetingColon}`
  const expectedEncodedHost = `msteams://${host}${meetingEncoded}`
  const expectedWithContextHost = `msteams://${host}${meetingColon}?${context}`
  const expectedShort = `msteams://${host}/meet/123?p=abc`
  const expectedShortNoP = `msteams://${host}/meet/123`

  assertFires(
    `https://${host}${meetingColon}`,
    expectedColonHost,
    `${host} colon meeting path`
  )
  assertFires(
    `https://${host}${meetingEncoded}`,
    expectedEncodedHost,
    `${host} %3a meeting path`
  )
  assertFires(
    `https://${host}/v2/?meetingjoin=true#${meetingColon}?${context}`,
    expectedWithContextHost,
    `${host} v2 fragment`
  )
  assertFires(
    launcherHref(host, `${meetingColon}?${context}`),
    expectedWithContextHost,
    `${host} single-encoded context in url=`
  )
  assertFires(
    launcherHref(
      host,
      `${meetingColon}?deeplinkId=abc-123&launchAgent=web&${context}&anon=true&enablemcas=1&suppressPrompt=true`
    ),
    expectedWithContextHost,
    `${host} deeplinkId= before context=`
  )
  assertFires(
    `https://${host}/meet/123?p=abc`,
    expectedShort,
    `${host} /meet/123?p=abc direct`
  )
  assertFires(
    `https://${host}/meet/123`,
    expectedShortNoP,
    `${host} /meet/123 without p=`
  )
  assertFires(
    launcherHref(
      host,
      '/_#/meet/123?p=abc&anon=true',
      {
        type: 'meet',
        deeplinkId: '11111111-1111-1111-1111-111111111111',
        directDl: 'true',
        msLaunch: 'true',
        enableMobilePage: 'true',
        launchAgent: 'join_launcher',
        fqdn: host,
      }
    ),
    expectedShort,
    `${host} launcher /_#/meet/123 with Step 0 keys`
  )
  assertFires(
    launcherHref(host, `/_#${meetingColon}?${context}&fqdn=${host}`),
    expectedWithContextHost,
    `${host} launcher /_#/l/meetup-join with context=`
  )
  assertFires(
    `https://${host}/v2/?meetingjoin=true#/meet/123?p=abc`,
    expectedShort,
    `${host} v2 fragment carrying /meet/`
  )
}

function assertStandDownAndLatch(href, description) {
  const store = new Map()
  const first = runScript(href, { store })
  assertEqual(first.state.href, href, `${description} stands down`)
  assertEqual(first.state.stopCalls, 0, `${description} does not call window.stop`)
  assert(store.size > 0, `${description} latches the tab`)

  const hop = `https://teams.microsoft.com/v2/?meetingjoin=true#${meetingColon}`
  const second = runScript(hop, { store })
  assertEqual(second.state.href, hop, `${description} latches a later marker-less /v2/ hop`)
  assertEqual(second.state.stopCalls, 0, `${description} /v2/ hop does not fire`)
}

assertStandDownAndLatch(
  `https://teams.microsoft.com${meetingColon}?omarchyWebapp=1`,
  'omarchyWebapp=1'
)

const encodedMarkerHref = launcherHref(
  'teams.microsoft.com',
  `${meetingColon}?omarchyWebapp=1`
)
assert(
  encodedMarkerHref.includes('omarchyWebapp%3D1'),
  'encoded marker href contains omarchyWebapp%3D1',
  encodedMarkerHref
)
assertStandDownAndLatch(encodedMarkerHref, 'omarchyWebapp%3D1')

{
  const href = `https://teams.microsoft.com${meetingColon}`
  const { state } = runScript(href, { standalone: true })
  assertEqual(state.href, href, 'display-mode: standalone yields no fire')
  assertEqual(state.stopCalls, 0, 'display-mode: standalone does not call window.stop')
  assertEqual(
    state.lastMatchMediaQuery,
    '(display-mode: standalone)',
    'standalone guard queries display-mode: standalone'
  )
}

{
  const href = 'https://teams.microsoft.com/l/chat/19:thread@thread.v2'
  const { state, store } = runScript(href)
  assertEqual(state.href, href, 'non-meeting URL does not fire')
  assertEqual(state.stopCalls, 0, 'non-meeting URL does not call window.stop')
  assertEqual(store.size, 0, 'non-meeting URL does not latch')
}

{
  const href = `https://teams.microsoft.com${meetingColon}`
  const store = new Map()
  const first = runScript(href, { store })
  assertEqual(first.state.href, expectedColon, 'first visit in a tab fires')
  assertEqual(first.state.stopCalls, 1, 'first visit in a tab calls window.stop')

  const second = runScript(href, { store })
  assertEqual(second.state.href, href, 'repeat in the same tab does not fire')
  assertEqual(second.state.stopCalls, 0, 'repeat in the same tab does not call window.stop')
}

{
  const meetingA = `https://teams.microsoft.com${meetingColon}`
  const meetingBPath = '/l/meetup-join/19:meeting_xyz@thread.v2'
  const meetingB = `https://teams.microsoft.com${meetingBPath}`
  const expectedB = `msteams://teams.microsoft.com${meetingBPath}`
  const store = new Map()

  const first = runScript(meetingA, { store })
  assertEqual(first.state.href, expectedColon, 'meeting A in a shared store fires')
  assertEqual(first.state.stopCalls, 1, 'meeting A in a shared store calls window.stop')

  const second = runScript(meetingB, { store })
  assertEqual(second.state.href, expectedB, 'a different meeting in the same tab still fires')
  assertEqual(second.state.stopCalls, 1, 'a different meeting in the same tab calls window.stop')

  const keys = [...store.keys()].sort()
  assertDeepEqual(
    keys,
    [
      'teamsjoin:/l/meetup-join/19:meeting_abc@thread.v2',
      'teamsjoin:/l/meetup-join/19:meeting_xyz@thread.v2',
    ].sort(),
    'the store holds two distinct teamsjoin: keys'
  )
}

for (const host of ['teams.microsoft.com', 'gov.teams.microsoft.us']) {
  assertFires(
    `https://${host}${channelPath}?${context}`,
    `msteams://${host}${channelPath}?${context}`,
    `${host} channel meeting @thread.tacv2`
  )
}

{
  const href = `https://dod.teams.microsoft.us${meetingColon.replace('19:meeting_abc', '19:dod:meeting_abc')}/0?${context}`
  const expected = `msteams://dod.teams.microsoft.us/l/meetup-join/19:dod:meeting_abc@thread.v2/0?${context}`
  const { state } = runScript(href)
  assertEqual(state.href, expected, 'DoD thread id rewrites to msteams://<page host>')
  assert(
    !state.href.includes('teams.microsoft.com'),
    'DoD emit does not contain teams.microsoft.com',
    state.href
  )
  assertEqual(state.stopCalls, 1, 'DoD thread id calls window.stop after a fire')
}

assertFires(
  launcherHref('gov.teams.microsoft.us', '/_#/meet/123?p=abc'),
  'msteams://gov.teams.microsoft.us/meet/123?p=abc',
  'gov launcher /_#/meet/123 preserves host'
)

{
  const href = 'https://teams.microsoft.com/meet/user@example.com?p=abc'
  const { state, store } = runScript(href)
  assertEqual(
    state.href,
    'msteams://teams.microsoft.com/meet/user@example.com?p=abc',
    'non-numeric /meet/ id rewrites to msteams://<page host>'
  )
  assertEqual(state.stopCalls, 1, 'non-numeric /meet/ id calls window.stop after a fire')
  assertDeepEqual(
    [...store.keys()],
    ['teamsjoin:/meet/user@example.com'],
    'non-numeric /meet/ latch key strips the query'
  )
}

{
  const href = launcherHref('teams.microsoft.com', '/_#/meet/123?p=abc')
  const { state, store } = runScript(href)
  assertEqual(
    state.href,
    'msteams://teams.microsoft.com/meet/123?p=abc',
    'launcher without type fires'
  )
  assertEqual(store.size, 1, 'launcher without type latches once')
}

assertFires(
  launcherHref('teams.microsoft.com', '/_#/meet/123?p=abc', { type: 'chat' }),
  'msteams://teams.microsoft.com/meet/123?p=abc',
  'launcher with misleading type=chat on a valid meeting'
)

assertNoFire(
  launcherHref('teams.microsoft.com', '/_#/l/chat/0/0?users=a', { type: 'meet' }),
  'launcher with type=meet on a non-meeting payload'
)

{
  const extra = 'futureKey=1&msLaunch=true&directDl=true&enableMobilePage=true&suppressPrompt=true&type=meet'
  assertFires(
    launcherHref('teams.microsoft.com', `/_#/meet/123?p=abc&${extra}`),
    'msteams://teams.microsoft.com/meet/123?p=abc',
    'unknown keys dropped from /meet/ launcher emit'
  )
  assertFires(
    launcherHref('teams.microsoft.com', `/_#${meetingColon}?${context}&${extra}`),
    expectedWithContext,
    'unknown keys dropped from classic launcher emit'
  )
  assertFires(
    'https://teams.microsoft.com/meet/123?futureKey=1&p=abc',
    'msteams://teams.microsoft.com/meet/123?p=abc',
    'allow-list keeps p= when it is not first'
  )
}

{
  const href = 'https://teams.microsoft.com/meet/123?p=abc'
  const store = new Map()
  const first = runScript(href, { store })
  assertEqual(first.state.href, 'msteams://teams.microsoft.com/meet/123?p=abc', '/meet/123?p=abc fires')
  assertDeepEqual([...store.keys()], ['teamsjoin:/meet/123'], 'p= never lands in the latch key')

  const second = runScript('https://teams.microsoft.com/meet/123?p=other', { store })
  assertEqual(second.state.href, 'https://teams.microsoft.com/meet/123?p=other', 'same /meet/ id with different p= does not fire')
  assertEqual(second.state.stopCalls, 0, 'same /meet/ id with different p= does not call window.stop')
}

{
  const href = 'https://teams.microsoft.com/meet/123'
  const { state } = runScript(href, { standalone: true })
  assertEqual(state.href, href, 'standalone /meet/ yields no fire')
  assertEqual(state.stopCalls, 0, 'standalone /meet/ does not call window.stop')
}

{
  const store = new Map()
  const first = runScript('https://teams.microsoft.com/meet/user@example.com', { store })
  assertEqual(
    first.state.href,
    'msteams://teams.microsoft.com/meet/user@example.com',
    '/meet/user@example.com fires'
  )
  const second = runScript('https://teams.microsoft.com/meet/user%40example.com', { store })
  assertEqual(
    second.state.href,
    'https://teams.microsoft.com/meet/user%40example.com',
    '/meet/user%40example.com stands down on the folded latch key'
  )
  assertDeepEqual(
    [...store.keys()],
    ['teamsjoin:/meet/user@example.com'],
    '%40 and @ /meet/ ids share one latch key'
  )
}

assertFires(
  'https://teams.microsoft.com/meet/omarchyWebapp?p=omarchyWebapp',
  'msteams://teams.microsoft.com/meet/omarchyWebapp?p=omarchyWebapp',
  'marker collision in /meet/ id and p= still fires'
)
assertFires(
  launcherHref('teams.microsoft.com', '/_#/meet/omarchyWebapp?p=omarchyWebapp'),
  'msteams://teams.microsoft.com/meet/omarchyWebapp?p=omarchyWebapp',
  'marker collision launcher form still fires'
)

{
  const href = 'https://teams.microsoft.com/meet/123?p=abc&omarchyWebapp=1'
  const store = new Map()
  const first = runScript(href, { store })
  assertEqual(first.state.href, href, 'page-query marker on /meet/ stands down')
  assertEqual(first.state.stopCalls, 0, 'page-query marker on /meet/ does not call window.stop')
  assert(store.size > 0, 'page-query marker on /meet/ latches')
}

{
  const href = launcherHref('teams.microsoft.com', '/_#/meet/123?p=abc&omarchyWebapp=1')
  assert(href.includes('omarchyWebapp%3D1'), 'launcher collision marker href encodes omarchyWebapp%3D1', href)
  const store = new Map()
  const first = runScript(href, { store })
  assertEqual(first.state.href, href, 'encoded marker inside url= stands down')
  assertEqual(first.state.stopCalls, 0, 'encoded marker inside url= does not call window.stop')
  assert(store.size > 0, 'encoded marker inside url= latches')
}

{
  const href = 'https://teams.microsoft.com/v2/?meetingjoin=true#/meet/123?omarchyWebapp=1'
  const store = new Map()
  const first = runScript(href, { store })
  assertEqual(first.state.href, href, 'fragment-query marker on /meet/ stands down')
  assertEqual(first.state.stopCalls, 0, 'fragment-query marker on /meet/ does not call window.stop')
  assert(store.size > 0, 'fragment-query marker on /meet/ latches')
}

assertFires(
  'https://teams.microsoft.com/meet/123?p=a/b',
  'msteams://teams.microsoft.com/meet/123?p=a/b',
  'slash in passcode is kept'
)
assertFires(
  'https://teams.microsoft.com/meet/123/extra?p=abc',
  'msteams://teams.microsoft.com/meet/123',
  '/meet/123/extra drops the tail and the query after it'
)

{
  const encoded = new URL('https://teams.microsoft.com/convene/meetings')
  encoded.searchParams.set('url', '/_#/meet/123?p=abc')
  assertNoFire(encoded.href, 'encoded /convene/?url=/_#/meet/ on teams.microsoft.com')

  assertNoFire(
    'https://gov.teams.microsoft.us/convene/meetings?url=/meet/123?p=abc',
    'raw /convene/?url=/meet/123 on gov'
  )
  assertNoFire(
    'https://teams.microsoft.com/convene/meetings?url=/_#/meet/123?p=abc',
    'unencoded /convene/?url=/_#/meet/ (hash on a non-/v2/ page)'
  )
}

assertNoFire(
  launcherHref('teams.microsoft.com', '/_#/l/chat/0/0?users=a', { type: 'chat' }),
  'launcher url= chat payload'
)
assertNoFire(
  launcherHref('teams.microsoft.com', '/_#/l/channel/19:x@thread.tacv2/General'),
  'launcher url= channel payload'
)

const a12Hosts = ['teams.microsoft.com', 'gov.teams.microsoft.us']
const a12Paths = [
  '/v2/?meetingjoin=true#/light-meetings/launch',
  '/light-meetings/launch?foo=1',
  '/l/meeting/new?subject=x',
  '/l/chat/19:thread@thread.v2',
  '/l/call/19:thread@thread.v2',
  '/l/channel/19:x@thread.tacv2/General',
  '/l/team/19:x@thread.tacv2',
  '/l/message/19:x@thread.tacv2/1788865197722',
  '/l/entity/foo',
  '/l/app/foo',
  '/l/task/foo',
  '/l/file/foo',
  '/l/meeting-share/foo',
]
for (const host of a12Hosts) {
  for (const path of a12Paths) {
    assertNoFire(`https://${host}${path}`, `${host} ${path}`)
  }
}
assertNoFire(
  'https://teams.microsoft.com/meetup-join/19:x',
  'meetup-join without /l/'
)
assertNoFire('https://teams.microsoft.com/meet/', '/meet/ with an empty id')
JS
