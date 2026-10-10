#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/backgrounds" "$work/home/.local/state/omarchy/current"

# Point the background at a file of that name. readlink -f resolves a missing
# last component, so the file itself is not created: some filesystems refuse
# names that are not UTF-8.
background_name() {
  ln -sfn "$work/backgrounds/$1" "$work/home/.local/state/omarchy/current/background"
  HOME="$work/home" "$ROOT/bin/omarchy-theme-bg-current"
}

# Each case is a file name then the name shown for it.
check_names() {
  local locale="$1" description="$2"
  shift 2

  while (( $# > 0 )); do
    local actual
    actual=$(LC_ALL=$locale background_name "$1")
    [[ $actual == "$2" ]] || fail "$description in $locale: $1 becomes $2" "actual: $actual"
    shift 2
  done
  pass "$description in $locale"
}

# File names are read as UTF-8 whatever the locale, so a letter after an
# accented one is not taken for the start of a word.
for locale in C.UTF-8 C; do
  check_names "$locale" 'current background name drops the extension and number prefix and title-cases each word' \
    1-kanagawa-dragon.jpg 'Kanagawa Dragon' \
    007-bond.png 'Bond' \
    noextension 'Noextension'

  check_names "$locale" 'accented letters do not start a new word' \
    02-über-städte.jpg 'Über Städte' \
    élan-vital.jpg 'Élan Vital'

  check_names "$locale" 'a name that is not UTF-8 still shows' \
    $'caf\xe9-cr\xe8me.jpg' $'Caf� Cr�Me'
done
