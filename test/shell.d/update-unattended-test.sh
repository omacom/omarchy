#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command script
require_command timeout

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
test_home="$test_tmp/home"
runtime_dir="$test_tmp/runtime"
state_dir="$test_tmp/state"
migration_state="$test_tmp/migration-state"
mkdir -p "$stub_bin" "$test_home/.local/state/omarchy" "$test_home/.config/omarchy/hooks/post-update.d" "$test_home/.local/bin" "$runtime_dir" "$state_dir" "$migration_state"

STEP_LOG="$test_tmp/steps.log"
GUM_LOG="$test_tmp/gum.log"
SUDO_LOG="$test_tmp/sudo.log"
PACMAN_LOG="$test_tmp/pacman.log"
PACMAN_KEY_LOG="$test_tmp/pacman-key.log"
SNAPPER_LOG="$test_tmp/snapper.log"
PACCACHE_LOG="$test_tmp/paccache.log"
YAY_LOG="$test_tmp/yay.log"
MISE_LOG="$test_tmp/mise.log"
GIT_LOG="$test_tmp/git.log"
GIT_ENV_LOG="$test_tmp/git-env.log"
SYSTEMCTL_LOG="$test_tmp/systemctl.log"
INHIBIT_LOG="$test_tmp/inhibit.log"
REBOOT_LOG="$test_tmp/reboot.log"
SHELL_LOG="$test_tmp/shell.log"
RESTART_LOG="$test_tmp/restart.log"
SHELL_RESTART_LOG="$test_tmp/shell-restart.log"
STATE_LOG="$test_tmp/state.log"
CHECKUPDATES_LOG="$test_tmp/checkupdates.log"
AUR_ACCESS_LOG="$test_tmp/aur-access.log"
HOOK_LOG="$test_tmp/hook.log"

export STEP_LOG GUM_LOG SUDO_LOG PACMAN_LOG PACMAN_KEY_LOG SNAPPER_LOG PACCACHE_LOG YAY_LOG MISE_LOG GIT_LOG GIT_ENV_LOG SYSTEMCTL_LOG INHIBIT_LOG REBOOT_LOG SHELL_LOG RESTART_LOG SHELL_RESTART_LOG STATE_LOG CHECKUPDATES_LOG AUR_ACCESS_LOG HOOK_LOG
export SHELL=/bin/bash

: >"$STEP_LOG"; : >"$GUM_LOG"; : >"$SUDO_LOG"; : >"$PACMAN_LOG"; : >"$PACMAN_KEY_LOG"
: >"$SNAPPER_LOG"; : >"$PACCACHE_LOG"; : >"$YAY_LOG"; : >"$MISE_LOG"; : >"$GIT_LOG"
: >"$GIT_ENV_LOG"; : >"$SYSTEMCTL_LOG"; : >"$INHIBIT_LOG"; : >"$REBOOT_LOG"; : >"$SHELL_LOG"
: >"$RESTART_LOG"; : >"$SHELL_RESTART_LOG"; : >"$STATE_LOG"; : >"$CHECKUPDATES_LOG"
: >"$AUR_ACCESS_LOG"; : >"$HOOK_LOG"

write_stub() {
  local name="$1"
  local body="$2"
  cat >"$stub_bin/$name" <<SH
#!/bin/bash
$body
SH
  chmod +x "$stub_bin/$name"
}

write_wrapper() {
  local name="$1"
  cat >"$stub_bin/$name" <<SH
#!/bin/bash
printf '%s %s\n' "$name" "\$*" >>"\$STEP_LOG"
exec "\$OMARCHY_PATH/bin/$name" "\$@"
SH
  chmod +x "$stub_bin/$name"
}

for step in omarchy-update-requires-free-space omarchy-update-confirm omarchy-update-pkg-prune omarchy-snapshot omarchy-update-stay-awake omarchy-update-dev omarchy-update-keyring omarchy-update-system-pkgs omarchy-migrate omarchy-hook omarchy-update-aur-pkgs omarchy-update-mise omarchy-update-orphan-pkgs omarchy-update-analyze-logs omarchy-update-status omarchy-update-restart; do
  write_wrapper "$step"
done

cat >"$stub_bin/omarchy-state" <<'SH'
#!/bin/bash
printf '%s %s\n' "omarchy-state" "$*" >>"$STATE_LOG"
exec "$OMARCHY_PATH/bin/omarchy-state" "$@"
SH
chmod +x "$stub_bin/omarchy-state"

cat >"$stub_bin/omarchy-toggle-idle" <<'SH'
#!/bin/bash
printf '%s %s\n' "omarchy-toggle-idle" "$*" >>"$STATE_LOG"
exec "$OMARCHY_PATH/bin/omarchy-toggle-idle" "$@"
SH
chmod +x "$stub_bin/omarchy-toggle-idle"

write_stub sudo '
printf "%q " "$@" >>"${SUDO_LOG:-/dev/null}"
printf "\n" >>"${SUDO_LOG:-/dev/null}"
stripped=()
for a in "$@"; do
  if [[ $a == "-n" || $a == "--" ]]; then continue; fi
  stripped+=("$a")
done
if (( ${#stripped[@]} == 1 )) && [[ ${stripped[0]} == "true" ]]; then
  exit "${TEST_SUDO_N_TRUE_EXIT:-0}"
fi
if (( ${#stripped[@]} == 0 )); then exit 0; fi
if [[ ${stripped[0]} == "-v" ]]; then exit 0; fi
exec "${stripped[@]}"'

write_stub pacman '
printf "%q " "$@" >>"${PACMAN_LOG:-/dev/null}"
printf "\n" >>"${PACMAN_LOG:-/dev/null}"
if [[ ${1:-} == "-Qtdq" ]]; then
  if [[ ${TEST_ORPHANS_EMPTY:-0} == "1" ]]; then exit 0; fi
  printf "old-lib\nunused-tool\n"
  exit 0
fi
if [[ ${1:-} == "-Qo" ]]; then
  exit "${TEST_PACMAN_QO_EXIT:-0}"
fi
if [[ ${1:-} == "-Qq" ]]; then
  exit 1
fi
if [[ ${1:-} == "-Qem" ]]; then
  exit "${TEST_PACMAN_QEM_EXIT:-0}"
fi
if [[ ${1:-} == "-Q" ]]; then
  exit 0
fi
if [[ $* == *"-Syu"* ]]; then
  if [[ ${TEST_SYSTEM_PKGS_FAIL:-0} == "1" ]]; then
    echo "error: unresolvable package conflicts detected" >&2
    exit 1
  fi
  exit 0
fi
if [[ ${1:-} == "-Sy" ]]; then
  exit 0
fi
if [[ ${1:-} == "-S" ]]; then
  exit 0
fi
if [[ $* == *"-Rns"* ]]; then
  exit "${TEST_ORPHAN_REMOVE_EXIT:-0}"
fi
exit 0'

write_stub pacman-key '
printf "%s\n" "$*" >>"${PACMAN_KEY_LOG:-/dev/null}"
exit 0'

write_stub pkexec '
printf "%s\n" "$*" >>"${SUDO_LOG:-/dev/null}"
echo "pkexec should not be called unattended" >&2
exit 1'

write_stub gum '
printf "%q " "$@" >>"${GUM_LOG:-/dev/null}"
printf "\n" >>"${GUM_LOG:-/dev/null}"
if [[ ${1:-} == "style" ]]; then exit 0; fi
if [[ ${1:-} == "confirm" ]]; then
  shift
  if [[ $* == *"Continue with update?"* ]]; then exit "${TEST_UPDATE_CONFIRM_EXIT:-0}"; fi
  if [[ $* == *"orphan"* ]]; then exit "${TEST_ORPHAN_CONFIRM_EXIT:-1}"; fi
  if [[ $* == *"Reboot"* || $* == *"reboot"* ]]; then exit "${TEST_REBOOT_CONFIRM_EXIT:-1}"; fi
  exit 1
fi
exit 99'

write_stub snapper '
printf "%q " "$@" >>"${SNAPPER_LOG:-/dev/null}"
printf "\n" >>"${SNAPPER_LOG:-/dev/null}"
if [[ ${TEST_SNAP_SLEEP:-0} == "1" ]]; then sleep 2; fi
if [[ $* == *"list-configs"* ]]; then
  printf "config,subvolume\n"
  exit 0
fi
exit 0'

write_stub paccache '
printf "%q " "$@" >>"${PACCACHE_LOG:-/dev/null}"
printf "\n" >>"${PACCACHE_LOG:-/dev/null}"
exit 0'

write_stub yay '
printf "%q " "$@" >>"${YAY_LOG:-/dev/null}"
printf "\n" >>"${YAY_LOG:-/dev/null}"
exit 0'

write_stub mise '
printf "%q " "$@" >>"${MISE_LOG:-/dev/null}"
printf "\n" >>"${MISE_LOG:-/dev/null}"
exit 0'

write_stub git '
printf "env:TERMINAL_PROMPT=%s ASKPASS=%s SSH=%s args:%s\n" "${GIT_TERMINAL_PROMPT-<unset>}" "${GIT_ASKPASS-<unset>}" "${GIT_SSH_COMMAND-<unset>}" "$*" >>"${GIT_LOG:-/dev/null}"
printf "TERMINAL_PROMPT=%s\n" "${GIT_TERMINAL_PROMPT-<unset>}" >>"${GIT_ENV_LOG:-/dev/null}"
if [[ $* == *"rev-parse --is-inside-work-tree"* ]]; then exit 0; fi
if [[ $* == *"rev-parse --abbrev-ref"* ]]; then printf "origin/quattro\n"; exit 0; fi
if [[ $* == *"pull --ff-only"* ]]; then exit "${TEST_GIT_PULL_EXIT:-0}"; fi
if [[ $* == *"fetch --quiet"* ]]; then exit 0; fi
if [[ $* == *"rev-list --count"* ]]; then printf "0\n"; exit 0; fi
if [[ $* == *"rev-parse --short HEAD"* ]]; then printf "abc123\n"; exit 0; fi
exit 0'

write_stub systemctl '
printf "%q " "$@" >>"${SYSTEMCTL_LOG:-/dev/null}"
printf "\n" >>"${SYSTEMCTL_LOG:-/dev/null}"
exit "${TEST_SYSTEMCTL_EXIT:-0}"'

write_stub systemd-inhibit '
printf "%q " "$@" >>"${INHIBIT_LOG:-/dev/null}"
printf "\n" >>"${INHIBIT_LOG:-/dev/null}"
exec sleep 30'

write_stub omarchy-system-reboot '
printf "reboot %s\n" "$*" >>"${REBOOT_LOG:-/dev/null}"
exit 0'

write_stub omarchy-shell '
printf "%q " "$@" >>"${SHELL_LOG:-/dev/null}"
printf "\n" >>"${SHELL_LOG:-/dev/null}"
exit 0'

write_stub omarchy-restart-audio '
printf "audio %s\n" "$*" >>"${RESTART_LOG:-/dev/null}"
exit 0'

write_stub omarchy-restart-trackpad '
printf "trackpad %s\n" "$*" >>"${RESTART_LOG:-/dev/null}"
exit 0'

write_stub omarchy-restart-shell '
printf "shell %s\n" "$*" >>"${SHELL_RESTART_LOG:-/dev/null}"
exit 0'

write_stub checkupdates '
printf "%s\n" "$*" >>"${CHECKUPDATES_LOG:-/dev/null}"
exit 0'

write_stub omarchy-pkg-aur-accessible '
printf "probe\n" >>"${AUR_ACCESS_LOG:-/dev/null}"
exit "${TEST_AUR_ACCESSIBLE:-0}"'

write_stub uname '
if [[ ${1:-} == "-r" ]]; then
  if [[ -n ${TEST_RUNNING_KERNEL:-} ]]; then printf "%s\n" "$TEST_RUNNING_KERNEL"; else exec /usr/bin/uname -r; fi
  exit 0
fi
exec /usr/bin/uname "$@"'

write_stub pgrep '
if [[ ${1:-} == "-x" && ${2:-} == "Hyprland" ]]; then
  if [[ ${TEST_PGREP_MODE:-none} == "present" ]]; then printf "1234\n"; exit 0; else exit 1; fi
fi
exit 1'

write_stub readlink '
if [[ ${1:-} == /proc/*/exe ]]; then
  if [[ ${TEST_HYPRLAND_DELETED:-0} == "1" ]]; then printf "/usr/bin/Hyprland (deleted)\n"; exit 0; else exit 1; fi
fi
exec /usr/bin/readlink "$@"'

cat >"$test_home/.config/omarchy/hooks/post-update.d/test-hook" <<'SH'
#!/bin/bash
printf 'hook-ran\n' >>"$HOOK_LOG"
exit 0
SH
chmod +x "$test_home/.config/omarchy/hooks/post-update.d/test-hook"

premark_migrations() {
  local tree="$1"
  local statedir="$2"
  mkdir -p "$statedir"
  local f
  for f in "$tree"/migrations/*.sh; do
    [[ -f $f ]] || continue
    touch "$statedir/$(basename "$f")"
  done
}
premark_migrations "$ROOT" "$migration_state"

reset_logs() {
  : >"$STEP_LOG"; : >"$GUM_LOG"; : >"$SUDO_LOG"; : >"$PACMAN_LOG"; : >"$PACMAN_KEY_LOG"
  : >"$SNAPPER_LOG"; : >"$PACCACHE_LOG"; : >"$YAY_LOG"; : >"$MISE_LOG"; : >"$GIT_LOG"
  : >"$GIT_ENV_LOG"; : >"$SYSTEMCTL_LOG"; : >"$INHIBIT_LOG"; : >"$REBOOT_LOG"; : >"$SHELL_LOG"
  : >"$RESTART_LOG"; : >"$SHELL_RESTART_LOG"; : >"$STATE_LOG"; : >"$CHECKUPDATES_LOG"
  : >"$AUR_ACCESS_LOG"; : >"$HOOK_LOG"
}

reset_state() {
  rm -f "$test_home/.local/state/omarchy/reboot-required"
  rm -f "$test_home"/.local/state/omarchy/restart-*-required
  rm -rf "$runtime_dir/omarchy-update-stay-awake"
  rm -f "$runtime_dir/omarchy-update.lock"
  rm -f /tmp/omarchy-update.log
  reset_logs
}

clean_out() {
  tr -d '\r' <"$1"
}

base_env() {
  env HOME="$test_home" \
    XDG_RUNTIME_DIR="$runtime_dir" \
    XDG_STATE_HOME="$state_dir" \
    XDG_CACHE_HOME="$test_home/.cache" \
    XDG_CONFIG_HOME="$test_home/.config" \
    XDG_DATA_HOME="$test_home/.local/share" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_MIGRATION_STATE="$migration_state" \
    STEP_LOG="$STEP_LOG" GUM_LOG="$GUM_LOG" SUDO_LOG="$SUDO_LOG" PACMAN_LOG="$PACMAN_LOG" \
    PACMAN_KEY_LOG="$PACMAN_KEY_LOG" SNAPPER_LOG="$SNAPPER_LOG" PACCACHE_LOG="$PACCACHE_LOG" \
    YAY_LOG="$YAY_LOG" MISE_LOG="$MISE_LOG" GIT_LOG="$GIT_LOG" GIT_ENV_LOG="$GIT_ENV_LOG" \
    SYSTEMCTL_LOG="$SYSTEMCTL_LOG" INHIBIT_LOG="$INHIBIT_LOG" REBOOT_LOG="$REBOOT_LOG" \
    SHELL_LOG="$SHELL_LOG" RESTART_LOG="$RESTART_LOG" SHELL_RESTART_LOG="$SHELL_RESTART_LOG" \
    STATE_LOG="$STATE_LOG" CHECKUPDATES_LOG="$CHECKUPDATES_LOG" AUR_ACCESS_LOG="$AUR_ACCESS_LOG" \
    HOOK_LOG="$HOOK_LOG" SHELL=/bin/bash \
    PATH="$stub_bin:$ROOT/bin:/usr/local/sbin:/usr/local/bin:/usr/bin" \
    "$@"
}

run_pty() {
  local out="$1"
  local err="$2"
  shift 2
  local cmd_str
  cmd_str=$(printf '%q ' "$@")
  base_env timeout 90 script -qefc "$cmd_str" /dev/null >"$out" 2>"$err"
}

run_headless() {
  local out="$1"
  local err="$2"
  shift 2
  base_env "$@" </dev/null >"$out" 2>"$err"
}

check_transcript() {
  local desc="$1"
  [[ -f /tmp/omarchy-update.log ]] || fail "$desc transcript exists" "missing /tmp/omarchy-update.log"
  [[ -s /tmp/omarchy-update.log ]] || fail "$desc transcript non-empty" "empty log"
  pass "$desc transcript exists non-empty"
}

check_unattended_summary() {
  local desc="$1"
  local kind="$2"
  clean_out /tmp/omarchy-update.log | grep -q "Unattended update ($kind)" ||
    fail "$desc transcript has unattended $kind summary" "$(clean_out /tmp/omarchy-update.log | head -n 30)"
  pass "$desc transcript has unattended $kind summary"
}

steps_names() {
  cut -d' ' -f1 "$STEP_LOG"
}

# --- 1. interactive TTY accept: confirm accept, orphan decline, reboot decline ---
reset_state
export TEST_UPDATE_CONFIRM_EXIT=0 TEST_ORPHAN_CONFIRM_EXIT=1 TEST_REBOOT_CONFIRM_EXIT=1
export TEST_RUNNING_KERNEL="" TEST_PGREP_MODE="none" TEST_HYPRLAND_DELETED="0"
export TEST_SUDO_N_TRUE_EXIT=0 TEST_SYSTEM_PKGS_FAIL=0 TEST_SYSTEMCTL_EXIT=0 TEST_ORPHANS_EMPTY=0
touch "$test_home/.local/state/omarchy/reboot-required"
set +e
run_pty "$test_tmp/i-acc.out" "$test_tmp/i-acc.err" omarchy-update
i_acc_status=$?
set -e
(( i_acc_status == 0 )) || fail "interactive accept exits 0" "got $i_acc_status out=$(clean_out "$test_tmp/i-acc.out") err=$(cat "$test_tmp/i-acc.err") steps=$(cat "$STEP_LOG")"
grep -q '^omarchy-update-confirm ' "$STEP_LOG" || fail "interactive accept runs confirm" "$(cat "$STEP_LOG")"
grep -q '^omarchy-update-pkg-prune ' "$STEP_LOG" || fail "interactive accept runs prune" "$(cat "$STEP_LOG")"
grep -q '^omarchy-update-system-pkgs ' "$STEP_LOG" || fail "interactive accept runs system-pkgs" "$(cat "$STEP_LOG")"
grep -q '^omarchy-migrate ' "$STEP_LOG" || fail "interactive accept runs migrate" "$(cat "$STEP_LOG")"
grep -q '^omarchy-update-orphan-pkgs ' "$STEP_LOG" || fail "interactive accept runs orphan" "$(cat "$STEP_LOG")"
grep -q '^omarchy-update-restart ' "$STEP_LOG" || fail "interactive accept runs restart" "$(cat "$STEP_LOG")"
(( $(grep -c '^confirm' "$GUM_LOG") == 3 )) || fail "interactive accept calls gum 3 times (confirm+orphan+reboot)" "$(cat "$GUM_LOG")"
[[ ! -s $REBOOT_LOG ]] || fail "interactive decline reboot does not reboot" "$(cat "$REBOOT_LOG")"
check_transcript "interactive accept"
pass "interactive TTY accept runs full pipeline with orphan+reboot prompts"

# --- 2. interactive TTY decline confirm ---
reset_state
export TEST_UPDATE_CONFIRM_EXIT=1
set +e
run_pty "$test_tmp/i-dec.out" "$test_tmp/i-dec.err" omarchy-update
i_dec_status=$?
set -e
(( i_dec_status == 0 )) || fail "interactive decline exits 0" "got $i_dec_status"
grep -q '^omarchy-update-confirm ' "$STEP_LOG" || fail "interactive decline runs confirm" "$(cat "$STEP_LOG")"
grep -q '^omarchy-update-pkg-prune ' "$STEP_LOG" && fail "interactive decline runs no prune" "$(cat "$STEP_LOG")"
grep -q '^omarchy-snapshot ' "$STEP_LOG" && fail "interactive decline runs no snapshot" "$(cat "$STEP_LOG")"
grep -q '^omarchy-update-system-pkgs ' "$STEP_LOG" && fail "interactive decline runs no system-pkgs" "$(cat "$STEP_LOG")"
check_transcript "interactive decline"
pass "interactive decline exits 0 before prune/snapshot/system-pkgs"

# --- 3. -y PTY full ---
reset_state
unset TEST_UPDATE_CONFIRM_EXIT TEST_ORPHAN_CONFIRM_EXIT TEST_REBOOT_CONFIRM_EXIT
export TEST_RUNNING_KERNEL="" TEST_PGREP_MODE="none" TEST_HYPRLAND_DELETED="0"
export TEST_SUDO_N_TRUE_EXIT=0 TEST_SYSTEM_PKGS_FAIL=0 TEST_SYSTEMCTL_EXIT=0 TEST_ORPHANS_EMPTY=0
set +e
run_pty "$test_tmp/y.out" "$test_tmp/y.err" omarchy-update -y
y_status=$?
set -e
(( y_status == 0 )) || fail "-y PTY exits 0" "got $y_status out=$(clean_out "$test_tmp/y.out" | tail -n 20) err=$(cat "$test_tmp/y.err") steps=$(cat "$STEP_LOG")"
[[ ! -s $GUM_LOG ]] || fail "-y PTY calls no gum" "$(cat "$GUM_LOG")"
for s in omarchy-update-requires-free-space omarchy-update-pkg-prune omarchy-snapshot omarchy-update-dev omarchy-update-keyring omarchy-update-system-pkgs omarchy-migrate omarchy-hook omarchy-update-aur-pkgs omarchy-update-mise omarchy-update-orphan-pkgs omarchy-update-analyze-logs omarchy-update-status omarchy-update-restart; do
  grep -q "^$s " "$STEP_LOG" || fail "-y PTY runs $s" "$(cat "$STEP_LOG")"
done
grep -q '^omarchy-update-confirm ' "$STEP_LOG" && fail "-y PTY skips confirm" "$(cat "$STEP_LOG")"
clean_out "$test_tmp/y.out" | grep -q 'Keeping orphaned packages' || fail "-y PTY reports orphans kept" "$(clean_out "$test_tmp/y.out")"
clean_out "$test_tmp/y.out" | grep -q 'Reboot required:' && fail "-y PTY reports no reboot without triggers" "$(clean_out "$test_tmp/y.out")"
[[ -s $YAY_LOG ]] || fail "-y PTY runs aur (yay called)" "yay empty steps=$(cat "$STEP_LOG")"
[[ -s $MISE_LOG ]] || fail "-y PTY runs mise" "$(cat "$STEP_LOG")"
[[ -s $HOOK_LOG ]] || fail "-y PTY runs hooks" "$(cat "$STEP_LOG")"
grep -q -- '-n -v' "$SUDO_LOG" || fail "-y PTY stay-awake probes sudo -n" "$(cat "$SUDO_LOG")"
grep -q -- '-n systemd-inhibit' "$SUDO_LOG" || fail "-y PTY stay-awake runs sudo -n inhibit" "$(cat "$SUDO_LOG")"
[[ ! -s $REBOOT_LOG ]] || fail "-y PTY never reboots" "$(cat "$REBOOT_LOG")"
(( $(grep -c '^shell' "$SHELL_RESTART_LOG") == 1 )) || fail "-y PTY restarts shell" "$(cat "$SHELL_RESTART_LOG")"
check_transcript "-y PTY"
check_unattended_summary "-y PTY" "full"
pass "-y PTY full pipeline unattended no-gum with transcript"

# --- 4. --yes alias identical ---
reset_state
set +e
run_pty "$test_tmp/yes.out" "$test_tmp/yes.err" omarchy-update --yes
yes_status=$?
set -e
(( yes_status == 0 )) || fail "--yes PTY exits 0" "got $yes_status"
[[ ! -s $GUM_LOG ]] || fail "--yes PTY calls no gum" "$(cat "$GUM_LOG")"
for s in omarchy-migrate omarchy-hook omarchy-update-aur-pkgs omarchy-update-mise omarchy-update-orphan-pkgs omarchy-update-restart; do
  grep -q "^$s " "$STEP_LOG" || fail "--yes PTY runs $s" "$(cat "$STEP_LOG")"
done
clean_out "$test_tmp/yes.out" | grep -q 'Keeping orphaned packages' || fail "--yes reports orphans kept" "$(clean_out "$test_tmp/yes.out")"
check_transcript "--yes PTY"
check_unattended_summary "--yes PTY" "full"
pass "--yes alias identical to -y"

# --- 5. --non-interactive PTY strict skip ---
reset_state
set +e
run_pty "$test_tmp/strict.out" "$test_tmp/strict.err" omarchy-update --non-interactive
strict_status=$?
set -e
(( strict_status == 0 )) || fail "strict PTY exits 0" "got $strict_status err=$(cat "$test_tmp/strict.err")"
[[ ! -s $GUM_LOG ]] || fail "strict PTY calls no gum" "$(cat "$GUM_LOG")"
grep -q '^omarchy-migrate ' "$STEP_LOG" || fail "strict still runs migrations" "$(cat "$STEP_LOG")"
grep -q '^omarchy-hook ' "$STEP_LOG" && fail "strict skips hooks" "$(cat "$STEP_LOG")"
grep -q '^omarchy-update-aur-pkgs ' "$STEP_LOG" && fail "strict skips aur" "$(cat "$STEP_LOG")"
grep -q '^omarchy-update-mise ' "$STEP_LOG" && fail "strict skips mise" "$(cat "$STEP_LOG")"
clean_out "$test_tmp/strict.out" | grep -q 'Skipping post-update hooks (--hooks=skip)' || fail "strict reports hook skip" "$(clean_out "$test_tmp/strict.out")"
clean_out "$test_tmp/strict.out" | grep -q 'Skipping AUR package updates (--aur=skip)' || fail "strict reports aur skip" "$(clean_out "$test_tmp/strict.out")"
clean_out "$test_tmp/strict.out" | grep -q 'Skipping mise updates (--mise=skip)' || fail "strict reports mise skip" "$(clean_out "$test_tmp/strict.out")"
[[ ! -s $YAY_LOG ]] || fail "strict does not call yay" "$(cat "$YAY_LOG")"
[[ ! -s $MISE_LOG ]] || fail "strict does not call mise" "$(cat "$MISE_LOG")"
[[ ! -s $HOOK_LOG ]] || fail "strict does not run hooks" "$(cat "$HOOK_LOG")"
clean_out "$test_tmp/strict.out" | grep -q 'Keeping orphaned packages' || fail "strict reports orphans kept" "$(clean_out "$test_tmp/strict.out")"
check_transcript "strict PTY"
check_unattended_summary "strict PTY" "strict"
pass "--non-interactive skips hooks/aur/mise with messages, migrations run"

# --- 6. strict opt-in warnings ---
reset_state
set +e
run_pty "$test_tmp/optin.out" "$test_tmp/optin.err" omarchy-update --non-interactive --hooks=run --aur=run --mise=run
optin_status=$?
set -e
(( optin_status == 0 )) || fail "strict opt-in exits 0" "got $optin_status"
grep -q '^omarchy-hook ' "$STEP_LOG" || fail "strict opt-in runs hooks" "$(cat "$STEP_LOG")"
grep -q '^omarchy-update-aur-pkgs ' "$STEP_LOG" || fail "strict opt-in runs aur" "$(cat "$STEP_LOG")"
grep -q '^omarchy-update-mise ' "$STEP_LOG" || fail "strict opt-in runs mise" "$(cat "$STEP_LOG")"
clean_out "$test_tmp/optin.out" | grep -q 'Warning: --hooks=run in strict mode' || fail "strict hooks opt-in warns" "$(clean_out "$test_tmp/optin.out")"
clean_out "$test_tmp/optin.out" | grep -q 'Warning: --aur=run in strict mode' || fail "strict aur opt-in warns" "$(clean_out "$test_tmp/optin.out")"
clean_out "$test_tmp/optin.out" | grep -q 'Warning: --mise=run in strict mode' || fail "strict mise opt-in warns" "$(clean_out "$test_tmp/optin.out")"
check_transcript "strict opt-in"
pass "strict opt-in runs externals with warnings"

# --- 7. --orphans=remove PTY ---
reset_state
set +e
run_pty "$test_tmp/orm.out" "$test_tmp/orm.err" omarchy-update -y --orphans=remove
orm_status=$?
set -e
(( orm_status == 0 )) || fail "orphans=remove exits 0" "got $orm_status"
[[ ! -s $GUM_LOG ]] || fail "orphans=remove calls no gum" "$(cat "$GUM_LOG")"
grep -q -- '-n' "$SUDO_LOG" || fail "orphans=remove uses sudo -n" "$(cat "$SUDO_LOG")"
grep -q -- '--noconfirm' "$PACMAN_LOG" || fail "orphans=remove uses --noconfirm" "$(cat "$PACMAN_LOG")"
grep -q 'old-lib.*unused-tool' "$PACMAN_LOG" || fail "orphans=remove passes package list" "$(cat "$PACMAN_LOG")"
clean_out "$test_tmp/orm.out" | grep -q 'Removing orphan system packages' || fail "orphans=remove reports removing" "$(clean_out "$test_tmp/orm.out")"
check_transcript "orphans=remove"
pass "--orphans=remove uses sudo -n pacman -Rns --noconfirm with list, no gum"

# --- 8. --orphans=keep PTY ---
reset_state
set +e
run_pty "$test_tmp/keep.out" "$test_tmp/keep.err" omarchy-update -y --orphans=keep
keep_status=$?
set -e
(( keep_status == 0 )) || fail "orphans=keep exits 0" "got $keep_status"
[[ ! -s $GUM_LOG ]] || fail "orphans=keep calls no gum" "$(cat "$GUM_LOG")"
grep -q -- '-Rns' "$PACMAN_LOG" && fail "orphans=keep runs no removal" "$(cat "$PACMAN_LOG")"
clean_out "$test_tmp/keep.out" | grep -q 'Keeping orphaned packages' || fail "orphans=keep reports keeping" "$(clean_out "$test_tmp/keep.out")"
check_transcript "orphans=keep"
pass "--orphans=keep reports only, no removal"

# --- 9. --reboot=if-needed success with kernel mismatch ---
reset_state
export TEST_RUNNING_KERNEL="0.0.0-fake-no-match" TEST_PGREP_MODE="none" TEST_HYPRLAND_DELETED="0" TEST_SYSTEMCTL_EXIT=0
set +e
run_pty "$test_tmp/rb.out" "$test_tmp/rb.err" omarchy-update -y --reboot=if-needed
rb_status=$?
set -e
(( rb_status == 0 )) || fail "reboot if-needed exits 0" "got $rb_status out=$(clean_out "$test_tmp/rb.out") err=$(cat "$test_tmp/rb.err")"
[[ ! -s $GUM_LOG ]] || fail "reboot if-needed calls no gum" "$(cat "$GUM_LOG")"
grep -q -- '--no-ask-password' "$SUDO_LOG" || fail "reboot uses --no-ask-password" "$(cat "$SUDO_LOG")"
grep -q -- 'reboot' "$SUDO_LOG" || fail "reboot calls reboot" "$(cat "$SUDO_LOG")"
grep -q -- '--no-wall' "$SUDO_LOG" || fail "reboot uses --no-wall" "$(cat "$SUDO_LOG")"
(( $(grep -c -- 'systemctl.*reboot' "$SUDO_LOG") == 1 )) || fail "reboot requested exactly once" "$(cat "$SUDO_LOG")"
(( $(wc -l <"$SYSTEMCTL_LOG") == 1 )) || fail "systemctl called exactly once" "$(cat "$SYSTEMCTL_LOG")"
clean_out "$test_tmp/rb.out" | grep -q 'Reboot requested\.' || fail "reboot prints success" "$(clean_out "$test_tmp/rb.out")"
check_transcript "reboot if-needed"
export TEST_RUNNING_KERNEL=""
pass "--reboot=if-needed single sudo systemctl reboot, exit 0"

# --- 10. --reboot=if-needed systemctl failure ---
reset_state
export TEST_RUNNING_KERNEL="0.0.0-fake-no-match" TEST_SYSTEMCTL_EXIT=5
touch "$test_home/.local/state/omarchy/reboot-required"
set +e
run_pty "$test_tmp/rbf.out" "$test_tmp/rbf.err" omarchy-update -y --reboot=if-needed
rbf_status=$?
set -e
(( rbf_status != 0 )) || fail "reboot failure exits nonzero" "got 0"
clean_out "$test_tmp/rbf.out" | grep -q 'Reboot requested\.' && fail "reboot failure prints no success" "$(clean_out "$test_tmp/rbf.out")"
[[ -f $test_home/.local/state/omarchy/reboot-required ]] || fail "reboot failure preserves marker" "marker gone"
check_transcript "reboot failure"
export TEST_RUNNING_KERNEL="" TEST_SYSTEMCTL_EXIT=0
pass "--reboot=if-needed failure exits nonzero, marker preserved"

# --- 11. --restarts=skip PTY ---
reset_state
mkdir -p "$test_home/.local/state/omarchy"
touch "$test_home/.local/state/omarchy/restart-audio-required"
touch "$test_home/.local/state/omarchy/restart-trackpad-required"
set +e
run_pty "$test_tmp/rskip.out" "$test_tmp/rskip.err" omarchy-update -y --restarts=skip
rskip_status=$?
set -e
(( rskip_status == 0 )) || fail "restarts=skip exits 0" "got $rskip_status"
[[ -f $test_home/.local/state/omarchy/restart-audio-required ]] || fail "restarts=skip keeps audio marker" "gone"
[[ -f $test_home/.local/state/omarchy/restart-trackpad-required ]] || fail "restarts=skip keeps trackpad marker" "gone"
[[ ! -s $RESTART_LOG ]] || fail "restarts=skip makes no service calls" "$(cat "$RESTART_LOG")"
[[ ! -s $SHELL_RESTART_LOG ]] || fail "restarts=skip makes no shell restart" "$(cat "$SHELL_RESTART_LOG")"
clean_out "$test_tmp/rskip.out" | grep -q 'Skipping service restarts' || fail "restarts=skip reports summary" "$(clean_out "$test_tmp/rskip.out")"
check_transcript "restarts=skip"
pass "--restarts=skip preserves markers, no restart calls"

# --- 12. headless -y ---
reset_state
export TEST_RUNNING_KERNEL="" TEST_PGREP_MODE="none" TEST_HYPRLAND_DELETED="0" TEST_SYSTEMCTL_EXIT=0
set +e
run_headless "$test_tmp/head.out" "$test_tmp/head.err" omarchy-update -y
head_status=$?
set -e
(( head_status == 0 )) || fail "headless -y exits 0" "got $head_status out=$(cat "$test_tmp/head.out") err=$(cat "$test_tmp/head.err") steps=$(cat "$STEP_LOG")"
[[ ! -s $GUM_LOG ]] || fail "headless -y calls no gum" "$(cat "$GUM_LOG")"
grep -q '^omarchy-migrate ' "$STEP_LOG" || fail "headless runs migrate" "$(cat "$STEP_LOG")"
grep -q '^omarchy-update-orphan-pkgs ' "$STEP_LOG" || fail "headless runs orphan" "$(cat "$STEP_LOG")"
check_transcript "headless -y"
check_unattended_summary "headless -y" "full"
pass "headless -y same as PTY minus TTY, transcript written"

# --- 13. conflicting packages stop before migrate ---
reset_state
export TEST_SYSTEM_PKGS_FAIL=1
set +e
run_pty "$test_tmp/conf.out" "$test_tmp/conf.err" omarchy-update -y
conf_status=$?
set -e
(( conf_status != 0 )) || fail "conflicting packages exit nonzero" "got 0"
grep -q '^omarchy-update-system-pkgs ' "$STEP_LOG" || fail "conflict runs system-pkgs" "$(cat "$STEP_LOG")"
grep -q '^omarchy-migrate ' "$STEP_LOG" && fail "conflict stops before migrate" "$(cat "$STEP_LOG")"
clean_out "$test_tmp/conf.out" | grep -q 'Something went wrong' || clean_out "$test_tmp/conf.err" | grep -q 'Something went wrong' || fail "conflict prints ERR trap message" "out=$(clean_out "$test_tmp/conf.out") err=$(clean_out "$test_tmp/conf.err")"
check_transcript "conflicting packages"
export TEST_SYSTEM_PKGS_FAIL=0
pass "conflicting packages stop before migrate with ERR message"

# --- 14. keyring no-auth fails before system-pkgs ---
reset_state
export TEST_SUDO_N_TRUE_EXIT=1
set +e
run_pty "$test_tmp/noauth.out" "$test_tmp/noauth.err" omarchy-update -y
noauth_status=$?
set -e
(( noauth_status != 0 )) || fail "keyring no-auth exits nonzero" "got 0"
grep -q '^omarchy-update-keyring ' "$STEP_LOG" || fail "no-auth runs keyring" "$(cat "$STEP_LOG")"
grep -q '^omarchy-update-system-pkgs ' "$STEP_LOG" && fail "no-auth stops before system-pkgs" "$(cat "$STEP_LOG")"
clean_out "$test_tmp/noauth.out" | grep -q 'sudo -n' || clean_out "$test_tmp/noauth.err" | grep -q 'sudo -n' || fail "no-auth actionable stderr" "out=$(clean_out "$test_tmp/noauth.out") err=$(clean_out "$test_tmp/noauth.err")"
check_transcript "keyring no-auth"
export TEST_SUDO_N_TRUE_EXIT=0
pass "keyring no-auth exits nonzero before system-pkgs with actionable stderr"

# --- 15. real lock second instance through transcript path ---
reset_state
export TEST_SNAP_SLEEP=1 TEST_SUDO_N_TRUE_EXIT=0 TEST_SYSTEM_PKGS_FAIL=0
rm -f "$test_tmp/first-started" "$test_tmp/second.out"
base_env omarchy-update -y </dev/null >"$test_tmp/first.out" 2>"$test_tmp/first.err" &
first_pid=$!
for _ in $(seq 1 100); do
  grep -q 'list-configs' "$SNAPPER_LOG" 2>/dev/null && break
  sleep 0.05
done
grep -q 'list-configs' "$SNAPPER_LOG" || fail "first update reached snapshot under lock" "$(cat "$SNAPPER_LOG")"
set +e
base_env omarchy-update -y </dev/null >"$test_tmp/second.out" 2>"$test_tmp/second.err"
second_status=$?
set -e
wait "$first_pid"
first_status=$?
export TEST_SNAP_SLEEP=0
(( second_status != 0 )) || fail "second update exits nonzero while lock held" "got 0"
grep -q 'already running' "$test_tmp/second.out" || grep -q 'already running' "$test_tmp/second.err" || clean_out /tmp/omarchy-update.log | grep -q 'already running' || fail "second update reports held lock" "out=$(cat "$test_tmp/second.out") err=$(cat "$test_tmp/second.err")"
(( first_status == 0 )) || fail "first update succeeds after lock released" "got $first_status"
pass "real lock second instance exits nonzero already running"

# --- 16. mutation proof: orphan + reboot guards catch regressions in disposable copies ---
reset_state
mut_orphan="$test_tmp/mut-orphan"
rm -rf "$mut_orphan"
cp -a "$ROOT" "$mut_orphan"
chmod -R u+w "$mut_orphan"
sed -i 's/if \[\[ ${OMARCHY_UPDATE_UNATTENDED:-} == "1" \]\]; then/if false; then/' "$mut_orphan/bin/omarchy-update-orphan-pkgs"
grep -q 'if false; then' "$mut_orphan/bin/omarchy-update-orphan-pkgs" || fail "orphan mutation applied" "sed missed"
: >"$GUM_LOG"
set +e
HOME="$test_home" PATH="$stub_bin:$mut_orphan/bin:/usr/local/sbin:/usr/local/bin:/usr/bin" OMARCHY_PATH="$mut_orphan" OMARCHY_UPDATE_ORPHANS="ask" OMARCHY_UPDATE_UNATTENDED="1" GUM_LOG="$GUM_LOG" SUDO_LOG="$SUDO_LOG" script -qec "$mut_orphan/bin/omarchy-update-orphan-pkgs" /dev/null >"$test_tmp/mut-orphan.out" 2>"$test_tmp/mut-orphan.err"
mut_orphan_status=$?
set -e
[[ -s $GUM_LOG ]] || fail "orphan guard mutation calls gum (test catches regression)" "gum empty, status=$mut_orphan_status"
pass "mutation proof orphan unattended no-gum fails on reverted guard"

: >"$GUM_LOG"
mut_reboot="$test_tmp/mut-reboot"
rm -rf "$mut_reboot"
cp -a "$ROOT" "$mut_reboot"
chmod -R u+w "$mut_reboot"
sed -i 's/if \[\[ ${OMARCHY_UPDATE_UNATTENDED:-} != "1" && -t 0 && -t 1 \]\]; then/if [[ -t 0 \&\& -t 1 ]]; then/' "$mut_reboot/bin/omarchy-update-restart"
grep -q 'if \[\[ -t 0 && -t 1 \]\]; then' "$mut_reboot/bin/omarchy-update-restart" || fail "reboot mutation applied" "sed missed"
: >"$GUM_LOG"
: >"$SUDO_LOG"
set +e
HOME="$test_home" PATH="$stub_bin:$mut_reboot/bin:/usr/local/sbin:/usr/local/bin:/usr/bin" OMARCHY_PATH="$mut_reboot" OMARCHY_UPDATE_REBOOT="ask" OMARCHY_UPDATE_UNATTENDED="1" OMARCHY_UPDATE_RESTARTS="run" TEST_RUNNING_KERNEL="0.0.0-fake-no-match" TEST_PGREP_MODE="none" TEST_HYPRLAND_DELETED="0" TEST_GUM_EXIT="0" GUM_LOG="$GUM_LOG" SUDO_LOG="$SUDO_LOG" REBOOT_LOG="$REBOOT_LOG" STATE_LOG="$STATE_LOG" RESTART_LOG="$RESTART_LOG" SYSTEMCTL_LOG="$SYSTEMCTL_LOG" SHELL_LOG="$SHELL_LOG" script -qec "$mut_reboot/bin/omarchy-update-restart" /dev/null >"$test_tmp/mut-reboot.out" 2>"$test_tmp/mut-reboot.err"
mut_reboot_status=$?
set -e
[[ -s $GUM_LOG ]] || fail "reboot guard mutation calls gum (test catches regression)" "gum empty status=$mut_reboot_status"
pass "mutation proof reboot unattended no-gum fails on reverted guard"

unset TEST_RUNNING_KERNEL TEST_PGREP_MODE TEST_HYPRLAND_DELETED TEST_SUDO_N_TRUE_EXIT TEST_SYSTEM_PKGS_FAIL TEST_SYSTEMCTL_EXIT TEST_ORPHANS_EMPTY TEST_SNAP_SLEEP TEST_UPDATE_CONFIRM_EXIT TEST_ORPHAN_CONFIRM_EXIT TEST_REBOOT_CONFIRM_EXIT
