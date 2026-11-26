echo "Move Anduril BlueChip camera relay and tunings to userland (omarchy-camera-tuning)"

if ! omarchy-camera-tuning match >/dev/null 2>&1 || ! omarchy-pkg-present anduril-bluechip-support; then
  exit 0
fi

# Stop the legacy system relay/guard units before disabling them: omarchy-update
# upgrades packages before running migrations, so anduril-bluechip-support 1-7
# may have already deleted the unit files (making `disable --now` fail before
# stopping a still-running daemon).
sudo systemctl stop v4l2-relayd@bluechip.service bluechip-camera-guard.service 2>/dev/null || true
sudo systemctl disable v4l2-relayd@bluechip.service bluechip-camera-guard.service 2>/dev/null || true

# If an older anduril-bluechip-support (< 1-7) is still installed, mask the
# legacy units so vendor symlinks and v4l2-relayd's generator cannot restart
# them on the next boot alongside the userland relay.
pkg_ver=$(pacman -Q anduril-bluechip-support 2>/dev/null | awk '{print $2}')
if [[ -n $pkg_ver ]] && (( $(vercmp "$pkg_ver" 1-7) < 0 )); then
  sudo systemctl mask v4l2-relayd@bluechip.service bluechip-camera-guard.service 2>/dev/null || true
fi
sudo systemctl daemon-reload 2>/dev/null || true

# Carry over any user-customized gamma/contrast/saturation values from the old
# /etc/v4l2-relayd.d/bluechip.conf (or its .pacsave) into ~/.config/omarchy/camera.conf.
override_file="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/camera.conf"
if [[ ! -e $override_file ]]; then
  for legacy in /etc/v4l2-relayd.d/bluechip.conf.pacsave /etc/v4l2-relayd.d/bluechip.conf; do
    [[ -r $legacy ]] || continue
    line=$(grep -E '^VIDEOSRC=' "$legacy" | head -n1 || true)
    [[ -n $line ]] || continue
    overrides=()
    for key in gamma contrast saturation; do
      if [[ $line =~ [[:space:]]${key}=([0-9]+(\.[0-9]+)?) ]]; then
        overrides+=("${key}=${BASH_REMATCH[1]}")
      fi
    done
    if ((${#overrides[@]})); then
      mkdir -p "$(dirname "$override_file")"
      printf '%s\n' "${overrides[@]}" >"$override_file"
    fi
    break
  done
fi

if ! omarchy-camera-tuning on; then
  echo "Camera tuning not applied yet. After logging in, run: omarchy camera tuning on" >&2
  exit 1
fi
