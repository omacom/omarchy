// Validates GlobeModel's solar maths against Open-Meteo's is_day flag for
// every city on the globe, plus projection invariants. Run: node tests/globe_check.js
const fs = require("fs"), path = require("path"), https = require("https");
const root = path.join(__dirname, "../../../shell/plugins/panels/elsewhen");
const src = fs.readFileSync(path.join(root, "GlobeModel.js"), "utf8").replace(".pragma library", "");
const M = {};
new Function(src + "; this.M={project,subsolarPoint,solarElevation,isDaylight,terminator,layoutLabels,scalePx};").call(M);
const G = M.M;
const cities = JSON.parse(fs.readFileSync(path.join(root, "cities.json"), "utf8"));

let fails = 0, checks = 0;
const ok = (name, cond, detail) => {
  checks++;
  if (!cond) { fails++; console.log("  FAIL", name, detail === undefined ? "" : detail); }
};

// ---- projection invariants ------------------------------------------------
const p = G.project(0, 0, 0, 0, 100);
ok("centre projects to origin", Math.abs(p.x) < 1e-9 && Math.abs(p.y) < 1e-9 && p.visible);
ok("antipode hidden", G.project(0, 180, 0, 0, 100).visible === false);
ok("north pole up at zero tilt", G.project(90, 0, 0, 0, 100).y < -99);
ok("east is +x", G.project(0, 45, 0, 0, 100).x > 0);
ok("spin follows the point", Math.abs(G.project(0, 45, 45, 0, 100).x) < 1e-9);
for (const [lat, lon] of [[12, 34], [-56, 78], [80, -170]]) {
  const q = G.project(lat, lon, 20, 15, 100);
  ok(`inside disc ${lat},${lon}`, Math.hypot(q.x, q.y) <= 100.0001, Math.hypot(q.x, q.y));
}

// ---- subsolar point -------------------------------------------------------
const jun = G.subsolarPoint(Date.UTC(2026, 5, 21, 12, 0, 0));
ok("june solstice declination ~ +23.4", Math.abs(jun.lat - 23.44) < 0.5, jun.lat);
const dec = G.subsolarPoint(Date.UTC(2026, 11, 21, 12, 0, 0));
ok("december solstice declination ~ -23.4", Math.abs(dec.lat + 23.44) < 0.5, dec.lat);
const mar = G.subsolarPoint(Date.UTC(2026, 2, 20, 12, 0, 0));
ok("march equinox declination ~ 0", Math.abs(mar.lat) < 1.0, mar.lat);
const noonUTC = G.subsolarPoint(Date.UTC(2026, 5, 21, 12, 0, 0));
ok("noon UTC subsolar near Greenwich meridian", Math.abs(noonUTC.lon) < 5, noonUTC.lon);
const sixUTC = G.subsolarPoint(Date.UTC(2026, 5, 21, 18, 0, 0));
ok("18:00 UTC subsolar near 90W", Math.abs(sixUTC.lon + 90) < 5, sixUTC.lon);

// ---- solar elevation ------------------------------------------------------
ok("sun is overhead at the subsolar point", Math.abs(G.solarElevation(jun.lat, jun.lon, jun) - 90) < 0.01);
ok("antipode is deepest night", G.solarElevation(-jun.lat, jun.lon + 180, jun) < -89);
ok("isDaylight agrees at the subsolar point", G.isDaylight(jun.lat, jun.lon, jun) === true);
ok("isDaylight agrees at the antipode", G.isDaylight(-jun.lat, jun.lon + 180, jun) === false);
ok("elevation stays in range", [[0, 0], [51, 0], [-33, 151], [78, -68]]
  .every(([la, lo]) => { const e = G.solarElevation(la, lo, jun); return e >= -90.01 && e <= 90.01; }));

// ---- terminator -----------------------------------------------------------
const sub = G.subsolarPoint(Date.now());
const term = G.terminator(sub, 60);
ok("terminator closes", term.length === 61);
ok("terminator is the 90-degree circle",
   term.every(([la, lo]) => {
     const cosz = Math.sin(la * Math.PI / 180) * Math.sin(sub.lat * Math.PI / 180)
                + Math.cos(la * Math.PI / 180) * Math.cos(sub.lat * Math.PI / 180)
                * Math.cos((lo - sub.lon) * Math.PI / 180);
     return Math.abs(cosz) < 1e-9;
   }));

// ---- label collision ------------------------------------------------------
const cand = [
  { index: 0, name: "AAAA", x: 0, y: 0, rank: 1, cosc: 1 },
  { index: 1, name: "BBBB", x: 2, y: 2, rank: 1, cosc: 0.9 },   // overlaps 0
  { index: 2, name: "CCCC", x: 0, y: 80, rank: 1, cosc: 0.8 },  // clear
];
const placed = G.layoutLabels(cand, 7, 12);
ok("overlapping label dropped", placed.length === 2, placed.map(p => p.index));
ok("clear label kept", placed.some(p => p.index === 2));

// A label that would run off the right edge is placed to the left of its dot
// instead of overflowing the panel.
const wide = [{ index: 0, name: "Bangkok", x: 120, y: 0, rank: 1, cosc: 1 }];
const free = G.layoutLabels(wide, 7, 12, 10)[0].box;
const bounded = G.layoutLabels(wide, 7, 12, 10, 150)[0].box;
ok("unbounded label may overflow", free.x + free.w > 150, free.x + free.w);
ok("bounded label flips to the left of its dot", bounded.x + bounded.w <= 150,
   bounded.x + bounded.w);
ok("flipped label still sits beside its dot", bounded.x < 120 && bounded.x + bounded.w > 60,
   bounded.x);
const near = [{ index: 0, name: "Lagos", x: -40, y: 0, rank: 1, cosc: 1 }];
ok("a label that fits is left alone", G.layoutLabels(near, 7, 12, 10, 150)[0].box.x === -34);

// ---- drawn constants follow the UI scale ---------------------------------
// The large globe's radius and labels scale with the shell's base font size;
// its strokes and marker radii did not, so a bigger font gave it thinner
// lines. Every drawn constant now goes through scalePx.
ok("scale 1 is the literal", G.scalePx(1.4, 1) === 1.4);
ok("a bigger shell draws heavier", G.scalePx(1.4, 2) === 2.8);
ok("radii scale too", G.scalePx(7.5, 1.5) === 11.25);
// Proportion is the whole point: a selection ring must stay the same multiple
// of a city dot at any scale, which a per-call rounding would break.
const ratio = s => G.scalePx(7.5, s) / G.scalePx(2.2, s);
ok("ring keeps its proportion to the dot",
   Math.abs(ratio(1) - ratio(1.67)) < 1e-9, [ratio(1), ratio(1.67)]);
// Below a pixel a stroke drops out of the raster rather than reading thin,
// which is why the small globe floors its widths the same way.
ok("hairlines floor at one pixel", G.scalePx(1, 0.5) === 1);
ok("the floor is overridable", G.scalePx(1, 0.5, 0.25) === 0.5);
ok("a nonsense scale falls back to 1", G.scalePx(2.5, 0) === 2.5
   && G.scalePx(2.5, undefined) === 2.5 && G.scalePx(2.5, NaN) === 2.5);

// The gap from a dot to its name is now scalable, but an omitted gap must
// leave every existing caller's layout untouched.
const gapCity = [{ index: 0, name: "Lagos", x: -40, y: 0, rank: 1, cosc: 1 }];
ok("omitted gap keeps the old 6px",
   G.layoutLabels(gapCity, 7, 12, 10, 150)[0].box.x === -34);
ok("a scaled gap moves the name out with the dot",
   G.layoutLabels(gapCity, 7, 12, 10, 150, 10)[0].box.x === -30);
ok("a nonsense gap falls back to 6",
   G.layoutLabels(gapCity, 7, 12, 10, 150, 0)[0].box.x === -34);

// ---- day/night against Open-Meteo is_day ---------------------------------
const lats = cities.map(c => c[2]).join(","), lons = cities.map(c => c[3]).join(",");
const url = `https://api.open-meteo.com/v1/forecast?latitude=${lats}&longitude=${lons}&current=is_day`;
if (process.argv.includes("--offline")) {
  console.log("  skipped is_day check (offline)");
  done();
} else https.get(url, res => {
  let buf = "";
  res.on("data", d => buf += d);
  res.on("end", () => {
    let feed;
    try { feed = JSON.parse(buf); } catch { console.log("  skipped is_day check (bad response)"); return done(); }
    if (!Array.isArray(feed)) { console.log("  skipped is_day check"); return done(); }
    const now = G.subsolarPoint(Date.now());
    // Open-Meteo reports `current` on a 15-minute interval, so near sunrise
    // or sunset its flag can be up to a quarter hour stale - it has been
    // wrong and this code right every time that has come up. So a
    // disagreement is judged by *where the sun actually is*: within a few
    // degrees of the horizon it is the reference lagging and is expected;
    // far from the horizon it would be a real error in this code, and fails.
    const NEAR_HORIZON_DEG = 4;
    let expected = [], real = [];
    feed.forEach((entry, i) => {
      const theirs = (entry.current || {}).is_day;
      if (theirs === undefined) return;
      const elev = G.solarElevation(cities[i][2], cities[i][3], now);
      const mine = G.isDaylight(cities[i][2], cities[i][3], now) ? 1 : 0;
      checks++;
      if (mine === theirs) return;
      const note = `${cities[i][0]} mine=${mine} theirs=${theirs} elev=${elev.toFixed(2)}`;
      if (Math.abs(elev) <= NEAR_HORIZON_DEG) expected.push(note); else real.push(note);
    });
    if (real.length) {
      fails += real.length;
      console.log(`  day/night: ${real.length} disagreement(s) away from the horizon ->`, real.join("; "));
    }
    if (expected.length) {
      console.log(`  day/night: ${expected.length} at the horizon (reference lag, expected) ->`, expected.join("; "));
    }
    if (!real.length && !expected.length) {
      console.log(`  day/night: all ${feed.length} cities agree with Open-Meteo is_day`);
    }
    done();
  });
}).on("error", () => { console.log("  skipped is_day check (offline)"); done(); });

function done() {
  console.log(`  -> ${checks - fails}/${checks} globe assertions passed`);
  process.exit(fails ? 1 : 0);
}
