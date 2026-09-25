import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import "Model.js" as Model

Item {
  id: root

  property var settings: ({})

  property bool installed: false
  property bool authenticated: false
  property bool tokenValid: false
  property bool refreshing: false
  property string statusText: "Checking…"
  property string email: ""
  property var accounts: []
  property string selectedAccountId: ""
  property var zones: []
  property var workers: []
  property string zonesError: ""
  property string workersError: ""
  property string actionStatus: ""
  property string lastError: ""

  // Worker detail view. `detailWorker` is the Worker on screen; the detail
  // properties below hold whichever Worker was loaded last (`_detailName`),
  // which is usually the same one: the panel prefetches the Worker under the
  // cursor, so opening it finds its data loaded or on the way. Loads are
  // cached briefly, so stepping back to the list and in again does not
  // refetch.
  property var detailWorker: null
  property var detailMetrics: ({})
  property string metricsError: ""
  property var detailVersions: []
  property var detailLive: ({})
  property string detailDeployedOn: ""
  property string detailSource: ""
  property string versionsError: ""
  property bool deploymentsLoaded: false
  // A load starts its calls a tick later; count that tick as loading so the
  // view never flashes its empty state in between.
  property bool _detailStarting: false
  readonly property bool metricsLoading: _detailStarting || usageProcess.running || errorsProcess.running
  readonly property bool versionsLoading: _detailStarting || versionsProcess.running || deploymentsProcess.running
  readonly property int detailCacheMs: 60000
  property var _detailCache: ({})
  property string _detailName: ""
  property real _detailLoadedAt: 0
  property int _detailGeneration: 0

  readonly property int refreshIntervalSec: intSetting("refreshIntervalSec", 300, 30, 3600)
  readonly property bool busy: whichProcess.running || whoamiProcess.running || loginProcess.running
  readonly property bool loadingResources: zonesProcess.running || workersProcess.running
  readonly property var selectedAccount: {
    for (var i = 0; i < accounts.length; i++) {
      if (accounts[i].id === selectedAccountId) return accounts[i]
    }
    return null
  }

  property string _whoamiOutput: ""
  property string _whoamiError: ""
  property string _zonesOutput: ""
  property string _zonesError: ""
  property string _workersOutput: ""
  property string _workersError: ""
  property string _loginOutput: ""
  property string _usageOutput: ""
  property string _errorsOutput: ""
  property string _versionsOutput: ""
  property string _versionsError: ""
  property string _deploymentsOutput: ""

  function setting(name, fallback) {
    var value = settings ? settings[name] : undefined
    return value === undefined || value === null ? fallback : value
  }

  function intSetting(name, fallback, min, max) {
    var n = parseInt(String(setting(name, fallback)), 10)
    if (!isFinite(n)) n = fallback
    if (n < min) n = min
    if (n > max) n = max
    return n
  }

  function elideStatus(text) {
    var value = Model.stripAnsi(text).replace(/\s+/g, " ").trim()
    return value.length > 140 ? value.substring(0, 137) + "…" : value
  }

  // cf is a Node CLI: plain JSON needs colors off, and NO_COLOR alone is
  // ignored while FORCE_COLOR is set. It reads the account for account-scoped
  // commands from CLOUDFLARE_ACCOUNT_ID, which is how the switcher scopes them.
  function cliEnvironment(accountId) {
    var env = { "NO_COLOR": "1", "FORCE_COLOR": null }
    if (accountId) env["CLOUDFLARE_ACCOUNT_ID"] = accountId
    return env
  }

  function refresh() {
    if (!installed) {
      if (!whichProcess.running) {
        refreshing = true
        whichProcess.command = ["which", "cf"]
        whichProcess.running = true
      }
      return
    }
    if (whoamiProcess.running) return
    _whoamiOutput = ""
    _whoamiError = ""
    refreshing = true
    whoamiProcess.command = ["cf", "auth", "whoami"]
    whoamiProcess.running = true
    pollWatchdog.restart()
  }

  // Zones and Workers load side by side once whoami has said who we are and
  // which accounts exist. Each keeps its last good list if its call fails.
  function refreshResources() {
    if (!authenticated || selectedAccountId === "") return
    var env = cliEnvironment(selectedAccountId)
    if (!zonesProcess.running) {
      _zonesOutput = ""
      _zonesError = ""
      zonesProcess.environment = env
      zonesProcess.command = ["cf", "zones", "list"]
      zonesProcess.running = true
    }
    if (!workersProcess.running) {
      _workersOutput = ""
      _workersError = ""
      workersProcess.environment = env
      workersProcess.command = ["cf", "workers", "list"]
      workersProcess.running = true
    }
    pollWatchdog.restart()
  }

  function applyWhoami(raw) {
    var parsed = Model.parseWhoami(raw)
    authenticated = parsed.authenticated
    tokenValid = parsed.tokenValid
    email = parsed.email
    accounts = parsed.accounts
    statusText = parsed.message
    lastError = parsed.ok ? "" : parsed.error

    if (!authenticated) {
      selectedAccountId = ""
      zones = []
      workers = []
      forgetWorkerDetail()
      return
    }
    if (selectedAccount === null) selectedAccountId = accounts.length > 0 ? accounts[0].id : ""
    refreshResources()
  }

  function resetSignedOut(message) {
    authenticated = false
    tokenValid = false
    email = ""
    accounts = []
    selectedAccountId = ""
    zones = []
    workers = []
    forgetWorkerDetail()
    statusText = message
  }

  function openWorkerDetail(worker) {
    if (!worker) return
    detailWorker = worker
    ensureWorkerDetail(worker)
  }

  // Loads a Worker in the background while its row has the cursor, so the
  // view is ready by the time it is opened. The view's own Worker wins: no
  // prefetching while one is open.
  function prefetchWorker(worker) {
    if (!worker || detailWorker) return
    ensureWorkerDetail(worker)
  }

  // Leaves a load that is still running or fresh alone, reuses a fresh
  // cached one, and otherwise starts over.
  function ensureWorkerDetail(worker) {
    var loading = metricsLoading || versionsLoading
    if (_detailName === worker.name && (loading || Date.now() - _detailLoadedAt < detailCacheMs)) return
    var cached = _detailCache[worker.name]
    if (cached && Date.now() - cached.at < detailCacheMs) {
      stopWorkerDetail()
      _detailStarting = false
      _detailName = worker.name
      applyDetailCache(cached)
      return
    }
    beginWorkerDetail(worker)
  }

  function beginWorkerDetail(worker) {
    _detailName = worker.name
    _detailLoadedAt = 0
    detailMetrics = ({})
    detailVersions = []
    detailLive = ({})
    detailDeployedOn = worker.deployedOn || ""
    detailSource = ""
    deploymentsLoaded = false
    metricsError = ""
    versionsError = ""
    loadWorkerDetail(worker)
  }

  function closeWorkerDetail() {
    detailWorker = null
  }

  // Bumping the generation makes any call still out for the previous Worker
  // drop its result instead of writing into the next one.
  function stopWorkerDetail() {
    _detailGeneration += 1
    var processes = [usageProcess, errorsProcess, versionsProcess, deploymentsProcess]
    for (var i = 0; i < processes.length; i++) if (processes[i].running) processes[i].running = false
  }

  // Another account, or none: nothing loaded so far applies any more.
  function forgetWorkerDetail() {
    stopWorkerDetail()
    _detailStarting = false
    detailWorker = null
    _detailCache = ({})
    _detailName = ""
  }

  function refreshWorkerDetail() {
    if (!detailWorker) return
    var cache = _detailCache
    delete cache[detailWorker.name]
    _detailCache = cache
    beginWorkerDetail(detailWorker)
  }

  function applyDetailCache(cached) {
    detailMetrics = cached.metrics
    detailVersions = cached.versions
    detailLive = cached.live
    detailDeployedOn = cached.deployedOn
    detailSource = cached.source
    deploymentsLoaded = true
    _detailLoadedAt = cached.at
    metricsError = cached.metricsError
    versionsError = cached.versionsError
  }

  function rememberDetail() {
    if (_detailName === "") return
    _detailLoadedAt = Date.now()
    var cache = _detailCache
    cache[_detailName] = {
      at: _detailLoadedAt,
      metrics: detailMetrics,
      versions: detailVersions,
      live: detailLive,
      deployedOn: detailDeployedOn,
      source: detailSource,
      metricsError: metricsError,
      versionsError: versionsError
    }
    _detailCache = cache
  }

  // Stops whatever is still loading for a previous Worker, then starts this
  // one's calls side by side on the next tick, once the stopped processes
  // have let go.
  function loadWorkerDetail(worker) {
    if (!worker) return
    // Each load gets a generation; a process only reports back if it was
    // started by the current one, so a stopped call for an earlier Worker
    // cannot write into this Worker's view.
    stopWorkerDetail()
    var generation = _detailGeneration
    var processes = [usageProcess, errorsProcess, versionsProcess, deploymentsProcess]
    _detailStarting = true

    Qt.callLater(function() {
      if (generation !== root._detailGeneration) return
      root._detailStarting = false
      for (var j = 0; j < processes.length; j++) processes[j].generation = generation
      var env = root.cliEnvironment(root.selectedAccountId)
      root._versionsOutput = ""
      root._versionsError = ""
      root._deploymentsOutput = ""
      versionsProcess.environment = env
      versionsProcess.command = ["cf", "workers", "versions", "list", "--worker-id", worker.name]
      versionsProcess.running = true
      deploymentsProcess.environment = env
      deploymentsProcess.command = ["cf", "workers", "deployments", "list", "--worker", worker.name]
      deploymentsProcess.running = true

      if (!worker.logsEnabled) {
        root.metricsError = "Turn on Workers Logs to see metrics"
        return
      }
      var to = Date.now()
      var from = to - 24 * 60 * 60 * 1000
      root._usageOutput = ""
      root._errorsOutput = ""
      usageProcess.environment = env
      usageProcess.command = ["cf", "observability", "telemetry", "query", "--body", Model.usageQuery(worker.name, from, to)]
      usageProcess.running = true
      errorsProcess.environment = env
      errorsProcess.command = ["cf", "observability", "telemetry", "query", "--body", Model.errorsQuery(worker.name, from, to)]
      errorsProcess.running = true
      detailWatchdog.restart()
    })
  }

  function applyMetrics(raw) {
    var parsed = Model.parseMetrics(raw)
    if (!parsed.ok) {
      metricsError = "Could not load metrics"
      return
    }
    var metrics = {}
    for (var key in detailMetrics) metrics[key] = detailMetrics[key]
    for (var alias in parsed.metrics) metrics[alias] = parsed.metrics[alias]
    detailMetrics = metrics
  }

  // Called from each call's exit handler, where the loading bindings have
  // not caught up with the process that just stopped; ask the processes.
  function detailProcessDone() {
    if (!usageProcess.running && !errorsProcess.running && !versionsProcess.running && !deploymentsProcess.running) rememberDetail()
  }

  function copyVersion(version) {
    if (version) copyToClipboard(version.id, "version " + version.shortId)
  }

  function selectAccount(id) {
    var accountId = String(id || "")
    if (accountId === "" || accountId === selectedAccountId) return
    forgetWorkerDetail()
    selectedAccountId = accountId
    zones = []
    workers = []
    zonesError = ""
    workersError = ""
    refreshResources()
  }

  // `cf auth login` opens the browser itself and waits for approval, so the
  // process can sit for minutes; the panel only reports that it is waiting.
  function login() {
    if (!installed || loginProcess.running) return
    _loginOutput = ""
    lastError = ""
    actionStatus = "Approve the sign-in in your browser…"
    loginProcess.command = ["cf", "auth", "login"]
    loginProcess.running = true
  }

  function openUrl(url) {
    if (String(url || "") !== "") Quickshell.execDetached(["omarchy-launch-webapp", url])
  }

  function openDashboard() {
    openUrl(Model.accountDashboardUrl(selectedAccountId))
  }

  function openZone(zone) {
    openUrl(Model.zoneDashboardUrl(selectedAccountId, zone))
  }

  function openWorker(worker) {
    openUrl(Model.workerDashboardUrl(selectedAccountId, worker))
  }

  function copyToClipboard(value, label) {
    var text = String(value || "")
    if (text === "") return
    Quickshell.execDetached(["bash", "-c", "printf %s " + Util.shellQuote(text) + " | wl-copy"])
    actionStatus = "Copied " + label
    actionStatusTimer.restart()
  }

  function copyZoneId(zone) {
    if (zone) copyToClipboard(zone.id, zone.name + " zone ID")
  }

  // A Worker without a public workers.dev route has nothing better to copy
  // than its name, which is what wrangler and cf take anyway.
  function copyWorker(worker) {
    if (!worker) return
    if (worker.url !== "") copyToClipboard(worker.url, worker.name + " URL")
    else copyToClipboard(worker.name, worker.name + " name")
  }

  Timer {
    id: refreshTimer
    interval: root.refreshIntervalSec * 1000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Timer {
    id: delayedRefresh
    interval: 600
    repeat: false
    onTriggered: root.refresh()
  }

  Timer {
    // Every call reaches the Cloudflare API, so a flaky network can leave one
    // hanging; reap it so the next refresh is not skipped forever. Every call
    // restarts it, so it only stops a call that has hung, never a fresh one
    // from a later refresh.
    id: pollWatchdog
    interval: 20000
    repeat: false
    onTriggered: {
      if (whoamiProcess.running) whoamiProcess.running = false
      if (zonesProcess.running) zonesProcess.running = false
      if (workersProcess.running) workersProcess.running = false
    }
  }

  Timer {
    // Log queries run on Cloudflare's side and can stall; give up on them
    // rather than leave the metrics section loading forever.
    id: detailWatchdog
    interval: 25000
    repeat: false
    onTriggered: {
      if (usageProcess.running || errorsProcess.running) root.metricsError = "Metrics took too long to load"
      if (usageProcess.running) usageProcess.running = false
      if (errorsProcess.running) errorsProcess.running = false
    }
  }

  Timer {
    id: actionStatusTimer
    interval: 2200
    repeat: false
    onTriggered: root.actionStatus = ""
  }

  Process {
    id: whichProcess
    running: false
    command: []
    onExited: function(exitCode) {
      root.installed = exitCode === 0
      if (root.installed) root.refresh()
      else {
        root.refreshing = false
        root.resetSignedOut("Not installed")
      }
    }
  }

  Process {
    id: whoamiProcess
    running: false
    command: []
    environment: root.cliEnvironment("")
    stdout: StdioCollector { id: whoamiStdout; waitForEnd: true; onStreamFinished: root._whoamiOutput = text }
    stderr: StdioCollector { id: whoamiStderr; waitForEnd: true; onStreamFinished: root._whoamiError = text }
    onExited: function(exitCode) {
      root.refreshing = false
      var stdout = String(whoamiStdout.text || root._whoamiOutput || "")
      var stderr = String(whoamiStderr.text || root._whoamiError || "")
      if (exitCode === 0) root.applyWhoami(stdout)
      else root.lastError = root.elideStatus(stderr || stdout || "Could not read Cloudflare status")
    }
  }

  Process {
    id: zonesProcess
    running: false
    command: []
    stdout: StdioCollector { id: zonesStdout; waitForEnd: true; onStreamFinished: root._zonesOutput = text }
    stderr: StdioCollector { id: zonesStderr; waitForEnd: true; onStreamFinished: root._zonesError = text }
    onExited: function(exitCode) {
      var stdout = String(zonesStdout.text || root._zonesOutput || "")
      var stderr = String(zonesStderr.text || root._zonesError || "")
      var parsed = exitCode === 0 ? Model.parseZones(stdout, root.selectedAccountId) : null
      if (parsed && parsed.ok) {
        root.zones = parsed.zones
        root.zonesError = ""
      } else {
        root.zonesError = root.elideStatus(stderr || "Could not list domains")
      }
    }
  }

  Process {
    id: workersProcess
    running: false
    command: []
    stdout: StdioCollector { id: workersStdout; waitForEnd: true; onStreamFinished: root._workersOutput = text }
    stderr: StdioCollector { id: workersStderr; waitForEnd: true; onStreamFinished: root._workersError = text }
    onExited: function(exitCode) {
      var stdout = String(workersStdout.text || root._workersOutput || "")
      var stderr = String(workersStderr.text || root._workersError || "")
      var parsed = exitCode === 0 ? Model.parseWorkers(stdout) : null
      if (parsed && parsed.ok) {
        root.workers = parsed.workers
        root.workersError = ""
      } else {
        root.workersError = root.elideStatus(stderr || "Could not list Workers")
      }
    }
  }

  Process {
    id: usageProcess
    property int generation: 0
    running: false
    command: []
    stdout: StdioCollector { id: usageStdout; waitForEnd: true; onStreamFinished: root._usageOutput = text }
    onExited: function(exitCode) {
      if (generation !== root._detailGeneration) return
      if (exitCode === 0) root.applyMetrics(String(usageStdout.text || root._usageOutput || ""))
      else if (root.metricsError === "") root.metricsError = "Could not load metrics"
      root.detailProcessDone()
    }
  }

  Process {
    id: errorsProcess
    property int generation: 0
    running: false
    command: []
    stdout: StdioCollector { id: errorsStdout; waitForEnd: true; onStreamFinished: root._errorsOutput = text }
    onExited: function(exitCode) {
      if (generation !== root._detailGeneration) return
      if (exitCode === 0) root.applyMetrics(String(errorsStdout.text || root._errorsOutput || ""))
      root.detailProcessDone()
    }
  }

  Process {
    id: versionsProcess
    property int generation: 0
    running: false
    command: []
    stdout: StdioCollector { id: versionsStdout; waitForEnd: true; onStreamFinished: root._versionsOutput = text }
    stderr: StdioCollector { id: versionsStderr; waitForEnd: true; onStreamFinished: root._versionsError = text }
    onExited: function(exitCode) {
      if (generation !== root._detailGeneration) return
      var parsed = exitCode === 0 ? Model.parseVersions(String(versionsStdout.text || root._versionsOutput || ""), 10) : null
      if (parsed && parsed.ok) {
        root.detailVersions = parsed.versions
        root.versionsError = ""
      } else {
        root.versionsError = root.elideStatus(String(versionsStderr.text || root._versionsError || "") || "Could not list versions")
      }
      root.detailProcessDone()
    }
  }

  Process {
    id: deploymentsProcess
    property int generation: 0
    running: false
    command: []
    stdout: StdioCollector { id: deploymentsStdout; waitForEnd: true; onStreamFinished: root._deploymentsOutput = text }
    onExited: function(exitCode) {
      if (generation !== root._detailGeneration) return
      if (exitCode === 0) {
        var parsed = Model.parseDeployments(String(deploymentsStdout.text || root._deploymentsOutput || ""))
        if (parsed.ok) {
          root.detailLive = parsed.live
          if (parsed.deployedOn !== "") root.detailDeployedOn = parsed.deployedOn
          root.detailSource = parsed.source
        }
      }
      root.deploymentsLoaded = true
      root.detailProcessDone()
    }
  }

  Process {
    id: loginProcess
    running: false
    command: []
    environment: root.cliEnvironment("")
    stdout: SplitParser { onRead: function(data) { root._loginOutput += String(data || "") + "\n" } }
    stderr: SplitParser { onRead: function(data) { root._loginOutput += String(data || "") + "\n" } }
    onExited: function(exitCode) {
      if (exitCode !== 0) {
        root.lastError = root.elideStatus(root._loginOutput || "Cloudflare sign-in failed")
        root.actionStatus = ""
      } else {
        root.actionStatus = "Signed in"
        actionStatusTimer.restart()
      }
      delayedRefresh.restart()
    }
  }
}
