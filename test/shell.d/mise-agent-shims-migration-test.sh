#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command mise

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
migration="$ROOT/migrations/1792504295.sh"
agents=(qwen dsh mcode kiro-cli freebuff kilo devin amp commandcode)

# The settings package ships the declarations before migrations run.
system_dir="$test_tmp/etc/mise"
mkdir -p "$system_dir"
cp -r "$ROOT/etc/mise/conf.d" "$system_dir/"

run_migration() {
  local test_home="$1" tools_config="${2:-$system_dir/conf.d/omarchy-tools.toml}"

  (
    cd "$test_home"
    env -i \
      HOME="$test_home" \
      XDG_CACHE_HOME="$test_home/.cache" \
      XDG_CONFIG_HOME="$test_home/.config" \
      XDG_DATA_HOME="$test_home/.local/share" \
      XDG_STATE_HOME="$test_home/.local/state" \
      MISE_SYSTEM_DIR="$system_dir" \
      OMARCHY_MISE_CONFIG_PATH="$tools_config" \
      PATH="$ROOT/bin:/usr/bin" \
      bash -euo pipefail "$migration"
  )
}

new_home() {
  local test_home="$test_tmp/$1"
  mkdir -p "$test_home/.config/mise"
  echo "$test_home"
}

home=$(new_home declared)
run_migration "$home" >/dev/null 2>&1
for agent in "${agents[@]}"; do
  [[ -x $home/.local/share/mise/shims/$agent ]] || fail "migration builds the lazy $agent shim"
done
[[ ! -e $home/.local/share/mise/installs ]] || fail "migration installs nothing before first launch"
run_migration "$home" >/dev/null 2>&1 || fail "migration is idempotent"
pass "migration builds the lazy shims for the newly declared agents"

# Until the settings package declares the agents, the migration stays pending.
waiting_home=$(new_home waiting)
if run_migration "$waiting_home" "$test_tmp/missing/omarchy-tools.toml" >/dev/null 2>&1; then
  fail "migration waits for the settings package's declarations"
fi
[[ ! -e $waiting_home/.local/share/mise/shims/qwen ]] || fail "migration builds nothing before the declarations arrive"
pass "migration stays pending until the declarations arrive"

# Remove Preinstalls opts the user out of Omarchy's declarations.
opted_out_home=$(new_home opted-out)
printf 'ignored_config_paths = ["%s"]\n' "$system_dir/conf.d/omarchy-tools.toml" >"$opted_out_home/.config/mise/miserc.toml"
run_migration "$opted_out_home" >/dev/null 2>&1 || fail "migration completes after Remove Preinstalls"
[[ ! -e $opted_out_home/.local/share/mise/shims/qwen ]] || fail "migration builds no shims after Remove Preinstalls"
pass "migration leaves a user who removed the preinstalls alone"
