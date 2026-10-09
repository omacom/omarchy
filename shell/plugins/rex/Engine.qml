import QtQuick
import "lib/Indices.js" as Indices

// Runs patterns on whichever engine a flavor names, off the UI thread, and
// reports results through `result`. Only the newest request is pursued: an
// older one still running is abandoned at its next slice.
//
// A result: { id, ok, done, error, matches, stride, count, elapsed, progress }
// where matches is flat, stride numbers per match: [start, end] for the
// whole match and then each group, in UTF-16 offsets into the text, -1 for
// a group that did not take part.
Item {
  id: root

  signal result(var reply)

  property int lastId: 0

  // Flavors this engine can run right now.
  function supports(flavorId) {
    return flavorId === "ecmascript"
  }

  // request: { flavor, pattern, flags, text, all, limit, parsed }
  function match(request) {
    var id = ++lastId
    if (request.flavor === "ecmascript") {
      var parsed = request.parsed
      var rewritten = parsed && parsed.errors.length === 0
        ? Indices.rewrite(request.pattern, parsed)
        : { source: request.pattern, plan: [] }
      ecmascript.sendMessage({
        op: "match",
        id: id,
        source: rewritten.source,
        plan: rewritten.plan,
        groups: parsed ? parsed.groupCount : 0,
        flags: request.flags,
        text: request.text,
        all: request.all,
        limit: request.limit,
      })
    } else {
      root.result({ id: id, ok: false, done: true, error: "No engine for " + request.flavor, matches: [], stride: 2, count: 0, elapsed: 0 })
    }
    return id
  }

  WorkerScript {
    id: ecmascript
    source: "workers/ecmascript.js"
    onMessage: function(reply) {
      if (reply.id !== root.lastId) return
      root.result(reply)
      if (!reply.done) ecmascript.sendMessage({ op: "continue", id: reply.id })
    }
  }
}
