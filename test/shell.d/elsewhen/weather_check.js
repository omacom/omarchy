// WMO present-weather codes collapsed to the five states a row has room for.
const fs = require("fs"), path = require("path");
const src = fs.readFileSync(path.join(__dirname, "../../../shell/plugins/panels/elsewhen", "Model.js"), "utf8")
  .replace(".pragma library", "");
const box = {};
new Function(src + "; this.M={weatherKind,resolveUnits,formatTemp,usesTwentyFourHour,resolveHour24};").call(box);
const kind = box.M.weatherKind;

let n = 0, f = 0;
const t = (label, code, want) => {
  n++;
  const got = kind(code);
  if (got !== want) { f++; console.log("  FAIL", label, `(${code}) ->`, JSON.stringify(got), "want", JSON.stringify(want)); }
};

t("clear sky", 0, "sunny");
t("mainly clear", 1, "sunny");
t("partly cloudy", 2, "partly");
t("overcast", 3, "cloudy");
t("fog", 45, "cloudy");
t("depositing rime fog", 48, "cloudy");
t("light drizzle", 51, "rain");
t("dense drizzle", 55, "rain");
t("freezing drizzle", 57, "rain");
t("slight rain", 61, "rain");
t("heavy rain", 65, "rain");
t("heavy freezing rain", 67, "rain");
t("slight rain showers", 80, "rain");
t("violent rain showers", 82, "rain");
t("thunderstorm", 95, "rain");
t("thunderstorm with hail", 99, "rain");
t("slight snow", 71, "snow");
t("heavy snow", 75, "snow");
t("snow grains", 77, "snow");
t("slight snow showers", 85, "snow");
t("heavy snow showers", 86, "snow");

// A missing reading must not become a sun: Number(null) is 0, which is the
// code for clear sky.
t("null", null, "");
t("undefined", undefined, "");
t("empty string", "", "");
t("not a number", "rain", "");
t("unassigned code", 7, "");

const known = ["", "sunny", "partly", "cloudy", "rain", "snow"];
let all = true;
for (let c = 0; c <= 99; c++) if (!known.includes(kind(c))) all = false;
n++; if (!all) { f++; console.log("  FAIL every code 0..99 maps to a known kind"); }

// Numeric strings are what a JSON round trip can hand back.
t("numeric string", "61", "rain");

// --- which unit, and the conversion ---------------------------------------
// The setting wins when it says something; everything else defers to the
// system's own measurement system, so a fresh install abroad does not read in
// Fahrenheit because that is where this was written.
const eq = (label, got, want) => {
  n++;
  if (got !== want) { f++; console.log("  FAIL", label, JSON.stringify(got), "!=", JSON.stringify(want)); }
};
const ru = box.M.resolveUnits, ft = box.M.formatTemp;
eq("explicit C", ru("C", "F"), "C");
eq("explicit F", ru("F", "C"), "F");
eq("lower case counts", ru("c", "F"), "C");
eq("padded counts", ru("  f  ", "C"), "F");
eq("unset follows a metric system", ru("", "C"), "C");
eq("unset follows a US system", ru("", "F"), "F");
eq("undefined follows the system", ru(undefined, "C"), "C");
eq("null follows the system", ru(null, "F"), "F");
eq("junk follows the system", ru("kelvin", "C"), "C");
eq("an unknown auto is metric", ru("", "wat"), "C");

// Freezing and boiling, and a rounding case in each direction.
eq("freezing in C", ft(0, "C"), "0\u00b0C");
eq("freezing in F", ft(0, "F"), "32\u00b0F");
eq("boiling in F", ft(100, "F"), "212\u00b0F");
eq("body heat in F", ft(37, "F"), "99\u00b0F");
eq("negative rounds toward zero-ish", ft(-17.8, "F"), "0\u00b0F");
eq("half rounds up in C", ft(21.5, "C"), "22\u00b0C");
eq("nothing to show", ft(null, "C"), "");

// --- twelve or twenty-four ------------------------------------------------
// Qt hands over the locale's short time pattern; the AM/PM designator is what
// tells the two clocks apart.
const t24 = box.M.usesTwentyFourHour, rh = box.M.resolveHour24;
eq("US pattern is twelve-hour", t24("h:mm AP"), false);
eq("lower-case designator too", t24("h:mm ap"), false);
eq("German pattern is twenty-four", t24("HH:mm"), true);
eq("seconds do not matter", t24("HH:mm:ss"), true);
eq("a quoted separator is not a designator", t24("H'h'mm"), true);
eq("but a real designator survives stripping", t24("h'h'mm AP"), false);
eq("designator before the hour", t24("AP h:mm"), false);
// The patterns Qt actually hands over, read off the running shell: the
// designator is spelled "Ap" and the space before it is U+202F, not a space.
eq("Qt's own en_US pattern", t24("h:mm\u202fAp"), false);
eq("Qt's own en_GB pattern", t24("HH:mm"), true);
eq("Qt's own ja_JP pattern", t24("H:mm"), true);
eq("Qt's own fi_FI pattern", t24("H.mm"), true);
eq("nothing known is twenty-four", t24(""), true);

eq("explicit true", rh(true, false), true);
eq("explicit false is not emptiness", rh(false, true), false);
eq("string true", rh("true", false), true);
eq("string false", rh("false", true), false);
eq("24 as a word", rh("24", false), true);
eq("12 as a word", rh("12", true), false);
eq("blank follows the system", rh("", true), true);
eq("blank follows a twelve-hour system", rh("", false), false);
eq("undefined follows the system", rh(undefined, true), true);
eq("null follows the system", rh(null, true), true);
eq("junk follows the system", rh("maybe", true), true);

console.log(`  -> ${n - f}/${n} weather assertions passed`);
if (f) process.exitCode = 1;
