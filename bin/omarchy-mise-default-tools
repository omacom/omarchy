#!/bin/bash

# omarchy:summary=List Omarchy's default mise tools, or opt this user out of or back into them
# omarchy:args=<list|declares <tool>|disable|enable>
# omarchy:hidden=true

set -euo pipefail

# The settings package owns this file, so a user opts out by having mise skip it
# rather than by deleting it. Skipping the file drops only Omarchy's
# declarations: the same tools declared in a project or the user's own config
# still load, which a disable_tools entry would block as well.
tools_config="${OMARCHY_MISE_CONFIG_PATH:-/etc/mise/conf.d/omarchy-tools.toml}"

# mise reads ignored_config_paths before any config file loads, so the setting
# lives in miserc.toml, which `mise settings` does not edit. Only this exact
# line is added or removed, leaving the rest of the file to the user.
miserc="$HOME/.config/mise/miserc.toml"
ignore_line="ignored_config_paths = [\"$tools_config\"]"

list_tools() {
  [[ -f $tools_config ]] || return 0
  awk '
    /^\[/ { in_tools = ($0 == "[tools]"); next }
    in_tools && match($0, /^("[^"]+"|[^ =]+) = /) {
      key = substr($0, RSTART, RLENGTH - 3)
      gsub(/"/, "", key)
      print key
    }
  ' "$tools_config"
}

# Counts the path in a list the user wrote themselves, too, but not in a comment.
opted_out() {
  [[ -f $miserc ]] && grep -v '^[[:space:]]*#' "$miserc" | grep -qF "$tools_config"
}

case "${1:-}" in
list)
  list_tools
  ;;
declares)
  [[ -n ${2:-} ]] && ! opted_out && list_tools | grep -qxF "$2"
  ;;
disable)
  if ! opted_out; then
    # miserc.toml is flat, so a second ignored_config_paths key would be a
    # duplicate. Merging into the user's own list is left to them.
    if [[ -f $miserc ]] && grep -q '^[[:space:]]*ignored_config_paths[[:space:]]*=' "$miserc"; then
      echo "Add \"$tools_config\" to ignored_config_paths in $miserc to opt out of Omarchy's mise tools." >&2
      exit 1
    fi
    mkdir -p "$(dirname "$miserc")"
    if [[ -s $miserc && -n $(tail -c1 "$miserc") ]]; then
      echo >>"$miserc"
    fi
    printf '%s\n' "$ignore_line" >>"$miserc"
  fi
  # A user reshim retires the lazy shims built from Omarchy's declarations.
  mise reshim
  ;;
enable)
  if [[ -f $miserc ]] && grep -qxF "$ignore_line" "$miserc"; then
    remaining=$(grep -vxF "$ignore_line" "$miserc" || true)
    if [[ -n ${remaining//[[:space:]]/} ]]; then
      printf '%s\n' "$remaining" >"$miserc"
    else
      rm -f "$miserc"
    fi
  fi
  if opted_out; then
    echo "Remove \"$tools_config\" from ignored_config_paths in $miserc to restore Omarchy's mise tools." >&2
    exit 1
  fi
  mise reshim --system
  mise reshim
  ;;
*)
  echo "Usage: omarchy-mise-default-tools <list|declares <tool>|disable|enable>" >&2
  exit 1
  ;;
esac
