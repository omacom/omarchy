#!/bin/bash

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tray="$ROOT/shell/plugins/bar/widgets/Tray.qml"

open_tray_menu=$(sed -n '/^  function openTrayMenu(/,/^  function trayIconSource(/p' "$tray")
normalized=$(tr '\n\r\t' '   ' <<<"$open_tray_menu")

echo "$normalized" | grep -Eq 'item\.display\(' &&
  fail "openTrayMenu still calls item.display when the SNI has no menu"

echo "$normalized" | grep -Eq 'if *\( *!item *\|\| *!item\.menu *\) *return' ||
  fail "openTrayMenu does not no-op when the SNI has no menu"

echo "$normalized" | grep -Eq 'trayMenuOpen *= *trayMenuOpener\.children\.length *> *0' ||
  fail "openTrayMenu still sets trayMenuOpen without opener children"

opener=$(sed -n '/^  QsMenuOpener {/,/^  PopupCard {/p' "$tray")
opener_n=$(tr '\n\r\t' '   ' <<<"$opener")

echo "$opener_n" | grep -Eq 'onChildrenChanged' ||
  fail "trayMenuOpener does not watch children for a late-ready SNI menu"

echo "$opener_n" | grep -Eq 'children\.length *=== *0' ||
  fail "trayMenuOpener does not close the grab when opener children drop to 0"

pass "unready SNI tray clicks do not take HyprlandFocusGrab"
