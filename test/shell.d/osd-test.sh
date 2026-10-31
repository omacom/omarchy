#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const osd = requireFromRoot('shell/plugins/osd/OsdModel.js')

const locales = {
  eng: {name: 'en_US', nativeLanguageName: 'American English'},
  en_001: {name: 'en_001', nativeLanguageName: 'English'},
  ara: {name: 'ar_EG', nativeLanguageName: 'العربية'},
  ja: {name: 'ja_JP', nativeLanguageName: '日本語'}
}
const localeFor = code => locales[code] || {name: 'C', nativeLanguageName: ''}
assertEqual(osd.inputLanguage({language: 'eng', name: 'English (US)'}, localeFor), 'English', 'generic English uses the standard language name')
assertEqual(osd.inputLanguage({language: 'ara', name: 'Arabic'}, localeFor), 'العربية', 'XKB ISO 639 codes use native names')
assertEqual(osd.inputLanguage({language: 'ja', name: 'Mozc'}, localeFor), '日本語', 'engine names do not replace language names')
assertEqual(osd.inputLanguage({language: 'unknown', name: 'Custom input'}, localeFor), 'Custom input', 'unknown language codes retain the provided name')
assertEqual(osd.inputLanguage(null, localeFor), '', 'missing language metadata stays empty')

assertEqual(osd.iconFor('', 0), osd.iconFor('muted', 50), 'osd falls back to muted icon at zero percent')
assertEqual(osd.iconFor('volume-high', 1), osd.iconFor('', 100), 'osd maps high volume aliases')
assertEqual(osd.iconFor('logout', 50), '󰍃', 'osd maps logout icon')
assertEqual(osd.iconFor('custom-symbol', 50), 'custom-symbol', 'osd preserves unknown explicit icons')
assertEqual(osd.widestIcon, osd.iconFor('volume-high', 100), 'osd sizes the icon column to a glyph it can show')

assertDeepEqual(
  osd.stateForShow('volume', '', '75', '100', '', '800'),
  {
    iconKey: 'volume',
    maxValue: 100,
    hasProgress: true,
    value: 75,
    message: '75%',
    icon: osd.iconFor('volume', 75),
    duration: 800
  },
  'osd builds progress state'
)

assertDeepEqual(
  osd.stateForShow('media-pause', 'Paused', '', '100', '', 'nope'),
  {
    iconKey: 'media-pause',
    maxValue: 100,
    hasProgress: false,
    value: 0,
    message: 'Paused',
    icon: osd.iconFor('media-pause', -1),
    duration: 1200
  },
  'osd builds message state'
)
JS
