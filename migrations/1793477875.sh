echo "Move dictation to Alt + Space, keeping F9 and Super + Ctrl + X for existing dictation users"

bindings="$HOME/.config/hypr/bindings.lua"
if omarchy-default-dictation >/dev/null 2>&1 && [[ -f $bindings ]]; then
  legacy=""
  if ! grep -qF '"SUPER + CTRL + X"' "$bindings"; then
    legacy+=$'  o.bind("SUPER + CTRL + X", "Toggle dictation", "omarchy-dictation toggle")\n'
  fi
  if ! grep -qF '"F9"' "$bindings"; then
    legacy+=$'  o.bind_hold("F9", "Start dictation (push-to-talk)", "omarchy-dictation start", "Stop dictation (push-to-talk)", "omarchy-dictation stop")\n'
  fi

  if [[ -n $legacy ]]; then
    {
      printf '\n-- Dictation keys from before Alt + Space and Right Alt became the defaults.\n'
      printf -- '-- Remove these lines to give the keys back to applications.\n'
      printf 'if o.dictation_installed and o.dictation_installed() then\n'
      printf '%s' "$legacy"
      printf 'end\n'
    } >> "$bindings"
  fi
fi

# Superwhisper needs a recording shortcut of its own; move it off Alt + Space,
# which Omarchy now binds for every dictation backend. A user who never set
# Superwhisper up has no preferences to move.
#
# Edit its files rather than calling `superwhisper shortcuts set`: that reloads
# Hyprland and rolls back on any config error, and a compositor upgraded by this
# same update is still running the old binary, which rejects keys new to the
# upgraded config until the next login. The service regenerates shortcuts.lua
# from shortcuts.active.json and reloads Hyprland when it starts.
superwhisper_config="$HOME/.config/superwhisper"
superwhisper_preferences="$superwhisper_config/preferences.json"
if omarchy-cmd-present superwhisper && [[ -f $superwhisper_preferences ]]; then
  toggle=$(jq -r '.toggleRecordingShortcut // empty' "$superwhisper_preferences")
  if [[ $toggle == "Alt+Space" ]]; then
    superwhisper_running=false
    if systemctl --user is-active --quiet superwhisper.service; then
      superwhisper_running=true
      systemctl --user stop superwhisper.service
    fi

    updated=$(mktemp "$superwhisper_preferences.XXXXXX")
    jq '.toggleRecordingShortcut = "Ctrl+Alt+Space"' "$superwhisper_preferences" > "$updated"
    mv "$updated" "$superwhisper_preferences"

    superwhisper_active="$superwhisper_config/shortcuts.active.json"
    if [[ -f $superwhisper_active ]]; then
      updated=$(mktemp "$superwhisper_active.XXXXXX")
      jq -c '.toggle = "Ctrl+Alt+Space"' "$superwhisper_active" > "$updated"
      mv "$updated" "$superwhisper_active"
    fi

    if [[ $superwhisper_running == "true" ]]; then
      systemctl --user start superwhisper.service
    fi
  fi
fi
