#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

# QML evaluates a shell JS module again for every delegate whose component
# imports it, unless the module is `.pragma library`. While it does, any name
# the module's top level reads or assigns without declaring it walks the
# delegate's context into Qt's list accessor, and when the Repeater's array
# model holds a destroyed object that walk crashes Quickshell (#11727).
# Builtins are no exception: `Math.PI`, `NaN`, `arguments`, `typeof console`,
# `globalThis` and `leaked = 1` all crash Qt 6.11.2 there. `Qt` and `.import`
# aliases are found through the imports first, and `undefined` and `Infinity`
# compile to constants. Code inside a function runs only when something calls
# it, so a module stays safe as long as its top level, and anything that top
# level calls, uses only what the module declares.

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT
export MODULE_LIST="$work_dir/modules"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')

// The header is the run of `.pragma`/`.import` lines, blank lines and
// comments before the first line of code; a directive anywhere else is not one.
// Returns the header's directives and the source with them blanked out, so
// line numbers stay put and nothing after the header changes.
function moduleHeader(source) {
  const lines = source.split('\n')
  const header = { library: false, aliases: [], body: source }
  let inComment = false
  let end = 0
  for (; end < lines.length; end++) {
    let line = lines[end].trim()
    if (inComment) {
      if (!line.includes('*/')) continue
      inComment = false
      line = line.slice(line.indexOf('*/') + 2).trim()
    }
    if (line.startsWith('/*')) {
      if (!line.includes('*/', 2)) {
        inComment = true
        continue
      }
      line = line.slice(line.indexOf('*/', 2) + 2).trim()
    }
    if (line === '' || line.startsWith('//')) continue
    const directive = line.match(/^\.(pragma|import)\s+(.*?)\s*;?\s*(\/\/.*)?$/)
    if (!directive) break
    if (directive[1] === 'pragma' && /^library\b/.test(directive[2])) header.library = true
    const alias = directive[1] === 'import' && directive[2].match(/\bas\s+(\w+)$/)
    if (alias) header.aliases.push(alias[1])
    lines[end] = ''
  }
  header.body = lines.join('\n')
  return header
}

// Runs a module's top level against a global object that records every name
// read or assigned on it. Unknown names answer with a stub so evaluation goes
// on and later lookups are seen too; the names Qt resolves safely answer with
// values of the right type, so branches on them go the way they would in Qt.
// The arrow wrapper keeps the module's declarations local without adding an
// `arguments` of its own. It errs on the safe side in one way: `this.Math`
// at the top level is reported, though Qt survives it.
function contextLookups(source) {
  const { aliases, body } = moduleHeader(source)
  const seen = new Set()
  const stub = new Proxy(function () {}, {
    get: (target, key) => (key === Symbol.toPrimitive ? () => 0 : stub),
    apply: () => stub,
    construct: () => stub
  })
  const objectStub = new Proxy({}, { get: (target, key) => (key === Symbol.toPrimitive ? () => 0 : stub) })
  const safe = new Map([['Qt', objectStub], ['undefined', undefined], ['Infinity', Infinity]])
  for (const alias of aliases) safe.set(alias, objectStub)
  const read = (name) => {
    if (typeof name === 'string' && !safe.has(name)) seen.add(name)
  }
  const write = (name) => {
    if (typeof name === 'string') seen.add(name)
  }
  const global = new Proxy({}, {
    has(target, name) {
      read(name)
      return safe.has(name)
    },
    get(target, name) {
      read(name)
      return safe.has(name) ? safe.get(name) : stub
    },
    set(target, name) {
      write(name)
      return true
    },
    defineProperty(target, name) {
      write(name)
      return true
    }
  })
  try {
    vm.runInContext(`(() => {\n${body}\n})()`, vm.createContext(global), { timeout: 500 })
  } catch (error) {
    seen.add(`(top level did not finish: ${error.message})`)
  }
  return [...seen].sort()
}

// Each snippet was run in Qt 6.11.2 as the module of a delegate whose
// Repeater's model holds a destroyed object: the first group crashes it, the
// second does not.
const crashes = {
  'a typeof module guard': 'if (typeof module !== "undefined") module.exports = { f: f }',
  'a parenthesised guard': 'if (typeof(module) !== "undefined") module["exports"] = { f: f }',
  'a global through globalThis': 'var m = globalThis.module',
  'a builtin': 'var TAU = Math.PI * 2',
  'a builtin reached through a top-level call': 'function tau() { return Math.PI * 2 }\nvar TAU = tau()',
  'NaN': 'var missing = NaN',
  'arguments': 'var x = arguments',
  'an assignment to an undeclared name': 'leaked = 1',
  'a builtin behind a branch on Infinity': 'if (Infinity === 1 / 0) var p = Math.PI',
  'a builtin behind a branch on Qt': 'if (typeof Qt === "object") var p = Math.PI',
  'an assignment to Qt': 'Qt = {}'
}
const safe = {
  'builtins inside a function': 'function tau() { return Math.PI * 2 }',
  'local declarations and literals': 'var a = 1\nconst b = { c: [a, 2], d: "x".toUpperCase(), e: /x+/g }\nvar f = b.c.map(function (x) { return x * 2 })',
  'Qt, undefined and Infinity': 'var hasQt = typeof Qt !== "undefined"\nvar u = undefined\nvar big = Infinity',
  'an .import alias': '.import "Lib.js" as Lib\nvar half = Lib.half',
  'an indented .import alias with a comment': '  .import "Lib.js" as Lib // the library\nvar half = Lib.half'
}
for (const [name, source] of Object.entries(crashes)) {
  assert(contextLookups(source).length > 0, `the module scope check catches ${name}`)
}
for (const [name, source] of Object.entries(safe)) {
  assertDeepEqual(contextLookups(source), [], `the module scope check allows ${name}`)
}
assert(contextLookups('var q = Qt.application.arguments\nwhile (q.length) q.pop()').length > 0, 'the module scope check gives up on a top level that does not finish')
assert(moduleHeader('// Sun position\n.pragma library\n.import "GlobeModel.js" as Solar\n').library, 'a .pragma library header after a comment counts')
assert(!moduleHeader('/*\n.pragma library\n*/\nvar a = 1\n').library, 'a .pragma library inside a comment does not count')
assert(!moduleHeader('var a = 1\n.pragma library\n').library, 'a .pragma library after code does not count')
assert(!moduleHeader('/* note */ var text = `\n.pragma library\n`\n').library, 'a .pragma library after code on a comment line does not count')
assert(contextLookups('var s = `\n.import "Lib.js" as Bar\n`\nif (s.length > 3) var p = Math.PI').length > 0, 'the module scope check leaves directive-like text after the header alone')

function shellModules(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const file = path.join(dir, entry.name)
    if (entry.isDirectory()) return shellModules(file)
    return entry.name.endsWith('.js') ? [file] : []
  })
}

const offenders = []
const checked = []
for (const file of shellModules(path.join(root, 'shell')).sort()) {
  const source = fs.readFileSync(file, 'utf8')
  const header = moduleHeader(source)
  if (header.library) continue
  checked.push(file)
  const names = contextLookups(source)
  if (names.length) offenders.push(`${path.relative(root, file)}: ${names.join(', ')}`)
}
fs.writeFileSync(process.env.MODULE_LIST, checked.map((file) => `${file}\n`).join(''))
assert(checked.length > 30, 'the module scope check finds the shell JS modules', `checked ${checked.length}`)
assert(
  offenders.length === 0,
  'shell JS modules read and assign nothing at their top level that they do not declare',
  offenders.join('\n')
)
JS

# The Node check only sees the paths a module's top level takes against its
# stubs. Where Qt is installed, run the real thing too: a Repeater per module
# whose array model keeps getting a destroyed object, and a delegate that
# imports the module. Qt reports a module whose top level throws and carries
# on, so anything it prints besides the closing line fails the check as well.
qml_bin=$(command -v qml6 || command -v qml || ls /usr/lib/qt6/bin/qml 2>/dev/null || true)
if [[ -z $qml_bin ]]; then
  skip "shell JS modules survive delegate creation in Qt (Qt's qml runtime is not installed)"
  exit 0
fi

repeaters=""
index=0
while IFS= read -r module; do
  (( ++index ))
  printf 'import QtQuick\nimport "file://%s" as Module\nItem { property string label: String(modelData) }\n' "$module" >"$work_dir/Row$index.qml"
  repeaters+="  Repeater { model: root.rows; delegate: Row$index {} }"$'\n'
done <"$MODULE_LIST"

cat >"$work_dir/main.qml" <<QML
import QtQuick
Item {
  id: root
  property var rows: []
  property var held: []
  property bool armed: false
  property int reassigned: 0
  Component { id: row; QtObject {} }
$repeaters
  Timer {
    interval: 20; repeat: true; running: true
    onTriggered: {
      if (!root.armed) {
        var dead = row.createObject(null)
        root.held = [dead]
        dead.destroy()
        root.armed = true
        return
      }
      root.rows = [root.held[0], row.createObject(root)]
      root.armed = false
      if (++root.reassigned >= 10) { console.warn("survived", root.reassigned); Qt.quit() }
    }
  }
}
QML

status=0
output=$(ulimit -c 0; LC_ALL=C.UTF-8 QT_QPA_PLATFORMTHEME= QT_QPA_PLATFORM=offscreen QT_FORCE_STDERR_LOGGING=1 QT_LOGGING_RULES="*.debug=false;*.info=false;*.warning=true;*.critical=true" QT_MESSAGE_PATTERN="%{message}" timeout 60 "$qml_bin" "$work_dir/main.qml" 2>&1) || status=$?
if (( status == 0 )) && [[ $output == "survived 10" ]]; then
  pass "$index shell JS modules survive delegate creation in Qt"
else
  fail "$index shell JS modules survive delegate creation in Qt" "exit $status: $output"
fi
