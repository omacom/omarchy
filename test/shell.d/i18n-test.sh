#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# --- Catalog completeness, placeholder parity, and menu translation logic ---

run_node_test <<'JS'
const fs = require('fs')
const MenuModel = requireFromRoot('shell/plugins/menu/MenuModel.js')

const i18nDir = path.join(root, 'default/i18n')
const readJson = (rel) => JSON.parse(fs.readFileSync(path.join(i18nDir, rel), 'utf8'))

const registry = readJson('locales.json')
const codes = Object.keys(registry)
assert(codes[0] === 'en', 'i18n registry lists English first (the default)')
const badRegistry = codes.filter((code) => !/^[a-z]{2,3}(-[A-Za-z]{2})?$/.test(code)
  || ['name', 'englishName', 'formatLocale', 'locale'].some((f) => typeof registry[code][f] !== 'string' || registry[code][f].length === 0)
  || !/\.UTF-8$/.test(registry[code].locale))
assert(badRegistry.length === 0, 'every registry entry is complete with a UTF-8 locale', JSON.stringify(badRegistry))

// The English menu catalog must mirror the shipped menu definition, so a
// relabeled row cannot leave translations pointing at stale English.
const enMenu = readJson('en/menu.json')
const menuItems = MenuModel.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))
assertEqual(enMenu.root.label, 'Go', 'English menu catalog carries the injected root label')
assert(menuItems.some((item) => item.id === 'setup.language' && item.provider === 'languages'), 'Setup > Language row uses the languages provider')
const staleMenu = menuItems.filter((item) => !enMenu[item.id] || enMenu[item.id].label !== item.label || (item.title && enMenu[item.id].title !== item.title) || (item.description && enMenu[item.id].description !== item.description))
assert(staleMenu.length === 0, 'English menu catalog mirrors the menu definition', JSON.stringify(staleMenu.map((i) => i.id)))
const orphanMenu = Object.keys(enMenu).filter((id) => id !== 'root' && !menuItems.some((item) => item.id === id))
assert(orphanMenu.length === 0, 'English menu catalog has no orphan ids', JSON.stringify(orphanMenu))

// Structural by default, as every gate runs it: individual PRs only add the
// English side, so missing translations are pending work for the sync
// workflow rather than failures. So are translations the manifest marks
// stale (their English changed since) and orphans awaiting pruning —
// an English-only edit must never wedge on 49 other languages. Structure
// of what IS current must still hold either way. I18N_STRICT=1 also wants
// every catalog complete, as it is right after a sync.
const structural = process.env.I18N_STRICT !== '1'
const crypto = require('crypto')
const manifest = readJson('translation-manifest.json')
// A plural entry hashes as Python's json.dumps(sort_keys=True) writes it.
const canonical = (value) => typeof value === 'string' ? value
  : '{' + Object.keys(value).sort().map((k) => `${JSON.stringify(k)}: ${JSON.stringify(value[k])}`).join(', ') + '}'
const sourceHash = (value) => crypto.createHash('sha256').update(canonical(value), 'utf8').digest('hex').slice(0, 12)
const Plural = requireFromRoot('shell/Commons/Plural.js')
const isStale = (code, unit, englishValue) => !manifest[code] || manifest[code][unit] !== sourceHash(englishValue)
// Only %1-style tokens count, as in scripts/i18n-sync.py: nothing escapes a
// percent sign, and Turkish writes it before the number ("%%2" shows "%80").
const placeholders = (value) => (String(value).match(/%\d/g) || []).sort().join(' ')
function assertCatalogMirrors(kind, english, catalog, code) {
  const problems = []
  const enKeys = Object.keys(english).sort()
  if (!structural && JSON.stringify(Object.keys(catalog).sort()) !== JSON.stringify(enKeys)) problems.push('key set differs')
  if (!structural)
    for (const key of Object.keys(catalog))
      if (!Object.hasOwn(english, key)) problems.push(`${key}: not in the English catalog`)
  for (const key of enKeys) {
    if (!Object.hasOwn(catalog, key)) continue
    if (kind === 'menu') {
      const staleField = (f) => structural && Object.hasOwn(english[key], f) && isStale(code, `menu:${key}.${f}`, english[key][f])
      if (!structural && JSON.stringify(Object.keys(catalog[key]).sort()) !== JSON.stringify(Object.keys(english[key]).sort())) problems.push(`${key}: fields differ`)
      else if (Object.keys(catalog[key]).some((f) => (Object.hasOwn(english[key], f) || !structural) && (typeof catalog[key][f] !== 'string' || catalog[key][f].length === 0))) problems.push(`${key}: invalid field`)
      else if (Object.keys(catalog[key]).some((f) => Object.hasOwn(english[key], f) && placeholders(catalog[key][f]) !== placeholders(english[key][f]) && !staleField(f))) problems.push(`${key}: placeholders differ`)
      else if (!structural && Object.keys(english[key]).some((f) => typeof catalog[key][f] !== 'string' || catalog[key][f].length === 0)) problems.push(`${key}: untranslated field`)
    } else if (english[key] && typeof english[key] === 'object') {
      // A plural entry: the language's categories, "other" with every
      // placeholder, and no form inventing one.
      const stale = structural && isStale(code, `${kind}:${key}`, english[key])
      const forms = catalog[key]
      const expected = placeholders(english[key].other)
      if (!forms || typeof forms !== 'object') { if (!stale) problems.push(`${key}: not plural forms`) }
      else if (!structural && JSON.stringify(Object.keys(forms).sort()) !== JSON.stringify(Plural.categories(code).slice().sort())) problems.push(`${key}: plural categories differ`)
      else if (Object.values(forms).some((form) => typeof form !== 'string' || form.length === 0)) problems.push(`${key}: empty plural form`)
      else if (!stale && (placeholders(forms.other || '') !== expected || Object.values(forms).some((form) => placeholders(form).split(' ').some((p) => p && !expected.split(' ').includes(p))))) problems.push(`${key}: placeholders differ`)
    } else if (typeof catalog[key] !== 'string' || catalog[key].length === 0) problems.push(`${key}: untranslated`)
    else if (placeholders(catalog[key]) !== placeholders(english[key]) && !(structural && isStale(code, `${kind}:${key}`, english[key]))) problems.push(`${key}: placeholders differ`)
    if (problems.length > 5) break
  }
  assert(problems.length === 0, `${code}/${kind}.json ${structural ? 'is structurally sound' : 'mirrors the English catalog'}`, JSON.stringify(problems))
}

const enShell = readJson('en/shell.json')
const enCli = readJson('en/cli.json')
const enKeybindings = readJson('en/keybindings.json')
const readOptional = (rel) => fs.existsSync(path.join(i18nDir, rel)) ? readJson(rel) : {}
for (const code of codes) {
  if (code === 'en') continue
  assertCatalogMirrors('menu', enMenu, readJson(`${code}/menu.json`), code)
  assertCatalogMirrors('shell', enShell, readJson(`${code}/shell.json`), code)
  assertCatalogMirrors('cli', enCli, readJson(`${code}/cli.json`), code)
  assertCatalogMirrors('keybindings', enKeybindings, readOptional(`${code}/keybindings.json`), code)
}

// Every catalog key must be referenced by the code that displays it, and
// every referenced key must exist in the English catalog.
function collectKeys(dir, extensions, pattern) {
  const found = new Set()
  const walk = (current) => {
    for (const entry of fs.readdirSync(current, { withFileTypes: true })) {
      const full = path.join(current, entry.name)
      if (entry.isDirectory()) { if (entry.name !== '__pycache__') walk(full) }
      else if (extensions.some((ext) => entry.name.endsWith(ext))) {
        for (const match of fs.readFileSync(full, 'utf8').matchAll(pattern)) found.add(match[1])
      }
    }
  }
  walk(dir)
  return found
}
const shellKeys = collectKeys(path.join(root, 'shell'), ['.qml', '.js'], /(?:I18n\.tn?|[^a-zA-Z_.]tn?|translator\(tr\))\("([a-z][a-zA-Z0-9]*(?:\.[a-zA-Z0-9]+)+)"/g)
const unreferencedShell = Object.keys(enShell).filter((key) => !shellKeys.has(key))
assert(unreferencedShell.length === 0, 'every shell catalog key is referenced', JSON.stringify(unreferencedShell))
const unknownShell = [...shellKeys].filter((key) => !Object.hasOwn(enShell, key))
assert(unknownShell.length === 0, 'every referenced shell key exists in the English catalog', JSON.stringify(unknownShell))

const cliKeyPattern = /omarchy-i18n (?:--count \S+ )?([a-z][a-zA-Z0-9]*(?:\.[a-zA-Z0-9]+)+)/g
const cliKeys = collectKeys(path.join(root, 'bin'), [''], cliKeyPattern)
for (const key of collectKeys(path.join(root, 'install'), ['.sh', '.hook'], cliKeyPattern)) cliKeys.add(key)
for (const key of collectKeys(path.join(root, 'default'), ['.py'], cliKeyPattern)) cliKeys.add(key)
for (const key of collectKeys(path.join(root, 'etc'), ['.jsonc'], cliKeyPattern)) cliKeys.add(key)
for (const key of collectKeys(path.join(root, 'install/provisioning'), ['setup-form.sh'], /omarchy_form_text ([a-z][a-zA-Z0-9]*(?:\.[a-zA-Z0-9]+)+)/g)) cliKeys.add(key)
const unreferencedCli = Object.keys(enCli).filter((key) => !cliKeys.has(key))
assert(unreferencedCli.length === 0, 'every cli catalog key is referenced', JSON.stringify(unreferencedCli))
const unknownCli = [...cliKeys].filter((key) => !Object.hasOwn(enCli, key))
assert(unknownCli.length === 0, 'every referenced cli key exists in the English catalog', JSON.stringify(unknownCli))

// applyTranslations: translated labels win, English stays searchable,
// untranslated rows pass through, and nothing mutates the source items.
const defaults = MenuModel.parseMenuJsonc(JSON.stringify({
  setup: { label: 'Setup', aliases: ['settings'] },
  'setup.language': { label: 'Language', provider: 'languages' }
}))
const translated = MenuModel.applyTranslations(defaults, { setup: { label: 'Opsætning' } })
assertEqual(translated[0].label, 'Opsætning', 'applyTranslations replaces the label')
assert(translated[0].searchTerms.includes('Setup') && translated[0].aliases.includes('settings') && !translated[0].aliases.includes('Setup'), 'applyTranslations keeps English searchable but not routable')
assertEqual(translated[1].label, 'Language', 'applyTranslations leaves untranslated rows in English')
assertEqual(defaults[0].label, 'Setup', 'applyTranslations does not mutate its input')
const merged = MenuModel.mergeMenuSources(translated, MenuModel.parseMenuJsonc(JSON.stringify({ setup: { label: 'My Setup' } })))
assertEqual(merged.items.setup.label, 'My Setup', 'a user retitle wins over the translation')
const customRoot = MenuModel.mergeMenuSources(translated, MenuModel.parseMenuJsonc(JSON.stringify({ root: { label: 'My Menu' } })), 'Gå')
assertEqual(customRoot.items.root.label, 'My Menu', 'a user-supplied root heading wins over the catalog label')
const injectedRoot = MenuModel.mergeMenuSources(translated, [], 'Gå')
assertEqual(injectedRoot.items.root.label, 'Gå', 'the injected root heading uses the catalog label')
assertEqual(MenuModel.mergeMenuSources(translated, []).items.root.label, 'Go', 'the injected root heading defaults to Go without a catalog')
assertDeepEqual(MenuModel.applyTranslations(defaults, null), defaults, 'a missing catalog degrades to English')

// Routing must not depend on the display language: English labels live in
// searchTerms, which resolveRoute never reads, so a word that is inert in
// English cannot become a command in another language.
const daMenu = readJson('da/menu.json')
const enMerged = MenuModel.mergeMenuSources(menuItems, [])
const daMerged = MenuModel.mergeMenuSources(MenuModel.applyTranslations(menuItems, daMenu), [])
for (const route of ['reboot', 'shutdown', 'logout', 'hibernate', 'lock', 'clock', 'danish', 'setup', 'settings', 'power-menu', 'language'])
  assertEqual(MenuModel.resolveRoute(daMerged.items, daMerged.itemOrder, route), MenuModel.resolveRoute(enMerged.items, enMerged.itemOrder, route), `route "${route}" resolves the same in Danish as in English`)
assert(MenuModel.nameSearchText(daMerged.items.setup).includes('setup'), 'English labels remain searchable in Danish')

// JS models translate through the optional tr argument and stay English
// without one (the audio/monitor/clipboard tests assert the same English).
const daShell = readJson('da/shell.json')
const tr = (key, english) => daShell[key] || english
const audio = requireFromRoot('shell/plugins/panels/audio/Model.js')
assertEqual(audio.outputVolumeName(0.5, true, tr), daShell['audio.level.muted'], 'audio levels translate through tr')
const clipboard = requireFromRoot('shell/plugins/clipboard/ClipboardHistory.js')
const daRow = clipboard.displayRows([{ type: 'image', path: '/tmp/a.png', mime: 'image/png', capturedAt: 'Friday 14:42' }], '', 50, tr)[0]
assertEqual(daRow.previewText, daShell['clipboard.screenshotFrom'].replace('%1', 'Friday 14:42'), 'clipboard previews translate through tr')

// The manual ships whole per language: same files as English, none empty,
// and the machine-significant parts of every chapter preserved — code block
// contents, URLs, relative link destinations, and commands or paths in
// inline code. Prose, link text, and synopsis placeholders in <...> or
// [...] may be localized. In structural mode, chapters the manifest marks
// stale are exempt: their repair is pending sync work, not corruption.
const manualDir = path.join(root, 'manual')
const englishManual = fs.readdirSync(manualDir).filter((name) => name.endsWith('.md')).sort()
assert(englishManual.length > 0, 'English manual exists')
const englishTexts = {}
for (const file of englishManual) englishTexts[file] = fs.readFileSync(path.join(manualDir, file), 'utf8')
const bagOf = (items) => JSON.stringify([...items].sort())
const fencesOf = (text) => [...text.matchAll(/```[^\n]*\n([\s\S]*?)```/g)].map((m) => m[1])
// The published manual's autolinks leave trailing ASCII punctuation out of a
// bare URL but keep 。 or । in it, and a (destination) keeps it all.
const urlsOf = (text) => [...text.matchAll(/https?:\/\/[^\s)`]+/g)].map((m) => text[m.index - 1] === '(' ? m[0] : m[0].replace(/[.,;:!?]+$/, ''))
const relDestsOf = (text) => [...text.matchAll(/\]\((?!<?https?:\/\/)([^)\s]+)/g)].map((m) => m[1])
const protectedInlineOf = (text) => [...text.matchAll(/`([^`\n]+)`/g)].map((m) => m[1])
  .filter((span) => /[/~$]/.test(span) || span.startsWith('omarchy ') || span.startsWith('omarchy-'))
  .map((span) => span.replace(/<[^>]+>/g, '<>').replace(/\[[^\]]+\]/g, '[]'))
function manualProblems(english, translatedText) {
  const problems = []
  if ((english.match(/^#{1,6} /gm) || []).length !== (translatedText.match(/^#{1,6} /gm) || []).length) problems.push('heading count changed')
  if (bagOf(urlsOf(english)) !== bagOf(urlsOf(translatedText))) problems.push('URLs changed')
  if (bagOf(fencesOf(english)) !== bagOf(fencesOf(translatedText))) problems.push('code block contents changed')
  if (bagOf(relDestsOf(english)) !== bagOf(relDestsOf(translatedText))) problems.push('relative link destinations changed')
  if (bagOf(protectedInlineOf(english)) !== bagOf(protectedInlineOf(translatedText))) problems.push('commands or paths in inline code changed')
  return problems
}
const fencedChapter = englishManual.find((file) => englishTexts[file].includes('```'))
assert(manualProblems(englishTexts[fencedChapter], englishTexts[fencedChapter].replace(/```[^\n]*\n/, '$&echo tampered\n')).length > 0, 'the manual integrity check catches a changed code block')
const linkedChapter = englishManual.find((file) => /\]\(\d\d-[a-z0-9-]+\.md\)/.test(englishTexts[file]))
assert(manualProblems(englishTexts[linkedChapter], englishTexts[linkedChapter].replace(/\]\(\d\d-[a-z0-9-]+\.md\)/, '](99-missing.md)')).length > 0, 'the manual integrity check catches a broken chapter link')
assert(['https://example.org/walls を参照してください。', 'ดูที่ https://example.org/walls', 'https://example.org/walls. पर देखें']
  .every((translated) => manualProblems('See https://example.org/walls.', translated).length === 0) &&
  ['参照: https://example.org/walls。', 'देखें https://example.org/walls।', 'دیکھیں https://example.org/walls۔', 'See https://example.org/other.']
    .every((translated) => manualProblems('See https://example.org/walls.', translated).length > 0) &&
  manualProblems('[LocalSend](https://localsend.org/)', '[LocalSend](https://localsend.org/ダウンロード)').length > 0 &&
  manualProblems('[dharmx/walls](https://github.com/dharmx/walls).', '[dharmx/walls](https://github.com/dharmx/walls.)。').length > 0, 'the manual integrity check ignores the full stop the published link drops, not one it keeps')
for (const code of codes) {
  if (code === 'en') continue
  const dir = path.join(manualDir, code)
  if (!fs.existsSync(dir)) {
    assert(structural, `manual/${code} exists`)
    continue
  }
  const chapters = fs.readdirSync(dir).filter((name) => name.endsWith('.md')).sort()
  const texts = {}
  for (const file of chapters) texts[file] = fs.readFileSync(path.join(dir, file), 'utf8')
  const extra = chapters.filter((file) => !englishManual.includes(file))
  const empty = chapters.filter((file) => texts[file].trim().length === 0)
  const broken = []
  for (const file of chapters) {
    if (!Object.hasOwn(englishTexts, file)) continue
    if (structural && isStale(code, `manual:${file}`, englishTexts[file])) continue
    for (const problem of manualProblems(englishTexts[file], texts[file])) broken.push(`${file}: ${problem}`)
    if (broken.length > 5) break
  }
  assert(broken.length === 0, `manual/${code} preserves commands, links, and code blocks`, JSON.stringify(broken.slice(0, 5)))
  if (structural) {
    // Extra chapters are prune-pending (their English was deleted or renamed).
    assert(empty.length === 0, `manual/${code} chapters present are translated`, JSON.stringify(empty))
  } else {
    const missing = englishManual.filter((file) => !chapters.includes(file))
    assert(JSON.stringify(chapters) === JSON.stringify(englishManual) && empty.length === 0, `manual/${code} has every English chapter translated`, JSON.stringify([...missing, ...empty]))
  }
}
JS

# --- Plural rules and number formatting agree between shell and CLI ---

# Plural.js (shell) and plural.jq (omarchy-i18n) hold the same CLDR rules;
# compare every language over every count a UI is likely to show, and the
# number formatting the two sides share.
require_command jq
counts='[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,19,20,21,22,25,100,101,102,103,111,112,121,1000,1001,1000000,2000000]'
codes_json=$(jq -c 'keys' "$ROOT/default/i18n/locales.json")
jq_categories=$(jq -c -n -L "$ROOT/default/i18n" --argjson codes "$codes_json" --argjson counts "$counts" \
  'include "plural"; [$codes[] as $c | $counts[] as $n | plural_category($c; $n)]')
jq_numbers=$(jq -c -n -L "$ROOT/default/i18n" --slurpfile registry "$ROOT/default/i18n/locales.json" \
  'include "plural"; [$registry[0] | to_entries[] | .value as $r | ("13.1", "2026", "-0.5") | localize_number($r.decimal; $r.zeroDigit)]')
JQ_CATEGORIES=$jq_categories JQ_NUMBERS=$jq_numbers CODES=$codes_json COUNTS=$counts run_node_test <<'JS'
const fs = require('fs')
const Plural = requireFromRoot('shell/Commons/Plural.js')
const Numbers = requireFromRoot('shell/Commons/Numbers.js')
const codes = JSON.parse(process.env.CODES)
const counts = JSON.parse(process.env.COUNTS)
const shell = codes.flatMap((code) => counts.map((n) => Plural.category(code, n)))
const cli = JSON.parse(process.env.JQ_CATEGORIES)
const disagree = shell.map((c, i) => c === cli[i] ? null : `${codes[Math.floor(i / counts.length)]}:${counts[i % counts.length]} ${c}/${cli[i]}`).filter(Boolean)
assert(disagree.length === 0, 'shell and CLI plural rules agree for every language', JSON.stringify(disagree.slice(0, 5)))

assertEqual(['one', 'few', 'many'].map((_, i) => Plural.category('ru', [21, 22, 25][i])).join(), 'one,few,many', 'Russian counts take one, few, and many')
assertEqual([0, 1, 2, 3, 11, 100].map((n) => Plural.category('ar', n)).join(), 'zero,one,two,few,many,other', 'Arabic counts take all six forms')
assertEqual(Plural.category('fr', 1000000), 'many', 'French millions take their own form')
assertEqual(Plural.categories('ja').join(), 'other', 'Japanese has one form')
assertEqual(Plural.categories('pl').join(), 'one,few,many,other', 'Polish needs one, few, many, and other')
assertEqual(Plural.pick({ one: '%1 file', other: '%1 files' }, 'en', 1), '%1 file', 'pick chooses the form for the count')
assertEqual(Plural.pick({ other: '%1 files' }, 'ru', 2), '%1 files', 'a missing form falls back to other')
assertEqual(Plural.pick('plain', 'ru', 2), 'plain', 'a plain string ignores the count')

const registry = JSON.parse(fs.readFileSync(path.join(root, 'default/i18n/locales.json'), 'utf8'))
const shellNumbers = Object.values(registry).flatMap((r) => ['13.1', '2026', '-0.5'].map((v) => Numbers.format(v, undefined, r.decimal, r.zeroDigit)))
assertDeepEqual(shellNumbers, JSON.parse(process.env.JQ_NUMBERS), 'shell and CLI write numbers the same way in every language')
assertEqual(Numbers.format(13.14, 1, ',', '0'), '13,1', 'formatNumber rounds and uses the decimal separator')
assertEqual(Numbers.format(13.5, 1, '٫', '۰'), '۱۳٫۵', 'formatNumber writes native digits')
assertEqual(Object.values(registry).filter((r) => typeof r.decimal !== 'string' || typeof r.zeroDigit !== 'string').length, 0, 'every registry entry says how it writes numbers')
JS

# --- omarchy-language and omarchy-i18n behavior ---

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
export OMARCHY_PATH=$ROOT
export PATH="$ROOT/bin:$PATH"
export OMARCHY_LANGUAGE_FILE=$work/language
export OMARCHY_LOCALE_GEN=$work/locale.gen
export OMARCHY_LOCALE_REGISTRY=$ROOT/default/i18n/locales.json
export XDG_CONFIG_HOME=$work/config
session_env=$XDG_CONFIG_HOME/uwsm/env.d/50-omarchy-language
printf '#da_DK.UTF-8 UTF-8\n' >"$OMARCHY_LOCALE_GEN"

# Stub the outside world: locale-gen records its argument, notifications
# record their text, and omarchy-language itself is the real one via PATH.
mkdir -p "$work/stubs"
cat >"$work/stubs/locale-gen" <<'STUB'
#!/bin/bash
echo "$@" >>"$LOCALE_GEN_LOG"
STUB
cat >"$work/stubs/omarchy-notification-send" <<'STUB'
#!/bin/bash
echo "$@" >>"$NOTIFY_LOG"
STUB
cat >"$work/stubs/locale" <<'STUB'
#!/bin/bash
if [[ $1 == "-a" ]]; then echo "en_US.utf8"; else echo "LANG=en_US.UTF-8"; fi
STUB
# A fake Hyprland session: the compositor and the shell restart record what
# they were asked, so the test never touches a desktop it runs inside.
cat >"$work/stubs/hyprctl" <<'STUB'
#!/bin/bash
echo "$@" >>"$SESSION_ENV_LOG"
STUB
cat >"$work/stubs/omarchy-restart-shell" <<'STUB'
#!/bin/bash
echo "restart" >>"$SESSION_ENV_LOG"
STUB
# sudo and pkexec record which one elevated and what it ran, then run it
# as-is. sudo answers the long listing (`sudo -n -l -l`) with the
# passwordless grant only when TEST_SUDO_GRANT is set, the way a machine with
# etc/sudoers.d/omarchy-locale-generate installed does.
cat >"$work/stubs/sudo" <<'STUB'
#!/bin/bash
if [[ $1 == "-n" && $2 == "-l" ]]; then
  [[ -n ${TEST_SUDO_GRANT:-} ]] && echo "    Options: !authenticate"
  exit 0
fi
flag=""
if [[ $1 == "-n" ]]; then flag=" -n"; shift; fi
echo "sudo$flag $(basename "$1") $2" >>"$ELEVATE_LOG"
exec "$@"
STUB
cat >"$work/stubs/pkexec" <<'STUB'
#!/bin/bash
echo "pkexec $(basename "$1") $2" >>"$ELEVATE_LOG"
exec "$@"
STUB
chmod +x "$work/stubs/"*
export PATH="$work/stubs:$PATH"
export LOCALE_GEN_LOG=$work/locale-gen.log NOTIFY_LOG=$work/notify.log ELEVATE_LOG=$work/elevate.log SESSION_ENV_LOG=$work/session-env.log
export HYPRLAND_INSTANCE_SIGNATURE=test
: >"$LOCALE_GEN_LOG"; : >"$NOTIFY_LOG"; : >"$ELEVATE_LOG"; : >"$SESSION_ENV_LOG"

assert_bash_equal() {
  if [[ $1 != "$2" ]]; then
    fail "$3" "expected [$2], got [$1]"
  fi
  pass "$3"
}

assert_bash_equal "$(omarchy-language)" "en" "omarchy-language defaults to English with no language file"
echo "bogus" >"$OMARCHY_LANGUAGE_FILE"
assert_bash_equal "$(omarchy-language)" "en" "omarchy-language falls back to English for an unknown code"
rm -f "$OMARCHY_LANGUAGE_FILE"

list=$(omarchy-language list)
assert_bash_equal "$(printf '%s\n' "$list" | wc -l)" "$(jq length "$ROOT/default/i18n/locales.json")" "omarchy-language list prints a row for every registered language"
assert_bash_equal "$(printf '%s\n' "$list" | head -n 1 | cut -f2)" "en" "omarchy-language list puts English first"
assert_bash_equal "$(omarchy-language locale da)" "da_DK.UTF-8" "omarchy-language locale maps da to its glibc locale"

# stdin is not a tty here, as when picked from the menu, and this machine has
# no passwordless grant, so generating the locale asks through polkit.
omarchy-language da </dev/null
assert_bash_equal "$(cat "$ELEVATE_LOG")" "pkexec omarchy-locale-generate da" "without the grant, the menu generates the locale through pkexec"
assert_bash_equal "$(cat "$OMARCHY_LANGUAGE_FILE")" "da" "omarchy-language persists the choice"
assert_bash_equal "$(omarchy-language)" "da" "omarchy-language reads the persisted choice"
assert_bash_equal "$(grep '^export LANG=' "$session_env")" "export LANG=da_DK.UTF-8" "omarchy-language sets the session LANG through uwsm for the next login"
assert_bash_equal "$(cat "$SESSION_ENV_LOG")" $'eval hl.env("LANG", "da_DK.UTF-8", true)\nrestart' "omarchy-language hands the new LANG to Hyprland and services, then respawns the shell from it"
assert_bash_equal "$(grep '^da_DK.UTF-8' "$OMARCHY_LOCALE_GEN")" "da_DK.UTF-8 UTF-8" "omarchy-language enables the locale in locale.gen"
assert_bash_equal "$(cat "$LOCALE_GEN_LOG")" "da_DK.UTF-8" "omarchy-language generates the locale"

if omarchy-language xx </dev/null 2>/dev/null; then
  fail "omarchy-language rejects unknown codes"
else
  pass "omarchy-language rejects unknown codes"
fi

da_changed=$(jq -r '."language.changed"' "$ROOT/default/i18n/da/cli.json" | sed 's/%1/Dansk/')
assert_bash_equal "$(omarchy-i18n language.changed Dansk)" "$da_changed" "omarchy-i18n prints the current language with substitution"
assert_bash_equal "$(omarchy-i18n missing.key)" "missing.key" "omarchy-i18n passes unknown keys through"

grep -q "$da_changed" "$NOTIFY_LOG" && pass "the language-change notification arrives in the new language" || fail "the language-change notification arrives in the new language" "notify log: $(cat "$NOTIFY_LOG")"

da_battery=$(jq -r '."battery.lowBody"' "$ROOT/default/i18n/da/cli.json" | sed 's/%1/12/')
assert_bash_equal "$(omarchy-i18n battery.lowBody 12)" "$da_battery" "omarchy-i18n substitutes %1 and keeps a literal percent sign"

# Plural entries pick their form by count, and plain-number arguments take
# the language's decimal separator and digits.
plural_root=$work/plural-root
mkdir -p "$plural_root/default/i18n/en" "$plural_root/default/i18n/ru" "$plural_root/default/i18n/fa"
cp "$ROOT/default/i18n/plural.jq" "$ROOT/default/i18n/locales.json" "$plural_root/default/i18n/"
printf '{"files.count": {"one": "%%1 file", "other": "%%1 files"}, "power.rate": "%%1 W"}\n' >"$plural_root/default/i18n/en/cli.json"
printf '{"files.count": {"one": "%%1 файл", "few": "%%1 файла", "many": "%%1 файлов", "other": "%%1 файла"}, "power.rate": "%%1 Вт"}\n' >"$plural_root/default/i18n/ru/cli.json"
printf '{}\n' >"$plural_root/default/i18n/fa/cli.json"
plural() { echo "$1" >"$work/plural-language"; OMARCHY_PATH=$plural_root OMARCHY_LANGUAGE_FILE=$work/plural-language omarchy-i18n "${@:2}"; }
assert_bash_equal "$(plural en --count 1 files.count 1)" "1 file" "omarchy-i18n --count picks the English singular"
assert_bash_equal "$(plural en --count 3 files.count 3)" "3 files" "omarchy-i18n --count picks the English plural"
assert_bash_equal "$(plural ru --count 21 files.count 21) / $(plural ru --count 22 files.count 22) / $(plural ru --count 25 files.count 25)" "21 файл / 22 файла / 25 файлов" "omarchy-i18n --count follows Russian plural rules"
assert_bash_equal "$(plural ru files.count 5)" "5 файла" "a plural entry without --count reads its other form"
assert_bash_equal "$(plural ru power.rate 13.1)" "13,1 Вт" "a number argument takes the language's decimal separator"
assert_bash_equal "$(plural fa --count 2 files.count 13.5)" "۱۳٫۵ files" "a number argument takes the language's digits, with the English entry as fallback"
assert_bash_equal "$(plural ru power.rate 10.0.0.1)" "10.0.0.1 Вт" "an argument that is not a plain number passes through"
assert_bash_equal "$(plural ru --number 13.1) $(plural fa --number 13.5)" "13,1 ۱۳٫۵" "omarchy-i18n --number writes one number in the language"
assert_bash_equal "$(plural en power.rate --foo) | $(plural en power.rate -n)" "--foo W | -n W" "an argument that starts with a dash is text, not a jq option"
if plural en --count many files.count 2>/dev/null; then
  fail "omarchy-i18n rejects a non-numeric count"
else
  pass "omarchy-i18n rejects a non-numeric count"
fi

da_changed_raw=$(jq -r '."language.changed"' "$ROOT/default/i18n/da/cli.json")
assert_bash_equal "$(omarchy-i18n language.changed 'Research & Development')" "${da_changed_raw//%1/"Research & Development"}" "omarchy-i18n keeps ampersands in arguments literal"

# With the locale already generated, picking the language needs no
# privilege at all: no password prompt, no locale-gen.
cat >"$work/stubs/locale" <<'STUB'
#!/bin/bash
if [[ $1 == "-a" ]]; then printf 'en_US.utf8\nda_DK.utf8\n'; else echo "LANG=da_DK.UTF-8"; fi
STUB
chmod +x "$work/stubs/locale"
: >"$LOCALE_GEN_LOG"; : >"$ELEVATE_LOG"; : >"$SESSION_ENV_LOG"
rm -f "$OMARCHY_LANGUAGE_FILE"
omarchy-language da </dev/null
assert_bash_equal "$(cat "$OMARCHY_LANGUAGE_FILE")" "da" "already-applied locale switches without elevating"
assert_bash_equal "$(cat "$LOCALE_GEN_LOG")" "" "already-generated locale is not regenerated"
assert_bash_equal "$(cat "$ELEVATE_LOG")" "" "no password prompt when nothing privileged is needed"
assert_bash_equal "$(head -n 1 "$SESSION_ENV_LOG")" 'eval hl.env("LANG", "da_DK.UTF-8", true)' "an already-generated locale still reaches the session"

# Switching back writes the new LANG over the old one rather than adding to it.
omarchy-language en </dev/null
assert_bash_equal "$(grep -c '^export LANG=' "$session_env") $(grep '^export LANG=' "$session_env")" "1 export LANG=en_US.UTF-8" "switching language replaces the session LANG"

# With etc/sudoers.d/omarchy-locale-generate installed, a language whose locale
# isn't generated yet still switches from the menu without any password
# prompt: the helper runs through sudo -n, never polkit.
cat >"$work/stubs/locale" <<'STUB'
#!/bin/bash
if [[ $1 == "-a" ]]; then echo "en_US.utf8"; else echo "LANG=en_US.UTF-8"; fi
STUB
: >"$LOCALE_GEN_LOG"; : >"$ELEVATE_LOG"
TEST_SUDO_GRANT=1 omarchy-language sv </dev/null
assert_bash_equal "$(cat "$ELEVATE_LOG")" "sudo -n omarchy-locale-generate sv" "with the grant, a new language generates its locale without a password prompt"
assert_bash_equal "$(cat "$LOCALE_GEN_LOG")" "sv_SE.UTF-8" "the passwordless helper generates the language's locale"
assert_bash_equal "$(cat "$OMARCHY_LANGUAGE_FILE")" "sv" "the passwordless switch persists the choice"

# A CJK language brings its glyph forms, and its input method where Fcitx
# answers; without a session bus the switch still succeeds and says how.
cjk_font=$XDG_CONFIG_HOME/fontconfig/conf.d/50-omarchy-input-method.conf
[[ ! -e $cjk_font ]] && pass "a non-CJK language leaves the CJK glyph forms alone" || fail "a non-CJK language leaves the CJK glyph forms alone"
cat >"$work/stubs/busctl" <<'STUB'
#!/bin/bash
echo "no session bus" >&2
exit 1
STUB
cp "$work/stubs/busctl" "$work/stubs/fcitx5-remote"
chmod +x "$work/stubs/busctl" "$work/stubs/fcitx5-remote"
cjk_output=$(TEST_SUDO_GRANT=1 omarchy-language ja </dev/null 2>&1) || fail "a CJK language switches without a reachable Fcitx" "$cjk_output"
assert_bash_equal "$(cat "$OMARCHY_LANGUAGE_FILE")" "ja" "a CJK language switches without a reachable Fcitx"
[[ $cjk_output == *"Setup > Typing > Input Methods"* ]] && pass "an input method that could not be added is named with where to add it" || fail "an input method that could not be added is named with where to add it" "$cjk_output"
grep -q 'Noto Sans CJK JP' "$cjk_font" && pass "Japanese seeds Japanese glyph forms" || fail "Japanese seeds Japanese glyph forms"
TEST_SUDO_GRANT=1 omarchy-language ko </dev/null 2>/dev/null
grep -q 'Noto Sans CJK JP' "$cjk_font" && pass "a second CJK language keeps the glyph forms already chosen" || fail "a second CJK language keeps the glyph forms already chosen"
rm -f "$work/stubs/busctl" "$work/stubs/fcitx5-remote" "$cjk_font"

# A cancelled polkit prompt must not persist the choice, or the interface
# would switch with LANG left behind.
cat >"$work/stubs/pkexec" <<'STUB'
#!/bin/bash
exit 126
STUB
cat >"$work/stubs/locale" <<'STUB'
#!/bin/bash
if [[ $1 == "-a" ]]; then echo "en_US.utf8"; else echo "LANG=en_US.UTF-8"; fi
STUB
rm -f "$OMARCHY_LANGUAGE_FILE" "$session_env"
if omarchy-language da </dev/null 2>/dev/null; then
  fail "a cancelled password prompt fails the switch"
else
  pass "a cancelled password prompt fails the switch"
fi
[[ ! -f $OMARCHY_LANGUAGE_FILE && ! -f $session_env ]] && pass "the choice is not persisted before the locale exists" || fail "the choice is not persisted before the locale exists"

# --- Translation sync tooling (scripts/i18n-sync.py) ---

require_command python3

if [[ ${I18N_STRICT:-} == "1" ]]; then
  pending_locales=$(python3 "$ROOT/scripts/i18n-sync.py" pending | jq -c '.locales')
  assert_bash_equal "$pending_locales" "[]" "no translations are pending"
else
  skip "no translations are pending (structural mode)"
fi

extract_candidates=$(python3 "$ROOT/scripts/i18n-sync.py" extract-scan | jq -c '.candidates | length')
keybindings_stale=$(python3 "$ROOT/scripts/i18n-sync.py" extract-scan | jq -c '.keybindingsCatalogStale')
assert_bash_equal "$keybindings_stale" "false" "the English keybindings catalog matches the Hyprland bindings"
assert_bash_equal "$extract_candidates" "0" "no embedded English literals await extraction"

# A miniature tree exercises staleness: one key changed in English, one
# deleted from the translation, one manual chapter missing.
fix=$work/fixture
mkdir -p "$fix/default/i18n/en" "$fix/default/i18n/da" "$fix/default/omarchy" "$fix/manual" "$fix/shell" "$fix/bin"
cat >"$fix/default/i18n/locales.json" <<'FIXJSON'
{
  "en": {"name": "English", "englishName": "English", "formatLocale": "en-US", "locale": "en_US.UTF-8"},
  "da": {"name": "Dansk", "englishName": "Danish", "formatLocale": "da-DK", "locale": "da_DK.UTF-8"}
}
FIXJSON
printf '{\n  "a.one": "One",\n  "a.two": "Two"\n}\n' >"$fix/default/i18n/en/shell.json"
printf '{}\n' >"$fix/default/i18n/en/cli.json"
printf '{\n  "root": {\n    "label": "Go"\n  }\n}\n' >"$fix/default/i18n/en/menu.json"
printf '{}\n' >"$fix/default/omarchy/omarchy-menu.jsonc"
printf '{\n  "strings": [],\n  "files": []\n}\n' >"$fix/default/i18n/extract-allowlist.json"
printf '{\n  "a.one": "En",\n  "a.two": "To"\n}\n' >"$fix/default/i18n/da/shell.json"
printf '{}\n' >"$fix/default/i18n/da/cli.json"
printf '{\n  "root": {\n    "label": "Gaa"\n  }\n}\n' >"$fix/default/i18n/da/menu.json"
printf '# Hello\n\nWorld.\n' >"$fix/manual/01-hello.md"
mkdir -p "$fix/manual/da"
printf '# Hej\n\nVerden.\n' >"$fix/manual/da/01-hello.md"
python3 "$ROOT/scripts/i18n-sync.py" --root "$fix" manifest >/dev/null
assert_bash_equal "$(python3 "$ROOT/scripts/i18n-sync.py" --root "$fix" pending | jq -c '.locales')" "[]" "sync fixture starts with nothing pending"

printf '{\n  "a.one": "One changed",\n  "a.two": "Two"\n}\n' >"$fix/default/i18n/en/shell.json"
printf '{\n  "a.two": "To"\n}\n' >"$fix/default/i18n/da/shell.json"
printf '# New\n' >"$fix/manual/02-new.md"
pending_units=$(python3 "$ROOT/scripts/i18n-sync.py" --root "$fix" pending | jq -c '.jobs.da.pending | sort')
assert_bash_equal "$pending_units" '["manual:02-new.md","shell:a.one"]' "sync detects changed English and missing chapters"

printf 'Text {\n  text: "Brand new string"\n}\n' >"$fix/shell/Panel.qml"
scan_strings=$(python3 "$ROOT/scripts/i18n-sync.py" --root "$fix" extract-scan | jq -c '[.candidates[].string]')
assert_bash_equal "$scan_strings" '["Brand new string"]' "extract-scan finds embedded English literals"

# Keybinding descriptions come from the bind calls: plain strings, a
# concatenation becomes a %1 pattern, bind_hold describes press and release,
# and a nil description or a commented-out bind adds nothing.
mkdir -p "$fix/default/hypr/bindings"
cat >"$fix/default/hypr/bindings/test.lua" <<'LUA'
o.bind("SUPER + K", "Keybindings", "omarchy-menu-keybindings")
for workspace = 1, 9 do
  o.bind("SUPER + " .. tostring(workspace), "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
end
o.bind_hold("F9", "Start dictation", "omarchy-dictation start", "Stop dictation", "omarchy-dictation stop")
o.bind_toggle("SUPER + CTRL + N", "Toggle nightlight", "nightlight")
o.bind(
  "SUPER + CTRL + code:10",
  "Bar panel " .. panel,
  "omarchy-shell -q shell togglePanelAt right " .. panel
)
o.bind("switch:on:Lid Switch", nil, "omarchy-system-lid-close", { locked = true })
-- o.bind("SUPER + X", "Commented out", "true")
LUA
keybinding_texts=$(cd "$fix" && python3 -c 'import importlib.util,json,sys; from pathlib import Path; spec=importlib.util.spec_from_file_location("s", sys.argv[1]); m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m); print(json.dumps(sorted(m.keybinding_descriptions(Path(".")))))' "$ROOT/scripts/i18n-sync.py")
assert_bash_equal "$keybinding_texts" '["Bar panel %1", "Keybindings", "Start dictation", "Stop dictation", "Switch to workspace %1", "Toggle nightlight"]' "keybinding descriptions are extracted from the bind calls"

# Any display-text property name counts, both arms of a ternary count, and a
# bare list item counts; identifiers and lines marked "i18n: ignore" do not.
cat >"$fix/shell/Panel.qml" <<'QML'
Item {
  activeTooltipText: "Allow notifications"
  leftLabel: busy ? "Working" : "Ready now"
  readonly property var phrases: [
    "Hoarding joules",
    "Braiding packets"
  ]
  colorRole: "bar.text"
  property string statusText: "Checking…"  // i18n: ignore
}
QML
scan_strings=$(python3 "$ROOT/scripts/i18n-sync.py" --root "$fix" extract-scan | jq -c '[.candidates[].string]')
assert_bash_equal "$scan_strings" '["Allow notifications","Working","Ready now","Hoarding joules","Braiding packets"]' "extract-scan catches any display property, ternaries, and phrase lists"

# Collect trusts nothing from a runner: a sidecar naming another locale is
# rejected, while an empty patch with a truthful sidecar still advances
# the manifest (an English edit may need no change in a language).
git -C "$fix" init -q
git -C "$fix" config user.email test@example.com
git -C "$fix" config user.name Test
git -C "$fix" add -A && git -C "$fix" commit -qm fixture
mkdir -p "$work/artifacts"
: >"$work/artifacts/da.patch"
printf '{"fr": ["shell:a.two"]}\n' >"$work/artifacts/da.done.json"
if python3 "$ROOT/scripts/i18n-sync.py" --root "$fix" collect "$work/artifacts" --expected da >/dev/null 2>&1; then
  fail "collect rejects a sidecar naming another locale"
else
  pass "collect rejects a sidecar naming another locale"
fi
printf '{"da": ["shell:a.two"]}\n' >"$work/artifacts/da.done.json"
if python3 "$ROOT/scripts/i18n-sync.py" --root "$fix" collect "$work/artifacts" --expected da >/dev/null 2>&1; then
  pass "collect accepts an empty patch with a truthful sidecar"
else
  fail "collect accepts an empty patch with a truthful sidecar"
fi
# a.one is English, but the Danish translation was deleted above.
printf '{"da": ["shell:a.one"]}\n' >"$work/artifacts/da.done.json"
if python3 "$ROOT/scripts/i18n-sync.py" --root "$fix" collect "$work/artifacts" --expected da >/dev/null 2>&1; then
  fail "collect rejects completion for units not in the tree"
else
  pass "collect rejects completion for units not in the tree"
fi

# Deleting an English unit prunes its translations; the prune's completion
# record must collect, and drop the unit from the manifest, rather than
# block every language's results, even for a translation the manifest
# never recorded.
python3 - "$fix" <<'PY'
import json, sys
from pathlib import Path
root = Path(sys.argv[1])
for code in ("en", "da"):
    path = root / "default/i18n" / code / "shell.json"
    data = json.loads(path.read_text()); data.pop("a.two", None); path.write_text(json.dumps(data))
# As if the Danish translation had been contributed by hand: never recorded.
manifest = root / "default/i18n/translation-manifest.json"
data = json.loads(manifest.read_text()); data.get("da", {}).pop("shell:a.two", None); manifest.write_text(json.dumps(data))
PY
git -C "$fix" add -A && git -C "$fix" commit -qm 'drop a.two'
printf '{"da": ["shell:a.two"]}\n' >"$work/artifacts/da.done.json"
if python3 "$ROOT/scripts/i18n-sync.py" --root "$fix" collect "$work/artifacts" --expected da >/dev/null 2>&1; then
  pass "collect accepts the completion record of a pruned unit"
else
  fail "collect accepts the completion record of a pruned unit"
fi
assert_bash_equal "$(jq -r '.da | has("shell:a.two")' "$fix/default/i18n/translation-manifest.json")" "false" "a pruned unit leaves the manifest"

# Every registry locale must be one glibc can actually generate.
if [[ -f /usr/share/i18n/SUPPORTED ]]; then
  unsupported=""
  while read -r loc; do
    grep -qE "^${loc%.UTF-8}(\.UTF-8)? UTF-8" /usr/share/i18n/SUPPORTED || unsupported="$unsupported $loc"
  done < <(jq -r '.[].locale' "$ROOT/default/i18n/locales.json")
  assert_bash_equal "$unsupported" "" "every registry locale exists in glibc SUPPORTED"
else
  skip "every registry locale exists in glibc SUPPORTED"
fi
