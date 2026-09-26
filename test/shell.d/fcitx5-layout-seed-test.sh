#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

helper="$ROOT/bin/omarchy-fcitx5-seed-layout"
migration="$ROOT/migrations/1790096150.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

stub_bin="$test_dir/bin"
mkdir -p "$stub_bin" "$test_dir/home/.config/fcitx5" "$test_dir/etc"

cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"${SYSTEMCTL_CALLS:?}"
case "$*" in
*"is-active"*omarchy-fcitx5*)
  exit "${FCITX_ACTIVE:-1}"
  ;;
*"is-active"*graphical-session*)
  exit "${SYSTEMCTL_ACTIVE:-1}"
  ;;
*"stop"*omarchy-fcitx5*)
  echo stop >>"${STOP_CALLS:?}"
  exit 0
  ;;
*)
  exit 0
  ;;
esac
STUB
cat >"$stub_bin/pgrep" <<'STUB'
#!/bin/bash
# No live fcitx5 unless a test opts in via FCITX_PGREP=0.
exit "${FCITX_PGREP:-1}"
STUB
cat >"$stub_bin/pkill" <<'STUB'
#!/bin/bash
echo pkill >>"${STOP_CALLS:?}"
exit 0
STUB
cat >"$stub_bin/omarchy-restart-xcompose" <<'STUB'
#!/bin/bash
echo restart >>"${RESTART_CALLS:?}"
STUB
chmod +x "$stub_bin"/*

stock_us_profile() {
  cat <<'EOF'
[Groups/0]
# Group Name
Name=Default
# Layout
Default Layout=us
# Default Input Method
DefaultIM=keyboard-us

[Groups/0/Items/0]
# Name
Name=keyboard-us
# Layout
Layout=

[GroupOrder]
0=Default
EOF
}

multi_im_profile() {
  cat <<'EOF'
[Groups/0]
Name=Default
Default Layout=us
DefaultIM=keyboard-us

[Groups/0/Items/0]
Name=keyboard-us
Layout=

[Groups/0/Items/1]
Name=mozc
Layout=

[GroupOrder]
0=Default
EOF
}

write_vconsole() {
  printf '%s\n' "$@" >"$test_dir/etc/vconsole.conf"
}

run_helper() {
  : >"$test_dir/stop-calls"
  SYSTEMCTL_CALLS="$test_dir/systemctl-calls" \
    STOP_CALLS="$test_dir/stop-calls" \
    FCITX_ACTIVE="${FCITX_ACTIVE:-1}" \
    FCITX_PGREP="${FCITX_PGREP:-1}" \
    OMARCHY_VCONSOLE="$test_dir/etc/vconsole.conf" \
    OMARCHY_FCITX5_PROFILE="$test_dir/home/.config/fcitx5/profile" \
    HOME="$test_dir/home" \
    PATH="$stub_bin:$PATH" \
    bash -euo pipefail "$helper"
}

profile="$test_dir/home/.config/fcitx5/profile"

# --- helper ---

rm -f "$profile"
write_vconsole 'XKBLAYOUT=us'
[[ -z $(run_helper) ]] || fail "us console leaves a missing profile alone"
[[ ! -e $profile ]] || fail "us console does not invent a profile"
pass "us console leaves fcitx5 to create its default"

rm -f "$profile"
write_vconsole 'XKBLAYOUT=fr'
[[ $(run_helper) == changed ]] || fail "missing non-us profile is seeded"
grep -qx 'DefaultIM=keyboard-fr' "$profile" || fail "seeded DefaultIM is keyboard-fr"
grep -qx 'Default Layout=fr' "$profile" || fail "seeded Default Layout is fr"
grep -qx 'Name=keyboard-fr' "$profile" || fail "seeded item is keyboard-fr"
pass "missing non-us profile is seeded from XKBLAYOUT"

[[ -z $(run_helper) ]] || fail "already-correct profile is left alone"
pass "helper is idempotent once the layout matches"

stock_us_profile >"$profile"
write_vconsole 'XKBLAYOUT=fr'
[[ $(run_helper) == changed ]] || fail "stock us profile is rewritten for fr"
grep -qx 'DefaultIM=keyboard-fr' "$profile" || fail "stock rewrite sets DefaultIM"
grep -qx 'Name=keyboard-fr' "$profile" || fail "stock rewrite sets item Name"
pass "stock keyboard-us-only profile is rewritten for a non-us console"

# Running daemon must be stopped before the profile write so it cannot flush
# the old layout back over the seed on shutdown.
stock_us_profile >"$profile"
write_vconsole 'XKBLAYOUT=fr'
FCITX_ACTIVE=0 FCITX_PGREP=1
[[ $(run_helper) == changed ]] || fail "helper still seeds while fcitx5 is active"
grep -qx stop "$test_dir/stop-calls" || fail "helper stops omarchy-fcitx5 before writing"
grep -qx 'DefaultIM=keyboard-fr' "$profile" || fail "profile stays fr after stop-then-write"
pass "helper stops a running fcitx5 before rewriting the profile"
FCITX_ACTIVE=1 FCITX_PGREP=1

stock_us_profile >"$profile"
write_vconsole 'XKBLAYOUT=us'
[[ -z $(run_helper) ]] || fail "stock us profile stays on a us console"
grep -qx 'DefaultIM=keyboard-us' "$profile" || fail "us console keeps keyboard-us"
pass "stock us profile is left alone when the console is us"

multi_im_profile >"$profile"
write_vconsole 'XKBLAYOUT=fr'
[[ -z $(run_helper) ]] || fail "multi-IM profile must not be rewritten"
grep -qx 'DefaultIM=keyboard-us' "$profile" || fail "multi-IM DefaultIM is preserved"
grep -qx 'Name=mozc' "$profile" || fail "multi-IM engines are preserved"
pass "intentional multi-IM profiles are left alone"

stock_us_profile >"$profile"
write_vconsole 'XKBLAYOUT=de' 'XKBVARIANT=nodeadkeys'
[[ $(run_helper) == changed ]] || fail "variant layout is seeded"
grep -qx 'DefaultIM=keyboard-de-nodeadkeys' "$profile" || fail "variant DefaultIM"
grep -qx 'Default Layout=de-nodeadkeys' "$profile" || fail "variant Default Layout"
pass "XKBVARIANT is folded into the fcitx5 keyboard id"

stock_us_profile >"$profile"
write_vconsole 'XKBLAYOUT=us,ara'
[[ -z $(run_helper) ]] || fail "comma list uses the first layout only"
# first entry is us — no rewrite
grep -qx 'DefaultIM=keyboard-us' "$profile" || fail "leading us in XKBLAYOUT keeps stock"
pass "comma-separated XKBLAYOUT uses the first layout"

stock_us_profile >"$profile"
write_vconsole 'XKBLAYOUT=ara,us'
[[ $(run_helper) == changed ]] || fail "leading non-us layout rewrites stock"
grep -qx 'DefaultIM=keyboard-ara' "$profile" || fail "leading ara becomes keyboard-ara"
pass "leading non-us layout in a comma list rewrites stock"

# --- migration ---

run_migration() {
  : >"$test_dir/systemctl-calls"
  : >"$test_dir/restart-calls"
  : >"$test_dir/stop-calls"
  SYSTEMCTL_CALLS="$test_dir/systemctl-calls" \
    RESTART_CALLS="$test_dir/restart-calls" \
    STOP_CALLS="$test_dir/stop-calls" \
    SYSTEMCTL_ACTIVE="${1:-1}" \
    FCITX_ACTIVE="${FCITX_ACTIVE:-1}" \
    FCITX_PGREP="${FCITX_PGREP:-1}" \
    OMARCHY_VCONSOLE="$test_dir/etc/vconsole.conf" \
    OMARCHY_FCITX5_PROFILE="$profile" \
    HOME="$test_dir/home" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    bash -euo pipefail "$migration" >"$test_dir/migration.out"
}

stock_us_profile >"$profile"
write_vconsole 'XKBLAYOUT=fr'
run_migration 0
grep -qx 'DefaultIM=keyboard-fr' "$profile" || fail "migration rewrites stock profile"
grep -qx restart "$test_dir/restart-calls" || fail "migration restarts fcitx5 in a graphical session"
pass "migration rewrites stock and restarts fcitx5 when a session is up"

stock_us_profile >"$profile"
run_migration 1
grep -qx 'DefaultIM=keyboard-fr' "$profile" || fail "migration still rewrites without a session"
[[ ! -s $test_dir/restart-calls ]] || fail "migration skips restart outside a graphical session"
pass "migration skips restart when there is no graphical session"

grep -F 'fcitx5-layout.sh' "$ROOT/install/user/all.sh" >/dev/null ||
  fail "fresh installs do not seed fcitx5 from install/user/all.sh"
pass "install/user/all.sh seeds fcitx5 layout on fresh installs"
