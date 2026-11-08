echo "Keep the firmware's USB4 display link on AMD machines"

# See install/hardware/amd/thunderbolt-host-reset.sh.
drop_in=/etc/limine-entry-tool.d/amd-thunderbolt.conf
param=thunderbolt.host_reset=0

omarchy-hw-amd || exit 0

if [[ ! -f $drop_in ]]; then
  sudo mkdir -p /etc/limine-entry-tool.d
  cat <<EOF | sudo tee "$drop_in" >/dev/null
# AMD: keep the firmware's USB4 display link at boot
KERNEL_CMDLINE[default]+=" $param"
EOF
fi

# The boot image holds the command line until it is rebuilt. Checking the
# running kernel rather than whether the drop-in was just written retries a
# rebuild that was interrupted.
if [[ " $(</proc/cmdline) " != *" $param "* ]]; then
  sudo limine-mkinitcpio
fi
