echo "Disable broken eDP Panel Replay on Dell XPS Panther Lake systems"

DROP_IN="/etc/limine-entry-tool.d/dell-xps-ptl-panel-replay.conf"

# New installs get this from install/hardware/intel/fix-dell-xps-ptl-panel-replay.sh.
# Systems that predate that hook live with the Panel Replay interrupt storm
# (~6000 xe IRQs/s, GT pinned awake, roughly half the battery life they should
# get), so retrofit the drop-in here. Second and later users skip the write.
if omarchy-hw-match "XPS" && omarchy-hw-intel-ptl; then
  if [[ ! -f $DROP_IN ]]; then
    sudo mkdir -p /etc/limine-entry-tool.d
    cat <<'EOF' | sudo tee "$DROP_IN" >/dev/null
# Dell XPS Panther Lake eDP Panel Replay workaround
KERNEL_CMDLINE[default]+=" xe.enable_panel_replay=0"
EOF
  fi

  panel_replay_rebuild_marker="/var/lib/omarchy/migrations/1789006054"

  # Record a successful machine-wide rebuild so other users do not repeat it.
  if [[ ! -e $panel_replay_rebuild_marker ]]; then
    if ! panel_replay_rebuild_output=$(sudo limine-mkinitcpio 2>&1); then
      printf '%s\n' "$panel_replay_rebuild_output" >&2
      exit 1
    fi
    printf '%s\n' "$panel_replay_rebuild_output"

    # Limine reports per-kernel build errors on stderr but can still exit zero.
    if [[ $panel_replay_rebuild_output == *"ERROR:"* ]]; then
      exit 1
    fi
    sudo install -Dm644 /dev/null "$panel_replay_rebuild_marker"
  fi

  if [[ " $(</proc/cmdline) " != *" xe.enable_panel_replay=0 "* ]]; then
    omarchy-state set reboot-required
  fi
fi
