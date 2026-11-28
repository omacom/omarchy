// Proves each level of Death Wish can be beaten, with the game's own physics (the part of index.html
// between <PHYSICS> and </PHYSICS>), by a clumsy bot: it only changes its mind every DECIDE seconds
// and treats every hazard as PAD tiles bigger than it is. Run after editing a level:
//
//   node solve.js              every level must be beaten; one that is not prints where the bot got to (+)
//   node solve.js --margins    how much bigger the hazards can get before each level is impossible:
//                              the smaller the margin, the harder the level, so it should shrink down the list
//   node solve.js --replay     the bot's winning inputs, to watch in the real game:
//                              index.html#replay=<what this prints>
//   node solve.js --replay 6   just room 6, to watch with index.html#from=6&replay=<what this prints>
const fs = require('fs'), path = require('path');
const src = fs.readFileSync(path.join(__dirname, 'index.html'), 'utf8');
const code = src.slice(src.indexOf('// <PHYSICS>'), src.indexOf('// </PHYSICS>'));
const { LEVELS, parseLevel, newPlayer, stepPlayer, status } = new Function(code + '; return { LEVELS, parseLevel, newPlayer, stepPlayer, status };')();
const STEP = 1 / 120, DECIDE = 0.1, PAD = 0.12;
const ACTIONS = [];
for (const dir of [-1, 0, 1]) for (const jump of [false, true]) ACTIONS.push([dir, jump]);   // the digit in a replay

function solve(L, decide, pad) {
  const n = Math.round(decide / STEP);
  const period = Math.max(0, ...L.saws.map(s => s.period));
  for (const s of L.saws) if (s.period && Math.abs(period / s.period - Math.round(period / s.period)) > 1e-9) throw new Error('saw periods must divide the longest one');
  const key = (p, t) => [Math.round(p.x * 4), Math.round(p.y * 4), Math.round(p.vx / 3.5), Math.round(p.vy / 5), p.ground | 0, p.wall, p.lock > 0 | 0, p.jumpHeld | 0,
    period ? Math.floor((t % period) / 0.1 + 1e-6) : 0].join(',');
  let frontier = [{ p: newPlayer(L), t: 0, path: '' }];
  const seen = new Set([key(frontier[0].p, 0)]), reached = new Set();
  for (let depth = 0; depth < 900 && frontier.length; depth++) {
    const next = [];
    for (const node of frontier) {
      for (let a = 0; a < ACTIONS.length; a++) {
        const p = { ...node.p };
        let t = node.t, result = null;
        for (let i = 0; i < n && !result; i++) { t += STEP; stepPlayer(p, ACTIONS[a][0], ACTIONS[a][1], L, STEP); result = status(p, L, t, pad); }
        if (result === 'goal') return { time: t, path: node.path + a, states: seen.size };
        if (result === 'dead') continue;
        const k = key(p, t);
        if (seen.has(k)) continue;
        seen.add(k);
        reached.add(Math.floor(p.x + 0.3) + ',' + (L.h - 1 - Math.floor(p.y + 0.4)));
        next.push({ p, t, path: node.path + a });
      }
    }
    frontier = next;
  }
  return { time: null, reached, states: seen.size };
}

const mode = process.argv[2], only = process.argv[3]?.split(',').map(Number);   // --margins 6,7 measures just those levels
const replay = [];
LEVELS.forEach((def, index) => {
  for (const row of def.map) if (row.length !== 32) throw new Error(`level ${index + 1}: row "${row}" is ${row.length} wide`);
  if (def.map.length !== 18) throw new Error(`level ${index + 1}: ${def.map.length} rows`);
  if (only && !only.includes(index + 1)) return;
  const L = parseLevel(def), label = `level ${String(index + 1).padStart(2)} ${def.name.padEnd(12)}`;
  if (mode === '--margins') {
    let margin = 0;
    for (const pad of [0.12, 0.18, 0.24, 0.3, 0.36, 0.42, 0.48]) { if (solve(L, 0.15, pad).time === null) break; margin = pad; }
    console.log(`${label} margin ${margin.toFixed(2)}  hazards ${L.spikes.length + L.saws.length}`);
    return;
  }
  const result = solve(L, DECIDE, PAD);
  if (result.time === null) {
    process.exitCode = 1;
    console.log(`${label} NOT BEATEN`);
    def.map.forEach((row, r) => console.log([...row].map((ch, c) => ch === '.' && result.reached.has(c + ',' + r) ? '+' : ch).join('')));
  } else if (mode === '--replay') replay[index] = result.path;
  else console.log(`${label} beaten in ${result.time.toFixed(1).padStart(4)}s`);
});
if (mode === '--replay') console.log(LEVELS.map((_, index) => replay[index] ?? '').join('.'));   // a room left out keeps its place, empty
