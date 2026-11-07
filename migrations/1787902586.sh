echo "Remove legacy SDDM Hyprland config and stale pacsave files"

# SDDM loads all files in /etc/sddm.conf.d/ in alphabetical order. If a stale
# 10-wayland.conf.pacsave exists from a pacman upgrade, it sorts after
# 10-wayland.conf, overriding the Lua configuration and forcing the old
# hyprland.conf format which triggers Hyprland's deprecation banner.
pacsave=/etc/sddm.conf.d/10-wayland.conf.pacsave
legacy_config=/usr/share/sddm/hyprland.conf
legacy_wayland_conf=$'[General]\nDisplayServer=wayland\n\n[Wayland]\nCompositorCommand=start-hyprland -- --config /usr/share/sddm/hyprland.conf'

if [[ -f $pacsave && ! -L $pacsave && $(<"$pacsave") == "$legacy_wayland_conf" ]]; then
  sudo rm -f "$pacsave"
fi

# Hyprland will not start on a missing config, so keep it while anything SDDM reads still names it.
if [[ -f $legacy_config && ! -L $legacy_config ]] &&
  [[ $(sha256sum "$legacy_config" | cut -d' ' -f1) == "73bdfb956a679d2b26cc3773ed7865a7202e90694a5a2b6e1ca0ca7d4731097a" ]] &&
  ! grep -rqsF "$legacy_config" /etc/sddm.conf /etc/sddm.conf.d /usr/lib/sddm/sddm.conf.d; then
  sudo rm -f "$legacy_config"
fi
