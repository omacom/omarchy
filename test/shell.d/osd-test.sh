#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const audio = requireFromRoot('shell/plugins/panels/audio/Model.js')
const osd = requireFromRoot('shell/plugins/osd/OsdModel.js')

assertEqual(osd.iconFor('', 0), osd.iconFor('muted', 50), 'osd falls back to muted icon at zero percent')
assertEqual(osd.iconFor('volume-low', 50), '\uf027', 'osd maps volume-low to 1-wave speaker')
assertEqual(osd.iconFor('volume-medium', 50), '\uefcf', 'osd maps volume-medium to 2-wave speaker')
assertEqual(osd.iconFor('volume-high', 50), '\uf028', 'osd maps volume-high to 3-wave speaker')
assertEqual(osd.iconFor('volume-high', 1), osd.iconFor('', 100), 'osd maps high volume aliases')
assertEqual(osd.iconFor('', 1), '\uf027', 'osd uses 1-wave speaker at 1%')
assertEqual(osd.iconFor('', 33), '\uf027', 'osd uses 1-wave speaker at 33%')
assertEqual(osd.iconFor('', 34), '\uefcf', 'osd uses 2-wave speaker at 34%')
assertEqual(osd.iconFor('', 66), '\uefcf', 'osd uses 2-wave speaker at 66%')
assertEqual(osd.iconFor('', 67), '\uf028', 'osd uses 3-wave speaker at 67%')
for (let p = 0; p <= 100; p++)
  assertEqual(osd.iconFor('', p), audio.speakerVolumeGlyph(p / 100), 'osd and audio panel agree at ' + p + '%')
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
