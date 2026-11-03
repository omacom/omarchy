#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const effects = requireFromRoot('shell/plugins/background/EffectsModel.js')

assertEqual(effects.sidecarPath('/t/backgrounds/1-totoro.webp'), '/t/backgrounds/effects/1-totoro.json', 'a still finds its sidecar in effects/')
assertEqual(effects.sidecarPath('/t/backgrounds/my.photo.JPG'), '/t/backgrounds/effects/my.photo.json', 'only the last extension is dropped')
assertEqual(effects.sidecarPath('/t/backgrounds/clip.mp4'), '', 'a video has no sidecar; OWE draws it')
assertEqual(effects.sidecarPath(''), '', 'no background has no sidecar')

const eye = (overrides) => Object.assign({
  center: [100, 50], radius: [40, 36], color: '#cba4f5',
  pupil: { radius: [16, 15], color: '#171723', rest: [6, -2] }
}, overrides)

const parsed = effects.parse(JSON.stringify({ eyes: [
  eye(),
  eye({ color: 'purple' }),
  eye({ pupil: { radius: 40, color: '#000000' } }),
  eye({ radius: [40, -1] }),
  eye({ pupil: { radius: 10, color: '#000000', highlight: { radius: 3 } } })
] }))
assertEqual(parsed.effects.eyes.length, 1, 'eyes with a bad color, an oversized pupil, a bad radius or an incomplete highlight are dropped one by one')
assertDeepEqual(parsed.warnings.map((w) => w.split(':')[0]), ['eyes[1] skipped', 'eyes[2] skipped', 'eyes[3] skipped', 'eyes[4] skipped'], 'each dropped eye is named, so an author can find the typo')
assertDeepEqual(parsed.effects.eyes[0].pupil.travel, { x: 40 - 16 * 1.1, y: 36 - 15 * 1.1 }, 'a pupil rolls to a tenth of its size from the rim by default')
const malformed = effects.parse('{ not json')
assert(malformed.effects.eyes.length === 0 && malformed.warnings.length === 1, 'malformed JSON gives no effects and says why', JSON.stringify(malformed))
assertEqual(effects.parse(JSON.stringify({ eyes: Array(100).fill(eye()) })).effects.eyes.length, effects.maxEntries, 'a sidecar cannot ask for unbounded eyes')
const newer = effects.parse(JSON.stringify({ sparkles: [{}], eyes: [eye()] }))
assert(newer.effects.eyes.length === 1 && newer.warnings[0].includes('sparkles'), 'an effect this version does not know is skipped without losing the ones it does', JSON.stringify(newer))
const inherited = effects.parse('{"toString": [1], "constructor": [1], "__proto__": [1], "eyes": [' + JSON.stringify(eye()) + ']}')
assert(inherited.effects.eyes.length === 1 && inherited.warnings.length === 3, 'names every object inherits are unknown effects, not parsers', JSON.stringify(inherited))

// 3840x2160 on a 16:10 screen is cropped at the sides.
const crop = effects.cropTransform(3840, 2160, 1920, 1200)
assertEqual(crop.scale, 1200 / 2160, 'a wider image scales to the screen height')
assertEqual(Math.round(crop.x), Math.round((1920 - 3840 * 1200 / 2160) / 2), 'the overflow is cropped evenly from both sides')
assertEqual(crop.y, 0, 'nothing is cropped vertically')
assertEqual(effects.cropTransform(0, 0, 1920, 1200), null, 'an unknown image size draws no eyes')

const totoro = parsed.effects.eyes[0]
assertDeepEqual(effects.pupilOffset(totoro, null, null, 100), { x: 6, y: -2 }, 'without a pointer the pupil keeps the pose the image paints')
assertDeepEqual(effects.pupilOffset(totoro, 0, 0, 100), { x: 0, y: 0 }, 'a pointer on the eye centers the pupil')
const far = effects.pupilOffset(totoro, 100000, 0, 100)
assert(far.x > totoro.pupil.travel.x * 0.99 && far.x <= totoro.pupil.travel.x, 'a far pointer rolls the pupil to its rim and no further', JSON.stringify(far))
const near = effects.pupilOffset(totoro, 0, -100, 100)
assert(Math.abs(near.y + totoro.pupil.travel.y / 2) < 1e-9 && near.x === 0, 'a pointer at the reach distance rolls the pupil halfway', JSON.stringify(near))

// Every sidecar a theme ships must name a background it has and parse
// without warnings; a dropped entry means a typo in the file.
const themes = path.join(root, 'themes')
for (const theme of fs.readdirSync(themes)) {
  const dir = path.join(themes, theme, 'backgrounds', 'effects')
  if (!fs.existsSync(dir)) continue
  for (const file of fs.readdirSync(dir)) {
    const stem = file.replace(/\.json$/, '')
    const images = fs.readdirSync(path.join(themes, theme, 'backgrounds')).filter((name) => name.replace(/\.[^.]+$/, '') === stem)
    assert(file.endsWith('.json') && images.length === 1, `${theme}/backgrounds/effects/${file} belongs to one background`)
    const image = path.join(themes, theme, 'backgrounds', images[0])
    assertEqual(effects.sidecarPath(image), path.join(dir, file), `${theme}/${images[0]} resolves to its sidecar`)
    const text = fs.readFileSync(path.join(dir, file), 'utf8')
    assertDeepEqual(effects.parse(text).warnings, [], `${theme}/backgrounds/effects/${file} parses cleanly`)
  }
}
JS

pass "background effects resolve sidecars, explain what they skip and follow the pointer within the eye"
