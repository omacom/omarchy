import QtQuick
import Quickshell
import Quickshell.Io
import "lib/Flavors.js" as Flavors
import "lib/Indices.js" as Indices

// Runs patterns on whichever engine a flavor names, off the UI thread, and
// reports results through `result`. Only the newest request is pursued: an
// older one still running is abandoned between slices.
//
// Qt's own JavaScript engine runs in a WorkerScript. Every other engine runs
// in a long-lived worker process (bin/omarchy-rex-worker), started on first
// use and kept warm, spoken to in JSON lines. The test text is sent to a
// worker once and referred to by id afterwards. A worker that does not
// answer in time is killed, which is how a catastrophically backtracking
// pattern is stopped; it is started again on the next request.
//
// A result: { id, ok, done, error, kind, matches, stride, elapsed, names }
// where matches is flat, stride numbers per match: [start, end] for the
// whole match and then each group, in UTF-16 offsets into the text, -1 for
// a group that did not take part.
Item {
  id: root

  signal result(var reply)

  property int lastId: 0
  // Flavors whose engines are installed, filled in by `detect`.
  property var installed: ({ ecmascript: true })
  property bool detected: false
  // How long a worker may stay silent before it is stopped.
  property int timeoutMs: 5000
  // How long a compiled worker may take to build on first use.
  property int buildTimeoutMs: 300000

  property var workers: ({})

  function supports(flavorId) {
    return installed[flavorId] === true
  }

  // request: { flavor, pattern, flags, text, textVersion, all, limit, parsed }
  function match(request) {
    var id = ++lastId
    var flavor = Flavors.byId(request.flavor)
    if (!supports(flavor.id)) {
      root.result({ id: id, ok: false, done: true, error: flavor.name + " is not installed", matches: [], stride: 2, elapsed: 0 })
      return id
    }
    if (flavor.worker === "") {
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
      return id
    }
    worker(flavor.worker).send({
      op: "match",
      id: id,
      flavor: flavor.id,
      pattern: request.pattern,
      flags: request.flags,
      groups: request.parsed ? request.parsed.groupCount : 0,
      all: request.all,
      limit: request.limit,
    }, request.text, request.textVersion)
    return id
  }

  function worker(name) {
    if (!workers[name]) {
      var next = {}
      for (var key in workers) next[key] = workers[key]
      next[name] = workerComponent.createObject(root, { name: name })
      workers = next
    }
    return workers[name]
  }

  function deliver(reply) {
    if (reply.id !== root.lastId) return
    root.result(reply)
  }

  Component.onCompleted: flavorProc.running = true

  Process {
    id: flavorProc
    command: ["omarchy-rex-worker", "--flavors"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var next = { ecmascript: true }
        var lines = text.split("\n")
        for (var i = 0; i < lines.length; i++) if (lines[i] !== "") next[lines[i]] = true
        root.installed = next
        root.detected = true
      }
    }
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

  Component {
    id: workerComponent

    Item {
      id: worker

      property string name: ""
      // The text the process holds, by version, and the request in flight.
      property int textVersion: -1
      property var current: null
      property string currentText: ""
      property int currentVersion: -1
      // Writes before the process has started would be lost; the request
      // goes out from onStarted instead.
      property bool started: false

      function send(request, text, version) {
        current = request
        currentText = text
        currentVersion = version
        if (!proc.running) {
          textVersion = -1
          proc.running = true
          watchdog.restart()
          return
        }
        if (started) write(request)
      }

      function write(request) {
        var payload = {}
        for (var key in request) payload[key] = request[key]
        payload.textId = currentVersion
        if (textVersion !== currentVersion) {
          payload.text = currentText
          textVersion = currentVersion
        }
        proc.write(JSON.stringify(payload) + "\n")
        watchdog.restart()
      }

      function handle(line) {
        var reply
        try { reply = JSON.parse(line) } catch (e) { return }
        // A compiled worker builds itself on first use, which can take a
        // while; say so instead of timing out.
        if (reply.building !== undefined) {
          watchdog.interval = root.buildTimeoutMs
          watchdog.restart()
          if (current) root.deliver({ id: current.id, ok: true, done: false, building: reply.building, matches: [], stride: 2, elapsed: 0 })
          return
        }
        if (reply.buildError !== undefined) {
          if (current) {
            var failed = current
            current = null
            watchdog.stop()
            root.deliver({ id: failed.id, ok: false, done: true, kind: "build", error: reply.buildError, matches: [], stride: 2, elapsed: 0 })
          }
          return
        }
        watchdog.interval = root.timeoutMs
        if (!current || reply.id !== current.id) return
        if (reply.error === "missing-text") {
          textVersion = -1
          write(current)
          return
        }
        if (reply.done) {
          watchdog.stop()
          current = null
          currentText = ""
        } else {
          watchdog.restart()
        }
        root.deliver(reply)
      }

      Timer {
        id: watchdog
        interval: root.timeoutMs
        onTriggered: {
          if (!worker.current) return
          var stopped = worker.current
          worker.current = null
          worker.currentText = ""
          proc.running = false
          worker.textVersion = -1
          root.deliver({
            id: stopped.id,
            ok: false,
            done: true,
            kind: "timeout",
            error: "Stopped after " + (root.timeoutMs / 1000) + " seconds without finishing. The pattern may be backtracking catastrophically on this text.",
            matches: [],
            stride: 2,
            elapsed: root.timeoutMs,
          })
        }
      }

      Process {
        id: proc
        command: ["setpriv", "--pdeathsig", "TERM", "omarchy-rex-worker", worker.name]
        stdinEnabled: true
        stdout: SplitParser {
          onRead: function(line) { worker.handle(line) }
        }
        onStarted: {
          worker.started = true
          if (worker.current) worker.write(worker.current)
        }
        onExited: {
          worker.started = false
          worker.textVersion = -1
          if (!worker.current) return
          var lost = worker.current
          worker.current = null
          watchdog.stop()
          root.deliver({ id: lost.id, ok: false, done: true, error: "The " + worker.name + " worker stopped unexpectedly", matches: [], stride: 2, elapsed: 0 })
        }
      }
    }
  }
}
