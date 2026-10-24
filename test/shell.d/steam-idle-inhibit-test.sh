#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
let steam = fs.readFileSync(root + '/default/hypr/apps/steam.lua', 'utf8')

// Assertions describe executable rules, not commented text. This kills both the
// original line-comment mutant and the later --[[ ... ]] block-comment mutant.
steam = steam.replace(/--\[\[[\s\S]*?\]\]/g, '')
  .replace(/--[^\n]*/g, '')

assert(
  /^\s*o\.window\("steam_app_\.\*",\s*\{\s*idle_inhibit\s*=\s*"fullscreen"\s*\}/m.test(steam),
  'Steam games (steam_app_<id>) get a fullscreen idle inhibitor'
)
assert(
  /^\s*o\.window\("steam",\s*\{[^}]*idle_inhibit\s*=\s*"fullscreen"/m.test(steam),
  'the Steam client still gets a fullscreen idle inhibitor'
)
assert(
  !/^\s*o\.window\("steam_app_\.\*",\s*\{[^}]*float\s*=\s*true/m.test(steam),
  'Steam games are not forced floating by the idle-inhibit rule'
)
JS
