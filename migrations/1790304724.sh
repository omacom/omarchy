echo "Remove legacy NVIDIA driver overrides from upgraded user configs"

# 3.x installers appended these to envs.conf (earlier, hyprland.conf).
# The upgrade retains those files; also repair overrides ported to Lua.
# Packaged nvidia.lua now chooses the drivers on every login, including after
# switching GPU modes, so remove the old unconditional overrides on all GPUs.
conf_pattern='^[[:space:]]*env[[:space:]]*=[[:space:]]*(LIBVA_DRIVER_NAME|__GLX_VENDOR_LIBRARY_NAME)[[:space:]]*,[[:space:]]*nvidia[[:space:]]*$'
lua_pattern='^[[:space:]]*hl\.env\("(LIBVA_DRIVER_NAME|__GLX_VENDOR_LIBRARY_NAME)",[[:space:]]*"nvidia"\)[[:space:]]*$'
changed=0

for config in "$HOME"/.config/hypr/{envs,hyprland}.{conf,lua}; do
  [[ -f $config ]] || continue
  if grep -Eq -e "$conf_pattern" -e "$lua_pattern" "$config"; then
    backup="$config.omarchy-nvidia-hybrid.bak"
    [[ -e $backup ]] || cp -p "$config" "$backup"
    # Keep NVD_BACKEND, non-NVIDIA driver choices, and unrelated settings.
    sed -i --follow-symlinks -E -e "/$conf_pattern/d" -e "/$lua_pattern/d" "$config"
    changed=1
  fi
done

if (( changed )); then
  # Reloading does not clear variables inherited by the running session.
  omarchy-state set reboot-required
  echo "Reboot to apply the GPU-aware NVIDIA driver defaults."
fi
