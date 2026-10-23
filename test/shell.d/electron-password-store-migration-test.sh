#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

migration="$ROOT/migrations/1788631245.sh"
[[ -f $migration ]] || fail "Electron password-store migration exists"

default_flags="$ROOT/config/electron-flags.conf"
[[ -f $default_flags ]] || fail "fresh installs pin Electron's password store"
[[ $(<"$default_flags") == "--password-store=gnome-libsecret" ]] ||
  fail "fresh installs pin Electron's password store"
pass "fresh installs pin Electron's password store"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

run_migration() {
  local home=$1

  env -u XDG_CONFIG_HOME HOME="$home" bash -euo pipefail "$migration" >/dev/null
}

home="$test_dir/commented-option"
mkdir -p "$home/.config"
printf '%s\n' '# --password-store=basic' >"$home/.config/electron-flags.conf"

run_migration "$home"

[[ $(<"$home/.config/electron-flags.conf") == $'# --password-store=basic\n--password-store=gnome-libsecret' ]] ||
  fail "migration ignores a commented password-store option"
pass "migration ignores a commented password-store option"

home="$test_dir/existing-user"
mkdir -p "$home"

run_migration "$home" || fail "migration prepares existing users for a future Electron app"

grep -qxF -- '--password-store=gnome-libsecret' "$home/.config/electron-flags.conf" ||
  fail "migration prepares existing users for a future Electron app"
pass "migration prepares existing users for a future Electron app"

home="$test_dir/custom-option"
mkdir -p "$home/.config"
printf '%s\n' '--password-store=basic' >"$home/.config/electron-flags.conf"

run_migration "$home"

[[ $(<"$home/.config/electron-flags.conf") == "--password-store=basic" ]] ||
  fail "migration preserves an active password-store choice"
pass "migration preserves an active password-store choice"

home="$test_dir/missing-newline"
mkdir -p "$home/.config"
printf %s '--enable-features=WaylandLinuxDrmSyncobj' >"$home/.config/electron-flags.conf"

run_migration "$home"

[[ $(<"$home/.config/electron-flags.conf") == $'--enable-features=WaylandLinuxDrmSyncobj\n--password-store=gnome-libsecret' ]] ||
  fail "migration appends the pin on its own line"
pass "migration appends the pin on its own line"

before=$(sha256sum "$home/.config/electron-flags.conf")
run_migration "$home"
after=$(sha256sum "$home/.config/electron-flags.conf")

[[ $before == "$after" ]] || fail "Electron password-store migration is idempotent"
pass "Electron password-store migration is idempotent"

home="$test_dir/versioned-flags"
mkdir -p "$home/.config"
printf '%s\n' '--enable-features=WaylandLinuxDrmSyncobj' >"$home/.config/electron43-flags.conf"

run_migration "$home"

grep -qxF -- '--password-store=gnome-libsecret' "$home/.config/electron-flags.conf" ||
  fail "migration still seeds the fallback flags file"
grep -qxF -- '--password-store=gnome-libsecret' "$home/.config/electron43-flags.conf" ||
  fail "migration pins a versioned Electron flags file"
pass "migration pins versioned Electron flags files that shadow the fallback"

home="$test_dir/versioned-custom"
mkdir -p "$home/.config"
printf '%s\n' '--password-store=basic_text' >"$home/.config/electron43-flags.conf"

run_migration "$home"

[[ $(<"$home/.config/electron43-flags.conf") == "--password-store=basic_text" ]] ||
  fail "migration preserves a versioned password-store choice"
pass "migration preserves a versioned password-store choice"

home="$test_dir/xdg-home"
config_home="$test_dir/xdg config"
mkdir -p "$home" "$config_home"
printf '%s\n' '--enable-features=WaylandLinuxDrmSyncobj' >"$config_home/electron43-flags.conf"

HOME="$home" XDG_CONFIG_HOME="$config_home" bash -euo pipefail "$migration" >/dev/null

grep -qxF -- '--password-store=gnome-libsecret' "$config_home/electron-flags.conf" ||
  fail "migration seeds the fallback flags file under XDG_CONFIG_HOME"
grep -qxF -- '--password-store=gnome-libsecret' "$config_home/electron43-flags.conf" ||
  fail "migration pins versioned flags files under XDG_CONFIG_HOME"
[[ ! -e $home/.config ]] || fail "migration writes nothing under ~/.config when XDG_CONFIG_HOME is set"
pass "migration follows XDG_CONFIG_HOME"
