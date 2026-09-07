#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export test_tmp

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
  if [[ ${PUBLISH_RESULT:-0} == "1" && $3 == */.blue.install.*/* ]]; then
    return 1
  fi
  command mv "$@"
}
export -f git omarchy-git-url-check omarchy-theme-set mv

run_install() {
  HOME="$test_tmp/$scenario" bash "$ROOT/bin/omarchy-theme-install" https://example.com/omarchy-blue-theme.git
}
for scenario in failed_clone interrupted replacement failed_publish failed_apply symlink fresh locked; do
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
    [[ $(<"$themes/blue/colors.toml") == "new" ]] || fail "completed clone is published"
    if [[ $scenario != "fresh" ]]; then
      backups=("$themes"/.blue.backup.*/theme)
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
