#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const model = requireFromRoot('shell/Commons/I18nModel.js')
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const catalogRaw = fs.readFileSync(path.join(root, 'shell/translations/zh_TW.json'), 'utf8')
const catalog = model.parseCatalog(catalogRaw)

assertEqual(model.normalizeLocale('zh-TW.UTF-8@variant'), 'zh_TW', 'locale normalization strips codeset and modifier')
assertEqual(model.catalogLocale({LANG: 'zh_TW.UTF-8'}), 'zh_TW', 'Taiwan locale selects Traditional Chinese')
assertEqual(model.catalogLocale({LANG: 'zh-Hant-TW'}), 'zh_TW', 'Traditional Chinese script locale selects the catalog')
assertEqual(model.catalogLocale({LANG: 'en_US.UTF-8', LC_MESSAGES: 'zh_TW.UTF-8'}), 'zh_TW', 'message locale takes precedence over LANG')
assertEqual(model.catalogLocale({LANG: 'zh_TW.UTF-8', LC_ALL: 'en_US.UTF-8'}), '', 'LC_ALL takes precedence over LANG')
assertEqual(model.catalogLocale({LANG: 'C.UTF-8', LANGUAGE: 'zh_TW'}), '', 'C message locale remains English even with LANGUAGE')
assertEqual(model.catalogLocale({LANG: 'en_US.UTF-8', LANGUAGE: 'fr:zh_TW:en'}), 'zh_TW', 'LANGUAGE walks supported translation preferences')
assertEqual(model.catalogLocale({LANG: 'zh_TW.UTF-8', LANGUAGE: 'en:zh_TW'}), '', 'explicit English preference stops fallback')
assertEqual(model.catalogLocale({LANG: 'zh_CN.UTF-8'}), '', 'Simplified Chinese locale does not silently switch to Traditional Chinese')
assertEqual(model.catalogLocale({LANG: '../../zh_TW'}), '', 'invalid locale cannot become a catalog path')
assertEqual(model.catalogLocale({}), '', 'missing environment falls back to English')
assertEqual(model.translate(catalog, 'Network'), '網路', 'catalog translates a visible label')
assertEqual(model.translate(catalog, 'Uncatalogued message'), 'Uncatalogued message', 'missing key keeps its source text')
assertEqual(model.translate(catalog, 'toString'), 'toString', 'inherited object properties are not translations')
assertDeepEqual(model.parseCatalog('not json'), {}, 'malformed catalog falls back safely')
assertDeepEqual(model.parseCatalog('[]'), {}, 'array is not a catalog')
assertDeepEqual(model.parseCatalog('{"Network":null,"Browser":42,"File":""}'), {}, 'non-string and empty values do not erase source text')
assertEqual(model.translate(model.parseCatalog('{"__proto__":"literal"}'), '__proto__'), 'literal', 'special keys remain data without prototype mutation')

assertEqual(model.translate(catalog, 'Do you want to uninstall %1?', ['<user-name>']), '確定要解除安裝 <user-name> 嗎？', 'confirmation inserts user labels literally')
assertEqual(model.translate({}, 'Authentication failed (%1)', [2]), 'Authentication failed (2)', 'English fallback formats message arguments')
assertEqual(model.format('%1 / %2', ['%2', '$&']), '%2 / $&', 'argument contents are not reinterpreted as placeholders')
assertEqual(model.format('%1 %10', ['one']), 'one %10', 'missing arguments remain visible instead of corrupting adjacent placeholders')
for (const [source, translated] of Object.entries(catalog)) {
  assertDeepEqual((source.match(/%[1-9][0-9]*/g) || []).sort(), (translated.match(/%[1-9][0-9]*/g) || []).sort(), 'translation preserves placeholders: '+source)
}

const originals = menu.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))
const before = JSON.stringify(originals)
const localized = model.localizeMenu(originals, catalog)
assertEqual(JSON.stringify(originals), before, 'localizing menu does not mutate its default source')
for (let i = 0; i < originals.length; i++) {
  const a = {...originals[i]}, b = {...localized[i]}
  for (const field of ['label', 'title', 'description']) { delete a[field]; delete b[field] }
  if (JSON.stringify(a) !== JSON.stringify(b)) fail('menu behavior survives localization', originals[i].id)
}
pass('all menu actions, routes, providers, guards, aliases and disabled conditions are identical')
const override = menu.normalizeItem('system', {label: 'My System', action: 'printf user-command'})
const merged = menu.mergeMenuSources(localized, [override])
assertEqual(merged.items.system.label, 'My System', 'user menu override wins over translated default label')
assertEqual(merged.items.system.action, 'printf user-command', 'user menu action is preserved')
const mergedDefaults = menu.mergeMenuSources(localized, [])
assertEqual(mergedDefaults.items['install.development.go'].label, 'Go', 'programming language names remain unchanged')
assertEqual(menu.resolveRoute(mergedDefaults.items, mergedDefaults.itemOrder, 'system'), 'system', 'English routes still resolve in Chinese menu')
assertDeepEqual(model.localizeMenu(originals, {}), originals, 'English fallback preserves entire menu data')

function filesUnder(dir) {
  return fs.readdirSync(dir, {withFileTypes:true}).flatMap(e => e.isDirectory() ? filesUnder(path.join(dir,e.name)) : [path.join(dir,e.name)])
}
let calls = 0
for (const file of filesUnder(path.join(root, 'shell')).filter(p => p.endsWith('.qml'))) {
  const source = fs.readFileSync(file, 'utf8')
  for (const match of source.matchAll(/I18n\.tr\(("(?:\\.|[^"\\])*")/g)) {
    const key = JSON.parse(match[1])
    assert(Object.hasOwn(catalog,key), 'catalog contains '+path.relative(root,file)+' source '+key)
    calls++
  }
}
assert(calls > 100, 'catalog covers the initial shared controls and built-in panels')
JS
