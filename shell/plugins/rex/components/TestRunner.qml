import QtQuick
import "../lib/Parser.js" as Parser
import "../lib/Tests.js" as Tests

// Runs patterns against unit tests on the real engine and calls back with
// one { pass, detail } per test. Runs are named by a token: a new run with
// the same token replaces one that has not finished.
Item {
  id: root

  property var engine
  property string channel: "tests"

  // token -> run, and request id -> [token, test index]
  property var runs: ({})
  property var byId: ({})
  property int counter: 0

  function run(token, pattern, flavor, flags, tests, done) {
    var current = { results: tests.map(function() { return null }), left: tests.length, done: done, tests: tests, serial: ++counter }
    runs[token] = current
    if (!tests.length || pattern === "") { done(current.results); return }
    var parsed = Parser.parse(pattern, flavor, flags)
    current.names = parsed.names
    for (var i = 0; i < tests.length; i++) {
      var id = engine.match({
        flavor: flavor,
        pattern: pattern,
        flags: flags,
        text: tests[i].text,
        // Every test text is its own text, sent along with the request.
        textVersion: 3000000 + (counter % 1000) * 1000 + i,
        all: false,
        limit: 1,
        parsed: parsed,
        channel: channel,
        keep: true,
      })
      byId[id] = { token: token, index: i, serial: current.serial }
    }
  }

  Connections {
    target: root.engine
    function onResult(reply) {
      var where = root.byId[reply.id]
      if (!where || !reply.done) return
      delete root.byId[reply.id]
      var current = root.runs[where.token]
      if (!current || current.serial !== where.serial) return
      var names = reply.names && Object.keys(reply.names).length ? reply.names : current.names
      current.results[where.index] = Tests.evaluate(current.tests[where.index], reply, names)
      if (--current.left === 0) current.done(current.results.slice())
    }
  }
}
