echo "Resume suspend on 2016-2017 MacBooks with Apple S3X NVMe"

product_name=$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)
[[ $product_name =~ MacBook(8,1|9,1|10,1)|MacBookPro13,[123]|MacBookPro14,[123] ]] || exit 0

source "$OMARCHY_PATH/install/hardware/apple/fix-suspend-nvme.sh"

# The boot parameters are installed only for the tested MacBookPro14,1.
# Other models in the installer match keep their current sleep mode.
[[ $product_name == MacBookPro14,1 ]] || exit 0

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

# omarchy-migrate runs this file with bash -euo pipefail. A failure on the left
# of && does not abort the script, so a failed rebuild would still be marked done.
if (( needs_rebuild )) && omarchy-cmd-present limine-mkinitcpio; then
  sudo limine-mkinitcpio
  omarchy-state set reboot-required
fi
