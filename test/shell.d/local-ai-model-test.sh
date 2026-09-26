#!/bin/bash

source "$(dirname "$0")/base-test.sh"

run_node_test <<'JS'
const model = requireFromRoot('shell/plugins/panels/local-ai/Model.js')
const hex = h => ({ r: parseInt(h.slice(1, 3), 16) / 255, g: parseInt(h.slice(3, 5), 16) / 255, b: parseInt(h.slice(5, 7), 16) / 255, a: 1 })
const lc = (text, bg) => Math.abs(model.apca(text, bg))

// APCA-W3 reference pairs
assert(Math.abs(model.apca(hex('#000000'), hex('#ffffff')) - 106.04) < 0.1, 'local-ai apca matches black on white')
assert(Math.abs(model.apca(hex('#ffffff'), hex('#000000')) + 107.88) < 0.1, 'local-ai apca matches white on black')
assert(Math.abs(model.apca(hex('#888888'), hex('#ffffff')) - 63.06) < 0.1, 'local-ai apca matches mid gray on white')

// Every theme keeps three readable tiers of text and visible lines, on both of the panel's backgrounds
const themes = { dark: ['#ffffff', '#161616', '#a55555'], omarchy: ['#cacccc', '#101315', '#a55555'], light: ['#1a1a1a', '#f4f1ea', '#c0392b'], dim: ['#8a8a8a', '#202020', '#aa4444'] }
Object.entries(themes).forEach(([name, [ink, bg, urgent]]) => {
  const surface = Object.assign(hex(ink), { a: 0.06 })
  const t = model.tones(hex(ink), hex(bg), surface, hex(urgent))
  ;[hex(bg), model.over(surface, hex(bg))].forEach((ground, i) => {
    const on = i ? 'card' : 'panel'
    assert(lc(t.ink, ground) >= model.LC.ink - 0.5, `local-ai ${name} ink reaches Lc ${model.LC.ink} on the ${on}`)
    assert(lc(t.value, ground) >= model.LC.value - 0.5, `local-ai ${name} values reach Lc ${model.LC.value} on the ${on}`)
    assert(lc(t.label, ground) >= model.LC.label - 0.5, `local-ai ${name} labels reach Lc ${model.LC.label} on the ${on}`)
    assert(lc(t.rule, ground) >= model.LC.rule - 0.5, `local-ai ${name} rules reach Lc ${model.LC.rule} on the ${on}`)
    assert(lc(t.alert, ground) >= model.LC.alert - 0.5, `local-ai ${name} alerts reach Lc ${model.LC.alert} on the ${on}`)
  })
  assert(lc(t.ink, hex(bg)) > lc(t.value, hex(bg)) && lc(t.value, hex(bg)) > lc(t.label, hex(bg)), `local-ai ${name} tiers stay in order`)
  assert(lc(hex(bg), t.ink) >= model.LC.value, `local-ai ${name} primary button text is readable on ink`)
})

// Home: running models as cards, then the available GPUs as rows; the rest is one "all GPUs" away
const recipe = { id: 'q', name: 'Qwen3.8-27B', family: 'qwen', caps: {}, weights: [] }
const snap = {
  version: '1.0.0', week: 925200, total: 4210000,
  gpus: [{ key: 'a0', name: 'Arc Pro B70', hw: 'arc', vramGb: 32 }, { key: 'a1', name: 'Arc Pro B70', hw: 'arc', vramGb: 32 },
    { key: 'a2', name: 'Arc Pro B70', hw: 'arc', vramGb: 32 }, { key: 'n0', name: 'RTX 3090', hw: '3090', vramGb: 24 },
    { key: 'r0', name: 'Radeon RX 6600', hw: '', vramGb: 8 }],
  kinds: [{ hw: 'arc', name: 'Arc Pro B70', keys: ['a0', 'a1', 'a2'], free: ['a1', 'a2'], taken: [], models: [recipe], groups: [{ id: 'q2', name: 'Qwen3.8-27B', cards: 2 }] },
    { hw: '3090', name: 'RTX 3090', keys: ['n0'], free: [], taken: ['n0'], models: [recipe] }],
  deployments: [{ id: 'd', name: 'Qwen3.8-27B', keys: ['a0'], state: 'ready', agent: 'pi', session: { all: { tokens: 10 } } }],
}
const home = model.build(snap, { view: 'home' })
assertDeepEqual(home.rows.map(r => r.type), ['run', 'sec', 'slot', 'slot', 'slot', 'field'], 'local-ai home: running cards, then available GPUs and groups, then all GPUs')
assertDeepEqual(home.rows.slice(2, 4).map(r => [r.label, r.run.action]), [['Arc Pro B70', 'run|q|a1'], ['Arc Pro B70', 'run|q|a2']], 'local-ai only free GPUs are listed, each running its model in one click')
assertDeepEqual([home.rows[4].label, home.rows[4].run.action], ['2 × Arc Pro B70', 'run|q2|a1,a2'], 'local-ai two free cards of a kind are also offered as a group, its own row')
assertDeepEqual([home.rows[5].label, home.rows[5].value, home.rows[5].action], ['all GPUs', '5', 'gpus'], 'local-ai the rest of the GPUs are one link away')
const may4 = new Date(2026, 4, 4).getTime() / 1000, days = Array(140).fill(0); days[3] = 50; days[10] = 200
const lived = model.build(Object.assign({}, snap, { life: { requests: 1204, since: 'May 7', start: may4, today: 12, days } }), { view: 'home' }).rows
assertDeepEqual([lived[0].type, lived[0].tokens, lived[0].requests, lived[0].since, lived[1].type], ['life', '4.2M tokens', '1.2K requests', 'since May 7', 'run'], 'local-ai home leads with your lifetime, tokens and requests, above the running models')
assertDeepEqual([lived[0].cells.length, lived[0].cells[3], lived[0].cells[10], lived[0].cells[11], lived[0].cells[13]], [140, 1, 4, 0, -1], 'local-ai each day is shaded against your busiest, and days to come are blank')
assertDeepEqual([lived[0].labels[3], lived[0].labels[11]], ['Thu May 7  50 tokens', 'Fri May 15  no tokens'], 'local-ai a hovered day says its date and tokens')
assertDeepEqual(lived[0].months.map(m => m.label + '@' + m.col), ['May@0', 'Jun@4', 'Jul@9', 'Aug@13', 'Sep@18'], 'local-ai the months sit under their first week')
assertDeepEqual(home.rows[0].type, 'run', 'local-ai a first run, with no answers yet, has no lifetime line')

// Opening a free GPU: run it, or its Config; groups are their own rows, whose Config is the group's page
const opened = model.build(snap, { view: 'home', open: 'gpu:a1' }).rows
assertDeepEqual(opened[3].items.map(a => a.action), ['run|q|a1', 'kind|arc|a1'], 'local-ai a free GPU runs its model or opens its Config')
const group = model.build(snap, { view: 'home', open: 'group:arc:2' }).rows
assertDeepEqual(group[5].items.map(a => a.action), ['run|q2|a1,a2', 'group|arc|2'], 'local-ai a group runs across its cards or opens its Config')
const gpage = model.build(snap, { view: 'group', id: 'arc', key: '2' })
assertDeepEqual([gpage.hero.name, gpage.rows.filter(r => r.type === 'gpu').length, gpage.rows[gpage.rows.length - 1].items[0].action], ['Qwen3.8-27B', 2, 'run|q2|a1,a2'], "local-ai a group's page lists its cards and runs across them")

// All GPUs: every card as home's rows, free ones first; a busy one still opens to its Config
const all = model.build(snap, { view: 'gpus' }).rows
assertDeepEqual(all.slice(1).map(r => r.run ? r.run.action : r.note), ['run|q|a1', 'run|q|a2', 'run|q2|a1,a2', 'running Qwen3.8-27B', 'in use by another program', 'no validated model yet'], 'local-ai the GPUs page lists every card and its state')
const held = model.build(snap, { view: 'gpus', open: 'gpu:n0' }).rows
assertDeepEqual([held[6].type, held[6].chips.map(c => c.text), held[6].items.map(a => a.label + ' ' + a.action)], ['links', ['24 GB'], ['Config kind|3090|n0']], 'local-ai a card another program holds opens to its Config')

// A card kind's page shows the one card it was opened from: Run when it is free, why not when another program holds it
const kfree = model.build(snap, { view: 'kind', id: 'arc', key: 'a2' })
assertDeepEqual([kfree.rows.filter(r => r.type === 'gpu').length, kfree.rows[kfree.rows.length - 1].items[0].action], [1, 'run|q|a2'], "local-ai a card's page runs its model on that card")
const kheld = model.build(snap, { view: 'kind', id: '3090', key: 'n0' })
assertDeepEqual([kheld.rows.filter(r => r.type === 'gpu').map(r => r.status), kheld.rows[kheld.rows.length - 1].items[0].action], [['in use by another program'], ''], "local-ai a held card's page says why it cannot run")

// A card's Config lists every model validated for it; choosing one changes the page and what Run starts
const other = { id: 'g', name: 'Gemma-4-12B-it', family: '', format: 'EXL3 · 4 bpw', ctx: 131072, caps: {}, weights: [] }
const picks = Object.assign({}, snap, { kinds: snap.kinds.map(k => k.hw === 'arc' ? Object.assign({}, k, { models: [recipe, other] }) : k) })
const cfg = model.build(picks, { view: 'kind', id: 'arc', key: 'a1' })
assertDeepEqual(cfg.rows.filter(r => r.type === 'opt').map(r => [r.label, r.on, r.action]), [['Qwen3.8-27B', true, 'model|q'], ['Gemma-4-12B-it', false, 'model|g']], "local-ai a card's Config lists its models, the recommended one chosen")
const chose = model.build(picks, { view: 'kind', id: 'arc', key: 'a1', model: 'g' })
assertDeepEqual([chose.hero.name, chose.rows.filter(r => r.type === 'opt' && r.on)[0].label, chose.rows[chose.rows.length - 1].items[0].action], ['Gemma-4-12B-it', 'Gemma-4-12B-it', 'run|g|a1'], 'local-ai choosing a model changes the page and what Run starts')

// A crashed model is an available GPU's row: run it again in one click, or open it for the reason, the log and dismiss
const crashed = Object.assign({}, snap, { deployments: [Object.assign({}, snap.deployments[0], { id: 'x', state: 'error', error: 'the engine stopped' })] })
const rows = model.build(crashed, { view: 'home', open: 'gpu:a0' }).rows
assertDeepEqual(rows.map(r => r.type), ['sec', 'slot', 'slot', 'slot', 'slot', 'links', 'field'], 'local-ai a crashed model is a row after the free ones and groups')
assertDeepEqual(rows[4].dismiss, 'stop|x', 'local-ai a crashed GPU is dismissed from its row in one click')
assertDeepEqual([rows[4].crashed, rows[4].run.action, rows[5].note, rows[5].items.map(a => a.action)], [true, 'again|x|a0', 'the engine stopped', ['again|x|a0', 'log', 'more|x']], 'local-ai a crashed GPU runs again, shows why, shows its logs or opens its Config')
JS
