#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# default/splash/layouts orders vconsole.conf's layouts for the unlock prompt
# and the login screen: the one they start in first, US among them, and no
# layout shortcut, as the screen's keyboard (ui/Layouts.qml) switches.

layouts=$ROOT/default/splash/layouts
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

assert_layouts() {
  local description=$1 expected=$2 actual
  printf '%s' "$3" >"$test_tmp/vconsole.conf"
  actual=$("$layouts" "$test_tmp/vconsole.conf") || fail "$description" "$actual"
  [[ $actual == "$expected" ]] ||
    fail "$description" "expected:"$'\n'"$expected"$'\n'"actual:"$'\n'"$actual"
  pass "$description"
}

assert_layouts "plain US has nothing to switch to" "XKBLAYOUT=us" $'KEYMAP=us\nXKBLAYOUT=us\n'
assert_layouts "a Latin layout starts in its own, with US after it" $'XKBLAYOUT=de,us\nXKBMODEL=pc105\nXKBOPTIONS=terminate:ctrl_alt_bksp' \
  $'XKBLAYOUT="de"\nXKBMODEL=pc105\nXKBOPTIONS=terminate:ctrl_alt_bksp\n'
assert_layouts "Colemak keeps a plain US apart from it" $'XKBLAYOUT=us,us\nXKBVARIANT=colemak,' $'XKBLAYOUT=us\nXKBVARIANT=colemak\n'
assert_layouts "a Latin layout with US keeps its order, without its layout shortcuts" $'XKBLAYOUT=cz,us\nXKBVARIANT=qwerty,\nXKBOPTIONS=terminate:ctrl_alt_bksp' \
  $'XKBLAYOUT=cz,us\nXKBVARIANT=qwerty,\nXKBOPTIONS=grp:alt_shift_toggle,terminate:ctrl_alt_bksp,grp_led:scroll\n'
assert_layouts "a non-Latin layout starts in US, its own after it" "XKBLAYOUT=us,il" $'XKBLAYOUT=il\n'
assert_layouts "a non-Latin layout's US moves to the front with its variant" $'XKBLAYOUT=us,ua,de\nXKBVARIANT=intl,,nodeadkeys' \
  $'XKBLAYOUT=ua,us,de\nXKBVARIANT=,intl,nodeadkeys\n'
assert_layouts "Serbian Latin starts in US, as kmscon does" $'XKBLAYOUT=us,rs\nXKBVARIANT=,latin\nXKBOPTIONS=terminate:ctrl_alt_bksp' \
  $'XKBLAYOUT=rs\nXKBVARIANT=latin\nXKBOPTIONS=terminate:ctrl_alt_bksp,grp:shifts_toggle\n'
assert_layouts "a Cherokee US is no US to start a non-Latin layout in" $'XKBLAYOUT=us,ru,us\nXKBVARIANT=,,chr' $'XKBLAYOUT=ru,us\nXKBVARIANT=,chr\n'
assert_layouts "several Latin layouts keep their order, US last" "XKBLAYOUT=de,fr,ru,us" $'XKBLAYOUT=de,fr,ru\n'
assert_layouts "a console keymap with no XKB layout stays the console's" "KEYMAP=de-latin1" $'KEYMAP=de-latin1\nXKBMODEL=pc105\n'

actual=$("$layouts" "$test_tmp/missing.conf") && [[ -z $actual ]] ||
  fail "no vconsole.conf leaves the keyboard to its defaults" "$actual"
pass "no vconsole.conf leaves the keyboard to its defaults"

hooks_layouts=$(awk -F')' '/\) ;;$/ { gsub(/[[:space:]|]+/, "\n", $1); print $1 }' "$ROOT/etc/mkinitcpio.conf.d/omarchy_hooks.conf" | grep '^[a-z]\+$' | sort)
script_layouts=$(awk -F')' '/ \| ua\)$/ { gsub(/[[:space:]|]+/, "\n", $1); print $1 }' "$layouts" | grep '^[a-z]\+$' | sort)
[[ -n $hooks_layouts && $hooks_layouts == "$script_layouts" ]] ||
  fail "the non-Latin layout list stays in sync with the initramfs hook" "$(diff <(echo "$hooks_layouts") <(echo "$script_layouts"))"
pass "the non-Latin layout list stays in sync with the initramfs hook"

# /usr/bin/qmltestrunner is the Qt 5 binary, which exits 0 having run nothing.
qml_test_runner=/usr/lib/qt6/bin/qmltestrunner
if [[ ! -x $qml_test_runner ]]; then
  skip "qt6 qmltestrunner not found; skipping the screen's layout labels"
  exit 0
fi

cat >"$test_tmp/tst_layouts.qml" <<QML
import QtQuick
import QtTest
import "file://$ROOT/default/splash/ui"

TestCase {
  name: "Layouts"

  Layouts { id: none; layout: "" }
  Layouts { id: shared; layout: "us,de,us"; variant: "colemak,nodeadkeys," }

  function test_no_layout_is_plain_us() {
    compare(none.count, 1)
    compare(none.label, "US")
  }

  function test_a_variant_tells_apart_entries_sharing_a_layout() {
    compare(shared.labels, ["US COLEMAK", "DE", "US"])
  }

  function test_a_click_goes_through_every_layout() {
    shared.next()
    compare(shared.label, "DE")
    shared.next()
    shared.next()
    compare(shared.label, "US COLEMAK")
  }
}
QML

output=$(QT_QPA_PLATFORM=offscreen "$qml_test_runner" -input "$test_tmp/tst_layouts.qml" -o -,txt 2>&1) ||
  fail "the screen's keyboard labels each layout apart and goes through them all" "$output"
pass "the screen's keyboard labels each layout apart and goes through them all"
