// What Setup shows and what a finished welcome tour runs. A page is a lens
// over the menu definition: its rows, their guards and their actions stay in
// omarchy-menu.jsonc, so a row added there appears here too (docs/setup.md).
// Plain JavaScript that Node can load, like MenuModel.js.

function translator(tr) {
  return typeof tr === "function" ? tr : function(key, english) { return english }
}

// The essentials: the tour's steps, in order, and the first pages of the app.
// `menu` is the submenu whose rows a step offers, `row` a single row. `value`
// reads what omarchy-setup-essentials takes for `flag` out of a row's action,
// so the tour runs what the menu row would, only in sequence. A row whose
// action it does not match is offered on the pages and left out of the tour.
var ESSENTIALS = [
  { id: "layout", menu: "appearance.workspace-layout", flag: "--layout",
    value: /^omarchy-hyprland-workspace-layout-default (dwindle|scrolling|floating)$/ },
  { id: "agent", menu: "agent.harness", flag: "--agent",
    value: /^omarchy-default-agent ([a-z0-9][a-z0-9-]*)$/ },
  { id: "dictation", menu: "setup.default.dictation", flag: "--dictation",
    value: /^omarchy-default-dictation ([a-z0-9][a-z0-9-]*)$/ },
  { id: "local-ai", flag: "--local-ai" },
  { id: "tailscale", row: "install.service.tailscale", flag: "--tailscale",
    value: /^omarchy-launch-floating-terminal-with-presentation omarchy-install-service-tailscale$/ }
]

// The Setup menu, whose rows become the rest of the pages, and the ones that
// have a scene of their own. Every other page shows what its rows open.
var SETUP_MENU = "setup"
var SETUP_SCENES = {
  "setup.default": "defaults",
  "setup.plugin": "plugins",
  "setup.security": "security",
  "setup.git": "git",
  "setup.keyboard": "keyboard",
  "setup.region": "region",
  "setup.network": "network"
}

// A recipe id as omarchy-local-ai writes them, which goes on a command line.
var RECIPE_ID = /^[A-Za-z0-9][A-Za-z0-9._-]*$/

function essentialTitle(id, t) {
  if (id === "layout") return t("setup.layoutTitle", "Workspace Layout")
  if (id === "agent") return t("setup.agentTitle", "Agent")
  if (id === "dictation") return t("setup.dictationTitle", "Dictation")
  if (id === "local-ai") return t("setup.localAiTitle", "Local AI")
  return "Tailscale"
}

// What a page is for, in a sentence. A submenu from a menu extension has only
// what its own entry says.
function pageDescription(id, entry, t) {
  switch (id) {
  case "layout": return t("setup.layoutDescription", "How windows are laid out on new workspaces. Super + L changes the one you're on.")
  case "agent": return t("setup.agentDescription", "The coding agent that Super + Shift + Ctrl + A opens, installed if needed.")
  case "dictation": return t("setup.dictationDescription", "Speak instead of typing. Hold Right Alt to dictate, or toggle with Alt + Space.")
  case "local-ai": return t("setup.localAiDescription", "Run an open model on this machine, for your agents to use instead of a cloud one.")
  case "tailscale": return t("setup.tailscaleDescription", "A private network across your own machines, wherever they are, with files sent straight between them.")
  case "setup.default": return t("setup.defaultsDescription", "The apps that open your links, text files and terminals.")
  case "setup.plugin": return t("setup.pluginsDescription", "The plugins that make up the bar and the desktop.")
  case "setup.security": return t("setup.securityDescription", "Fingerprint, security keys, SSH and sudo.")
  case "setup.git": return t("setup.gitDescription", "The name and email on your commits, and signing in to GitHub.")
  case "setup.config": return t("setup.configDescription", "The config files behind the desktop, opened in your editor.")
  case "setup.keyboard": return t("setup.keyboardDescription", "Keyboard layouts, input methods and your own keybindings.")
  case "setup.input": return t("setup.inputDescription", "Key repeat, trackpad and mouse settings.")
  case "setup.region": return t("setup.regionDescription", "Your language, how dates and numbers are written, and your timezone.")
  case "setup.network": return t("setup.networkDescription", "DNS resolvers, and sharing Wi-Fi with a QR code.")
  }
  return (entry && entry.description) || ""
}

// What choosing one row means, where its name alone doesn't say. A row with no
// line here shows the description its menu entry carries, if any.
function optionDetail(id, entry, t) {
  switch (id) {
  case "appearance.workspace-layout.dwindle": return t("setup.layoutTilingDetail", "Windows split the screen between them. Nothing overlaps and nothing hides.")
  case "appearance.workspace-layout.scrolling": return t("setup.layoutScrollingDetail", "Windows sit side by side on a strip that scrolls past the edge of the screen.")
  case "appearance.workspace-layout.floating": return t("setup.layoutFloatingDetail", "Windows overlap and go where you put them, with titlebars and a dock.")
  case "setup.default.dictation.superwhisper": return t("setup.dictationSuperwhisperDetail", "Transcribes in the cloud, with nothing to download first.")
  case "setup.default.dictation.voxtype": return t("setup.dictationVoxtypeDetail", "Runs on this machine, with a 150MB English model.")
  case "setup.default.dictation.hex": return t("setup.dictationHexDetail", "Runs on this machine, with a speech model it downloads during setup.")
  case "install.service.tailscale": return t("setup.tailscaleDetail", "Installs Tailscale, signs this machine in and adds Tailscale to the bar.")
  case "setup.plugin.enable": return t("setup.pluginEnableDetail", "Turn on a plugin, built in or installed.")
  case "setup.plugin.disable": return t("setup.pluginDisableDetail", "Turn a plugin off and keep it installed.")
  case "setup.plugin.add": return t("setup.pluginAddDetail", "Install a plugin from a git repository.")
  case "setup.plugin.clone": return t("setup.pluginCloneDetail", "Copy a built-in plugin into your config to make it your own.")
  case "setup.plugin.remove": return t("setup.pluginRemoveDetail", "Delete a plugin you installed.")
  case "setup.security.fingerprint": return t("setup.fingerprintDetail", "Unlock the screen, and approve sudo and admin prompts, with your fingerprint.")
  case "setup.security.fido2": return t("setup.fido2Detail", "Approve sudo and admin prompts with a tap on a security key.")
  case "setup.security.sshd": return t("setup.sshdDetail", "Let other machines log in to this one over SSH, with a key you authorize.")
  case "setup.security.ssh-agent": return t("setup.sshAgentDetail", "Unlock each SSH key once, from a prompt on the desktop.")
  case "setup.security.sudoless-docker": return t("setup.sudolessDockerDetail", "Run Docker without sudo. Anything that can reach Docker then has root.")
  case "setup.security.passwordless-sudo": return t("setup.passwordlessSudoDetail", "Let sudo run without your password, for a while or for good.")
  case "setup.config.hyprland": return t("setup.configHyprlandDetail", "Your own Hyprland settings, on top of Omarchy's.")
  case "setup.config.hyprsunset": return t("setup.configHyprsunsetDetail", "When the night light comes on, and how warm it gets.")
  case "setup.config.xcompose": return t("setup.configXcomposeDetail", "Compose key sequences for emoji, symbols and snippets.")
  case "setup.keyboard.keybindings": return t("setup.keybindingsDetail", "Your own hotkeys, added to Omarchy's or in their place.")
  case "setup.keyboard.inputs": return t("setup.keyboardInputsDetail", "The keyboard layouts you switch between.")
  case "setup.keyboard.input-methods": return t("setup.inputMethodsDetail", "Typing in Japanese, Korean or Chinese.")
  case "setup.region.language": return t("setup.languageDetail", "The language of the menu, the desktop and Omarchy's notifications.")
  case "setup.region.formats": return t("setup.formatsDetail", "How dates, times, numbers and units are written.")
  case "setup.region.timezone": return t("setup.timezoneDetail", "The timezone your clock follows.")
  case "setup.network.dns.dhcp": return t("setup.dnsDhcpDetail", "The resolver your network hands out.")
  case "setup.network.dns.cloudflare": return t("setup.dnsCloudflareDetail", "Cloudflare's public resolvers.")
  case "setup.network.dns.google": return t("setup.dnsGoogleDetail", "Google's public resolvers.")
  case "setup.network.dns.custom": return t("setup.dnsCustomDetail", "Resolvers you name yourself.")
  case "setup.network.qr": return t("setup.wifiQrDetail", "The Wi-Fi you're on as a QR code, for a phone to scan.")
  }
  return (entry && entry.description) || ""
}

// Where a dictation backend does its listening, for its scene: on this
// machine, or in the cloud. A backend Setup has not been told about says neither.
function dictationPlace(id) {
  if (id === "setup.default.dictation.voxtype" || id === "setup.default.dictation.hex") return "device"
  if (id === "setup.default.dictation.superwhisper") return "cloud"
  return ""
}

// ------------------------------------------------------------- the menu

function entryOf(items, id) {
  return items && items[id] ? items[id] : null
}

// The rows standing in for another while Alt is held, which the menu keeps out
// of their submenu's list.
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

// A submenu's rows as the menu lists them: by parent, in order, without the
// Alt stand-ins, which `skip` caches.
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

// Whether a guard an entry declares came back true.
function guardAnswer(guards, entry, key) {
  return !!entry[key] && !!(guards && guards[key] && guards[key][entry.id])
}

// Whether a guard an entry declares got no answer from a batch that broke off
// part way, which `partial` marks. The menu falls back on its last full set of
// answers then; Setup has none, so it leaves such a row out rather than guess.
function unanswered(guards, entry, key) {
  return !!entry[key] && !!(guards && guards.partial) && !(guards[key] && entry.id in guards[key])
}

// Whether an entry's own guards keep it out of Setup altogether.
function hidden(guards, entry) {
  if (entry.when && guards && guards.when && guards.when[entry.id] === false) return true
  return unanswered(guards, entry, "when") || unanswered(guards, entry, "disabled")
}

// Whether the menu would let anyone get as far as a submenu: neither it nor
// any submenu above it hidden or switched off.
function reachable(items, guards, id) {
  var entry = entryOf(items, id)
  for (var depth = 0; entry && depth < 32; depth++) {
    if (hidden(guards, entry) || guardAnswer(guards, entry, "disabled")) return false
    entry = entryOf(items, entry.parent)
  }
  return true
}

// A row whose `when:` failed is hidden, and so is a submenu left with no row
// to show, as in the menu. Providers list their rows at runtime, so they stay.
function shown(items, order, guards, entry, depth, skip) {
  if (!entry) return false
  if (hidden(guards, entry)) return false
  if (entry.kind === "action" || entry.provider) return true
  if ((depth || 0) >= 32) return false

  var standIns = skip || altStandIns(items, order)
  var children = childrenOf(items, order, entry.kind === "link" ? entry.target : entry.id, standIns)
  for (var i = 0; i < children.length; i++)
    if (shown(items, order, guards, children[i], (depth || 0) + 1, standIns)) return true
  return false
}

// What running a row leads to, for the scene that previews it: a terminal, the
// editor, the menu, or nothing the screen shows.
function handoffKind(action) {
  var command = String(action || "")
  if (/(^|[\s;&|(])(omarchy-launch-floating-terminal-with-presentation|xdg-terminal-exec)\b/.test(command)) return "terminal"
  if (/(^|[\s;&|(])omarchy-launch-editor\b/.test(command)) return "editor"
  if (/(^|[\s;&|(])omarchy[- ]menu\b/.test(command)) return "menu"
  return ""
}

// The file an editor row opens, to title its scene with.
function editorFile(action) {
  var match = /omarchy-launch-editor\s+(?:"([^"]+)"|'([^']+)'|([^\s;&|]+))/.exec(String(action || ""))
  if (!match) return ""
  return String(match[1] || match[2] || match[3]).replace(/^.*\//, "")
}

// The arguments omarchy-setup-essentials takes for a row, or null when the tour
// cannot run it: a row from a menu extension with a command of its own, say.
function stageArgs(step, action) {
  if (!step || !step.value) return null
  var match = step.value.exec(String(action || ""))
  if (!match) return null
  return match.length > 1 ? [step.flag, match[1]] : [step.flag]
}

// One row as an option. A submenu, a link and a provider's list all open in
// the menu, where their rows live; `route` names where. A row the menu shows
// disabled is shown the same way here, with nothing to run.
function optionFor(entry, guards, step, t) {
  var opensMenu = entry.kind !== "action"
  var installed = guardAnswer(guards, entry, "disabled")
  return {
    id: entry.id,
    label: entry.label,
    icon: entry.icon || "",
    iconFont: entry.iconFont || "",
    detail: optionDetail(entry.id, entry, t),
    action: opensMenu || installed ? "" : entry.action,
    route: opensMenu && !installed ? (entry.kind === "link" ? entry.target : entry.id) : "",
    handoff: opensMenu ? "menu" : handoffKind(entry.action),
    file: opensMenu ? "" : editorFile(entry.action),
    place: dictationPlace(entry.id),
    current: guardAnswer(guards, entry, "checked"),
    installed: installed,
    args: opensMenu || installed ? null : stageArgs(step, entry.action)
  }
}

function optionsFor(items, order, guards, entries, step, t, skip) {
  var out = []
  for (var i = 0; i < entries.length; i++)
    if (shown(items, order, guards, entries[i], 0, skip)) out.push(optionFor(entries[i], guards, step, t))
  return out
}

// A submenu's rows as groups: the rows directly under it first, untitled, then
// each submenu under it as a titled group of its own rows. Anything deeper, a
// disabled submenu, and anything a provider lists, is a single row. `covered`
// names submenus an essentials page already shows, which are not repeated.
function groupsFor(items, order, guards, menuId, covered, t, skip) {
  var direct = []
  var groups = []
  var children = childrenOf(items, order, menuId, skip)

  for (var i = 0; i < children.length; i++) {
    var child = children[i]
    if (!shown(items, order, guards, child, 0, skip) || (covered && covered[child.id])) continue

    var expands = child.kind === "menu" && !child.provider && !guardAnswer(guards, child, "disabled")
    var options = expands ? optionsFor(items, order, guards, childrenOf(items, order, child.id, skip), null, t, skip) : []
    if (options.length > 0) groups.push({ id: child.id, title: child.label, options: options })
    else direct.push(optionFor(child, guards, null, t))
  }

  if (direct.length > 0) groups.unshift({ id: menuId, title: "", options: direct })
  return groups
}

// ------------------------------------------------------------- local AI

// The recipe omarchy-local-ai recommends for this machine, from its own
// listing, or null when none fits or the best one is already set up.
function localOffer(listRaw) {
  var recipes
  try { recipes = JSON.parse(listRaw || "[]") } catch (e) { recipes = [] }
  if (!Array.isArray(recipes)) return null

  for (var i = 0; i < recipes.length; i++) {
    var recipe = recipes[i]
    if (!recipe || !recipe.best || !recipe.available || recipe.installed) continue
    // The engine recommends a model of each kind, and only the coding one is
    // an agent's to use. The agents panel asks the same of what it lists, so
    // a model offered here is one it will have to add.
    if (recipe.kind !== "text") continue
    if (!RECIPE_ID.test(String(recipe.id || ""))) continue
    return {
      id: String(recipe.id),
      name: String(recipe.name || recipe.id),
      memoryGib: Number(recipe.memory_gib) || 0,
      context: Number(recipe.context) || 0,
      tokensPerSecond: Number(recipe.decode_tok_s) || 0
    }
  }
  return null
}

// The recipe is named, not asked for again as "best", so what is set up is
// what was shown. The pages run it the way the tour does.
function localOption(offer, t) {
  return {
    id: "local-ai." + offer.id,
    label: offer.name,
    icon: "\u{f035b}",
    iconFont: "",
    detail: t("setup.localAiDetail", "Its download runs in the background. Add it from the agents panel to code with it."),
    action: "omarchy-setup-essentials --local-ai " + offer.id,
    route: "",
    handoff: "terminal",
    file: "",
    place: "",
    current: false,
    installed: false,
    args: ["--local-ai", offer.id]
  }
}

// ------------------------------------------------------------- pages

function isSetupLauncher(entry) {
  return /^omarchy-launch-setup\b/.test(String(entry && entry.action || ""))
}

function essentialPage(step, items, order, guards, offer, t, skip) {
  var options = []
  var entry = null

  if (step.menu) {
    entry = entryOf(items, step.menu)
    if (entry && reachable(items, guards, step.menu) && shown(items, order, guards, entry, 0, skip))
      options = optionsFor(items, order, guards, childrenOf(items, order, step.menu, skip), step, t, skip)
  } else if (step.row) {
    entry = entryOf(items, step.row)
    if (entry && reachable(items, guards, entry.parent)) options = optionsFor(items, order, guards, [entry], step, t, skip)
  } else if (offer) {
    options = [localOption(offer, t)]
  }
  if (options.length === 0) return null

  return {
    id: step.id,
    section: "essentials",
    title: essentialTitle(step.id, t),
    description: pageDescription(step.id, null, t),
    icon: entry ? entry.icon : "\u{f035b}",
    iconFont: entry ? entry.iconFont : "",
    scene: step.id,
    groups: [{ id: step.id, title: "", options: options }]
  }
}

// The menu opens a submenu from outside by route, which is made for typing:
// it folds case and underscores, follows aliases, keeps a few words for itself
// and runs an action it lands on. `opens` says whether a route leads back to
// the very submenu it names. An option that could only be handed over by one
// that does not is taken off its page, and a page left empty goes with it.
function routed(list, opens) {
  var out = []
  for (var i = 0; i < list.length; i++) {
    var groups = []
    for (var j = 0; j < list[i].groups.length; j++) {
      var group = list[i].groups[j]
      var options = group.options.filter(function(option) { return !option.route || opens(option.route) })
      if (options.length > 0) groups.push({ id: group.id, title: group.title, options: options })
    }
    if (groups.length === 0) continue

    var page = {}
    for (var key in list[i]) page[key] = list[i][key]
    page.groups = groups
    out.push(page)
  }
  return out
}

// Every page: the essentials that have something to offer on this machine,
// then one page per row of the Setup menu. `resolve` is the menu's own
// MenuModel.resolveRoute, which decides what a route would open.
function pages(items, order, guards, offer, tr, resolve) {
  var t = translator(tr)
  var skip = altStandIns(items, order)
  var out = []
  var covered = {}

  for (var i = 0; i < ESSENTIALS.length; i++) {
    var page = essentialPage(ESSENTIALS[i], items, order, guards, offer, t, skip)
    if (page) out.push(page)
    if (ESSENTIALS[i].menu) covered[ESSENTIALS[i].menu] = true
  }

  var rows = reachable(items, guards, SETUP_MENU) ? childrenOf(items, order, SETUP_MENU, skip) : []
  for (var j = 0; j < rows.length; j++) {
    var row = rows[j]
    if (!shown(items, order, guards, row, 0, skip) || isSetupLauncher(row)) continue

    var expands = row.kind === "menu" && !row.provider && !guardAnswer(guards, row, "disabled")
    var groups = expands ? groupsFor(items, order, guards, row.id, covered, t, skip) : []
    if (expands && groups.length === 0) continue
    if (!expands) groups = [{ id: row.id, title: "", options: [optionFor(row, guards, null, t)] }]

    out.push({
      id: row.id,
      section: "setup",
      title: row.label,
      description: pageDescription(row.id, row, t),
      icon: row.icon,
      iconFont: row.iconFont,
      scene: SETUP_SCENES[row.id] || "",
      groups: groups
    })
  }

  if (typeof resolve !== "function") return out
  return routed(out, function(id) { return resolve(items, order, id) === id })
}

// A page by its id, the last part of its id, or its name as the rail shows
// it: `omarchy launch setup security`, `omarchy launch setup defaults`.
function pageIndex(list, name) {
  var wanted = String(name || "").toLowerCase()
  if (!wanted) return -1
  for (var i = 0; i < list.length; i++) if (list[i].id === wanted) return i
  for (var j = 0; j < list.length; j++) if (list[j].id.replace(/^.*\./, "") === wanted) return j
  for (var k = 0; k < list.length; k++) if (String(list[k].title).toLowerCase() === wanted) return k
  return -1
}

// The menu entries whose guards the pages read, so the batch asks only those:
// everything under the Setup menu and the essentials' own rows, found the way
// the menu finds them, by parent and through links, and the submenus above
// each of those.
function guardEntries(items, order) {
  var out = {}
  // What has been walked down from. A submenu noted only for being above a
  // root has not been, and its own rows are still to find.
  var walked = {}
  var skip = altStandIns(items, order)

  function collect(id, depth) {
    var entry = entryOf(items, id)
    if (!entry || walked[id] || depth > 32) return
    walked[id] = true
    out[id] = entry
    var under = entry.kind === "link" ? entry.target : id
    if (under !== id) collect(under, depth + 1)
    var children = childrenOf(items, order, under, skip)
    for (var i = 0; i < children.length; i++) collect(children[i].id, depth + 1)
  }

  // The submenus above a root, whose guards decide whether it can be reached.
  function above(id) {
    var entry = entryOf(items, id)
    for (var depth = 0; entry && depth < 32; depth++) {
      out[entry.id] = entry
      entry = entryOf(items, entry.parent)
    }
  }

  var roots = [SETUP_MENU]
  for (var i = 0; i < ESSENTIALS.length; i++) {
    var root = ESSENTIALS[i].menu || ESSENTIALS[i].row
    if (root) roots.push(root)
  }
  for (var j = 0; j < roots.length; j++) {
    collect(roots[j], 0)
    above(roots[j])
  }
  return out
}

// Whether a batch answered every guard that can keep a row out of Setup. One
// that ended early without an error, a guard having exited its group's
// subshell cleanly, has not, though its status says nothing of it.
function answeredAll(entries, guards) {
  for (var id in entries) {
    var entry = entries[id]
    if (entry.when && !(guards.when && id in guards.when)) return false
    if (entry.disabled && !(guards.disabled && id in guards.disabled)) return false
  }
  return true
}

// The guard batch's answers, one `<id>:<w|c|d>:<0|1>` a line, as the maps the
// pages read. An id may hold a colon of its own, so the line is read from its end.
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

// ------------------------------------------------------------- the tour

function flatOptions(page) {
  var out = []
  var groups = page ? page.groups : []
  for (var i = 0; i < groups.length; i++) out = out.concat(groups[i].options)
  return out
}

function optionById(page, id) {
  var options = flatOptions(page)
  for (var i = 0; i < options.length; i++) if (options[i].id === id) return options[i]
  return null
}

function currentOption(page) {
  var options = flatOptions(page)
  for (var i = 0; i < options.length; i++) if (options[i].current) return options[i]
  return null
}

// A step as the tour offers it: only what omarchy-setup-essentials can run and
// the machine doesn't already have. Where nothing is chosen yet, a first card
// says so, so Enter on a fresh step changes nothing.
function tourStep(page, tr) {
  var t = translator(tr)
  var options = flatOptions(page).filter(function(option) { return option.args && !option.installed })
  if (options.length === 0) return null

  if (!options.some(function(option) { return option.current })) {
    options.unshift({
      id: "", label: t("setup.notNow", "Not now"), icon: "\u{f0156}", iconFont: "", detail: "",
      action: "", route: "", handoff: "", file: "", place: "", current: false, installed: false, args: null
    })
  }

  var copy = {}
  for (var key in page) copy[key] = page[key]
  copy.groups = [{ id: page.id, title: "", options: options }]
  return copy
}

// The tour's steps: the essentials with something left to choose.
function tourSteps(list, tr) {
  var out = []
  for (var i = 0; i < list.length; i++) {
    if (list[i].section !== "essentials") continue
    var step = tourStep(list[i], tr)
    if (step) out.push(step)
  }
  return out
}

// A step's pick: the option chosen there, if the step still offers it, else
// what the machine has, else its Not now card. `staged` maps a step to the
// option chosen there. The card a step marks, the picture it draws and the
// plan below all ask here, so they cannot come to differ.
function pick(step, staged) {
  if (!step) return null
  var id = staged ? staged[step.id] : undefined
  return (id === undefined ? null : optionById(step, id)) || currentOption(step) || optionById(step, "")
}

// What Finish runs: one omarchy-setup-essentials call carrying a flag for each
// step whose pick differs from what the machine has. No changes means no
// command at all.
function tourPlan(steps, staged) {
  var changes = []
  var argv = []

  for (var i = 0; i < steps.length; i++) {
    var option = pick(steps[i], staged)
    if (!option || !option.args || option.current) continue
    changes.push({ page: steps[i].id, title: steps[i].title, label: option.label, icon: option.icon, iconFont: option.iconFont })
    argv = argv.concat(option.args)
  }

  return { changes: changes, argv: argv.length > 0 ? ["omarchy-setup-essentials"].concat(argv) : [] }
}

// ------------------------------------------------------------- the cursor

// The options of a page laid out as rows of `columns`, each group starting a
// row of its own, as flat indexes into flatOptions().
function optionRows(page, columns) {
  var rows = []
  var index = 0
  var groups = page ? page.groups : []
  var width = Math.max(1, columns | 0)

  for (var i = 0; i < groups.length; i++) {
    for (var j = 0; j < groups[i].options.length; j++) {
      if (j % width === 0) rows.push([])
      rows[rows.length - 1].push(index++)
    }
  }
  return rows
}

// Where the cursor lands one step from `index`: along its row for dx, and to
// the nearest column of the row above or below for dy. It stops at the edges.
function moveCursor(page, columns, index, dx, dy) {
  var rows = optionRows(page, columns)
  for (var r = 0; r < rows.length; r++) {
    var column = rows[r].indexOf(index)
    if (column < 0) continue
    if (dx) return rows[r][Math.max(0, Math.min(rows[r].length - 1, column + dx))]
    var target = rows[r + dy]
    return target ? target[Math.min(target.length - 1, column)] : index
  }
  return rows.length > 0 ? rows[0][0] : -1
}

if (typeof module !== "undefined") {
  module.exports = {
    essentials: ESSENTIALS,
    pageDescription: pageDescription,
    optionDetail: optionDetail,
    handoffKind: handoffKind,
    editorFile: editorFile,
    stageArgs: stageArgs,
    shown: shown,
    reachable: reachable,
    groupsFor: groupsFor,
    localOffer: localOffer,
    pages: pages,
    pageIndex: pageIndex,
    guardEntries: guardEntries,
    answeredAll: answeredAll,
    parseGuards: parseGuards,
    flatOptions: flatOptions,
    optionById: optionById,
    currentOption: currentOption,
    tourSteps: tourSteps,
    pick: pick,
    tourPlan: tourPlan,
    optionRows: optionRows,
    moveCursor: moveCursor
  }
}
