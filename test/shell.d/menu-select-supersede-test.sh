#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "menu select supersede test"

qml_fixture_scratch
scratch="$QML_FIXTURE_TMP/scratch"
mkdir -p "$scratch"

OMARCHY_MENU_TMP="$scratch" run_qml_fixture menu-select-supersede "the menu takes over from pending select requests" Ui Commons

for name in a b c d; do
  if [[ ! -e $scratch/done-$name ]]; then
    sed -n '1,220p' "$QML_FIXTURE_LOG" >&2
    fail "superseding a pending menu select strands its waiter" "done-$name was never written; the displaced omarchy-menu-select waiter would spin forever"
  fi
done

pass "superseding a pending menu select finishes its request instead of leaking the waiter"
