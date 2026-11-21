echo "Update Hyprland Lua entrypoint to load Omarchy bootstrap"

hyprland_config="$HOME/.config/hypr/hyprland.lua"

if [[ -f $hyprland_config ]] && ! grep -Fq '/default/hypr/bootstrap.lua' "$hyprland_config"; then
  # Only the preambles Omarchy shipped are rewritten: with either OMARCHY_PATH
  # fallback it carried, each as installed and as 1781043107 left it after adding
  # the state path. A preamble the user edited is their own Lua, and guessing
  # where it ends cost them their config.
  preambles=()
  for omarchy_fallback in '"/usr/share/omarchy"' '(os.getenv("HOME") .. "/.local/share/omarchy")'; do
    for state_path in "" $'\n  .. "/.local/state/?.lua;"\n  .. os.getenv("HOME")'; do
      preambles+=("-- Load user modules from ~/.config and Omarchy defaults from \$OMARCHY_PATH.
package.path = os.getenv(\"HOME\")$state_path
  .. \"/.config/?.lua;\"
  .. (os.getenv(\"OMARCHY_PATH\") or $omarchy_fallback)
  .. \"/?.lua;\"
  .. package.path")
    done
  done

  bootstrap_dofile='dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")'
  tmp=$(mktemp)

  # The shipped block can also be the start of a longer assignment the user
  # extended, or a copy they commented out or wrapped in a function. So the
  # rewrite is installed only if Lua can load it and the bootstrap is in its
  # top-level code: luac lists the main chunk before any function.
  if PREAMBLES=$(printf '%s\036' "${preambles[@]}") \
    BOOTSTRAP="-- Omarchy's bootstrap keeps path setup out of this user config."$'\n'"$bootstrap_dofile" \
    awk '
      { file = file "\n" $0 }

      END {
        file = file "\n"
        count = split(ENVIRON["PREAMBLES"], preambles, "\036")

        for (i = 1; i <= count; i++) {
          if (preambles[i] == "") continue

          block = "\n" preambles[i] "\n"
          pos = index(file, block)
          if (!pos) continue

          printf "%s%s\n%s", substr(file, 2, pos - 1), ENVIRON["BOOTSTRAP"], substr(file, pos + length(block))
          exit 0
        }

        exit 1
      }
    ' "$hyprland_config" >"$tmp" &&
    listing=$(luac -l -p "$tmp" 2>/dev/null) &&
    awk '/^function </ { exit } index($0, "\"/default/hypr/bootstrap.lua\"") { found = 1; exit } END { exit !found }' <<<"$listing"; then
    mv "$tmp" "$hyprland_config"
  else
    rm -f "$tmp"

    # The user's own path setup is theirs to switch. Until they do, the
    # migration stays pending and runs again on the next omarchy-migrate. A
    # comment that only mentions package.path is not a setup to switch.
    if awk '!/^[[:space:]]*--/ && /package\.path[[:space:]]*=([^=]|$)/ { found = 1; exit } END { exit !found }' "$hyprland_config"; then
      echo "Could not switch $hyprland_config to Omarchy's bootstrap: its package.path setup is not one Omarchy shipped." >&2
      echo "Replace that setup with the line below, then run omarchy-migrate again:" >&2
      echo "  $bootstrap_dofile" >&2
      exit 1
    fi
  fi
fi
