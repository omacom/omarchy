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
hooks_conf="${OMARCHY_HOOKS_CONF:-/etc/mkinitcpio.conf.d/omarchy_hooks.conf}"

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
# separated by runs of tabs used for alignment, so split on tab runs and read
# the logical columns: layout in field 2, variant in field 4 (`-` when there
# is none). Fixed positions would hand back alignment padding or the model —
# is-latin1's row would surface as pc105. Keep the first entry of
# comma-separated lists: the session and greeter prepend "us" to non-Latin
# layouts themselves.
if [[ -f $kbd_map ]]; then
  map_row=$(awk -F'\t+' -v key="$keymap" '$1 == key { print $2 "\t" $4; exit }' "$kbd_map") || map_row=""
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

# A non-Latin layout must not reach the initramfs: bundling vconsole.conf
# makes Plymouth apply the layout at the LUKS prompt, and a passphrase is
# Latin. migrations/1784476564.sh removed exactly this bundling, but it no-ops
# when vconsole.conf carries no XKBLAYOUT — the shape every install this
# migration repairs is in — so its repair may still be pending here. Remove
# the bundling and rebuild before the layout below lands, or the next UKI
# rebuild would reintroduce the lockout that migration exists to prevent.
# Ordered before the write, so a cancelled sudo leaves the migration pending
# with nothing applied rather than marked complete mid-repair.
if [[ $layout =~ ^(af|am|ara|bd|bg|by|et|ge|gr|il|in|iq|ir|kg|kh|kz|la|lk|mk|mm|mn|mv|np|rs|ru|sy|th|tj|ua)$ ]] &&
  [[ -f $hooks_conf ]] && grep -Eq '^#?FILES\+=\(/etc/vconsole.conf\)$' "$hooks_conf"; then
  # Disable the line first, because mkinitcpio sources this file during the
  # rebuild itself. Only a successful rebuild drops it: limine-mkinitcpio
  # failing leaves the line disabled, so the migration exits non-zero and the
  # retry's guard still matches and rebuilds, instead of finding the line gone
  # and completing while the old UKI still bundles the unsafe vconsole.conf.
  sudo sed -i 's|^FILES+=(/etc/vconsole.conf)$|#FILES+=(/etc/vconsole.conf)|' "$hooks_conf"
  if omarchy-cmd-present limine-mkinitcpio; then
    if sudo limine-mkinitcpio; then
      sudo sed -i '\|^#FILES+=(/etc/vconsole.conf)$|d' "$hooks_conf"
    else
      exit 1
    fi
  fi
fi

# One write, so a failure (a cancelled sudo prompt, say) leaves nothing
# half-applied for a retry's XKBLAYOUT guard to treat as complete.
payload="XKBLAYOUT=$layout"
if [[ -n $variant ]]; then
  payload+=$'\nXKBVARIANT='"$variant"
fi
printf '%s\n' "$payload" | sudo tee -a "$vconsole" >/dev/null
