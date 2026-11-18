echo "Resume suspend on 2016-2017 MacBooks with Apple S3X NVMe"

s3x_models='^MacBook9,1$\|^MacBook10,1$\|^MacBookPro13,[12]$\|^MacBookPro14,[12]$'
omarchy-hw-match "$s3x_models" || exit 0

# Install only the udev rule and, on the MacBookPro14,1, the boot drop-in.
# Sourcing the leaf would also rewrite and re-enable the older D3cold service.
# A file that already holds the setting is left alone, so a second user's run
# changes nothing, while one an interrupted run left empty or cut short is rewritten.
rule=/etc/udev/rules.d/99-omarchy-apple-nvme-d3cold.rules
if ! grep -qsF 'ATTR{device}=="0x2003", ATTR{d3cold_allowed}="0"' "$rule"; then
  sudo mkdir -p /etc/udev/rules.d
  sudo tee "$rule" >/dev/null <<'EOF'
# Keep the Apple S3X NVMe out of D3cold wherever it is enumerated.
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x106b", ATTR{device}=="0x2003", ATTR{d3cold_allowed}="0"
EOF
fi

# The boot parameters are installed only for the tested MacBookPro14,1.
# Other models in the installer match keep their current sleep mode.
omarchy-hw-match '^MacBookPro14,1$' || exit 0

drop_in=/etc/limine-entry-tool.d/apple-s3x-suspend.conf
if ! grep -qsF ' mem_sleep_default=s2idle nvme_core.default_ps_max_latency_us=0 intel_idle.max_cstate=1"' "$drop_in"; then
  sudo mkdir -p /etc/limine-entry-tool.d
  sudo tee "$drop_in" >/dev/null <<'EOF'
# Tested on MacBookPro14,1 only. intel_idle.max_cstate=1 raises idle power use.
KERNEL_CMDLINE[default]+=" mem_sleep_default=s2idle nvme_core.default_ps_max_latency_us=0 intel_idle.max_cstate=1"
EOF
fi

# Drop-ins are merged into the UKI command line by limine-mkinitcpio. Skip the
# rebuild when this boot already has the parameters.
if [[ -r /proc/cmdline ]]; then
  booted=$(</proc/cmdline)
else
  booted=""
fi

needs_rebuild=0
for param in mem_sleep_default=s2idle nvme_core.default_ps_max_latency_us=0 intel_idle.max_cstate=1; do
  [[ " $booted " == *" $param "* ]] || needs_rebuild=1
done

# Records the machine-wide rebuild, so another user's run before the reboot does
# not repeat it, while a missing marker still retries a failed rebuild.
rebuild_marker=/var/lib/omarchy/migrations/1791387391

if (( needs_rebuild )) && omarchy-cmd-present limine-mkinitcpio; then
  if [[ ! -e $rebuild_marker ]]; then
    rebuild_log=$(mktemp)
    trap 'rm -f "$rebuild_log"' EXIT
    sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

    # limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
    # That image lacks the suspend parameters, so the migration stays pending.
    if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
      echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
      exit 1
    fi

    sudo install -Dm644 /dev/null "$rebuild_marker"
  fi

  # The reboot notice is kept per user, so every user who updates before the reboot needs it.
  omarchy-state set reboot-required
fi
