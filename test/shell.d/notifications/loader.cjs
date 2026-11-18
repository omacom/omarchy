// Load a notification-plugin JS module the way QML does: `.pragma library`
// dropped, each `.import "X.js" as Alias` resolved to that module's scope.
const fs = require('node:fs'), vm = require('node:vm'), path = require('node:path')
const dir = path.join(__dirname, '..', '..', '..', 'shell', 'plugins', 'notifications')
const cache = {}
function load(name) {
  if (cache[name]) return cache[name]
  const scope = { console, Qt: { openUrlExternally: u => u } }
  const code = fs.readFileSync(path.join(dir, name + '.js'), 'utf8')
    .replace(/^\.pragma.*$/mg, '')
    .replace(/^\.import "([^"]+)" as (\w+)$/mg, (_, file, alias) => {
      scope[alias] = load(file.replace(/\.js$/, '')); return ''
    })
  vm.createContext(scope)
  vm.runInContext(code, scope)
  return cache[name] = scope
}
load.dir = dir
module.exports = load
