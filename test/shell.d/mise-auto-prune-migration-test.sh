#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command mise

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
migration="$ROOT/migrations/1792343225.sh"

# The settings package ships the setting before migrations run.
system_dir="$test_tmp/etc/mise"
mkdir -p "$system_dir"
cp -r "$ROOT/etc/mise/conf.d" "$system_dir/"

in_home() {
  local test_home="$1"
  shift

  (
    cd "$test_home"
    env -i \
      HOME="$test_home" \
      XDG_CACHE_HOME="$test_home/.cache" \
      XDG_CONFIG_HOME="$test_home/.config" \
      XDG_DATA_HOME="$test_home/.local/share" \
      XDG_STATE_HOME="$test_home/.local/state" \
      MISE_SYSTEM_DIR="$system_dir" \
      PATH="$ROOT/bin:/usr/bin" \
      "$@"
  )
}

new_home() {
  local test_home="$test_tmp/$1"
  mkdir -p "$test_home/.config/mise"
  printf '%s' "$2" >"$test_home/.config/mise/config.toml"
  echo "$test_home"
}

legacy_home=$(new_home legacy $'[tools]\nruby = "latest"\n\n[settings]\nminimum_release_age = "0s"\n\n[settings.upgrade]\nauto_prune = false\n')
legacy_config="$legacy_home/.config/mise/config.toml"
in_home "$legacy_home" bash -euo pipefail "$migration" >/dev/null
grep -q 'auto_prune' "$legacy_config" && fail "migration drops the setting setup wrote"
grep -Fx 'ruby = "latest"' "$legacy_config" >/dev/null || fail "migration keeps the user's tools"
grep -Fx 'minimum_release_age = "0s"' "$legacy_config" >/dev/null || fail "migration keeps the user's other settings"
[[ $(in_home "$legacy_home" mise settings get upgrade.auto_prune 2>/dev/null) == "false" ]] ||
  fail "upgrades still keep versions in use once the user's copy is gone"
cp "$legacy_config" "$test_tmp/legacy-after"
in_home "$legacy_home" bash -euo pipefail "$migration" >/dev/null
cmp -s "$test_tmp/legacy-after" "$legacy_config" || fail "migration is idempotent"
pass "migration hands upgrade pruning over to Omarchy's config"

dotted_home=$(new_home dotted $'[settings]\nupgrade.auto_prune = false\n')
in_home "$dotted_home" bash -euo pipefail "$migration" >/dev/null
grep -q 'auto_prune' "$dotted_home/.config/mise/config.toml" && fail "migration drops a dotted-key copy of the setting"
pass "migration finds the setting in either TOML form"

# mise keeps its global config under XDG_CONFIG_HOME, so that's where setup wrote.
xdg_home=$(new_home xdg "")
xdg_config="$xdg_home/xdg/mise/config.toml"
mkdir -p "$(dirname "$xdg_config")"
printf '[settings.upgrade]\nauto_prune = false\n' >"$xdg_config"
in_home "$xdg_home" env XDG_CONFIG_HOME="$xdg_home/xdg" bash -euo pipefail "$migration" >/dev/null
grep -q 'auto_prune' "$xdg_config" && fail "migration drops the setting from a config under XDG_CONFIG_HOME"
pass "migration finds the config where XDG_CONFIG_HOME puts it"

chosen_home=$(new_home chosen $'[settings.upgrade]\nauto_prune = true\n')
cp "$chosen_home/.config/mise/config.toml" "$test_tmp/chosen-before"
in_home "$chosen_home" bash -euo pipefail "$migration" >/dev/null
cmp -s "$test_tmp/chosen-before" "$chosen_home/.config/mise/config.toml" || fail "migration keeps a value the user chose"
pass "migration keeps a pruning choice the user made"

# A config kept with dotfiles is often a link into the user's repository.
linked_home=$(new_home linked "")
dotfile="$test_tmp/dotfiles-mise.toml"
printf '[settings.upgrade]\nauto_prune = false\n' >"$dotfile"
ln -sf "$dotfile" "$linked_home/.config/mise/config.toml"
in_home "$linked_home" bash -euo pipefail "$migration" >/dev/null
[[ -L $linked_home/.config/mise/config.toml ]] || fail "migration preserves a dotfile symlink"
grep -q 'auto_prune' "$dotfile" && fail "migration edits the dotfile the link points to"
pass "migration edits a linked config in place"

empty_home="$test_tmp/empty"
mkdir -p "$empty_home"
in_home "$empty_home" bash -euo pipefail "$migration" >/dev/null || fail "migration succeeds without a user mise config"
[[ ! -e $empty_home/.config/mise/config.toml ]] || fail "migration does not create a user mise config"
pass "migration leaves a missing user config missing"
