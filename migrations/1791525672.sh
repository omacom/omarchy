echo "Sleep in s2idle on the MacBookPro14,3, where S3 cannot resume the Radeon"

product_name=$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)
[[ $product_name == MacBookPro14,3 ]] || exit 0

source "$OMARCHY_PATH/install/hardware/apple/fix-suspend-radeon.sh"

# Drop-ins are merged into the UKI command line by limine-mkinitcpio. Skip the
# rebuild when this boot already has the parameters.
if [[ -r /proc/cmdline ]]; then
  booted=$(</proc/cmdline)
else
  booted=""
fi

needs_rebuild=0
for param in mem_sleep_default=s2idle button.lid_init_state=open; do
  [[ " $booted " == *" $param "* ]] || needs_rebuild=1
done

if (( needs_rebuild )) && omarchy-cmd-present limine-mkinitcpio; then
  sudo limine-mkinitcpio
  omarchy-state set reboot-required
fi
