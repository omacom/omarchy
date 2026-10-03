#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command node
require_command /usr/bin/python

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export HOME="$test_tmp/home"
export XDG_CONFIG_HOME="$test_tmp/config"
export XDG_DATA_HOME="$test_tmp/data"
export XDG_STATE_HOME="$test_tmp/state"
export XDG_CACHE_HOME="$test_tmp/cache"
export XDG_RUNTIME_DIR="$test_tmp/run"
export OMARCHY_TEST_TMP="$test_tmp"

run_node_test <<'JS'
const fs = require('fs')
const crypto = require('crypto')
const { spawnSync } = require('child_process')
const scratch = process.env.OMARCHY_TEST_TMP
const helper = path.join(root, 'bin/omarchy-install-chromium-theme-sync')
const migration = path.join(root, 'migrations/1788886195.sh')
const target = path.join(root, 'default/chromium/extensions/theme-sync')
const packaged = '/usr/share/omarchy/default/chromium/extensions/theme-sync'
const hostName = 'com.omarchy.theme.json'
const manifest = JSON.parse(fs.readFileSync(path.join(target, 'manifest.json'), 'utf8'))
const defaults = fs.readFileSync(path.join(root, 'config/chromium-flags.conf'), 'utf8')
const seeded = defaults.replace(packaged, target)
const mockBin = path.join(scratch, 'bin')
fs.mkdirSync(mockBin)

const stub = `#!/bin/bash
printf '%s:%s\\n' "\${0##*/}" "$*" >>"$TEST_LOG"
[[ \${TEST_FAIL:-} != "\${0##*/}" ]] || exit 42
case \${0##*/} in
  omarchy-install-chromium-copy-url|omarchy-install-chromium-ytdlp|omarchy-install-chromium-theme-sync|omarchy-refresh-config)
    exec "$ROOT/bin/\${0##*/}" "$@" ;;
  sudo|omarchy-pkg-add|omarchy-pkg-aur-add|omarchy-theme-set-browser|omarchy-install-chromium-google-account) exit 0 ;;
  *) exit 77 ;;
esac
`
for (const name of ['sudo', 'omarchy-pkg-add', 'omarchy-pkg-aur-add', 'omarchy-theme-set-browser',
  'omarchy-install-chromium-copy-url', 'omarchy-install-chromium-ytdlp', 'omarchy-install-chromium-theme-sync',
  'omarchy-refresh-config', 'omarchy-install-chromium-google-account', 'omarchy-refresh-chromium',
  'omarchy-restart-app', 'chromium', 'google-chrome-stable', 'brave', 'brave-origin', 'microsoft-edge-stable']) {
  fs.writeFileSync(path.join(mockBin, name), stub, { mode: 0o755 })
}

function scenario(name, configName = '.config') {
  const home = path.join(scratch, name)
  const env = { ...process.env, HOME: home, XDG_CONFIG_HOME: path.join(home, configName),
    XDG_DATA_HOME: path.join(home, '.local/share'), XDG_STATE_HOME: path.join(home, '.local/state'),
    XDG_CACHE_HOME: path.join(home, '.cache'), XDG_RUNTIME_DIR: path.join(home, 'run'),
    OMARCHY_PATH: root, PATH: `${mockBin}:${root}/bin:${process.env.PATH}`, TEST_LOG: path.join(home, 'calls') }
  fs.mkdirSync(env.XDG_CONFIG_HOME, { recursive: true })
  return env
}

function write(file, text, mode) {
  fs.mkdirSync(path.dirname(file), { recursive: true })
  fs.writeFileSync(file, text, mode === undefined ? {} : { mode })
}

function run(env, command = helper, args = [], success = true) {
  const result = spawnSync(command, args, { env, encoding: 'utf8' })
  if (result.error || (success ? result.status !== 0 : result.status === 0 || result.status === null)) {
    fail(`${path.basename(command)} ${success ? 'succeeds' : 'fails'}`, String(result.error || result.stdout + result.stderr))
  }
  return result
}

function native(env, browser = 'chromium') {
  return path.join(env.XDG_CONFIG_HOME, browser, 'NativeMessagingHosts', hostName)
}

function read(file) { return fs.readFileSync(file, 'utf8') }
function quoted(argument) { return "'" + argument.replaceAll("'", "'\\''") + "'" }
function parsedArgv(text) {
  const result = spawnSync('/usr/bin/python', ['-c', `import json, sys
from gi.repository import GLib
argv = []
for line in sys.stdin.buffer:
  try:
    argv.extend(GLib.shell_parse_argv(line.decode("utf-8"))[1])
  except GLib.Error as error:
    if not error.matches(GLib.shell_error_quark(), GLib.ShellError.EMPTY_STRING):
      raise
print(json.dumps(argv))`], { input: text, encoding: 'utf8', env: process.env })
  if (result.status !== 0) fail('the Arch launcher GLib parser accepts the flags', result.stderr)
  return JSON.parse(result.stdout)
}
function calls(env) { return read(env.TEST_LOG).trim().split('\n') }
function snapshot(files) {
  return files.map(file => {
    const stat = fs.statSync(file)
    return [file, read(file), stat.mode, stat.ino, stat.mtimeMs]
  })
}

const id = [...crypto.createHash('sha256').update(Buffer.from(manifest.key, 'base64')).digest().subarray(0, 16)]
  .map(byte => 'abcdefghijklmnop'[byte >> 4] + 'abcdefghijklmnop'[byte & 15]).join('')
assertEqual(id, 'ppnnomfimbfcofidkfmghapellfbgklc', 'Theme Sync has its stable public-key-derived extension ID')
assert(defaults.split('\n').filter(line => line.startsWith('--load-extension=')).length === 1 &&
  defaults.includes(packaged), 'shipped Chromium defaults include Theme Sync in the existing extension list')
assertEqual(fs.statSync(migration).mode & 0o777, 0o644, 'Theme Sync migration is non-executable')

const fresh = scenario('fresh')
run(fresh)
assertDeepEqual(JSON.parse(read(native(fresh))), {
  name: 'com.omarchy.theme', description: 'Omarchy Theme Sync native host',
  path: `${root}/bin/omarchy-browser-theme-host`, type: 'stdio',
  allowed_origins: [`chrome-extension://${id}/`]
}, 'fresh Chromium registers only the stable allowed origin before first launch')
assertEqual(fs.statSync(native(fresh)).mode & 0o777, 0o644, 'generated native manifests are readable 0644 files')
assertEqual(read(path.join(fresh.XDG_CONFIG_HOME, 'chromium-flags.conf')), seeded,
  'missing primary Chromium flags are seeded with all bundled extensions and the checkout path')
assertDeepEqual(fs.readdirSync(fresh.XDG_CONFIG_HOME).filter(name => name.endsWith('-flags.conf')),
  ['chromium-flags.conf'], 'setup does not create irrelevant browser flags')

const explicit = scenario('explicit-missing-brave', 'xdg config')
const explicitFlags = path.join(explicit.XDG_CONFIG_HOME, 'brave-flags.conf')
run(explicit, helper, [path.join(explicit.XDG_CONFIG_HOME, '..', 'xdg config', 'brave-flags.conf')])
assert(fs.existsSync(native(explicit, 'BraveSoftware/Brave-Browser')) && read(explicitFlags) === seeded,
  'an explicit missing Brave flags target registers its native host on the first helper call')
assertDeepEqual(fs.readdirSync(explicit.XDG_CONFIG_HOME).filter(name => name.endsWith('-flags.conf')),
  ['brave-flags.conf'], 'an explicit missing flags target does not seed other browser flags')

const user = scenario('fresh-user')
run(user, '/bin/bash', ['-euo', 'pipefail', '-c', 'source "$ROOT/install/user/chromium.sh"'])
assert(['com.omarchy.copy_url.json', 'com.omarchy.ytdlp.json', hostName].every(name =>
  fs.existsSync(path.join(user.XDG_CONFIG_HOME, 'chromium/NativeMessagingHosts', name))),
  'fresh user setup registers every bundled native host without launching Chromium')
assertDeepEqual(calls(user), ['omarchy-install-chromium-copy-url:', 'omarchy-install-chromium-ytdlp:',
  'omarchy-install-chromium-theme-sync:'], 'fresh user setup runs Theme Sync after the existing native helpers')

const inventory = [
  ['google-chrome', 'chrome'], ['google-chrome-beta', 'chrome-beta'], ['google-chrome-unstable', 'chrome-dev'],
  ['google-chrome-unstable', 'chrome-unstable'], ['BraveSoftware/Brave-Browser', 'brave'],
  ['BraveSoftware/Brave-Browser-Beta', 'brave-beta'], ['BraveSoftware/Brave-Browser-Nightly', 'brave-nightly'],
  ['BraveSoftware/Brave-Origin', 'brave-origin'], ['BraveSoftware/Brave-Origin-Beta', 'brave-origin-beta'],
  ['BraveSoftware/Brave-Origin-Nightly', 'brave-origin-nightly'], ['microsoft-edge', 'microsoft-edge-stable'],
  ['microsoft-edge-beta', 'microsoft-edge-beta'], ['microsoft-edge-dev', 'microsoft-edge-dev'], ['helium', 'helium'],
  ['vivaldi', 'vivaldi'], ['vivaldi-snapshot', 'vivaldi-snapshot'], ['opera', 'opera'],
  ['opera-beta', 'opera-beta'], ['opera-developer', 'opera-developer']
]
const upgrade = scenario('migration')
const unchanged = []
for (const [browser, flags] of inventory) {
  write(path.join(upgrade.XDG_CONFIG_HOME, `${flags}-flags.conf`), `# ${flags}\n--custom=keep\n--load-extension=/keep/${flags}\n`)
  for (const file of ['NativeMessagingHosts/other.json', 'Default/Preferences', 'Default/Secure Preferences']) {
    const destination = path.join(upgrade.XDG_CONFIG_HOME, browser, file)
    write(destination, `untouched ${file}\n`)
    unchanged.push(destination)
  }
}
write(path.join(upgrade.XDG_CONFIG_HOME, 'not-a-browser-flags.conf'), 'do not change\n')
unchanged.push(path.join(upgrade.XDG_CONFIG_HOME, 'not-a-browser-flags.conf'))
const beforeUpgrade = snapshot(unchanged)
run(upgrade, '/bin/bash', ['-euo', 'pipefail', migration])
assert(inventory.every(([browser, flags]) => fs.existsSync(native(upgrade, browser)) &&
  read(path.join(upgrade.XDG_CONFIG_HOME, `${flags}-flags.conf`)) ===
  `# ${flags}\n--custom=keep\n--load-extension=/keep/${flags},${target}\n`),
  'migration merges existing Chrome, Edge, Brave Origin, Helium, Vivaldi and Opera variant flags and hosts')
assertEqual(read(path.join(upgrade.XDG_CONFIG_HOME, 'chromium-flags.conf')), seeded,
  'migration seeds a missing primary flags file without a destructive refresh')
assertDeepEqual(snapshot(unchanged), beforeUpgrade, 'migration leaves other native manifests, browser preferences and unknown flags untouched')
const migratedFiles = [native(upgrade), path.join(upgrade.XDG_CONFIG_HOME, 'chromium-flags.conf'),
  ...inventory.flatMap(([browser, flags]) => [native(upgrade, browser), path.join(upgrade.XDG_CONFIG_HOME, `${flags}-flags.conf`)])]
const migratedSnapshot = snapshot(migratedFiles)
run(upgrade, '/bin/bash', ['-euo', 'pipefail', migration])
run(upgrade)
assertDeepEqual(snapshot(migratedFiles), migratedSnapshot, 'repeated migration and setup preserve content, modes, inodes and mtimes')
assert(calls(upgrade).every(call => call === 'omarchy-install-chromium-theme-sync:'),
  'migration never invokes refresh, package installation or browser restarts')

const profiles = scenario('profiles-only')
for (const [browser] of inventory) fs.mkdirSync(path.join(profiles.XDG_CONFIG_HOME, browser), { recursive: true })
run(profiles)
assert(inventory.every(([browser]) => fs.existsSync(native(profiles, browser))), 'existing profile roots get hosts even without launcher flags')
assertDeepEqual(fs.readdirSync(profiles.XDG_CONFIG_HOME).filter(name => name.endsWith('-flags.conf')),
  ['chromium-flags.conf'], 'existing profiles alone do not create unused variant flags')

const takeover = scenario('takeover')
const legacy = path.join(scratch, 'standalone source & [copy]', 'extension')
const unrelated = path.join(scratch, 'unrelated', 'theme-sync')
const missing = path.join(scratch, 'missing', 'extension')
const malformed = path.join(scratch, 'malformed', 'extension')
const multiple = path.join(scratch, 'multiple-json-documents', 'extension')
write(path.join(legacy, 'manifest.json'), JSON.stringify({ ...manifest, name: 'Renamed standalone' }))
write(path.join(legacy, '../.git/keep'), 'external repository stays\n')
write(path.join(unrelated, 'manifest.json'), JSON.stringify({ name: manifest.name, key: 'another-public-key' }))
write(path.join(malformed, 'manifest.json'), '{not valid json')
write(path.join(multiple, 'manifest.json'), '{}\n' + JSON.stringify(manifest))
const legacyFiles = [path.join(legacy, 'manifest.json'), path.join(legacy, '../.git/keep'),
  path.join(unrelated, 'manifest.json'), path.join(malformed, 'manifest.json'), path.join(multiple, 'manifest.json')]
const legacySnapshot = snapshot(legacyFiles)
const takeoverFlags = path.join(takeover.XDG_CONFIG_HOME, 'chromium-flags.conf')
const preserved = [unrelated, missing, malformed, multiple, unrelated]
write(takeoverFlags, `# keep comment\n${quoted(`--load-extension=/inactive-only,${legacy}`)}\n--custom=keep\n` +
  `  ${quoted(`--load-extension=${[...preserved, legacy, target, packaged, target].join(',')}`)}\n--last=unterminated`)
run(takeover)
assertEqual(read(takeoverFlags), `# keep comment\n\n--custom=keep\n  --load-extension=${[...preserved, target].join(',')}\n--last=unterminated`,
  'only the last extension list survives; same-key copies and exact packaged aliases become one selected target')
assertDeepEqual(parsedArgv(read(takeoverFlags)), ['--custom=keep', `--load-extension=${[...preserved, target].join(',')}`, '--last=unterminated'],
  'GLib sees only the effective extension list after same-key takeover')
assertDeepEqual(snapshot(legacyFiles), legacySnapshot, 'takeover never deletes or rewrites standalone repositories or unrelated manifests')
assert(read(takeoverFlags).includes(missing) && read(takeoverFlags).includes(malformed) && read(takeoverFlags).includes(multiple),
  'missing and malformed manifests are preserved rather than guessed from names')
write(takeoverFlags, '--load-extension=/disabled\n--custom=keep\n--load-extension=')
run(takeover)
assertEqual(read(takeoverFlags), `\n--custom=keep\n--load-extension=${target}`, 'an empty final extension list does not reactivate earlier extensions')
write(takeoverFlags, '--load-extension=/disabled\n--load-extension')
run(takeover)
assertEqual(read(takeoverFlags), `\n--load-extension=${target}`, 'a bare final load-extension flag also supersedes earlier lists')

const dotfiles = scenario('dotfiles')
const sourceFlags = path.join(scratch, 'source dotfiles', 'chromium-flags.conf')
const symlinkFlags = path.join(dotfiles.XDG_CONFIG_HOME, 'chromium-flags.conf')
const payload = `source "${scratch}/do-not-source"\n$(touch "${scratch}/executed")\n--custom=$HOME\\literal\n`
write(sourceFlags, `# --load-extension=/comment-only\n${payload}--last=unterminated`, 0o640)
const link = path.relative(path.dirname(symlinkFlags), sourceFlags)
fs.symlinkSync(link, symlinkFlags)
run(dotfiles)
assert(fs.lstatSync(symlinkFlags).isSymbolicLink() && fs.readlinkSync(symlinkFlags) === link,
  'setup preserves a relative symlink to source-controlled dotfiles')
assertEqual(read(sourceFlags), `--load-extension=${target}\n# --load-extension=/comment-only\n${payload}--last=unterminated`,
  'adding a missing flag preserves comments, custom flags, literal shell syntax and an unterminated final line')
assertEqual(fs.statSync(sourceFlags).mode & 0o777, 0o640, 'atomic flags updates retain existing file permissions')
assert(!fs.existsSync(path.join(scratch, 'executed')), 'flags are never evaluated or sourced')
const dangling = path.join(dotfiles.XDG_CONFIG_HOME, 'chrome-flags.conf')
const newDotfile = path.join(scratch, 'source dotfiles', 'new-flags.conf')
fs.symlinkSync(newDotfile, dangling)
run(dotfiles)
assert(fs.lstatSync(dangling).isSymbolicLink() && read(newDotfile) === seeded,
  'a dangling dotfile symlink is preserved while its target is seeded')

const special = scenario('special paths', 'xdg config & "quoted" \\ literal $HOME')
const specialRoot = path.join(scratch, 'checkout & "quoted" \\ literal $HOME and apostrophe\'s')
fs.symlinkSync(root, specialRoot)
special.OMARCHY_PATH = specialRoot
const specialFlags = path.join(special.XDG_CONFIG_HOME, 'chromium-flags.conf')
const otherPath = path.join(scratch, 'another extension & "quoted" \\ literal $HOME and apostrophe\'s')
write(specialFlags, `--custom=keep\n${quoted(`--load-extension=${otherPath},${legacy}`)}\n`)
run(special)
assertEqual(JSON.parse(read(native(special))).path, `${specialRoot}/bin/omarchy-browser-theme-host`,
  'jq safely escapes special characters in native host paths')
assertDeepEqual(parsedArgv(read(specialFlags)), ['--custom=keep', `--load-extension=${otherPath},${specialRoot}/default/chromium/extensions/theme-sync`],
  'GLib receives exact checkout and unrelated paths including spaces, quotes, apostrophes and backslashes')
assert(!fs.existsSync(path.join(special.HOME, '.config')), 'the helper honors XDG_CONFIG_HOME instead of touching HOME/.config')

const literalPath = `${scratch}/$(touch ${scratch}/executed-by-flags)`
const literalCustom = `--custom="$(touch ${scratch}/executed-by-flags)"`
const quotedPaths = "/keep one,/keep two's,/back\\slash"
const argvCases = [
  {
    name: 'multiple arguments and inline comments',
    source: '--load-extension=/keep --user-data-dir=/profile # keep comment',
    expected: `--load-extension=/keep,${target} --user-data-dir=/profile # keep comment`,
    argv: [`--load-extension=/keep,${target}`, '--user-data-dir=/profile']
  },
  {
    name: 'last switch after another argument',
    source: '--load-extension=/disabled,/also-disabled # keep old comment\n--user-data-dir=/profile --load-extension=/active # last comment',
    expected: ` # keep old comment\n--user-data-dir=/profile --load-extension=/active,${target} # last comment`,
    argv: ['--user-data-dir=/profile', `--load-extension=/active,${target}`]
  },
  {
    name: 'mixed quoting and escaped apostrophes and backslashes',
    source: String.raw`--user-data-dir="/profile with spaces" --load-extension="/keep one",'/keep two'\''s',/back\\slash # keep`,
    expected: `--user-data-dir="/profile with spaces" ${quoted(`--load-extension=${quotedPaths},${target}`)} # keep`,
    argv: ['--user-data-dir=/profile with spaces', `--load-extension=${quotedPaths},${target}`]
  },
  {
    name: 'backslashes inside comments do not continue lines',
    source: '# comment with an unmatched " and backslash\\\n--load-extension=/keep # inline backslash\\\n/second\n',
    expected: `# comment with an unmatched " and backslash\\\n--load-extension=/keep,${target} # inline backslash\\\n/second\n`,
    argv: [`--load-extension=/keep,${target}`, '/second']
  },
  {
    name: 'literal command substitutions',
    source: `${quoted(`--load-extension=${literalPath}`)} ${literalCustom} # never execute`,
    expected: `${quoted(`--load-extension=${literalPath},${target}`)} ${literalCustom} # never execute`,
    argv: [`--load-extension=${literalPath},${target}`, `--custom=$(touch ${scratch}/executed-by-flags)`]
  },
  {
    name: 'GLib tab-prefixed hashes are not comments',
    source: '--keep=one\t#literal\n--load-extension="/keep # literal"\t#not-a-comment\n',
    expected: `--keep=one\t#literal\n${quoted(`--load-extension=/keep # literal,${target}`)}\t#not-a-comment\n`,
    argv: ['--keep=one', '#literal', `--load-extension=/keep # literal,${target}`, '#not-a-comment']
  },
  {
    name: 'end-of-options marker',
    source: '--load-extension=/active\n--\n--load-extension=/positional /url',
    expected: `--load-extension=/active,${target}\n--\n--load-extension=/positional /url`,
    argv: [`--load-extension=/active,${target}`, '--', '--load-extension=/positional', '/url']
  },
  {
    name: 'missing switch before an end-of-options marker',
    source: '--\n--load-extension=/positional # keep',
    expected: `--load-extension=${target}\n--\n--load-extension=/positional # keep`,
    argv: [`--load-extension=${target}`, '--', '--load-extension=/positional']
  },
  {
    name: 'comment-only unterminated flags',
    source: '# --load-extension=/comment-only',
    expected: `--load-extension=${target}\n# --load-extension=/comment-only`,
    argv: [`--load-extension=${target}`]
  },
  {
    name: 'only LF separates physical lines, not CR, VT or FF',
    source: '# comment\r\n--load-extension=/keep --label="two\rlines" --vt="left\vright" --ff="left\fright"\n--last=end',
    expected: `# comment\r\n--load-extension=/keep,${target} --label="two\rlines" --vt="left\vright" --ff="left\fright"\n--last=end`,
    argv: [`--load-extension=/keep,${target}`, '--label=two\rlines', '--vt=left\vright', '--ff=left\fright', '--last=end']
  }
]
for (const [i, entry] of argvCases.entries()) {
  const env = scenario(`argv-${i}`)
  const flags = path.join(env.XDG_CONFIG_HOME, 'chromium-flags.conf')
  write(flags, entry.source)
  run(env)
  assertDeepEqual(parsedArgv(read(flags)), entry.argv, `${entry.name}: per-physical-line GLib argv matches the intended merge`)
  assertEqual(read(flags), entry.expected, `${entry.name}: unrelated text and physical line endings are preserved`)
  const before = snapshot([flags])
  run(env)
  assertDeepEqual(snapshot([flags]), before, `${entry.name}: repeated merging is a no-op`)
}
assert(!fs.existsSync(path.join(scratch, 'executed-by-flags')), 'neither extension paths nor other arguments execute command substitutions')

const splitExtension = scenario('split-extension-poc')
const splitFlags = path.join(splitExtension.XDG_CONFIG_HOME, 'chromium-flags.conf')
const splitSource = '--load-extension=/keep,\\\n/second\n'
write(splitFlags, splitSource, 0o640)
const splitBefore = snapshot([splitFlags])
assertDeepEqual(parsedArgv(splitSource), ['--load-extension=/keep,', '/second'],
  'the reported continuation PoC gives the real launcher a positional /second argument')
const splitResult = run(splitExtension, helper, [], false)
run(splitExtension, '/bin/bash', ['-euo', 'pipefail', migration], false)
assert(splitResult.stderr.includes('keep each argument on one physical line'),
  'cross-line escapes fail with an actionable physical-line diagnostic')
assertDeepEqual(snapshot([splitFlags]), splitBefore, 'the continuation PoC fails before replacing or changing the flags file')
assertDeepEqual(parsedArgv(read(splitFlags)), ['--load-extension=/keep,', '/second'],
  'the continuation PoC never promotes /second into the extension list')

const invalidFlags = [
  '--load-extension="/unclosed',
  '--load-extension=/trailing-escape\\',
  '--load-extension=/keep\0 --user-data-dir=/profile',
  Buffer.from([0xff, 0xfe]),
  '--load-extension=/keep\\\n# embedded comment\n,/second',
  '--load-extension="/literal\nnewline"',
  '--label="two\r\nlines"\n--load-extension=/keep',
  '--user-data-dir=/pro\\\nfile\n--load-extension=/keep',
  '--keep=one \\\n--load-extension=/keep',
  '--keep="quoted\\\ncontinuation"\n--load-extension=/keep',
  '--load-exten\\\nsion=/keep',
  '--load-extension=/keep\n--load-extension="/unclosed'
]
for (const [i, source] of invalidFlags.entries()) {
  const env = scenario(`invalid-flags-${i}`)
  const flags = path.join(env.XDG_CONFIG_HOME, 'chromium-flags.conf')
  write(flags, source, 0o640)
  const before = snapshot([flags])
  run(env, helper, [], false)
  run(env, '/bin/bash', ['-euo', 'pipefail', migration], false)
  assertDeepEqual(snapshot([flags]), before, `invalid or unsupported flags ${i}: helper and migration fail without rewriting the file`)
  assert(fs.readFileSync(flags).equals(Buffer.from(source)), `invalid or unsupported flags ${i}: original bytes remain intact`)
}

const fallback = scenario('unset-xdg')
delete fallback.XDG_CONFIG_HOME
run(fallback)
assert(fs.existsSync(path.join(fallback.HOME, '.config/chromium/NativeMessagingHosts', hostName)),
  'an explicitly unset XDG_CONFIG_HOME falls back to the temporary HOME')

const links = scenario('manifest-links')
const outside = path.join(scratch, 'outside-manifest')
write(outside, 'do not overwrite\n')
fs.mkdirSync(path.dirname(native(links)), { recursive: true })
fs.symlinkSync(outside, native(links))
fs.symlinkSync(outside, path.join(path.dirname(native(links)), 'other.json'))
run(links)
assert(!fs.lstatSync(native(links)).isSymbolicLink() && read(outside) === 'do not overwrite\n' &&
  fs.lstatSync(path.join(path.dirname(native(links)), 'other.json')).isSymbolicLink(),
  'registration atomically replaces only its own manifest symlink without following it')

const broken = scenario('failed-registration')
const brokenFlags = path.join(broken.XDG_CONFIG_HOME, 'chromium-flags.conf')
write(brokenFlags, '--custom=keep\n--load-extension=/keep\n')
fs.mkdirSync(native(broken), { recursive: true })
write(path.join(native(broken), 'keep'), 'do not delete\n')
const brokenSnapshot = snapshot([brokenFlags, path.join(native(broken), 'keep')])
run(broken, helper, [], false)
run(broken, '/bin/bash', ['-euo', 'pipefail', migration], false)
assertDeepEqual(snapshot([brokenFlags, path.join(native(broken), 'keep')]), brokenSnapshot,
  'failed native registration propagates through the helper and migration without truncating existing data')
assertDeepEqual(fs.readdirSync(path.dirname(native(broken))), [hostName], 'failed registration cleans up its atomic temporary file')
fs.unlinkSync(path.join(native(broken), 'keep'))
fs.rmdirSync(native(broken))
run(broken, '/bin/bash', ['-euo', 'pipefail', migration])
assertEqual(read(brokenFlags), `--custom=keep\n--load-extension=/keep,${target}\n`,
  'a failed migration remains safely retryable after the registration problem is fixed')

const invalid = scenario('invalid-template')
const invalidRoot = path.join(scratch, 'invalid-root')
fs.mkdirSync(path.join(invalidRoot, 'default/chromium/extensions'), { recursive: true })
fs.symlinkSync(target, path.join(invalidRoot, 'default/chromium/extensions/theme-sync'))
write(path.join(invalidRoot, 'default/chromium/native-messaging-hosts', hostName), '{malformed')
invalid.OMARCHY_PATH = invalidRoot
run(invalid, helper, [], false)
assertDeepEqual(fs.readdirSync(invalid.XDG_CONFIG_HOME), [], 'JSON generation failures abort before registration or flags writes')
write(path.join(invalidRoot, 'default/chromium/native-messaging-hosts', hostName), '')
run(invalid, helper, [], false)
assertDeepEqual(fs.readdirSync(invalid.XDG_CONFIG_HOME), [], 'empty native templates also fail before changing configuration')
for (const badPath of ['checkout,comma', 'checkout\nnewline']) {
  const invalidPath = path.join(scratch, badPath)
  fs.symlinkSync(root, invalidPath)
  invalid.OMARCHY_PATH = invalidPath
  run(invalid, helper, [], false)
}
assertDeepEqual(fs.readdirSync(invalid.XDG_CONFIG_HOME), [], 'unrepresentable comma and newline extension paths fail without changing configuration')

for (const [selection, browser, flags] of [
  ['chromium', 'chromium', 'chromium'], ['chrome', 'google-chrome', 'chrome'],
  ['edge', 'microsoft-edge', 'microsoft-edge-stable'], ['brave', 'BraveSoftware/Brave-Browser', 'brave'],
  ['brave-origin', 'BraveSoftware/Brave-Origin', 'brave-origin']
]) {
  const install = scenario(`install-${selection}`, 'xdg config')
  const flagsFile = path.join(install.XDG_CONFIG_HOME, `${flags}-flags.conf`)
  run(install, path.join(root, 'bin/omarchy-install-browser'), [selection])
  assert(read(flagsFile) === seeded && fs.existsSync(native(install, browser)),
    `${selection} installer seeds bundled extension flags and registers the selected browser before first launch`)
  assertDeepEqual(calls(install).filter(call => call.startsWith('omarchy-install-chromium-')),
    ['omarchy-install-chromium-copy-url:', 'omarchy-install-chromium-ytdlp:', `omarchy-install-chromium-theme-sync:${flagsFile}`],
    `${selection} installer passes its XDG destination to Theme Sync after the other native helpers`)
  const customFlags = path.join(install.HOME, 'dotfiles/flags')
  fs.unlinkSync(flagsFile)
  write(customFlags, '# custom\n--custom=keep\n--load-extension=/user-extension', 0o600)
  fs.symlinkSync(customFlags, flagsFile)
  run(install, path.join(root, 'bin/omarchy-install-browser'), [selection])
  assert(fs.lstatSync(flagsFile).isSymbolicLink() && (fs.statSync(customFlags).mode & 0o777) === 0o600 &&
    read(customFlags) === `# custom\n--custom=keep\n--load-extension=/user-extension,${target}`,
    `${selection} reinstall merges without overwriting custom flags, their symlink, permissions or final line`)
}

const refresh = scenario('refresh')
const refreshFlags = path.join(refresh.XDG_CONFIG_HOME, 'chromium-flags.conf')
const oldFlags = '--custom=old\n--oauth2-client-id=test\n--oauth2-client-secret=secret\n'
write(refreshFlags, oldFlags)
run(refresh, path.join(root, 'bin/omarchy-refresh-chromium'))
assertEqual(read(refreshFlags), seeded, 'explicit Chromium refresh includes Theme Sync and the other bundled extensions')
assert(fs.readdirSync(refresh.XDG_CONFIG_HOME).filter(name => name.startsWith('chromium-flags.conf.bak.'))
  .some(name => read(path.join(refresh.XDG_CONFIG_HOME, name)) === oldFlags), 'explicit refresh retains the existing config backup behavior')
assertDeepEqual(calls(refresh), ['omarchy-refresh-config:chromium-flags.conf', 'omarchy-install-chromium-copy-url:',
  'omarchy-install-chromium-ytdlp:', 'omarchy-install-chromium-theme-sync:', 'omarchy-install-chromium-google-account:'],
  'refresh registers Theme Sync after existing native hosts and preserves Google account setup without restarting the browser')
refresh.TEST_FAIL = 'omarchy-install-chromium-theme-sync'
write(refreshFlags, oldFlags)
write(refresh.TEST_LOG, '')
run(refresh, path.join(root, 'bin/omarchy-refresh-chromium'), [], false)
assert(!calls(refresh).includes('omarchy-install-chromium-google-account:'),
  'failed Theme Sync registration also aborts refresh rather than reporting success')
JS
