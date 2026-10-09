import QtQuick
import Quickshell
import Quickshell.Io
import "lib/Flavors.js" as Flavors
import "lib/Indices.js" as Indices

// Runs patterns on whichever engine a flavor names, off the UI thread, and
// reports every reply through `result`; callers keep the ids `match`
// returned and pick out their own.
//
// Qt's own JavaScript engine runs in a WorkerScript. Every other engine runs
// in a long-lived worker process (bin/omarchy-rex-worker), started on first
// use and kept warm, spoken to in JSON lines. The test text is sent to a
// worker once and referred to by id afterwards. A worker that does not
// answer in time is killed, which is how a catastrophically backtracking
// pattern is stopped; it is started again on the next request.
//
// Requests travel on channels ("main" for the workbench, others for the
// comparison, benchmarks, and unit tests), and each channel has its own
// workers, so a comparison never waits behind the workbench. On a channel,
// a new request supersedes the one before it unless the request says
// `keep`, which queues it instead.
//
// A reply: { id, ok, done, error, kind, matches, stride, elapsed, names }
// where matches is flat, stride numbers per match: [start, end] for the
// whole match and then each group, in UTF-16 offsets into the text, -1 for
// a group that did not take part.
Item {
  id: root

  signal result(var reply)

  property int lastId: 0
  // Flavors whose engines are installed, filled in from omarchy-rex-worker.
  property var installed: ({ ecmascript: true })
  property bool detected: false
  // How long a worker may stay silent before it is stopped: longer for
  // larger texts, which a fast engine still takes a while to get through.
  property int baseTimeoutMs: 5000
  property int textLength: 0
  readonly property int timeoutMs: baseTimeoutMs + Math.round(textLength / 1000000 * 3000)
  // How long a compiled worker may take to build on first use.
  property int buildTimeoutMs: 300000
  // A worker silent this long on a request that has since been superseded
  // is restarted instead of waited for.
  property int stuckMs: 400

  property var workers: ({})
  property var scripts: ({})

  function supports(flavorId) {
    return installed[flavorId] === true
  }

  // request: { flavor, pattern, flags, text, textPath, textVersion, all,
  // limit, parsed, channel, keep }. textPath names the file the text was
  // read from, which a worker then reads itself instead of receiving it.
  function match(request) {
    var id = ++lastId
    var channel = request.channel || "main"
    textLength = request.text.length
    var flavor = Flavors.byId(request.flavor)
    if (!supports(flavor.id)) {
      Qt.callLater(function() { root.result({ id: id, ok: false, done: true, error: flavor.name + " is not installed", matches: [], stride: 2, elapsed: 0 }) })
      return id
    }
    if (flavor.worker === "") {
      script(channel).send(id, request)
      return id
    }
    worker(flavor.worker, channel).send({
      op: "match",
      id: id,
      flavor: flavor.id,
      pattern: request.pattern,
      flags: request.flags,
      groups: request.parsed ? request.parsed.groupCount : 0,
      all: request.all,
      limit: request.limit,
      keep: request.keep === true,
    }, request.text, request.textVersion, request.textPath || "")
    return id
  }

  function worker(name, channel) {
    var key = name + "/" + channel
    if (!workers[key]) {
      var next = {}
      for (var k in workers) next[k] = workers[k]
      next[key] = workerComponent.createObject(root, { name: name })
      workers = next
    }
    return workers[key]
  }

  function script(channel) {
    if (!scripts[channel]) {
      var next = {}
      for (var k in scripts) next[k] = scripts[k]
      next[channel] = scriptComponent.createObject(root)
      scripts = next
    }
    return scripts[channel]
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

  // ---- Qt's own engine ----------------------------------------------------

  Component {
    id: scriptComponent

    Item {
      id: channelScript

      property int version: -1
      // Kept requests waiting while another runs.
      property var queue: []
      property int running: 0

      function send(id, request) {
        var parsed = request.parsed
        var rewritten = parsed && parsed.errors.length === 0
          ? Indices.rewrite(request.pattern, parsed)
          : { source: request.pattern, plan: [] }
        var message = {
          op: "match",
          id: id,
          source: rewritten.source,
          plan: rewritten.plan,
          groups: parsed ? parsed.groupCount : 0,
          flags: request.flags,
          all: request.all,
          limit: request.limit,
          version: request.textVersion,
          text: request.text,
        }
        if (request.keep && running !== 0) {
          queue = queue.concat([message])
          return
        }
        queue = []
        start(message)
      }

      function start(message) {
        running = message.id
        // Copying a large text into the worker costs the UI thread, so it
        // only goes over when it changed.
        if (version === message.version) delete message.text
        version = message.version
        js.sendMessage(message)
      }

      WorkerScript {
        id: js
        source: "workers/ecmascript.js"
        onMessage: function(reply) {
          if (reply.id !== channelScript.running) return
          root.result(reply)
          if (!reply.done) {
            js.sendMessage({ op: "continue", id: reply.id })
            return
          }
          channelScript.running = 0
          if (channelScript.queue.length) {
            var next = channelScript.queue[0]
            channelScript.queue = channelScript.queue.slice(1)
            channelScript.start(next)
          }
        }
      }
    }
  }

  // ---- worker processes -----------------------------------------------------

  Component {
    id: workerComponent

    Item {
      id: worker

      property string name: ""
      // The text the process holds, by version.
      property int textVersion: -1
      // Requests sent and not yet answered in full, oldest first. A request
      // that is not kept drops the ones before it.
      property var inflight: []
      // Writes before the process has started would be lost; they wait
      // here until onStarted.
      property var outbox: []
      property bool started: false
      // When the process last said anything, and whether it is being
      // restarted on purpose.
      property real lastHeard: 0
      property bool restarting: false

      function send(request, text, version, path) {
        var item = { id: request.id, request: request, text: text, version: version, path: path }
        // A superseded request the process has been silent on for a while is
        // probably stuck backtracking; start afresh rather than wait for the
        // watchdog, so fixing a runaway pattern takes effect at once.
        var stuck = !request.keep && inflight.length > 0 && started && Date.now() - lastHeard > root.stuckMs
        inflight = request.keep ? inflight.concat([item]) : [item]
        if (stuck) {
          restarting = true
          outbox = [item]
          proc.running = false
          return
        }
        if (!proc.running) {
          textVersion = -1
          outbox = [item]
          proc.running = true
          watchdog.interval = root.timeoutMs
          watchdog.restart()
          return
        }
        if (!started) {
          outbox = request.keep ? outbox.concat([item]) : [item]
          return
        }
        write(item)
      }

      function write(item) {
        var payload = {}
        for (var key in item.request) payload[key] = item.request[key]
        payload.textId = item.version
        if (textVersion !== item.version) {
          if (item.path !== "") payload.textPath = item.path
          else payload.text = item.text
          textVersion = item.version
        }
        proc.write(JSON.stringify(payload) + "\n")
        if (inflight.length === 1) lastHeard = Date.now()
        if (!watchdog.running) {
          watchdog.interval = root.timeoutMs
          watchdog.restart()
        }
      }

      function find(id) {
        for (var i = 0; i < inflight.length; i++) if (inflight[i].id === id) return inflight[i]
        return null
      }

      function finish(id) {
        inflight = inflight.filter(function(item) { return item.id !== id })
        if (inflight.length === 0) watchdog.stop()
      }

      function handle(line) {
        var reply
        try { reply = JSON.parse(line) } catch (e) { return }
        lastHeard = Date.now()
        // A compiled worker builds itself on first use, which can take a
        // while; say so instead of timing out.
        if (reply.building !== undefined) {
          watchdog.interval = root.buildTimeoutMs
          watchdog.restart()
          for (var b = 0; b < inflight.length; b++)
            root.result({ id: inflight[b].id, ok: true, done: false, building: reply.building, matches: [], stride: 2, elapsed: 0 })
          return
        }
        if (reply.buildError !== undefined) {
          var failed = inflight
          inflight = []
          watchdog.stop()
          for (var f = 0; f < failed.length; f++)
            root.result({ id: failed[f].id, ok: false, done: true, kind: "build", error: reply.buildError, matches: [], stride: 2, elapsed: 0 })
          return
        }
        watchdog.interval = root.timeoutMs
        if (inflight.length) watchdog.restart()
        var current = find(reply.id)
        if (!current) return
        if (reply.error === "missing-text") {
          textVersion = -1
          write(current)
          return
        }
        if (reply.done) finish(reply.id)
        root.result(reply)
      }

      Timer {
        id: watchdog
        interval: root.timeoutMs
        onTriggered: {
          var stopped = worker.inflight
          if (!stopped.length) return
          worker.inflight = []
          proc.running = false
          worker.textVersion = -1
          for (var i = 0; i < stopped.length; i++) {
            root.result({
              id: stopped[i].id,
              ok: false,
              done: true,
              kind: "timeout",
              error: "Stopped after " + Math.round(watchdog.interval / 1000) + " seconds without finishing. The pattern may be backtracking catastrophically on this text.",
              matches: [],
              stride: 2,
              elapsed: watchdog.interval,
            })
          }
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
          var pending = worker.outbox
          worker.outbox = []
          for (var i = 0; i < pending.length; i++) worker.write(pending[i])
        }
        onExited: {
          worker.started = false
          worker.textVersion = -1
          if (worker.restarting) {
            worker.restarting = false
            proc.running = true
            return
          }
          var lost = worker.inflight
          worker.inflight = []
          worker.outbox = []
          watchdog.stop()
          for (var i = 0; i < lost.length; i++)
            root.result({ id: lost[i].id, ok: false, done: true, error: "The " + worker.name + " worker stopped unexpectedly", matches: [], stride: 2, elapsed: 0 })
        }
      }
    }
  }
}
