// The list and the globe select the same city through two different index
// spaces: a row is an index into `zones`, the globe's `selected` is an index
// into its own catalogue of every city it draws. Model.indexOfZone is the
// crossing between them. Run: node tests/selection_check.js
const fs = require("fs"), path = require("path");
const root = path.join(__dirname, "../../../shell/plugins/panels/elsewhen");
const box = {};
const src = fs.readFileSync(path.join(root, "Model.js"), "utf8").replace(".pragma library", "");
new Function(src + "; this.M={parseZones,indexOfZone,indexOfZoneKey,factsKey,moveZone,removeZoneAt,labelForZoneId,addZone,serializeZones,zoneOptions,chipAfterTap,chipAfterRelease,NO_CHIP,arrowBox,arrowCovered};").call(box);
const M = box.M;

let n = 0, f = 0;
const t = (k, a, b) => {
  n++;
  if (JSON.stringify(a) !== JSON.stringify(b)) { f++; console.log("  FAIL", k, JSON.stringify(a), "!=", JSON.stringify(b)); }
};

const zones = M.parseZones("Paris|Europe/Paris, Tokyo|Asia/Tokyo|w, New York|America/New_York");

// --- the crossing itself ---------------------------------------------------
t("first row found", M.indexOfZone(zones, "Paris", "Europe/Paris"), 0);
t("middle row found", M.indexOfZone(zones, "Tokyo", "Asia/Tokyo"), 1);
t("last row found", M.indexOfZone(zones, "New York", "America/New_York"), 2);

// A globe city the list does not track has no row to focus. This is the
// common case - the globe draws every zone's main city - and it must read as
// "no row", never as row 0 or as home.
t("untracked globe city is not a row", M.indexOfZone(zones, "Lagos", "Africa/Lagos"), -1);

// Both fields have to agree. The globe carries a label and a zone precisely
// because either alone is ambiguous: zones share city names, and a renamed
// row keeps its zone.
t("right label, wrong zone", M.indexOfZone(zones, "Tokyo", "Asia/Osaka"), -1);
t("right zone, wrong label", M.indexOfZone(zones, "Tokyo City", "Asia/Tokyo"), -1);
t("empty list", M.indexOfZone([], "Paris", "Europe/Paris"), -1);
t("missing list", M.indexOfZone(undefined, "Paris", "Europe/Paris"), -1);

// --- the round trip the two views actually make ---------------------------
// Panel builds the globe's tracked rows as [label, id, lat, lon, 0], and the
// globe hands back element 0 and element 1 of whichever it selected. Building
// the rows the same way Panel.qml does is the point: a hand-written pair
// could agree with indexOfZone while the real one did not.
const facts = {
  "Europe/Paris": { lat: 48.86, lon: 2.35 },
  "Asia/Tokyo": { lat: 35.68, lon: 139.69 },
  "America/New_York": { lat: 40.71, lon: -74.01 },
};
const trackedCities = zones
  .filter(z => facts[z.id] !== undefined)
  .map(z => [z.label, z.id, facts[z.id].lat, facts[z.id].lon, 0]);

t("every tracked row survives the round trip",
  trackedCities.map(c => M.indexOfZone(zones, c[0], c[1])), [0, 1, 2]);

// Selecting on the globe and then reading the row back must land on the row
// that was clicked, for every row, not just the first.
for (let i = 0; i < trackedCities.length; i++) {
  const c = trackedCities[i];
  t(`row ${i} round trips`, M.indexOfZone(zones, c[0], c[1]), i);
}

// A city added with no label of its own still round trips: parseZones fills
// the label in from the zone id, and Panel builds the globe row from that
// same filled-in value.
const added = M.parseZones("Europe/Rome");
t("a bare zone gets a label", added[0].label, "Rome");
t("and still round trips", M.indexOfZone(added, added[0].label, added[0].id), 0);
t("labelForZoneId agrees", M.labelForZoneId("Europe/Rome"), added[0].label);

// Reordering the list moves the row a globe selection resolves to; the pair
// is positional in nothing, so it follows the city rather than the slot.
const reordered = M.parseZones("Tokyo|Asia/Tokyo|w, Paris|Europe/Paris, New York|America/New_York");
t("selection follows the city, not the slot",
  M.indexOfZone(reordered, "Paris", "Europe/Paris"), 1);

// A zone is not a city. Six of the picker's entries share
// America/Los_Angeles, so the name the user pointed at is the only thing that
// distinguishes them - committing the zone alone put "Los Angeles" on the list
// when Oakland was chosen, which the keyboard selection made impossible to
// miss. The pure function was always right; the panel was dropping the label
// on the way in. These pin the contract it relies on.
const catalog = M.zoneOptions("America/Los_Angeles\nAsia/Tokyo", []);
const sharing = catalog.filter(o => o.value === "America/Los_Angeles");
t("one zone, several cities", sharing.length > 1, true, sharing.length > 1);
t("and they are told apart by name",
  new Set(sharing.map(o => o.label)).size, sharing.length);
t("the chosen name is kept", M.addZone([], "America/Los_Angeles", "Oakland")[0].label, "Oakland");
t("a blank name still falls back to the zone",
  M.addZone([], "America/Los_Angeles", "")[0].label, "Los Angeles");
t("two cities in one zone can both be tracked",
  M.addZone(M.addZone([], "America/Los_Angeles", "Oakland"), "America/Los_Angeles", "Las Vegas").length, 2);

// The IPC `add` takes any two strings. What goes in must come back out of the
// "Label|Zone, Label|Zone" setting as the row that was asked for.
const roundTrip = zs => M.parseZones(M.serializeZones(zs));
t("a label with a comma survives the setting",
  roundTrip(M.addZone([], "Asia/Tokyo", "Tokyo, Japan")).map(z => z.label + "@" + z.id), ["Tokyo Japan@Asia/Tokyo"]);
t("a label with a pipe survives the setting",
  roundTrip(M.addZone([], "Asia/Tokyo", "Tokyo|HQ")).map(z => z.label + "@" + z.id), ["Tokyo HQ@Asia/Tokyo"]);
t("a label that is only delimiters falls back to the zone's name",
  M.addZone([], "Asia/Tokyo", ",|,")[0].label, "Tokyo");
t("an id that could not name a zone is refused", M.addZone([], "evil id, with|pipe", "x").length, 0);
t("an id with a space is refused", M.addZone([], "Asia/Tokyo x", "x").length, 0);
t("refusing returns the same array, so nothing is written", (() => { const z = []; return M.addZone(z, "bad id", "x") === z; })(), true);
t("markup is kept as text for the row to draw plainly",
  M.addZone([], "Asia/Tokyo", "<img src=x>")[0].label, "<img src=x>");
// And the picker stops offering the one already taken, by name and not by zone.
const remaining = M.zoneOptions("America/Los_Angeles", M.addZone([], "America/Los_Angeles", "Oakland"));
t("the tracked city drops out of the picker",
  remaining.some(o => o.label === "Oakland"), false);
t("its neighbours stay in",
  remaining.some(o => o.label === "Las Vegas"), true);

// --- the list's focus survives the list changing ---------------------------
//
// focusIndex used to be a stored row number, and `zones` is a binding replaced
// wholesale on a reorder or a removal - so the number silently came to mean a
// different city. It is a key now, and the index is derived from it.
const focusOf = (list, key) => M.indexOfZoneKey(list, key);
const tokyoKey = M.factsKey(zones[1]);

t("the key finds its city", focusOf(zones, tokyoKey), 1);
t("an empty key is no focus", focusOf(zones, ""), -1);
t("a key for a city that is gone is no focus either",
  focusOf(zones, "Lagos|Africa/Lagos"), -1);
t("a missing list does not throw", focusOf(null, tokyoKey), -1);

// Drag the row above it away and the focus goes with the city, not the slot.
const moved = M.moveZone(zones, 0, 2);
t("a reorder moves the city off slot 1", moved[1].label !== "Tokyo", true);
t("and the focus follows the city", moved[focusOf(moved, tokyoKey)].label, "Tokyo");

// Remove the row above it and the same holds: Tokyo is now row 0.
const shorter = M.removeZoneAt(zones, 0);
t("a removal shifts the rows up", shorter[0].label, "Tokyo");
t("and the focus is still on Tokyo", focusOf(shorter, tokyoKey), 0);

// Remove the focused city itself and the focus falls back to home, which is
// what -1 means everywhere it is read.
const withoutTokyo = M.removeZoneAt(zones, 1);
t("losing the focused city drops the focus", focusOf(withoutTokyo, tokyoKey), -1);

// --- where the arrows sit --------------------------------------------------
//
// The glyph has to land outside the band it points at. A mark on the boundary
// reads as part of the band, which is what putting the arrows outside it was
// for, and the tuck that pulls them closer is three pixels from undoing that.
const { arrowBox, arrowCovered } = box.M;
const BAR = 567, BOX = 14, TUCK = 3, MARK = 10, SLACK = 4;

t("the up arrow sits before the band", arrowBox(0.26, BAR, BOX, TUCK, true), 136);
t("the down arrow sits after it", arrowBox(0.81, BAR, BOX, TUCK, false), 456);
t("the up glyph stays before its crossing",
  arrowBox(0.26, BAR, BOX, TUCK, true) + BOX / 2 < 0.26 * BAR, true);
t("the down glyph stays after its crossing",
  arrowBox(0.81, BAR, BOX, TUCK, false) + BOX / 2 > 0.81 * BAR, true);

// A sunrise a minute after midnight cannot hang its box off the end of the bar.
t("a box at the very start is held on the bar", arrowBox(0, BAR, BOX, TUCK, true), 0);
t("a box at the very end is held on too", arrowBox(1, BAR, BOX, TUCK, false), BAR - BOX);

t("the marker covers an arrow it sits on", arrowCovered(136, BOX, 143, MARK, SLACK), true);
t("and not one it has passed", arrowCovered(136, BOX, 160, MARK, SLACK), false);
t("nor one at the other end of the bar", arrowCovered(456, BOX, 143, MARK, SLACK), false);

// --- the row's popup chips, under either delivery order --------------------
//
// A press on an arrow reaches only the arrow - tests/qml/tst_arrows.qml proves
// that with synthetic mouse events - but a press on the row body reaches the
// reorder grab, which dismisses. Which of the two runs first is Qt's business
// and not worth depending on, so the pair has to come out right in either
// order.
const { chipAfterTap, chipAfterRelease, NO_CHIP } = box.M;
const SUNRISE = 0, SUNSET = 1;

// One click, played both ways. `atPress` is what was showing when the press
// began, which is the only thing either rule is allowed to read.
function click(atPress, slot, tapFirst) {
  let shown = atPress;
  if (tapFirst) {
    shown = chipAfterTap(atPress, slot);
    shown = chipAfterRelease(shown, atPress);
  } else {
    shown = chipAfterRelease(shown, atPress);
    shown = chipAfterTap(atPress, slot);
  }
  return shown;
}

for (const tapFirst of [true, false]) {
  const when = tapFirst ? "tap first" : "release first";
  t(`${when}: clicking sunrise from nothing opens it`,
    click(NO_CHIP, SUNRISE, tapFirst), SUNRISE);
  t(`${when}: clicking sunrise again closes it`,
    click(SUNRISE, SUNRISE, tapFirst), NO_CHIP);
  t(`${when}: clicking sunset while sunrise is open swaps them`,
    click(SUNRISE, SUNSET, tapFirst), SUNSET);
  t(`${when}: clicking sunrise while sunset is open swaps back`,
    click(SUNSET, SUNRISE, tapFirst), SUNRISE);
}

// A click on the bare row - no tap handler runs at all, only the release.
t("clicking elsewhere with a chip open closes it",
  chipAfterRelease(SUNSET, SUNSET), NO_CHIP);
t("clicking elsewhere with nothing open stays shut",
  chipAfterRelease(NO_CHIP, NO_CHIP), NO_CHIP);
// A drag that began before a chip was opened must not undo the opening.
t("a release never undoes a chip opened during the same press",
  chipAfterRelease(SUNRISE, NO_CHIP), SUNRISE);

console.log(`  -> ${n - f}/${n} selection assertions passed`);
process.exit(f ? 1 : 0);
