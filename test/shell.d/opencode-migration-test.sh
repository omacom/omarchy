#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"
export HOME="$test_tmp/home"
export XDG_CONFIG_HOME="$HOME/.config"
export MISE_CONFIG_DIR="$XDG_CONFIG_HOME/mise"
export MISE_GLOBAL_CONFIG_FILE="$MISE_CONFIG_DIR/config.toml"
export OMARCHY_PATH="$ROOT"
export OMARCHY_TEST_MISE_LOG="$test_tmp/mise.log"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"
wrapper="$HOME/.local/bin/opencode"
migration="$ROOT/migrations/1789156273.sh"
package="npm:@opencode/cli[allow_builds=@opencode/cli]"

cat >"$test_tmp/bin/mise" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_MISE_LOG"
[[ $1 != "${OMARCHY_TEST_FAIL_COMMAND:-}" ]]
SH
chmod +x "$test_tmp/bin/mise"

reset_home() {
  rm -rf "$HOME"
  mkdir -p "$MISE_CONFIG_DIR"
  : >"$OMARCHY_TEST_MISE_LOG"
  "$ROOT/bin/omarchy-mise-install" opencode
}

run_migration() {
  bash -euo pipefail "$migration" >"$test_tmp/output" 2>&1
}

reset_home
run_migration
[[ ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "unused OpenCode stays lazy"
"$wrapper" --auto --prompt "Review this project"
mapfile -t calls <"$OMARCHY_TEST_MISE_LOG"
[[ ${calls[0]} == "use -g --quiet $package" &&
  ${calls[1]} == "x $package -- opencode --auto --prompt Review this project" ]] ||
  fail "the migrated lazy wrapper installs V2 with its binary-selection script"
pass "unused OpenCode stays lazy and launches through the V2 package"

reset_home
printf '[tools]\nopencode = "latest"\nnode = "24"\n' >"$MISE_GLOBAL_CONFIG_FILE"
run_migration
mapfile -t calls <"$OMARCHY_TEST_MISE_LOG"
[[ ${#calls[@]} == 2 &&
  ${calls[0]} == "use --path $MISE_GLOBAL_CONFIG_FILE --fuzzy $package@latest" &&
  ${calls[1]} == "unuse --path $MISE_GLOBAL_CONFIG_FILE --no-prune opencode" ]] ||
  fail "migration installs V2 before removing only the V1 request, without pruning"
cp "$wrapper" "$test_tmp/migrated-wrapper"
: >"$OMARCHY_TEST_MISE_LOG"
run_migration
[[ ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "migration is idempotent"
cmp -s "$wrapper" "$test_tmp/migrated-wrapper" || fail "a migrated wrapper stays intact"
pass "active defaults migrate in order and repeated migration is a no-op"

for command in use unuse; do
  reset_home
  printf '[tools]\nopencode = "latest"\n' >"$MISE_GLOBAL_CONFIG_FILE"
  cp "$wrapper" "$test_tmp/old-wrapper"
  if OMARCHY_TEST_FAIL_COMMAND="$command" run_migration; then
    fail "$command failure must leave the migration pending"
  fi
  cmp -s "$wrapper" "$test_tmp/old-wrapper" || fail "$command failure preserves the old launcher"
  if [[ $command == "use" ]]; then
    ! grep -q '^unuse ' "$OMARCHY_TEST_MISE_LOG" || fail "a failed install never removes V1"
  fi
  run_migration
  grep -Fq "$package" "$wrapper" || fail "migration can retry after $command failure"
done
pass "installation and config-removal failures preserve the launcher and can retry"

for config in \
  'opencode = "1.18.30"' \
  'opencode = ["latest", "1.18.30"]' \
  'opencode = { version = "latest", install_env = { CUSTOM = "yes" } }' \
  '"github:anomalyco/opencode" = "latest"' \
  '"npm:@opencode-ai/cli" = "beta"' \
  '"npm:@opencode/cli" = "2.0.1"' \
  $'opencode = "latest"\n[alias.opencode]\nbackend = "github:anomalyco/opencode"'; do
  reset_home
  printf '[tools]\n%s\n' "$config" >"$MISE_GLOBAL_CONFIG_FILE"
  cp "$wrapper" "$test_tmp/old-wrapper"
  cp "$MISE_GLOBAL_CONFIG_FILE" "$test_tmp/old-config"
  run_migration
  cmp -s "$wrapper" "$test_tmp/old-wrapper" || fail "migration preserves a customized mise setup"
  cmp -s "$MISE_GLOBAL_CONFIG_FILE" "$test_tmp/old-config" || fail "migration preserves custom config contents"
  [[ ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "custom mise setups trigger no installations"
done
pass "migration leaves explicit pins, options, backends, aliases and beta setups alone"

reset_home
printf '[tools]\nopencode = "latest"\n"npm:@opencode/cli" = { version = "latest", allow_builds = "@opencode/cli" }\n' >"$MISE_GLOBAL_CONFIG_FILE"
run_migration
grep -Fq "unuse --path $MISE_GLOBAL_CONFIG_FILE --no-prune opencode" "$OMARCHY_TEST_MISE_LOG" ||
  fail "retry handles the new package already being configured"
pass "migration handles a retry after V2 was configured but V1 was not yet removed"

for kind in edited symlink; do
  reset_home
  printf '[tools]\nopencode = "latest"\n' >"$MISE_GLOBAL_CONFIG_FILE"
  if [[ $kind == "edited" ]]; then
    printf '\n# My custom launcher\n' >>"$wrapper"
  else
    mv "$wrapper" "$test_tmp/user-wrapper"
    ln -s "$test_tmp/user-wrapper" "$wrapper"
  fi
  cp "$wrapper" "$test_tmp/old-wrapper"
  run_migration
  cmp -s "$wrapper" "$test_tmp/old-wrapper" || fail "migration preserves $kind launchers"
  [[ ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "$kind launchers trigger no installations"
  if [[ $kind == "symlink" ]]; then
    [[ -L $wrapper ]] || fail "migration preserves launcher symlinks"
  fi
done
pass "custom launchers and symlinks are preserved"

reset_home
mkdir -p "$HOME/.local/state/omarchy"
touch "$HOME/.local/state/omarchy/preinstalls-removed"
rm "$wrapper"
run_migration
[[ ! -e $wrapper && ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "migration respects the preinstall opt-out"
pass "migration respects the preinstall opt-out"

reset_home
printf 'invalid toml = [' >"$MISE_GLOBAL_CONFIG_FILE"
cp "$wrapper" "$test_tmp/old-wrapper"
if run_migration; then
  fail "invalid TOML leaves the migration pending"
fi
[[ ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "invalid TOML triggers no installations"
cmp -s "$wrapper" "$test_tmp/old-wrapper" || fail "invalid TOML preserves the launcher"
pass "invalid config fails without changing the launcher"
