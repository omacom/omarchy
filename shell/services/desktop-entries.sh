#!/bin/bash

# Reads what the shell needs from desktop entries beyond what Quickshell
# parses, one line per finding:
#   hidden<TAB><id>
#     the entry stays out of the launcher
#   dock-click<TAB><mode><TAB><id>
#     its X-Omarchy-Dock-Click: how a dock click on the running app answers,
#     with a new window (new) or one on this workspace if any (workspace)

desktop_names=${1:-}

declare -A seen_ids=()
files=()
ids=()

collect_dir() {
  local dir=$1
  local file id

  [[ -d $dir ]] || return 0

  while IFS= read -r -d '' file; do
    id=${file#"$dir"/}
    id=${id%.desktop}
    id=${id//\//-}
    [[ -n ${seen_ids[$id]+set} ]] && continue
    seen_ids[$id]=1
    files+=("$file")
    ids+=("$id")
  done < <(find "$dir" -type f -name '*.desktop' -print0 2>/dev/null | sort -z)
}

collect_dir "$HOME/.local/share/applications"

IFS=":" read -ra data_dirs <<< "${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
for data_dir in "${data_dirs[@]}"; do
  [[ -n $data_dir ]] && collect_dir "$data_dir/applications"
done

collect_dir "$HOME/.nix-profile/share/applications"

(( ${#files[@]} > 0 )) || exit 0

awk -v desktop_names="$desktop_names" '
  BEGIN {
    n = split(desktop_names, parts, ":")
    for (i = 1; i <= n; i++) {
      if (parts[i] != "") desktops[parts[i]] = 1
    }
  }

  function desktop_matches(list,    m, entries, i) {
    m = split(list, entries, ";")
    for (i = 1; i <= m; i++) {
      if (entries[i] != "" && (entries[i] in desktops)) return 1
    }
    return 0
  }

  BEGINFILE {
    if ((getline id < "/dev/fd/3") <= 0) id = ""
    in_desktop_entry = 0
    hidden = 0
    only_show_in = ""
    not_show_in = ""
    dock_click = ""
    if (ERRNO != "") nextfile
  }

  {
    sub(/\r$/, "")
    if ($0 ~ /^\[.*\]$/) {
      in_desktop_entry = ($0 == "[Desktop Entry]")
      next
    }
    if (!in_desktop_entry) next
    eq = index($0, "=")
    if (eq == 0) next

    key = substr($0, 1, eq - 1)
    value = substr($0, eq + 1)

    if ((key == "Hidden" || key == "NoDisplay") && value == "true") {
      hidden = 1
    } else if (key == "OnlyShowIn") {
      only_show_in = value
    } else if (key == "NotShowIn") {
      not_show_in = value
    } else if (key == "X-Omarchy-Dock-Click") {
      dock_click = value
    }
  }

  ENDFILE {
    if (id != "") {
      if (only_show_in != "" && !desktop_matches(only_show_in)) hidden = 1
      if (not_show_in != "" && desktop_matches(not_show_in)) hidden = 1
      if (hidden) printf "hidden\t%s\n", id
      if (dock_click != "") printf "dock-click\t%s\t%s\n", dock_click, id
    }
  }
' "${files[@]}" 3< <(printf '%s\n' "${ids[@]}")
