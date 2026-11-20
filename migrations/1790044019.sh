echo "Persist XKBLAYOUT for Latin keymaps so the LUKS prompt matches enrollment"

# Passphrases are typed under loadkeys during install/first-boot, but Plymouth
# reads XKBLAYOUT from the vconsole.conf bundled in the initramfs. A KEYMAP
# without XKBLAYOUT leaves that prompt on US QWERTY and locks the user out
# (#8196). Fill the missing XKB coordinates and rebuild when the layout is Latin.

source "$OMARCHY_PATH/install/helpers/keyboard-vconsole.sh"

[[ -f $(omarchy_vconsole_conf) ]] || exit 0

pending_dir="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy"
pending="$pending_dir/vconsole-xkb-pending-rebuild"
had_layout=$(omarchy_vconsole_get XKBLAYOUT)
# Record the rebuild before the file changes. A retry that sees XKBLAYOUT
# already filled would otherwise skip the UKI and mark the migration done.
if [[ -z $had_layout ]]; then
  mkdir -p "$pending_dir" || exit 1
  : >"$pending" || exit 1
fi

omarchy_ensure_vconsole_xkb
if [[ -z $had_layout && -z $(omarchy_vconsole_get XKBLAYOUT) ]]; then
  rm -f "$pending"
fi

layout=$(omarchy_vconsole_get XKBLAYOUT)
variant=$(omarchy_vconsole_get XKBVARIANT)
layout=${layout%%,*}
variant=${variant%%,*}
[[ -n $layout ]] || exit 0

# Non-Latin layouts must stay out of the initramfs (#6229); hooks already skip
# them. Only rebuild when a Latin layout (or Latin variant of rs) applies.
if omarchy_layout_is_non_latin "$layout" "$variant"; then
  rm -f "$pending"
  exit 0
fi

# A failed limine/mkinitcpio run must not mark this migration complete on retry
# when XKBLAYOUT is already set and CHANGED stays 0.
if (( OMARCHY_VCONSOLE_XKB_CHANGED == 1 )); then
  mkdir -p "$pending_dir" || exit 1
  : >"$pending" || exit 1
fi

[[ -f $pending ]] || exit 0

if omarchy-cmd-present limine-mkinitcpio; then
  sudo limine-mkinitcpio
elif omarchy-cmd-present limine-update; then
  sudo limine-update
else
  echo "No limine rebuild command available; leaving pending rebuild flag." >&2
  exit 1
fi

rm -f "$pending"
