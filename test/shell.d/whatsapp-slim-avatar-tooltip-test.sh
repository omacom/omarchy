#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command jq
require_command node

EXT_DIR="$ROOT/default/chromium/extensions/whatsapp-slim"

# The avatar-tooltip content script must be registered so its rail-mode hover
# tooltip actually runs, and it must load after WhatsApp's DOM exists.
jq -e '
  .content_scripts[] |
  select(.matches == ["https://web.whatsapp.com/*"]) |
  .js == ["avatar-tooltip.js"] and .run_at == "document_idle"
' "$EXT_DIR/manifest.json" >/dev/null ||
  fail "WhatsApp registers the avatar-tooltip script at document_idle"

# A minimal DOM/matchMedia harness drives avatar-tooltip.js through its rail
# gating, name extraction, dynamic-row tagging, and viewport clamping without
# pulling in a full browser.
EXT_DIR="$EXT_DIR" run_node_test <<'JS'
const fs = require('fs')

class MockElement {
  constructor(tag) {
    this.nodeType = 1
    this.tagName = tag
    this.style = {}
    this.attrs = new Map()
    this.dataset = {}
    this.children = []
    this.listeners = {}
    this._text = ''
    this._offsetW = 0
    this._offsetH = 0
    this._rect = { right: 0, top: 0 }
  }

  set id(v) { this.attrs.set('id', String(v)) }
  get id() { return this.attrs.get('id') }

  set textContent(v) { this._text = String(v) }
  get textContent() { return this._text }

  get offsetWidth() { return this._offsetW }
  get offsetHeight() { return this._offsetH }

  setAttribute(k, v) { this.attrs.set(k, String(v)) }
  getAttribute(k) { return this.attrs.get(k) }

  appendChild(child) {
    child.parent = this
    this.children.push(child)
    return child
  }

  addEventListener(type, fn) {
    (this.listeners[type] ||= []).push(fn)
  }

  emit(type) {
    for (const fn of this.listeners[type] || []) fn()
  }

  matches(sel) {
    // [attr="value"] with optional *=
    let m = sel.match(/^\[([a-z-]+)(\*?)=?"?([^"\]]*)"?\]$/)
    if (m) {
      const [, attr, star, val] = m
      const actual = this.attrs.get(attr) || ''
      return star ? actual.includes(val) : actual === val
    }
    // tag[attr] (attribute presence), e.g. img[title]
    m = sel.match(/^([a-z]+)\[([a-z-]+)\]$/)
    if (m) {
      return this.tagName === m[1] && this.attrs.has(m[2])
    }
    // bare tag name, e.g. span
    if (/^[a-z]+$/.test(sel)) return this.tagName === sel
    return false
  }

  querySelector(sel) {
    return this._collect(sel, this.matches(sel) ? this : null, true)[0] || null
  }

  querySelectorAll(sel) {
    return this._collect(sel, null, true)
  }

  getBoundingClientRect() {
    return this._rect
  }

  _collect(sel, include, recurse) {
    const out = []
    const visit = (node) => {
      if (node.matches(sel)) out.push(node)
      if (recurse) for (const c of node.children) visit(c)
    }
    if (include) visit(include)
    else for (const c of this.children) visit(c)
    return out
  }
}

function makeCell(options = {}) {
  const cell = new MockElement('div')
  cell.attrs.set('data-testid', 'cell-frame-container')
  cell._rect = { right: options.right ?? 90, top: options.top ?? 10 }

  const img = new MockElement('img')
  if (options.title) img.setAttribute('title', options.title)
  cell.appendChild(img)
  cell._img = img

  if (options.avatarLabel) {
    const label = new MockElement('span')
    label.setAttribute('aria-label', options.avatarLabel)
    cell.appendChild(label)
  }

  return cell
}

// --- MatchMedia harness ---------------------------------------------------
const listeners = []
const query = {
  matches: false,
  addEventListener: (type, fn) => { if (type === 'change') listeners.push(fn) },
}
function setRail(on) {
  query.matches = on
  for (const fn of listeners) fn({ matches: on })
}

// --- Window / document harness -------------------------------------------
const window = { innerWidth: 400, innerHeight: 300, matchMedia: () => query }
global.window = window

const documentElement = new MockElement('html')
let tip = null
const paneSide = new MockElement('div')
paneSide.attrs.set('id', 'pane-side')

global.document = {
  documentElement,
  createElement: (tag) => new MockElement(tag),
  querySelector: (sel) => (sel === '#pane-side' ? paneSide : documentElement),
}

const origAppend = documentElement.appendChild.bind(documentElement)
documentElement.appendChild = (child) => {
  if (child.id === 'wa-slim-tooltip') {
    tip = child
    tip._offsetW = 120
    tip._offsetH = 20
  }
  return origAppend(child)
}

// --- MutationObserver harness --------------------------------------------
let ioCallback = null
global.MutationObserver = class {
  constructor(cb) { ioCallback = cb }
  observe() {}
  disconnect() {}
}
function addNodes(parent, ...nodes) {
  for (const n of nodes) parent.appendChild(n)
  ioCallback([{ addedNodes: nodes }])
}

// --- Load the script ------------------------------------------------------
// Seed one chat row already present at load time so the script's initial scan
// tags it; dynamic rows added later exercise the MutationObserver path.
const seed = makeCell({ title: 'Alice', right: 90, top: 10 })
paneSide.appendChild(seed)

eval(fs.readFileSync(`${process.env.EXT_DIR}/avatar-tooltip.js`, 'utf8'))

if (!tip) fail('whatsapp-slim avatar tooltip element is created')

// --- Rail gating ----------------------------------------------------------
setRail(false)
seed.emit('mouseenter')
if (tip.style.display === 'block') {
  fail('avatar tooltip stays hidden outside rail mode')
} else {
  pass('avatar tooltip stays hidden outside rail mode')
}

setRail(true)
seed.emit('mouseenter')
if (tip.style.display !== 'block') {
  fail('avatar tooltip shows on hover in rail mode')
} else {
  pass('avatar tooltip shows the contact name on hover in rail mode')
  if (tip.textContent === 'Alice') {
    pass('avatar tooltip shows the contact name from the avatar title')
  } else {
    fail('avatar tooltip shows the contact name', `got: ${tip.textContent}`)
  }
}

// --- Unread badge must not masquerade as the name -------------------------
const unread = makeCell({ title: '2', avatarLabel: '1 unread' })
const unreadName = new MockElement('span')
unreadName._text = 'Bob'
unread.appendChild(unreadName)
addNodes(paneSide, unread)
unread.emit('mouseenter')
if (tip.textContent !== 'Bob') {
  fail('avatar tooltip ignores unread badge and uses the contact name', `got: ${tip.textContent}`)
} else {
  pass('avatar tooltip ignores unread badge and uses the contact name')
}

// --- Dynamic rows are tagged when added ----------------------------------
const dyn = makeCell({ title: 'Carol', right: 40, top: 60 })
addNodes(paneSide, dyn)
dyn.emit('mouseenter')
if (tip.textContent === 'Carol' && tip.style.display === 'block') {
  pass('avatar tooltip tags dynamically added chat rows')
} else {
  fail('avatar tooltip tags dynamically added chat rows')
}

// --- Name is re-read each hover (not a stale cache) -----------------------
const reused = makeCell({ title: 'Dave' })
addNodes(paneSide, reused)
reused.emit('mouseenter')
if (tip.textContent !== 'Dave') {
  fail('avatar tooltip re-reads the current name on hover')
} else {
  pass('avatar tooltip re-reads the current name on hover')
}
reused._img.setAttribute('title', 'Eve')
reused.emit('mouseenter')
if (tip.textContent === 'Eve') {
  pass('avatar tooltip picks up a reused row\u0027s updated name')
} else {
  fail('avatar tooltip picks up a reused row\u0027s updated name', `got: ${tip.textContent}`)
}

// --- Viewport clamping on both axes ---------------------------------------
const edge = makeCell({ title: 'A very long contact name', right: 380, top: 290 })
addNodes(paneSide, edge)
edge.emit('mouseenter')
const left = parseInt(tip.style.left, 10)
const topN = parseInt(tip.style.top, 10)
if (left + tip._offsetW <= window.innerWidth && topN + tip._offsetH <= window.innerHeight) {
  pass('avatar tooltip clamps to the viewport on both axes')
} else {
  fail('avatar tooltip clamps to the viewport on both axes', `left:${left} top:${topN}`)
}
JS
