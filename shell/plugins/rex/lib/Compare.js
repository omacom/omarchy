.pragma library

// Compares one flavor's matches with another's.
//
// A result is { ok, error, matches, stride, count }. compare() returns
// { verdict, detail, firstDifference } where verdict is "same", "groups"
// (the same matches with different groups), "different", or "error", and
// firstDifference is the index of the first match that differs, or -1.

function spans(result, i, groups) {
  var out = []
  for (var g = 0; g <= groups; g++) out.push(result.matches[i * result.stride + g * 2], result.matches[i * result.stride + g * 2 + 1])
  return out.join(",")
}

function compare(reference, other) {
  if (other.ok === false) return { verdict: "error", detail: other.error || "error", firstDifference: -1 }
  if (reference.ok === false) return { verdict: "different", detail: "matches where the reference fails", firstDifference: 0 }
  var count = Math.min(reference.count, other.count)
  var groups = Math.min(reference.stride, other.stride) / 2 - 1
  for (var i = 0; i < count; i++) {
    if (spans(reference, i, 0) !== spans(other, i, 0)) {
      return { verdict: "different", detail: "match " + (i + 1) + " differs: " + describe(other, i) + " instead of " + describe(reference, i), firstDifference: i }
    }
  }
  if (reference.count !== other.count) {
    return { verdict: "different", detail: other.count + " matches instead of " + reference.count, firstDifference: count }
  }
  if (reference.stride !== other.stride) {
    return { verdict: "groups", detail: (other.stride / 2 - 1) + " groups instead of " + (reference.stride / 2 - 1), firstDifference: -1 }
  }
  for (var j = 0; j < count; j++) {
    if (spans(reference, j, groups) !== spans(other, j, groups)) {
      return { verdict: "groups", detail: "the same matches, but match " + (j + 1) + "'s groups differ", firstDifference: j }
    }
  }
  return { verdict: "same", detail: "the same matches and groups", firstDifference: -1 }
}

function describe(result, i) {
  return result.matches[i * result.stride] + "–" + result.matches[i * result.stride + 1]
}

if (typeof module !== "undefined") module.exports = { compare: compare }
