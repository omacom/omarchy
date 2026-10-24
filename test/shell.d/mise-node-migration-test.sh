#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command mise

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
migration="$ROOT/migrations/1792343099.sh"

# The settings package ships the declarations before migrations run.
system_dir="$test_tmp/etc/mise"
mkdir -p "$system_dir"
cp -r "$ROOT/etc/mise/conf.d" "$system_dir/"

run_migration() {
  local test_home="$1"

  (
    cd "$test_home"
    env -i \
      HOME="$test_home" \
      XDG_CACHE_HOME="$test_home/.cache" \
      XDG_CONFIG_HOME="$test_home/.config" \
      XDG_DATA_HOME="$test_home/.local/share" \
      XDG_STATE_HOME="$test_home/.local/state" \
      MISE_SYSTEM_DIR="$system_dir" \
      OMARCHY_MISE_CONFIG_PATH="$system_dir/conf.d/omarchy-tools.toml" \
      PATH="$ROOT/bin:/usr/bin" \
      bash -euo pipefail "$migration"
  )
}

new_home() {
  local test_home="$test_tmp/$1"
  mkdir -p "$test_home/.config/mise"
  printf '%s' "$2" >"$test_home/.config/mise/config.toml"
  echo "$test_home"
}

legacy_home=$(new_home legacy $'[tools]\nnode = "latest"\nruby = "latest"\n\n[settings.upgrade]\nauto_prune = false\n')
legacy_node="$legacy_home/.local/share/mise/installs/node/26.12.0/bin/node"
mkdir -p "$(dirname "$legacy_node")"
touch "$legacy_node"
run_migration "$legacy_home" >/dev/null
legacy_config="$legacy_home/.config/mise/config.toml"
grep -q '^node' "$legacy_config" && fail "migration drops the node entry setup wrote"
grep -Fx 'ruby = "latest"' "$legacy_config" >/dev/null || fail "migration keeps the user's other tools"
grep -Fx 'auto_prune = false' "$legacy_config" >/dev/null || fail "migration leaves the user's settings alone"
[[ -e $legacy_node ]] || fail "migration keeps the Node install for the declaration to reuse"
cp "$legacy_config" "$test_tmp/legacy-after"
run_migration "$legacy_home" >/dev/null
cmp -s "$test_tmp/legacy-after" "$legacy_config" || fail "migration is idempotent"
pass "migration hands the latest Node over to Omarchy's declaration"

pinned_home=$(new_home pinned $'[tools]\nnode = "22"\n')
cp "$pinned_home/.config/mise/config.toml" "$test_tmp/pinned-before"
run_migration "$pinned_home" >/dev/null
cmp -s "$test_tmp/pinned-before" "$pinned_home/.config/mise/config.toml" || fail "migration keeps a pinned Node"
pass "migration keeps a Node version the user pinned"

# After Remove Preinstalls nothing else provides Node.
opted_out_home=$(new_home opted-out $'[tools]\nnode = "latest"\n')
printf 'ignored_config_paths = ["%s"]\n' "$system_dir/conf.d/omarchy-tools.toml" >"$opted_out_home/.config/mise/miserc.toml"
cp "$opted_out_home/.config/mise/config.toml" "$test_tmp/opted-out-before"
run_migration "$opted_out_home" >/dev/null
cmp -s "$test_tmp/opted-out-before" "$opted_out_home/.config/mise/config.toml" ||
  fail "migration keeps Node for a user who removed the preinstalls"
pass "migration keeps Node after Remove Preinstalls"

empty_home="$test_tmp/empty"
mkdir -p "$empty_home"
run_migration "$empty_home" >/dev/null || fail "migration succeeds without a user mise config"
[[ ! -e $empty_home/.config/mise/config.toml ]] || fail "migration does not create a user mise config"
pass "migration leaves a missing user config missing"
