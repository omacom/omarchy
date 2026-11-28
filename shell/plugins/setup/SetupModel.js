// What the Welcome tour offers and what Finish runs. Choices that live in the
// menu (workspace layout, dictation, Tailscale) are read from omarchy-menu.jsonc
// and the user's extension so added rows, translations and guards stay in one
// place (docs/setup.md). Plain JavaScript that Node can load, like MenuModel.js.

function translator(tr) {
  return typeof tr === "function" ? tr : function(key, english) { return english }
}

// The tour's steps, in order. Choice steps pick among a menu's direct rows;
// toggle steps are opt-ins (Tailscale from the menu, Agent and Local AI from
// their own sources). `value` reads what omarchy-setup-essentials takes for
// `flag` out of a menu row's action so the tour runs the same action in order.
var ESSENTIALS = [
  { id: "layout", kind: "choice", menu: "appearance.workspace-layout", flag: "--layout",
    value: /^omarchy-hyprland-workspace-layout-default (dwindle|scrolling|floating)$/ },
  { id: "dictation", kind: "choice", menu: "setup.default.dictation", flag: "--dictation",
    value: /^omarchy-default-dictation ([a-z0-9][a-z0-9-]*)$/ },
  { id: "agent", kind: "toggle", flag: "--agent" },
  { id: "local-ai", kind: "toggle", flag: "--local-ai" },
  { id: "tailscale", kind: "toggle", row: "install.service.tailscale", flag: "--tailscale",
    value: /^omarchy-launch-floating-terminal-with-presentation omarchy-install-service-tailscale$/ }
]

// A recipe id as omarchy-models writes them, which goes on a command line.
var RECIPE_ID = /^[A-Za-z0-9][A-Za-z0-9._-]*$/

function stepTitle(id, entry, t) {
  if (id === "layout") return t("setup.layoutTitle", "Workspace Layout")
  if (id === "dictation") return t("setup.dictationTitle", "Dictation")
  if (id === "agent") return t("setup.agentTitle", "Agent")
  if (id === "local-ai") return t("setup.localAiTitle", "Local AI")
  return (entry && entry.label) || "Tailscale"
}

function stepDescription(id, t) {
  switch (id) {
  case "layout": return t("setup.layoutDescription", "How windows arrange on new workspaces. Press Super + L anytime to switch.")
  case "dictation": return t("setup.dictationDescription", "Speak instead of typing. Hold Right Alt to dictate, or toggle with Alt + Space.")
  case "agent": return t("setup.agentDescription", "The coding agent that Super + Shift + Ctrl + A opens.")
  case "local-ai": return t("setup.localAiDescription", "Run an open coding model directly on this machine, private and offline.")
  case "tailscale": return t("setup.tailscaleDescription", "A private mesh network across your machines, with direct file sharing.")
  }
  return ""
}

// Concise inside-card subtitle for each option so a screen is self-explanatory
// without clicking around.
function optionSubtitle(id, entry, t) {
  switch (id) {
  case "appearance.workspace-layout.dwindle": return t("setup.layoutTilingDetail", "Auto-tiled, zero overlap")
  case "appearance.workspace-layout.scrolling": return t("setup.layoutScrollingDetail", "Side-by-side infinite strip")
  case "appearance.workspace-layout.floating": return t("setup.layoutFloatingDetail", "Overlapping windows & dock")
  case "setup.default.dictation.superwhisper": return t("setup.dictationSuperwhisperDetail", "Cloud or on-device")
  case "setup.default.dictation.voxtype": return t("setup.dictationVoxtypeDetail", "On-device · 150 MB English")
  case "setup.default.dictation.hex": return t("setup.dictationHexDetail", "On-device · Model download")
  case "install.service.tailscale": return t("setup.tailscaleDetail", "Installs Tailscale, opens sign-in, and adds it to the bar.")
  }
  return (entry && entry.description) || ""
}

// Where a dictation backend listens: on this machine or in the cloud.
function dictationPlace(id) {
  if (id === "setup.default.dictation.voxtype" || id === "setup.default.dictation.hex") return "device"
  if (id === "setup.default.dictation.superwhisper") return "cloud"
  return ""
}

// Differentiated card/summary icons: layout uses the workspace glyph (never
// the raw geometric shape), and dictation distinguishes cloud vs on-device.
function optionIcon(stepId, id, entry) {
  if (stepId === "layout") return { icon: "\u{f10ac}", iconFont: "" }
  var place = dictationPlace(id)
  if (place === "cloud") return { icon: "\u{f0c2}", iconFont: "" }
  if (place === "device") return { icon: "\u{f035b}", iconFont: "" }
  return { icon: (entry && entry.icon) || "", iconFont: (entry && entry.iconFont) || "" }
}

// ------------------------------------------------------------- menu & guards

function entryOf(items, id) {
  return items && items[id] ? items[id] : null
}

// Rows that only stand in for another while Alt is held.
function altStandIns(items, order) {
  var ids = {}
  var list = Array.isArray(order) ? order : []
  for (var i = 0; i < list.length; i++) {
    var entry = entryOf(items, list[i])
    var standIn = entry && entry.alt ? entryOf(items, entry.alt) : null
    if (standIn && standIn.kind === "action") ids[standIn.id] = true
  }
  return ids
}

function childrenOf(items, order, parentId, skip) {
  var out = []
  var list = Array.isArray(order) ? order : []
  var standIns = skip || altStandIns(items, order)
  for (var i = 0; i < list.length; i++) {
    var entry = entryOf(items, list[i])
    if (entry && entry.parent === parentId && !standIns[entry.id]) out.push(entry)
  }
  return out
}

function guardAnswer(guards, entry, key) {
  return !!entry[key] && !!(guards && guards[key] && guards[key][entry.id])
}

// Unanswered visibility or disabled guards on a partial batch treat the row as
// unavailable rather than guessing. An unanswered `checked` stays unknown.
function unanswered(guards, entry, key) {
  return !!entry[key] && !!(guards && guards.partial) && !(guards[key] && entry.id in guards[key])
}

function hidden(guards, entry) {
  if (entry.when && guards && guards.when && guards.when[entry.id] === false) return true
  return unanswered(guards, entry, "when") || unanswered(guards, entry, "disabled")
}

function reachable(items, guards, id) {
  var entry = entryOf(items, id)
  for (var depth = 0; entry && depth < 32; depth++) {
    if (hidden(guards, entry) || guardAnswer(guards, entry, "disabled")) return false
    entry = entryOf(items, entry.parent)
  }
  return true
}

function stageArgs(step, action) {
  if (!step || !step.value) return null
  var match = step.value.exec(String(action || ""))
  if (!match) return null
  return match.length > 1 ? [step.flag, match[1]] : [step.flag]
}

// The menu entries whose guards the tour actually reads: the direct rows of
// workspace layout and dictation, the Tailscale row, and each ancestor chain.
function guardEntries(items, order) {
  var out = {}
  var skip = altStandIns(items, order)

  function above(id) {
    var entry = entryOf(items, id)
    for (var depth = 0; entry && depth < 32; depth++) {
      out[entry.id] = entry
      entry = entryOf(items, entry.parent)
    }
  }

  for (var i = 0; i < ESSENTIALS.length; i++) {
    var step = ESSENTIALS[i]
    if (step.menu) {
      above(step.menu)
      var children = childrenOf(items, order, step.menu, skip)
      for (var j = 0; j < children.length; j++) out[children[j].id] = children[j]
    } else if (step.row) {
      above(step.row)
    }
  }
  return out
}

function answeredAll(entries, guards) {
  for (var id in entries) {
    var entry = entries[id]
    if (entry.when && !(guards.when && id in guards.when)) return false
    if (entry.disabled && !(guards.disabled && id in guards.disabled)) return false
  }
  return true
}

function parseGuards(raw) {
  var out = { when: {}, checked: {}, disabled: {} }
  var keys = { w: "when", c: "checked", d: "disabled" }
  var lines = String(raw || "").split("\n")

  for (var i = 0; i < lines.length; i++) {
    var match = /^(.+):([wcd]):([01])$/.exec(lines[i].trim())
    if (match) out[keys[match[2]]][match[1]] = match[3] === "1"
  }
  return out
}

// ------------------------------------------------------------- local AI

// Superwhisper's active processing mode from `superwhisper models show`:
// normalizes `offline_lite` and `offline` into `"offline"`, `"cloud"` into
// `"cloud"`, and anything missing/unreadable into `""`.
function parseSuperwhisperMode(raw) {
  var data
  try { data = JSON.parse(raw || "{}") } catch (e) { return "" }
  var mode = data && typeof data.processing === "string" ? data.processing : ""
  if (mode === "cloud") return "cloud"
  if (mode === "offline" || mode === "offline_lite") return "offline"
  return ""
}

// Every text blueprint omarchy-models marks available and not yet installed
// on this machine (`omarchy-models list --json`), sorted with `best` first —
// matching the Agents panel's own local-model blueprint filter.
function localOffers(listRaw) {
  var recipes
  try { recipes = JSON.parse(listRaw || "[]") } catch (e) { recipes = [] }
  if (!Array.isArray(recipes)) return []

  var out = []
  for (var i = 0; i < recipes.length; i++) {
    var recipe = recipes[i]
    if (!recipe || !recipe.available || recipe.installed) continue
    if (recipe.kind !== "text") continue
    if (!RECIPE_ID.test(String(recipe.id || ""))) continue
    out.push({
      id: String(recipe.id),
      name: String(recipe.name || recipe.id),
      vendor: String(recipe.vendor || "local"),
      best: !!recipe.best,
      memoryGib: Number(recipe.memory_gib) || 0,
      context: Number(recipe.context) || 0,
      tokensPerSecond: Number(recipe.decode_tok_s) || 0
    })
  }
  out.sort(function(a, b) { return (b.best ? 1 : 0) - (a.best ? 1 : 0) })
  return out
}

function localOffer(listRaw) {
  var all = localOffers(listRaw)
  return all.length > 0 ? all[0] : null
}

// ------------------------------------------------------------- tour steps

function optionSubOptions(entryId, isCurrent, dictationMode, t) {
  if (entryId === "setup.default.dictation.superwhisper") {
    var mode = dictationMode === "offline" ? "offline"
      : dictationMode === "cloud" ? "cloud"
      : (isCurrent ? "cloud" : "")
    return [
      {
        id: "cloud",
        label: t("setup.dictationModeCloud", "Cloud"),
        detail: t("setup.dictationModeCloudDetail", "Free tier"),
        icon: "\u{f0c2}",
        place: "cloud",
        current: mode === "cloud",
        args: ["--dictation-mode", "cloud"]
      },
      {
        id: "offline",
        label: t("setup.dictationModeLocal", "On-device"),
        detail: t("setup.dictationModeLocalDetail", "Downloads model"),
        icon: "\u{f035b}",
        place: "device",
        current: mode === "offline",
        args: ["--dictation-mode", "offline"]
      }
    ]
  }
  return []
}

function choiceOption(entry, guards, step, dictationMode, t) {
  var args = stageArgs(step, entry.action)
  if (!args || entry.kind !== "action" || hidden(guards, entry) || guardAnswer(guards, entry, "disabled")) return null
  var current = guardAnswer(guards, entry, "checked")
  var glyph = optionIcon(step.id, entry.id, entry)
  var subs = optionSubOptions(entry.id, current, dictationMode, t)
  return {
    id: entry.id,
    label: entry.label,
    summaryLabel: entry.label,
    detail: optionSubtitle(entry.id, entry, t),
    icon: glyph.icon,
    iconFont: glyph.iconFont,
    pictogram: step.id === "layout" ? args[1] : "",
    place: dictationPlace(entry.id),
    current: current,
    subOptions: subs,
    args: args
  }
}

function buildStep(step, items, order, guards, offer, agents, dictationMode, t, skip) {
  if (step.kind === "choice" && step.menu) {
    var menuEntry = entryOf(items, step.menu)
    if (!menuEntry || !reachable(items, guards, step.menu)) return null
    var children = childrenOf(items, order, step.menu, skip)
    var options = []
    for (var i = 0; i < children.length; i++) {
      var opt = choiceOption(children[i], guards, step, dictationMode, t)
      if (opt) options.push(opt)
    }
    if (options.length === 0) return null
    return {
      id: step.id,
      kind: "choice",
      title: stepTitle(step.id, menuEntry, t),
      description: stepDescription(step.id, t),
      scene: step.id,
      options: options
    }
  }

  if (step.id === "agent") {
    if (!agents || !agents.panel || agents.chosen) return null
    return {
      id: "agent",
      kind: "toggle",
      title: stepTitle("agent", null, t),
      description: stepDescription("agent", t),
      scene: "agent",
      option: {
        id: "agent.add",
        label: t("setup.agentAdd", "Add a coding agent"),
        summaryLabel: t("setup.agentSummary", "Open Agents panel"),
        detail: t("setup.agentAddDetail", "Opens the Agents panel after Finish to sign in, add an API key, or use a local model."),
        icon: "\u{f06a9}",
        iconFont: "",
        args: ["--agent"]
      }
    }
  }

  if (step.id === "local-ai") {
    var offers = Array.isArray(offer) ? offer : (offer ? [offer] : [])
    if (offers.length === 0) return null
    if (offers.length === 1) {
      var single = offers[0]
      return {
        id: "local-ai",
        kind: "toggle",
        title: stepTitle("local-ai", null, t),
        description: stepDescription("local-ai", t),
        scene: "local-ai",
        option: {
          id: "local-ai." + single.id,
          label: single.name,
          summaryLabel: single.name,
          detail: t("setup.localAiDetail", "Downloads in the background. Follow progress and add it from the Agents panel."),
          icon: "\u{f035b}",
          iconFont: "",
          vendor: single.vendor || "",
          facts: single,
          recommended: !!single.best,
          args: ["--local-ai", single.id]
        }
      }
    }
    var modelOptions = []
    for (var m = 0; m < offers.length; m++) {
      var item = offers[m]
      modelOptions.push({
        id: "local-ai." + item.id,
        label: item.name,
        summaryLabel: item.name,
        detail: t("setup.localAiDetail", "Downloads in the background. Follow progress and add it from the Agents panel."),
        icon: "\u{f035b}",
        iconFont: "",
        vendor: item.vendor || "",
        pictogram: "",
        place: "",
        current: false,
        recommended: !!item.best,
        facts: item,
        args: ["--local-ai", item.id]
      })
    }
    return {
      id: "local-ai",
      kind: "choice",
      optional: true,
      title: stepTitle("local-ai", null, t),
      description: t("setup.localAiChoiceDescription", "Pick a compatible open coding model, or leave unselected. Downloads run in the background."),
      scene: "local-ai",
      options: modelOptions
    }
  }

  if (step.id === "tailscale" && step.row) {
    var row = entryOf(items, step.row)
    if (!row || row.kind !== "action" || !reachable(items, guards, step.row)) return null
    var args = stageArgs(step, row.action)
    if (!args) return null
    return {
      id: "tailscale",
      kind: "toggle",
      title: stepTitle("tailscale", row, t),
      description: stepDescription("tailscale", t),
      scene: "tailscale",
      option: {
        id: row.id,
        label: t("setup.tailscaleAdd", "Install Tailscale"),
        summaryLabel: t("setup.tailscaleSummary", "Install & sign in"),
        detail: optionSubtitle(row.id, row, t),
        icon: row.icon || "",
        iconFont: row.iconFont || "",
        args: args
      }
    }
  }

  return null
}

// The welcome tour's steps, omitting any step with nothing to offer on this machine.
function tourSteps(items, order, guards, offer, agents, tr, dictationMode) {
  var t = translator(tr)
  var skip = altStandIns(items, order)
  var out = []

  for (var i = 0; i < ESSENTIALS.length; i++) {
    var built = buildStep(ESSENTIALS[i], items, order, guards, offer, agents, dictationMode || "", t, skip)
    if (built) out.push(built)
  }
  return out
}

function optionById(step, id) {
  if (!step || step.kind !== "choice") return null
  for (var i = 0; i < step.options.length; i++) if (step.options[i].id === id) return step.options[i]
  return null
}

function currentOption(step) {
  if (!step || step.kind !== "choice") return null
  for (var i = 0; i < step.options.length; i++) if (step.options[i].current) return step.options[i]
  return null
}

// A step's effective pick:
// - Choice step: the staged option if still offered, null if explicitly kept
//   unstaged (""), else the machine's current option (or null if none matched).
// - Toggle step: step.option when staged[step.id] === true, else null (off).
function pick(step, staged) {
  if (!step) return null
  var value = staged ? staged[step.id] : undefined
  if (step.kind === "toggle") return value === true ? step.option : null
  if (value === "") return null
  return (value === undefined ? null : optionById(step, value)) || currentOption(step)
}

// Effective sub-option for a choice option that offers sub-selections (such as
// Superwhisper's Cloud vs On-device mode). Falls back to the current mode, then
// the first sub-option.
function pickSubOption(option, stagedSubId) {
  if (!option || !Array.isArray(option.subOptions) || option.subOptions.length === 0) return null
  if (stagedSubId) {
    for (var i = 0; i < option.subOptions.length; i++) {
      if (option.subOptions[i].id === stagedSubId) return option.subOptions[i]
    }
  }
  for (var j = 0; j < option.subOptions.length; j++) {
    if (option.subOptions[j].current) return option.subOptions[j]
  }
  return option.subOptions[0]
}

// What Finish runs: one omarchy-setup-essentials call carrying a flag for each
// step whose pick (or sub-option) differs from what the machine already has.
function tourPlan(steps, staged, stagedSub) {
  var changes = []
  var argv = []
  var hasInstalls = false
  var hasAgent = false

  for (var i = 0; i < steps.length; i++) {
    var step = steps[i]
    var option = pick(step, staged)
    if (!option || !option.args) continue
    var sub = pickSubOption(option, stagedSub ? stagedSub[step.id] : "")
    if (option.current && (!sub || sub.current)) continue
    var label = option.summaryLabel || option.label
    if (sub) label = label + " \u{b7} " + sub.label
    changes.push({
      page: step.id,
      title: step.title,
      label: label,
      icon: sub && sub.icon ? sub.icon : option.icon,
      iconFont: sub && sub.icon ? "" : option.iconFont
    })
    argv = argv.concat(option.args)
    if (sub && sub.args) argv = argv.concat(sub.args)
    if (step.id === "dictation" || step.id === "local-ai" || step.id === "tailscale") hasInstalls = true
    if (step.id === "agent") hasAgent = true
  }

  return {
    changes: changes,
    argv: argv.length > 0 ? ["omarchy-setup-essentials"].concat(argv) : [],
    hasInstalls: hasInstalls,
    hasAgent: hasAgent
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    essentials: ESSENTIALS,
    stepDescription: stepDescription,
    optionSubtitle: optionSubtitle,
    stageArgs: stageArgs,
    reachable: reachable,
    guardEntries: guardEntries,
    answeredAll: answeredAll,
    parseGuards: parseGuards,
    parseSuperwhisperMode: parseSuperwhisperMode,
    localOffer: localOffer,
    localOffers: localOffers,
    tourSteps: tourSteps,
    optionById: optionById,
    currentOption: currentOption,
    pick: pick,
    pickSubOption: pickSubOption,
    tourPlan: tourPlan
  }
}
