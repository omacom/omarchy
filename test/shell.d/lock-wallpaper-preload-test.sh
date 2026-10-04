#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const read = (file) => fs.readFileSync(path.join(root, file), 'utf8')
const media = read('shell/Ui/BackgroundMedia.qml')
const view = read('shell/plugins/lock/LockView.qml')
const service = read('shell/plugins/lock/Service.qml')

assert(/^import qs\.Ui$/m.test(service), 'lock preload imports its shared wallpaper types')

// The preload and view consume the same per-screen resolution, cache URL,
// physical decode size and fill metadata, including responsive variants.
assert(
  media.includes('property bool cached: version === 0') && media.includes('cache: root.cached'),
  'background media caches unversioned images, and versioned ones on request'
)
assert(
  /cached: true\s*constrainDecode: true\s*decodeSize: Qt\.size\(Math\.round\(width \* Screen\.devicePixelRatio\), Math\.round\(height \* Screen\.devicePixelRatio\)\)/.test(view),
  'the lock wallpaper waits for its physical size and reads from the cache'
)
assert(
  service.includes('readonly property string lockWallpaperPath: videoBackground ? videoPosterPath : backgroundPath') &&
    service.includes('canonicalPath: root.lockWallpaperPath') &&
    service.includes('refreshToken: root.backgroundVersion') &&
    view.includes('readonly property var resolution: preparedBackground || backgroundResolver') &&
    service.includes('preparedBackground: root.preloadedBackground(lockSurface.screen)'),
  'the lock consumes the same resolved per-screen variant as its preload'
)
assert(
  service.includes('path: preloadResolver.ready ? preloadResolver.resolvedPath : ""') &&
    view.includes('path: root.loadBackground && root.resolution.ready ? root.resolution.resolvedPath : ""') &&
    /version: root\.backgroundVersion/.test(service) && /version: root\.backgroundVersion/.test(view) &&
    service.includes('Math.round(preload.width * preload.modelData.devicePixelRatio)') &&
    service.includes('Math.round(preload.height * preload.modelData.devicePixelRatio)') &&
    service.includes('fill: preloadResolver.fill') && view.includes('fill: root.resolution.fill') &&
    service.includes('backdrop: preloadResolver.backdrop') && view.includes('backdrop: root.resolution.backdrop'),
  'the preload matches the lock view cache version, physical decode size, fill and backdrop'
)

// A wallpaper overwritten in place keeps its path, so the version, which is
// part of the cached URL, follows the file's mtime and size as well.
assert(
  service.includes('stat -Lc %Y:%s') &&
    /\} else if \(signature !== root\.backgroundSignature\) \{\s*root\.backgroundSignature = signature\s*root\.backgroundVersion \+= 1/.test(service),
  'an overwritten wallpaper bumps the lock wallpaper version'
)
JS
