#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const picker = requireFromRoot('shell/plugins/image-picker/ImagePickerModel.js')

assertEqual(picker.nameForPath('/themes/nord-river.png'), 'nord-river', 'image picker strips directory and extension')
assertEqual(picker.labelForPath('/themes/nord_river.png'), 'Nord River', 'image picker builds display labels')
assertEqual(picker.wallpaperLabelForPath('/themes/5-neon-smoke-orb.jpg'), 'Neon Smoke Orb', 'image picker strips leading wallpaper indices')
assertEqual(
  picker.themeWallpaperLabel('/cache/theme-selector/previews/sakura-mochi.jpg', '/themes/sakura-mochi/backgrounds/5-neon-smoke-orb.jpg', ''),
  'Sakura Mochi · Neon Smoke Orb',
  'image picker labels a cycled theme wallpaper'
)
assertEqual(
  picker.themeWallpaperLabel('/cache/theme-selector/previews/sakura-mochi.jpg', '/cache/theme-selector/previews/sakura-mochi.jpg', ''),
  'Sakura Mochi',
  'image picker keeps the theme label when the preview is unchanged'
)

const rows = [
  '/themes/a/nord-river.png\t/cache/nord-river.jpg',
  '/themes/b/nord-river.png\t/cache/duplicate.jpg',
  '/themes/a/gruvbox-dark.jpeg',
  '',
  '\t/cache/no-path.jpg',
  '/themes/a/plain'
].join('\n')

const images = picker.loadRows(rows)
assertDeepEqual(
  images,
  [
    { filePath: '/themes/a/nord-river.png', fileName: 'nord-river.png', thumbnailPath: '/cache/nord-river.jpg' },
    { filePath: '/themes/a/gruvbox-dark.jpeg', fileName: 'gruvbox-dark.jpeg', thumbnailPath: '/themes/a/gruvbox-dark.jpeg' },
    { filePath: '/themes/a/plain', fileName: 'plain', thumbnailPath: '/themes/a/plain' }
  ],
  'image picker parses rows and dedupes by file name'
)

assert(picker.itemMatches(images, 0, 'river'), 'image picker matches file names')
assert(picker.itemMatches(images, 1, 'Gruvbox Dark'), 'image picker matches labels case-insensitively')
assert(!picker.itemMatches(images, 2, 'river'), 'image picker rejects non-matching filters')
assertEqual(picker.firstMatchingIndex(images, 'plain'), 2, 'image picker finds first matching index')
assertEqual(picker.indexForSelectedImage(images, '/themes/a/gruvbox-dark.jpeg'), 1, 'image picker finds selected image')
assertEqual(picker.indexForSelectedImage(images, '/missing.png'), 0, 'image picker defaults selected image to first row')

assertEqual(picker.filteredPosition(images, 2, 'dark'), 1, 'image picker computes filtered position')
assertEqual(picker.selectedFilteredPosition(images, 2, 'dark'), 0, 'image picker selected filtered position falls back when selected is hidden')
assertEqual(picker.nextSelectedIndexForFilter(images, 0, 'dark'), 1, 'image picker moves selection to first match when filter hides current item')

const imagePickerQml = fs.readFileSync(path.join(root, 'shell/plugins/image-picker/ImagePicker.qml'), 'utf8')
assert(
  /function preloadRows[\s\S]*if \(opened \|\| requestActive\) return/.test(imagePickerQml),
  'image picker ignores cache preloads while a request is visible'
)
assert(
  /source: item\.sourceActivated && item\.displayPath \? Util\.fileUrl\(item\.displayPath\) : ""[\s\S]*asynchronous: false/.test(imagePickerQml),
  'image picker loads activated thumbnails synchronously to avoid carousel flicker'
)
assert(
  /event\.key === Qt\.Key_Up[\s\S]*cycleThemeWallpaper\(-1\)[\s\S]*event\.key === Qt\.Key_Down[\s\S]*cycleThemeWallpaper\(1\)/.test(imagePickerQml),
  'theme switcher cycles wallpapers with up and down'
)
assert(
  /scriptPath\("list-theme-bgs\.sh"\)/.test(imagePickerQml),
  'theme switcher lists wallpapers from the bundled theme background helper'
)
JS

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/home/.config/omarchy/themes/demo/backgrounds" "$tmpdir/omarchy/themes/demo/backgrounds" "$tmpdir/home/.config/omarchy/backgrounds/demo"
printf 'user\n' >"$tmpdir/home/.config/omarchy/themes/demo/backgrounds/1-user.png"
printf 'stock\n' >"$tmpdir/omarchy/themes/demo/backgrounds/0-stock.png"
printf 'extra\n' >"$tmpdir/home/.config/omarchy/backgrounds/demo/2-extra.png"
printf 'shared\n' >"$tmpdir/omarchy/themes/demo/backgrounds/same.png"
ln -s "$tmpdir/omarchy/themes/demo/backgrounds/same.png" "$tmpdir/home/.config/omarchy/themes/demo/backgrounds/same.png"

listed=$(HOME="$tmpdir/home" OMARCHY_PATH="$tmpdir/omarchy" "$ROOT/shell/plugins/image-picker/list-theme-bgs.sh" demo)
assert_contains() {
  local needle="$1"
  if [[ $listed != *"$needle"* ]]; then
    fail "theme wallpaper list includes $needle" "$listed"
  fi
}
assert_contains "2-extra.png"
assert_contains "1-user.png"
assert_contains "0-stock.png"
same_count=$(printf '%s\n' "$listed" | grep -c '/same.png$' || true)
if (( same_count != 1 )); then
  fail "theme wallpaper list dedupes identical files" "$listed"
fi
pass "theme wallpaper list prefers extras, then the user theme, then stock"
