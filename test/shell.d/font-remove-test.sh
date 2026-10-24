#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/fc-list" <<'SH'
#!/bin/bash
if [[ $1 == "-f" ]]; then
  printf '%s\t%s\n' 'Liberation Mono' '/usr/share/fonts/TTF/liberation.ttf'
fi
SH

cat >"$mock_bin/pacman" <<'SH'
#!/bin/bash
case $1 in
  -Ql)
    printf '%s\n' 'liberation-font /usr/share/fonts/TTF/liberation.ttf'
    ;;
  -Qi)
    cat <<'INFO'
Name            : liberation-font
Provides        : None
Depends On      : None

INFO
    ;;
esac
SH

cat >"$mock_bin/omarchy-font-current" <<'SH'
#!/bin/bash
echo "${TEST_CURRENT_FONT:-Some other font}"
SH

cat >"$mock_bin/omarchy-menu-select" <<'SH'
#!/bin/bash
printf '%s\n' "$2" >"$TEST_MENU_SELECTION"
printf '%s\n' "$2"
SH

cat >"$mock_bin/omarchy-i18n" <<'SH'
#!/bin/bash
case $1 in
  font.active) echo "Active" ;;
  font.removeSuccessBody) printf 'The %s font has been removed successfully.\n' "$2" ;;
  font.removed) echo "Font removed" ;;
  font.removeSkipped) echo "Font removal skipped" ;;
  font.removeActive) printf '%s is the active font\n' "$2" ;;
esac
SH

cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >>"$TEST_NOTIFICATION_LOG"
SH

cat >"$mock_bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_PKG_DROP_LOG"
SH
chmod +x "$mock_bin/fc-list" "$mock_bin/pacman" "$mock_bin/omarchy-font-current" \
  "$mock_bin/omarchy-menu-select" "$mock_bin/omarchy-i18n" \
  "$mock_bin/omarchy-notification-send" "$mock_bin/omarchy-pkg-drop"

for requested in 'Liberation Mono?' 'liberation-font?'; do
  if PATH="$mock_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-font-remove" "$requested" >"$test_tmp/output" 2>&1; then
    fail "wildcard characters in an unknown font name are rejected: $requested"
  fi

  grep -q "Font '$requested' was not found" "$test_tmp/output" ||
    fail "unknown font name reports not found: $requested" "$(cat "$test_tmp/output")"
done
pass "unknown family and package globs do not resolve to installed fonts"

if TEST_CURRENT_FONT="Liberation Mono" TEST_MENU_SELECTION="$test_tmp/menu-selection" \
  TEST_PKG_DROP_LOG="$test_tmp/pkg-drop.log" \
  TEST_NOTIFICATION_LOG="$test_tmp/notification.log" \
  PATH="$mock_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-font-remove" >"$test_tmp/output" 2>&1; then
  fail "active font cannot be removed from the picker"
fi

grep -q "Liberation Mono.*currently in use" "$test_tmp/output" ||
  fail "active font is identified after selection" "$(cat "$test_tmp/output")"
grep -q $'\tLiberation Mono (Active)\tliberation-font' "$test_tmp/menu-selection" ||
  fail "active font is visibly marked in the picker" "$(cat "$test_tmp/menu-selection")"
[[ ! -e $test_tmp/pkg-drop.log ]] || fail "active font package is never removed"
[[ $(sed -n '1p' "$test_tmp/notification.log") == "-g" ]] ||
  fail "font notifications include the glyph option"
[[ $(sed -n '2p' "$test_tmp/notification.log") == "$(printf '\ue659')" ]] ||
  fail "font notifications use the font glyph" "$(cat "$test_tmp/notification.log")"
pass "active installed font appears in the picker but remains protected"

TEST_CURRENT_FONT="Some other font" TEST_PKG_DROP_LOG="$test_tmp/pkg-drop-success.log" \
  TEST_NOTIFICATION_LOG="$test_tmp/notification-success.log" \
  PATH="$mock_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-font-remove" --do "Liberation Mono" >"$test_tmp/output" 2>&1 ||
  fail "removing a non-active font succeeds" "$(cat "$test_tmp/output")"

[[ $(sed -n '1p' "$test_tmp/notification-success.log") == "-g" &&
  $(sed -n '2p' "$test_tmp/notification-success.log") == "$(printf '\ue659')" ]] ||
  fail "success notification uses the font glyph" "$(cat "$test_tmp/notification-success.log")"
[[ $(sed -n '3p' "$test_tmp/notification-success.log") == "-u" &&
  $(sed -n '4p' "$test_tmp/notification-success.log") == "normal" ]] ||
  fail "success notification uses normal urgency" "$(cat "$test_tmp/notification-success.log")"
[[ $(sed -n '5p' "$test_tmp/notification-success.log") == "Font removed" ]] ||
  fail "success notification has a concise title" "$(cat "$test_tmp/notification-success.log")"
[[ $(sed -n '6p' "$test_tmp/notification-success.log") == "The Liberation Mono font has been removed successfully." ]] ||
  fail "success notification says which font was removed" "$(cat "$test_tmp/notification-success.log")"
[[ $(cat "$test_tmp/pkg-drop-success.log") == "liberation-font" ]] ||
  fail "success path removes the selected font package"
pass "success notification says which font was removed"
