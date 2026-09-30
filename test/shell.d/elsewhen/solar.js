// GlobeModel.js and Sun.js keep QML's .pragma/.import headers, so node
// strips those lines and evaluates the rest.
const fs = require('fs')
const path = require('path')

const dir = path.join(__dirname, '../../../shell/plugins/panels/elsewhen')

function load(file, scope) {
  const source = fs.readFileSync(path.join(dir, file), 'utf8').replace(/^\.(pragma|import) .*$/gm, '')
  const module = { exports: {} }
  new Function('module', ...Object.keys(scope), source)(module, ...Object.values(scope))
  return module.exports
}

const Solar = load('GlobeModel.js', {})
const Sun = load('Sun.js', { Solar })

module.exports = { Solar, Sun }
