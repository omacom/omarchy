.pragma library

// Unit tests for a pattern: a text and what the pattern must do with it.
//   { text, expect, group, value }
// expect: "match" (somewhere in the text), "nomatch", "full" (the first
// match covers the whole text), or "group" (in the first match, group
// `group`, a number or a name, matched exactly `value`).

var KINDS = [
  { value: "match", label: "matches" },
  { value: "nomatch", label: "does not match" },
  { value: "full", label: "matches all of it" },
  { value: "group", label: "captures" },
]

function normalize(test) {
  var t = test || {}
  var expect = ["match", "nomatch", "full", "group"].indexOf(t.expect) >= 0 ? t.expect : "match"
  return {
    text: typeof t.text === "string" ? t.text : "",
    expect: expect,
    group: t.group === undefined || t.group === null || t.group === "" ? "1" : String(t.group),
    value: typeof t.value === "string" ? t.value : "",
  }
}

// Whether a reply from the engine (first match only is needed) passes.
// Returns { pass, detail }.
function evaluate(test, reply, names) {
  if (reply.ok === false) return { pass: false, detail: reply.error || "the engine failed" }
  var count = reply.matches.length / reply.stride
  var start = count ? reply.matches[0] : -1, end = count ? reply.matches[1] : -1
  switch (test.expect) {
  case "match":
    return count ? { pass: true, detail: "matches at " + start + "–" + end } : { pass: false, detail: "no match" }
  case "nomatch":
    return count ? { pass: false, detail: "matches " + JSON.stringify(test.text.substring(start, end)) + " at " + start } : { pass: true, detail: "no match" }
  case "full":
    if (!count) return { pass: false, detail: "no match" }
    return start === 0 && end === test.text.length
      ? { pass: true, detail: "matches all of it" }
      : { pass: false, detail: "the first match is " + JSON.stringify(test.text.substring(start, end)) + " at " + start + "–" + end }
  case "group":
    if (!count) return { pass: false, detail: "no match" }
    var index = /^\d+$/.test(test.group) ? parseInt(test.group, 10) : (names || {})[test.group]
    if (index === undefined) return { pass: false, detail: "there is no group " + test.group }
    if (index * 2 >= reply.stride) return { pass: false, detail: "there is no group " + test.group }
    var gs = reply.matches[index * 2], ge = reply.matches[index * 2 + 1]
    if (gs < 0) return { pass: false, detail: "group " + test.group + " did not take part" }
    var got = test.text.substring(gs, ge)
    return got === test.value
      ? { pass: true, detail: "group " + test.group + " is " + JSON.stringify(got) }
      : { pass: false, detail: "group " + test.group + " is " + JSON.stringify(got) + ", not " + JSON.stringify(test.value) }
  }
  return { pass: false, detail: "unknown test" }
}

function describe(test) {
  var kind = KINDS.filter(function(k) { return k.value === test.expect })[0]
  if (test.expect === "group") return "group " + test.group + " captures " + JSON.stringify(test.value)
  return kind ? kind.label : test.expect
}

if (typeof module !== "undefined") module.exports = { KINDS: KINDS, normalize: normalize, evaluate: evaluate, describe: describe }
