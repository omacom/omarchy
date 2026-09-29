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

# The gap table and the vconsole.conf assignment rules, shared with the
# installer. The readers here (default/hypr/input.lua, default/sddm/
# hyprland.lua) skip leading whitespace on an assignment and take the last
# one, so an indented XKBLAYOUT counts — writes must accept the same shape or
# a guarded variable gets duplicated instead of replaced.
source "$OMARCHY_PATH/install/provisioning/setup-form.sh"

vconsole_value() {
  omarchy_vconsole_value "$1" "$vconsole"
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
if [[ -z $layout ]]; then
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

# A variant left by the keymap this replaces must not survive the new layout:
# the readers take the last assignment, so an old variant appended under
# would silently reshape the new keys. An empty XKBLAYOUT= goes with it, so
# the layout is replaced rather than repeated. Drop them first, then append.
# Each step is guarded by the next run's checks — a cancelled sudo prompt
# leaves either the original file or a layout-less one, and the retry's
# XKBLAYOUT guard still re-derives and rewrites instead of marking the
# migration complete.
if grep -q '^[[:space:]]*XKB\(LAYOUT\|VARIANT\)[[:space:]]*=' "$vconsole"; then
  sudo sed -i '/^[[:space:]]*XKB\(LAYOUT\|VARIANT\)[[:space:]]*=/d' "$vconsole"
fi
payload="XKBLAYOUT=$layout"
if [[ -n $variant ]]; then
  payload+=$'\nXKBVARIANT='"$variant"
fi
printf '%s\n' "$payload" | sudo tee -a "$vconsole" >/dev/null
