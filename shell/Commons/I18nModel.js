// I18nModel.js — the pure-JS core of qs.Commons.I18n.
//
// No Qt or QML dependencies, so it runs under node for tests and QML loads it
// with `import "I18nModel.js" as Model`. Keep it that way: everything that
// touches FileView, Quickshell.env, or the plugin registry lives in I18n.qml.
//
// Vocabulary
//   domain    a namespace for keys, normally a plugin id ("omarchy.menu");
//             "omarchy.shell" and "omarchy.cli" are reserved for code with no id
//   owner     whoever registered a set of catalogs, normally a language pack;
//             owners are replaced atomically and can be cleared
//   catalog   one JSON object per domain, po2json/Jed shape: a "" header entry
//             plus msgid -> msgstr. A plural is msgid -> [forms] or
//             msgid -> { msgid_plural, msgstr: [forms] }; both load as the
//             object shape, stamped with the plural rule of the catalog it
//             came from so entries from different locales can share a domain
//   link      child domain -> parent domain, from a clone's omarchy.clonedFrom

var CONTEXT_SEPARATOR = "\u0004"

// ---------------------------------------------------------------------------
// Locale selection

function normalizeLocale(value) {
  var locale = String(value || "").trim()
  if (!locale) return ""
  locale = locale.split(".")[0].split("@")[0].replace(/-/g, "_")
  if (locale === "C" || locale === "POSIX") return ""
  var parts = locale.split("_")
  var language = parts[0].toLowerCase()
  // ISO 639 codes only: the result names /usr/share/locale directories.
  if (!/^[a-z]{2,3}$/.test(language)) return ""
  // Region ISO 3166 (2 letras) o numérica UN M.49 (3 dígitos, p. ej. es_419).
  // El script BCP-47 (zh_Hans_CN) no existe en nombres de locale glibc/gettext:
  // se omite y se conserva la región, que es lo que los catálogos usan.
  var region = ""
  for (var i = 1; i < parts.length; i++) {
    if (/^[A-Za-z]{2}$/.test(parts[i]) || /^\d{3}$/.test(parts[i])) {
      region = parts[i].toUpperCase()
      break
    }
  }
  return region ? language + "_" + region : language
}

// Ordered preference list from the gettext environment variables. LANGUAGE is
// a colon-separated list and wins outright; the others are single values.
// Each entry expands to [regional, language] so "ca_ES" also tries "ca".
// "en" is the source language: nothing after it can apply, so the list stops.
function localeCandidates(environment) {
  var env = environment || {}
  var raw = env.LANGUAGE || env.LC_ALL || env.LC_MESSAGES || env.LANG || ""
  var requested = env.LANGUAGE ? String(raw).split(":") : [raw]
  var candidates = []
  for (var i = 0; i < requested.length; i++) {
    var normalized = normalizeLocale(requested[i])
    if (!normalized) continue
    var language = normalized.split("_")[0]
    if (candidates.indexOf(normalized) === -1) candidates.push(normalized)
    if (candidates.indexOf(language) === -1) candidates.push(language)
    if (language === "en") break
  }
  return candidates
}

// Candidates for the language picked under Setup > Language: the registry
// code ("pt-BR", "no") and its glibc locale ("pt_BR.UTF-8", "nb_NO.UTF-8"),
// which names the directories gettext catalogs live in. English is the
// source language, so it has no candidates and nothing is translated.
function languageCandidates(code, glibcLocale) {
  var language = String(code || "").trim()
  if (!language || language === "en" || language.indexOf("en-") === 0) return []
  var candidates = localeCandidates({ LANGUAGE: String(glibcLocale || "") || language })
  return candidates.length > 0 && candidates[0].split("_")[0] === "en" ? [] : candidates
}

// ---------------------------------------------------------------------------
// Interpolation: %1, %2 ... Single pass, so an argument that itself contains
// "%2" is inserted verbatim and never re-expanded. Unknown indices stay as-is.

function interpolate(value, args) {
  var output = String(value === undefined || value === null ? "" : value)
  var values = Array.isArray(args) ? args : []
  return output.replace(/%([1-9][0-9]*)/g, function(match, rawIndex) {
    var index = Number(rawIndex) - 1
    return index < values.length ? String(values[index]) : match
  })
}

function contextKey(context, source) {
  var ctx = String(context === undefined || context === null ? "" : context)
  var key = String(source === undefined || source === null ? "" : source)
  return ctx ? ctx + CONTEXT_SEPARATOR + key : key
}

// ---------------------------------------------------------------------------
// Plural rules. The catalog header carries a gettext Plural-Forms line:
//   "nplurals=3; plural=(n==1 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2);"
// The expression is a C integer expression over n. It is evaluated by a small
// recursive-descent parser rather than eval/Function, so a hostile catalog
// cannot run code and a malformed one is rejected rather than half-applied.

var ENGLISH_PLURAL = { nplurals: 2, plural: function(n) { return n !== 1 ? 1 : 0 } }

function tokenizePlural(text) {
  var tokens = []
  var i = 0
  while (i < text.length) {
    var c = text.charAt(i)
    if (c === " " || c === "\t" || c === "\n") { i++; continue }
    if (c >= "0" && c <= "9") {
      var j = i
      while (j < text.length && text.charAt(j) >= "0" && text.charAt(j) <= "9") j++
      tokens.push({ type: "num", value: Number(text.slice(i, j)) })
      i = j
      continue
    }
    if (c === "n") { tokens.push({ type: "n" }); i++; continue }
    var two = text.substr(i, 2)
    if (["||", "&&", "==", "!=", "<=", ">="].indexOf(two) !== -1) {
      tokens.push({ type: "op", value: two }); i += 2; continue
    }
    if ("?:()<>+-*/%!".indexOf(c) !== -1) { tokens.push({ type: "op", value: c }); i++; continue }
    throw new Error("unexpected character in plural expression: " + c)
  }
  return tokens
}

function parsePluralExpression(text) {
  var tokens = tokenizePlural(text)
  var pos = 0

  function peek() { return tokens[pos] }
  function take(value) {
    var t = tokens[pos]
    if (!t || (value !== undefined && (t.type !== "op" || t.value !== value))) {
      throw new Error("plural expression: expected " + (value || "token") + " at " + pos)
    }
    pos++
    return t
  }
  function isOp(value) { var t = peek(); return t && t.type === "op" && t.value === value }

  function primary() {
    var t = peek()
    if (!t) throw new Error("plural expression: unexpected end")
    if (t.type === "num") { pos++; var v = t.value; return function() { return v } }
    if (t.type === "n") { pos++; return function(n) { return n } }
    if (isOp("(")) { take("("); var e = ternary(); take(")"); return e }
    throw new Error("plural expression: unexpected " + t.value)
  }
  function unary() {
    if (isOp("!")) { take("!"); var e = unary(); return function(n) { return e(n) ? 0 : 1 } }
    return primary()
  }
  function binary(next, ops, apply) {
    return function parse() {
      var left = next()
      while (peek() && peek().type === "op" && ops.indexOf(peek().value) !== -1) {
        var op = take().value
        var right = next()
        left = (function(l, r, o) { return function(n) { return apply(o, l(n), r(n)) } })(left, right, op)
      }
      return left
    }
  }
  var mul = binary(unary, ["*", "/", "%"], function(o, a, b) {
    if (o === "*") return a * b
    if (b === 0) return 0
    return o === "/" ? Math.floor(a / b) : a % b
  })
  var add = binary(mul, ["+", "-"], function(o, a, b) { return o === "+" ? a + b : a - b })
  var rel = binary(add, ["<", ">", "<=", ">="], function(o, a, b) {
    if (o === "<") return a < b ? 1 : 0
    if (o === ">") return a > b ? 1 : 0
    if (o === "<=") return a <= b ? 1 : 0
    return a >= b ? 1 : 0
  })
  var eq = binary(rel, ["==", "!="], function(o, a, b) { return (o === "==" ? a === b : a !== b) ? 1 : 0 })
  var and = binary(eq, ["&&"], function(o, a, b) { return a && b ? 1 : 0 })
  var or = binary(and, ["||"], function(o, a, b) { return a || b ? 1 : 0 })
  function ternary() {
    var cond = or()
    if (!isOp("?")) return cond
    take("?")
    var yes = ternary()
    take(":")
    var no = ternary()
    return function(n) { return cond(n) ? yes(n) : no(n) }
  }

  var fn = ternary()
  if (pos !== tokens.length) throw new Error("plural expression: trailing tokens")
  return fn
}

// Returns { nplurals, plural(n) } or null when the header is absent/invalid.
var pluralRuleCache = {}

function parsePluralForms(header) {
  var text = String(header || "")
  var countMatch = text.match(/nplurals\s*=\s*(\d+)/)
  var exprMatch = text.match(/plural\s*=\s*([^;]+)/)
  if (!countMatch || !exprMatch) return null
  var nplurals = Number(countMatch[1])
  if (!(nplurals >= 1)) return null
  var expr
  try { expr = parsePluralExpression(exprMatch[1]) } catch (e) { return null }
  return {
    nplurals: nplurals,
    plural: function(n) {
      var count = Math.abs(Math.floor(Number(n) || 0))
      var index = Number(expr(count))
      if (!(index >= 0)) index = 0
      if (index >= nplurals) index = nplurals - 1
      return index
    }
  }
}

// ---------------------------------------------------------------------------
// Catalog validation. A catalog is a plain object; the "" entry is a header
// object; every other value is a non-empty string or a plural. Anything else
// is dropped entry-by-entry so one bad line does not lose the whole file.
//
// Plurals arrive as an array of forms (po2json) or as an object
// { msgid_plural, msgstr: [forms] } (msgunfmt output and i18n.json). Both
// are normalized to { msgstr: [forms], "plural-forms": rule }, where the
// rule is the entry's own "plural-forms" or else the catalog header's. The
// rule travels with the entry, so a domain that folds catalogs of several
// locales (es_MX over es, or a LANGUAGE list) picks each entry's form with
// the rule of the language it was written in.

function headerPluralRule(header) {
  if (!header || typeof header !== "object") return ""
  var rule = header["plural-forms"] || header["Plural-Forms"]
  return typeof rule === "string" ? rule : ""
}

function sanitizePlural(forms, rule) {
  if (!Array.isArray(forms) || forms.length === 0) return null
  var translated = false
  for (var i = 0; i < forms.length; i++) {
    if (typeof forms[i] !== "string") return null
    if (forms[i] !== "") translated = true
  }
  // Every form empty means untranslated: let the English source answer.
  if (!translated) return null
  var entry = { msgstr: forms.slice() }
  if (rule) entry["plural-forms"] = rule
  return entry
}

function sanitizeCatalog(raw) {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) return null
  var out = {}
  var header = raw[""]
  if (header && typeof header === "object" && !Array.isArray(header)) out[""] = header
  var catalogRule = headerPluralRule(out[""])
  for (var key in raw) {
    if (!Object.prototype.hasOwnProperty.call(raw, key) || key === "") continue
    var value = raw[key]
    if (typeof value === "string") {
      if (value !== "") out[key] = value
      continue
    }
    var plural = null
    if (Array.isArray(value)) {
      plural = sanitizePlural(value, catalogRule)
    } else if (value && typeof value === "object") {
      var own = typeof value["plural-forms"] === "string" ? value["plural-forms"] : ""
      if (typeof value.msgstr === "string") {
        if (value.msgstr !== "") out[key] = value.msgstr
        continue
      }
      plural = sanitizePlural(value.msgstr, own || catalogRule)
    }
    if (plural) out[key] = plural
  }
  return out
}

function pluralRule(text) {
  var key = String(text || "")
  if (!key) return null
  if (!Object.prototype.hasOwnProperty.call(pluralRuleCache, key)) pluralRuleCache[key] = parsePluralForms(key)
  return pluralRuleCache[key]
}

// Locale catalogs that apply, in the user's preference order. byLocale is
// an i18n.json-shaped object ({ "es": catalog, "pt-BR": catalog }); keys are
// normalized like the candidates, so "pt-BR" and "pt_BR" are the same. Every
// matching catalog is returned, not just the first: a partial es_MX catalog
// still falls back to es per string.
function selectLocaleCatalogs(byLocale, candidates) {
  var list = []
  if (!byLocale || typeof byLocale !== "object" || Array.isArray(byLocale)) return list
  var byNormalized = {}
  for (var key in byLocale) {
    if (!Object.prototype.hasOwnProperty.call(byLocale, key)) continue
    var normalized = normalizeLocale(key)
    if (normalized && byNormalized[normalized] === undefined) byNormalized[normalized] = byLocale[key]
  }
  var wanted = Array.isArray(candidates) ? candidates : []
  for (var i = 0; i < wanted.length; i++) {
    var locale = normalizeLocale(wanted[i])
    var catalog = byNormalized[locale]
    if (!locale || !catalog || typeof catalog !== "object" || Array.isArray(catalog)) continue
    var seen = false
    for (var j = 0; j < list.length; j++) if (list[j].locale === locale) seen = true
    if (!seen) list.push({ locale: locale, catalog: catalog })
  }
  return list
}

// ---------------------------------------------------------------------------
// Registry. Holds every owner's catalogs and links, and derives:
//   merged[domain]  one catalog per domain, owners folded by precedence
//   global          every domain folded into one map, parents before children
//   parents         child domain -> parent domain
// Derived state is rebuilt on every change; catalogs are small and changes
// are rare (login, plugin toggles), so simplicity wins over incrementality.

function createRegistry() {
  var owners = {}          // ownerId -> { catalogs, links, precedence, order }
  var nextOrder = 0
  var state = { revision: 0, merged: {}, global: {}, parents: {} }

  // The startup cache is registered as an ordinary owner at the lowest
  // precedence so it can answer lookups for the frames before the live
  // sources register. It is a stand-in per domain: a domain's cached copy is
  // retired once a live source has registered that domain (or the caller
  // says the domain has no live source any more), and never comes back for
  // the life of the registry. Everything else stays cached, so a small
  // plugin catalog arriving first does not throw away the system catalog
  // that is still loading.
  var CACHE_OWNER = "cache"
  var retired = {}         // domain -> true once its cached copy is retired

  function hasOwn(object, key) {
    return Object.prototype.hasOwnProperty.call(object, key)
  }

  // Fold a list of owners into { merged, parents, global }.
  function computeState(list) {
    // Lower precedence number wins. Among equals, the later registration
    // wins, which is what lets a pack refresh itself by re-registering.
    list = list.slice().sort(function(a, b) {
      return a.precedence !== b.precedence ? b.precedence - a.precedence : a.order - b.order
    })

    var merged = {}
    var parents = {}
    var domainOrder = []
    for (var i = 0; i < list.length; i++) {
      var owner = list[i]
      for (var domain in owner.catalogs) {
        if (!merged[domain]) { merged[domain] = {}; domainOrder.push(domain) }
        var cat = owner.catalogs[domain]
        for (var key in cat) merged[domain][key] = cat[key]
      }
      for (var child in owner.links) parents[child] = owner.links[child]
    }

    // Global merge: a domain's ancestors are folded before it, so a clone's
    // translation shadows the original's for unbound callers.
    var global = {}
    var folded = {}
    function fold(domain, depth) {
      if (folded[domain] || depth > 16) return
      folded[domain] = true
      if (parents[domain] && merged[parents[domain]]) fold(parents[domain], depth + 1)
      var cat = merged[domain]
      for (var key in cat) if (key !== "") global[key] = { value: cat[key], domain: domain }
    }
    for (var o = 0; o < domainOrder.length; o++) fold(domainOrder[o], 0)

    return { merged: merged, global: global, parents: parents }
  }

  function ownerList(excludeId) {
    var list = []
    for (var id in owners) if (id !== excludeId) list.push(owners[id])
    return list
  }

  function rebuild() {
    var next = computeState(ownerList())
    state.merged = next.merged
    state.global = next.global
    state.parents = next.parents
    state.revision++
  }

  // Drop the cached copy of each domain. Returns true when the cache changed.
  function retireDomains(domains) {
    var cache = owners[CACHE_OWNER]
    var changed = false
    for (var i = 0; i < domains.length; i++) {
      var domain = String(domains[i])
      retired[domain] = true
      if (cache && hasOwn(cache.catalogs, domain)) {
        delete cache.catalogs[domain]
        changed = true
      }
    }
    if (cache && Object.keys(cache.catalogs).length === 0) delete owners[CACHE_OWNER]
    return changed
  }

  // True when an owner other than the cache supplies the domain.
  function liveDomain(domain) {
    for (var id in owners) {
      if (id !== CACHE_OWNER && hasOwn(owners[id].catalogs, domain)) return true
    }
    return false
  }

  // Domain chain for a bound caller: the domain, then its parents.
  function chain(domain) {
    var out = []
    var seen = {}
    var current = domain ? String(domain) : ""
    while (current && !seen[current] && out.length < 16) {
      seen[current] = true
      out.push(current)
      current = state.parents[current]
    }
    return out
  }

  // Per-key lookup. Returns { value, domain } or null.
  function lookup(key, domain) {
    var domains = chain(domain)
    for (var i = 0; i < domains.length; i++) {
      var cat = state.merged[domains[i]]
      if (cat && hasOwn(cat, key) && key !== "") {
        return { value: cat[key], domain: domains[i] }
      }
    }
    return hasOwn(state.global, key) ? state.global[key] : null
  }

  function translate(source, options) {
    var opts = options || {}
    var fallback = String(source === undefined || source === null ? "" : source)
    var key = contextKey(opts.context, fallback)
    var hit = lookup(key, opts.domain)
    var value = hit ? hit.value : fallback
    if (value && typeof value === "object") value = value.msgstr[0] || fallback
    return interpolate(value, opts.args)
  }

  function translatePlural(count, singular, plural, options) {
    var opts = options || {}
    var n = Number(count) || 0
    var english = ENGLISH_PLURAL.plural(n) === 0 ? singular : plural
    var key = contextKey(opts.context, String(singular === undefined || singular === null ? "" : singular))
    var hit = lookup(key, opts.domain)
    var text = english
    if (hit && hit.value && typeof hit.value === "object") {
      var forms = hit.value.msgstr
      var rule = pluralRule(hit.value["plural-forms"]) || ENGLISH_PLURAL
      var form = forms[rule.plural(n)]
      if (form === undefined) form = forms[forms.length - 1]
      if (form) text = form
    } else if (hit && typeof hit.value === "string") {
      text = hit.value
    }
    return interpolate(text, opts.args)
  }

  function cleanCatalogs(catalogs) {
    var clean = {}
    var raw = catalogs && typeof catalogs === "object" ? catalogs : {}
    for (var domain in raw) {
      var cat = sanitizeCatalog(raw[domain])
      if (cat) clean[String(domain)] = cat
    }
    return clean
  }

  function cleanLinks(rawLinks) {
    var links = {}
    var source = rawLinks && typeof rawLinks === "object" ? rawLinks : {}
    for (var child in source) {
      if (typeof source[child] === "string" && source[child] && source[child] !== child) {
        links[String(child)] = source[child]
      }
    }
    return links
  }

  function putOwner(ownerId, clean, links, precedence) {
    owners[ownerId] = {
      catalogs: clean,
      links: links,
      precedence: typeof precedence === "number" ? precedence : 0,
      order: nextOrder++
    }
  }

  // Owners registered by setLocaleCatalogs are named "<ownerId>@<locale>".
  function removeOwnerFamily(ownerId) {
    var removed = false
    var prefix = ownerId + "@"
    for (var id in owners) {
      if (id === CACHE_OWNER) continue
      if (id === ownerId || id.indexOf(prefix) === 0) {
        delete owners[id]
        removed = true
      }
    }
    return removed
  }

  // Replace an owner's whole contribution atomically.
  //   catalogs   { domain: catalog }
  //   options    { links: { child: parent }, precedence: number }
  function setCatalogs(ownerId, catalogs, options) {
    var opts = options || {}
    var id = String(ownerId)
    if (id === CACHE_OWNER) return "rejected"
    var clean = cleanCatalogs(catalogs)
    var existing = !!owners[id]
    putOwner(id, clean, cleanLinks(opts.links), opts.precedence)
    retireDomains(Object.keys(clean))
    rebuild()
    return existing ? "replaced" : "added"
  }

  // Register one domain's catalogs for several locales at once, most
  // preferred first ({ locale, catalog } items, see selectLocaleCatalogs).
  // Each locale becomes its own owner one precedence step below the
  // previous, so lookups fall back per string: a key missing from es_MX is
  // answered by es, then by the next LANGUAGE entry. Replaces every owner
  // this ownerId registered before.
  function setLocaleCatalogs(ownerId, domain, list, options) {
    var opts = options || {}
    var id = String(ownerId)
    var name = String(domain)
    if (id === CACHE_OWNER) return 0
    var base = typeof opts.precedence === "number" ? opts.precedence : 0
    var hadAny = removeOwnerFamily(id)
    var registered = 0
    var items = Array.isArray(list) ? list : []
    for (var i = 0; i < items.length; i++) {
      var item = items[i]
      if (!item || !item.locale) continue
      var catalogs = {}
      catalogs[name] = item.catalog
      var clean = cleanCatalogs(catalogs)
      if (!clean[name]) continue
      putOwner(id + "@" + item.locale, clean, {}, base + i)
      registered++
    }
    if (registered > 0) retireDomains([name])
    if (registered > 0 || hadAny) rebuild()
    return registered
  }

  // Removes the owner and every per-locale owner registered under its id.
  function clearOwner(ownerId) {
    var id = String(ownerId)
    if (id === CACHE_OWNER || !removeOwnerFamily(id)) return false
    rebuild()
    return true
  }

  // Retire cached domains by name: for a source that finished loading and
  // turned out to have nothing (no system catalog for the language).
  function retireCached(domains) {
    var changed = retireDomains(Array.isArray(domains) ? domains : [])
    if (changed) rebuild()
    return changed
  }

  // Retire every cached domain not in keep: once the plugin scan is done,
  // a cached domain whose plugin is gone or disabled has no live source.
  function settleCache(keep) {
    var cache = owners[CACHE_OWNER]
    if (!cache) return false
    var keepSet = {}
    var wanted = Array.isArray(keep) ? keep : []
    for (var i = 0; i < wanted.length; i++) keepSet[String(wanted[i])] = true
    var stale = []
    for (var domain in cache.catalogs) if (!keepSet[domain]) stale.push(domain)
    return retireCached(stale)
  }

  function cachedDomains() {
    var cache = owners[CACHE_OWNER]
    return cache ? Object.keys(cache.catalogs) : []
  }

  // Serializable view of the merged state, for the startup cache. Cached
  // domains still waiting for their live source are included, so a snapshot
  // written before the system catalog loads does not lose it; retired ones
  // are already gone from the cache owner.
  function snapshot() {
    var view = computeState(ownerList())
    var catalogs = {}
    for (var domain in view.merged) catalogs[domain] = view.merged[domain]
    var links = {}
    for (var child in view.parents) links[child] = view.parents[child]
    return { version: 1, catalogs: catalogs, links: links }
  }

  // Load a startup snapshot as the cache owner. Domains a live source has
  // already registered, or whose cached copy was retired, are skipped:
  // writing the cache re-triggers the FileView that loads it, and that
  // reload must not resurrect a domain that was just disabled.
  function loadSnapshot(snap) {
    if (!snap || typeof snap !== "object" || snap.version !== 1) return false
    var raw = snap.catalogs && typeof snap.catalogs === "object" ? snap.catalogs : {}
    var pending = {}
    var count = 0
    for (var domain in raw) {
      if (!hasOwn(raw, domain) || retired[domain] || liveDomain(domain)) continue
      pending[domain] = raw[domain]
      count++
    }
    if (count === 0) return false
    var clean = cleanCatalogs(pending)
    if (Object.keys(clean).length === 0) return false
    putOwner(CACHE_OWNER, clean, cleanLinks(snap.links), 1000)
    rebuild()
    return true
  }

  return {
    setCatalogs: setCatalogs,
    setLocaleCatalogs: setLocaleCatalogs,
    clearOwner: clearOwner,
    retireCached: retireCached,
    settleCache: settleCache,
    cachedDomains: cachedDomains,
    lookup: lookup,
    chain: chain,
    translate: translate,
    translatePlural: translatePlural,
    snapshot: snapshot,
    loadSnapshot: loadSnapshot,
    domains: function() { var out = []; for (var d in state.merged) out.push(d); return out },
    owners: function() { var out = []; for (var o in owners) out.push(o); return out },
    revision: function() { return state.revision }
  }
}

if (typeof module !== "undefined") module.exports = {
  CONTEXT_SEPARATOR: CONTEXT_SEPARATOR,
  normalizeLocale: normalizeLocale,
  localeCandidates: localeCandidates,
  languageCandidates: languageCandidates,
  interpolate: interpolate,
  contextKey: contextKey,
  parsePluralForms: parsePluralForms,
  sanitizeCatalog: sanitizeCatalog,
  selectLocaleCatalogs: selectLocaleCatalogs,
  createRegistry: createRegistry
}
