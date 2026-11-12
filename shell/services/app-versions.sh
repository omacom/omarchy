#!/bin/bash

# Prints "<desktop-id>\t<version>" for every launcher entry a package owns, so
# the app grid can show the version of the app in focus. The version drops the
# epoch and package release ("1:2.4.0-3" -> "2.4.0"). Directories go in XDG
# precedence order and the first owned entry per id wins.

dirs=("${XDG_DATA_HOME:-$HOME/.local/share}/applications")
IFS=":" read -ra data_dirs <<<"${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
for dir in "${data_dirs[@]}"; do
  dirs+=("$dir/applications")
done

files=()
for dir in "${dirs[@]}"; do
  [[ -d $dir ]] && files+=("$dir"/*.desktop)
done

(( ${#files[@]} )) || exit 0

LC_ALL=C pacman -Qo "${files[@]}" 2>/dev/null | awk -v OFS="\t" '
  match($0, / is owned by [^ ]+ [^ ]+$/) {
    path = substr($0, 1, RSTART - 1)
    split(substr($0, RSTART + 13), owner, " ")
    id = path; sub(/.*\//, "", id); sub(/\.desktop$/, "", id)
    version = owner[2]; sub(/^[0-9]+:/, "", version); sub(/-[^-]+$/, "", version)
    if (!(id in seen)) { seen[id] = 1; print id, version }
  }'
