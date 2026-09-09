#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

copy_migration="$ROOT/migrations/1786643346.sh"
hermes_migration="$ROOT/migrations/1787760281.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
test_home="$test_tmp/home"
state_dir="$test_tmp/migration-state"
mkdir -p "$stub_bin" "$test_home" "$state_dir" "$test_home/.local/bin" "$test_home/.local/state/omarchy"

GUM_LOG="$test_tmp/gum.log"
PKG_LOG="$test_tmp/pkg.log"
INSTALLER_LOG="$test_tmp/installer.log"
MISE_LOG="$test_tmp/mise.log"
PKG_ADD_LOG="$test_tmp/pkg-add.log"
: >"$GUM_LOG"
: >"$PKG_LOG"
: >"$INSTALLER_LOG"
: >"$MISE_LOG"
: >"$PKG_ADD_LOG"

export GUM_LOG PKG_LOG INSTALLER_LOG MISE_LOG PKG_ADD_LOG

unset OMARCHY_UPDATE_UNATTENDED || true
unset OMARCHY_UPDATE_STRICT || true
unset OMARCHY_UPDATE_MISE || true

cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"${GUM_LOG:-/dev/null}"
exit "${OMARCHY_TEST_GUM_EXIT:-99}"
STUB

cat >"$stub_bin/omarchy-pkg-present" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"${PKG_LOG:-/dev/null}"
if [[ ${1:-} == "hermes-desktop" ]]; then
  [[ ${OMARCHY_TEST_DESKTOP_INSTALLED:-0} == "1" ]]
else
  exit 1
fi
STUB

cat >"$stub_bin/omarchy-install-hermes-cli" <<'STUB'
#!/bin/bash
printf 'installer:%s\n' "$*" >>"${INSTALLER_LOG:-/dev/null}"
if [[ ${1:-} == "--owns" ]]; then
  [[ ${OMARCHY_TEST_WRAPPER_OWNED:-0} == "1" ]]
else
  exit "${OMARCHY_TEST_INSTALLER_EXIT:-0}"
fi
STUB

cat >"$stub_bin/mise" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"${MISE_LOG:-/dev/null}"
exit 0
STUB

cat >"$stub_bin/omarchy-pkg-add" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"${PKG_ADD_LOG:-/dev/null}"
exit 0
STUB

cat >"$stub_bin/omarchy-notification-dismiss" <<'STUB'
#!/bin/bash
exit 0
STUB

chmod +x "$stub_bin"/*

reset_logs() {
  : >"$GUM_LOG"
  : >"$PKG_LOG"
  : >"$INSTALLER_LOG"
  : >"$MISE_LOG"
  : >"$PKG_ADD_LOG"
}

installer_bare_calls() {
  grep -c '^installer:$' "$INSTALLER_LOG" || true
}

installer_owns_calls() {
  grep -c '^installer:--owns$' "$INSTALLER_LOG" || true
}

# --- Copy URL migration ---

profile_root="$test_home/.config/chromium"
preferences="$profile_root/Default/Preferences"
mkdir -p "$(dirname "$preferences")"

ghost_id="ikkebdkaanlebnifjnbeiaklodhbjcci"
pinned_id="bgpiichlckmfanooecilcjemknkcpngb"

write_stale_preferences() {
  jq -n --arg ghost "$ghost_id" --arg pinned "$pinned_id" '{extensions: {commands: {"linux:Alt+Shift+L": {command_name: "copy-url", extension: $ghost, global: false}}, settings: {($ghost): {commands: {"copy-url": {suggested_key: "Alt+Shift+L", was_assigned: true}}}, ($pinned): {commands: {"copy-url": {suggested_key: "Alt+Shift+L"}}}}}}' >"$preferences"
}

open_browser() {
  mkdir -p "$profile_root"
  ln -sfn "test-host-1234" "$profile_root/SingletonLock"
}

close_browser() {
  rm -f "$profile_root/SingletonLock"
}

# Unattended + open profile: nonzero, gum never called, actionable stderr.
write_stale_preferences
open_browser
before_hash=$(sha256sum "$preferences" | cut -d' ' -f1)
reset_logs
set +e
OMARCHY_UPDATE_UNATTENDED=1 HOME="$test_home" OMARCHY_MIGRATION_STATE="$state_dir" PATH="$stub_bin:$PATH" \
  bash -euo pipefail "$copy_migration" >"$test_tmp/copy-unattended.out" 2>"$test_tmp/copy-unattended.err"
copy_unattended_status=$?
set -e
(( copy_unattended_status != 0 )) || fail "copy-url unattended defers with nonzero exit"
[[ ! -s $GUM_LOG ]] || fail "copy-url unattended never calls gum" "$(cat "$GUM_LOG")"
grep -q "Close" "$test_tmp/copy-unattended.err" || fail "copy-url unattended stderr is actionable (close browsers)" "$(cat "$test_tmp/copy-unattended.err")"
grep -q "omarchy-migrate" "$test_tmp/copy-unattended.err" || fail "copy-url unattended stderr names omarchy-migrate" "$(cat "$test_tmp/copy-unattended.err")"
[[ $(sha256sum "$preferences" | cut -d' ' -f1) == "$before_hash" ]] || fail "copy-url unattended leaves preferences alone"
[[ ! -f $state_dir/1786643346.sh ]] || fail "copy-url unattended leaves marker absent"
pass "copy-url unattended defers without prompting"

# Interactive + accept: completes (shape of existing test).
close_browser
write_stale_preferences
open_browser
cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"${GUM_LOG:-/dev/null}"
touch "${GUM_CALLED_FILE:?}"
rm -f "$HOME/.config/chromium/SingletonLock"
exit 0
STUB
chmod +x "$stub_bin/gum"
reset_logs
export GUM_CALLED_FILE="$test_tmp/gum-called"
rm -f "$GUM_CALLED_FILE"
set +e
HOME="$test_home" OMARCHY_MIGRATION_STATE="$state_dir" PATH="$stub_bin:$PATH" \
  env -u OMARCHY_UPDATE_UNATTENDED -u OMARCHY_UPDATE_STRICT \
  bash -euo pipefail "$copy_migration" >"$test_tmp/copy-interactive.out" 2>"$test_tmp/copy-interactive.err"
copy_interactive_status=$?
set -e
unset GUM_CALLED_FILE
(( copy_interactive_status == 0 )) || fail "copy-url interactive completes on accept" "$(cat "$test_tmp/copy-interactive.err")"
[[ -f $test_tmp/gum-called ]] || fail "copy-url interactive asks before repairing"
jq -e --arg pinned "$pinned_id" '.extensions.commands["linux:Alt+Shift+L"].extension == $pinned' "$preferences" >/dev/null || fail "copy-url interactive repairs after confirm"
pass "copy-url interactive repairs on confirmation"
rm -f "$preferences.omarchy-copy-url-repair.bak"
close_browser

# Restore default gum stub for remaining cases.
cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"${GUM_LOG:-/dev/null}"
exit "${OMARCHY_TEST_GUM_EXIT:-99}"
STUB
chmod +x "$stub_bin/gum"

# --- Hermes migration ---

hermes_wrapper="$test_home/.local/bin/hermes"
preinstalls_marker="$test_home/.local/state/omarchy/preinstalls-removed"

reset_hermes_home() {
  rm -f "$hermes_wrapper" "$preinstalls_marker"
  rm -f "$state_dir/1787760281.sh"
}

# strict+skip+plain-install-path: defer, installer not called, marker absent.
reset_hermes_home
reset_logs
set +e
OMARCHY_UPDATE_STRICT=1 OMARCHY_UPDATE_MISE=skip OMARCHY_TEST_DESKTOP_INSTALLED=0 \
  HOME="$test_home" OMARCHY_MIGRATION_STATE="$state_dir" PATH="$stub_bin:$ROOT/bin:$PATH" \
  bash -euo pipefail "$hermes_migration" >"$test_tmp/hermes-defer-plain.out" 2>"$test_tmp/hermes-defer-plain.err"
hermes_plain_status=$?
set -e
(( hermes_plain_status != 0 )) || fail "hermes strict+skip plain defers nonzero"
[[ ! -s $INSTALLER_LOG ]] || fail "hermes strict+skip plain never calls installer" "$(cat "$INSTALLER_LOG")"
grep -q "omarchy-migrate" "$test_tmp/hermes-defer-plain.err" || fail "hermes strict+skip plain stderr names omarchy-migrate" "$(cat "$test_tmp/hermes-defer-plain.err")"
grep -q "mise=run" "$test_tmp/hermes-defer-plain.err" || fail "hermes strict+skip plain stderr names --mise=run" "$(cat "$test_tmp/hermes-defer-plain.err")"
[[ ! -f $state_dir/1787760281.sh ]] || fail "hermes strict+skip plain leaves marker absent"
pass "hermes strict+skip defers plain install"

# strict with MISE unset (default skip): also defers.
reset_hermes_home
reset_logs
set +e
OMARCHY_UPDATE_STRICT=1 OMARCHY_TEST_DESKTOP_INSTALLED=0 \
  HOME="$test_home" OMARCHY_MIGRATION_STATE="$state_dir" PATH="$stub_bin:$ROOT/bin:$PATH" \
  env -u OMARCHY_UPDATE_MISE \
  bash -euo pipefail "$hermes_migration" >"$test_tmp/hermes-defer-unset.out" 2>"$test_tmp/hermes-defer-unset.err"
hermes_unset_status=$?
set -e
(( hermes_unset_status != 0 )) || fail "hermes strict with unset mise defers nonzero"
[[ ! -s $INSTALLER_LOG ]] || fail "hermes strict with unset mise never calls installer" "$(cat "$INSTALLER_LOG")"
pass "hermes strict with unset mise defers"

# strict+skip+desktop-present: defer too, not swallowed by || true.
reset_hermes_home
reset_logs
set +e
OMARCHY_UPDATE_STRICT=1 OMARCHY_UPDATE_MISE=skip OMARCHY_TEST_DESKTOP_INSTALLED=1 \
  HOME="$test_home" OMARCHY_MIGRATION_STATE="$state_dir" PATH="$stub_bin:$ROOT/bin:$PATH" \
  bash -euo pipefail "$hermes_migration" >"$test_tmp/hermes-defer-desktop.out" 2>"$test_tmp/hermes-defer-desktop.err"
hermes_desktop_defer_status=$?
set -e
(( hermes_desktop_defer_status != 0 )) || fail "hermes strict+skip desktop defers nonzero"
[[ ! -s $INSTALLER_LOG ]] || fail "hermes strict+skip desktop never calls installer (not swallowed by || true)" "$(cat "$INSTALLER_LOG")"
grep -q "omarchy-migrate" "$test_tmp/hermes-defer-desktop.err" || fail "hermes strict+skip desktop stderr names omarchy-migrate"
[[ ! -f $state_dir/1787760281.sh ]] || fail "hermes strict+skip desktop leaves marker absent"
pass "hermes strict+skip defers desktop path"

# strict+mise=run bare path: installer called once, completes.
reset_hermes_home
reset_logs
set +e
OMARCHY_UPDATE_STRICT=1 OMARCHY_UPDATE_MISE=run OMARCHY_TEST_DESKTOP_INSTALLED=0 \
  HOME="$test_home" OMARCHY_MIGRATION_STATE="$state_dir" PATH="$stub_bin:$ROOT/bin:$PATH" \
  bash -euo pipefail "$hermes_migration" >"$test_tmp/hermes-strict-run.out" 2>"$test_tmp/hermes-strict-run.err"
hermes_strict_run_status=$?
set -e
(( hermes_strict_run_status == 0 )) || fail "hermes strict+mise=run completes" "$(cat "$test_tmp/hermes-strict-run.err")"
(( $(installer_bare_calls) == 1 )) || fail "hermes strict+mise=run calls installer once" "$(cat "$INSTALLER_LOG")"
touch "$state_dir/1787760281.sh"
[[ -f $state_dir/1787760281.sh ]] || fail "hermes strict+mise=run records marker"
pass "hermes strict+mise=run installs"

# Full unattended (UNATTENDED=1, no STRICT) with mise=skip: installer called, completes.
reset_hermes_home
reset_logs
set +e
OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_UPDATE_MISE=skip OMARCHY_TEST_DESKTOP_INSTALLED=0 \
  HOME="$test_home" OMARCHY_MIGRATION_STATE="$state_dir" PATH="$stub_bin:$ROOT/bin:$PATH" \
  env -u OMARCHY_UPDATE_STRICT \
  bash -euo pipefail "$hermes_migration" >"$test_tmp/hermes-full.out" 2>"$test_tmp/hermes-full.err"
hermes_full_status=$?
set -e
(( hermes_full_status == 0 )) || fail "hermes full unattended completes" "$(cat "$test_tmp/hermes-full.err")"
(( $(installer_bare_calls) == 1 )) || fail "hermes full unattended calls installer" "$(cat "$INSTALLER_LOG")"
touch "$state_dir/1787760281.sh"
[[ -f $state_dir/1787760281.sh ]] || fail "hermes full unattended records marker"
pass "hermes full unattended installs"

# Interactive: completes.
reset_hermes_home
reset_logs
set +e
OMARCHY_TEST_DESKTOP_INSTALLED=0 \
  HOME="$test_home" OMARCHY_MIGRATION_STATE="$state_dir" PATH="$stub_bin:$ROOT/bin:$PATH" \
  env -u OMARCHY_UPDATE_UNATTENDED -u OMARCHY_UPDATE_STRICT -u OMARCHY_UPDATE_MISE \
  bash -euo pipefail "$hermes_migration" >"$test_tmp/hermes-interactive.out" 2>"$test_tmp/hermes-interactive.err"
hermes_interactive_status=$?
set -e
(( hermes_interactive_status == 0 )) || fail "hermes interactive completes" "$(cat "$test_tmp/hermes-interactive.err")"
(( $(installer_bare_calls) == 1 )) || fail "hermes interactive calls installer" "$(cat "$INSTALLER_LOG")"
pass "hermes interactive installs"

# preinstalls-removed strict+skip: exit 0, no installer.
reset_hermes_home
mkdir -p "$(dirname "$preinstalls_marker")"
touch "$preinstalls_marker"
reset_logs
set +e
OMARCHY_UPDATE_STRICT=1 OMARCHY_UPDATE_MISE=skip OMARCHY_TEST_DESKTOP_INSTALLED=0 \
  HOME="$test_home" OMARCHY_MIGRATION_STATE="$state_dir" PATH="$stub_bin:$ROOT/bin:$PATH" \
  bash -euo pipefail "$hermes_migration" >"$test_tmp/hermes-preinstalls.out" 2>"$test_tmp/hermes-preinstalls.err"
hermes_preinstalls_status=$?
set -e
(( hermes_preinstalls_status == 0 )) || fail "hermes preinstalls-removed exits 0"
[[ ! -s $INSTALLER_LOG ]] || fail "hermes preinstalls-removed never calls installer" "$(cat "$INSTALLER_LOG")"
pass "hermes preinstalls-removed skips"
rm -f "$preinstalls_marker"

# foreign-wrapper strict+skip: exit 0, no bare install.
reset_hermes_home
printf '#!/bin/bash\necho foreign\n' >"$hermes_wrapper"
chmod +x "$hermes_wrapper"
before_wrapper=$(cat "$hermes_wrapper")
reset_logs
set +e
OMARCHY_UPDATE_STRICT=1 OMARCHY_UPDATE_MISE=skip OMARCHY_TEST_DESKTOP_INSTALLED=0 OMARCHY_TEST_WRAPPER_OWNED=0 \
  HOME="$test_home" OMARCHY_MIGRATION_STATE="$state_dir" PATH="$stub_bin:$ROOT/bin:$PATH" \
  bash -euo pipefail "$hermes_migration" >"$test_tmp/hermes-foreign.out" 2>"$test_tmp/hermes-foreign.err"
hermes_foreign_status=$?
set -e
(( hermes_foreign_status == 0 )) || fail "hermes foreign-wrapper exits 0"
(( $(installer_bare_calls) == 0 )) || fail "hermes foreign-wrapper never runs installer" "$(cat "$INSTALLER_LOG")"
[[ $(cat "$hermes_wrapper") == "$before_wrapper" ]] || fail "hermes foreign-wrapper leaves wrapper alone"
pass "hermes foreign-wrapper skips"
rm -f "$hermes_wrapper"

# desktop-present+mise=run: installer called, exits 0 (|| true preserved).
reset_hermes_home
reset_logs
set +e
OMARCHY_UPDATE_STRICT=1 OMARCHY_UPDATE_MISE=run OMARCHY_TEST_DESKTOP_INSTALLED=1 \
  HOME="$test_home" OMARCHY_MIGRATION_STATE="$state_dir" PATH="$stub_bin:$ROOT/bin:$PATH" \
  bash -euo pipefail "$hermes_migration" >"$test_tmp/hermes-desktop-run.out" 2>"$test_tmp/hermes-desktop-run.err"
hermes_desktop_run_status=$?
set -e
(( hermes_desktop_run_status == 0 )) || fail "hermes desktop+mise=run exits 0"
(( $(installer_bare_calls) == 1 )) || fail "hermes desktop+mise=run calls installer" "$(cat "$INSTALLER_LOG")"
pass "hermes desktop+mise=run stands aside via installer"

# --- Runner: marker + queue stop ---

runner_root="$test_tmp/runner-omarchy"
runner_home="$test_tmp/runner-home"
runner_state="$test_tmp/runner-state"
mkdir -p "$runner_root/migrations" "$runner_home/.local/bin" "$runner_home/.local/state/omarchy" "$runner_state"
cp "$hermes_migration" "$runner_root/migrations/1787760281.sh"
cat >"$runner_root/migrations/1787760282.sh" <<SH
echo second >>"$test_tmp/runner-calls"
SH
: >"$test_tmp/runner-calls"

set +e
OMARCHY_UPDATE_STRICT=1 OMARCHY_UPDATE_MISE=skip OMARCHY_TEST_DESKTOP_INSTALLED=0 \
  HOME="$runner_home" OMARCHY_PATH="$runner_root" OMARCHY_MIGRATION_STATE="$runner_state" PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-migrate" >"$test_tmp/runner-defer.out" 2>"$test_tmp/runner-defer.err"
runner_defer_status=$?
set -e
(( runner_defer_status != 0 )) || fail "runner stops queue on deferral"
[[ ! -f $runner_state/1787760281.sh ]] || fail "runner leaves deferred marker absent"
[[ ! -s $test_tmp/runner-calls ]] || fail "runner does not run later migrations after deferral"
OMARCHY_TEST_DESKTOP_INSTALLED=0 HOME="$runner_home" OMARCHY_PATH="$runner_root" OMARCHY_MIGRATION_STATE="$runner_state" PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-migrate" --pending >"$test_tmp/runner-pending.out" 2>/dev/null
grep -q '^1787760281\.sh$' "$test_tmp/runner-pending.out" || fail "deferred migration stays pending" "$(cat "$test_tmp/runner-pending.out")"
pass "runner stops queue on deferral and stays pending"

# Runner success records marker.
runner_root2="$test_tmp/runner2-omarchy"
runner_home2="$test_tmp/runner2-home"
runner_state2="$test_tmp/runner2-state"
mkdir -p "$runner_root2/migrations" "$runner_home2/.local/bin" "$runner_home2/.local/state/omarchy" "$runner_state2"
cp "$hermes_migration" "$runner_root2/migrations/1787760281.sh"
set +e
OMARCHY_UPDATE_STRICT=1 OMARCHY_UPDATE_MISE=run OMARCHY_TEST_DESKTOP_INSTALLED=0 \
  HOME="$runner_home2" OMARCHY_PATH="$runner_root2" OMARCHY_MIGRATION_STATE="$runner_state2" PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-migrate" >"$test_tmp/runner-success.out" 2>"$test_tmp/runner-success.err"
runner_success_status=$?
set -e
(( runner_success_status == 0 )) || fail "runner completes on installer success" "$(cat "$test_tmp/runner-success.err")"
[[ -f $runner_state2/1787760281.sh ]] || fail "runner records marker on completion"
pass "runner records marker on completion"
