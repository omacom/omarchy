#!/bin/bash

# Prints "package<TAB>desktop id" for each given installed package that ships a
# visible launcher, so the update window can show the app's real icon.

declare -A desktop
while read -r pkg path; do
  id=${path##*/}
  id=${id%.desktop}
  # First visible entry wins, unless a later one is named after the package.
  [[ -z ${desktop[$pkg]:-} || $id == "$pkg" ]] || continue
  grep -qs '^NoDisplay=true' "$path" || desktop[$pkg]=$id
done < <((( $# )) && pacman -Ql "$@" 2>/dev/null | grep -E ' /usr/share/applications/[^/]+\.desktop$')

for pkg in "${!desktop[@]}"; do
  printf '%s\t%s\n' "$pkg" "${desktop[$pkg]}"
done
