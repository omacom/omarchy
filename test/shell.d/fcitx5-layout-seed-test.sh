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
  # Model the daemon flushing its old in-memory profile during shutdown.
  cp "$TEST_STOCK_PROFILE" "$OMARCHY_FCITX5_PROFILE"
  exit 0
  ;;
*"start"*omarchy-fcitx5*)
  echo start >>"${RESTART_CALLS:?}"
  exit 0
  ;;
*)
  exit 0
  ;;
esac
STUB
cat >"$stub_bin/pgrep" <<'STUB'
#!/bin/bash
# Scoped checks see only our process; an unscoped check also sees another user.
if [[ $* == "-u $UID -x fcitx5" ]]; then
  exit "${FCITX_PGREP:-1}"
fi
if [[ ${FCITX_OTHER:-1} == 0 ]]; then exit 0; fi
exit "${FCITX_PGREP:-1}"
STUB
cat >"$stub_bin/pkill" <<'STUB'
#!/bin/bash
printf 'pkill %s\n' "$*" >>"${STOP_CALLS:?}"
exit 0
STUB
cat >"$stub_bin/mkdir" <<'STUB'
#!/bin/bash
if [[ ${TEST_WRITE_FAIL:-0} == 1 && $* == "-p $(dirname "$OMARCHY_FCITX5_PROFILE")" ]]; then
  echo "synthetic profile write failure" >&2
  exit 1
fi
exec /bin/mkdir "$@"
STUB
cat >"$stub_bin/cat" <<'STUB'
#!/bin/bash
if [[ ${TEST_PARTIAL_WRITE:-0} == 1 && $# == 0 ]]; then
  printf '[Groups/0]\n'
  exit 1
fi
exec /bin/cat "$@"
STUB
cat >"$stub_bin/mv" <<'STUB'
#!/bin/bash
if [[ ${TEST_RENAME_FAIL:-0} == 1 ]]; then exit 1; fi
exec /bin/mv "$@"
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

stock_us_profile >"$test_dir/stock-profile"
export TEST_STOCK_PROFILE="$test_dir/stock-profile"
export RESTART_CALLS="$test_dir/restart-calls"
export FCITX_OTHER=1 TEST_WRITE_FAIL=0 TEST_PARTIAL_WRITE=0 TEST_RENAME_FAIL=0

run_helper() {
  : >"$test_dir/stop-calls"
  : >"$test_dir/restart-calls"
  SYSTEMCTL_CALLS="$test_dir/systemctl-calls" \
    STOP_CALLS="$test_dir/stop-calls" \
    SYSTEMCTL_ACTIVE="${SYSTEMCTL_ACTIVE:-1}" \
    FCITX_ACTIVE="${FCITX_ACTIVE:-1}" \
    FCITX_PGREP="${FCITX_PGREP:-1}" \
    OMARCHY_VCONSOLE="$test_dir/etc/vconsole.conf" \
    OMARCHY_FCITX5_PROFILE="$test_dir/home/.config/fcitx5/profile" \
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
grep -qx "pkill -u $UID -x fcitx5" "$test_dir/stop-calls" || fail "signals are scoped to this user"
FCITX_ACTIVE=1 FCITX_PGREP=1

# An unrelated user's daemon cannot block our profile rewrite or get signalled.
stock_us_profile >"$profile"
FCITX_OTHER=0
[[ $(run_helper) == changed ]] || fail "another user's daemon does not block the helper"
[[ ! -s $test_dir/stop-calls ]] || fail "another user's daemon is not stopped"
FCITX_OTHER=1
pass "other users' input methods are ignored"

# A lingering own daemon must leave the profile untouched and restore the unit.
stock_us_profile >"$profile"
FCITX_ACTIVE=0 FCITX_PGREP=0 SYSTEMCTL_ACTIVE=0
status=0
run_helper >"$test_dir/output" 2>"$test_dir/error" || status=$?
[[ $status == 1 && ! -s $test_dir/output ]] || fail "a lingering daemon rejects the rewrite"
cmp -s "$profile" "$TEST_STOCK_PROFILE" || fail "a lingering daemon keeps its profile"
grep -qx start "$test_dir/restart-calls" || fail "failed stop restores the graphical-session unit"
pass "failed stop leaves the profile unchanged and restores the session service"

# Failure while writing must also restore the session service and remain a failure.
FCITX_PGREP=1 TEST_WRITE_FAIL=1
status=0
run_helper >"$test_dir/output" 2>"$test_dir/error" || status=$?
[[ $status != 0 && ! -s $test_dir/output ]] || fail "failed profile write does not report changed"
grep -qx start "$test_dir/restart-calls" || fail "failed write restores the graphical-session unit"
TEST_WRITE_FAIL=0
pass "failed write restores the session service without hiding the error"

# A failed write after truncation, or a failed rename, must preserve the old file.
for failure in TEST_PARTIAL_WRITE TEST_RENAME_FAIL; do
  stock_us_profile >"$profile"
  export "$failure=1"
  status=0
  run_helper >"$test_dir/output" 2>"$test_dir/error" || status=$?
  [[ $status != 0 && ! -s $test_dir/output ]] || fail "$failure remains a failure"
  cmp -s "$profile" "$TEST_STOCK_PROFILE" || fail "$failure preserves the previous profile"
  ! compgen -G "${profile}.*" >/dev/null || fail "$failure cleans temporary profiles"
  grep -qx start "$test_dir/restart-calls" || fail "$failure restores the running service"
  export "$failure=0"
  pass "$failure preserves the existing profile and cleans up"
done

# The install leaf gets the same restart guarantee as the migration.
: >"$test_dir/restart-calls"
stock_us_profile >"$profile"
SYSTEMCTL_CALLS="$test_dir/systemctl-calls" STOP_CALLS="$test_dir/stop-calls" \
  SYSTEMCTL_ACTIVE=0 FCITX_ACTIVE=0 FCITX_PGREP=1 \
  OMARCHY_VCONSOLE="$test_dir/etc/vconsole.conf" OMARCHY_FCITX5_PROFILE="$profile" \
  PATH="$stub_bin:$ROOT/bin:$PATH" bash -euo pipefail "$ROOT/install/user/fcitx5-layout.sh"
grep -qx 'DefaultIM=keyboard-fr' "$profile" || fail "install leaf seeds the profile"
grep -qx start "$test_dir/restart-calls" || fail "install leaf restores the graphical-session unit"
pass "install leaf restores the input method in a live session"
FCITX_ACTIVE=1 FCITX_PGREP=1 SYSTEMCTL_ACTIVE=1

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

for input in ara ara,us ru il,us; do
  stock_us_profile >"$profile"
  write_vconsole "XKBLAYOUT=$input" 'XKBVARIANT=phonetic'
  [[ -z $(run_helper) ]] || fail "non-latin first layout keeps the session US default"
  cmp -s "$profile" "$TEST_STOCK_PROFILE" || fail "non-latin first layout preserves stock US profile"
done
pass "non-latin layouts match Hyprland US-first policy, without inheriting the variant"

# Keep the fallback list aligned with the compositor source.
helper_layouts=$(sed -n '/^case "\$layout" in/,/^esac/p' "$helper" | sed -n '/^  af /p' | tr '|)' '  ' | xargs)
lua_layouts=$(sed -n '/^local non_latin_layouts =/,+1p' "$ROOT/default/hypr/input.lua" | tail -n 1 | tr -d '"' | xargs)
[[ $helper_layouts == "$lua_layouts" ]] || fail "helper non-latin list matches Hyprland"
pass "helper and compositor non-latin lists match"

stock_us_profile | sed 's/^Layout=$/Layout=de-nodeadkeys/' >"$profile"
cp "$profile" "$test_dir/custom-profile"
write_vconsole 'XKBLAYOUT=fr'
[[ -z $(run_helper) ]] || fail "custom per-item layout is not stock"
cmp -s "$profile" "$test_dir/custom-profile" || fail "custom per-item layout survives"
pass "custom per-item keyboard mapping is preserved"

rm -f "$profile"
ln -s "$TEST_STOCK_PROFILE" "$profile"
[[ -z $(run_helper) ]] || fail "linked profiles are left to their owner"
[[ -L $profile ]] || fail "profile symlink survives"
rm "$profile"
pass "user-managed profile symlinks are preserved"

stock_us_profile >"$profile"
FCITX_ACTIVE=1 FCITX_PGREP=1 SYSTEMCTL_ACTIVE=0
[[ $(run_helper) == changed ]] || fail "stopped service still allows profile seeding"
[[ ! -s $test_dir/restart-calls ]] || fail "intentionally stopped service stays stopped"
pass "profile seeding does not launch an intentionally stopped service"

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
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    bash -euo pipefail "$migration" >"$test_dir/migration.out"
}

stock_us_profile >"$profile"
write_vconsole 'XKBLAYOUT=fr'
FCITX_ACTIVE=0
run_migration 0
grep -qx 'DefaultIM=keyboard-fr' "$profile" || fail "migration rewrites stock profile"
[[ $(<"$test_dir/restart-calls") == start ]] || fail "migration restores fcitx5 exactly once in a graphical session"
pass "migration rewrites stock and restarts fcitx5 when a session is up"

stock_us_profile >"$profile"
run_migration 1
grep -qx 'DefaultIM=keyboard-fr' "$profile" || fail "migration still rewrites without a session"
[[ ! -s $test_dir/restart-calls ]] || fail "migration skips restart outside a graphical session"
pass "migration skips restart when there is no graphical session"

grep -F 'fcitx5-layout.sh' "$ROOT/install/user/all.sh" >/dev/null ||
  fail "fresh installs do not seed fcitx5 from install/user/all.sh"
pass "install/user/all.sh seeds fcitx5 layout on fresh installs"
