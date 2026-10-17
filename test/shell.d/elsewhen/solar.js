// Sun.js imports GlobeModel.js as Solar, so it is loaded with that binding.
const path = require('path')
const { requireFromRoot } = require('../js-model-loader.js')

const root = path.join(__dirname, '../../..')
const elsewhen = 'shell/plugins/panels/elsewhen'

const Solar = requireFromRoot(root, `${elsewhen}/GlobeModel.js`)
const Sun = requireFromRoot(root, `${elsewhen}/Sun.js`, { Solar })

module.exports = { Solar, Sun }
