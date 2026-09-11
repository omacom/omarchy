echo "Update T1 Mac suspend and PCIe hotplug defaults"

limine_conf="${OMARCHY_T1_LIMINE_CONF:-/etc/limine-entry-tool.d/macbook-t1.conf}"
running_cmdline="${OMARCHY_T1_RUNNING_CMDLINE:-/proc/cmdline}"
repair_marker="${OMARCHY_T1_REPAIR_MARKER:-/var/lib/omarchy/migrations/1788906000}"
needs_limine_rebuild=0

# T1 MacBook installs used pcie_ports=compat, which disables native PCIe
# hotplug and prevents Thunderbolt PCIe devices from appearing after attach.
# Match the suspend defaults already used by current T2 Mac installs.
if [[ -f $limine_conf ]] && grep -q 'pcie_ports=compat' "$limine_conf"; then
  sudo sed -i \
    's/pcie_ports=compat/pm_async=off mem_sleep_default=deep/' \
    "$limine_conf"
  needs_limine_rebuild=1
fi

# If the config was already repaired but a previous rebuild was interrupted,
# retry while the running kernel still lacks either replacement parameter. The
# marker prevents repeated rebuilds before the next reboot.
if [[ -f $limine_conf ]] &&
  [[ ! -e $repair_marker ]] &&
  grep -q 'pm_async=off' "$limine_conf" &&
  grep -q 'mem_sleep_default=deep' "$limine_conf" &&
  { [[ ! -r $running_cmdline ]] ||
    ! grep -Eq '(^| )pm_async=off( |$)' "$running_cmdline" ||
    ! grep -Eq '(^| )mem_sleep_default=deep( |$)' "$running_cmdline"; }; then
  needs_limine_rebuild=1
fi

if (( needs_limine_rebuild )); then
  sudo limine-mkinitcpio
  sudo install -Dm644 /dev/null "$repair_marker"
fi
