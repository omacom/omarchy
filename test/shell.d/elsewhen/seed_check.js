// The list a fresh install starts with: the city you are in, plus four
// well-known places spread round the clock from it.
//
// The point of these is that the four are chosen *relative to home*. A fixed
// list would hand someone in Paris a second Paris, and would give a reader in
// Tokyo a spread that is really a spread around California - so every check
// below is run from several different home cities.
const fs = require("fs"), path = require("path"), cp = require("child_process");
const src = fs.readFileSync(path.join(__dirname, "../../../shell/plugins/panels/elsewhen", "Model.js"), "utf8")
  .replace(".pragma library", "");
const box = {};
new Function(src + "; this.M={seedZones,pickSeedZones,seedCandidateZones,SEED_CANDIDATES,parseZones,serializeZones,labelForZoneId};").call(box);
const M = box.M;

let n = 0, f = 0;
const t = (k, cond, detail) => { n++; if (!cond) { f++; console.log("  FAIL", k, detail === undefined ? "" : detail); } };

// Real offsets, so the checks account for whatever DST is in force today.
const offsets = {};
const zoneOffset = z => {
  const o = cp.execSync(`TZ=${z} date +%z`).toString().trim();
  return (o[0] === "-" ? -1 : 1) * (parseInt(o.slice(1, 3), 10) * 60 + parseInt(o.slice(3, 5), 10));
};
const HOMES = [
  "America/Los_Angeles", "America/New_York", "Europe/London", "Europe/Paris",
  "Europe/Copenhagen", "Asia/Tokyo", "Asia/Kolkata", "Australia/Sydney",
  "America/Sao_Paulo", "Africa/Nairobi", "Pacific/Honolulu", "Pacific/Auckland",
  "Atlantic/Reykjavik", "Asia/Kathmandu", "UTC",
];
for (const z of new Set(M.seedCandidateZones().concat(HOMES))) offsets[z] = zoneOffset(z);

const dial = (a, b) => { const d = Math.abs(a - b) % 1440; return Math.min(d, 1440 - d); };

// An unset setting is a fresh install, not the old hardcoded trio.
t("blank setting yields no cities", M.parseZones("").length === 0);
t("blank setting is what triggers seeding", M.parseZones(undefined).length === 0);

for (const home of HOMES) {
  const label = M.labelForZoneId(home);
  const list = M.seedZones({ label: label, id: home }, offsets, 4);
  const name = `[${label}]`;

  t(`${name} five cities`, list.length === 5, list.length);
  t(`${name} home comes first`, list[0] && list[0].id === home);

  const ids = list.map(z => z.id);
  t(`${name} no repeated zone`, new Set(ids).size === ids.length, ids);
  const labels = list.map(z => String(z.label).toLowerCase());
  t(`${name} no repeated name`, new Set(labels).size === labels.length, labels);
  t(`${name} home is not also a destination`,
    ids.slice(1).every(id => id !== home));

  // Every pick must be a real separation from home and from the others -
  // otherwise the list is five clocks showing nearly the same time.
  const offs = list.map(z => offsets[z.id]);
  t(`${name} destinations differ from home by 3h or more`,
    offs.slice(1).every(o => dial(o, offs[0]) >= 180),
    offs.slice(1).map(o => (dial(o, offs[0]) / 60).toFixed(1)));
  let closest = 1e9;
  for (let i = 1; i < offs.length; i++)
    for (let j = i + 1; j < offs.length; j++)
      closest = Math.min(closest, dial(offs[i], offs[j]));
  t(`${name} destinations differ from each other by 3h or more`,
    closest >= 180, (closest / 60).toFixed(1) + "h");

  // Reading order: eastward from home, so the list walks round the world.
  const east = offs.map(o => ((o - offs[0]) % 1440 + 1440) % 1440);
  t(`${name} sorted eastward`,
    east.slice(1).every((e, i) => i === 0 || e >= east[i]), east.map(e => (e / 60).toFixed(1)));

  // The four should be places people have heard of.
  const known = new Set(M.SEED_CANDIDATES.map(c => c.label));
  t(`${name} destinations come from the curated list`,
    list.slice(1).every(z => known.has(z.label)));

  // It must survive a round trip through the settings string.
  const round = M.parseZones(M.serializeZones(list));
  t(`${name} round trips through settings`,
    round.length === 5 && round.every((z, i) => z.id === list[i].id));
}

// Missing home offset must not produce a broken list.
t("unknown home zone yields nothing",
  M.seedZones({ label: "Nowhere", id: "Not/AZone" }, offsets, 4).length === 1);
t("no offsets at all yields nothing",
  M.pickSeedZones({ label: "X", id: "UTC" }, {}, 4).length === 0);

console.log(`  -> ${n - f}/${n} first-run seed assertions passed`);
if (f) process.exitCode = 1;
