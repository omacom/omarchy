#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

# A non-English locale must not grow a second set of user folders next to the
# ones Omarchy creates. Omarchy records its folders in ~/.config/user-dirs.dirs
# (provision-user, upgrade-to-quattro), so the login-time xdg-user-dirs-update
# has nothing left to fill in with translated names.

command -v xdg-user-dirs-update >/dev/null || skip "user-dirs locale test needs xdg-user-dirs-update"
[[ -r /usr/share/i18n/locales/ko_KR ]] || skip "user-dirs locale test needs the ko_KR locale source"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Build the Korean locale into the test dir; no root and no host change.
LOCPATH="$test_tmp/locales"
mkdir -p "$LOCPATH"
localedef -i ko_KR -f UTF-8 "$LOCPATH/ko_KR.UTF-8" >/dev/null 2>&1 ||
  skip "could not build ko_KR.UTF-8 into a private LOCPATH"

login_user_dirs_update() {
  # What xdg-user-dirs.service runs at first login under a non-English locale.
  (cd "$1" && env -u XDG_CONFIG_HOME LANG=ko_KR.UTF-8 LC_ALL=ko_KR.UTF-8 \
    LOCPATH="$LOCPATH" xdg-user-dirs-update)
}

translated_dirs_present() {
  local home="$1" dir
  for dir in 다운로드 사진 비디오 프로젝트; do
    [[ -d $home/$dir ]] && return 0
  done
  return 1
}

assert_english_user_dirs() {
  local home="$1"
  local dirs="$home/.config/user-dirs.dirs" key path
  for key in DOWNLOAD PICTURES VIDEOS PROJECTS; do
    # user-dirs.dirs stores unexpanded $HOME literals.
    path=$(grep -oP "(?<=^XDG_${key}_DIR=\").*(?=\"\$)" "$dirs") ||
      fail "user-dirs.dirs records XDG_${key}_DIR"
    case $path in
      "\$HOME/Downloads" | "\$HOME/Pictures" | "\$HOME/Videos" | "\$HOME/Projects") ;;
      *) fail "XDG_${key}_DIR points at Omarchy's folder (got $path)" ;;
    esac
  done
  if translated_dirs_present "$home"; then
    fail "login update created translated user folders in addition to Omarchy's"
  fi
}

# --- provision-user ----------------------------------------------------------

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/home"
for command in xdg-settings xdg-mime; do
  printf '#!/bin/bash\nexit 0\n' >"$mock_bin/$command"
done
chmod +x "$mock_bin"/*

mkdir -p "$test_tmp/install/user"
: >"$test_tmp/install/user/all.sh"

HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_INSTALL="$test_tmp/install" bash "$ROOT/bin/omarchy-provision-user" >/dev/null ||
  fail "omarchy-provision-user finishes under the test home"
[[ -d $test_tmp/home/Projects ]] || fail "omarchy-provision-user creates ~/Projects (it bookmarks it)"

login_user_dirs_update "$test_tmp/home"
assert_english_user_dirs "$test_tmp/home"
pass "provision-user leaves nothing for the login xdg-user-dirs-update to translate"

# --- upgrade-to-quattro ------------------------------------------------------

# The upgrade runs real pacman and migrations, so exercise just its user-dirs
# block: from its mkdir of Omarchy's folders to the end of the bookmark loop.
block=$(awk '
  /^mkdir -p "\$HOME\/Downloads"/ { found = 1 }
  found { print }
  found && /^done$/ { exit }
' "$ROOT/bin/omarchy-upgrade-to-quattro")
[[ -n $block ]] || fail "found the user-dirs block in omarchy-upgrade-to-quattro"

rm -rf "$test_tmp/home"
mkdir -p "$test_tmp/home"
HOME="$test_tmp/home" bash -c "$block" ||
  fail "upgrade user-dirs block finishes under the test home"

login_user_dirs_update "$test_tmp/home"
assert_english_user_dirs "$test_tmp/home"
pass "upgrade-to-quattro leaves nothing for the login xdg-user-dirs-update to translate"
