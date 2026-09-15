#!/bin/bash

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

desktop_id_for_file() {
  local dir=$1
  local file=$2
  local rel=${file#"$dir"/}

  rel=${rel%.desktop}
  printf '%s\n' "${rel//\//-}"
}

is_hidden_desktop_file() {
  local file=$1
  local in_desktop_entry=0
  local hidden=false
  local only_show_in=
  local not_show_in=
  local line key value

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
    esac
  done < "$file"

  [[ $hidden == "true" ]] && return 0
  [[ -n $only_show_in ]] && ! desktop_matches "$only_show_in" && return 0
  [[ -n $not_show_in ]] && desktop_matches "$not_show_in" && return 0

  return 1
}

scan_dir() {
  local dir=$1
  local file id

  [[ -d $dir ]] || return

  while IFS= read -r -d '' file; do
    id=$(desktop_id_for_file "$dir" "$file")
    [[ -n ${seen_ids[$id]+set} ]] && continue
    seen_ids[$id]=1

    if is_hidden_desktop_file "$file"; then
      printf '%s\n' "$id"
    fi
  done < <(find "$dir" -type f -name '*.desktop' -print0 2>/dev/null | sort -z)
}

# The first word of an entry's Exec, quoted or bare, is the command it
# launches: an absolute path is checked where it points and a bare name on
# PATH, the way the launcher runs it. A relative path resolves against the
# entry's own Path= and an escape such as \s is decoded by the launcher;
# neither is read here, so both are taken as live.
exec_target_exists() {
  local target=${1#Exec=}

  if [[ $target == \"*\"* ]]; then
    target=${target#\"}
    target=${target%%\"*}
  else
    target=${target%%[[:space:]]*}
  fi
  [[ -n $target ]] || return 1
  # The launcher decodes desktop-entry string escapes before running the
  # command; judging the raw form here would call any escaped target live
  # forever, so decode it the same way. Leftover backslash means an escape
  # this decoder does not know, and the entry is left to the launcher like
  # one with a relative command.
  local decoded=$target placeholder=$'\x01' unknown=$'\x02'
  decoded=${decoded//\\\\/$placeholder}
  decoded=${decoded//\\/$unknown}
  decoded=${decoded//${unknown}s/ }
  decoded=${decoded//${unknown}t/$'\t'}
  decoded=${decoded//${unknown}n/$'\n'}
  decoded=${decoded//${unknown}r/$'\r'}
  if [[ $decoded == *$unknown* ]]; then
    # An escape this decoder does not know leaves the command unreadable:
    # the ID is hidden as unjudgable while the entry itself is left for
    # the remover, which keeps what it cannot judge dead.
    return 1
  fi
  decoded=${decoded//${placeholder}/\\}
  target=$decoded
  if [[ $target == /* ]]; then
    [[ -e $target ]]
  elif [[ $target == */* ]]; then
    return 0
  else
    omarchy-cmd-present "$target"
  fi
}

# The upstream runtime registers its own Hermes launcher, and the packaged
# desktop app supersedes it while the package Omarchy installed owns Hermes.
# An entry whose Exec target is gone -- a runtime deleted by hand, a removal
# that never reached the entry -- stays hidden too: a launcher that cannot
# launch is only search noise.
# The runtime registers its entry under the XDG data home, wherever that is;
# a custom XDG_DATA_HOME leaves $HOME/.local/share with nothing of ours in it.
[[ -n ${XDG_DATA_HOME-} ]] && data_dir="$XDG_DATA_HOME/applications" || data_dir="$HOME/.local/share/applications"

if omarchy-pkg-present hermes-desktop; then
  printf '%s\n' hermes
elif [[ -f $data_dir/hermes.desktop ]]; then
  exec_line=$(grep -m1 '^Exec=' "$data_dir/hermes.desktop" 2>/dev/null) || true
  if ! exec_target_exists "$exec_line"; then
    printf '%s\n' hermes
  fi
fi

scan_dir "$data_dir"

IFS=":" read -ra data_dirs <<< "${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
for data_dir in "${data_dirs[@]}"; do
  scan_dir "$data_dir/applications"
done

scan_dir "$HOME/.nix-profile/share/applications"
