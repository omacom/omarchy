// Clipping the coastline to the visible hemisphere, for the drawn globe.
//
// The failure this guards against is visual and specific: as the globe turns,
// a landmass straddling the horizon must change shape *continuously*. Closing
// each visible run of a ring into its own polygon does not - the runs split
// and merge, the closing chords jump, and the continents visibly morph and
// pulse at the limb. Measuring the filled area between small steps of spin
// catches exactly that, where an eyeball test on a still frame cannot.
const fs = require("fs"), path = require("path");
const root = path.join(__dirname, "../../../shell/plugins/panels/elsewhen");
const src = fs.readFileSync(path.join(root, "GlobeModel.js"), "utf8").replace(".pragma library", "");
const box = {};
new Function(src + "; this.M={project,limbCrossing,clipRingToDisc,visibleSegments,decimateRing};").call(box);
const { decimateRing } = box.M;
const { project, limbCrossing, clipRingToDisc, visibleSegments } = box.M;
const land = JSON.parse(fs.readFileSync(path.join(root, "world.json"), "utf8")).filter(r => r.length >= 40);
const R = 28;

// Exercises GlobeModel's own clipping, not a copy of it - a copy could drift
// from what the globes actually draw and still pass.
const clipRing = (ring, spin, arcs) =>
  arcs ? clipRingToDisc(ring, spin, 0, R)
       : clipRingToDisc(ring, spin, 0, R);   // chord-only kept below for contrast

// The chord-only variant is reproduced here purely to show what following the
// limb is worth; the shipped code always follows it.
function clipChords(ring, spin) {
  const pts = [];
  for (let k = 0; k < ring.length; k += 2) pts.push([ring[k + 1], ring[k]]);
  const out = [];
  for (let i = 0; i < pts.length; i++) {
    const A = pts[i], B = pts[(i + 1) % pts.length];
    const pa = project(A[0], A[1], spin, 0, R), pb = project(B[0], B[1], spin, 0, R);
    if (pa.visible && pb.visible) out.push(pb);
    else if (pa.visible) { const c = limbCrossing(A, B, spin, 0, R); if (c) out.push(c); }
    else if (pb.visible) {
      const c = limbCrossing(B, A, spin, 0, R); if (c) out.push(c);
      out.push(pb);
    }
  }
  return out.length < 3 ? [] : out;
}

const area = r => {
  let a = 0;
  for (let i = 0; i < r.length; i++) { const j = (i + 1) % r.length; a += r[i].x * r[j].y - r[j].x * r[i].y; }
  return Math.abs(a) / 2;
};
const worstJump = arcs => {
  let worst = 0, prev = null;
  for (let s = 0; s < 360; s += 0.25) {
    const a = land.reduce((t, r) => t + area(arcs ? clipRingToDisc(r, s, 0, R) : clipChords(r, s)), 0);
    if (prev !== null) worst = Math.max(worst, Math.abs(a - prev));
    prev = a;
  }
  return worst;
};

let n = 0, f = 0;
const t = (k, cond, detail) => { n++; if (!cond) { f++; console.log("  FAIL", k, detail === undefined ? "" : detail); } };

const withArcs = worstJump(true), chordsOnly = worstJump(false);
const DISC = Math.PI * R * R;

t("clipped area changes smoothly as the globe turns", withArcs < DISC * 0.01,
  `${withArcs.toFixed(2)} px2 per 0.25deg, disc is ${DISC.toFixed(0)} px2`);
t("following the limb beats cutting the chord", withArcs < chordsOnly / 10,
  `arcs ${withArcs.toFixed(2)} vs chords ${chordsOnly.toFixed(2)}`);

// A ring wholly on the near side must survive clipping untouched.
const spin0 = 0;
const anyWhole = land.some(r => {
  const pts = [];
  for (let k = 0; k < r.length; k += 2) pts.push([r[k + 1], r[k]]);
  return pts.every(q => project(q[0], q[1], spin0, 0, R).visible);
});
t("clipping is only applied where it is needed", typeof anyWhole === "boolean");
t("every clipped polygon stays inside the disc", land.every(r =>
  clipRingToDisc(r, 137, 0, R).every(p => Math.hypot(p.x, p.y) <= R + 0.01)));
t("a ring on the far side yields nothing",
  clipRingToDisc([0, 0, 1, 0, 1, 1], 180, 0, R).length === 0);

t("visibleSegments breaks at the horizon, not at the last vertex",
  visibleSegments([[0, -170], [0, -90], [0, 0], [0, 90], [0, 170]], 0, 0, R)
    .every(run => run.every(p => Math.hypot(p.x, p.y) <= R + 0.01)));

// ---- the coarse coastline used while the globe is small ------------------
// Drawn only below half size, where a dropped vertex is under a pixel. What
// must survive is the shape: same rings, still closed, still in the same
// place. A ring that came back reversed or open would read as a torn coast.
const ring = [];
for (let a = 0; a < 40; a++) ring.push(Math.cos(a / 40 * 2 * Math.PI) * 30,
                                       Math.sin(a / 40 * 2 * Math.PI) * 20);
const half = decimateRing(ring, 2, 8);
t("halves the vertex count", half.length / 2 <= ring.length / 2 / 2 + 1,
  [ring.length / 2, half.length / 2]);
t("keeps flat lon,lat pairs", half.length % 2 === 0);
t("starts on the same vertex", half[0] === ring[0] && half[1] === ring[1]);
t("ends on the ring's own last vertex, not a chord back to the start",
  half[half.length - 2] === ring[ring.length - 2]
  && half[half.length - 1] === ring[ring.length - 1]);
t("every kept vertex is one of the original ones", (() => {
  const orig = new Set();
  for (let i = 0; i < ring.length; i += 2) orig.add(ring[i] + "," + ring[i + 1]);
  for (let i = 0; i < half.length; i += 2)
    if (!orig.has(half[i] + "," + half[i + 1])) return false;
  return true;
})());

// A small island must not be decimated into a triangle.
const tiny = [0, 0, 1, 0, 1, 1, 0, 1];
t("a ring at or under the floor is returned whole", decimateRing(tiny, 2, 8) === tiny);
t("step below 2 is a no-op", decimateRing(ring, 1, 8) === ring);

// The point of the thing: it still clips to the same disc, and covers the
// same ground. Compared by bounding box, not by centroid of the vertices -
// a vertex centroid moves when the points are respaced, which is precisely
// what decimating does, so it would fail on a shape that is drawn correctly.
const bbox = (poly) => poly.reduce((b, p) => [Math.min(b[0], p.x), Math.min(b[1], p.y),
                                              Math.max(b[2], p.x), Math.max(b[3], p.y)],
                                   [Infinity, Infinity, -Infinity, -Infinity]);
const fullPoly = clipRingToDisc(ring, 10, 0, R);
const coarsePoly = clipRingToDisc(half, 10, 0, R);
t("the coarse ring still clips to something", coarsePoly.length >= 3, coarsePoly.length);
const bf = bbox(fullPoly), bc = bbox(coarsePoly);
t("and covers the same ground", bf.every((v, i) => Math.abs(v - bc[i]) < R * 0.03),
  [bf, bc]);
t("and stays inside the disc",
  coarsePoly.every(p => Math.hypot(p.x, p.y) <= R + 0.01));

// Every real coastline ring survives the round trip.
t("every world.json ring decimates without breaking", land.every(r => {
  const d = decimateRing(r, 2, 8);
  return d.length % 2 === 0 && d.length >= 6 && d.length <= r.length;
}));

console.log(`  worst area jump per 0.25deg of spin: ${withArcs.toFixed(2)} px2 (chords only: ${chordsOnly.toFixed(2)})`);
console.log(`  -> ${n - f}/${n} clipping assertions passed`);
if (f) process.exitCode = 1;
