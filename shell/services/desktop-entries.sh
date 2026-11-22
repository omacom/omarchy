#!/bin/bash

# Reads what the shell needs from desktop entries beyond what Quickshell
# parses, one line per finding:
#   hidden<TAB><id>
#     the entry stays out of the launcher
#   dock-click<TAB><mode><TAB><id>
#     its X-Omarchy-Dock-Click: how a dock click on the running app answers,
#     with a new window (new) or one on this workspace if any (workspace)

desktop_names=${1:-}

declare -A seen_ids

desktop_matches() {
  local list=$1
  local desktop_name
  local entry

  IFS=":" read -ra desktop_parts <<< "$desktop_names"
  IFS=";" read -ra entries <<< "$list"

  for desktop_name in "${desktop_parts[@]}"; do
    [[ -z $desktop_name ]] && continue

    for entry in "${entries[@]}"; do
      [[ -z $entry ]] && continue
      [[ $entry == "$desktop_name" ]] && return 0
    done
  done

  return 1
}

# Sets hidden and dock_click for one file.
read_desktop_file() {
  local file=$1
  local in_desktop_entry=0
  local only_show_in=
  local not_show_in=
  local line key value
  hidden=false
  dock_click=

  while IFS= read -r line || [[ -n $line ]]; do
    line=${line%$'\r'}

    if [[ $line =~ ^\[(.*)\]$ ]]; then
      [[ ${BASH_REMATCH[1]} == "Desktop Entry" ]] && in_desktop_entry=1 || in_desktop_entry=0
      continue
    fi

    (( in_desktop_entry )) || continue
    [[ $line == *=* ]] || continue

    key=${line%%=*}
    value=${line#*=}

    case $key in
      Hidden|NoDisplay)
        [[ $value == "true" ]] && hidden=true
        ;;
      OnlyShowIn)
        only_show_in=$value
        ;;
      NotShowIn)
        not_show_in=$value
        ;;
      X-Omarchy-Dock-Click)
        dock_click=$value
        ;;
    esac
  done < "$file"

  [[ -n $only_show_in ]] && ! desktop_matches "$only_show_in" && hidden=true
  [[ -n $not_show_in ]] && desktop_matches "$not_show_in" && hidden=true
  return 0
}

scan_dir() {
  local dir=$1
  local file id

  [[ -d $dir ]] || return

  while IFS= read -r -d '' file; do
    id=${file#"$dir"/}
    id=${id%.desktop}
    id=${id//\//-}
    [[ -n ${seen_ids[$id]+set} ]] && continue
    seen_ids[$id]=1

    read_desktop_file "$file"
    if [[ $hidden == "true" ]]; then
      printf 'hidden\t%s\n' "$id"
    fi
    if [[ -n $dock_click ]]; then
      printf 'dock-click\t%s\t%s\n' "$dock_click" "$id"
    fi
  done < <(find "$dir" -type f -name '*.desktop' -print0 2>/dev/null | sort -z)
}

scan_dir "$HOME/.local/share/applications"

IFS=":" read -ra data_dirs <<< "${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
for data_dir in "${data_dirs[@]}"; do
  scan_dir "$data_dir/applications"
done

scan_dir "$HOME/.nix-profile/share/applications"
