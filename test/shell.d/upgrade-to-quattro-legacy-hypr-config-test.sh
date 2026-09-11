#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

upgrade_to_quattro="$ROOT/bin/omarchy-upgrade-to-quattro"

function_body() {
  awk -v name="$1" '$0 == name "() {" { inside = 1; next } inside && $0 == "}" { exit } inside' "$upgrade_to_quattro"
}

changes_body=$(function_body legacy_hypr_config_changes)
[[ -n $changes_body ]] || fail "Quattro upgrade has a legacy Hyprland comparison helper"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
test_home="$test_tmp/home"
legacy_backup="$test_tmp/legacy"
mkdir -p "$test_home/.config/hypr" "$legacy_backup/config/hypr" "$legacy_backup/default/hypr"

legacy_changes() {
  HOME="$test_home" LEGACY_BACKUP="$legacy_backup" CHANGES_BODY="$changes_body" bash -euo pipefail <<'INNER'
eval "legacy_hypr_config_changes() { $CHANGES_BODY
}"
legacy_hypr_config_changes "$LEGACY_BACKUP"
INNER
}

cat >"$legacy_backup/config/hypr/bindings.conf" <<'CONF'
bindd = SUPER, RETURN, Terminal, exec, xdg-terminal-exec
CONF
cp "$legacy_backup/config/hypr/bindings.conf" "$test_home/.config/hypr/bindings.conf"
[[ -z $(legacy_changes) ]] || fail "unchanged legacy bindings do not trigger a migration warning"
pass "unchanged legacy Hyprland config stays quiet"

echo 'bindd = SUPER, GRAVE, Dictation, exec, voxtype record toggle' >>"$test_home/.config/hypr/bindings.conf"
[[ $(legacy_changes) == bindings.conf ]] || fail "modified legacy bindings are reported"
pass "modified legacy bindings are reported"

rm -f "$test_home/.config/hypr/bindings.conf"
cat >"$legacy_backup/default/hypr/envs.conf" <<'CONF'
env = XCURSOR_SIZE,24
CONF
cp "$legacy_backup/default/hypr/envs.conf" "$test_home/.config/hypr/envs.conf"
echo 'env = LIBVA_DRIVER_NAME,nvidia' >>"$test_home/.config/hypr/envs.conf"
[[ $(legacy_changes) == envs.conf ]] || fail "legacy env overrides compare against default/hypr/envs.conf"
pass "legacy environment overrides use the correct stock reference"

rm -f "$legacy_backup/default/hypr/envs.conf"
[[ -z $(legacy_changes) ]] || fail "missing stock reference does not create an unprovable warning"
pass "missing legacy reference stays conservative"

grep -F 'post-boot.d/quattro-legacy-hypr-config-warning' "$upgrade_to_quattro" >/dev/null ||
  fail "upgrade leaves a one-shot post-boot warning for detected legacy config"
grep -F 'omarchy-notification-send -u critical' "$upgrade_to_quattro" >/dev/null ||
  fail "post-boot legacy warning is critical"
grep -F 'The old .conf files are kept for reference but are no longer loaded' "$upgrade_to_quattro" >/dev/null ||
  fail "post-boot warning explains why the legacy files need review"
grep -F 'rm -f "\$0"' "$upgrade_to_quattro" >/dev/null ||
  fail "post-boot warning removes itself only after successful delivery"
pass "Quattro upgrade carries the warning across reboot"
