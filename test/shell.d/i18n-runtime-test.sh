#!/bin/bash

# Runtime translation by source string: the registry in
# shell/Commons/I18nModel.js and the system gettext reader in
# shell/Commons/I18nSystem.js, which I18n.qml and the Ui kit build on.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const { execFileSync } = require('child_process')
const fs = require('fs')
const os = require('os')
const M = requireFromRoot('shell/Commons/I18nModel.js')
const S = requireFromRoot('shell/Commons/I18nSystem.js')

const ES_HEADER = { language: 'es', 'plural-forms': 'nplurals=2; plural=(n != 1);' }
const RU_HEADER = { language: 'ru', 'plural-forms': 'nplurals=3; plural=(n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2);' }

// ---- locales

assertEqual(M.normalizeLocale('es_CL.UTF-8'), 'es_CL', 'normalizeLocale drops the encoding')
assertEqual(M.normalizeLocale('pt-br'), 'pt_BR', 'normalizeLocale accepts BCP 47 separators')
assertEqual(M.normalizeLocale('es_419'), 'es_419', 'normalizeLocale keeps a numeric region')
assertEqual(M.normalizeLocale('C'), '', 'normalizeLocale treats C as untranslated')
assertEqual(M.normalizeLocale("es;rm -rf ~"), '', 'normalizeLocale rejects a language that is not an ISO 639 code')
assertDeepEqual(M.localeCandidates({ LANGUAGE: 'es_MX:fr', LANG: 'de_DE.UTF-8' }), ['es_MX', 'es', 'fr'], 'LANGUAGE lists win and each entry falls back to its language')
assertDeepEqual(M.localeCandidates({ LANGUAGE: 'de:en:fr' }), ['de', 'en'], 'candidates stop at English, the source language')
assertDeepEqual(M.languageCandidates('pt-BR', 'pt_BR.UTF-8'), ['pt_BR', 'pt'], 'the picked language maps to its gettext locales')
assertDeepEqual(M.languageCandidates('no', 'nb_NO.UTF-8'), ['nb_NO', 'nb'], 'Norwegian reads the nb catalogs through the registry locale')
assertDeepEqual(M.languageCandidates('es-MX', ''), ['es_MX', 'es'], 'a language without a registry locale falls back to its code')
assertDeepEqual(M.languageCandidates('en', 'en_US.UTF-8'), [], 'English has nothing to translate')

// ---- plural rules and interpolation

const ru = M.parsePluralForms(RU_HEADER['plural-forms'])
assertDeepEqual([1, 2, 5, 11, 21, 22, 25].map(n => ru.plural(n)), [0, 1, 2, 2, 0, 1, 2], 'Russian plural rule picks the CLDR forms')
assertEqual(M.parsePluralForms('nplurals=2; plural=alert(1);'), null, 'a plural rule with code in it is rejected, never evaluated')
assertEqual(M.parsePluralForms('nplurals=2; plural=n >'), null, 'a malformed plural rule is rejected')
assertEqual(M.interpolate('%1 of %2', ['%2', 3]), '%2 of 3', 'interpolation is single pass')
assertEqual(M.interpolate('%1 and %3', ['a']), 'a and %3', 'unknown placeholders stay')

// ---- catalog sanitizing: both plural shapes load

const clean = M.sanitizeCatalog({
  '': ES_HEADER,
  Save: 'Guardar',
  Empty: '',
  '%1 file': ['%1 archivo', '%1 archivos'],
  '%1 city': { msgid_plural: '%1 cities', msgstr: ['%1 ciudad', '%1 ciudades'] },
  Untranslated: { msgid_plural: 'Untranslateds', msgstr: ['', ''] },
  Broken: { msgstr: [1, 2] },
  Number: 7
})
assertDeepEqual(Object.keys(clean).sort(), ['', '%1 city', '%1 file', 'Save'], 'sanitizeCatalog keeps strings and both plural shapes, drops the rest')
assertDeepEqual(clean['%1 city'], { msgstr: ['%1 ciudad', '%1 ciudades'], 'plural-forms': ES_HEADER['plural-forms'] }, 'object plurals keep their forms and the catalog plural rule')
assertDeepEqual(clean['%1 file'].msgstr, ['%1 archivo', '%1 archivos'], 'array plurals load as the object shape')

// ---- registry: lookups

{
  const r = M.createRegistry()
  r.setCatalogs('plugin', { 'dev.foo': {
    '': ES_HEADER,
    Save: 'Guardar',
    '%1 city': { msgid_plural: '%1 cities', msgstr: ['%1 ciudad', '%1 ciudades'] },
    ['verb' + M.CONTEXT_SEPARATOR + 'Open']: 'Abrir'
  } }, { precedence: 100 })
  assertEqual(r.translate('Save'), 'Guardar', 'translate answers from the global merge')
  assertEqual(r.translate('Unknown'), 'Unknown', 'a missing string returns its source')
  assertEqual(r.translate('Open', { context: 'verb' }), 'Abrir', 'context keys translate')
  assertEqual(r.translatePlural(1, '%1 city', '%1 cities', { args: [1] }), '1 ciudad', 'object plurals from i18n.json translate the singular')
  assertEqual(r.translatePlural(4, '%1 city', '%1 cities', { args: [4] }), '4 ciudades', 'object plurals from i18n.json translate the plural')
  assertEqual(r.translatePlural(2, '%1 town', '%1 towns', { args: [2] }), '2 towns', 'a missing plural falls back to English by count')
  assertEqual(r.translate('%1 city'), '%1 ciudad', 'translate of a plural entry gives its first form')
}

// ---- registry: per-string locale fallback

{
  const r = M.createRegistry()
  const byLocale = {
    'es-MX': { '': ES_HEADER, Profiles: 'Perfiles (MX)' },
    es: { '': ES_HEADER, Profiles: 'Perfiles', Clear: 'Limpiar' },
    ru: { '': RU_HEADER, Clear: 'Очистить', '%1 file': { msgstr: ['%1 файл', '%1 файла', '%1 файлов'] } },
    fr: { Clear: 'Effacer' }
  }
  const list = M.selectLocaleCatalogs(byLocale, ['es_MX', 'es', 'ru'])
  assertDeepEqual(list.map(item => item.locale), ['es_MX', 'es', 'ru'], 'every matching locale catalog is selected in preference order')
  assertEqual(r.setLocaleCatalogs('dev.foo:i18n', 'dev.foo', list, { precedence: 100 }), 3, 'setLocaleCatalogs registers one layer per locale')
  assertEqual(r.translate('Profiles'), 'Perfiles (MX)', 'the regional catalog wins where it has the string')
  assertEqual(r.translate('Clear'), 'Limpiar', 'a string missing from the regional catalog falls back to the language')
  assertEqual(r.translatePlural(5, '%1 file', '%1 files', { args: [5] }), '5 файлов', 'a fallback entry picks its form with its own language rule')
  assertEqual(r.translatePlural(3, '%1 file', '%1 files', { args: [3] }), '3 файла', 'a fallback entry uses the few form of its own rule')
  r.setLocaleCatalogs('dev.foo:i18n', 'dev.foo', M.selectLocaleCatalogs(byLocale, ['fr']), { precedence: 100 })
  assertEqual(r.translate('Profiles'), 'Profiles', 'registering again replaces every earlier locale layer')
  assertEqual(r.clearOwner('dev.foo:i18n'), true, 'clearOwner removes the per-locale layers')
  assertEqual(r.translate('Clear'), 'Clear', 'nothing is left after clearing')
  assertDeepEqual(M.selectLocaleCatalogs(byLocale, ['de']), [], 'no catalog applies to an unrelated language')
}

// ---- registry: plugin catalogs beat the system catalog

{
  const r = M.createRegistry()
  r.setLocaleCatalogs('system:gettext', 'omarchy.system', [{ locale: 'es', catalog: { Save: 'Guardar', Test: 'Prueba' } }], { precedence: 200 })
  r.setLocaleCatalogs('dev.foo:i18n', 'dev.foo', [{ locale: 'es', catalog: { Test: 'Probar' } }], { precedence: 100 })
  assertEqual(r.translate('Test'), 'Probar', 'a plugin i18n.json overrides the system catalog')
  assertEqual(r.translate('Save'), 'Guardar', 'the system catalog answers what the plugin does not define')
  assertEqual(r.translate('Test', { domain: 'omarchy.system' }), 'Prueba', 'a bound domain looks up its own catalog first')
}

// ---- startup snapshot: cached domains retire one at a time

{
  const previous = M.createRegistry()
  previous.setLocaleCatalogs('system:gettext', 'omarchy.system', [{ locale: 'es', catalog: { '': ES_HEADER, Save: 'Guardar', '%1 item': ['%1 elemento', '%1 elementos'] } }], { precedence: 200 })
  previous.setLocaleCatalogs('dev.foo:i18n', 'dev.foo', [{ locale: 'es', catalog: { Test: 'Probar' } }], { precedence: 100 })
  previous.setLocaleCatalogs('dev.gone:i18n', 'dev.gone', [{ locale: 'es', catalog: { Gone: 'Ido' } }], { precedence: 100 })
  const snap = JSON.parse(JSON.stringify(previous.snapshot()))

  const r = M.createRegistry()
  assertEqual(r.loadSnapshot(snap), true, 'a snapshot loads as the cache')
  assertEqual(r.translate('Save'), 'Guardar', 'the cache answers before any live source')
  assertEqual(r.translatePlural(3, '%1 item', '%1 items', { args: [3] }), '3 elementos', 'cached plurals keep their rule through JSON')

  r.setLocaleCatalogs('dev.foo:i18n', 'dev.foo', [{ locale: 'es', catalog: { Test: 'Probar de nuevo' } }], { precedence: 100 })
  assertEqual(r.translate('Save'), 'Guardar', 'a plugin registering first keeps the cached system catalog')
  assertEqual(r.translate('Test'), 'Probar de nuevo', 'the live plugin catalog replaces its cached copy')
  assertDeepEqual(r.cachedDomains().sort(), ['dev.gone', 'omarchy.system'], 'only the registered domain left the cache')

  r.setLocaleCatalogs('system:gettext', 'omarchy.system', [{ locale: 'es', catalog: { Save: 'Guardar (live)' } }], { precedence: 200 })
  assertEqual(r.translate('Save'), 'Guardar (live)', 'the live system catalog replaces its cached copy')
  assertEqual(r.translatePlural(3, '%1 item', '%1 items', { args: [3] }), '3 items', 'a string the live catalog dropped no longer comes from the cache')

  r.settleCache(['omarchy.system', 'dev.foo'])
  assertEqual(r.translate('Gone'), 'Gone', 'settling drops a cached domain no live source claims')
  assertDeepEqual(r.cachedDomains(), [], 'the cache is empty once settled')

  r.clearOwner('dev.foo:i18n')
  assertEqual(r.loadSnapshot(snap), false, 'reloading the snapshot after a write cannot resurrect retired domains')
  assertEqual(r.translate('Test'), 'Test', 'a cleared plugin stays cleared')
  assertEqual(r.snapshot().catalogs['dev.foo'], undefined, 'the next snapshot leaves the cleared plugin out')

  const fresh = M.createRegistry()
  fresh.loadSnapshot(snap)
  assertEqual(fresh.retireCached(['omarchy.system']), true, 'a source that found nothing retires its cached domain')
  assertEqual(fresh.translate('Save'), 'Save', 'the retired system cache no longer answers')
  assertEqual(fresh.translate('Gone'), 'Ido', 'other cached domains are untouched')
  assertEqual(fresh.setCatalogs('cache', { x: { a: 'b' } }), 'rejected', 'nothing can register under the cache owner name')
}

// ---- system gettext: PO text through the registry

const po = [
  'msgid ""',
  'msgstr ""',
  '"Language: es\\n"',
  '"Plural-Forms: nplurals=2; plural=(n != 1);\\n"',
  '',
  'msgid "_Save"',
  'msgstr "_Guardar"',
  '',
  '#, fuzzy',
  'msgid "Test"',
  'msgstr "Prueba"',
  '',
  'msgid "Untranslated"',
  'msgstr ""',
  '',
  'msgctxt "menu"',
  'msgid "File"',
  'msgstr "Archivo"',
  '',
  'msgid "%d _file"',
  'msgid_plural "%d _files"',
  'msgstr[0] "%d _archivo"',
  'msgstr[1] "%d _archivos"',
  '',
  'msgid "Long "',
  '"line"',
  'msgstr "Línea "',
  '"larga"',
  ''
].join('\n')

const built = S.buildCatalog([po])
assertEqual(built.Save, 'Guardar', 'mnemonics are stripped from both msgid and msgstr')
assertEqual(built._Save, '_Guardar', 'the mnemonic key keeps its marker')
assertEqual(built.Test, undefined, 'fuzzy entries are skipped')
assertEqual(built.Untranslated, undefined, 'untranslated entries are skipped')
assertEqual(built.File, undefined, 'context entries are not reachable through tr and are skipped')
assertEqual(built['Long line'], 'Línea larga', 'multi-line strings are joined')
assertEqual(built[''].language === undefined && built['']['Plural-Forms'], 'nplurals=2; plural=(n != 1);', 'the PO header keeps the plural rule')

{
  const r = M.createRegistry()
  r.setCatalogs('system', { 'omarchy.system': built }, { precedence: 200 })
  assertEqual(r.translatePlural(1, '%d file', '%d files'), '%d archivo', 'buildCatalog plurals survive setCatalogs (singular)')
  assertEqual(r.translatePlural(7, '%d file', '%d files'), '%d archivos', 'buildCatalog plurals survive setCatalogs (plural)')
  assertEqual(r.translatePlural(7, '%d _file', '%d _files'), '%d _archivos', 'the mnemonic plural key survives too')
}

// ---- system gettext: the msgunfmt command

const command = S.catalogCommand(['es_MX', 'es', 'bad;locale', 'es'], '/nonexistent')
assertDeepEqual(command.slice(0, 2), ['bash', '-c'], 'the system catalog read is one bash')
assertDeepEqual(command.slice(3), ['bash', '/nonexistent', 'es_MX', 'es'], 'locales are passed as arguments, validated and deduplicated')
assert(command[2].indexOf('es_MX') === -1, 'the script never contains a locale')
assertDeepEqual(S.catalogCommand([]), [], 'no candidates, no command')
assertEqual(S.requestKey(['es_MX', 'es']), 'es_MX es', 'the request key names the locales asked for')

const parsed = S.parseCatalogOutput('X-OMARCHY-SYSTEM-REQUEST: es_MX es\nX-OMARCHY-SYSTEM-LOCALE: es_MX\nmsgid "a"\nmsgstr "b"\nX-OMARCHY-SYSTEM-LOCALE: es\nmsgid "c"\nmsgstr "d"\n')
assertEqual(parsed.request, 'es_MX es', 'the reply echoes its request')
assertDeepEqual(parsed.sections.map(s => s.locale), ['es_MX', 'es'], 'the reply has one section per locale, in order')

let haveMsgfmt = true
try { execFileSync('msgfmt', ['--version'], { stdio: 'ignore' }) } catch (e) { haveMsgfmt = false }
if (haveMsgfmt) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'omarchy-i18n-'))
  try {
    const compile = (locale, domain, text) => {
      const target = path.join(dir, locale, 'LC_MESSAGES')
      fs.mkdirSync(target, { recursive: true })
      fs.writeFileSync(path.join(target, domain + '.po'), text)
      execFileSync('msgfmt', ['-o', path.join(target, domain + '.mo'), path.join(target, domain + '.po')])
    }
    const header = 'msgid ""\nmsgstr ""\n"Content-Type: text/plain; charset=UTF-8\\n"\n"Plural-Forms: nplurals=2; plural=(n != 1);\\n"\n\n'
    compile('es_MX', 'gtk30', header + 'msgid "Profiles"\nmsgstr "Perfiles (MX)"\n')
    compile('es', 'gtk30', header + 'msgid "Profiles"\nmsgstr "Perfiles"\n\nmsgid "_Save"\nmsgstr "_Guardar"\n')
    compile('es', 'glib20', header + 'msgid "%d item"\nmsgid_plural "%d items"\nmsgstr[0] "%d elemento"\nmsgstr[1] "%d elementos"\n')

    const run = S.catalogCommand(['es_MX', 'es'], dir)
    const output = execFileSync(run[0], run.slice(1), { encoding: 'utf8' })
    const result = S.buildLocaleCatalogs(output)
    assertEqual(result.request, S.requestKey(['es_MX', 'es']), 'the real run echoes its request key')
    assertDeepEqual(result.catalogs.map(c => c.locale), ['es_MX', 'es'], 'every locale with catalogs is read, not just the first')

    const r = M.createRegistry()
    r.setLocaleCatalogs('system:gettext', 'omarchy.system', result.catalogs, { precedence: 200 })
    assertEqual(r.translate('Profiles'), 'Perfiles (MX)', 'compiled regional catalog wins')
    assertEqual(r.translate('Save'), 'Guardar', 'a string only the language catalog has still translates')
    assertEqual(r.translatePlural(3, '%d item', '%d items'), '%d elementos', 'compiled plurals translate through the registry')

    const none = S.catalogCommand(['fr'], dir)
    let status = 0
    let noneOutput = ''
    try { noneOutput = execFileSync(none[0], none.slice(1), { encoding: 'utf8' }) } catch (e) { status = e.status; noneOutput = e.stdout }
    assertEqual(status, 1, 'the run exits 1 when no locale has a catalog')
    assertDeepEqual(S.buildLocaleCatalogs(noneOutput), { request: 'fr', catalogs: [] }, 'an empty reply still names its request')
  } finally {
    fs.rmSync(dir, { recursive: true, force: true })
  }
} else {
  pass('msgfmt not installed; skipping the compiled catalog round trip')
}
JS
