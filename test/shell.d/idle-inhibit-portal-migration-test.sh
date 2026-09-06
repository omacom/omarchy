#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

migration="$ROOT/migrations/1788655505.sh"
shipped="$ROOT/config/xdg-desktop-portal/hyprland-portals.conf"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

home="$test_dir/home"
portals_conf="$home/.config/xdg-desktop-portal/hyprland-portals.conf"

# The migration restarts the portal; a test must never reach the real session bus.
stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
echo "$*" >>"${SYSTEMCTL_CALLS:?}"
STUB
chmod +x "$stub_bin/systemctl"

systemctl_calls="$test_dir/systemctl-calls"

run_migration() {
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" \
    SYSTEMCTL_CALLS="$systemctl_calls" bash -euo pipefail "$migration" >/dev/null 2>&1
}

# The shipped config is what makes browsers fall through to the Wayland
# idle-inhibit protocol; without this key the whole change is a no-op.
grep -q "^org.freedesktop.impl.portal.Inhibit=none$" "$shipped" ||
  fail "shipped config disables the Inhibit portal"
grep -q "^default=hyprland;gtk$" "$shipped" ||
  fail "shipped config keeps the stock backend routing"
pass "shipped config disables the Inhibit portal"

# Fresh install: no file yet, so the shipped default lands and the portal picks it up.
rm -rf "$home"
: >"$systemctl_calls"
run_migration || fail "migration succeeds when no portals.conf exists"
[[ -f $portals_conf ]] || fail "migration installs the portals config"
cmp -s "$portals_conf" "$shipped" || fail "migration installs the shipped config verbatim"
grep -q "try-restart xdg-desktop-portal.service" "$systemctl_calls" ||
  fail "migration restarts the portal so the change applies without a relogin"
pass "migration installs the portals config and restarts the portal"

# Omarchy has never shipped this file, so an existing one is hand-written
# routing. Clobbering it could break the user's screencast or file-chooser
# backends, so it is left exactly as-is.
custom=$'[preferred]\ndefault=hyprland\n'
printf '%s' "$custom" >"$portals_conf"
: >"$systemctl_calls"
run_migration || fail "migration succeeds when a custom portals.conf exists"
[[ $(cat "$portals_conf") == "${custom%$'\n'}" ]] ||
  fail "migration leaves a user-written portals.conf untouched"
[[ ! -s $systemctl_calls ]] ||
  fail "migration does not restart the portal when it changed nothing"
pass "migration leaves a user-written portals.conf untouched"

# Rerunning after a successful install hits the same guard and changes nothing.
rm -rf "$home"
run_migration || fail "migration succeeds on first run"
installed_hash=$(sha256sum "$portals_conf" | cut -d' ' -f1)
: >"$systemctl_calls"
run_migration || fail "migration reruns cleanly"
[[ $(sha256sum "$portals_conf" | cut -d' ' -f1) == "$installed_hash" ]] ||
  fail "migration is idempotent"
pass "migration is idempotent"
