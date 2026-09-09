#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command script

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$stub_bin" "$test_home"

GUM_LOG="$test_tmp/gum.log"
SUDO_LOG="$test_tmp/sudo.log"
: >"$GUM_LOG"
: >"$SUDO_LOG"

write_stub() {
  local name="$1"
  local body="$2"

  cat >"$stub_bin/$name" <<SH
#!/bin/bash
$body
SH
  chmod +x "$stub_bin/$name"
}

run_orphan_checker() {
  HOME="$test_home" PATH="$stub_bin:$PATH" GUM_LOG="$GUM_LOG" SUDO_LOG="$SUDO_LOG" env -u OMARCHY_UPDATE_ORPHANS -u OMARCHY_UPDATE_UNATTENDED "$ROOT/bin/omarchy-update-orphan-pkgs"
}

run_orphan_headless() {
  HOME="$test_home" PATH="$stub_bin:$PATH" GUM_LOG="$GUM_LOG" SUDO_LOG="$SUDO_LOG" "$ROOT/bin/omarchy-update-orphan-pkgs"
}

run_orphan_pty() {
  # Inherits exported env (including OMARCHY_UPDATE_*); child gets a real PTY
  # for stdin/stdout/stderr via script(1) so [[ -t 0 && -t 1 ]] is true.
  HOME="$test_home" PATH="$stub_bin:$PATH" GUM_LOG="$GUM_LOG" SUDO_LOG="$SUDO_LOG" \
    script -qec "$ROOT/bin/omarchy-update-orphan-pkgs" /dev/null
}

reset_logs() {
  : >"$GUM_LOG"
  : >"$SUDO_LOG"
}

clean_pty_out() {
  tr -d '\r' <"$1"
}

# Default stubs: two orphans, gum/sudo must not run unless a case allows them.
write_stub pacman 'if [[ $1 == "-Qtdq" ]]; then printf "old-lib\nunused-tool\n"; exit 0; fi; exit 1'
write_stub sudo 'printf "%s\n" "$*" >>"${SUDO_LOG:-/dev/null}"; echo "sudo should not be called" >&2; exit 99'
write_stub gum 'printf "%s\n" "$*" >>"${GUM_LOG:-/dev/null}"; echo "gum should not be called" >&2; exit 99'

reset_logs
run_orphan_checker >"$test_tmp/noninteractive.out" 2>"$test_tmp/noninteractive.err"
grep -q '^  old-lib$' "$test_tmp/noninteractive.out" || fail "orphan checker lists orphan packages"
grep -q 'Re-run omarchy-update-orphan-pkgs in a terminal' "$test_tmp/noninteractive.out" || fail "orphan checker does not remove packages non-interactively"
[[ ! -s $GUM_LOG ]] || fail "orphan checker does not call gum non-interactively"
[[ ! -s $SUDO_LOG ]] || fail "orphan checker does not call sudo non-interactively"
pass "orphan checker only reports orphans non-interactively"

write_stub pacman 'if [[ $1 == "-Qtdq" ]]; then exit 0; fi; exit 1'
reset_logs
run_orphan_checker >"$test_tmp/none.out" 2>"$test_tmp/none.err"
[[ ! -s $test_tmp/none.out ]] || fail "orphan checker stays quiet when no orphans exist"
[[ ! -s $GUM_LOG ]] || fail "orphan checker does not call gum without orphans"
[[ ! -s $SUDO_LOG ]] || fail "orphan checker does not call sudo without orphans"
pass "orphan checker stays quiet without orphans"

# Restore orphan list for the remaining cases.
write_stub pacman 'if [[ $1 == "-Qtdq" ]]; then printf "old-lib\nunused-tool\n"; exit 0; fi; exit 1'

# ask PTY + decline: gum called once, orphans retained, exit 0.
write_stub gum 'printf "%s\n" "$*" >>"${GUM_LOG:-/dev/null}"; exit 1'
write_stub sudo 'printf "%s\n" "$*" >>"${SUDO_LOG:-/dev/null}"; echo "sudo should not be called" >&2; exit 99'
reset_logs
set +e
unset OMARCHY_UPDATE_ORPHANS
unset OMARCHY_UPDATE_UNATTENDED
export GUM_LOG SUDO_LOG
HOME="$test_home" PATH="$stub_bin:$PATH" script -qec "$ROOT/bin/omarchy-update-orphan-pkgs" /dev/null >"$test_tmp/ask-decline.out" 2>"$test_tmp/ask-decline.err"
ask_decline_status=$?
set -e
(( ask_decline_status == 0 )) || fail "ask PTY decline exits 0" "got $ask_decline_status"
(( $(wc -l <"$GUM_LOG") == 1 )) || fail "ask PTY decline calls gum once" "$(cat "$GUM_LOG")"
grep -q 'confirm --default=false' "$GUM_LOG" || fail "ask PTY decline confirms with default=false" "$(cat "$GUM_LOG")"
[[ ! -s $SUDO_LOG ]] || fail "ask PTY decline does not call sudo" "$(cat "$SUDO_LOG")"
clean_pty_out "$test_tmp/ask-decline.out" | grep -q 'Keeping orphaned packages' || fail "ask PTY decline keeps orphans" "$(clean_pty_out "$test_tmp/ask-decline.out")"
pass "ask PTY decline keeps orphans without sudo"

# ask PTY + accept: sudo without --noconfirm, interactive behavior preserved.
write_stub gum 'printf "%s\n" "$*" >>"${GUM_LOG:-/dev/null}"; exit 0'
write_stub sudo 'printf "%s\n" "$*" >>"${SUDO_LOG:-/dev/null}"; exit 0'
reset_logs
set +e
unset OMARCHY_UPDATE_ORPHANS
unset OMARCHY_UPDATE_UNATTENDED
HOME="$test_home" PATH="$stub_bin:$PATH" script -qec "$ROOT/bin/omarchy-update-orphan-pkgs" /dev/null >"$test_tmp/ask-accept.out" 2>"$test_tmp/ask-accept.err"
ask_accept_status=$?
set -e
(( ask_accept_status == 0 )) || fail "ask PTY accept exits 0" "got $ask_accept_status"
(( $(wc -l <"$GUM_LOG") == 1 )) || fail "ask PTY accept calls gum once" "$(cat "$GUM_LOG")"
grep -q 'pacman' "$SUDO_LOG" || fail "ask PTY accept calls sudo pacman" "$(cat "$SUDO_LOG")"
grep -q -- '--noconfirm' "$SUDO_LOG" && fail "ask PTY accept does not use --noconfirm" "$(cat "$SUDO_LOG")"
grep -q 'old-lib' "$SUDO_LOG" || fail "ask PTY accept passes orphan list to sudo" "$(cat "$SUDO_LOG")"
pass "ask PTY accept removes without --noconfirm"

# keep headless: no gum/no sudo, Keeping report, exit 0.
write_stub gum 'printf "%s\n" "$*" >>"${GUM_LOG:-/dev/null}"; echo "gum should not be called" >&2; exit 99'
write_stub sudo 'printf "%s\n" "$*" >>"${SUDO_LOG:-/dev/null}"; echo "sudo should not be called" >&2; exit 99'
reset_logs
set +e
export OMARCHY_UPDATE_ORPHANS="keep"
unset OMARCHY_UPDATE_UNATTENDED
run_orphan_headless >"$test_tmp/keep-headless.out" 2>"$test_tmp/keep-headless.err"
keep_headless_status=$?
set -e
(( keep_headless_status == 0 )) || fail "keep headless exits 0" "got $keep_headless_status"
grep -q 'Keeping orphaned packages' "$test_tmp/keep-headless.out" || fail "keep headless reports Keeping" "$(cat "$test_tmp/keep-headless.out")"
grep -q 'Re-run omarchy-update-orphan-pkgs in a terminal' "$test_tmp/keep-headless.out" || fail "keep headless reuses headless wording" "$(cat "$test_tmp/keep-headless.out")"
[[ ! -s $GUM_LOG ]] || fail "keep headless does not call gum" "$(cat "$GUM_LOG")"
[[ ! -s $SUDO_LOG ]] || fail "keep headless does not call sudo" "$(cat "$SUDO_LOG")"
pass "keep headless lists and keeps without gum or sudo"

# keep PTY: still no gum (mutation-proof: old helper would call gum here).
reset_logs
set +e
export OMARCHY_UPDATE_ORPHANS="keep"
unset OMARCHY_UPDATE_UNATTENDED
HOME="$test_home" PATH="$stub_bin:$PATH" script -qec "$ROOT/bin/omarchy-update-orphan-pkgs" /dev/null >"$test_tmp/keep-pty.out" 2>"$test_tmp/keep-pty.err"
keep_pty_status=$?
set -e
(( keep_pty_status == 0 )) || fail "keep PTY exits 0" "got $keep_pty_status"
[[ ! -s $GUM_LOG ]] || fail "keep PTY does not call gum" "$(cat "$GUM_LOG")"
[[ ! -s $SUDO_LOG ]] || fail "keep PTY does not call sudo" "$(cat "$SUDO_LOG")"
clean_pty_out "$test_tmp/keep-pty.out" | grep -q 'Keeping orphaned packages' || fail "keep PTY reports Keeping" "$(clean_pty_out "$test_tmp/keep-pty.out")"
pass "keep PTY lists and keeps without gum or sudo"

# remove via scoped adapter: -n plus --noconfirm and package list in order.
write_stub gum 'printf "%s\n" "$*" >>"${GUM_LOG:-/dev/null}"; echo "gum should not be called" >&2; exit 99'
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
printf '%q ' "$@" >>"${SUDO_LOG:-/dev/null}"
printf '\n' >>"${SUDO_LOG:-/dev/null}"
exit 0
STUB
chmod +x "$stub_bin/sudo"
reset_logs
set +e
export OMARCHY_UPDATE_ORPHANS="remove"
export OMARCHY_UPDATE_UNATTENDED=1
export OMARCHY_PATH="$ROOT"
HOME="$test_home" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-run" "$ROOT/bin/omarchy-update-orphan-pkgs" >"$test_tmp/remove-adapter.out" 2>"$test_tmp/remove-adapter.err"
remove_status=$?
set -e
(( remove_status == 0 )) || fail "remove via adapter exits 0" "got $remove_status; out=$(cat "$test_tmp/remove-adapter.out"); err=$(cat "$test_tmp/remove-adapter.err")"
[[ ! -s $GUM_LOG ]] || fail "remove does not call gum" "$(cat "$GUM_LOG")"
grep -q -- '-n' "$SUDO_LOG" || fail "remove via adapter uses sudo -n" "$(cat "$SUDO_LOG")"
grep -q -- '--noconfirm' "$SUDO_LOG" || fail "remove uses --noconfirm" "$(cat "$SUDO_LOG")"
grep -q 'old-lib.*unused-tool' "$SUDO_LOG" || fail "remove passes packages in order" "$(cat "$SUDO_LOG")"
grep -q 'Removing orphan system packages' "$test_tmp/remove-adapter.out" || fail "remove prints removing message" "$(cat "$test_tmp/remove-adapter.out")"
unset OMARCHY_PATH
pass "remove via adapter uses sudo -n --noconfirm with package list"

# remove failure propagates nonzero with no success message after failure.
write_stub gum 'printf "%s\n" "$*" >>"${GUM_LOG:-/dev/null}"; echo "gum should not be called" >&2; exit 99'
write_stub sudo 'printf "%s\n" "$*" >>"${SUDO_LOG:-/dev/null}"; exit 7'
reset_logs
set +e
export OMARCHY_UPDATE_ORPHANS="remove"
unset OMARCHY_UPDATE_UNATTENDED
unset OMARCHY_PATH
run_orphan_headless >"$test_tmp/remove-fail.out" 2>"$test_tmp/remove-fail.err"
remove_fail_status=$?
set -e
(( remove_fail_status != 0 )) || fail "remove failure exits nonzero" "got 0"
(( remove_fail_status == 7 )) || fail "remove failure propagates exit 7" "got $remove_fail_status"
grep -q 'pacman' "$SUDO_LOG" || fail "remove failure still calls sudo" "$(cat "$SUDO_LOG")"
[[ ! -s $GUM_LOG ]] || fail "remove failure does not call gum" "$(cat "$GUM_LOG")"
pass "remove failure propagates nonzero without masking"

# empty orphans: all policies exit 0 with no gum/sudo calls.
write_stub pacman 'if [[ $1 == "-Qtdq" ]]; then exit 0; fi; exit 1'
write_stub gum 'printf "%s\n" "$*" >>"${GUM_LOG:-/dev/null}"; echo "gum should not be called" >&2; exit 99'
write_stub sudo 'printf "%s\n" "$*" >>"${SUDO_LOG:-/dev/null}"; echo "sudo should not be called" >&2; exit 99'
for policy in ask keep remove; do
  reset_logs
  set +e
  export OMARCHY_UPDATE_ORPHANS="$policy"
  unset OMARCHY_UPDATE_UNATTENDED
  run_orphan_headless >"$test_tmp/empty-$policy.out" 2>"$test_tmp/empty-$policy.err"
  empty_status=$?
  set -e
  (( empty_status == 0 )) || fail "empty orphans with $policy exits 0" "got $empty_status"
  [[ ! -s $test_tmp/empty-$policy.out ]] || fail "empty orphans with $policy stays quiet" "$(cat "$test_tmp/empty-$policy.out")"
  [[ ! -s $GUM_LOG ]] || fail "empty orphans with $policy does not call gum" "$(cat "$GUM_LOG")"
  [[ ! -s $SUDO_LOG ]] || fail "empty orphans with $policy does not call sudo" "$(cat "$SUDO_LOG")"
done
pass "empty orphans exit 0 quietly for all policies"

# Restore orphan list.
write_stub pacman 'if [[ $1 == "-Qtdq" ]]; then printf "old-lib\nunused-tool\n"; exit 0; fi; exit 1'

# unattended without policy defaults to keep (no gum).
write_stub gum 'printf "%s\n" "$*" >>"${GUM_LOG:-/dev/null}"; echo "gum should not be called" >&2; exit 99'
write_stub sudo 'printf "%s\n" "$*" >>"${SUDO_LOG:-/dev/null}"; echo "sudo should not be called" >&2; exit 99'
reset_logs
set +e
unset OMARCHY_UPDATE_ORPHANS
export OMARCHY_UPDATE_UNATTENDED=1
run_orphan_headless >"$test_tmp/unattended-default.out" 2>"$test_tmp/unattended-default.err"
unattended_default_status=$?
set -e
(( unattended_default_status == 0 )) || fail "unattended default exits 0" "got $unattended_default_status"
grep -q 'Keeping orphaned packages' "$test_tmp/unattended-default.out" || fail "unattended default keeps orphans" "$(cat "$test_tmp/unattended-default.out")"
[[ ! -s $GUM_LOG ]] || fail "unattended default does not call gum" "$(cat "$GUM_LOG")"
[[ ! -s $SUDO_LOG ]] || fail "unattended default does not call sudo" "$(cat "$SUDO_LOG")"
pass "unattended without policy defaults to keep"

# unattended + ask under PTY must not reach gum.
reset_logs
set +e
export OMARCHY_UPDATE_ORPHANS="ask"
export OMARCHY_UPDATE_UNATTENDED=1
HOME="$test_home" PATH="$stub_bin:$PATH" script -qec "$ROOT/bin/omarchy-update-orphan-pkgs" /dev/null >"$test_tmp/unattended-ask-pty.out" 2>"$test_tmp/unattended-ask-pty.err"
unattended_ask_status=$?
set -e
(( unattended_ask_status == 0 )) || fail "unattended ask PTY exits 0" "got $unattended_ask_status"
[[ ! -s $GUM_LOG ]] || fail "unattended ask PTY does not call gum" "$(cat "$GUM_LOG")"
[[ ! -s $SUDO_LOG ]] || fail "unattended ask PTY does not call sudo" "$(cat "$SUDO_LOG")"
clean_pty_out "$test_tmp/unattended-ask-pty.out" | grep -q 'Re-run omarchy-update-orphan-pkgs in a terminal' || fail "unattended ask PTY reports instead of prompting" "$(clean_pty_out "$test_tmp/unattended-ask-pty.out")"
pass "unattended ask never reaches gum even under PTY"

# invalid policy exits 2.
reset_logs
set +e
export OMARCHY_UPDATE_ORPHANS="bogus"
unset OMARCHY_UPDATE_UNATTENDED
run_orphan_headless >"$test_tmp/invalid.out" 2>"$test_tmp/invalid.err"
invalid_status=$?
set -e
(( invalid_status == 2 )) || fail "invalid policy exits 2" "got $invalid_status"
[[ ! -s $GUM_LOG ]] || fail "invalid policy does not call gum" "$(cat "$GUM_LOG")"
[[ ! -s $SUDO_LOG ]] || fail "invalid policy does not call sudo" "$(cat "$SUDO_LOG")"
pass "invalid policy exits 2"

# explicit remove with interactive env still removes nonconfirm without gum.
write_stub gum 'printf "%s\n" "$*" >>"${GUM_LOG:-/dev/null}"; echo "gum should not be called" >&2; exit 99'
write_stub sudo 'printf "%s\n" "$*" >>"${SUDO_LOG:-/dev/null}"; exit 0'
reset_logs
set +e
export OMARCHY_UPDATE_ORPHANS="remove"
unset OMARCHY_UPDATE_UNATTENDED
unset OMARCHY_PATH
run_orphan_headless >"$test_tmp/remove-interactive.out" 2>"$test_tmp/remove-interactive.err"
remove_interactive_status=$?
set -e
(( remove_interactive_status == 0 )) || fail "explicit remove interactive exits 0" "got $remove_interactive_status"
[[ ! -s $GUM_LOG ]] || fail "explicit remove interactive does not call gum" "$(cat "$GUM_LOG")"
grep -q -- '--noconfirm' "$SUDO_LOG" || fail "explicit remove interactive uses --noconfirm" "$(cat "$SUDO_LOG")"
grep -q 'old-lib.*unused-tool' "$SUDO_LOG" || fail "explicit remove interactive passes packages in order" "$(cat "$SUDO_LOG")"
pass "explicit remove runs nonconfirm without gum when interactive"

unset OMARCHY_UPDATE_ORPHANS
unset OMARCHY_UPDATE_UNATTENDED
unset OMARCHY_PATH
