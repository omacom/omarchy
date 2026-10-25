// The notification plugin's pure JS modules, plus the service's own functions
// lifted out of Service.qml and run against a fake ListModel and fake senders.
const assert = require('node:assert/strict'), fs = require('node:fs'), vm = require('node:vm')
const { URL } = require('node:url')
const load = require('./loader.cjs')
const S = load('Security'), M = load('Markup'), D = load('Detect'), Store = load('Store')
const Layout = load('Layout'), Delivery = load('Delivery'), Icons = load('Icons')
const snap = (n, key = 'k') => Store.snapshot(n, key, { Normal: 1 })

// ---------------------------------------------------------------- URL policy
// Hosts a WHATWG parser reads as IPv4. Node's URL proves each canonicalisation
// is real before the policy is checked to refuse it.
const numericHosts = [
  ['http://0x7f.0x0.0x0.0x1/', '127.0.0.1'], ['http://0X7F.0X0.0X0.0X1/', '127.0.0.1'],
  ['http://0xa.0x0.0x0.0x1/', '10.0.0.1'], ['http://0177.0.0.1/', '127.0.0.1'],
  ['http://0177.00.00.01/', '127.0.0.1'], ['http://2130706433/', '127.0.0.1'],
  ['http://0x7f000001/', '127.0.0.1'], ['http://10.0.0x0.0x1/', '10.0.0.1'],
  ['http://10.0.00.01/', '10.0.0.1'], ['http://127.0x/', '127.0.0.0'], ['https://127.1', '127.0.0.1'],
]
for (const [u, ip] of numericHosts) assert.equal(new URL(u).hostname, ip, 'sanity: ' + u)
const bad = ['https://paypal.com@evil.example', 'https://user:pass@example.com', 'javascript:alert(1)', 'file:///etc/passwd',
  'smb://server/share', 'data:text/html,test', 'https://example.com/\n', 'https://example.com/%0d%0a', 'https://example.com/%250a',
  'https://example.com%40evil.example', 'https://[::1]', 'https://[::ffff:127.0.0.1]', 'https://éxample.com', 'https://example..com',
  'https://example.com:99999', 'https://example.com\\@evil.example', 'https://example.com/' + 'x'.repeat(4096),
  ...numericHosts.map(([u]) => u)]
for (const u of bad) {
  assert.equal(S.safeExternalUrl(u), '', u)
  assert.equal(S.openExternalUrl(u), false, u)
  assert.ok(!M.render('<a href="' + u + '">click</a>').includes('<a href='), u)
  for (const detected of D.links(u)) assert.ok(S.safeHttpUrl(detected))
}
for (const u of ['https://example.com', 'http://example.com/path?q=1', 'https://xn--bcher-kva.example', 'https://example.com/a%40b',
                 'https://sub.example.co.uk/', 'https://x0.example.com/', 'mailto:user@example.com'])
  assert.ok(S.safeExternalUrl(u), u)
assert.equal(S.safeHttpUrl('HTTPS://Example.COM.:443/a'), 'https://example.com:443/a')
assert.equal(S.safeMailtoUrl('mailto:user@example.com?attach=/etc/passwd'), '')

// -------------------------------------------------------------------- markup
// Only the safe subset survives, however it is spelled.
for (const body of ['<img src="file:///etc/passwd">', '<svg><image href="https://example.com"/></svg>', '<script>alert(1)</script>',
                    '<iframe src="x">', 'https://example.com/"onmouseover="x', '<style>a{}</style>x', '<font color=red>x</font>',
                    '&lt;img src="file:///etc/passwd"&gt;', '&amp;lt;img src=x&amp;gt;', '<b><i>x', '<img src=x', '<<img src=x>>',
                    '<a href="qrc:/x">x</a>', '<a href="image://icon/x">x</a>', '<a href="javascript:alert(1)">x</a>',
                    '<a href="https://paypal.com@evil.example">paypal.com</a>Your code is 1234'])
  assert.ok(!/<(?:img|svg|script|iframe|object|embed|style|font)\b|<a[^>]+onmouseover=|href="(?:qrc|image|javascript|file|data):/i
    .test(M.render(body)), body)

// A bare URL is a link even beside formatting, but never inside the sender's own anchor.
assert.equal(M.render('<b>Standup</b> https://example.com/x'), '<b>Standup</b> <a href="https://example.com/x">https://example.com/x</a>')
assert.equal(M.render('<a href="https://example.com/">https://example.com/</a>'), '<a href="https://example.com/">https://example.com/</a>')

{ // Escaped sender markup must not leak into collapsed or restored previews.
  const body = 'Thread in #support: &lt;b&gt;Sam&lt;/b&gt;&lt;br/&gt;the preview is readable &amp; compact'
  const expected = 'Thread in #support: Sam the preview is readable & compact'
  assert.equal(snap({ appName: 'Slack', summary: 'Slack', body }).bodyLine, expected)
  assert.equal(Store.restored({ key: 'markup', body: body.replace(/&/g, '&amp;'), bodyLine: 'stale' }).bodyLine, expected)
  const literals = 'List&lt;String&gt;: Sam &lt;sam@example.com&gt; asks if 3 &lt; 5\n&amp; 5 &gt; 2; &lt;3'
  const literalLine = 'List<String>: Sam <sam@example.com> asks if 3 < 5 & 5 > 2; <3'
  assert.equal(snap({ body: literals }).bodyLine, literalLine)
  assert.equal(Store.restored({ key: 'literal', body: literals, bodyLine: 'stale' }).bodyLine, literalLine)
  assert.equal(M.oneLine('<b>Sam</b><br/><a href="https://example.com">read &lt;details&gt;</a>'), 'Sam read <details>')
  assert.equal(M.oneLine('&lt;img src="file:///etc/passwd"&gt; &lt;b class="literal"&gt;'), '<img src="file:///etc/passwd"> <b class="literal">')
  // Reverse only our own escaping; no fourth sender-decoding pass.
  assert.equal(M.oneLine('&amp;amp;amp;lt;b&amp;amp;amp;gt;'), '&lt;b&gt;')
  assert.equal(M.oneLine('&#128512; &#x1F600;'), '\u{1F600} \u{1F600}')
}

// Parsers stay fast on hostile input, and a generated corpus never yields a
// non-idempotent URL or a dangerous tag.
const start = Date.now()
for (const text of ['<'.repeat(32768), '&amp;'.repeat(6500), '9'.repeat(32768), 'https://'.repeat(4000)]) { M.render(text); D.scan('', text) }
assert.ok(Date.now() - start < 3000, 'parsers exceeded 3-second budget')
let seed = 17
for (let i = 0; i < 1000; i++) {
  let s = ''
  for (let j = 0; j < 80; j++) { seed = (seed * 1664525 + 1013904223) >>> 0; s += String.fromCharCode(seed % 128) }
  const u = S.safeExternalUrl(s)
  if (u) assert.equal(S.safeExternalUrl(u), u)
  assert.ok(!/<(?:img|script|iframe|object|svg)\b/i.test(M.render(s)))
}

// ------------------------------------------------------------------ identity
{ // Only a browser's leading origin anchor names a site; only an http(s) href
  // can be that origin; a label never stands in for it.
  const id = (app, body, summary) => snap({ appName: app, summary: summary || 'hi', body })
  for (const href of ['javascript:alert(1)', 'data:text/html,hello', 'qrc:/x', 'file:///etc/passwd', 'https://bank.example']) {
    const chat = id('Chat', '<a href="' + href + '">bank.example</a>message')
    assert.equal(chat.groupKey, 'app:chat', href)
    assert.equal(chat.source, 'Chat')
  }
  for (const href of ['javascript:alert(1)', 'data:text/html,hello', 'qrc:/x', 'file:///etc/passwd', 'https://user@bank.example'])
    assert.equal(id('Google Chrome', '<a href="' + href + '">bank.example</a>message').groupKey, 'app:google-chrome', href)
  const real = id('Google Chrome', '<a href="https://app.slack.com/">app.slack.com</a>Dominic: hi')
  assert.equal(real.groupKey, 'web:app.slack.com')
  assert.equal(real.source, 'app.slack.com')
  assert.equal(id('Chromium', '<a href="https://evil.example/">bank.example</a>hi').source, 'evil.example', 'the href is the origin')
  assert.equal(id('Brave Origin', '<a href="https://app.basecamp.com/">app.basecamp.com</a>\n\nKendall: hi').groupKey, 'web:app.basecamp.com')
  // A restored row cannot claim a site either unless it came from a browser.
  assert.equal(Store.restored({ key: 'r', app: 'Chat', source: 'bank.example' }).groupKey, 'app:chat')
  assert.equal(Store.restored({ key: 'r', app: 'Chromium', source: 'app.slack.com' }).groupKey, 'web:app.slack.com')
  // An unnamed sender's toasts each stand alone rather than stacking.
  for (const app of ['omarchy-action', 'notify-send'])
    assert.notEqual(Store.restored({ key: 'a', app }).groupKey, Store.restored({ key: 'b', app }).groupKey, app)
}

{ // `-i name` is an icon name, not a picture; only the strict charset is kept.
  // A sender's file is kept as its path, read whole, once the policy accepts it.
  const long = '/tmp/' + 'a'.repeat(400) + '.png'
  for (const [image, appIcon, kept] of [['image://icon/kitty', 'kitty', ''], ['image://qsimage/12/1', '', 'image://qsimage/12/1'],
      ['image://icon/../../etc/passwd', '', ''], ['image://icon/' + 'a'.repeat(500), 'a'.repeat(243), ''],
      ['image://icon//tmp/.org.chromium.Chromium.Xk3lQa/1', '', '/tmp/.org.chromium.Chromium.Xk3lQa/1'],
      ['file:///home/u/Pictures/cover%20art.png', '', '/home/u/Pictures/cover art.png'], ['image://icon/' + long, '', long],
      ['file:///proc/self/environ', '', ''], ['https://example/image.png', '', ''], ['image://icon//tmp/../etc/x.png', '', '']]) {
    const row = snap({ appName: 'Test', summary: 's', body: 'b', image })
    assert.equal(row.appIcon, appIcon, image)
    assert.equal(row.image, kept, image)
  }
  for (const [image, kept] of [['/tmp/a.png', '/tmp/a.png'], ['image://icon//tmp/a.png', '/tmp/a.png'], ['image://qsimage/1/2', 'image://qsimage/1/2'],
                               ['image://icon//tmp/../etc/x.png', ''], ['/dev/zero', ''], ['image://qsimage/1/2/../3', ''], ['data:image/png;base64,AAAA', '']])
    assert.equal(Store.normalise({ image }).image, kept, image)
  // Images belong to the live sender: never persisted, never read back.
  assert.ok(!('image' in Store.persistable({ key: 'p', image: '/tmp/a.png' })))
  assert.equal(Store.restored(Store.parseLive(JSON.stringify([{ key: 'p', image: '/tmp/a.png' }]))[0]).image, '')
  assert.equal(Store.normalise({ body: 'hello', bodyRich: '<img src="x">' }).bodyRich, 'hello')
  assert.equal(snap({ body: 'x'.repeat(100000), summary: 'y'.repeat(3000) }).body.length, 32768)
}

// ---------------------------------------------------------- store transforms
for (const body of ['Your verification code is 938271', 'Your code is 938 271', 'Your code is 938-271', 'Your code is &#57;38271',
                    'Your code is A9F3K2']) {
  const saved = Store.sanitiseForPersistence(snap({ appName: 'Test', summary: 'Verification', body }))
  assert.equal(saved.body, '[redacted]', body)
  // Shown translated: the stored placeholder, restored or listed, is recognised.
  assert.ok(Store.redacted(Store.restored(Object.assign(saved, { key: 'r' }))), body)
  for (const secret of ['938271', '938 271', '938-271', 'A9F3K2']) assert.ok(!JSON.stringify(saved).includes(secret))
}
{ // Literal attributes must not move legacy/raw-only codes outside the scan window.
  const body = 'Your code is <span title="' + 'x'.repeat(100) + '">938271</span>'
  for (const entry of [{ body }, { rawBody: body.replace(/</g, '&lt;').replace(/>/g, '&gt;') }]) {
    const saved = Store.sanitiseForPersistence(entry)
    assert.equal(saved.body, '[redacted]')
    assert.ok(!JSON.stringify(saved).includes('938271'))
  }
}

{ // Restore recomputes the link from the text under today's policy, never
  // trusting the field on the stored entry.
  const entry = body => ({ key: 'n1', app: 'Chat', summary: 'New message', body, rawBody: body, urgency: 1 })
  const row = Store.restored(entry('Join https://meet.google.com/abc-defg-hij'))
  assert.equal(row.link, 'https://meet.google.com/abc-defg-hij')
  assert.equal(row.restored, true)
  const tampered = Store.restored({ ...entry('Nothing to see here'), link: 'https://evil.example/phish' })
  assert.equal(tampered.link, '')
  assert.equal(Store.restored(entry('See http://127.0.0.1/admin for details')).link, '')
}

{ // The --exec click argv: structural, fails closed, stays discrete arguments.
  const shot = JSON.stringify(['omasnap', '--edit', '/tmp/shot.png'])
  const literal = ['printf', '%s|', '$(touch /tmp/x)', '`id`', 'a; rm -rf /', "q'uote", 'new\nline', '-dash']
  for (const good of [shot, ['mpv', '--', '/tmp/a b.mp4'], JSON.stringify(['bash', '-c', 'id']), JSON.stringify(literal)]) {
    const text = typeof good === 'string' ? good : JSON.stringify(good)
    assert.equal(JSON.stringify(S.parseExecArgv(good)), text)
  }
  for (const bad of ['', 'not json', '{}', '[]', '[1]', '["mpv", 2]', '[""]', '["-rf"]', '["--help"]',
                     JSON.stringify(Array(33).fill('x')), JSON.stringify(['x'.repeat(4097)]),
                     // A NUL cannot travel in an argv; Qt would cut the argument short.
                     JSON.stringify(['/usr/bin/printf\u0000ignored', '%s']), JSON.stringify(['echo', 'safe\u0000TRUNCATED'])])
    assert.equal(S.parseExecArgv(bad), null, bad)
  assert.equal(snap({ appName: 'x', summary: 'y', hints: { 'omarchy-exec-argv': '["-x"]' } }).execArgv, '')
  for (const app of ['omarchy-action', 'Crash watch', 'notify-send']) {
    const row = snap({ appName: app, summary: 'Action', hints: { 'omarchy-exec-argv': shot } })
    assert.equal(row.execArgv, shot, app)
    // A toast restored after a shell restart clicks through like the live one.
    assert.equal(Store.restored(Store.sanitiseForPersistence(row)).execArgv, shot)
  }
  // A verification-code card is redacted whole, its command and glyph included.
  const secret = Store.sanitiseForPersistence(snap({ appName: 'x', summary: 'Sign in', body: 'Your verification code is 482913',
    hints: { 'omarchy-exec-argv': shot, 'omarchy-glyph': '\u{f0306}' } }))
  assert.deepEqual([secret.execArgv, secret.glyph], ['', ''])
}

{ // --action buttons: up to three, each a label and an argv held to the click's rules.
  const actions = JSON.stringify([{ label: 'Edit', argv: ['omasnap', '--file', '/tmp/a b.png'] },
                                  { label: 'Copy path', argv: ['wl-copy', '--', '/tmp/a b.png'] }])
  assert.equal(JSON.stringify(S.parseExecActions(actions)), actions)
  const one = { label: 'Go', argv: ['true'] }
  for (const bad of ['', '[]', '{}', JSON.stringify([one, one, one, one]), JSON.stringify([{ label: ' ', argv: ['true'] }]),
                     JSON.stringify([{ label: 'Go', argv: ['-rf'] }]), JSON.stringify([{ label: 'Go' }]), JSON.stringify([one, 'x'])])
    assert.equal(S.parseExecActions(bad), null, bad)
  // Stored with the row, so a restored card keeps its buttons; redacted with a code.
  const row = snap({ appName: 'omasnap', summary: 'Screenshot saved', hints: { 'omarchy-actions': actions } })
  assert.equal(Store.restored(Store.sanitiseForPersistence(row)).execActions, actions)
  const secret = snap({ appName: 'x', summary: 'Sign in', body: 'Your verification code is 482913', hints: { 'omarchy-actions': actions } })
  assert.equal(Store.sanitiseForPersistence(secret).execActions, '')
}

{ // Sender image paths: absolute, one spelling, bounded, and never a kernel interface or service state.
  for (const path of ['/tmp/.org.chromium.Chromium.Xk3lQa/1', '/tmp/.org.chromium.Chromium.Xk3lQa/notification-icon', '/home/u/.cache/app/avatar.png',
                      '/usr/share/icons/hicolor/48x48/apps/slack.png', '/run/user/1000/app/com.slack.Slack/icon.png', '/tmp/a b#c?.png',
                      '/home/u/' + 'x'.repeat(1000)])
    assert.equal(S.localImagePath(path), path, path)
  assert.equal(S.localImagePath('file:///tmp/a%20b.png'), '/tmp/a b.png')
  assert.equal(S.localImagePath('image://icon/file:///tmp/a.png'), '/tmp/a.png')
  assert.equal(S.localImagePath('FILE:///tmp/a.png'), '/tmp/a.png')
  for (const bad of ['', 'a.png', './a.png', '~/a.png', 'tmp/a.png', '/', '/tmp/', '/tmp//a.png', '/tmp/./a.png', '/tmp/../etc/passwd',
                     '/tmp/..', '/proc/self/environ', '/proc', '/sys/kernel/notes', '/dev/zero', '/dev/tty', '/run/dbus/system_bus_socket',
                     '/var/run/x.png', '/run/user/1000', '/run/user//a.png', '/tmp/a\u0000.png', '/tmp/a\n.png', '/tmp/\u007f.png',
                     '/home/u/' + 'x'.repeat(1020), 'file:///tmp/%2e%2e/etc/passwd', 'file:///tmp/a%00.png', 'file:///proc/self/environ',
                     'file:///tmp/%ZZ.png', 'file://localhost/tmp/a.png', 'file://host/tmp/a.png', 'file:///tmp/a.png?x', 'file:///tmp/a.png#y',
                     'http://example.com/a.png', 'https://example.com/a.png', 'data:image/png;base64,AAAA', 'qrc:/a.png', 'image://qsimage/1/2',
                     'image://other//tmp/a.png', 'smb://host/a.png', null, undefined, 42, { path: '/tmp/a.png' }])
    assert.equal(S.localImagePath(bad), '', String(bad))
  // What Qt loads: each segment escaped, so a # or ? stays part of the name.
  assert.equal(S.localImageUrl('/tmp/a b#c?.png'), 'file:///tmp/a%20b%23c%3F.png')
  assert.equal(S.localImageUrl('/dev/zero'), '')
}

{ // The desktop-entry hint names the icon when the sender gave none; a path there (Chrome's) does not.
  assert.equal(snap({ appName: 'Slack', desktopEntry: 'slack' }).appIcon, 'slack')
  assert.equal(snap({ appName: 'Slack', appIcon: 'slack-tray', desktopEntry: 'slack' }).appIcon, 'slack-tray')
  assert.equal(snap({ appName: 'Google Chrome', desktopEntry: '/tmp/.org.chromium.Chromium.x/google-chrome' }).appIcon, '')
}

{ // Icon names: a site by its own names first and its browser last, never fetched.
  const same = (actual, expected, message = '') => assert.equal(JSON.stringify(actual), JSON.stringify(expected), message)
  same(Icons.siteNames('app.slack.com'), ['app.slack.com', 'slack'])
  same(Icons.siteNames('mail.google.com'), ['mail.google.com', 'google', 'mail'])
  same(Icons.siteNames('www.x.com'), ['www.x.com', 'x'])
  for (const bad of ['', 'localhost', '127.0.0.1', '0x7f.0x1', 'a..b', 'slack', '-x.com', 'x'.repeat(300) + '.com'])
    same(Icons.siteNames(bad), [], bad)
  // Only the browser is looked up among desktop entries: a fuzzy match on a
  // domain label is how mail.google.com would wear Google Contacts.
  same(Icons.candidates(Store.restored({ key: 'w', app: 'Google Chrome', appIcon: 'google-chrome', source: 'app.slack.com' })), {
    themed: ['app.slack.com', 'slack', 'google-chrome'],
    entries: ['google-chrome', 'Google Chrome'] })
  // An app: its hint, then its source and name, as given and slugged; a name
  // with a space is no theme name.
  same(Icons.candidates(Store.restored({ key: 'a', app: 'Spotify', appIcon: 'spotify-client' })), {
    themed: ['spotify-client', 'Spotify', 'spotify'],
    entries: ['spotify-client', 'Spotify'] })
  // A hostname-looking app is not a site unless a browser lifted it.
  same(Icons.candidates({ app: 'example.com', source: 'example.com', groupKey: 'app:example-com' }).themed, ['example.com'])
  same(Icons.candidates({}), { themed: [], entries: [] })
  assert.equal(Icons.slug('  Google Chrome!! '), 'google-chrome')
  assert.equal(Icons.slug('../../etc/passwd'), 'etc-passwd')
  // One-colour icons go by their freedesktop name, as a theme name or a file.
  for (const mono of ['image://icon/audio-volume-high-symbolic', 'file:///usr/share/icons/Adwaita/symbolic/apps/x.svg',
                      'file:///icons/signal-symbolic.svg', 'image://icon/x-symbolic?fallback=y'])
    assert.ok(Icons.isSymbolic(mono), mono)
  for (const colour of ['image://icon/signal', 'image://icon/symbolic-thing', 'file:///icons/slack.png', '', 'image://qsimage/1/2'])
    assert.ok(!Icons.isSymbolic(colour), colour)
}

{ // The glyph hint: a short mark for the icon slot, persisted with the row.
  const row = snap({ appName: 'omarchy-action', summary: '14:02', hints: { 'omarchy-glyph': '\u{f0954}' } })
  assert.equal(Store.restored(Store.sanitiseForPersistence(row)).glyph, '\u{f0954}')
  for (const bad of ['x'.repeat(17), 'a\u0007', 12]) assert.equal(S.safeGlyph(bad), '')
  assert.equal(snap({ appName: 'Slack', summary: 'typing', hints: { transient: true } }).transient, true)
}

// ------------------------------------------------------------------ delivery
{
  for (const [row, dnd, expected] of [
    [{ app: 'Slack', urgency: 1 }, false, ''],
    [{ app: 'Slack', urgency: 1 }, true, 'silenced'],
    [{ app: 'Slack', urgency: 2 }, true, 'silenced'],      // a branded critical does not punch through
    [{ app: 'notify-send', urgency: 2 }, true, ''],
    [{ app: 'notify-send', urgency: 1 }, true, 'silenced'],
    [{ app: 'omarchy-action', urgency: 0 }, true, ''],
    [{ app: 'Google', urgency: 1, code: '482913' }, true, ''],
  ]) assert.equal(Delivery.quietReason(row, dnd), expected, JSON.stringify([row, dnd]))
  // The number keys count buttons in the order the card draws them: codes, --action, the sender's.
  const deeds = Delivery.deeds({ codes: '482913 771204', execActions: JSON.stringify([{ label: 'Edit', argv: ['omasnap'] }]) },
                               [{ id: 'join', text: 'Join call' }])
  assert.equal(JSON.stringify(Array.from(deeds, d => d.kind + ':' + d.value)), JSON.stringify(['code:482913', 'code:771204', 'exec:0', 'action:join']))
  assert.equal(Delivery.deeds({}, []).length, 0)
  for (const [row, ephemeral] of [[{ app: 'notify-send' }, true], [{ app: 'omarchy-action' }, true],
                                  [{ app: 'Slack', transient: true }, true], [{ app: 'Slack' }, false]])
    assert.equal(Delivery.isEphemeral(row), ephemeral, row.app)
  assert.ok(Delivery.summaryStartsWithGlyph('\u{f009b}  Silenced'))
  assert.ok(!Delivery.summaryStartsWithGlyph('Silenced  notifications'))
  assert.ok(!Delivery.summaryStartsWithGlyph(''))
  // Omarchy's marks share code points with Nerd Font devicons.
  assert.ok(Delivery.omarchyGlyph(''))
  assert.ok(Delivery.omarchyGlyph(''))
  assert.ok(!Delivery.omarchyGlyph('\u{f048a}'))
  assert.ok(!Delivery.omarchyGlyph(''))
  assert.ok(!Delivery.omarchyGlyph(''))

  // The deck clears the bar only on the top and right edges it touches.
  const bar = { barHidden: false, barSize: 26, barSizeFor: name => name === 'notched' ? 40 : 26 }
  assert.equal(Delivery.barThickness(bar, 'notched', 26), 40)
  assert.equal(Delivery.barThickness(bar, 'plain', 26), 26)
  assert.equal(Delivery.barThickness({ barHidden: true }, 'plain', 26), 0)
  assert.equal(Delivery.barThickness(null, 'plain', 28), 28)
  for (const [position, thickness, top, right] of [['top', 26, 36, 10], ['right', 40, 10, 50], ['bottom', 26, 10, 10], ['left', 26, 10, 10]])
    assert.deepEqual({ ...Delivery.deckMargins(position, thickness, 10) }, { top, right }, position)
}

// --------------------------------------------------- Service.qml functions
const source = fs.readFileSync(load.dir + '/Service.qml', 'utf8')
// One function from Service.qml by name: its own line when that balances,
// else up to the closing brace at its indent. QML return types are dropped.
function fn(name) {
  const m = source.match(new RegExp('^( *)function ' + name + '\\(.*$', 'm'))
  if (!m) throw new Error('Service.qml has no function ' + name)
  let text = m[0]
  const opens = text.split('{').length - 1
  if (!opens || opens > text.split('}').length - 1) {
    const end = source.indexOf('\n' + m[1] + '}', m.index)
    if (end < 0) throw new Error('Service.qml function ' + name + ' never closes')
    text = source.slice(m.index, end + m[1].length + 2)
  }
  return text.replace(/^( *function \w+\([^)]*\))\s*:\s*\w+/, '$1')
}
function runIn(scope, ...names) {
  vm.createContext(scope)
  vm.runInContext(names.map(fn).join('\n'), scope)
  return scope
}

{ // Hostile compositor metadata must not become Lua; only a hex address dispatches.
  const calls = [], s = runIn({ Hyprland: { dispatch: x => calls.push(x) } }, 'focusWindow')
  s.focusWindow({ wmClass: 'x\\"}); os.execute("bad") --' })
  s.focusWindow({ address: '0x123);bad()', wmClass: 'x' })
  assert.equal(calls.length, 0)
  s.focusWindow({ address: '0x123abc' })
  assert.deepEqual(calls, ['hl.dsp.focus({window = hl.get_window("address:0x123abc")})'])
}

// Admission, close and replay run for real; only the ListModel, QObject
// signals, the deferred event loop and external effects are faked.
const capacityFunctions = ['pinDeckDisplay', 'showsOn', 'fullscreenOn',
  'durationFor', 'liveCount', 'reserveLive', 'releaseLive',
  'nextKey', 'rowIndexFor', 'keyForOriginal', 'handleNotification', 'watchNotification', 'showRow', 'release', 'closeToast',
  'closeToasts', 'unmarkLeaving', 'finishDeparted', 'newestLive', 'finishLeaving', 'finishClose', 'clearAll', 'dismissNewest', 'releaseHeld', 'restoreRows', 'actionsOf', 'dismissOne',
  'storePut', 'storeClose', 'storeDrop', 'storeRecord', 'saveSoon', 'loadLive']

function newCapacityScope() {
  const toasts = { rows: [],
    get count() { return this.rows.length },
    get(i) { return this.rows[i] },
    insert(i, row) { this.rows.splice(i, 0, { ...row }) },
    setProperty(i, role, value) { this.rows[i][role] = value },
    remove(i) { this.rows.splice(i, 1) } }
  const later = []
  const s = {
    toasts, refs: {}, refsRevision: 0, keySeed: 0, liveKeys: Object.create(null),
    maxLiveNotifications: 100, heights: {}, fresh: {}, leaving: {}, departures: {}, layoutRevision: 0,
    arriving: '', jumping: false, travel: 24, arriveDuration: 250, leaveDuration: 200, placements: {},
    held: [], doNotDisturb: false,
    liveEntries: [], historyEntries: [], unsaved: {}, liveLoaded: false,
    saveTimer: { running: false, start() {} },
    deckDisplayName: '',
    hyprRevision: 0,
    displayNames: ['fixture-display'], focusedDisplayName: 'fixture-display',
    Quickshell: { screens: [] }, Hyprland: { monitorFor: screen => screen.monitor },
    lowDuration: 5000, normalDuration: 8000, maxDuration: 30000,
    Security: S, Delivery, Store, Markup: M,
    NotificationUrgency: { Critical: 2, Normal: 1, Low: 0 },
    Qt: { callLater: f => later.push(f),
      md5: value => require('node:crypto').createHash('md5').update(value).digest('hex') },
    Style: { space: n => n, duration: n => n },
    departureDeadline: { running: false, start() {}, restart() {} },
    holding: () => s.pointerHolding === true,
    snapshot: () => ({}), deckHeight: 0, retarget: () => {}, land: () => {}, layout: { placements: {} },
  }
  // Bare QML properties and service-qualified accesses are the same object.
  s.service = s
  runIn(s, ...capacityFunctions)
  s.drainCallLater = () => { while (later.length) later.shift()() }
  s.fakeNotification = (id = 0, summary = 'Synthetic', urgency = 1) => {
    let tracked = false, destroyed = false
    const signal = () => {
      const listeners = []
      return { connect: f => listeners.push(f), emit: () => listeners.slice().forEach(f => f()) }
    }
    const close = reason => {
      n.closeAttempts++
      if (destroyed) { n.destroyedCloseAttempts++; return }
      destroyed = true
      tracked = false
      if (reason === 'expired') n.expiries++
      else n.dismissals++
      n.closed.emit()
    }
    const n = { id, summary, body: 'Synthetic body: ' + summary, urgency, appName: 'Fixture',
      actions: [{ identifier: 'open', text: summary }], dismissals: 0, expiries: 0,
      closeAttempts: 0, destroyedCloseAttempts: 0, closed: signal(),
      get tracked() { return tracked },
      set tracked(value) { if (value) tracked = true; else close('dismissed') },
      dismiss() { close('dismissed') },
      expire() { close('expired') },
      // NotificationServer::Notify mutates the same QObject; no new server event.
      replace(properties) {
        const changed = Object.keys(properties).filter(field => n[field] !== properties[field])
        Object.assign(n, properties)
        for (const field of changed) n[field + 'Changed'].emit()
      },
    }
    for (const field of ['summary', 'body', 'appName', 'appIcon', 'image', 'urgency', 'expireTimeout', 'hints', 'actions'])
      n[field + 'Changed'] = signal()
    return n
  }
  s.admit = (...notes) => { for (const n of notes) s.handleNotification(n); s.drainCallLater() }
  return s
}
const summaries = rows => Array.from(rows, row => row.summary)

{ // Step aside for fullscreen windows, but not merely maximised ones.
  const s = newCapacityScope()
  const game = { lastIpcObject: { fullscreen: 1, class: 'steam_app_31' } }
  s.Quickshell.screens = [{ name: 'game',
    monitor: { activeWorkspace: { hasFullscreen: true, toplevels: { values: [game] } } } }]
  assert.equal(s.fullscreenOn('game'), false)
  game.lastIpcObject.fullscreen = 2
  assert.equal(s.fullscreenOn('game'), true)
}

{ // Rapid single dismissals must skip rows that are leaving but not yet removed.
  const s = newCapacityScope()
  assert.equal(s.dismissOne(), 'none')
  const senders = [1, 2, 3, 4].map(id => s.fakeNotification(id))
  s.admit(...senders)
  const keys = s.toasts.rows.map(row => row.key)
  s.closeToast(keys[0], 'expired')
  for (const key of keys.slice(1)) {
    assert.equal(s.dismissOne(), 'ok')
    assert.equal(s.leaving[key], 'dismissed', 'each press selects the next live card')
  }
  assert.equal(s.dismissOne(), 'none', 'departing cards are not dismissible')
  assert.equal(s.toasts.count, 4, 'leaving rows keep their model slots until the next tick')
  assert.equal(s.leaving[keys[0]], 'expired', 'dismissal preserves an earlier expiry')
  s.drainCallLater()
  assert.equal(s.toasts.count, 0, 'the next tick removes every leaving row')
  assert.equal(Object.keys(s.leaving).length, 0)
  assert.equal(senders[3].expiries, 1)
  for (const sender of senders.slice(0, 3)) assert.equal(sender.dismissals, 1)
  for (const sender of senders) assert.equal(sender.closeAttempts, 1)
}

{ // A clicked card rises out before it goes; a keypress clears every card with one jump.
  const s = newCapacityScope()
  s.admit(...[1, 2, 3].map(id => s.fakeNotification(id)))
  let lands = 0, moves = 0
  s.land = () => { lands += 1 }
  s.retarget = () => { moves += 1 }
  s.closeToast(s.toasts.get(0).key, 'dismissed')
  s.drainCallLater()
  assert.equal(moves, 1)
  assert.equal(s.toasts.count, 3, 'a clicked card keeps its row until its exit move finishes')
  assert.equal(s.clearAll('dismissed', true), 3)
  assert.equal(lands, 1)
  s.drainCallLater()
  assert.equal(s.toasts.count, 0, 'the jump takes the card already on its way out too')
}

{ // A card on its way out is passed over by the shortcuts, and goes on its own deadline
  // however often an update restarts the scene.
  const s = newCapacityScope()
  s.admit(...[1, 2].map(id => s.fakeNotification(id)))
  const [front, back] = s.toasts.rows.map(row => row.key)
  const at = { y: 0, scale: 1, opacity: 1, height: 58 }
  s.snapshot = () => ({ [front]: at, [back]: at })
  s.closeToast(front, 'dismissed')
  assert.equal(s.newestLive(), back, 'the activation shortcut must not run the departing card again')
  s.finishDeparted(Date.now())
  assert.equal(s.toasts.count, 2, 'the card rises out before it goes')
  s.finishDeparted(Date.now() + 1000)
  assert.deepEqual(s.toasts.rows.map(row => row.key), [back], 'its deadline removes it without the scene settling')
}

{ // A sender replacing a card during its exit brings it back instead of losing the update.
  const s = newCapacityScope()
  const sender = s.fakeNotification(1, 'Expiring')
  s.admit(sender)
  const key = s.keyForOriginal(1)
  s.snapshot = () => ({ [key]: { y: 0, scale: 1, opacity: 1, height: 58 } })
  s.closeToast(key, 'expired')
  sender.replace({ summary: 'Still going', expireTimeout: 12345 })
  s.drainCallLater()
  s.finishDeparted(Date.now() + 1000)
  assert.equal(s.toasts.count, 1)
  assert.equal(s.toasts.get(0).summary, 'Still going')
  assert.equal(sender.expiries, 0, 'the fresh notification must not be reported expired')
}

{ // A code must not outlive its toast, even in source metadata.
  const s = newCapacityScope()
  const code = s.fakeNotification(1, 'Your verification code is 938271')
  code.appName = 'Source 938271'
  s.admit(code)
  s.finishClose(s.keyForOriginal(1), 'expired')
  assert.ok(Store.redacted(s.historyEntries[0]))
  assert.ok(!Store.redacted({ summary: 'Verification notification', body: 'a real message' }))
  assert.ok(!JSON.stringify(s.historyEntries).includes('938271'))
}

{ // The keyboard only selects cards that fit on screen: the deck does not scroll.
  const s = newCapacityScope()
  const other = s.fakeNotification(9, 'Other app')
  other.appName = 'Other'
  s.admit(other, ...[1, 2, 3, 4, 5].map(id => s.fakeNotification(id, 'Card ' + id)))
  Object.assign(s, { Layout, gap: 6, targetDisplayName: 'fixture-display', marginsFor: () => ({ top: 10, right: 10 }),
    Quickshell: { screens: [{ name: 'fixture-display', height: 300 }] }, keyboardMode: true, keyboardRejected: {} })
  runIn(s, 'layoutWith', 'reachable', 'moveSelection', 'keepSelectionInReach', 'keyboardOrder')
  for (const row of s.toasts.rows) s.heights[row.key] = 100
  Object.defineProperty(s, 'layout', { get: () => s.layoutWith(true, s.openDeck) })
  s.selectCard = key => { s.keyboardKey = key; s.openDeck = Layout.groupKeyFor(s.toasts.get(s.rowIndexFor(key))) }
  const summary = () => s.toasts.get(s.rowIndexFor(s.keyboardKey)).summary
  s.selectCard(s.keyboardOrder()[0])
  s.moveSelection(1)
  // 300 tall, 10 down, 6 apart: two 100-tall cards fit, the third would end at 322...
  assert.equal(summary(), 'Card 4')
  // ...so Down skips the rest of that deck for the next one, which fits once it opens.
  s.moveSelection(1)
  assert.equal(summary(), 'Other app')
  s.moveSelection(-1)
  assert.equal(summary(), 'Card 4')
  // A selected card that grows past the bottom (its buttons, its body) gives way.
  const grown = s.keyboardKey
  s.heights[grown] = 200
  s.keepSelectionInReach()
  assert.equal(summary(), 'Card 5')
  // Its buttons hide again once it is not selected; Down passes it rather than
  // landing on it and giving way again, forever.
  s.heights[grown] = 100
  s.moveSelection(1)
  assert.equal(summary(), 'Other app')
}

for (const held of [true, false]) { // Capacity: at most 100 live senders, held or deferred.
  const s = newCapacityScope()
  s.pointerHolding = held
  const arrivals = Array.from({ length: 150 }, (_, i) => s.fakeNotification(i + 1))
  arrivals.forEach(n => s.handleNotification(n))
  assert.equal(s.toasts.count, 0, 'held/deferred arrivals have not entered the model')
  assert.equal(arrivals.filter(n => n.tracked).length, 100)
  assert.equal(s.liveCount(), 100)
  if (held) assert.equal(s.held.length, 100)
  const updated = arrivals[0]
  for (const summary of ['First replacement', 'Second replacement', 'Latest replacement']) {
    updated.replace({ summary, body: 'Synthetic body: ' + summary, actions: [{ identifier: 'open', text: summary }] })
    assert.equal(updated.tracked, true, 'pending replacement stays accepted at capacity')
    assert.equal(s.liveCount(), 100)
    if (held) assert.equal(s.held.length, 100, 'replacement does not queue a second card')
  }
  s.pointerHolding = false
  s.releaseHeld()
  s.drainCallLater()
  assert.equal(s.toasts.count, 100)
  const replacements = s.toasts.rows.filter(row => row.originalId === 1)
  assert.equal(replacements.length, 1)
  assert.equal(replacements[0].summary, 'Latest replacement')
  assert.equal(replacements[0].body, 'Synthetic body: Latest replacement')
}

{ // Visible replacements keep their position and expose only the latest sender's actions.
  const s = newCapacityScope()
  const updated = s.fakeNotification(1, 'Original')
  s.handleNotification(updated)
  for (let i = 2; i <= 100; i++) s.handleNotification(s.fakeNotification(i))
  s.drainCallLater()
  const key = s.keyForOriginal(1), index = s.rowIndexFor(key)
  s.pointerHolding = true
  updated.replace({ summary: 'Updated', actions: [{ identifier: 'open', text: 'Updated' }] })
  updated.replace({ summary: 'Same object latest', body: 'Latest body', expireTimeout: 12345 })
  s.drainCallLater()
  assert.equal(s.rowIndexFor(key), index)
  assert.equal(s.toasts.get(index).summary, 'Same object latest')
  assert.equal(s.toasts.get(index).body, 'Latest body')
  assert.equal(s.toasts.get(index).duration, 12345)
  assert.equal(s.actionsOf(key)[0].text, 'Updated')
  assert.equal(s.held.length, 0)
  assert.equal(s.toasts.count, 100)
  const rejected = s.fakeNotification(1001)
  s.handleNotification(rejected)
  assert.equal(rejected.tracked, false)
  updated.replace({ summary: 'Cancelled visible update' })
  s.closeToast(key, 'expired')
  assert.equal(s.liveCount(), 100, 'a leaving visible row retains its reservation')
  s.finishClose(key, 'expired')
  s.finishClose(key, 'expired')
  s.drainCallLater()
  assert.equal(s.toasts.count, 99, 'a pending visible update cannot resurrect a closed card')
  assert.equal(updated.expiries, 1)
  assert.equal(updated.closeAttempts, 1, 'expire must not be followed by a second close via tracked=false')
  assert.equal(updated.destroyedCloseAttempts, 0)
  assert.equal(updated.tracked, false)
  assert.equal(s.actionsOf(key).length, 0)
  assert.equal(s.liveCount(), 99)
}

for (const held of [true, false]) { // A cancelled pending card frees exactly one slot.
  const s = newCapacityScope()
  s.pointerHolding = held
  const dropped = s.fakeNotification(1, 'Cancelled')
  s.handleNotification(dropped)
  for (let i = 2; i <= 100; i++) s.handleNotification(s.fakeNotification(i))
  dropped.replace({ summary: 'Cancelled pending update' })
  const key = s.keyForOriginal(1)
  s.closeToast(key, 'dismissed')
  s.closeToast(key, 'dismissed')
  assert.equal(dropped.dismissals, 1)
  assert.equal(dropped.closeAttempts, 1, 'dismiss must not be followed by tracked=false')
  assert.equal(dropped.destroyedCloseAttempts, 0)
  assert.equal(dropped.tracked, false)
  assert.equal(s.liveCount(), 99)
  const replacement = s.fakeNotification(1, 'Reused sender ID')
  s.handleNotification(replacement)
  assert.equal(replacement.tracked, true)
  dropped.closed.emit()
  const rejected = s.fakeNotification(1001)
  s.handleNotification(rejected)
  assert.equal(rejected.tracked, false, 'cancellation frees exactly one slot')
  s.pointerHolding = false
  s.releaseHeld()
  s.drainCallLater()
  assert.equal(s.toasts.count, 100)
  assert.equal(s.toasts.rows.filter(r => r.summary === 'Cancelled').length, 0)
  assert.equal(s.toasts.rows.filter(r => r.summary === 'Reused sender ID').length, 1)
}

{ // A callback queued before the pointer arrived must not insert or overwrite the held update.
  const s = newCapacityScope()
  const pending = s.fakeNotification(1, 'Deferred')
  s.handleNotification(pending)
  s.pointerHolding = true
  pending.replace({ summary: 'Held update' })
  s.drainCallLater()
  assert.equal(s.toasts.count, 0)
  s.pointerHolding = false
  s.releaseHeld()
  pending.replace({ summary: 'Update after release' })
  s.drainCallLater()
  assert.deepEqual(summaries(s.toasts.rows), ['Update after release'])
}

{ // Sender withdrawal cancels pending cards but leaves an already visible snapshot intact.
  const s = newCapacityScope()
  const withdrawn = s.fakeNotification(1, 'Withdrawn')
  s.handleNotification(withdrawn)
  withdrawn.replace({ summary: 'Withdrawn pending update' })
  withdrawn.tracked = false
  s.drainCallLater()
  assert.equal(s.liveCount(), 0)
  assert.equal(s.toasts.count, 0)
  const visible = s.fakeNotification(2, 'Visible')
  s.admit(visible)
  const key = s.keyForOriginal(2)
  visible.tracked = false
  assert.equal(s.toasts.get(0).summary, 'Visible')
  assert.equal(s.actionsOf(key).length, 0)
  assert.equal(s.liveCount(), 1)
  s.finishClose(key, 'dismissed')
  assert.equal(s.liveCount(), 0)
}

for (const holding of [false, true]) { // Silencing closes a muted update; only Omarchy and bare notify-send critical get through.
  const s = newCapacityScope()
  s.pointerHolding = holding
  const muted = s.fakeNotification(1, 'Before quiet')
  s.handleNotification(muted)
  s.doNotDisturb = true
  muted.replace({ summary: 'Quiet update' })
  s.releaseHeld()
  s.drainCallLater()
  assert.equal(muted.tracked, false)
  assert.equal(s.liveCount(), 0)
  assert.equal(muted.closeAttempts, 1)
  assert.equal(s.toasts.count, 0)
  for (const [id, summary, urgency, app, shows] of [[2, 'Branded critical', 2, 'Fixture', false],
                                                     [3, 'Critical', 2, 'notify-send', true],
                                                     [4, 'Theme changed', 0, 'omarchy-action', true]]) {
    const before = s.toasts.count, n = s.fakeNotification(id, summary, urgency)
    n.appName = app
    s.handleNotification(n)
    s.releaseHeld()
    s.drainCallLater()
    assert.equal(s.toasts.count - before, shows ? 1 : 0, (holding ? 'holding: ' : '') + summary)
    if (shows) assert.equal(s.toasts.get(0).summary, summary)
  }
}

{ // A muted visible replacement keeps the old card, not a previously queued update.
  const s = newCapacityScope()
  const visible = s.fakeNotification(1, 'Visible original')
  s.admit(visible)
  visible.replace({ summary: 'Pending update' })
  s.doNotDisturb = true
  visible.replace({ summary: 'Muted update' })
  s.drainCallLater()
  assert.equal(s.toasts.get(0).summary, 'Visible original')
  assert.equal(s.liveCount(), 1)
  assert.equal(s.actionsOf(s.keyForOriginal(1)).length, 0)
}

{ // Non-text updates refresh the snapshot too: urgency, and the sender-pid hint.
  const s = newCapacityScope()
  const n = s.fakeNotification(1, 'Unchanged text')
  s.admit(n)
  n.replace({ urgency: 2 })
  s.drainCallLater()
  assert.equal(s.toasts.get(0).urgency, 2)
  assert.equal(s.toasts.get(0).duration, 0)
  n.replace({ hints: { 'sender-pid': 1234 } })
  s.drainCallLater()
  assert.equal(s.toasts.get(0).senderPid, 1234)
  assert.equal(s.toasts.count, 1)
}

const storedRows = count => Array.from({ length: count }, (_, i) => ({ key: 'stored-' + i, summary: 'Stored ' + i }))
for (const replay of [false, true]) { // Replay and startup restore share held reservations.
  const s = newCapacityScope()
  s.pointerHolding = true
  for (let i = 1; i <= 98; i++) s.handleNotification(s.fakeNotification(i))
  s.restoreRows(storedRows(4), replay)
  assert.equal(s.liveCount(), 100)
  s.restoreRows([{ key: 'overflow', summary: 'Overflow' }], !replay)
  s.drainCallLater()
  assert.equal(s.toasts.count, 2)
  s.finishClose(s.toasts.get(0).key, 'dismissed')
  s.restoreRows([{ key: 'reused-slot', summary: 'Slot reused' }], !replay)
  s.pointerHolding = false
  s.releaseHeld()
  s.drainCallLater()
  assert.equal(s.toasts.count, 100)
  assert.equal(s.toasts.rows.filter(r => r.summary === 'Slot reused').length, 1)
  assert.equal(s.toasts.rows.filter(r => r.summary === 'Overflow').length, 0)
  assert.equal(new Set(s.toasts.rows.map(r => r.key)).size, 100)
}

{ // Startup itself is bounded, including a replay before its deferred insertions drain.
  const s = newCapacityScope()
  s.restoreRows(storedRows(150), false)
  s.restoreRows([{ key: 'history-a' }, { key: 'history-b' }], true)
  s.drainCallLater()
  assert.equal(s.toasts.count, 100)
  assert.equal(s.liveCount(), 100)
  assert.equal(s.toasts.get(0).summary, 'Stored 99', 'startup order remains newest first')
  s.clearAll('dismissed')
  for (const row of [...s.toasts.rows]) s.finishClose(row.key, 'dismissed')
  s.restoreRows([{ key: 'history-a' }, { key: 'history-b' }], true)
  s.drainCallLater()
  assert.equal(s.toasts.count, 2)
}

{ // Repeated replay creates distinct cards; restore cannot overwrite an admitted key.
  const s = newCapacityScope()
  s.restoreRows([{ key: 'same', app: 'notify-send', summary: 'Original' }], true)
  s.restoreRows([{ key: 'same', app: 'notify-send', summary: 'Replay' }], true)
  s.restoreRows([{ key: 'same', app: 'notify-send', summary: 'Stale startup' }], false)
  s.drainCallLater()
  assert.deepEqual(summaries(s.toasts.rows), ['Replay', 'Original'])
  assert.equal(new Set(s.toasts.rows.map(r => r.key)).size, 2)
  assert.equal(new Set(s.toasts.rows.map(r => r.groupKey)).size, 2, 'the replayed card is its own deck')
}

{ // Clearing pending rows cancels their callbacks even if replay reuses the exact key.
  const s = newCapacityScope()
  s.restoreRows([{ key: 'same', summary: 'Cancelled replay' }], true)
  s.pointerHolding = true
  const held = s.fakeNotification(1, 'Cancelled held')
  s.handleNotification(held)
  s.clearAll('cleared')
  assert.equal(s.liveCount(), 0)
  assert.equal(held.tracked, false)
  s.restoreRows([{ key: 'same', summary: 'Latest replay' }], true)
  s.releaseHeld()
  s.drainCallLater()
  assert.deepEqual(summaries(s.toasts.rows), ['Latest replay'])
  assert.equal(s.liveCount(), 1)
}

{ // A restarted server may allocate an ID that persisted rows carried last session.
  const s = newCapacityScope()
  s.restoreRows([{ key: 'previous-session', originalId: 1, summary: 'Previous session' }], false)
  s.drainCallLater()
  s.admit(s.fakeNotification(1, 'New session'))
  assert.deepEqual(summaries(s.toasts.rows), ['New session', 'Previous session'])
}

{ // ID zero never replaces a pending notification or a restored card.
  const s = newCapacityScope()
  s.restoreRows([{ key: 'restored-zero', summary: 'Restored zero' }], false)
  s.admit(s.fakeNotification(0, 'First zero'), s.fakeNotification(0, 'Second zero'))
  assert.equal(s.toasts.count, 3)
  assert.equal(new Set(s.toasts.rows.map(r => r.key)).size, 3)
  assert.equal(s.liveCount(), 3)
}


// ---------------------------------------------------------------- persistence
const plain = value => JSON.parse(JSON.stringify(value))
// Arrays from the module's own realm compare by value.
const eq = (actual, expected, message) => assert.deepEqual(plain(actual), plain(expected), message)

{ // A stored row keeps only its scalar fields: no codes, links, images or
  // derived text.
  const saved = Store.persistable({ key: 'n1', app: 'Chat', summary: 'Hi', body: 'See https://example.com',
    code: '1234', codes: '1234', link: 'https://example.com', image: '/tmp/a.png',
    bodyRich: '<b>x</b>', transient: true })
  eq(Object.keys(saved).sort(), [...Store.STORED].sort())
  assert.equal(saved.rawBody, '', 'a raw body the same as the body is not stored twice')
}

{ // Codes persist only as the redacted placeholder, on write and on read back,
  // while numbered ordinary messages survive whole.
  const secrets = [{ code: '938271', body: '938271' }, { codes: '938271', rawBody: '&#57;38271' }, { body: 'Your code is 938271' },
    { body: 'Your code is G-938271' }, { body: 'Your OTP is 938 271' }, { body: 'Your OTP is 938\t271' }, { body: 'Your OTP is 938\n271' },
    { body: 'Your code is 72-9182' }, { body: 'Your code is A9F3K2' }, { body: 'Your code is &#57;38271' },
    { body: 'Your code is &amp;#57;38271' }, { body: 'Your OTP is 938<br/>271' },
    { body: 'Your code to finish signing in to your account in this browser is 938271' },
    { body: '938271 is your verification code' }, { body: 'Please confirm 938271' }, { body: 'Your security key is 938271' },
    { body: 'Your Verification Code is 938271' }, { summary: 'Your code is', body: '938271' }, { summary: 'Your OTP is 938271' },
    { rawBody: 'Your OTP is 938\n271', body: 'Open the app' }]
  for (const text of secrets) {
    const entry = { key: 'k', urgency: 1, app: 'alternate-secret', source: 'alternate-secret', appIcon: 'alternate-secret',
                    image: '/etc/passwd', glyph: '\u{f0306}',
                    execArgv: JSON.stringify(['xdg-open', 'https://example.com/938271']), ...text }
    for (const saved of [Store.persistable(entry), Store.parseLive(JSON.stringify([entry]))[0],
                         Store.parseHistory(JSON.stringify([{ ...entry, closed_ts: 1 }]))[0]]) {
      assert.ok(Store.redacted(Store.restored(saved)), JSON.stringify(text))
      eq([saved.app, saved.source, saved.appIcon, saved.glyph, saved.execArgv], ['', '', '', '', ''])
      assert.ok(!/938|9182|A9F3K2|alternate|passwd/.test(JSON.stringify(saved)), JSON.stringify(saved))
    }
  }
  for (const [app, summary, body] of [['Visual Studio Code', 'Build finished', 'Build 4123 completed successfully'],
      ['Assistant', 'Task finished', 'Claude Code finished build 4123'], ['Chat', 'New message', 'Please review the code from 2025'],
      ['VS Code', 'Build finished', 'VS Code finished build 4123'], ['Xcode', 'Build finished', 'Xcode build 4123 completed'],
      ['Chat', 'Review requested', 'Please review code abc123'], ['OTP Monitor', 'Build finished', 'Build 4123 completed successfully'],
      ['Auth', 'Verification completed successfully', 'Account ready'], ['Settings', 'PIN configuration updated', 'Settings saved']]) {
    const [saved] = Store.parseLive(JSON.stringify([Store.persistable({ key: 'notification-4123', app, summary, body, urgency: 1 })]))
    eq([saved.app, saved.summary, saved.body], [app, summary, body], body)
  }
}

{ // Rows are bounded: a live row stays restorable, a history row stays small,
  // and text is cut from the end before the click command goes.
  const argv = JSON.stringify(['notify-send', 'x'.repeat(3000)])
  for (const body of ['x'.repeat(30000), '中'.repeat(30000), '\u{1F600}'.repeat(16000), '\u0001'.repeat(30000)]) {
    const live = Store.persistable({ key: 'big', summary: 'Long', body, rawBody: 'raw ' + body, execArgv: argv })
    assert.ok(JSON.stringify(live).length <= Store.LIVE_ROW_CHARS)
    assert.ok(live.body.length > 500 && body.startsWith(live.body) && live.execArgv === argv)
    const closed = Store.closedEntry(live, 'dismissed', 1)
    assert.ok(JSON.stringify(closed).length <= Store.HISTORY_ROW_CHARS + 64)
    assert.ok(body.startsWith(closed.body) && closed.rawBody.startsWith('raw '))
  }
  const huge = Store.closedEntry({ key: 'h', summary: '\u0001'.repeat(2048), body: 'b', execArgv: JSON.stringify(['run', 'y'.repeat(4000)]) }, 'x', 1)
  assert.ok(JSON.stringify(huge).length <= Store.HISTORY_ROW_CHARS + 64)
  assert.equal(huge.execArgv, '')
}

{ // History is newest first, capped, and kept for a day.
  const now = 1e6, entry = (key, age, reason = 'dismissed') => ({ key, closed_ts: now - age, closed_reason: reason })
  let history = []
  for (let i = 0; i < 150; i++) history = Store.addHistory(history, entry('n' + i, 150 - i), now)
  assert.equal(history.length, 100)
  assert.equal(history[0].key, 'n149')
  eq(Store.retain([entry('a', 60), entry('b', 24 * 3600 - 1), entry('c', 24 * 3600 + 1)], now).map(e => e.key), ['a', 'b'])
  assert.equal(Store.closedEntry({ key: 'x' }, 'Bad reason!', 1).closed_reason, '')
}

{ // Live rows: one per key, replaced in place, the oldest dropped past capacity.
  let live = []
  for (let i = 0; i < 120; i++) live = Store.putLive(live, { key: 'n' + i })
  assert.equal(live.length, 100)
  assert.equal(live[0].key, 'n20')
  live = Store.putLive(live, { key: 'n50', summary: 'updated' })
  assert.equal(live.length, 100)
  assert.equal(live[30].summary, 'updated')
  assert.equal(Store.liveEntry(live, 'n50').summary, 'updated')
  assert.equal(Store.liveEntry(Store.dropLive(live, 'n50'), 'n50'), null)
  const merged = Store.mergeLive([{ key: 'a', summary: 'stored' }, { key: 'b' }], [{ key: 'a', summary: 'arrived' }, { key: 'c' }])
  eq(merged.map(e => e.key + (e.summary ? ':' + e.summary : '')), ['a:arrived', 'b', 'c'])
}

{ // Hostile or broken files read as nothing, never as a crash or a capability.
  for (const text of ['', '   ', 'not json', '{"key":"a"}', '"text"', '42', 'null', '[1, "a", null, [], true]',
                      '[{"summary":"no key"}]', '[{"key":"../escape"}]', '[{"key":""}]', '[{"key":7}]',
                      '[{"key":"' + 'k'.repeat(121) + '"}]', '[' + '['.repeat(5000) + ']'.repeat(5000) + ']'])
    for (const parse of [Store.parseLive, Store.parseHistory]) eq(parse(text), [], text.slice(0, 40))
  const big = JSON.stringify(Array.from({ length: 150 }, (_, i) => ({ key: 'n' + i, summary: 's', closed_ts: 1 })))
  assert.equal(Store.parseLive(big).length, 100)
  assert.equal(Store.parseHistory(big).length, 100)
  eq(Store.parseLive(' '.repeat(Store.LIVE_LIMIT * Store.LIVE_ROW_CHARS * 2 + 1) + '[{"key":"a"}]'), [],
                   'an oversized file is not parsed at all')
  const [row] = Store.parseLive(JSON.stringify([{ key: '__proto__', summary: 's', image: '/tmp/a.png', bodyRich: '<img src=x>',
    link: 'https://evil.example/', urgency: 'high', ts: 'soon', glyph: '\n' }]))
  eq([row.key, row.image, row.link, row.urgency, row.ts, row.glyph, 'bodyRich' in row],
                   ['__proto__', undefined, undefined, 1, 0, '', false])
  assert.equal(Store.parseLive('[{"key":"a","summary":"first"},{"key":"a","summary":"second"}]').length, 1)
  // The previous engine's rows had no key; rows without a close time are not history.
  eq(Store.parseHistory('[{"id":7,"summary":"Legacy","timestamp":1},{"key":"n1","summary":"open"}]'), [])
  eq(Store.parseHistory('[{"key":"n1","closed_ts":"1"},{"key":"n2","closed_ts":1e999}]'), [])
}

{ // What is written reads back as itself, so a clean file is never rewritten.
  const rows = [Store.persistable(snap({ appName: 'Google Chrome', summary: '#design',
                  body: '<a href="https://app.slack.com/">app.slack.com</a>\n\nGurbinder: <b>look</b>',
                  hints: { 'omarchy-exec-argv': JSON.stringify(['omarchy-update']), 'omarchy-glyph': '\u{f0954}' } }, 'n1')),
                Store.persistable({ key: 'n2', summary: 'Your code is 938271' }),
                Store.persistable({ key: 'n3', body: '中'.repeat(30000) })]
  const text = Store.serialise(rows)
  assert.equal(Store.serialise(Store.parseLive(text)), text)
  const history = rows.map((row, i) => Store.closedEntry(row, 'expired', 1000 + i))
  assert.equal(Store.serialise(Store.parseHistory(Store.serialise(history))), Store.serialise(history))
  // Restored, a card clicks through and draws its glyph like the live one.
  const restored = Store.restored(Store.parseLive(text)[0])
  eq([restored.restored, restored.duration, restored.execArgv, restored.glyph, restored.source],
                   [true, Store.RESTORE_GRACE, '["omarchy-update"]', '\u{f0954}', 'app.slack.com'])
  assert.equal(Store.normalise(history[0]).bodyLine, restored.bodyLine)
}

{ // quiet.json keeps today's shape, and anything else in it is ignored.
  const state = { dnd: true }
  eq(Store.parseQuiet(Store.serialiseQuiet(state)), state)
  eq(JSON.parse(Store.serialiseQuiet(state)), state)
  for (const text of ['', 'nope', '[]', '"dnd"', 'null'])
    assert.equal(Store.parseQuiet(text), null, text)
  const odd = Store.parseQuiet('{"snoozes":{"a":{"until":5}},"dnd":"yes","silencedSince":"later","codesBypassQuiet":"no"}')
  eq(odd, { dnd: false })
}

{ // The service: shown rows are saved live, closed ones move to history, quiet
  // ones go straight there, and ephemeral ones are never written.
  const s = newCapacityScope()
  s.admit(s.fakeNotification(1, 'Shown'))
  const key = s.keyForOriginal(1)
  eq(s.liveEntries.map(e => e.summary), ['Shown'])
  s.finishClose(key, 'expired')
  eq([s.liveEntries.length, s.historyEntries[0].summary, s.historyEntries[0].closed_reason], [0, 'Shown', 'expired'])
  s.doNotDisturb = true
  s.handleNotification(s.fakeNotification(2, 'Silenced'))
  const quiet = s.fakeNotification(3, 'Ephemeral')
  quiet.appName = 'notify-send'
  s.handleNotification(quiet)
  eq(s.historyEntries.map(e => e.summary + ':' + e.closed_reason), ['Silenced:silenced', 'Shown:expired'])
  assert.equal(s.liveEntries.length, 0)
  assert.ok(s.unsaved.live && s.unsaved.history)
}

{ // A pending card silenced before it showed leaves nothing to restore.
  const s = newCapacityScope()
  s.pointerHolding = true
  const pending = s.fakeNotification(1, 'Pending')
  s.handleNotification(pending)
  assert.equal(s.liveEntries.length, 1)
  s.doNotDisturb = true
  pending.replace({ summary: 'Silenced update' })
  s.drainCallLater()
  eq([s.liveEntries.length, s.historyEntries[0].summary], [0, 'Silenced update'])
}

{ // Startup restore: stored rows come back under any newer arrival, and a row
  // with no room is not kept to haunt the next restart.
  const s = newCapacityScope()
  s.admit(s.fakeNotification(1, 'Arrived first'))
  const text = Store.serialise([...Array.from({ length: 100 }, (_, i) => Store.persistable({ key: 'old' + i, summary: 'Old ' + i }))])
  s.loadLive(text)
  s.drainCallLater()
  assert.equal(s.toasts.count, 100)
  assert.equal(s.liveEntries.length, 100)
  assert.ok(s.liveEntries.every(e => s.liveKeys[e.key]))
  assert.equal(s.liveEntries[99].summary, 'Arrived first')
  assert.ok(s.toasts.rows.filter(r => r.restored).every(r => r.duration === Store.RESTORE_GRACE))
  s.loadLive('[]')
  assert.equal(s.liveEntries.length, 100, 'a second load event is ignored')
}

console.log('notification logic: passed')
