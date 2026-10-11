#!/bin/bash
#
# omarchy-nvim 2026.8.13 seeded homes with monokai-pro from gthelding's fork,
# which has since been deleted, so every :Lazy sync reported it as failed.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command git

migration="$ROOT/migrations/1791691040.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
themes="$home/.config/nvim/lua/plugins/all-themes.lua"
lock="$home/.config/nvim/lazy-lock.json"
clone="$home/.local/share/nvim/lazy/monokai-pro.nvim"

dead_pin=5b06ae0736813b1c65d76a4be9edbe92be0b9c74
upstream_pin=a68e38b8e55d69a215d0f02598900a79c356da9d

seed_home() { # owner named in the spec, owner of the clone's origin
  rm -rf "$home"
  mkdir -p "$(dirname "$themes")" "$clone"
  printf 'return {\n\t{\n\t\t"%s/monokai-pro.nvim",\n\t\tlazy = true,\n\t},\n\t{\n\t\t"folke/tokyonight.nvim",\n\t},\n}\n' "$1" >"$themes"
  printf '{\n  "monokai-pro.nvim": { "branch": "master", "commit": "%s" },\n  "tokyonight.nvim": { "branch": "main", "commit": "%s" }\n}\n' "$dead_pin" "$dead_pin" >"$lock"
  git init -q "$clone"
  git -C "$clone" remote add origin "https://github.com/$2/monokai-pro.nvim.git"
}

run() {
  HOME="$home" OMARCHY_PATH="$ROOT" bash -euo pipefail "$migration" >/dev/null
}

snapshot() {
  cat "$themes" "$lock"
  git -C "$clone" remote get-url origin
}

seed_home gthelding gthelding
run
grep -qF '"loctvl842/monokai-pro.nvim"' "$themes" || fail "the monokai-pro spec still names the deleted fork" "$(cat "$themes")"
! grep -q gthelding "$themes" || fail "the deleted fork is still named in all-themes.lua" "$(cat "$themes")"
grep -qF '"folke/tokyonight.nvim"' "$themes" || fail "another plugin spec was changed" "$(cat "$themes")"
pass "the monokai-pro spec points at upstream"

grep -qF "\"monokai-pro.nvim\": { \"branch\": \"master\", \"commit\": \"$upstream_pin\" }" "$lock" || fail "the lockfile still pins the deleted fork's commit" "$(cat "$lock")"
grep -qF "\"tokyonight.nvim\": { \"branch\": \"main\", \"commit\": \"$dead_pin\" }" "$lock" || fail "another plugin's pin was changed" "$(cat "$lock")"
pass "the lockfile pins a monokai-pro commit upstream has, and no other pin moves"

[[ $(git -C "$clone" remote get-url origin) == "https://github.com/loctvl842/monokai-pro.nvim.git" ]] || fail "the plugin clone still fetches from the deleted fork"
pass "the packaged plugin clone fetches from upstream"

before=$(snapshot)
run
[[ $(snapshot) == "$before" ]] || fail "a second run changed the home again"
pass "a second run changes nothing"

# A run that stopped before the spec was rewritten is retried in full.
seed_home gthelding loctvl842
run
grep -qF "\"commit\": \"$upstream_pin\"" "$lock" || fail "a retried run left the dead pin in place" "$(cat "$lock")"
grep -qF '"loctvl842/monokai-pro.nvim"' "$themes" || fail "a retried run left the dead spec in place" "$(cat "$themes")"
pass "a run retried after the clone was already repointed still finishes the repair"

seed_home someone gthelding
before=$(snapshot)
run
[[ $(snapshot) == "$before" ]] || fail "a home whose spec names its own fork was changed" "$(snapshot)"
pass "a config that chose its own monokai-pro keeps its spec, pin and clone"

rm -rf "$home"
mkdir -p "$home"
run
[[ ! -e $home/.config/nvim ]] || fail "the migration created a Neovim config where there was none"
pass "a home without a Neovim config is left alone"
