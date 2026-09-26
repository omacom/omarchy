const fs = require('fs')
const path = require('path')

// shell/**/*.js files are QML JS modules (`import "X.js" as X`), not CommonJS
// modules -- QML's module context has no `module`, `require`, or `exports`,
// and referencing `module` there can crash the Qt QML engine (see #12677,
// #12892). So these files declare plain top-level functions/consts and carry
// no export statement of their own.
//
// The test suite still needs to reach those declarations from Node, so this
// loader reads the source, finds the top-level declaration names, and
// evaluates the file as a function body that returns them as an object --
// entirely outside the file itself, so shell/ stays QML-safe.
function requireFromRoot(root, relativePath) {
  const filePath = path.join(root, relativePath)
  const source = fs.readFileSync(filePath, 'utf8')

  const names = new Set()
  const declaration = /^(?:function\s+(\w+)\s*\(|(?:const|let|var)\s+(\w+)\s*=)/gm
  let match
  while ((match = declaration.exec(source))) {
    names.add(match[1] || match[2])
  }

  const body = `${source}\nreturn {${[...names].map((name) => `${name}: ${name}`).join(', ')}}`
  return new Function(body)()
}

module.exports = { requireFromRoot }
