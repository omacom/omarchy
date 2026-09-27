// Bending a line of text onto an arc: does it end up where it was asked to?
//
// The real line is around 300px of 6px monospace with a rise of a few pixels,
// so that is the regime the tight tolerances below use. `layout` sets the
// radius from the shallow-arc approximation R = w^2/8s, which loses accuracy
// as the bend deepens; the deep cases are checked for shape and sanity only.
const fs = require("fs"), path = require("path");
const src = fs.readFileSync(path.join(__dirname, "../../../shell/plugins/panels/elsewhen", "Arc.js"), "utf8").replace(".pragma library", "");
const A = {};
new Function(src + "; this.A={layout};").call(A);
const a = A.A;

let n = 0, f = 0;
const t = (k, ok, extra) => { n++; if (!ok) { f++; console.log("  FAIL", k, extra === undefined ? "" : extra); } };
const near = (x, y, eps) => Math.abs(x - y) <= (eps === undefined ? 0.01 : eps);

const mono = (count, w) => new Array(count).fill(w === undefined ? 6 : w);
const RISE = 6;

// --- a flat line is still a line -----------------------------------------
const flat = a.layout(mono(10), 0, true);
t("no rise, no height", flat.height === 0);
t("no rise, full width", flat.width === 60);
t("no rise, no rotation", flat.chars.every(c => c.rotation === 0));
t("no rise, laid out end to end", flat.chars.map(c => c.x).join() === "0,6,12,18,24,30,36,42,48,54");
t("empty text", a.layout([], 6, true).chars.length === 0);
t("negative rise is flat", a.layout(mono(4), -3, true).height === 0);

// --- the rise is the thing being asked for -------------------------------
// Sagitta of the arc the characters sit on, end box to middle box.
for (const count of [20, 30, 50, 90]) {
  const r = a.layout(mono(count), RISE, true);
  const ys = r.chars.map(c => c.y);
  const dip = Math.max(...ys) - (ys[0] + ys[ys.length - 1]) / 2;
  t("height is the rise at " + count + " chars", near(r.height, RISE, 0.05), r.height);
  // The end characters sit half a character in from the ends of the arc, so
  // the run of glyphs dips a little less than the full sagitta - the shorter
  // the line, the bigger a share of it that half character is.
  t("glyphs dip by about the rise at " + count, dip > RISE * 0.85 && dip <= RISE, dip);
}

// --- shape ----------------------------------------------------------------
const smile = a.layout(mono(30), RISE, true);
const frown = a.layout(mono(30), RISE, false);
t("smile dips in the middle", smile.chars[15].y > smile.chars[0].y);
t("frown rises in the middle", frown.chars[15].y < frown.chars[0].y);
t("smile and frown are mirrors",
  smile.chars.every((c, i) => near(c.y, smile.height - frown.chars[i].y)
                           && near(c.rotation, -frown.chars[i].rotation)
                           && near(c.x, frown.chars[i].x)));

t("symmetric heights", smile.chars.every((c, i) =>
  near(c.y, smile.chars[smile.chars.length - 1 - i].y)));
t("symmetric turns", smile.chars.every((c, i) =>
  near(c.rotation, -smile.chars[smile.chars.length - 1 - i].rotation)));
t("advances left to right", smile.chars.every((c, i) => i === 0 || c.x > smile.chars[i - 1].x));
t("starts at the left edge", near(smile.chars[0].x, 0));
// Qt turns clockwise for a positive angle, so the left arm of a smile leans
// down to the right and the right arm leans up.
t("leans into each end", smile.chars[0].rotation > 0 && smile.chars[29].rotation < 0);
t("the middle is level", near(smile.chars[14].rotation, -smile.chars[15].rotation));

// --- the characters follow the tangent, not just the height ---------------
// Each character's turn should match the slope of the line under it, or the
// glyphs sit on the arc without following it - a ransom note, not a curve.
for (let i = 1; i < smile.chars.length; i++) {
  const dy = smile.chars[i].y - smile.chars[i - 1].y;
  const dx = smile.chars[i].x - smile.chars[i - 1].x;
  const turn = (smile.chars[i].rotation + smile.chars[i - 1].rotation) / 2;
  t("tangent matches the climb at " + i, near(Math.atan2(dy, dx) * 180 / Math.PI, turn, 0.1));
}

// --- proportional text, not just monospace -------------------------------
// "Ill" against "WWW": wide characters must keep their room.
const prop = a.layout([4, 4, 4, 16, 16, 16].concat(mono(24)), RISE, true);
t("narrow advances stay narrow", near(prop.chars[1].x - prop.chars[0].x, 4, 0.1));
t("wide advances stay wide", near(prop.chars[4].x - prop.chars[3].x, 16, 0.1));

// --- the width is what has to be reserved --------------------------------
// The chord is shorter than the flat run, but the end boxes hang past it, so
// the reported width covers them: centring on it cannot clip the first glyph.
const wide = a.layout(mono(40), 20, true);
t("boxes are inside the reported width",
  wide.chars.every(c => c.x >= -0.001 && c.x + 6 <= wide.width + 0.001));
t("arc is narrower than the flat run", wide.width < 240, wide.width);
t("but only a little", wide.width > 230, wide.width);

// --- a rise the arc cannot take ------------------------------------------
const absurd = a.layout(mono(10), 1000, true);
t("absurd rise is clamped, not NaN", isFinite(absurd.height) && absurd.height <= 15.01, absurd.height);
t("absurd rise still lays out every character", absurd.chars.length === 10
  && absurd.chars.every(c => isFinite(c.x) && isFinite(c.y) && isFinite(c.rotation)));

console.log((f ? "FAIL " : "ok ") + (n - f) + "/" + n + " arc");
process.exit(f ? 1 : 0);
