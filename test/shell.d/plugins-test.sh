#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const pluginsDir = path.join(root, 'shell/plugins')
const kindEntryPoints = {
  'bar': 'bar',
  'bar-widget': 'barWidget',
  'menu': 'menu',
  'overlay': 'overlay',
  'panel': 'panel',
  'service': 'service'
}

function isPlainObject(value) {
  return !!value && typeof value === 'object' && !Array.isArray(value)
}

function walk(dir) {
  const rows = []
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name)
    if (entry.isDirectory()) {
      rows.push(...walk(fullPath))
    } else if (entry.isFile() && (entry.name === 'manifest.json' || entry.name.endsWith('.manifest.json'))) {
      rows.push(fullPath)
    }
  }
  return rows.sort()
}

function relativeFromPlugins(filePath) {
  return path.relative(pluginsDir, filePath).split(path.sep).join('/')
}

function sourceDirForManifest(manifestPath) {
  return path.dirname(manifestPath)
}

const errors = []

function check(condition, detail) {
  if (!condition) errors.push(detail)
}

function assertSafeEntryPoint(manifest, manifestPath, key, value) {
  const label = `${manifest.id} ${key} entry point`
  check(typeof value === 'string' && value.length > 0, `${label} must be a non-empty string`)
  check(!path.isAbsolute(value), `${label} must be relative`)
  check(!String(value).split(/[\\/]+/).includes('..'), `${label} must stay inside plugin source`)
  check(fs.existsSync(path.join(sourceDirForManifest(manifestPath), String(value))), `${label} file must exist`)
}

const manifests = walk(pluginsDir)
const manifestPaths = manifests.map(relativeFromPlugins)
const manifestSet = new Set(manifestPaths)
const groupedPluginRoots = new Set(['panels', 'services'])

assert(manifests.length > 0, 'plugin manifests are present')

for (const entry of fs.readdirSync(pluginsDir, { withFileTypes: true })) {
  if (!entry.isDirectory() || groupedPluginRoots.has(entry.name)) continue
  check(
    manifestSet.has(`${entry.name}/manifest.json`),
    `top-level plugin ${entry.name} must have a manifest`
  )
}

for (const groupName of groupedPluginRoots) {
  const groupRoot = path.join(pluginsDir, groupName)
  if (!fs.existsSync(groupRoot)) continue

  for (const entry of fs.readdirSync(groupRoot, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue
    check(
      manifestSet.has(`${groupName}/${entry.name}/manifest.json`),
      `${groupName} plugin ${entry.name} must have a manifest`
    )
  }
}

for (const manifestPath of manifestPaths) {
  const depth = manifestPath.split('/').length
  check(depth >= 2 && depth <= 3, `${manifestPath} must be discoverable by PluginRegistry`)
}

const ids = new Set()
for (const manifestPath of manifests) {
  const relativePath = relativeFromPlugins(manifestPath)
  let manifest = null
  try {
    manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'))
  } catch (error) {
    errors.push(`${relativePath} must parse as JSON: ${error.message}`)
    continue
  }

  check(isPlainObject(manifest), `${relativePath} must parse to an object`)
  if (!isPlainObject(manifest)) continue

  check(manifest.schemaVersion === 1, `${relativePath} must use schema version 1`)

  for (const field of ['id', 'name', 'version', 'description']) {
    check(typeof manifest[field] === 'string' && manifest[field].length > 0, `${manifest.id || relativePath} must have ${field}`)
  }

  check(String(manifest.id).startsWith('omarchy.'), `${manifest.id} must use the first-party namespace`)
  check(!String(manifest.id).includes('/') && !String(manifest.id).includes('..'), `${manifest.id} must be safe as a plugin id`)
  check(!ids.has(manifest.id), `${manifest.id} must be unique`)
  ids.add(manifest.id)

  check(Array.isArray(manifest.kinds) && manifest.kinds.length > 0, `${manifest.id} must declare plugin kinds`)
  check(
    JSON.stringify([...new Set(manifest.kinds || [])]) === JSON.stringify(manifest.kinds || []),
    `${manifest.id} must not duplicate plugin kinds`
  )
  check(isPlainObject(manifest.entryPoints), `${manifest.id} must have an entryPoints object`)

  for (const kind of manifest.kinds || []) {
    check(kindEntryPoints[kind], `${manifest.id} must use supported plugin kind ${kind}`)
    const entryPointKey = kindEntryPoints[kind]
    check(manifest.entryPoints && manifest.entryPoints[entryPointKey], `${manifest.id} must declare ${entryPointKey} entry point`)
  }

  for (const key of Object.keys(manifest.entryPoints || {})) {
    check(Object.values(kindEntryPoints).includes(key), `${manifest.id} entry point ${key} must be a supported key`)
    assertSafeEntryPoint(manifest, manifestPath, key, manifest.entryPoints[key])
  }

  if (manifest.keepLoaded !== undefined) {
    check(typeof manifest.keepLoaded === 'boolean', `${manifest.id} keepLoaded must be boolean when present`)
  }

  if ((manifest.kinds || []).includes('bar-widget')) {
    check(isPlainObject(manifest.barWidget), `${manifest.id} must have barWidget metadata`)
    for (const field of ['displayName', 'description', 'category']) {
      check(
        manifest.barWidget && typeof manifest.barWidget[field] === 'string' && manifest.barWidget[field].length > 0,
        `${manifest.id} barWidget metadata must have ${field}`
      )
    }
    check(manifest.barWidget && typeof manifest.barWidget.allowMultiple === 'boolean', `${manifest.id} barWidget allowMultiple must be boolean`)
    if (manifest.barWidget && manifest.barWidget.defaultSection !== undefined) {
      check(
        ['left', 'center', 'right'].includes(manifest.barWidget.defaultSection),
        `${manifest.id} barWidget defaultSection must be left, center, or right`
      )
    }
  }

  if (relativePath.endsWith('.manifest.json')) {
    check(JSON.stringify(manifest.kinds) === JSON.stringify(['bar-widget']), `${manifest.id} sibling manifest must be a bar widget`)
  }

  const clonePaths = manifest.omarchy?.clonePaths
  if (clonePaths !== undefined) {
    check(Array.isArray(clonePaths), `${manifest.id} omarchy.clonePaths must be an array`)
    const cloneTargets = new Set()
    for (const clonePath of Array.isArray(clonePaths) ? clonePaths : []) {
      const valid = isPlainObject(clonePath)
        && typeof clonePath.source === 'string'
        && /^[A-Za-z0-9_./-]+$/.test(clonePath.source)
        && typeof clonePath.target === 'string'
        && /^[A-Za-z0-9_./-]+$/.test(clonePath.target)
        && !clonePath.target.startsWith('/')
        && !clonePath.target.includes('..')
      check(
        valid,
        `${manifest.id} clone paths must have safe source and target paths`
      )
      if (valid) {
        check(
          fs.existsSync(path.resolve(path.dirname(manifestPath), clonePath.source)),
          `${manifest.id} clone source ${clonePath.source} must exist`
        )
        check(!cloneTargets.has(clonePath.target), `${manifest.id} clone target ${clonePath.target} must be unique`)
        cloneTargets.add(clonePath.target)
      }
    }
  }
}

const byId = Object.fromEntries(manifests.map(manifestPath => {
  const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'))
  return [manifest.id, manifest]
}))
for (const [id, section] of Object.entries({
  'omarchy.active-window': 'left',
  'omarchy.dropbox': 'right'
})) {
  check(byId[id]?.barWidget?.defaultSection === section, `${id} must default to the ${section} bar section`)
}
check(byId['omarchy.media']?.barWidget?.defaultSection === undefined, 'omarchy.media must use the center fallback')

for (const id of ['omarchy.lock', 'omarchy.idle', 'omarchy.polkit', 'omarchy.notifications', 'omarchy.media']) {
  check(byId[id]?.keepLoaded === true, `${id} must stay loaded across plugin reloads`)
}

const shellSource = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
const unloadMatch = shellSource.match(/function unloadPluginServices\(\) \{[\s\S]*?\n  \}/)
check(!!unloadMatch, 'unloadPluginServices is defined')
check(!!unloadMatch && /serviceKeepLoaded/.test(unloadMatch[0]), 'unloadPluginServices honors keepLoaded')
check(
  /function _syncServices\(\) \{[\s\S]*Drop services for plugins that have been disabled/.test(shellSource),
  '_syncServices still drops disabled or removed services'
)

// A truncated or torn user shell.json must not fall back to stock config:
// the next mutation would persist the defaults over the user's file,
// disabling every third-party plugin at once. Keep the last good parse and
// only reset on a genuinely missing file.
check(
  /property var lastUserConfig/.test(shellSource),
  'shell keeps the last valid user shell.json parse'
)
check(
  /if \(user\) \{[\s\S]*?lastUserConfig = user[\s\S]*?else if \(userConfigMissing\)[\s\S]*?lastUserConfig = null[\s\S]*?else if \(lastUserConfig\)/.test(shellSource),
  'shell keeps the last user config when shell.json is empty or invalid'
)
check(
  /id: userConfigFile[\s\S]*?onLoaded: \{[\s\S]*?userConfigMissing = false[\s\S]*?onLoadFailed: function\(error\) \{\s*shell\.userConfigMissing = error === FileViewError\.FileNotFound/.test(shellSource),
  'shell distinguishes a missing shell.json from a truncated one'
)
check(
  /function persistShellConfig[\s\S]*?shellConfig = payload[\s\S]*?lastUserConfig = payload[\s\S]*?setText/.test(shellSource),
  'shell remembers the config it just persisted as the last good user config'
)

assert(errors.length === 0, 'plugin manifests match shell registry contract', errors.join('\n'))
JS

# A 0-byte shell.json is a torn write, not an empty config: the commit path
# must refuse to seed it with defaults rather than overwrite whatever was
# being written.
EMPTY_HOME=$(mktemp -d)
trap 'rm -rf "$EMPTY_HOME"' EXIT
mkdir -p "$EMPTY_HOME/.config/omarchy"
: >"$EMPTY_HOME/.config/omarchy/shell.json"

commit_status=0
HOME="$EMPTY_HOME" OMARCHY_PATH="$ROOT" bash -c "source '$ROOT/bin/omarchy-shell-config'; commit '.'" >/dev/null 2>&1 || commit_status=$?
(( commit_status != 0 )) ||
  fail "omarchy-shell-config refuses to commit over an empty shell.json"
pass "omarchy-shell-config refuses to commit over an empty shell.json"

[[ -e "$EMPTY_HOME/.config/omarchy/shell.json" && ! -s "$EMPTY_HOME/.config/omarchy/shell.json" ]] ||
  fail "omarchy-shell-config leaves the empty shell.json untouched"
pass "omarchy-shell-config leaves the empty shell.json untouched"
