echo "Boot N1x laptops quietly so Plymouth stays up from the LUKS prompt to login"

# Early N1x installs added loglevel=7, systemd.show_status=1 and friends to the
# default boot entry for bring-up. They come after Omarchy's quiet splash on the
# command line and win, so kernel and systemd messages print over Plymouth after
# unlocking and during shutdown. The rescue entry keeps its own verbose line.
console_conf="${OMARCHY_N1X_CONSOLE_CONF:-/etc/limine-entry-tool.d/00-omarchy-n1x-console.conf}"
running_cmdline="${OMARCHY_RUNNING_CMDLINE:-/proc/cmdline}"
rebuild_marker="${OMARCHY_LIMINE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1790917773}"

[[ -f $console_conf ]] || exit 0

if grep -Fq 'loglevel=7' "$console_conf"; then
  sudo tee "$console_conf" >/dev/null <<'EOF'
# N1x: keep the console on the panel rather than the firmware's serial port;
# see install/hardware/n1x.sh.
KERNEL_CMDLINE[default]+=" console=tty0 acpi=nospcr"
EOF
fi

# The running kernel keeps the verbose command line until reboot, so a marker
# records the machine-wide rebuild: another user's run must not repeat it, while
# a missing marker still retries an interrupted rebuild.
[[ ! -e $rebuild_marker ]] || exit 0
[[ " $(<"$running_cmdline") " == *" rd.udev.log_level=info "* ]] || exit 0

sudo limine-mkinitcpio
sudo install -Dm644 /dev/null "$rebuild_marker"
