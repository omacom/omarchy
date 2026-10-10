#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const { choose } = requireFromRoot('shell/plugins/background/BackgroundVariants.js')
const image = (path, width, height) => ({ path, width, height })
const choices = [image('default', 3840, 2160), image('wide', 5120, 2160), image('portrait', 2160, 3840)]
assertEqual(choose(choices, 'default', 1920, 1080, 1), 'default', '16:9 output keeps the default')
assertEqual(choose(choices, 'default', 2560, 1080, 2), 'wide', 'scaled ultrawide output chooses its authored variant')
assertEqual(choose(choices, 'default', 1080, 1920, 2), 'portrait', 'rotated output chooses portrait artwork')
assertEqual(choose(choices, 'default', 1920, 1080, 1), 'default', 'selection on another monitor remains independent')
const resolutions = [image('1080', 1920, 1080), image('4k', 3840, 2160), image('8k', 7680, 4320)]
assertEqual(choose(resolutions, 'default', 1920, 1080, 1), '1080', 'smallest sufficient image wins at equal aspect ratio')
assertEqual(choose(resolutions, 'default', 1920, 1080, 2), '4k', 'physical pixel density controls resolution selection')
const fractional = [image('2560x1600', 2560, 1600), image('3840x2400', 3840, 2400)]
assertEqual(choose(fractional, 'default', 1600, 1000, 1.6), '2560x1600', 'fractional scale does not select an oversized file')
const fs = require('fs')
const backgroundQml = fs.readFileSync(path.join(root, 'shell/plugins/background/Background.qml'), 'utf8')
assert(backgroundQml.includes('pixelScale: panel.devicePixelRatio') && !backgroundQml.includes('screen.devicePixelRatio') && !backgroundQml.includes('modelData.devicePixelRatio'), 'selection and decoding use the fractional window ratio, not the rounded screen ratio')
assert(backgroundQml.includes('known[candidate.path] = { width: candidate.width, height: candidate.height }') && backgroundQml.includes('root.nativeSizes = known'), 'catalog dimensions make selected variant paths loadable')
assert(backgroundQml.includes('version: root.displayedVersion') && backgroundQml.includes('cached: true') && !backgroundQml.includes('reloads'), 'displayed frames keep shared caching with versioned URLs instead of the removed reload mechanism')
const vm = require('vm')
const finish = backgroundQml.match(/  function finishTransition\(\) \{[\s\S]*?\n  \}/)[0]
const prune = backgroundQml.match(/  function pruneNativeSizes\(\) \{[\s\S]*?\n  \}/)[0]
const transition = {
  finishingTransition: true, incomingBackground: 'snapshot', oldBackground: 'old', preparedBackground: 'snapshot',
  displayedBackground: 'default', displayedCandidates: [image('wide', 5120, 2160), image('portrait', 2160, 3840)],
  nativeSizes: { default: {width: 3840, height: 2160}, wide: {width: 5120, height: 2160}, portrait: {width: 2160, height: 3840}, snapshot: {width: 3840, height: 2160} },
  backgroundPanels: {instances: [{backgroundReady: true}, {backgroundReady: false}]}
}
vm.createContext(transition)
const ready = backgroundQml.match(/  readonly property bool ready: \{([\s\S]*?)\n  \}/)[1]
transition.isVideo = () => false
transition.variantCatalog = {busy: true, generation: 1}
transition.resolvedVariantGeneration = 0
transition.backgroundPanels.instances[1].backgroundReady = true
assert(!vm.runInContext('(function() {' + ready + '})()', transition), 'startup readiness waits for the variant catalog even with a decoded default')
transition.variantCatalog.busy = false
assert(!vm.runInContext('(function() {' + ready + '})()', transition), 'startup readiness cannot release the cover between scan exit and candidate application')
transition.resolvedVariantGeneration = 1
transition.backgroundPanels.instances[1].backgroundReady = false
assert(!vm.runInContext('(function() {' + ready + '})()', transition), 'startup readiness waits for every output to present its variant')
transition.backgroundPanels.instances[1].backgroundReady = true
assert(vm.runInContext('(function() {' + ready + '})()', transition), 'startup readiness releases the cover after all variants are presented')
transition.backgroundPanels.instances[1].backgroundReady = false
vm.runInContext(finish + '\n' + prune + '\nfinishTransition()', transition)
assert(transition.finishingTransition && transition.incomingBackground === 'snapshot', 'transition retains the incoming frame until every output is ready')
transition.backgroundPanels.instances[1].backgroundReady = true
vm.runInContext('finishTransition()', transition)
assert(!transition.finishingTransition && !transition.incomingBackground && !transition.preparedBackground, 'transition releases its frames after all outputs are ready')
assertDeepEqual(Object.keys(transition.nativeSizes).sort(), ['default', 'portrait', 'wide'], 'size pruning retains variants for future screen changes and removes snapshots')
assertEqual(choose(resolutions, 'default', 10000, 5625, 1), '8k', 'largest image wins when all require enlargement')
assertEqual(choose([image('huge', 8000, 8000), image('right-shape', 1280, 720)], 'default', 1920, 1080, 1), 'right-shape', 'aspect ratio takes precedence over resolution')
assertEqual(choose([], 'default', 1920, 1080, 1), 'default', 'empty groups fall back to the default')
assertEqual(choose([image('invalid', 0, 0)], 'default', 1920, 1080, 1), 'default', 'invalid dimensions are ignored')
assertEqual(choose(choices, 'default', 0, 0, 1), 'default', 'disconnected output has a safe fallback')
assertEqual(choose([image('b', 1920, 1080), image('a', 1920, 1080)], 'default', 1920, 1080, 1), 'a', 'equal candidates have a deterministic tie break')
JS

require_command python
require_command vipsheader
python - <<'PY'
import importlib.util
import os
from pathlib import Path
import struct
import shutil
import time
import subprocess
import tempfile
from unittest.mock import patch
import zlib

spec = importlib.util.spec_from_file_location('variants', Path(os.environ['ROOT']) / 'shell/plugins/background/variant-images.py')
variants = importlib.util.module_from_spec(spec)
spec.loader.exec_module(variants)

def png(path, width, height):
  def chunk(name, data):
    return struct.pack('!I', len(data)) + name + data + struct.pack('!I', zlib.crc32(name + data))
  path.write_bytes(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('!2I5B', width, height, 8, 2, 0, 0, 0))
          + chunk(b'IDAT', zlib.compress((b'\0' + b'\x00\x88\xff' * width) * height)) + chunk(b'IEND', b''))

with tempfile.TemporaryDirectory(prefix='omarchy-variant-test-') as temporary:
  root = Path(temporary)
  default = root / '01 image $(untouched).png'
  cache = root / 'cache'
  png(default, 160, 90)
  assert variants.candidates(default, cache) == [], 'flat backgrounds should need no probing'
  folder = default.with_suffix('')
  folder.mkdir()
  alternate = folder / 'arbitrary name.PNG'
  png(alternate, 210, 90)
  (folder / 'broken.webp').write_text('invalid')
  (folder / 'video.mp4').write_text('not a still')
  (folder / 'nested').mkdir()
  png(folder / 'nested' / 'ignored.png', 90, 160)
  expected = [{'path': str(default), 'width': 160, 'height': 90},
        {'path': str(alternate), 'width': 210, 'height': 90}]
  assert variants.candidates(default, cache) == expected
  print('ok - discovery reads actual dimensions, handles special paths, skips broken images and ignores deeper nesting')
  with patch.object(variants.subprocess, 'check_output', side_effect=AssertionError('cache miss')):
    assert variants.dimensions(alternate, cache) == expected[1]
  before = len(list(cache.iterdir()))
  png(alternate, 90, 160)
  assert variants.dimensions(alternate, cache)['width'] == 90
  assert len(list(cache.iterdir())) == before
  print('ok - dimension cache avoids repeat probes and replaces entries for changed images')

  blocked = root / 'blocked'
  blocked.write_text('not a directory')
  assert len(variants.candidates(default, blocked / 'cache')) == 2
  with patch.object(Path, 'write_text', side_effect=OSError('disk full')):
    assert variants.dimensions(default, root / 'full-cache') == expected[0]
  print('ok - unwritable and full caches do not discard successfully probed images')

  # Mirror theme-set staging with plain cp -r, which changes mtime and ctime.
  theme = root / 'theme'
  staged = root / 'current' / 'next-theme'
  current = root / 'current' / 'theme'
  (theme / 'backgrounds' / 'design').mkdir(parents=True)
  png(theme / 'backgrounds' / 'design.png', 160, 90)
  png(theme / 'backgrounds' / 'design' / 'wide.png', 210, 90)
  theme_cache = root / 'theme-cache'
  def apply_theme():
    staged.mkdir(parents=True)
    subprocess.run(['cp', '-r', str(theme / 'backgrounds'), str(staged)], check=True)
    shutil.rmtree(current, ignore_errors=True)
    staged.rename(current)
  apply_theme()
  selected = current / 'backgrounds' / 'design.png'
  first = variants.candidates(selected, theme_cache)
  apply_theme()
  with patch.object(variants.subprocess, 'check_output', side_effect=AssertionError('theme reapply cache miss')):
    assert variants.candidates(selected, theme_cache) == first
  assert len(list(theme_cache.iterdir())) == 2
  print('ok - reapplying an unchanged theme reuses dimensions without adding cache entries')

  stale = theme_cache / 'obsolete'
  stale.write_text('old entry')
  expired = time.time() - variants.CACHE_LIFETIME - 1
  os.utime(stale, (expired, expired))
  variants.candidates(selected, theme_cache)
  assert not stale.exists() and len(list(theme_cache.iterdir())) == 2
  print('ok - unused dimension cache entries are pruned')
  with patch.dict(os.environ, XDG_CACHE_HOME='', HOME=str(root)):
    assert variants.cache_directory() == root / '.cache/omarchy/background-dimensions'
  print('ok - an empty XDG_CACHE_HOME uses the home cache, not the working directory')
  assert variants.candidates(alternate, cache) == []
  assert variants.candidates(folder / 'video.mp4', cache) == []
  print('ok - direct variant and video selection retain ordinary file behavior')

  backgrounds = root / 'backgrounds'
  backgrounds.mkdir()
  for index in range(4):
    png(backgrounds / f'{index}.png', 160, 90)
    (backgrounds / str(index)).mkdir()
    png(backgrounds / str(index) / 'wide.png', 210, 90)
  picker_cache = root / 'picker-cache'
  subprocess.run(['bash', str(Path(os.environ['ROOT']) / 'bin/omarchy-menu-images'), '--prepare-only', str(backgrounds)],
         env=dict(os.environ, XDG_CACHE_HOME=str(picker_cache)), check=True)
  rows = list((picker_cache / 'omarchy/image-selector').glob('*.rows'))
  assert len(rows) == 1 and len(rows[0].read_text().splitlines()) == 4
  print('ok - the real picker lists four designs from eight files without listing variants')
PY

# This fixture exercises the real asynchronous Process lifecycle without
# creating any desktop surfaces or requiring a running compositor.
if command -v quickshell >/dev/null && command -v magick >/dev/null; then
  variant_test_dir=$(mktemp -d /tmp/omarchy-variants.XXXXXX)
  trap 'rm -rf "$variant_test_dir"' EXIT
  mkdir -p "$variant_test_dir/config" "$variant_test_dir/images/design" "$variant_test_dir/runtime"
  chmod 700 "$variant_test_dir/runtime"
  ln -s "$ROOT/shell/plugins/background" "$variant_test_dir/config/background"
  cp "$ROOT/test/shell.d/fixtures/background-variant-catalog.qml" "$variant_test_dir/config/shell.qml"
  magick -size 160x90 xc:red "$variant_test_dir/images/design.png"
  magick -size 210x90 xc:blue "$variant_test_dir/images/design/wide.png"
  ulimit -c 0 2>/dev/null || true
  env -u WAYLAND_DISPLAY QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME=basic \
    XDG_RUNTIME_DIR="$variant_test_dir/runtime" XDG_CACHE_HOME="$variant_test_dir/cache" \
    VARIANT_TEST_DIR="$variant_test_dir/images" \
    timeout 15 quickshell -p "$variant_test_dir/config" --no-color >"$variant_test_dir/runtime.log" 2>&1 ||
    fail "variant catalog runtime fixture exits" "$(cat "$variant_test_dir/runtime.log")"
  if ! rg -q 'PASS variant catalog' "$variant_test_dir/runtime.log" || rg -q 'FAIL variant catalog' "$variant_test_dir/runtime.log"; then
    fail "variant catalog rejects stale scans" "$(cat "$variant_test_dir/runtime.log")"
  fi
  pass "variant catalog resolves real files and rejects stale asynchronous scans"

  # Real fast candidates followed by a probe that outlasts the total deadline.
  # Cover both uncached probes and cache hits before reaching the slow file.
  mkdir -p "$variant_test_dir/bin"
  real_vipsheader=$(command -v vipsheader)
  printf '#!/bin/bash\nif [[ ${*: -1} == */zz-slow.png ]]; then sleep 3; fi\nexec "%s" "$@"\n' "$real_vipsheader" >"$variant_test_dir/bin/vipsheader"
  chmod +x "$variant_test_dir/bin/vipsheader"
  magick -size 90x160 xc:green "$variant_test_dir/images/design/zz-slow.png"
  cp "$ROOT/test/shell.d/fixtures/background-variant-catalog-timeout.qml" "$variant_test_dir/config/shell.qml"
  rm -rf "$variant_test_dir/cache"
  for cache_state in cold warm; do
    env -u WAYLAND_DISPLAY QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME=basic \
      PATH="$variant_test_dir/bin:$PATH" \
      XDG_RUNTIME_DIR="$variant_test_dir/runtime" XDG_CACHE_HOME="$variant_test_dir/cache" \
      VARIANT_TEST_DIR="$variant_test_dir/images" \
      timeout 8 quickshell -p "$variant_test_dir/config" --no-color >"$variant_test_dir/timeout.log" 2>&1 ||
      fail "timed-out variant catalog runtime fixture exits" "$(<"$variant_test_dir/timeout.log")"
    if ! rg -q 'PASS partial variant catalog' "$variant_test_dir/timeout.log" || rg -q 'FAIL partial variant catalog' "$variant_test_dir/timeout.log"; then
      fail "timed-out variant catalog retains completed candidates" "$(<"$variant_test_dir/timeout.log")"
    fi
    pass "timed-out variant catalog retains $cache_state-cache candidates and releases the reveal gate"
  done
else
  skip "quickshell or ImageMagick unavailable; skipping catalog runtime fixtures"
fi
