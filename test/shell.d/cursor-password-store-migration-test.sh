#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1791772723.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

run_migration() {
  env -u XDG_CONFIG_HOME HOME="$1" OMARCHY_PATH="$ROOT" bash -euo pipefail "$migration" >/dev/null
}

home="$test_tmp/fresh"
mkdir -p "$home"
run_migration "$home"
run_migration "$home"
cmp -s "$ROOT/config/cursor-flags.conf" "$home/.config/cursor-flags.conf" ||
  fail "the migration seeds missing Cursor flags from the shipped config"
pass "the migration seeds missing Cursor flags and can run twice"

home="$test_tmp/flags"
mkdir -p "$home/.config"
printf '%s' '--ozone-platform=wayland' >"$home/.config/cursor-flags.conf"
run_migration "$home"
run_migration "$home"
[[ $(cat "$home/.config/cursor-flags.conf") == $'--ozone-platform=wayland\n--password-store=gnome-libsecret' ]] ||
  fail "the migration appends the password store once, past a missing trailing newline"
pass "the migration keeps existing Cursor flags"

home="$test_tmp/chosen"
mkdir -p "$home/.config"
printf '%s\n' '--password-store=kwallet6' >"$home/.config/cursor-flags.conf"
run_migration "$home"
[[ $(cat "$home/.config/cursor-flags.conf") == '--password-store=kwallet6' ]] ||
  fail "the migration leaves a password store the user chose"
pass "the migration leaves a chosen password store alone"

home="$test_tmp/commented"
mkdir -p "$home/.config"
printf '%s\n' '# --password-store=basic' >"$home/.config/cursor-flags.conf"
run_migration "$home"
[[ $(cat "$home/.config/cursor-flags.conf") == $'# --password-store=basic\n--password-store=gnome-libsecret' ]] ||
  fail "the migration pins the password store past a commented-out one"
pass "the migration ignores a commented-out password store"

home="$test_tmp/xdg"
config_home="$test_tmp/xdg config"
mkdir -p "$home"
HOME="$home" XDG_CONFIG_HOME="$config_home" OMARCHY_PATH="$ROOT" bash -euo pipefail "$migration" >/dev/null
cmp -s "$ROOT/config/cursor-flags.conf" "$config_home/cursor-flags.conf" ||
  fail "the migration writes Cursor flags where the launcher reads them"
[[ ! -e $home/.config/cursor-flags.conf ]] || fail "the migration ignores XDG_CONFIG_HOME"
pass "the migration follows XDG_CONFIG_HOME"
