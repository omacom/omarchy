# Disable hardware cursors when the machine will stay on nouveau.
#
# The nouveau DRM driver does not display the hardware cursor plane on many
# older NVIDIA GPUs, leaving the mouse pointer invisible under Hyprland.
# Skip the fix when the proprietary driver was configured: supported GPUs can
# still use nouveau during installation before switching drivers on reboot.
#
# Nouveau need not be bound while installing (an ISO booted with nomodeset or
# nouveau blacklisted), so fall back to the GPU itself when no driver is in use.
nvidia_config="${OMARCHY_NVIDIA_MODPROBE_CONFIG:-/etc/modprobe.d/nvidia.conf}"
nouveau_module="${OMARCHY_NOUVEAU_MODULE_PATH:-/sys/module/nouveau}"

using_or_stuck_on_nouveau() {
  # Already bound in this boot (live ISO / first session).
  [[ -d $nouveau_module ]] && return 0
  lsmod 2>/dev/null | awk '{ print $1 }' | grep -qx nouveau && return 0

  if omarchy-cmd-present lspci &&
    LC_ALL=C lspci -k 2>/dev/null | grep -qi 'Kernel driver in use: nouveau'; then
    return 0
  fi

  # Install-time fallback: nvidia.sh already ran and only writes nvidia.conf when
  # a proprietary driver will take over. An NVIDIA display device with no
  # nvidia.conf means this GPU stays on nouveau after reboot.
  if omarchy-cmd-present lspci &&
    LC_ALL=C lspci 2>/dev/null | grep -qiE 'VGA compatible controller: NVIDIA|3D controller: NVIDIA'; then
    return 0
  fi

  return 1
}

if [[ ! -f $nvidia_config ]] && using_or_stuck_on_nouveau; then
  looknfeel="$HOME/.config/hypr/looknfeel.lua"
  mkdir -p "$(dirname "$looknfeel")"

  # hyprland.lua always require()'s hypr.looknfeel. Seed the packaged stub if
  # user finalization ran before configs were copied, or the file was removed.
  if [[ ! -f $looknfeel ]]; then
    if [[ -f $OMARCHY_PATH/config/hypr/looknfeel.lua ]]; then
      cp "$OMARCHY_PATH/config/hypr/looknfeel.lua" "$looknfeel"
    else
      printf '%s\n' "-- User look and feel overrides." >"$looknfeel"
    fi
  fi

  if ! grep -q 'no_hardware_cursors' "$looknfeel"; then
    echo "Detected nouveau / unsupported NVIDIA GPU. Forcing software cursors so the mouse pointer stays visible."

    cat >>"$looknfeel" <<'LUA'

-- nouveau does not display the hardware cursor plane on many older NVIDIA GPUs,
-- leaving the pointer invisible on the physical display. Render it in software.
hl.config({
  cursor = {
    no_hardware_cursors = true,
  },
})
LUA
  fi
fi
