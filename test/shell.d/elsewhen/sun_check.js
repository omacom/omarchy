// Sunrise and sunset, against Open-Meteo's own published times.
//
// Not against ourselves: the whole point of computing this locally is that it
// has to agree with what a person would find if they looked the city up. The
// reference rows below were fetched from Open-Meteo's daily sunrise/sunset
// (api.open-meteo.com for the recent dates, archive-api for the older ones)
// with timezone=UTC, and are held here verbatim so the test stays offline.
//
// The set is chosen for the cases that break naive implementations: both
// hemispheres, both solstices, the equator, a city whose clock is two hours
// from its own sun (Kashgar on Beijing time), and the two polar cases where
// there is no sunrise at all.

const fs = require("fs"), path = require("path");
const read = (f) => fs.readFileSync(path.join(__dirname, "../../../shell/plugins/panels/elsewhen", f), "utf8")
  .replace(/^\.pragma library$/m, "")
  .replace(/^\.import .*$/gm, "");

const box = {};
new Function(read("GlobeModel.js") + "\nvar Solar = { subsolarPoint: subsolarPoint };\n"
  + read("Sun.js")
  + "; this.M={sunTimes,litSpans,litAt,eventMark,solarNoonMs};").call(box);
const m = box.M;

let n = 0, f = 0;
const fail = (label, got, want) => {
  n++; f++;
  console.log("  FAIL", label, JSON.stringify(got), "!=", JSON.stringify(want));
};
const eq = (label, got, want) => { n++; if (got !== want) { n--; fail(label, got, want); } };
const near = (label, gotMs, wantIso, toleranceMin) => {
  n++;
  const want = Date.parse(wantIso + "Z");
  const off = Math.abs(gotMs - want) / 60000;
  if (!(off <= toleranceMin)) {
    n--;
    fail(label + ` (out by ${off.toFixed(1)} min)`,
      new Date(gotMs).toISOString(), wantIso);
  }
};

// name, lat, lon, local date, UTC offset in minutes, reference rise, reference set
const REF = [
  ["Chicago", 41.85, -87.65, [2026, 8, 31], -300, "2026-08-31T11:15", "2026-09-01T00:26"],
  ["Auckland", -36.85, 174.76, [2026, 8, 31], 720, "2026-08-30T18:43", "2026-08-31T05:59"],
  ["Copenhagen", 55.68, 12.57, [2026, 8, 31], 120, "2026-08-31T04:13", "2026-08-31T18:07"],
  ["Tokyo", 35.69, 139.69, [2026, 8, 31], 540, "2026-08-30T20:12", "2026-08-31T09:11"],
  ["Quito", -0.22, -78.51, [2026, 8, 31], -300, "2026-08-31T11:10", "2026-08-31T23:17"],
  ["Kashgar", 39.47, 75.99, [2026, 8, 31], 480, "2026-08-31T00:23", "2026-08-31T13:29"],
  ["Reykjavik", 64.15, -21.94, [2025, 12, 21], 0, "2025-12-21T11:21", "2025-12-21T15:30"],
  ["Sydney", -33.87, 151.21, [2025, 12, 21], 660, "2025-12-20T18:40", "2025-12-21T09:05"],
  ["Nairobi", -1.29, 36.82, [2026, 3, 20], 180, "2026-03-20T03:36", "2026-03-20T15:43"],
  ["Anchorage", 61.22, -149.90, [2026, 6, 21], -480, "2026-06-21T12:19", "2026-06-22T07:43"],
  ["Ushuaia", -54.80, -68.30, [2026, 6, 21], -180, "2026-06-21T12:58", "2026-06-21T20:11"],
  // Past 64 north, where the sun cuts the horizon at a shallow angle and the
  // shared solar model's fraction of a degree becomes minutes of time. These
  // two are here with the tolerance they need rather than left out to keep the
  // headline number tidy - the bar cannot show four minutes, but the chip
  // prints a time.
  ["Nuuk", 64.18, -51.72, [2026, 8, 31], -120, "2026-08-31T08:06", "2026-08-31T22:47"],
  ["Anadyr", 64.73, 177.51, [2026, 8, 31], 720, "2026-08-30T16:47", "2026-08-31T07:35"],
];
const SHALLOW = { Nuuk: 5, Anadyr: 5 };

// Local noon of the reference date, which is the instant a row would be asking
// about in the middle of its own day.
const noonAt = ([y, mo, d], offset) => Date.UTC(y, mo - 1, d, 12) - offset * 60000;

for (const [name, lat, lon, date, offset, rise, set] of REF) {
  const t = m.sunTimes(lat, lon, noonAt(date, offset), offset);
  eq(name + " has a sunrise", t.kind, "normal");
  // Two minutes. Open-Meteo publishes to the minute and rounds; the remaining
  // difference is the low-precision solar position the globe shares, which is
  // good to a fraction of a degree - about a minute of time at these latitudes
  // and more where the sun cuts the horizon at a shallow angle.
  var slack = SHALLOW[name] || 2;
  near(name + " sunrise", t.riseMs, rise, slack);
  near(name + " sunset", t.setMs, set, slack);
}

// --- the poles, where there is no sunrise to be out by --------------------
const longyear = (date, offset) =>
  m.sunTimes(78.22, 15.63, noonAt(date, offset), offset);

eq("Longyearbyen in June is midnight sun", longyear([2026, 6, 21], 120).kind, "midnightSun");
eq("Longyearbyen in December is polar night", longyear([2025, 12, 21], 60).kind, "polarNight");
eq("midnight sun lights the whole bar",
  JSON.stringify(m.litSpans(longyear([2026, 6, 21], 120))), JSON.stringify([{ x0: 0, x1: 1 }]));
eq("polar night lights none of it",
  JSON.stringify(m.litSpans(longyear([2025, 12, 21], 60))), "[]");
eq("the sun is up all day under midnight sun",
  m.litAt(longyear([2026, 6, 21], 120), 3 * 60), true);
eq("and never up under polar night",
  m.litAt(longyear([2025, 12, 21], 60), 12 * 60), false);
eq("no tick where there is no sunrise",
  m.eventMark(longyear([2026, 6, 21], 120).riseMinutes), null);

// --- the day the strip actually draws --------------------------------------
// Chicago on this date: sunrise 06:15 and sunset 19:26 by its own clock, so
// the band starts a quarter of the way along the bar and ends four fifths of
// the way along.
const chicago = m.sunTimes(41.85, -87.65, noonAt([2026, 8, 31], -300), -300);
const span = m.litSpans(chicago)[0];
// Derived from the reference row above - 11:15 and 00:26 UTC are 06:15 and
// 19:26 on Chicago's clock - with the same minute of slack the instants get.
const within = (label, got, want, slack) => {
  n++;
  if (Math.abs(got - want) > slack) { n--; fail(label + ` (out by ${(got - want).toFixed(1)})`, got, want); }
};
within("Chicago's band starts at sunrise", span.x0 * 1440, 375, 2);
within("Chicago's band ends at sunset", span.x1 * 1440, 1166, 2);
within("thirteen hours of daylight", chicago.dayMinutes, 791, 2);
eq("dawn is dark", m.litAt(chicago, 5 * 60), false);
eq("noon is not", m.litAt(chicago, 12 * 60), true);
eq("and so is the evening", m.litAt(chicago, 22 * 60), false);

// A clock two hours from its own sun still gets one band, not two. Kashgar's
// day runs 08:23 to 21:29 on Beijing time and fits inside the bar; nothing is
// wrapped round to the other end.
const kashgar = m.sunTimes(39.47, 75.99, noonAt([2026, 8, 31], 480), 480);
eq("Kashgar draws one band", m.litSpans(kashgar).length, 1);
within("Kashgar's sun rises after eight", kashgar.riseMinutes, 503, 2);
within("and sets after nine in the evening", kashgar.setMinutes, 1289, 2);

// --- a bar that is lit at both ends ---------------------------------------
// Reykjavik on the June solstice sets four minutes after midnight, so the first
// four minutes of the same day are lit as well - by the sun that rose the
// morning before. This used to be clipped away and drawn dark, which put the
// sun below the horizon at an hour when the shared solar model has it above.
const solstice = m.sunTimes(64.15, -21.94, noonAt([2026, 6, 21], 0), 0);
eq("its sun sets after midnight", solstice.setMinutes > 1440, true);
const bothEnds = m.litSpans(solstice);
eq("so the bar is drawn in two pieces", bothEnds.length, 2);
within("the first piece starts at midnight", bothEnds[0].x0 * 1440, 0, 0.01);
within("and ends at the small hours' sunset", bothEnds[0].x1 * 1440, 4, 1);
within("the second piece starts at sunrise", bothEnds[1].x0 * 1440, 175, 1);
within("and runs to the end of the bar", bothEnds[1].x1 * 1440, 1440, 0.01);
eq("midnight is lit", m.litAt(solstice, 0), true);
eq("an hour later is not", m.litAt(solstice, 60), false);
eq("and the morning is lit again", m.litAt(solstice, 180), true);

// An ordinary city is untouched by any of that: one piece, dark at midnight.
eq("Chicago is still one band", m.litSpans(chicago).length, 1);
eq("and dark at midnight", m.litAt(chicago, 0), false);
eq("Kashgar too", m.litSpans(kashgar).length, 1);

// --- the ticks still clip -------------------------------------------------
// The band wraps but the arrows do not. A sunset at 00:04 belongs to the next
// bar along; a mark pinned to the edge of this one would claim the sun set at
// midnight, and its printed time would name an hour that is not on this bar.
eq("no tick for a sunset past midnight", m.eventMark(solstice.setMinutes), null);
eq("an event before the bar has no mark", m.eventMark(-30), null);
eq("an event after it has none either", m.eventMark(1500), null);
eq("midnight is on the bar", m.eventMark(0), 0);
eq("and so is the far end", m.eventMark(1440), 1);

console.log(`  -> ${n}/${n + f} sun assertions passed`);
if (f) process.exitCode = 1;
