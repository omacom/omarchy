#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command mise

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
migration="$ROOT/migrations/1789095456.sh"

run_migration() {
  local test_home="$1"

  env HOME="$test_home" bash -euo pipefail "$migration"
}

mise_environment() {
  local test_home="$1"
  local project="$2"

  (
    cd "$project"
    env \
      HOME="$test_home" \
      XDG_CACHE_HOME="$test_home/.cache" \
      XDG_CONFIG_HOME="$test_home/.config" \
      XDG_DATA_HOME="$test_home/.local/share" \
      XDG_STATE_HOME="$test_home/.local/state" \
      MISE_TRUSTED_CONFIG_PATHS="$test_home/Work/.mise.toml" \
      PATH=/usr/bin \
      mise env -s bash
  )
}

assert_unsafe_variant_removed() {
  local variant="$1"
  local assignment="$2"
  local variant_home="$test_dir/$variant-home"
  local variant_config="$variant_home/Work/.mise.toml"
  local variant_project="$variant_home/Work/tries/untrusted-repository"
  local before after

  mkdir -p "$variant_project/bin"
  printf '[env]\n%s\n' "$assignment" >"$variant_config"

  before=$(mise_environment "$variant_home" "$variant_project")
  grep -F "$variant_project/bin" <<<"$before" >/dev/null || fail "$variant legacy config prepends the repository bin directory"

  run_migration "$variant_home" >/dev/null
  after=$(mise_environment "$variant_home" "$variant_project")
  if grep -F "$variant_project/bin" <<<"$after" >/dev/null; then
    fail "$variant repository bin directory remains in PATH after migration"
  fi
}

install_home="$test_dir/install-home"
install_log="$test_dir/install-mise.log"
mkdir -p "$install_home" "$test_dir/bin"
cat >"$test_dir/bin/mise" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$MISE_TEST_LOG"
SH
chmod +x "$test_dir/bin/mise"

env \
  HOME="$install_home" \
  MISE_TEST_LOG="$install_log" \
  OMARCHY_SETUP_CONTEXT=runtime \
  PATH="$test_dir/bin:/usr/bin" \
  bash -euo pipefail -c 'source "$1"' bash "$ROOT/install/user/mise-work.sh"

[[ -d $install_home/Work/tries ]] || fail "installer creates the work and tries directories"
[[ ! -e $install_home/Work/.mise.toml ]] || fail "installer does not create a trusted Work Mise config"
[[ $(<"$install_log") == "use -g node@latest" ]] || fail "installer only invokes Mise for the global Node setup"
pass "new installs do not add project bin directories to PATH"

stock_home="$test_dir/stock-home"
stock_config="$stock_home/Work/.mise.toml"
stock_project="$stock_home/Work/tries/untrusted-repository"
mkdir -p "$stock_project/bin"
cat >"$stock_config" <<'TOML'
[env]
_.path = "{{ cwd }}/bin"
TOML

before=$(mise_environment "$stock_home" "$stock_project")
grep -F "$stock_project/bin" <<<"$before" >/dev/null || fail "legacy config prepends the repository bin directory"

run_migration "$stock_home" >/dev/null
[[ ! -e $stock_config ]] || fail "migration removes the stock Work Mise config"
after=$(mise_environment "$stock_home" "$stock_project")
if grep -F "$stock_project/bin" <<<"$after" >/dev/null; then
  fail "repository bin directory is absent from PATH after migration"
fi
run_migration "$stock_home" >/dev/null
[[ ! -e $stock_config ]] || fail "stock migration is idempotent"
pass "migration explicitly removes the repository bin directory from Mise PATH"

assert_unsafe_variant_removed inline-comment '_.path = "{{ cwd }}/bin" # Omarchy default'
assert_unsafe_variant_removed single-quoted "_.path = '{{ cwd }}/bin'"
pass "migration removes annotated and single-quoted project bin paths"

custom_home="$test_dir/custom-home"
custom_config="$custom_home/Work/.mise.toml"
mkdir -p "$(dirname "$custom_config")"
cat >"$custom_config" <<'TOML'
[env]
KEEP = "yes"
  _.path   =   "{{ cwd }}/bin"
# _.path = "{{ cwd }}/bin"

[tools]
ruby = "latest"
TOML
cp "$custom_config" "$test_dir/custom-original"
cat >"$test_dir/custom-expected" <<'TOML'
[env]
KEEP = "yes"
# _.path = "{{ cwd }}/bin"

[tools]
ruby = "latest"
TOML
chmod 600 "$custom_config"

run_migration "$custom_home" >/dev/null
cmp -s "$test_dir/custom-expected" "$custom_config" || fail "migration preserves unrelated custom Mise settings"
[[ $(stat -c %a "$custom_config") == "600" ]] || fail "migration preserves custom config permissions"
custom_backups=("$custom_config".bak.*)
[[ -f ${custom_backups[0]} ]] || fail "migration backs up a customized Mise config"
(( ${#custom_backups[@]} == 1 )) || fail "migration creates one custom config backup"
cmp -s "$test_dir/custom-original" "${custom_backups[0]}" || fail "custom config backup preserves the original"

run_migration "$custom_home" >/dev/null
custom_backups=("$custom_config".bak.*)
(( ${#custom_backups[@]} == 1 )) || fail "custom migration does not create another backup on rerun"
cmp -s "$test_dir/custom-expected" "$custom_config" || fail "custom migration is idempotent"
pass "custom Mise settings, permissions, and original backup survive the repair"

unrelated_home="$test_dir/unrelated-home"
unrelated_config="$unrelated_home/Work/.mise.toml"
mkdir -p "$(dirname "$unrelated_config")"
printf '[env]\nKEEP = "yes"\n' >"$unrelated_config"
cp "$unrelated_config" "$test_dir/unrelated-original"
run_migration "$unrelated_home" >/dev/null
cmp -s "$test_dir/unrelated-original" "$unrelated_config" || fail "unrelated Mise config remains unchanged"
unrelated_backups=("$unrelated_config".bak.*)
[[ ! -e ${unrelated_backups[0]} ]] || fail "unchanged Mise config is not backed up"

absent_home="$test_dir/absent-home"
mkdir -p "$absent_home"
run_migration "$absent_home" >/dev/null
[[ ! -e $absent_home/Work/.mise.toml ]] || fail "absent config remains absent"
pass "migration leaves unrelated and absent Mise configs alone"

symlink_home="$test_dir/symlink-home"
symlink_config="$symlink_home/Work/.mise.toml"
symlink_target="$test_dir/dotfiles-mise.toml"
mkdir -p "$(dirname "$symlink_config")"
cat >"$symlink_target" <<'TOML'
[env]
_.path = "{{ cwd }}/bin"
KEEP = "yes"
TOML
ln -s "$symlink_target" "$symlink_config"

run_migration "$symlink_home" >/dev/null
[[ -L $symlink_config ]] || fail "migration preserves a dotfile symlink"
grep -F '{{ cwd }}/bin' "$symlink_target" >/dev/null && fail "symlink target retains the unsafe path"
grep -Fx 'KEEP = "yes"' "$symlink_target" >/dev/null || fail "symlink target keeps unrelated settings"
pass "custom dotfile symlinks survive the repair"
