#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
test_tmp=$(mktemp -d)
cross_state=""
trap 'rm -rf "$test_tmp"; [[ -z $cross_state ]] || rm -rf "$cross_state"' EXIT
export test_tmp
unset XDG_STATE_HOME

git() {
  local destination="${*: -1}"
  mkdir -p "$destination"
  printf '%s\n' new > "$destination/colors.toml"
  if [[ ${CLONE_SIGNAL:-0} == "1" ]]; then
    kill -TERM "$BASHPID"
  fi
  return "${CLONE_RESULT:-0}"
}
omarchy-git-url-check() { return 0; }
omarchy-theme-set() {
  printf '%s\n' "$1" >> "$test_tmp/applied"
  return "${APPLY_RESULT:-0}"
}
mv() {
  if [[ ${PUBLISH_RESULT:-0} == "1" && $3 == */.blue.install.*/blue ]]; then
    return 1
  fi
  command mv "$@"
  if [[ ${PUBLISH_HANGUP:-0} == "1" && $3 == "$THEME_PATH" && $4 == */previous ]]; then
    kill -HUP "$BASHPID"
  fi
}
cp() {
  if [[ ${BACKUP_FAILURE:-0} == "1" ]]; then
    mkdir -p "${*: -1}"
    printf partial >"${*: -1}/colors.toml"
    return 1
  fi
  command cp "$@"
}
export -f git omarchy-git-url-check omarchy-theme-set mv cp

run_install() {
  HOME="$test_tmp/$scenario" bash "$ROOT/bin/omarchy-theme-install" https://example.com/omarchy-blue-theme.git
}
for scenario in failed_clone interrupted hangup backup_failure replacement failed_publish failed_apply symlink fresh locked; do
  themes="$test_tmp/$scenario/.config/omarchy/themes"
  mkdir -p "$themes"
  if [[ $scenario == "symlink" ]]; then
    mkdir -p "$test_tmp/linked"
    printf '%s\n' old > "$test_tmp/linked/colors.toml"
    ln -s "$test_tmp/linked" "$themes/blue"
  elif [[ $scenario != "fresh" ]]; then
    mkdir -p "$themes/blue"
    printf '%s\n' old > "$themes/blue/colors.toml"
  fi

  case "$scenario" in
  failed_clone)
    if CLONE_RESULT=1 run_install; then fail "clone failure must fail installation"; fi
    [[ $(<"$themes/blue/colors.toml") == "old" ]] || fail "clone failure preserves existing theme"
    ;;
  interrupted)
    if CLONE_SIGNAL=1 run_install; then fail "interruption must fail installation"; fi
    [[ $(<"$themes/blue/colors.toml") == "old" ]] || fail "interruption preserves existing theme"
    ;;
  hangup)
    if PUBLISH_HANGUP=1 run_install; then fail "hangup must fail installation"; fi
    [[ $(<"$themes/blue/colors.toml") == "old" ]] || fail "hangup restores the previous theme"
    ;;
  backup_failure)
    if BACKUP_FAILURE=1 run_install; then fail "a failed backup copy must stop installation"; fi
    [[ $(<"$themes/blue/colors.toml") == "old" ]] || fail "partial backup copies leave the installed theme intact"
    [[ -z $(find "$test_tmp/$scenario/.local/state/omarchy/theme-backups" -mindepth 1 -print) ]] || fail "failed copies leave no partial backup behind"
    ;;
  failed_publish)
    if PUBLISH_RESULT=1 run_install; then fail "publish failure must fail installation"; fi
    [[ $(<"$themes/blue/colors.toml") == "old" ]] || fail "publish failure restores existing theme"
    ;;
  locked)
    exec 8>"$themes/.blue.install.lock"
    flock 8
    if run_install; then fail "overlapping installation must fail"; fi
    exec 8>&-
    [[ $(<"$themes/blue/colors.toml") == "old" ]] || fail "overlapping installation leaves theme intact"
    ;;
  *)
    if [[ $scenario == "failed_apply" ]]; then
      if APPLY_RESULT=1 run_install; then fail "application failure must remain visible"; fi
    else
      run_install
    fi
    listed=$(HOME="$test_tmp/$scenario" OMARCHY_PATH="$ROOT" bash "$ROOT/bin/omarchy-theme-list")
    [[ $listed != *Backup* ]] || fail "saved themes do not appear in the theme list"
    [[ -z $(find "$themes" -maxdepth 1 -name '.*backup*' -print) ]] || fail "backups stay outside selectable themes"
    [[ $(<"$themes/blue/colors.toml") == "new" ]] || fail "completed clone is published"
    if [[ $scenario != "fresh" ]]; then
      backups=("$test_tmp/$scenario/.local/state/omarchy/theme-backups"/blue.*/theme)
      [[ ${#backups[@]} == 1 && $(<"${backups[0]}/colors.toml") == "old" ]] || fail "previous theme remains recoverable"
      if [[ $scenario == "symlink" ]]; then
        [[ -L ${backups[0]} ]] || fail "backup preserves the original symlink"
        [[ $(<"$test_tmp/linked/colors.toml") == "old" ]] || fail "symlink target is untouched"
      fi
    fi
    ;;
  esac
  [[ -z $(find "$themes" -maxdepth 1 -type d -name '.blue.install.*' -print) ]] || fail "staging directory is cleaned up"
  pass "$scenario theme installation preserves recoverable user data"
done

if cross_state=$(mktemp -d /dev/shm/omarchy-theme-state.XXXXXX 2>/dev/null) &&
  [[ $(stat -c %d "$test_tmp") != $(stat -c %d "$cross_state") ]]; then
  scenario=cross_filesystem
  themes="$test_tmp/$scenario/.config/omarchy/themes"
  mkdir -p "$themes/blue"
  printf old >"$themes/blue/colors.toml"
  [[ $(stat -c %d "$themes") != $(stat -c %d "$cross_state") ]] || fail "the cross-filesystem fixture must use separate filesystems"
  HOME="$test_tmp/$scenario" XDG_STATE_HOME="$cross_state" bash "$ROOT/bin/omarchy-theme-install" https://example.com/omarchy-blue-theme.git
  backups=("$cross_state"/omarchy/theme-backups/blue.*/theme)
  [[ $(<"${backups[0]}/colors.toml") == "old" && $(<"$themes/blue/colors.toml") == "new" ]] || fail "the configured state directory keeps the complete previous theme across filesystems"
  pass "theme backups honor XDG_STATE_HOME across a real filesystem boundary"
else
  echo "skip - no accessible shared-memory filesystem separate from the test directory"
fi

# Verify that staging and publication also work with an actual Git checkout.
remote="$test_tmp/omarchy-blue-theme"
command git init -q "$remote"
printf '%s\n' 'new' > "$remote/colors.toml"
command git -C "$remote" add .
command git -C "$remote" -c user.name=Test -c user.email=test@example.com commit -qm initial
scenario=real_git
HOME="$test_tmp/$scenario" bash -c 'unset -f git; exec bash "$1/bin/omarchy-theme-install" "$2"' bash "$ROOT" "$remote"
installed="$test_tmp/$scenario/.config/omarchy/themes/blue"
[[ $(command git -C "$installed" rev-parse HEAD) == $(command git -C "$remote" rev-parse HEAD) ]] || fail "real Git revision survives publication"
[[ $(command git -C "$installed" remote get-url origin) == "$remote" ]] || fail "published checkout retains its remote"
pass "real Git checkout retains its history and origin after publication"

scenario=update_lock
themes="$test_tmp/$scenario/.config/omarchy/themes"
mkdir -p "$themes/blue"
omarchy-theme-extras() { printf '%s\n' "$UPDATE_THEME"; }
export -f omarchy-theme-extras
git() { printf '%s\n' "$*" >>"$test_tmp/pulls"; }
export -f git
exec 8>"$themes/.blue.install.lock"
flock 8
if UPDATE_THEME="$themes/blue" bash "$ROOT/bin/omarchy-theme-update" >/dev/null 2>&1; then
  fail "theme updates must respect the install lock"
fi
[[ ! -e $test_tmp/pulls ]] || fail "a concurrent updater cannot change the theme during its backup"
exec 8>&-
UPDATE_THEME="$themes/blue" bash "$ROOT/bin/omarchy-theme-update" >/dev/null
grep -Fq 'pull' "$test_tmp/pulls" || fail "theme updates resume after the install lock is released"
pass "theme installs and updates share one lock around working-tree changes"
