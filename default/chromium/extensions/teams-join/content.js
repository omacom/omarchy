// Anchored at a path start so a meeting buried in another page's query cannot
// match. Classic keeps its settled tail (`[^#\s]+` after 19:/19%3a, no /0 or
// meeting_ requirement). Short is meet/<id> with optional ?query; a /extra tail
// stops the match at the id.
function meetingPath(str) {
  if (!str) return null;
  var m = str.match(/^\/(?:l\/meetup-join\/19(?::|%3[aA])[^#\s]+|meet\/[^\/?#\s]+(?:\?[^#\s]*)?)/);
  if (!m) return null;
  var raw = m[0], q = raw.indexOf("?");
  if (q < 0) return raw;
  // Keep only the meeting's own query (p=, context=). Everything else, including
  // unknown future launcher keys, is dropped (Requirement 11).
  var keep = /^(p|context)$/;
  var kept = raw.slice(q + 1).split("&").filter(function (x) { return keep.test(x.split("=")[0]); });
  return kept.length ? raw.slice(0, q) + "?" + kept.join("&") : raw.slice(0, q);
}
// omarchyWebapp as a query KEY in one already-decoded layer, not a substring of
// a path, id, or passcode. URL (not URLSearchParams) because the Node sandbox
// injects only URL.
function hasMarker(layer) {
  if (!layer) return false;
  var q = layer.indexOf("?");
  if (q < 0) return false;
  try { return new URL("https://x/?" + layer.slice(q + 1)).searchParams.has("omarchyWebapp"); }
  catch (e) { return false; }
}
var href = window.location.href;
// Origin- and time-independent guard: the web-app window the handler opens is a Chromium
// --app window, which reports standalone; a normal browser tab does not. Standing down here
// closes the cross-origin / >20s sign-in drift the per-origin latch and the 20s throttle can
// miss. Phase 3 confirms it distinguishes the two; marker + throttle stay as the proven
// fallback for any engine where it does not.
var standalone = false;
try { standalone = window.matchMedia("(display-mode: standalone)").matches; } catch (e) {}
var path = null;
var marker = false;
try {
  var u = new URL(href);
  // Page query, fragment query, and decoded url= (any page: a match can only stand
  // down, which the Security tie-break prefers). searchParams.get decodes one layer
  // so omarchyWebapp%3D1 inside url= still counts.
  marker = hasMarker(u.search) || hasMarker(u.hash) || hasMarker(u.searchParams.get("url") || "");
  if (u.pathname === "/dl/launcher/launcher.html") {
    var v = u.searchParams.get("url") || "";
    path = meetingPath(v) || meetingPath(v.slice(v.indexOf("#") + 1));
  }
  if (!path) path = meetingPath(u.pathname + u.search);
  if (!path && (u.pathname === "/v2/" || u.pathname === "/v2")) {
    path = meetingPath(u.hash.slice(1));
  }
} catch (e) {}
var target = path ? ("msteams://" + u.hostname + path) : null;
// Per-meeting latch (per origin per tab): key on the normalized meeting path so the same
// meeting via different encodings maps to one key. Firing OR standing down latches it, so a
// later same-origin hop for THIS meeting -- e.g. a launcher->/v2/ hop that drops the marker
// -- does not fire again, while a different meeting in the same tab still can (A3, A8).
var key = path ? ("teamsjoin:" + path.replace(/%3[aA]/g, ":").replace(/%40/g, "@").split("?")[0]) : null;
var done = false;
try { if (key) done = !!sessionStorage.getItem(key); } catch (e) {}
if (!done && key) {
  try { sessionStorage.setItem(key, "1"); } catch (e) {}
  if (!marker && !standalone) {
    window.location.href = target;
    try { window.stop(); } catch (e) {}  // halt the launcher's forward so the tab does not become the web join UI (A1)
  }
}
