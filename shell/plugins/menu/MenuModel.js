function stripJsonc(raw) {
  return String(raw || "")
    .replace(/^\s*\/\/[^\n]*(\n|$)/gm, "")
    .replace(/,(\s*[}\]])/g, "$1")
}

function normalizeAliases(value) {
  if (Array.isArray(value)) return value.filter(function(v) { return v })
  if (typeof value === "string" && value) return [value]
  return []
}

function normalizeItem(id, raw) {
  var value = raw || {}
  var aliases = normalizeAliases(value.aliases)
  var parent = value.parent
  if (parent === undefined)
    parent = id.indexOf(".") >= 0 ? id.split(".").slice(0, -1).join(".") : "root"
  if (id === "root") parent = ""

  var kind = value.action ? "action" : (value.target ? "link" : "menu")

  return {
    id: id,
    parent: parent,
    kind: kind,
    icon: value.icon || "",
    iconFont: value.iconFont || "",
    label: value.label || id,
    title: value.title || "",
    target: value.target || "",
    description: value.description || "",
    action: value.action || "",
    provider: value.provider || "",
    aliases: aliases,
    // Search-only terms: matched by nameSearchText, never by resolveRoute.
    // Translations put the English label here so English search keeps
    // working without making English words routable commands.
    searchTerms: normalizeAliases(value.searchTerms),
    when: value.when || "",
    checked: value.checked || "",
    disabled: value.disabled || ""
  }
}

function parseMenuJsonc(raw) {
  return readMenuJsonc(raw) || []
}

// Like parseMenuJsonc, but null when the text is not a menu at all: what a
// reader sees of a file caught mid-write by an update, a checkout or an
// editor's save. A file of nothing but comments is still an empty menu.
function readMenuJsonc(raw) {
  var stripped = stripJsonc(raw)
  if (!stripped.trim()) return []

  var parsed
  try {
    parsed = JSON.parse(stripped)
  } catch (e) {
    return null
  }
  if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) return null

  var source = (parsed.items && typeof parsed.items === "object" && !Array.isArray(parsed.items))
    ? parsed.items
    : parsed
  var out = []
  for (var id in source) {
    var entry = source[id]
    if (!entry || typeof entry !== "object" || Array.isArray(entry)) continue
    out.push(normalizeItem(id, entry))
  }
  return out
}

// The rows a watched menu file leaves after a read. An update, a checkout or
// an editor's save can be read mid-write, and that read must not replace good
// rows with nothing, so it keeps the previous ones until a later read finds
// the file whole. The shipped menu is never legitimately empty, so for it
// (required) an empty read is mid-write too.
function keepMenuRows(previous, raw, required) {
  var items = readMenuJsonc(raw)
  if (!items || (required && items.length === 0)) return previous
  return items
}

// The root row has no JSONC entry, so the merge injects it when neither
// source supplies one; only then does rootLabel (the catalog's translation
// of "Go") apply. A root row from either source keeps its own label, so a
// user-supplied heading is never overwritten by the catalog.
function mergeMenuSources(defaultItems, userItems, rootLabel) {
  var nextItems = ({})
  var nextOrder = []
  var sources = [defaultItems || [], userItems || []]

  for (var s = 0; s < sources.length; s++) {
    var src = sources[s]
    for (var i = 0; i < src.length; i++) {
      var entry = src[i]
      if (!entry || !entry.id) continue
      if (!nextItems[entry.id]) nextOrder.push(entry.id)
      var prior = nextItems[entry.id] || {}
      var merged = {}
      for (var k in prior) merged[k] = prior[k]
      for (var k2 in entry) merged[k2] = entry[k2]
      merged.id = entry.id
      nextItems[entry.id] = merged
    }
  }

  if (!nextItems.root) {
    nextItems.root = { id: "root", parent: "", kind: "menu", icon: "", iconFont: "", label: (typeof rootLabel === "string" && rootLabel) ? rootLabel : "Go", title: "", target: "", description: "", aliases: [], searchTerms: [], when: "", checked: "", disabled: "", action: "", provider: "" }
    nextOrder.unshift("root")
  }
  for (var k3 = 0; k3 < nextOrder.length; k3++) nextItems[nextOrder[k3]].order = k3

  return {
    items: nextItems,
    itemOrder: nextOrder
  }
}

// Both merges below return fresh items/itemOrder objects for the caller to
// assign in one go. They must never write into the maps they are handed: those
// live in QML `var` properties, and an in-place write into such an object is
// occasionally dropped by the engine — the key lands with an undefined value.
// A lost write used to leave an id in itemOrder with no item behind it, and
// the next merge then kept that orphan and appended a second row for the same
// app, so the launcher listed it twice (and again on every later rescan).

// Swaps every app row for the current set. Rows keep the order they arrive in;
// ids already claimed (including duplicate desktop ids) are listed once.
function mergeAppRows(items, itemOrder, appRows) {
  var source = items || ({})
  var order = Array.isArray(itemOrder) ? itemOrder : []
  var rows = Array.isArray(appRows) ? appRows : []
  var nextItems = ({})
  var nextOrder = []

  for (var i = 0; i < order.length; i++) {
    var id = order[i]
    var existing = source[id]
    // Orphans (an id with no item) are dropped rather than carried forward,
    // so a single lost write cannot compound into a duplicate row.
    if (!existing || existing.kind === "app") continue
    nextItems[id] = existing
    nextOrder.push(id)
  }

  for (var j = 0; j < rows.length; j++) {
    var row = rows[j]
    if (!row || !row.id || nextItems[row.id]) continue
    row.order = nextOrder.length
    nextItems[row.id] = row
    nextOrder.push(row.id)
  }

  return { items: nextItems, itemOrder: nextOrder }
}

// Swaps the rows one provider contributed, leaving every other item untouched.
// Rows carry the id of the submenu that produced them, so a provider that runs
// again drops its previous batch — a plugin that was just enabled disappears
// from the Enable list — without disturbing static children declared in JSONC.
function swapProviderRows(items, itemOrder, menuId, rows) {
  var source = items || ({})
  var order = Array.isArray(itemOrder) ? itemOrder : []
  var incoming = Array.isArray(rows) ? rows : []
  var nextItems = ({})
  var nextOrder = []

  for (var i = 0; i < order.length; i++) {
    var id = order[i]
    var existing = source[id]
    if (!existing || existing.providerMenu === menuId) continue
    nextItems[id] = existing
    nextOrder.push(id)
  }

  for (var j = 0; j < incoming.length; j++) {
    var row = incoming[j]
    if (!row || !row.id || nextItems[row.id]) continue
    row.providerMenu = menuId
    row.order = nextOrder.length
    nextItems[row.id] = row
    nextOrder.push(row.id)
  }

  return { items: nextItems, itemOrder: nextOrder }
}

function item(items, id) {
  return items && items[id] ? items[id] : null
}

// Routes may name a real id (`system`, `setup.power`) or an alias declared in
// JSONC (`power-menu`, `settings`). An exact id beats any alias, and app rows
// are never routable: their aliases carry .desktop Keywords and GenericName
// for search, so an installed application could otherwise shadow a menu route
// (htop ships `Keywords=system;...`). Unknown strings fall through as the
// literal input so misspellings still attempt to open that id.
function resolveRoute(items, itemOrder, input) {
  var raw = String(input || "").toLowerCase().replace(/_/g, "-")
  if (!raw || raw === "go" || raw === "menu") return "root"
  if (item(items, raw)) return raw
  var order = Array.isArray(itemOrder) ? itemOrder : []
  for (var i = 0; i < order.length; i++) {
    var entry = item(items, order[i])
    if (!entry || entry.kind === "app" || !entry.aliases) continue
    for (var j = 0; j < entry.aliases.length; j++) {
      var alias = String(entry.aliases[j] || "").toLowerCase().replace(/_/g, "-")
      if (alias === raw) return entry.id
    }
  }
  return raw
}

function slugify(value) {
  return String(value || "").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "") || "item"
}

function depthFor(items, id) {
  var depth = 0
  var current = item(items, id)
  var guard = 0

  while (current && current.parent && current.parent !== "root" && guard < 32) {
    depth += 1
    current = item(items, current.parent)
    guard += 1
  }

  return depth
}

function pathFor(items, id) {
  var labels = []
  var current = item(items, id)
  var guard = 0

  while (current && current.id !== "root" && guard < 32) {
    labels.unshift(current.label)
    current = item(items, current.parent)
    guard += 1
  }

  return labels.join(" › ")
}

function parentPathFor(items, id) {
  var entry = item(items, id)
  if (!entry || !entry.parent || entry.parent === "root") return ""
  return pathFor(items, entry.parent)
}

function isDescendantOf(items, id, ancestorId) {
  if (ancestorId === "root") return id !== "root"

  var current = item(items, id)
  var guard = 0
  while (current && current.parent && guard < 32) {
    if (current.parent === ancestorId) return true
    current = item(items, current.parent)
    guard += 1
  }

  return false
}

function childCount(items, itemOrder, id) {
  var count = 0
  var order = Array.isArray(itemOrder) ? itemOrder : []
  for (var i = 0; i < order.length; i++) {
    var entry = item(items, order[i])
    if (entry && entry.parent === id) count += 1
  }
  return count
}

function isVisible(items, itemOrder, whenResults, entry, depth) {
  if (!entry) return false
  if (entry.when && whenResults && whenResults[entry.id] === false) return false
  if (entry.kind !== "menu" && entry.kind !== "link") return true
  if (entry.provider) return true

  var guard = depth || 0
  if (guard >= 32) return false

  var target = entry.kind === "link" ? entry.target : entry.id
  var order = Array.isArray(itemOrder) ? itemOrder : []
  for (var i = 0; i < order.length; i++) {
    var child = item(items, order[i])
    if (child && child.parent === target && isVisible(items, itemOrder, whenResults, child, guard + 1)) return true
  }

  return false
}

// A `disabled:` row stays listed but goes dim and unselectable. The
// Install submenus use it so software already on the machine reads as
// installed rather than disappearing from the list it was installed from.
function isDisabled(disabledResults, entry) {
  if (!entry || !entry.disabled) return false
  return !!(disabledResults && disabledResults[entry.id])
}

// A disabled row is software you already have, which is the same thing the ✓
// says everywhere else in the menu, so it earns the same marker.
function labelFor(entry, checkedResults, disabledResults) {
  if (!entry) return ""
  var marked = (entry.checked && checkedResults && checkedResults[entry.id]) || isDisabled(disabledResults, entry)
  return marked ? entry.label + " ✓" : entry.label
}

function searchableToken(value) {
  return String(value || "").replace(/[._-]+/g, " ")
}

function leafIdFor(id) {
  var parts = String(id || "").split(".")
  return parts.length > 0 ? parts[parts.length - 1] : id
}

function nameSearchText(entry) {
  if (!entry) return ""
  var aliases = []
  var values = (Array.isArray(entry.aliases) ? entry.aliases : []).concat(Array.isArray(entry.searchTerms) ? entry.searchTerms : [])
  for (var i = 0; i < values.length; i++) aliases.push(searchableToken(values[i]))
  return [entry.label, searchableToken(leafIdFor(entry.id)), aliases.join(" ")].join(" ").toLowerCase()
}

function termInSearchWords(term, text) {
  var words = String(text || "").toLowerCase().split(/\s+/)
  for (var i = 0; i < words.length; i++) {
    if (words[i] === term) return true
  }
  return false
}

function descriptionTextMatches(query, text) {
  var terms = String(query || "").toLowerCase().trim().split(/\s+/)
  for (var i = 0; i < terms.length; i++) {
    if (terms[i] && !termInSearchWords(terms[i], text)) return false
  }
  return true
}

function matchesQuery(entry, query, visible) {
  if (!entry || entry.id === "root") return false
  if (!visible) return false

  var nameText = nameSearchText(entry)
  var descriptionText = String(entry.description || "").toLowerCase()
  var terms = String(query || "").toLowerCase().trim().split(/\s+/)

  for (var i = 0; i < terms.length; i++) {
    if (!terms[i]) continue
    if (nameText.indexOf(terms[i]) >= 0) continue
    if (termInSearchWords(terms[i], descriptionText)) continue
    return false
  }

  return true
}

function searchScore(items, entry, query) {
  var needle = String(query || "").toLowerCase().trim()
  var label = entry.label.toLowerCase()
  var nameText = nameSearchText(entry)
  var descriptionText = String(entry.description || "").toLowerCase()
  var score = 80

  if (label === needle) score = entry.parent === "root" ? 2 : 0
  // An installed app whose name contains the query as a whole word ("zen"
  // for Zen Browser) beats exact-labeled menu entries like Install > Zen.
  else if (entry.kind === "app" && label.split(/\s+/).indexOf(needle) >= 0) score = 0
  else if (label.indexOf(needle) === 0) score = 10
  else if (label.indexOf(needle) >= 0) score = 30
  else if (nameText.indexOf(needle) >= 0) score = 40
  else if (descriptionTextMatches(needle, descriptionText)) score = 60

  if (entry.kind === "menu" || entry.kind === "link") score -= 2
  // App rows sort after all menu items, so they lose the tiebreak below to an
  // equal match. Outrank those, but stay inside the tier so better ones win.
  if (entry.kind === "app") score -= 5

  return score * 1000 + depthFor(items, entry.id) * 25 + entry.order
}

function displayRow(items, itemOrder, checkedResults, disabledResults, entry, detail, score, section) {
  var target = entry.kind === "link" ? entry.target : entry.id
  return {
    itemId: entry.id,
    disabled: isDisabled(disabledResults, entry),
    kind: entry.kind,
    icon: entry.icon,
    iconFont: entry.iconFont || "",
    appIcon: entry.appIcon || "",
    appId: entry.appId || "",
    label: labelFor(entry, checkedResults, disabledResults),
    target: target,
    detail: detail || "",
    path: pathFor(items, entry.id),
    childCount: (entry.kind === "menu" || entry.kind === "link") ? childCount(items, itemOrder, target) : 0,
    action: entry.action || "",
    provider: entry.provider || "",
    score: score || 0,
    section: section || ""
  }
}

// Commands a `checked:` expression reads a value out of. Every sibling row
// asks the same one -- Defaults > Browser has seven rows all comparing
// against `omarchy-default-browser` -- so the batch runs it once and the rows
// read the captured answer.
//
// The capture has to be eager. These are read inside `$(...)`, and a value
// cached while one expression runs lives in that subshell only, so a lazy
// memo never survives to the expression after it.
var GUARD_READERS = [
  "omarchy-bar background",
  "omarchy-bar get omarchy.power showPercentage",
  "omarchy-bar get omarchy.clock format",
  "omarchy-bar get omarchy.clock verticalFormat",
  "omarchy-bar position",
  "omarchy-channel-current",
  "omarchy-default-agent",
  "omarchy-default-browser",
  "omarchy-default-editor",
  "omarchy-default-terminal",
  "omarchy-default-dictation",
  "omarchy-dns",
  "omarchy-dock autohide",
  "omarchy-dock position",
  "omarchy-hyprland-corners",
  "omarchy-hyprland-window-transparency",
  "omarchy-hyprland-workspace-layout-default",
  "omarchy-shell notifications isDnd",
  "omarchy-toggle-nightlight --status"
]

// Package and command presence account for most of what the guards ask, and
// asked one at a time they are almost all fork: the shipped menu spends over
// a second on them. Answer them inside the guard process instead. These
// shadow the real commands for the batch only, so they have to agree with
// them everywhere, including for no arguments at all (present is true of
// nothing, missing is not).
//
// `pacman -Q` resolves a name through what installed packages provide, not
// just what they are called -- with gvim installed it reports `vim` as
// present -- so the set has to carry provides too, or `install.editor.vim`
// comes back and offers to install what is already there. A version
// constraint (`bash>=1`) is not a name any set can answer, so it goes to
// pacman itself; no shipped guard writes one.
//
// `pacman -Qi` wraps a long list across continuation lines whenever COLUMNS
// is set in the environment, which a login shell may well have done, so the
// parser follows the indented lines rather than reading the first one and
// dropping half of what is installed.
//
// Building the set is most of the batch's runtime (~75ms of `-Qi` over a
// thousand packages), yet it only changes when a transaction does. So it is
// kept in $XDG_RUNTIME_DIR, stamped with the local database directory's
// identity and change times: every install, removal and upgrade adds, removes
// or renames a `name-version` entry there, which moves them. A set is stored
// only from a build no transaction can have overlapped -- the same stamp
// before and after, and no db.lck at either end -- so a half-written database
// is never what gets remembered. The stamp and the set are read through one
// descriptor, so a writer replacing the file mid-read cannot pair one stamp
// with another set.
//
// A build that failed is used for this run, as before, but never stored:
// only when both queries succeed does it end with a `/` line, which no
// package name can contain.
//
// The database is wherever pacman.conf's DBPath puts it, so pacman-conf
// names the directory the stamp and lock are read from; one that cannot be
// named is never cached.
function guardPackageSnapshot() {
  var build = '{ set -o pipefail; pacman -Qq && LC_ALL=C pacman -Qi'
    + " | awk '/^[A-Za-z]/ { provides = ($0 ~ /^Provides/); sub(/^[^:]*: /, \"\") }"
    + ' provides && $0 != "None" { n = split($0, p, " ");'
    + ' for (i = 1; i <= n; i++) { sub(/[<>=].*/, "", p[i]); print p[i] } }\' && echo /; } 2>/dev/null'
  var stamp = 'stat -c "%d:%i:%.9Y:%.9Z" -- "$__omarchy_pkg_db/local" 2>/dev/null'

  return '__omarchy_pkg_db=${OMARCHY_PACMAN_DB_PATH:-$(pacman-conf DBPath 2>/dev/null)} || __omarchy_pkg_db=""\n'
    + '__omarchy_pkg_db=${__omarchy_pkg_db%/}\n'
    + '__omarchy_pkg_cache=${XDG_RUNTIME_DIR:+$XDG_RUNTIME_DIR/omarchy-menu-packages}\n'
    + '__omarchy_pkg_stamp=""\n'
    + '[[ -z $__omarchy_pkg_db ]] || __omarchy_pkg_stamp=$(' + stamp + ') || __omarchy_pkg_stamp=""\n'
    + '__omarchy_pkg_names=()\n'
    + 'if [[ -n $__omarchy_pkg_cache && -n $__omarchy_pkg_stamp ]]'
    + ' && { IFS= read -r __omarchy_pkg_line && [[ $__omarchy_pkg_line == "$__omarchy_pkg_stamp" ]]'
    + ' && mapfile -t __omarchy_pkg_names; } 2>/dev/null <"$__omarchy_pkg_cache"; then :\n'
    + 'else\n'
    + '  __omarchy_pkg_names=()\n'
    + '  [[ ! -e $__omarchy_pkg_db/db.lck ]] || __omarchy_pkg_stamp=""\n'
    + '  mapfile -t __omarchy_pkg_names < <(' + build + ')\n'
    + '  if ((${#__omarchy_pkg_names[@]})) && [[ ${__omarchy_pkg_names[-1]} == "/" ]]; then unset "__omarchy_pkg_names[-1]"; else __omarchy_pkg_stamp=""; fi\n'
    + '  if [[ -n $__omarchy_pkg_cache && -n $__omarchy_pkg_stamp && ! -e $__omarchy_pkg_db/db.lck ]]'
    + ' && [[ $(' + stamp + ') == "$__omarchy_pkg_stamp" ]]; then\n'
    + '    { printf "%s\\n" "$__omarchy_pkg_stamp" "${__omarchy_pkg_names[@]}" >"$__omarchy_pkg_cache.$$"'
    + ' && mv -f -- "$__omarchy_pkg_cache.$$" "$__omarchy_pkg_cache"; } 2>/dev/null'
    + ' || rm -f -- "$__omarchy_pkg_cache.$$" 2>/dev/null || :\n'
    + '  fi\n'
    + 'fi\n'
}

function guardHelpers() {
  return 'declare -A __omarchy_pkgs=()\n'
    + guardPackageSnapshot()
    + 'for __omarchy_pkg in "${__omarchy_pkg_names[@]}"; do __omarchy_pkgs[$__omarchy_pkg]=1; done\n'
    + '__omarchy_pkg_has() { [[ -n ${__omarchy_pkgs[$1]-} ]] && return 0; '
    + '[[ $1 == *[\\<\\>=]* ]] && { pacman -Q "$1" &>/dev/null; return; }; return 1; }\n'
    + 'omarchy-pkg-present() { local p; for p in "$@"; do __omarchy_pkg_has "$p" || return 1; done; return 0; }\n'
    + 'omarchy-pkg-missing() { local p; for p in "$@"; do __omarchy_pkg_has "$p" || return 0; done; return 1; }\n'
    + 'omarchy-cmd-present() { local c; for c in "$@"; do command -v "$c" &>/dev/null || return 1; done; return 0; }\n'
    + 'omarchy-cmd-missing() { local c; for c in "$@"; do command -v "$c" &>/dev/null || return 0; done; return 1; }\n'
}

// Substitute the captured answer into the expression rather than shadowing
// the reader with a function. `$(reader)` and the variable holding what it
// printed are interchangeable -- both strip trailing newlines, both split the
// same way unquoted -- while a function would also catch `command -v reader`,
// `VAR=x reader`, and every other form, and answer those wrong. Anything but
// the plain substitution is left alone to run the real command.
//
// The readers are separate programs with nothing to share, so they all start
// at once, before the package set is built, each on a process substitution
// of its own; the batch then reads each one's output in turn. Run one after
// another they were a quarter of the batch. Reading to EOF and dropping the
// trailing newlines is what `$(...)` does with the same output.
function guardPrelude(guards) {
  var start = ""
  var collect = ""

  for (var i = 0; i < GUARD_READERS.length; i++) {
    // The guards arrive already substituted, so what marks a reader as wanted
    // is the slot standing in for it, not the call it replaced.
    if (guards.indexOf(guardReaderSlot(i)) < 0) continue
    var value = "__omarchy_read_" + i
    var fd = "__omarchy_read_fd_" + i
    start += "exec {" + fd + "}< <(" + GUARD_READERS[i] + " 2>/dev/null)\n"
    // `|| :` because read reports the EOF it stops at, and a login shell may
    // have turned on errexit.
    collect += "IFS= read -r -d '' " + value + " <&$" + fd + " || :\n"
      + "exec {" + fd + "}<&-\n"
      + value + "=${" + value + "%\"${" + value + "##*[!$'\\n']}\"}\n"
  }

  return start + guardHelpers() + collect
}

function guardReaderSlot(index) {
  return "${__omarchy_read_" + index + "}"
}

function substituteGuardReaders(expression) {
  for (var i = 0; i < GUARD_READERS.length; i++)
    expression = expression.split("$(" + GUARD_READERS[i] + ")").join(guardReaderSlot(i))

  return expression
}

function guardLine(id, tag, expression) {
  return "if { " + substituteGuardReaders(expression) + "; } >/dev/null 2>&1; then echo "
    + id + ":" + tag + ":1; else echo " + id + ":" + tag + ":0; fi\n"
}

// How many subshells share the guards. Most of what is left of the batch is
// a few dozen separate programs (hardware probes, systemctl, the screen
// recorder's status), each waiting on its own process start rather than on
// a core, so running them side by side is where the time comes back. Eight
// took the shipped menu's batch from ~400ms to ~160ms on a 32-thread desktop
// (~195ms to ~55ms once the package set was cached); more stopped paying.
var GUARD_GROUPS = 8

// One bash script for every `when:`, `checked:` and `disabled:` in the menu,
// reporting `<id>:<w|c|d>:<0|1>` per line. Speed is the whole point: the menu
// opens on the last evaluation's answers, so however long this takes is how
// long a row can contradict the state it describes.
//
// Guards are dealt round-robin into GUARD_GROUPS background subshells, each
// inheriting the package set, the shadowed helpers and the readers' answers,
// and the batch exits once all of them have. Lines arrive in any order, which
// the menu never relied on: each names its row, and each is one short write
// to the pipe, which the kernel never interleaves.
//
// A group that dies part way (a guard tripping a login shell's `set -u`, say)
// has left its remaining rows unanswered, and the menu keeps the last full
// set only when the batch fails. So each group is waited for by pid, and the
// batch's status is nonzero if any of them was.
function guardScript(items) {
  var lines = []
  var ids = Object.keys(items || {})

  for (var i = 0; i < ids.length; i++) {
    var entry = items[ids[i]]
    if (!entry) continue
    if (entry.when) lines.push(guardLine(ids[i], "w", entry.when))
    if (entry.checked) lines.push(guardLine(ids[i], "c", entry.checked))
    if (entry.disabled) lines.push(guardLine(ids[i], "d", entry.disabled))
  }
  if (lines.length === 0) return ""

  var groups = []
  for (var j = 0; j < lines.length; j++) {
    var group = j % GUARD_GROUPS
    groups[group] = (groups[group] || "") + lines[j]
  }

  var script = guardPrelude(lines.join("")) + "__omarchy_groups=()\n"
  for (var k = 0; k < groups.length; k++) script += "{\n" + groups[k] + "} &\n__omarchy_groups+=($!)\n"
  return script + "__omarchy_failed=0\n"
    + 'for __omarchy_group in "${__omarchy_groups[@]}"; do wait "$__omarchy_group" || __omarchy_failed=1; done\n'
    + "((__omarchy_failed == 0))\n"
}

// An action that only asks this shell to summon one of its own plugins can be
// run in-process, skipping the bash and qs ipc spawns. Anything more than the
// bare call, such as a second command or a shell-expanded payload, is left to
// bash.
function summonAction(action) {
  var match = /^omarchy-shell shell summon ([A-Za-z0-9._-]+)(?: '([^']*)')?$/.exec(String(action || ""))
  if (!match) return null
  return { id: match[1], payload: match[2] || "{}" }
}


// Multi-select requests return stable values, without icons, in option order.
function dmenuValue(option) {
  var parts = String(option || "").split("\t")
  if (parts.length > 1) parts.shift()
  return parts.join("\t")
}

function dmenuSelections(options, selected, preserveOrder) {
  var available = options.map(dmenuValue)
  return (preserveOrder ? selected : available).filter(function(value, index, values) {
    return available.indexOf(value) !== -1 && selected.indexOf(value) !== -1 && values.indexOf(value) === index
  })
}

function toggleDmenuSelection(selected, value) {
  return selected.indexOf(value) === -1 ? selected.concat([value])
    : selected.filter(function(item) { return item !== value })
}

// Returns a copy of items with label/title/description replaced from a
// translation catalog ({id: {label, title, description}}), as shipped in
// default/i18n/<code>/menu.json. The English label stays searchable by
// moving it into searchTerms when the translation differs — searchTerms
// feed search but never resolveRoute, so English words do not become
// routable commands in other languages. Items without a
// catalog entry pass through untouched, so an incomplete (or missing)
// catalog degrades to English row by row. Applied to the default items
// before the user extension merges, so user rows and retitles always win.
function applyTranslations(items, catalog) {
  var source = Array.isArray(items) ? items : []
  var strings = (catalog && typeof catalog === "object") ? catalog : ({})
  var out = []
  for (var i = 0; i < source.length; i++) {
    var entry = source[i]
    var translated = entry && strings[entry.id]
    if (!translated || typeof translated !== "object") {
      out.push(entry)
      continue
    }
    var next = {}
    for (var k in entry) next[k] = entry[k]
    if (translated.label) {
      if (translated.label !== entry.label && entry.label) {
        var terms = Array.isArray(entry.searchTerms) ? entry.searchTerms.slice() : []
        if (terms.indexOf(entry.label) < 0) terms.push(entry.label)
        next.searchTerms = terms
      }
      next.label = translated.label
    }
    if (translated.title) next.title = translated.title
    if (translated.description) next.description = translated.description
    out.push(next)
  }
  return out
}

if (typeof module !== "undefined") {
  module.exports = {
    summonAction: summonAction,
    guardReaders: GUARD_READERS,
    guardScript: guardScript,
    stripJsonc: stripJsonc,
    normalizeAliases: normalizeAliases,
    normalizeItem: normalizeItem,
    parseMenuJsonc: parseMenuJsonc,
    keepMenuRows: keepMenuRows,
    mergeMenuSources: mergeMenuSources,
    mergeAppRows: mergeAppRows,
    swapProviderRows: swapProviderRows,
    item: item,
    resolveRoute: resolveRoute,
    slugify: slugify,
    depthFor: depthFor,
    pathFor: pathFor,
    parentPathFor: parentPathFor,
    isDescendantOf: isDescendantOf,
    childCount: childCount,
    isVisible: isVisible,
    isDisabled: isDisabled,
    labelFor: labelFor,
    searchableToken: searchableToken,
    leafIdFor: leafIdFor,
    nameSearchText: nameSearchText,
    termInSearchWords: termInSearchWords,
    descriptionTextMatches: descriptionTextMatches,
    matchesQuery: matchesQuery,
    searchScore: searchScore,
    dmenuValue: dmenuValue,
    dmenuSelections: dmenuSelections,
    toggleDmenuSelection: toggleDmenuSelection,
    displayRow: displayRow,
    applyTranslations: applyTranslations
  }
}
