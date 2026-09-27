// The Earth row's clock: does 4.54 billion years actually land where it says?
//
// Two kinds of check. The structural ones are the reason this file exists at
// all - a hand-typed geological table loses contiguity and nesting silently,
// and a gap between two eras looks like nothing until a moment falls into it.
// The arithmetic ones are anchored on values worked out by hand from the
// division alone (66/4540 of a day is 20.93 minutes, so the dinosaurs go at
// 23:39), not by running the code and writing down what it said.
const fs = require("fs"), path = require("path");
const src = fs.readFileSync(path.join(__dirname, "../../../shell/plugins/panels/elsewhen", "DeepTime.js"), "utf8").replace(".pragma library", "");
const D = {};
new Function(src + "; this.D={AGE_MA,EONS,ERAS,PERIODS,EPOCHS,AGES,LEVELS,divisionAt,breadcrumb,dayFraction,clockAt,yearsPer,asClockSpan,bands};").call(D);
const d = D.D;

let n = 0, f = 0;
const t = (k, ok, extra) => { n++; if (!ok) { f++; console.log("  FAIL", k, extra === undefined ? "" : extra); } };
const near = (x, y, eps) => Math.abs(x - y) <= eps;
const hm = (ma) => { const c = d.clockAt(ma); return c.hour + ":" + String(c.minute).padStart(2, "0"); };

// --- the table holds together ---------------------------------------------
const levelNames = ["eons", "eras", "periods", "epochs", "ages"];
d.LEVELS.forEach((level, li) => {
  const name = levelNames[li];
  t(name + ": run oldest to youngest", level.every(x => x.from > x.to));
  t(name + ": contiguous", level.every((x, i) => i === 0 || x.from === level[i - 1].to),
    level.map(x => x.from + ">" + x.to).join(" "));
  t(name + ": end at the present", level[level.length - 1].to === 0);
  t(name + ": named", level.every(x => typeof x.name === "string" && x.name.length > 2));
});
t("eons span the whole Earth", d.EONS[0].from === d.AGE_MA);
t("eons end now", d.EONS[d.EONS.length - 1].to === 0);

// Every division must sit inside one division of the level above it, or the
// breadcrumb would claim a Cenozoic Cambrian.
for (let li = 1; li < d.LEVELS.length; li++) {
  for (const child of d.LEVELS[li]) {
    const parent = d.divisionAt(d.LEVELS[li - 1], child.from - 1e-9);
    t("nested: " + child.name, parent !== null && child.from <= parent.from && child.to >= parent.to,
      child.name + " in " + (parent ? parent.name : "nothing"));
  }
}

// --- published boundaries, not round numbers ------------------------------
// Spot values from the ICS chart. Wrong-by-rounding is the failure this
// catches: 540 for the Cambrian and 250 for the Permian-Triassic are the
// numbers people remember, and neither is the boundary.
const boundary = (level, name) => level.find(x => x.name === name);
t("Cambrian base is 538.8", boundary(d.PERIODS, "Cambrian").from === 538.8);
t("Permian-Triassic is 251.902", boundary(d.PERIODS, "Triassic").from === 251.902);
t("K-Pg is 66", boundary(d.PERIODS, "Paleogene").from === 66);
t("Quaternary base is 2.58", boundary(d.PERIODS, "Quaternary").from === 2.58);
t("Holocene base is 11,700 years", boundary(d.EPOCHS, "Holocene").from === 0.0117);
t("Meghalayan base is 4,200 years", boundary(d.AGES, "Meghalayan").from === 0.0042);

// --- the clock ------------------------------------------------------------
// 4540 Ma over 1440 minutes is 3.1528 Ma per minute; each anchor below is
// (ma / 4540) * 1440 minutes back from midnight, worked out on paper.
t("formation is midnight", hm(4540) === "0:00");
t("the present is a minute short of midnight", hm(0) === "23:59");
t("the present never reads 24:00", d.clockAt(0).hour === 23);
t("K-Pg at 23:39", hm(66) === "23:39");                    // 20.93 min back
t("Cambrian at 21:09", hm(538.8) === "21:09");             // 170.9 min back
t("end of the Archean at 10:47", hm(2500) === "10:47");    // 792.9 min in
t("Pleistocene opens at 23:59", hm(2.58) === "23:59");     // 49 s back
t("halfway is 2270 Ma", near(d.dayFraction(2270), 0.5, 1e-12));

// --- the units that make the row worth reading ----------------------------
t("an hour is 189 Myr", near(d.yearsPer("hour") / 1e6, 189.17, 0.01), d.yearsPer("hour") / 1e6);
t("a minute is 3.15 Myr", near(d.yearsPer("minute") / 1e6, 3.1528, 0.001));
t("a second is 52,546 years", near(d.yearsPer("second"), 52546, 1));
t("a day is the whole Earth", d.yearsPer("day") === d.AGE_MA * 1e6);
t("nonsense unit", d.yearsPer("fortnight") === 0);

// The three facts the row is for, each to a tenth of a unit.
t("the genus Homo is about a minute", near(d.asClockSpan(2.8e6) / 60, 0.89, 0.01));
t("our own species is six seconds", near(d.asClockSpan(300000), 5.71, 0.01));
t("recorded history is a tenth of a second", near(d.asClockSpan(5000), 0.095, 0.001));
t("a human life is a twentieth of a millisecond", d.asClockSpan(80) < 0.002);

// --- the breadcrumb -------------------------------------------------------
t("now", d.breadcrumb(0).join(" ") === "Phanerozoic Cenozoic Quaternary Holocene Meghalayan");
t("the age of dinosaurs", d.breadcrumb(100).join(" ") === "Phanerozoic Mesozoic Cretaceous");
t("the day the asteroid hit", d.breadcrumb(66.01).join(" ") === "Phanerozoic Mesozoic Cretaceous");
t("the day after", d.breadcrumb(65.99).join(" ") === "Phanerozoic Cenozoic Paleogene");
t("the Hadean has no smaller divisions", d.breadcrumb(4400).join(" ") === "Hadean");
t("deep in the Archean", d.breadcrumb(3000).join(" ") === "Archean Mesoarchean");
t("before the Earth", d.breadcrumb(5000).length === 0);

// --- the strip ------------------------------------------------------------
const bands = d.bands();
t("four bands", bands.length === 4);
t("bands start at the left edge", bands[0].x0 === 0);
t("bands end at the right edge", bands[bands.length - 1].x1 === 1);
t("bands are contiguous", bands.every((b, i) => i === 0 || near(b.x0, bands[i - 1].x1, 1e-12)));
t("bands cover the width", near(bands.reduce((s, b) => s + (b.x1 - b.x0), 0), 1, 1e-12));
// Every band has to be wide enough to see at the width of a panel: 300px of
// strip means anything under 1% is a hairline that reads as an artefact.
t("no band is invisible", bands.every(b => b.x1 - b.x0 > 0.02),
  bands.map(b => b.name + " " + ((b.x1 - b.x0) * 100).toFixed(1) + "%").join(" "));
t("the Phanerozoic is a ninth of the day", near(bands[3].x1 - bands[3].x0, 0.1187, 0.0005));

console.log((f ? "FAIL " : "ok ") + (n - f) + "/" + n + " deep time");
process.exit(f ? 1 : 0);
