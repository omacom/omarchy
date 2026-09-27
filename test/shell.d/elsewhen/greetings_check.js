// The greeting table: shape, coverage, and the claims it makes about
// languages.
//
// There is no independent oracle for "is this what people say in Lagos at
// 8am" on this machine, so what is checked here is everything around that: no
// city can be greeted in nothing, no hour of the day can fall in a gap, and
// every non-Latin greeting carries a pronunciation. The words themselves want
// a speaker's eye, not a test - see the note in NOTES.md.
const fs = require("fs"), path = require("path");
const root = path.join(__dirname, "../../../shell/plugins/panels/elsewhen");
const load = (file, exports) => {
  const src = fs.readFileSync(path.join(root, file), "utf8").replace(".pragma library", "");
  const box = {};
  new Function(src + "; this.X={" + exports + "};").call(box);
  return box.X;
};
const g = load("Greetings.js", "greeting,languageFor,languageKeys,zoneIds,countryCodes,countryFor,bandsOf");

let n = 0, f = 0;
const t = (k, ok, extra) => { n++; if (!ok) { f++; console.log("  FAIL", k, extra === undefined ? "" : extra); } };

// --- every zone the picker can offer can be greeted ----------------------
// The picker does not offer the shipped catalogue. It offers whatever
// `timedatectl list-timezones` returns - 598 zones on this machine - and the
// first version of this file checked coverage against cities.json instead,
// which is exactly why Tel Aviv said "Good morning" in English for a day.
// Check the list the panel actually uses, from the same command it uses.
const { execSync } = require("child_process");
let offered = [];
try {
  offered = execSync("timedatectl list-timezones", { encoding: "utf8" }).trim().split("\n");
} catch (e) {
  try {
    offered = execSync("find /usr/share/zoneinfo -type f -printf '%P\\n' | grep /", { encoding: "utf8" })
      .trim().split("\n");
  } catch (e2) { offered = []; }
}
// Zones that are offsets rather than places: Etc/GMT+5, UTC, Zulu. Nobody
// lives in one, so nobody is greeted in one.
const placeless = z => /^(Etc\/|GMT|UCT$|UTC$|Universal$|Zulu$|Greenwich$|Factory$)/.test(z);
const places = offered.filter(z => !placeless(z));

t("the system offers a zone list at all", places.length > 300, places.length);
// English is a real answer in a great many places, so it cannot be checked by
// looking at the result. It is checked at the source instead: a zone is only
// greeted in English if some country explicitly asked for English. A zone that
// is missing from the table gets English too, and that is the accident.
const stranded = places.filter(z => g.countryFor(z) === "");
t("every place has a country", stranded.length === 0, stranded.slice(0, 10).join(", "));
const orphan = places.filter(z => g.countryFor(z) !== "" && g.languageFor(z) === "en"
                                  && g.countryCodes().indexOf(g.countryFor(z)) === -1);
t("no zone falls through to the default", orphan.length === 0, orphan.slice(0, 10).join(", "));
t("the offset-only zones are still answered",
  g.greeting("Etc/GMT+5", 9).text === "Good morning" && g.countryFor("Etc/GMT+5") === "");

// Every offered zone must be in the baked table, not merely resolve to
// something: a zone missing from ZONE_COUNTRY still "works", in English.
const absent = places.filter(z => g.zoneIds().indexOf(z) === -1);
t("every offered zone is in the table", absent.length === 0, absent.slice(0, 10).join(", "));

// And the shipped catalogue, which is the subset most people will ever add.
const cities = JSON.parse(fs.readFileSync(path.join(root, "cities.json"), "utf8"));
for (const zone of [...new Set(cities.map(c => c[1]))])
  t("catalogue city mapped: " + zone, g.zoneIds().indexOf(zone) !== -1);

// --- the ones that were wrong ---------------------------------------------
t("Tel Aviv is greeted in Hebrew", g.greeting("Asia/Jerusalem", 7).language === "Hebrew");
t("Tel Aviv at 7am", g.greeting("Asia/Jerusalem", 7).roman === "boker tov");
t("Singapore is greeted in Malay", g.greeting("Asia/Singapore", 14).language === "Malay");
t("Singapore at 2pm", g.greeting("Asia/Singapore", 14).text === "Selamat tengah hari");

// --- overrides, aliases and countries -------------------------------------
t("Honolulu overrides the United States", g.greeting("Pacific/Honolulu", 8).language === "Hawaiian");
t("but the mainland does not", g.greeting("America/Denver", 8).language === "English");
t("Montreal overrides Canada", g.greeting("America/Montreal", 8).language === "French");
t("Toronto does not", g.greeting("America/Toronto", 8).language === "English");
t("an alias resolves like its target", g.greeting("Asia/Calcutta", 8).language === "Hindi");
t("so does a legacy US alias", g.greeting("US/Pacific", 8).language === "English");
t("so does a renamed capital", g.greeting("Europe/Kiev", 8).language === "Ukrainian");
t("every country code is spoken for", g.countryCodes().length > 240);

// --- the fallback is a fallback, not a crash -----------------------------
t("unknown zone", g.greeting("Mars/Olympus_Mons", 9).text === "Good morning");
t("empty zone", g.greeting("", 9).language === "English");
t("undefined zone", g.greeting(undefined, 9).text.length > 0);

// --- every hour of every language lands in a band ------------------------
// Latin script, generously: Latin-1 and both Extended blocks for the European
// diacritics, IPA Extensions for Azerbaijani's schwa, combining marks for
// Yoruba's tones, and the okina for Hawaiian.
const LATIN = /^[\u0020-\u007e\u00a0-\u024f\u0250-\u02ff\u0300-\u036f\u1e00-\u1eff\u2018\u2019]+$/;
for (const key of g.languageKeys()) {
  const bands = g.bandsOf(key);
  t(key + ": starts at midnight", bands[0].from === 0, bands[0].from);
  t(key + ": bands ascend", bands.every((b, i) => i === 0 || b.from > bands[i - 1].from));
  t(key + ": bands are inside a day", bands.every(b => b.from >= 0 && b.from <= 23));
  t(key + ": no empty greeting", bands.every(b => b.text.trim() === b.text && b.text.length > 0));

  // Adjacent bands must actually say something different, or the boundary is
  // a claim about the language that the words do not back up. The first and
  // last may repeat - that is the night wrapping around midnight.
  for (let i = 1; i < bands.length; i++) {
    const wrap = i === bands.length - 1 && bands[i].text === bands[0].text;
    t(key + ": band " + i + " differs from the one before",
      wrap || bands[i].text !== bands[i - 1].text, bands[i].text);
  }

  // Pronunciation exactly where the script is not Latin, and nowhere else.
  for (const b of bands) {
    const latin = LATIN.test(b.text);
    t(key + ": " + (latin ? "Latin script needs no roman" : "non-Latin script carries a roman"),
      latin ? b.roman === "" : b.roman.length > 0, b.text + " / " + b.roman);
    t(key + ": roman is sayable", b.roman === "" || /^[a-z' -]+$/.test(b.roman), b.roman);
  }

  // Every hour resolves, and to one of this language's own bands.
  const texts = new Set(bands.map(b => b.text));
  for (let h = 0; h < 24; h++) {
    const zone = g.zoneIds().find(z => g.languageFor(z) === key);
    if (!zone) continue;
    t(key + ": hour " + h + " has a greeting", texts.has(g.greeting(zone, h).text), h);
  }
}

// --- out-of-range hours ---------------------------------------------------
t("hour 24 clamps into the day", g.greeting("Asia/Tokyo", 24).text === g.greeting("Asia/Tokyo", 23).text);
t("negative hour clamps to midnight", g.greeting("Asia/Tokyo", -3).text === g.greeting("Asia/Tokyo", 0).text);
t("fractional hour truncates", g.greeting("Asia/Tokyo", 11.9).text === g.greeting("Asia/Tokyo", 11).text);

// --- the boundaries the table exists to express --------------------------
// If these ever collapse into each other the feature has stopped saying
// anything: the whole point is that the hour means different things.
const at = (z, h) => g.greeting(z, h).text;
t("Tokyo walks through its day",
  at("Asia/Tokyo", 7) !== at("Asia/Tokyo", 13) && at("Asia/Tokyo", 13) !== at("Asia/Tokyo", 20));
t("Madrid is still in the afternoon at 20:00", at("Europe/Madrid", 20) === "Buenas tardes");
t("Lima is not", at("America/Lima", 20) === "Buenas noches");
t("both are Spanish", g.greeting("Europe/Madrid", 20).language.indexOf("Spanish") === 0
                   && g.greeting("America/Lima", 20).language === "Spanish");
t("Vienna and Berlin differ at midday", at("Europe/Vienna", 13) !== at("Europe/Berlin", 13));
t("Zurich too", at("Europe/Zurich", 13) !== at("Europe/Berlin", 13));
t("Jakarta has an afternoon and a late afternoon",
  at("Asia/Jakarta", 12) !== at("Asia/Jakarta", 16));
t("Yangon says the same thing all day",
  new Set([0, 6, 12, 18, 23].map(h => at("Asia/Yangon", h))).size === 1);
t("Hong Kong is not greeted in Mandarin", at("Asia/Hong_Kong", 8) !== at("Asia/Shanghai", 8));
t("Honolulu is Hawaiian", g.greeting("Pacific/Honolulu", 8).language === "Hawaiian");

// --- the legacy aliases name places, not rules -----------------------------
//
// The zone table was built by matching compiled zoneinfo files, which puts an
// alias in whatever country happens to keep the same time. Iceland kept
// Abidjan's clock and was greeted in French; NZ matched Antarctica. Checked
// here against the canonical zone for the *same place*, which is an answer that
// does not come from the same table - not against the tz link table, which
// would hand back Côte d'Ivoire for Iceland and Papua New Guinea for Truk.
const samePlace = [
  ["Iceland", "Atlantic/Reykjavik"],
  ["NZ", "Pacific/Auckland"],
  ["Singapore", "Asia/Singapore"],
  ["Asia/Rangoon", "Asia/Yangon"],
  ["Africa/Asmera", "Africa/Asmara"],
  ["Africa/Timbuktu", "Africa/Bamako"],
  ["America/Virgin", "America/St_Thomas"],
  ["Pacific/Truk", "Pacific/Chuuk"],
  ["Pacific/Yap", "Pacific/Chuuk"],
  ["US/Arizona", "America/Phoenix"],
  ["MST", "America/Phoenix"],
  ["Canada/Eastern", "America/Toronto"],
  ["America/Nipigon", "America/Toronto"],
  ["America/Thunder_Bay", "America/Toronto"],
];
for (const [alias, canonical] of samePlace) {
  t(alias + " is in the same country as " + canonical,
    g.countryFor(alias) === g.countryFor(canonical));
  t(alias + " is greeted like " + canonical,
    at(alias, 9) === at(canonical, 9));
}

// The two that look like alias mistakes and are not: the South Pole really is
// in Antarctica and Pohnpei really is in Micronesia, whatever the link table
// says about the zones they share their rules with.
t("the South Pole stays in Antarctica", g.countryFor("Antarctica/South_Pole") === "AQ");
t("Pohnpei stays in Micronesia", g.countryFor("Pacific/Ponape") === "FM");
// A choice rather than a lookup, and worth failing loudly if it is ever flipped
// by a regenerated table.
t("Simferopol is greeted in Ukrainian", g.greeting("Europe/Simferopol", 9).language === "Ukrainian");

// America/Montreal is the exception to the rule above: same country as Toronto,
// different language, because it has an explicit override.
t("Montreal is Canadian", g.countryFor("America/Montreal") === g.countryFor("America/Toronto"));
t("but greeted in French", g.greeting("America/Montreal", 9).language === "French");

console.log((f ? "FAIL " : "ok ") + (n - f) + "/" + n + " greetings");
process.exit(f ? 1 : 0);
