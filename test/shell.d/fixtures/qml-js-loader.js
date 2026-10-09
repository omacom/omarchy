// Loads a QML JavaScript library under Node. QML resolves `.pragma library`
// and `.import "Other.js" as Other` itself; Node knows neither, so this turns
// each .import into a load of the sibling file, caches every library once (as
// `.pragma library` does), and returns what the file's module.exports guard
// exports.
const fs = require('fs')
const path = require('path')

const cache = new Map()

function loadQmlJs(file) {
  const resolved = path.resolve(file)
  if (cache.has(resolved)) return cache.get(resolved)

  const imports = []
  const source = fs.readFileSync(resolved, 'utf8').replace(/^\.(pragma|import)\b(.*)$/gm, (line, kind, rest) => {
    if (kind === 'import') {
      const m = /^\s+"([^"]+\.js)"\s+as\s+(\w+)\s*$/.exec(rest)
      if (!m) throw new Error(`${resolved}: unsupported import: ${line}`)
      imports.push({ name: m[2], file: path.join(path.dirname(resolved), m[1]) })
    }
    return ''
  })

  const module = { exports: {} }
  cache.set(resolved, module.exports)
  const names = imports.map(i => i.name)
  const values = imports.map(i => loadQmlJs(i.file))
  new Function('module', ...names, source)(module, ...values)
  cache.set(resolved, module.exports)
  return module.exports
}

module.exports = { loadQmlJs }
