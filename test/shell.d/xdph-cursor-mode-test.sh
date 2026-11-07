#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1792090074.sh"
default="$ROOT/config/hypr/xdph.conf"

# The shipped default asks for an embedded cursor, so a browser share that
# cannot request a mode itself (Chromium's portal client) still shows one.
grep -q '^    cursor_mode = 2$' "$default" ||
  fail "the shipped xdph.conf defaults to an embedded cursor" "$(cat "$default")"
pass "the shipped xdph.conf defaults to an embedded cursor"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
config_dir="$tmpdir/home/.config/hypr"
mkdir -p "$config_dir"

# An env without the user session's bus, so the migration's portal restart is
# skipped exactly as it would be on a headless machine.
run_migration() {
  env -u DBUS_SESSION_BUS_ADDRESS -u XDG_RUNTIME_DIR \
    HOME="$tmpdir/home" OMARCHY_PATH="$ROOT" \
    bash -euo pipefail "$migration" >/dev/null
}

old_default='screencopy {
    allow_token_by_default = true
    custom_picker_binary = hyprland-preview-share-picker
}'

# Every historical shipped default is refreshed; run twice, as a retried update
# would.
for run in 1 2; do
  printf '%s\n' "$old_default" >"$config_dir/xdph.conf"
  run_migration
  [[ $(<"$config_dir/xdph.conf") == "$(cat "$default")" ]] ||
    fail "an old shipped default gains the cursor mode (run $run)" "$(cat "$config_dir/xdph.conf")"
done
pass "an old shipped default gains the cursor mode, idempotently"

# A file already carrying the setting is left alone.
printf '%s\n' "$old_default" | sed 's/}$//' >"$config_dir/xdph.conf"
printf '    cursor_mode = 2\n}\n' >>"$config_dir/xdph.conf"
customized=$(<"$config_dir/xdph.conf")
run_migration
[[ $(<"$config_dir/xdph.conf") == "$customized" ]] ||
  fail "a config already carrying the cursor mode is untouched" "$(cat "$config_dir/xdph.conf")"
pass "a config already carrying the cursor mode is untouched"

# A user-modified file keeps its edits.
printf '%s\n' "$old_default" >"$config_dir/xdph.conf"
printf '    # my own note\n' >>"$config_dir/xdph.conf"
customized=$(<"$config_dir/xdph.conf")
run_migration
[[ $(<"$config_dir/xdph.conf") == "$customized" ]] ||
  fail "a user-modified xdph.conf is not overwritten" "$(cat "$config_dir/xdph.conf")"
pass "a user-modified xdph.conf is not overwritten"

# No config yet: a fresh install gets the default from the package copy.
rm -f "$config_dir/xdph.conf"
run_migration
[[ ! -e $config_dir/xdph.conf ]] ||
  fail "the migration does not fabricate a config" "$(ls -l "$config_dir")"
pass "the migration does not fabricate a config"
