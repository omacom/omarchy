#!/bin/bash

# Prints what omarchy update would install, one package per line:
# source<TAB>package<TAB>old version<TAB>new version<TAB>desktop id. The desktop
# id lets the update window show the app's real icon; packages without one are
# system components.

here=$(dirname "$(realpath "$0")")
pending=$(mktemp)
trap 'rm -f "$pending"' EXIT

repo=$(timeout 60 checkupdates --nocolor 2>/dev/null)
status=$?
# checkupdates exits 2 when nothing is pending; anything else but 0 means it
# could not tell, which the window must not pass off as up to date.
(( status == 0 || status == 2 )) || echo "unknown"
awk 'NF >= 4 { print "repo\t" $1 "\t" $2 "\t" $4 }' <<<"$repo" >>"$pending"
if pacman -Qem >/dev/null && omarchy-pkg-aur-accessible; then
  timeout 60 yay -Qua 2>/dev/null | awk 'NF >= 4 && $3 == "->" { print "aur\t" $1 "\t" $2 "\t" $4 }' >>"$pending"
fi

declare -A desktop
while IFS=$'\t' read -r pkg id; do
  desktop[$pkg]=$id
done < <(cut -f2 "$pending" | xargs -r "$here/launchers.sh")

while IFS=$'\t' read -r source pkg old new; do
  printf '%s\t%s\t%s\t%s\t%s\n' "$source" "$pkg" "$old" "$new" "${desktop[$pkg]:-}"
done <"$pending"
