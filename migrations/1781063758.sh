echo "Update Hyprland Lua entrypoint to load Omarchy bootstrap"

hyprland_config="$HOME/.config/hypr/hyprland.lua"

if [[ -f $hyprland_config ]] && ! grep -Fq '/default/hypr/bootstrap.lua' "$hyprland_config"; then
  tmp=$(mktemp)
  consumed=$(mktemp)

  awk -v consumed="$consumed" '
    BEGIN { replaced = 0 }

    !replaced && $0 == "-- Load user modules from ~/.config and Omarchy defaults from $OMARCHY_PATH." {
      comment = $0
      got_next = getline next_line
      if (got_next > 0 && next_line == "package.path = os.getenv(\"HOME\")") {
        print "-- Omarchy'\''s bootstrap keeps path setup out of this user config."
        print "dofile((os.getenv(\"OMARCHY_PATH\") or \"/usr/share/omarchy\") .. \"/default/hypr/bootstrap.lua\")"
        replaced = 1

        # The assignment ends where its continuations do, however the user has
        # wrapped it. Anything else is the next statement and is printed, not
        # dropped: looking for one exact terminator line ran to EOF and took
        # the rest of the config with it.
        while ((getline line) > 0) {
          if (line ~ /^[[:space:]]*\.\./ || line ~ /^[[:space:]]*package\.path[[:space:]]*$/) {
            print line > consumed
            continue
          }
          print line
          break
        }

        next
      }

      print comment
      if (got_next > 0) { print next_line }
      next
    }

    { print }
  ' "$hyprland_config" >"$tmp"

  # Keep a copy only when the preamble was not the shipped one, so a path entry
  # the user added is recoverable rather than absorbed without trace.
  stock=$(mktemp)
  cat >"$stock" <<'STOCK'
  .. "/.config/?.lua;"
  .. (os.getenv("OMARCHY_PATH") or "/usr/share/omarchy")
  .. "/?.lua;"
  .. package.path
STOCK

  if cmp -s "$tmp" "$hyprland_config"; then
    # No preamble of the shape this migration rewrites, so there is nothing to
    # replace and nothing to keep a copy of.
    rm -f "$tmp"
  else
    if ! cmp -s "$consumed" "$stock"; then
      backup="$hyprland_config.omarchy-bootstrap.bak"
      cp "$hyprland_config" "$backup"
      echo "Your hyprland.lua set package.path itself; the bootstrap owns that now."
      echo "Saved your previous file as $backup."
    fi

    mv "$tmp" "$hyprland_config"
  fi

  rm -f "$consumed" "$stock"
fi
