#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

menu="$ROOT/default/omarchy/omarchy-menu.jsonc"

row_when() {
  grep -F "\"$1\":" "$menu" | sed -E 's/.*"when":"([^"]*)".*/\1/'
}

# Whether a row is offered with only the given packages installed.
offered() {
  local when=$1
  shift
  INSTALLED=" $* " bash -c '
    omarchy-pkg-present() { local p; for p in "$@"; do [[ $INSTALLED == *" $p "* ]] || return 1; done; }
    eval "$1"
  ' _ "$when"
}

dictation=$(row_when remove.dictation)
voxtype=$(row_when remove.dictation.voxtype)

# The remover acts on whichever of these provides the voxtype command, so each
# one alone has to offer it.
for package in voxtype-bin voxtype-bin-rc voxtype; do
  offered "$voxtype" "$package" || fail "Remove > Dictation > Voxtype is offered with $package installed"
  offered "$dictation" "$package" || fail "Remove > Dictation is offered with $package installed"
  pass "Remove > Dictation > Voxtype is offered with $package installed"
done

offered "$dictation" superwhisper-bin || fail "Remove > Dictation is offered with superwhisper-bin installed"
! offered "$voxtype" superwhisper-bin || fail "Remove > Dictation > Voxtype is hidden without a voxtype package"
! offered "$dictation" || fail "Remove > Dictation is hidden with no dictation package installed"
pass "Remove > Dictation is hidden with no dictation package installed"
