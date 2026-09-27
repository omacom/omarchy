// Solar elevation (GlobeModel) and the sky-tint palette (Sky.js).
const fs = require("fs"), path = require("path");
const root = path.join(__dirname, "../../../shell/plugins/panels/elsewhen");
const load = (file, names) => {
  const src = fs.readFileSync(path.join(root, file), "utf8").replace(".pragma library", "");
  const box = {};
  new Function(src + `; this.M={${names}};`).call(box);
  return box.M;
};
const G = load("GlobeModel.js", "subsolarPoint,solarElevation,isDaylight");
const S = load("Sky.js", "tint,STOPS");

let n = 0, f = 0;
const t = (k, cond, detail) => { n++; if (!cond) { f++; console.log("  FAIL", k, detail === undefined ? "" : detail); } };
const chan = (hex, i) => parseInt(hex.slice(1 + i * 2, 3 + i * 2), 16);

// --- elevation ------------------------------------------------------------
const sub = G.subsolarPoint(Date.UTC(2026, 5, 21, 12, 0, 0));
t("sun is overhead at the subsolar point", Math.abs(G.solarElevation(sub.lat, sub.lon, sub) - 90) < 0.01);
t("antipode is deepest night", G.solarElevation(-sub.lat, sub.lon + 180, sub) < -89);
t("isDaylight agrees at the subsolar point", G.isDaylight(sub.lat, sub.lon, sub) === true);
t("isDaylight agrees at the antipode", G.isDaylight(-sub.lat, sub.lon + 180, sub) === false);
t("elevation stays in range", [[0, 0], [51, 0], [-33, 151], [78, -68]]
  .every(([la, lo]) => { const e = G.solarElevation(la, lo, sub); return e >= -90.01 && e <= 90.01; }));

// --- palette --------------------------------------------------------------
t("endpoint: deepest night", S.tint(-90) === "#6e79a8", S.tint(-90));
t("endpoint: high sun", S.tint(90) === "#c8e1f0", S.tint(90));
// -40 sits between the -90 and -12 stops, so it interpolates rather than
// matching either endpoint - that is the point of the ramp.
t("between stops it interpolates", S.tint(-40) !== S.tint(-90) && S.tint(-40) !== S.tint(-12), S.tint(-40));
t("golden hour is warm (red > blue)", chan(S.tint(2), 0) > chan(S.tint(2), 2), S.tint(2));
t("daylight is cool (blue > red)", chan(S.tint(40), 2) > chan(S.tint(40), 0), S.tint(40));
t("night is cool (blue > red)", chan(S.tint(-40), 2) > chan(S.tint(-40), 0), S.tint(-40));
t("continuous across a stop", Math.abs(chan(S.tint(-6.01), 0) - chan(S.tint(-5.99), 0)) < 3);
t("monotone through dawn: night -> twilight -> gold",
  chan(S.tint(-20), 0) < chan(S.tint(-6), 0) && chan(S.tint(-6), 0) < chan(S.tint(3), 0));
t("clamps below", S.tint(-999) === S.tint(-90));
t("clamps above", S.tint(999) === S.tint(90));
t("rejects nonsense", S.tint(NaN) === null && S.tint("x") === null);
t("always a 6-digit hex", [-90, -30, -13, -6, 0, 5, 20, 60, 90].every(e => /^#[0-9a-f]{6}$/.test(S.tint(e))));
t("stops are ordered by elevation", S.STOPS.every((s, i) => i === 0 || s.e > S.STOPS[i - 1].e));

console.log(`  -> ${n - f}/${n} sky assertions passed`);
if (f) process.exitCode = 1;
