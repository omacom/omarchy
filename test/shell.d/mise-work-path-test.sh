#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command mise

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
migration="$ROOT/migrations/1789095456.sh"

run_migration() {
  local test_home="$1"

  env -i \
    HOME="$test_home" \
    XDG_CACHE_HOME="$test_home/.cache" \
    XDG_CONFIG_HOME="$test_home/.config" \
    XDG_DATA_HOME="$test_home/.local/share" \
    XDG_STATE_HOME="$test_home/.local/state" \
    MISE_PARANOID="${OMARCHY_TEST_MISE_PARANOID:-false}" \
    PATH=/usr/bin \
    bash -euo pipefail "$migration"
}

run_mise() {
  local test_home="$1"
  shift

  env -i \
    HOME="$test_home" \
    XDG_CACHE_HOME="$test_home/.cache" \
    XDG_CONFIG_HOME="$test_home/.config" \
    XDG_DATA_HOME="$test_home/.local/share" \
    XDG_STATE_HOME="$test_home/.local/state" \
    MISE_PARANOID="${OMARCHY_TEST_MISE_PARANOID:-false}" \
    PATH=/usr/bin \
    mise "$@"
}

mise_environment() {
  local test_home="$1"
  local project="$2"

  (
    cd "$project"
    run_mise "$test_home" env -s bash
  )
}

mise_path_active() {
  local test_home="$1"
  local project="$2"
  local output

  if ! output=$(mise_environment "$test_home" "$project" 2>/dev/null); then
    return 1
  fi

  grep -F "$project/bin" <<<"$output" >/dev/null
}

assert_unsafe_variant_removed() {
  local variant="$1"
  local assignment="$2"
  local variant_home="$test_dir/$variant-home"
  local variant_config="$variant_home/Work/.mise.toml"
  local variant_project="$variant_home/Work/tries/untrusted-repository"

  mkdir -p "$variant_project/bin"
  printf '[env]\n%s\n' "$assignment" >"$variant_config"
  run_mise "$variant_home" trust "$variant_config" >/dev/null

  mise_path_active "$variant_home" "$variant_project" || fail "$variant legacy config prepends the repository bin directory"

  run_migration "$variant_home" >/dev/null
  if mise_path_active "$variant_home" "$variant_project"; then
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
run_mise "$stock_home" trust "$stock_config" >/dev/null

mise_path_active "$stock_home" "$stock_project" || fail "legacy config prepends the repository bin directory"

run_migration "$stock_home" >/dev/null
[[ ! -e $stock_config ]] || fail "migration removes the stock Work Mise config"
cat >"$stock_config" <<'TOML'
[env]
_.path = "{{ cwd }}/bin"
TOML
if mise_path_active "$stock_home" "$stock_project"; then
  fail "recreated Work config remains trusted after migration"
fi
run_migration "$stock_home" >/dev/null
[[ ! -e $stock_config ]] || fail "stock migration is idempotent"
pass "migration removes the repository bin directory and revokes the Work trust root"

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

[other]
_.path = "{{ cwd }}/bin"
TOML
cp "$custom_config" "$test_dir/custom-original"
cat >"$test_dir/custom-expected" <<'TOML'
[env]
KEEP = "yes"
# _.path = "{{ cwd }}/bin"

[tools]
ruby = "latest"

[other]
_.path = "{{ cwd }}/bin"
TOML
chmod 600 "$custom_config"
run_mise "$custom_home" trust "$custom_config" >/dev/null

custom_output=$(run_migration "$custom_home")
cmp -s "$test_dir/custom-expected" "$custom_config" || fail "migration preserves unrelated custom Mise settings"
[[ $(stat -c %a "$custom_config") == "600" ]] || fail "migration preserves custom config permissions"
grep -F "mise trust $custom_config" <<<"$custom_output" >/dev/null || fail "migration explains how to review and re-trust a custom config"
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
unrelated_project="$unrelated_home/Work/tries/untrusted-repository"
mkdir -p "$unrelated_project/bin"
printf '[env]\nKEEP = "yes"\n' >"$unrelated_config"
cp "$unrelated_config" "$test_dir/unrelated-original"
run_mise "$unrelated_home" trust "$unrelated_config" >/dev/null
run_migration "$unrelated_home" >/dev/null
cmp -s "$test_dir/unrelated-original" "$unrelated_config" || fail "unrelated Mise config remains unchanged"
unrelated_backups=("$unrelated_config".bak.*)
[[ ! -e ${unrelated_backups[0]} ]] || fail "unchanged Mise config is not backed up"
printf '[env]\n_.path = "{{ cwd }}/bin"\n' >"$unrelated_config"
if mise_path_active "$unrelated_home" "$unrelated_project"; then
  fail "safe Work config retains its old trust grant"
fi

absent_home="$test_dir/absent-home"
absent_config="$absent_home/Work/.mise.toml"
absent_project="$absent_home/Work/tries/untrusted-repository"
mkdir -p "$(dirname "$absent_config")"
printf '[env]\n_.path = "{{ cwd }}/bin"\n' >"$absent_config"
run_mise "$absent_home" trust "$absent_config" >/dev/null
rm "$absent_config"
rmdir "$absent_home/Work"
run_migration "$absent_home" >/dev/null
[[ ! -e $absent_home/Work ]] || fail "migration does not retain a temporary Work directory"
mkdir -p "$absent_project/bin"
printf '[env]\n_.path = "{{ cwd }}/bin"\n' >"$absent_config"
if mise_path_active "$absent_home" "$absent_project"; then
  fail "deleted Work directory retains its stale trust grant"
fi
pass "migration leaves unrelated configs alone and revokes dangling Work trust"

paranoid_home="$test_dir/paranoid-home"
paranoid_work="$paranoid_home/Work"
paranoid_config="$paranoid_work/.mise.toml"
paranoid_project="$paranoid_work/tries/untrusted-repository"
mkdir -p "$paranoid_project/bin"
printf '[env]\n_.path = "{{ cwd }}/bin"\n' >"$paranoid_config"
OMARCHY_TEST_MISE_PARANOID=true run_mise "$paranoid_home" trust "$paranoid_config" >/dev/null
OMARCHY_TEST_MISE_PARANOID=true mise_path_active "$paranoid_home" "$paranoid_project" || fail "paranoid legacy config prepends the repository bin directory"
rm -r "$paranoid_work"

OMARCHY_TEST_MISE_PARANOID=true run_migration "$paranoid_home" >/dev/null
[[ ! -e $paranoid_work ]] || fail "paranoid migration removes its temporary Work directory"
mkdir -p "$paranoid_project/bin"
printf '[env]\n_.path = "{{ cwd }}/bin"\n' >"$paranoid_config"
if OMARCHY_TEST_MISE_PARANOID=true mise_path_active "$paranoid_home" "$paranoid_project"; then
  fail "paranoid migration retains content-bound trust for the deleted legacy config"
fi
pass "migration revokes stale content-bound trust in Mise paranoid mode"

ignored_home="$test_dir/ignored-home"
ignored_config="$ignored_home/Work/.mise.toml"
ignored_project="$ignored_home/Work/tries/untrusted-repository"
mkdir -p "$ignored_project/bin"
cat >"$ignored_config" <<'TOML'
[env]
_.path = "{{ cwd }}/bin"
KEEP = "yes"
TOML
run_mise "$ignored_home" trust "$ignored_config" >/dev/null
run_mise "$ignored_home" trust --ignore "$ignored_config" >/dev/null

ignored_output=$(run_migration "$ignored_home")
grep -F '{{ cwd }}/bin' "$ignored_config" >/dev/null && fail "ignored config retains the unsafe path"
grep -Fx 'KEEP = "yes"' "$ignored_config" >/dev/null || fail "ignored config keeps unrelated settings"
ignored_entries=("$ignored_home/.local/state/mise/ignored-configs/"*)
[[ -L ${ignored_entries[0]} ]] || fail "migration preserves the explicit Mise ignore marker"
(( ${#ignored_entries[@]} == 1 )) || fail "migration preserves exactly one Mise ignore marker"
[[ $(readlink "${ignored_entries[0]}") == "$ignored_home/Work" ]] || fail "preserved Mise ignore marker still targets Work"
grep -F "remains ignored by Mise" <<<"$ignored_output" >/dev/null || fail "migration reports that the custom config remains ignored"
if mise_path_active "$ignored_home" "$ignored_project"; then
  fail "ignored config becomes active after migration"
fi
pass "migration preserves an explicit decision to ignore the Work config"

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
