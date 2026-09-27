// Circular-time maths for the time scrubber, the offset labels beside it,
// and drag-to-reorder.
const fs = require("fs"), path = require("path");
const src = fs.readFileSync(path.join(__dirname, "../../../shell/plugins/panels/elsewhen", "Model.js"), "utf8").replace(".pragma library", "");
const M = {};
new Function(src + "; this.M={scrubDeltaMinutes,formatScrubDelta,formatMinuteOfDay,utcOffsetLabel,relativeOffsetLabel};").call(M);
const m = M.M;

let n = 0, f = 0;
const t = (k, a, b) => { n++; if (JSON.stringify(a) !== JSON.stringify(b)) { f++; console.log("  FAIL", k, JSON.stringify(a), "!=", JSON.stringify(b)); } };

// --- scrubbing ------------------------------------------------------------
t("scrub forward", Math.round(m.scrubDeltaMinutes(0.5, 600)), 120);
t("scrub backward", Math.round(m.scrubDeltaMinutes(0.5, 840)), -120);
t("scrub takes the short way round midnight", Math.round(m.scrubDeltaMinutes(0.0, 1380)), 60);
t("scrub clamps past the right edge", Math.round(m.scrubDeltaMinutes(2, 720)), 720);
// Exactly half a day away is genuinely ambiguous - forward and back are the
// same distance, and strip position 0 and 1 are the same instant on a
// circular day. The function resolves consistently into (-720, +720].
t("half-day is resolved forward, consistently", Math.round(m.scrubDeltaMinutes(-1, 720)), 720);
t("and the same from the other edge", Math.round(m.scrubDeltaMinutes(1, 720)), 720);
t("scrub at current time is zero", Math.round(m.scrubDeltaMinutes(600 / 1440, 600)), 0);
t("delta format", [m.formatScrubDelta(0), m.formatScrubDelta(45), m.formatScrubDelta(-90), m.formatScrubDelta(180)],
  ["", "+45m", "-1h 30m", "+3h"]);
t("minute-of-day format", [m.formatMinuteOfDay(0, false), m.formatMinuteOfDay(13 * 60 + 5, false), m.formatMinuteOfDay(13 * 60, true)],
  ["12:00 AM", "1:05 PM", "13:00"]);

// --- absolute offsets, for cities you have not added yet -----------------
// The rows say "+9h", meaning nine hours from here. A search result has no
// "here" to be relative to, so it says where it is instead.
t("Greenwich", m.utcOffsetLabel(0), "UTC");
t("whole hours drop the minutes", m.utcOffsetLabel(120), "UTC+2");
t("west of Greenwich", m.utcOffsetLabel(-300), "UTC-5");
t("the three-quarter zones keep theirs", m.utcOffsetLabel(345), "UTC+5:45");
t("Newfoundland", m.utcOffsetLabel(-210), "UTC-3:30");
t("Adelaide", m.utcOffsetLabel(570), "UTC+9:30");
t("the far end of the line", m.utcOffsetLabel(840), "UTC+14");
t("and the other far end", m.utcOffsetLabel(-720), "UTC-12");
t("a single-digit minute pads", m.utcOffsetLabel(65), "UTC+1:05");
// --- fractional minutes, which is what a sunrise is -----------------------
// The hour and the minute have to be carried together. Rounding them apart
// printed "6:60 AM" for 12 seconds before seven, and rolled neither the hour
// nor, at the end of the day, the date.
t("a few seconds short of the hour rolls the hour",
  m.formatMinuteOfDay(419.81, false), "7:00 AM");
t("and does the same on a 24-hour clock",
  m.formatMinuteOfDay(419.81, true), "07:00");
t("exactly half a minute rounds up",
  m.formatMinuteOfDay(419.5, false), "7:00 AM");
t("just under half stays put",
  m.formatMinuteOfDay(419.49, false), "6:59 AM");
t("noon is not midnight",
  m.formatMinuteOfDay(719.7, false), "12:00 PM");
t("the last minute of the day wraps to the first",
  m.formatMinuteOfDay(1439.7, false), "12:00 AM");
t("and wraps on a 24-hour clock too",
  m.formatMinuteOfDay(1439.7, true), "00:00");
t("whole minutes are unchanged",
  m.formatMinuteOfDay(375, false), "6:15 AM");

t("nothing known yet", m.utcOffsetLabel(undefined), "");
t("nothing at all", m.utcOffsetLabel(null), "");
t("not a number", m.utcOffsetLabel(NaN), "");

// --- the same offset read the other way ----------------------------------
// The globe's footer prints one of these two, chosen by the same setting the
// rows use. The blank case is the one that matters to the interface: a city
// on your own offset has no relative label, which is why the zone name beside
// it is part of the click target and not just decoration.
const rel = m.relativeOffsetLabel;
t("nine hours ahead", rel(540, 0), "+9h");
t("three behind", rel(-300, -120), "-3h");
t("quarter zones round to a tenth", rel(345, 0), "+5.8h");
t("half-hour zones keep the half", rel(330, 0), "+5.5h");
t("Adelaide from Sydney", rel(570, 600), "-0.5h");
t("your own offset says nothing", rel(-480, -480), "");
t("same offset, different zone, still nothing", rel(0, 0), "");

console.log(`  -> ${n - f}/${n} scrub assertions passed`);
// exitCode rather than exit(), so the sections below still run.
if (f) process.exitCode = 1;

// --- drag-to-reorder ------------------------------------------------------
const M3 = {};
new Function(require("fs").readFileSync(require("path").join(__dirname, "../../../shell/plugins/panels/elsewhen", "Model.js"), "utf8")
  .replace(".pragma library", "") + "; this.M={parseZones,moveZone};").call(M3);
const r = M3.M;
const four = r.parseZones("A|X/a, B|X/b, C|X/c, D|X/d");
const names = zs => zs.map(z => z.label).join("");

let n3 = 0, f3 = 0;
const t3 = (k, a, b) => { n3++; if (JSON.stringify(a) !== JSON.stringify(b)) { f3++; console.log("  FAIL", k, JSON.stringify(a), "!=", JSON.stringify(b)); } };

t3("move down one", names(r.moveZone(four, 0, 1)), "BACD");
t3("move to the end", names(r.moveZone(four, 0, 3)), "BCDA");
t3("move to the front", names(r.moveZone(four, 3, 0)), "DABC");
t3("move up one", names(r.moveZone(four, 2, 1)), "ACBD");
t3("same position is a no-op", r.moveZone(four, 2, 2), four);
t3("out of range low", r.moveZone(four, -1, 2), four);
t3("out of range high", r.moveZone(four, 0, 9), four);
t3("length is preserved", r.moveZone(four, 0, 3).length, 4);
t3("original is untouched", names(four), "ABCD");

console.log(`  -> ${n3 - f3}/${n3} reorder assertions passed`);
if (f3) process.exitCode = 1;
