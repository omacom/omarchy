echo "Expose the XKB keyboard layout in /etc/vconsole.conf when the console keymap left it out"

# The installer persists the chosen console keymap with systemd-firstboot or
# localectl, and systemd derives XKBLAYOUT/XKBVARIANT from its kbd-model-map.
# Keymaps with no conversion row there (Polish, Czech, Ukrainian, Colemak, ...)
# got KEYMAP only. Both the user session (default/hypr/input.lua) and the SDDM
# greeter (default/sddm/hyprland.lua) resolve their layout from the XKB
# variables, so those installs fell back to "us" and a password typed under the
# chosen layout during setup could not be reproduced at login (#9442). Fill the
# gap from systemd's own table, then from the installer's gap table
# (install/provisioning/setup-form.sh) for the keymaps the table has no row for.

vconsole="${OMARCHY_VCONSOLE_CONF:-/etc/vconsole.conf}"
kbd_map="${OMARCHY_KBD_MODEL_MAP:-/usr/share/systemd/kbd-model-map}"

[[ -f $vconsole ]] || exit 0

vconsole_value() {
  awk -F= -v key="$1" '
    $1 == key {
      value = $2
      sub(/^[[:space:]]*/, "", value)
      sub(/[[:space:]]*$/, "", value)
      gsub(/^"/, "", value)
      gsub(/"$/, "", value)
      print value
      exit
    }
  ' "$vconsole"
}

# Idempotency: a vconsole.conf that already carries the layout (or no keymap to
# derive one from) needs nothing — including reruns and other users on this
# machine, who each run this migration.
[[ -z $(vconsole_value XKBLAYOUT) ]] || exit 0
keymap=$(vconsole_value KEYMAP)
[[ -n $keymap ]] || exit 0

layout=""
variant=""

# systemd's own conversion table, where it knows the keymap. Its columns are
# tab-separated with deliberate empty padding: the layout sits in field 4 and
# the variant in field 7 (`-` when there is none). Keep the first entry of
# comma-separated lists: the session and greeter prepend "us" to non-Latin
# layouts themselves.
if [[ -f $kbd_map ]]; then
  map_row=$(awk -F'\t' -v key="$keymap" '$1 == key { print $4 "\t" $7; exit }' "$kbd_map") || map_row=""
  if [[ -n $map_row ]]; then
    layout=${map_row%%$'\t'*}
    variant=${map_row#*$'\t'}
    layout=${layout%%,*}
    variant=${variant%%,*}
    if [[ $variant == "-" ]]; then
      variant=""
    fi
  fi
fi

# The keymaps kbd-model-map has no row for, from the installer's gap table.
if [[ -z $layout && -f $OMARCHY_PATH/install/provisioning/setup-form.sh ]]; then
  source "$OMARCHY_PATH/install/provisioning/setup-form.sh"
  gap=$(omarchy_keyboard_xkb "$keymap")
  if [[ -n $gap ]]; then
    layout=${gap%% *}
    variant=${gap#* }
  fi
fi

[[ -n $layout ]] || exit 0

printf 'XKBLAYOUT=%s\n' "$layout" | sudo tee -a "$vconsole" >/dev/null
if [[ -n $variant ]]; then
  printf 'XKBVARIANT=%s\n' "$variant" | sudo tee -a "$vconsole" >/dev/null
fi
