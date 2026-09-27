// The moon phase shown on each row's night marker.
//
// The phase itself is checked against eclipses, which are the one thing that
// pins a lunation to a wall clock: a solar eclipse can only happen at new
// moon and a lunar eclipse only at full. The drawn shape is checked by
// rasterising it and counting lit pixels against the illumination formula.
const fs = require("fs"), path = require("path");
const src = fs.readFileSync(path.join(__dirname, "../../../shell/plugins/panels/elsewhen", "GlobeModel.js"), "utf8")
  .replace(".pragma library", "");
const box = {};
new Function(src + "; this.M={moonPhase,moonIllumination,moonLitOutline,moonPhaseName,SYNODIC_MONTH};").call(box);
const { moonPhase, moonIllumination, moonLitOutline, moonPhaseName, SYNODIC_MONTH } = box.M;

let n = 0, f = 0;
const t = (k, cond, detail) => { n++; if (!cond) { f++; console.log("  FAIL", k, detail === undefined ? "" : detail); } };

// --- phase against known eclipses -----------------------------------------
// A mean synodic month drifts from the true one by a few hours either way, so
// these are allowed a day. That is 3% of a cycle, and at most a few percent
// of illumination - far finer than a dot a few pixels across can show.
const TOLERANCE_DAYS = 1.0;
const eclipses = [
  ["2017-08-21T18:26Z", 0.0,  "total solar, Wyoming"],
  ["2024-04-08T18:17Z", 0.0,  "total solar, Mexico"],
  ["2019-01-21T05:12Z", 0.5,  "total lunar"],
  ["2022-11-08T10:59Z", 0.5,  "total lunar"],
  ["2021-05-26T11:19Z", 0.5,  "total lunar"],
];
for (const [iso, want, label] of eclipses) {
  const p = moonPhase(Date.parse(iso));
  let d = Math.abs(p - want);
  if (d > 0.5) d = 1 - d;
  t(`${label} falls at phase ${want}`, d * SYNODIC_MONTH <= TOLERANCE_DAYS,
    `phase ${p.toFixed(3)}, off by ${(d * SYNODIC_MONTH * 24).toFixed(1)}h`);
}

// --- the names, on the same eclipses ---------------------------------------
// The eclipses pin the naming as well as the number: a solar eclipse can only
// happen at new moon and a lunar one only at full, so the name at those
// instants is not a matter of taste.
for (const [iso, want, label] of eclipses) {
  t(`${label} is named for its phase`,
    moonPhaseName(moonPhase(Date.parse(iso))) === (want === 0 ? "New moon" : "Full moon"),
    moonPhaseName(moonPhase(Date.parse(iso))));
}

// The exact instants, and the mid-points between them.
const named = [
  [0, "New moon"], [0.25, "First quarter"], [0.5, "Full moon"], [0.75, "Last quarter"],
  [0.125, "Waxing crescent"], [0.375, "Waxing gibbous"],
  [0.625, "Waning gibbous"], [0.875, "Waning crescent"],
];
for (const [p, want] of named)
  t(`phase ${p} is ${want}`, moonPhaseName(p) === want, moonPhaseName(p));

// The principal phases hold for a day either side and not a moment longer, and
// the wrap at the top of the cycle is a new moon rather than a waning one.
const day = 1 / SYNODIC_MONTH;
t("a day past full is still full", moonPhaseName(0.5 + day * 0.9) === "Full moon");
t("two days past full is not", moonPhaseName(0.5 + day * 2) === "Waning gibbous");
t("just before new is still new", moonPhaseName(1 - day * 0.5) === "New moon");
t("phase 1 wraps to new", moonPhaseName(1) === "New moon");
t("negative phases wrap too", moonPhaseName(-0.25) === "Last quarter");
t("nonsense names nothing", moonPhaseName(NaN) === "");

// --- phase arithmetic ------------------------------------------------------
t("phase always in [0,1)", [0, 1e12, Date.now(), Date.UTC(1970, 0, 1)]
  .every(ms => { const p = moonPhase(ms); return p >= 0 && p < 1; }));
t("a synodic month later is the same phase", (() => {
  const now = Date.now();
  const a = moonPhase(now), b = moonPhase(now + SYNODIC_MONTH * 86400000);
  return Math.abs(a - b) < 1e-6 || Math.abs(a - b) > 1 - 1e-6;
})());
t("illumination: new is dark, full is lit",
  moonIllumination(0) < 1e-9 && Math.abs(moonIllumination(0.5) - 1) < 1e-9);
t("illumination: quarters are half",
  Math.abs(moonIllumination(0.25) - 0.5) < 1e-9
  && Math.abs(moonIllumination(0.75) - 0.5) < 1e-9);

// --- the drawn shape -------------------------------------------------------
const R = 40;
const inside = (poly, x, y) => {          // even-odd
  let c = false;
  for (let i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    const a = poly[i], b = poly[j];
    if (((a.y > y) !== (b.y > y)) && (x < (b.x - a.x) * (y - a.y) / (b.y - a.y) + a.x)) c = !c;
  }
  return c;
};
function measure(phase) {
  const poly = moonLitOutline(phase, R, 96);
  let lit = 0, disc = 0, litLeft = 0, litRight = 0;
  for (let y = -R; y <= R; y += 0.5)
    for (let x = -R; x <= R; x += 0.5) {
      if (x * x + y * y > R * R) continue;
      disc++;
      if (!inside(poly, x, y)) continue;
      lit++;
      if (x < 0) litLeft++; else litRight++;
    }
  return { frac: lit / disc, litLeft, litRight };
}
for (const p of [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875]) {
  const m = measure(p);
  t(`drawn area matches the formula at phase ${p}`,
    Math.abs(m.frac - moonIllumination(p)) < 0.03,
    `drawn ${(m.frac * 100).toFixed(1)}% vs ${(moonIllumination(p) * 100).toFixed(1)}%`);
}
// Waxing lights the right limb, waning the left - the northern view.
t("waxing crescent is lit on the right", measure(0.125).litRight > measure(0.125).litLeft * 20);
t("waning crescent is lit on the left", measure(0.875).litLeft > measure(0.875).litRight * 20);
t("first quarter lights the right half", measure(0.25).litLeft < measure(0.25).litRight * 0.05);
t("last quarter lights the left half", measure(0.75).litRight < measure(0.75).litLeft * 0.05);
t("new moon draws nothing", measure(0).frac < 0.01);
t("full moon draws everything", measure(0.5).frac > 0.99);
// The outline must never leave the disc it is drawn on.
t("outline stays within the disc", [0, 0.2, 0.4, 0.6, 0.8].every(p =>
  moonLitOutline(p, R, 48).every(q => Math.hypot(q.x, q.y) <= R + 1e-6)));

console.log(`  -> ${n - f}/${n} moon assertions passed`);
if (f) process.exitCode = 1;
