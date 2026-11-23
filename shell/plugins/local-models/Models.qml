import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

// The plugin's service, one for the whole shell: everything the panel shows,
// followed from the files omarchy-models
// writes under ~/.local/state/omarchy/agent-local/: this machine's models, the
// catalog's recipes, and the models other machines share on the tailnet. The
// commands that set models up and pair with them run from here too, so they
// carry on while the panel is closed.
Item {
  id: root
  visible: false

  property var shell: null

  readonly property string home: Quickshell.env("HOME") || ""

  // The states the engine writes a model in; a file with any other is half written.
  readonly property var units: ["installing", "active", "activating", "inactive", "failed", "deactivating", "removing"]

  // What omarchy-models runs here, followed even before the panel's
  // content has been built.
  property var localModel: ({})

  FileView {
    id: localModelFile
    path: root.home + "/.local/state/omarchy/agent-local/status.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.parseLocalModel(text())
  }

  // The catalog's recipes as this machine sees them (fits, best, installed),
  // which the panel's + offers from, and whether the startup refresh has
  // written them yet: until then, no machine can be told it runs no model.
  property var localRecipes: []
  property bool listed: false

  FileView {
    id: localRecipesFile
    path: root.home + "/.local/state/omarchy/agent-local/list.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      try {
        var parsed = JSON.parse(text())
        if (Array.isArray(parsed)) root.localRecipes = parsed
      } catch (e) {
        // A half-written listing keeps the last good one.
      }
    }
  }

  // Rewrites the listing and status, which a package upgrade may have
  // changed. On a fresh account neither file exists until this first run, and
  // a missing file can't be watched, so both are loaded once it finishes.
  function refreshLocal() {
    if (!localRefresh.running) localRefresh.running = true
  }

  Process {
    id: localRefresh
    command: ["omarchy-models", "refresh", "--quiet"]
    onExited: {
      localRecipesFile.reload()
      localModelFile.reload()
      root.listed = true
    }
  }

  // Models other machines share on the tailnet, as omarchy-models
  // network last surveyed them: running, stopped, or offline with the host
  // away. The survey runs while the panel is open; this only follows its file.
  property var networkModels: ({})
  // The last survey's models, but for when each was last seen, which every
  // survey moves on: an unchanged tailnet leaves the panel's lines alone.
  property string networkKey: ""
  // Whether this machine can share its own models: Tailscale running with
  // MagicDNS and HTTPS certificates, as the last survey found it.
  property bool canShare: false

  FileView {
    id: networkFile
    path: root.home + "/.local/state/omarchy/agent-local/network.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.parseNetwork(text())
  }

  // How many machines use each shared model, as omarchy-models's share
  // proxy counts them: those whose request it served in the last five
  // minutes. The proxy rewrites the file only when a count changes.
  property var shareClients: ({})

  FileView {
    id: clientsFile
    path: root.home + "/.local/state/omarchy/agent-local/clients.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.shareClients = root.parseClients(text())
    // No proxy running, so nobody is using anything.
    onLoadFailed: root.shareClients = ({})
  }

  function parseClients(content) {
    try {
      var models = JSON.parse(content).models
      var counts = {}
      if (models && typeof models === "object" && !Array.isArray(models))
        for (var id in models)
          if (Number.isInteger(models[id]) && models[id] > 0) counts[id] = models[id]
      return counts
    } catch (e) {
      return {}
    }
  }

  function refreshNetwork() {
    if (!networkRefresh.running) networkRefresh.running = true
  }

  Process {
    id: networkRefresh
    command: ["omarchy-models", "network", "--write"]
    // A first survey creates the file, which can't be watched before it exists.
    onExited: networkFile.reload()
  }

  // Pairing with a model another machine shares runs here, not in a terminal,
  // so the panel stays open on it: with no terminal, omarchy-models pair
  // trusts a host met for the first time and asks nothing, so it pairs or
  // fails with a reason. One at a time; the model being paired, while it runs.
  property string pairingId: ""
  // A pairing that failed, by model: the reason's first line, which the
  // model's line shows, and all that pair printed, which that line opens.
  // Kept until the model is paired again or the shell restarts.
  property var pairFailures: ({})

  // Forgotten once its output has been read, or when pairing is tried again.
  function dismissPairFailure(id) {
    if (!pairFailures[id]) return
    var failures = Object.assign({}, pairFailures)
    delete failures[id]
    pairFailures = failures
  }

  function pair(model) {
    if (pairProcess.running) return
    var id = model.host + "/" + model.recipe
    dismissPairFailure(id)
    pairingId = id
    // A host already paired for another model is found by its tailnet name
    // too, and connects this one with no SSH.
    pairProcess.command = ["bash", "-c", "exec omarchy-models pair \"$1\" \"$2\" 2>&1", "pair", String(model.dns || model.host), String(model.recipe)]
    pairProcess.running = true
  }

  // The reason omarchy-models gives, which it prints as "Error: " and
  // a first line saying what went wrong; empty when it gave none.
  function pairFailureMessage(output) {
    var lines = String(output || "").split("\n")
    for (var i = lines.length - 1; i >= 0; i--)
      if (lines[i].indexOf("Error: ") === 0) return lines[i].slice(7).trim()
    return ""
  }

  Process {
    id: pairProcess
    stdout: StdioCollector { id: pairOutput; waitForEnd: true }
    onExited: function(exitCode) {
      var id = root.pairingId
      if (exitCode !== 0) {
        var failures = Object.assign({}, root.pairFailures)
        failures[id] = { message: root.pairFailureMessage(pairOutput.text), output: pairOutput.text }
        root.pairFailures = failures
      }
      root.pairingId = ""
      networkFile.reload()
    }
  }

  // Setting a model up runs here too, never in a terminal: a first one
  // installs Podman, asking for the password through polkit, before its
  // download starts in the background. Until status.json lists the setup,
  // the panel draws its line from this: installing, or why it failed.
  property var settingUp: null
  property var setupFailure: null
  // Setups chosen while another was still starting, which run in turn.
  property var setupQueue: []

  property string setupOutput: ""

  // One setup starts at a time. Another chosen meanwhile, while the first
  // asks for the password and installs Podman, waits on a line of its own.
  function setUp(recipe) {
    if (!recipe) return
    var setup = { recipe: String(recipe.id), name: recipe.name || String(recipe.id), vendor: recipe.vendor || "", since_ms: Date.now(), installing: false }
    if (!settingUp) {
      startSetup(setup)
    } else if (setup.recipe !== settingUp.recipe && !setupQueue.some(function(queued) { return queued.recipe === setup.recipe })) {
      setupQueue = setupQueue.concat([setup])
    }
  }

  function startSetup(setup) {
    setupFailure = null
    setupOutput = ""
    settingUp = Object.assign({}, setup, { since_ms: Date.now() })
    setupProcess.command = ["bash", "-c", "exec omarchy-models use --detach \"$1\" 2>&1", "use", setup.recipe]
    setupProcess.running = true
  }

  function unqueueSetup(recipe) {
    setupQueue = setupQueue.filter(function(queued) { return queued.recipe !== recipe })
  }

  // omarchy-models says "Installing …" before it asks for the password,
  // and only on a first setup: until then the line just says it's starting.
  function setupLine(line) {
    setupOutput += line + "\n"
    if (settingUp && !settingUp.installing && line.indexOf("Installing ") === 0)
      settingUp = Object.assign({}, settingUp, { installing: true })
  }

  // A dismissed password dialog (pkexec's 126) is a change of mind, not a
  // failure: the offer comes back as it was. Either way the setups waiting
  // behind it would stop at the same place, so they go too; once it hands
  // off to the background, the next one starts. Returns that next one.
  function finishSetup(exitCode) {
    if (exitCode !== 0 && exitCode !== 126 && settingUp)
      setupFailure = Object.assign({}, settingUp, { message: pairFailureMessage(setupOutput) || I18n.t("localModels.setupFailed"), output: setupOutput })
    settingUp = null
    var next = exitCode === 0 ? setupQueue[0] || null : null
    setupQueue = next ? setupQueue.slice(1) : []
    return next
  }

  function dismissSetupFailure() {
    setupFailure = null
  }

  // The lines setups have before status.json lists them, shaped like the
  // installing rows omarchy-local-ai writes: the one starting, or the one that
  // failed, and those waiting their turn.
  function setupRows() {
    var rows = []
    var row = function(setup, phase) {
      return {
        recipe: setup.recipe, name: setup.name, vendor: setup.vendor, unit: "installing", fits: true,
        since_ms: setup.since_ms, error: phase === "failed" ? setup.message : "", output: phase === "failed" ? setup.output : "",
        panelSetup: true, install: { phase: phase }
      }
    }
    if (settingUp) rows.push(row(settingUp, settingUp.installing ? "dependencies" : "starting"))
    else if (setupFailure) rows.push(row(setupFailure, "failed"))
    for (var i = 0; i < setupQueue.length; i++) rows.push(row(setupQueue[i], "waiting"))
    return rows
  }

  Process {
    id: setupProcess
    stdout: SplitParser { onRead: function(line) { root.setupLine(line) } }
    onExited: function(exitCode) {
      var next = root.finishSetup(exitCode)
      localModelFile.reload()
      root.refreshLocal()
      if (next) root.startSetup(next)
    }
  }

  function parseNetwork(content) {
    try {
      var parsed = JSON.parse(content)
      if (!parsed || typeof parsed.models !== "object" || Array.isArray(parsed.models)) return
      var models = {}
      for (var id in parsed.models) {
        var model = parsed.models[id]
        if (!model || model.id !== id || id !== model.host + "/" + model.recipe) return
        if (root.units.indexOf(model.unit) < 0) return
        models[id] = model
      }
      var key = JSON.stringify(models, function(field, value) { return field === "last_seen_ms" ? undefined : value })
      if (key !== root.networkKey) {
        root.networkKey = key
        root.networkModels = models
      }
      root.canShare = parsed.can_share === true
    } catch (e) {
      // A missing or partially written survey keeps the last good one.
    }
  }

  function parseLocalModel(content) {
    try {
      var parsed = JSON.parse(content)
      if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) return
      if (!parsed.models || typeof parsed.models !== "object" || Array.isArray(parsed.models)) return
      for (var id in parsed.models) {
        var model = parsed.models[id]
        if (!model || model.recipe !== id || id === "") return
        if (root.units.indexOf(model.unit) < 0) return
      }
      root.noteReadyModels(parsed.models)
      root.noteLaunchableModels(parsed.models)
      root.noteSharedModels(parsed.models)
      root.localModel = parsed
    } catch (e) {
      // A missing or partially written file leaves the last good state intact.
    }
  }

  // A model set up here says so once it has downloaded and loaded, as an
  // agent does once it's signed in, and clicking it opens an agent on it. Only
  // a model seen installing counts, so starting one already set up is quiet;
  // one that ends stopped (no memory to start it now) or failed isn't ready.
  property var installingModels: ({})

  function noteReadyModels(models) {
    var installing = {}
    for (var id in installingModels) {
      var model = models[id]
      if (!model) continue
      if (model.unit === "active" && model.sub_state === "running") notifyModelReady(model)
      else if (model.unit === "installing" || model.unit === "activating") installing[id] = true
    }
    for (var next in models)
      if (models[next].unit === "installing") installing[next] = true
    installingModels = installing
  }

  // A model that is set up has a launcher of its own, which
  // omarchy-models-launchers draws. omarchy-models runs that after
  // a setup or a removal it waited for, but a setup started here carries on
  // in the background, so the launcher is added when the model stops
  // installing. A setup that finished while the shell wasn't watching gets
  // its launcher from the first reading; with no models there is nothing to
  // sync.
  property string launchableModels: ""

  function noteLaunchableModels(models) {
    var ids = []
    for (var id in models)
      if (models[id].unit !== "installing" && models[id].unit !== "removing") ids.push(id)
    var key = ids.sort().join("\n")
    if (key !== launchableModels) syncLaunchers()
    launchableModels = key
  }

  // Sharing starts and stops the share proxy, which makes and removes
  // clients.json, a file that can't be watched before it exists, so it's read
  // again whenever which models are shared changes.
  property string sharedModels: ""

  function noteSharedModels(models) {
    var key = Object.keys(models).filter(function(id) { return models[id].shared === true }).sort().join("\n")
    if (key === sharedModels) return
    sharedModels = key
    clientsFile.reload()
  }

  function syncLaunchers() {
    Util.execArgv(["omarchy-models-launchers"])
  }

  function notifyModelReady(model) {
    Util.execArgv(["bash", "-c",
      'exec omarchy-notification-send --sticky -g 󰚩 --image "$(omarchy-agent-logo "$1")" "$(omarchy-i18n agents.readyToCode "$2")" "$(omarchy-i18n agents.readyToCodeBody)" --exec omarchy-agent --local-model "$3"',
      "notify", String(model.vendor || "local"), String(model.name || model.recipe), String(model.recipe)])
  }


  // ------------------------------------------------------------------ lines
  //
  // The panel's lines: this machine's models and the setups on their way, then
  // the tailnet's, then the recommended model while none is set up, in the
  // order someone dragged them into. A line keeps its place when its model
  // starts or stops, so the keyboard cursor stays on the model it was on.
  readonly property var lines: {
    var list = []
    var models = localModel.models || {}
    for (var id in models)
      list.push({ id: "local:" + id, model: models[id] })
    var setups = setupRows()
    for (var s = 0; s < setups.length; s++) {
      var setup = setups[s]
      if (models[setup.recipe]) continue
      list.push({ id: "local:" + setup.recipe, model: setup })
      // A setup under way is this machine's model already: no offer beside it.
      models = Object.assign({}, models)
      models[setup.recipe] = setup
    }
    // The tailnet's models follow this machine's own.
    var network = networkModels || {}
    for (var nid in network)
      list.push({ id: "net:" + nid, model: network[nid] })
    var offer = localOffer(localRecipes, models)
    if (offer) list.push({ id: "local:" + offer.id, name: offer.name || offer.id, offer: offer })
    list = orderedLines(list)
    // Another DGX Spark cabled to this one and not set up yet (omarchy-models's status.json
    // `link`) is offered like a recommended model, always first: its line opens link setup.
    var link = localModel.link
    if (link && link.state === "available")
      list.unshift({ id: "local:link", name: link.host || "DGX Spark", offer: { id: "link", vendor: "nvidia", link: link } }) // i18n: ignore
    return list
  }

  // A machine with no local model yet is offered the one the catalog
  // recommends for it, ready to download. It shares its id with the model it
  // becomes, and hiding it hides the offer, not the model.
  function localOffer(recipes, models) {
    if (Object.keys(models || {}).length > 0) return null
    for (var i = 0; i < (recipes || []).length; i++) {
      var recipe = recipes[i]
      if (recipe && recipe.best && recipe.available && !recipe.installed) return recipe
    }
    return null
  }

  // The order lines were dragged into, by line id. A line the order doesn't
  // name yet keeps its place after the ones it does.
  readonly property string orderPath: (Quickshell.env("XDG_STATE_HOME") || home + "/.local/state") + "/omarchy/local-models-order.json"
  property var lineOrder: []

  function orderedLines(list) {
    var order = lineOrder
    var rank = function(line) {
      var i = order.indexOf(line.id)
      return i < 0 ? order.length : i
    }
    return list.slice().sort(function(a, b) { return rank(a) - rank(b) })
  }

  // Saves the order of the lines a panel shows, keeping the places of lines
  // hidden or gone for now after them.
  function saveOrder(ids) {
    var order = ids.concat(lineOrder.filter(function(id) { return ids.indexOf(id) < 0 }))
    lineOrder = order
    orderFile.setText(JSON.stringify(order) + "\n")
  }

  FileView {
    id: orderFile
    path: root.orderPath
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: {
      var parsed = []
      try { parsed = JSON.parse(text()) } catch (e) { parsed = [] }
      root.lineOrder = Array.isArray(parsed) ? parsed.map(String) : []
    }
    onFileChanged: reload()
  }

  // Whether the panel is offered at all: only on a machine that can run a
  // model itself (see the README).
  readonly property bool relevant: canRunModels(localRecipes, localModel.models, localModel.link)

  function canRunModels(recipes, models, link) {
    return (recipes || []).some(function(recipe) { return recipe && recipe.available === true })
      || Object.keys(models || {}).length > 0
      || (!!link && link.state === "available")
  }

  // Whether the icon shows rests on the listing, which a fresh account doesn't
  // have yet and an upgrade may have changed, so the shell reads it fresh as
  // it starts. The tailnet is surveyed while the panel is open.
  Component.onCompleted: refreshLocal()

  // ----------------------------------------------------------------- memory
  //
  // What's free for a model to load into, read the way omarchy-local-ai
  // decides whether one fits: available memory plus the pages a GPU driver
  // keeps pooled (GPUReclaim), which the kernel hands back under pressure.
  // Memory has no change signal, so the panel reads it while it's open.
  property real memoryTotalGib: 0
  property real memoryFreeGib: 0
  // What each running model holds now, by recipe, as the engine measures it:
  // an idle model may hold much less than it took to load. Empty where the
  // engine can't say, and the panel falls back to what it took.
  property var modelMemory: ({})

  function readMemory() {
    meminfoFile.reload()
    var models = localModel.models || {}
    var running = Object.keys(models).some(function(id) { return ["active", "activating", "deactivating"].indexOf(models[id].unit) >= 0 })
    if (!running) modelMemory = ({})
    else if (!memoryProcess.running) memoryProcess.running = true
  }

  Process {
    id: memoryProcess
    command: ["omarchy-models", "memory", "--json"]
    stdout: StdioCollector {
      onStreamFinished: root.modelMemory = root.parseModelMemory(text)
    }
  }

  function parseModelMemory(content) {
    try {
      var parsed = JSON.parse(content)
      var held = {}
      if (parsed && typeof parsed === "object" && !Array.isArray(parsed))
        for (var id in parsed)
          if (typeof parsed[id] === "number" && parsed[id] >= 0) held[id] = parsed[id]
      return held
    } catch (e) {
      return {}
    }
  }

  function parseMeminfo(content) {
    var fields = {}
    var rows = String(content || "").split("\n")
    for (var i = 0; i < rows.length; i++) {
      var match = rows[i].match(/^(\w+):\s+(\d+) kB/)
      if (match) fields[match[1]] = Number(match[2])
    }
    if (!(fields.MemTotal > 0) || fields.MemAvailable === undefined) return null
    var kibPerGib = 1024 * 1024
    return { total: fields.MemTotal / kibPerGib, free: (fields.MemAvailable + (fields.GPUReclaim || 0)) / kibPerGib }
  }

  FileView {
    id: meminfoFile
    path: "/proc/meminfo"
    printErrors: false
    onLoaded: {
      var memory = root.parseMeminfo(text())
      if (!memory) return
      root.memoryTotalGib = memory.total
      root.memoryFreeGib = memory.free
    }
  }
}
