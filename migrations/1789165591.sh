echo "Arbitrate MacBookPro11,5 dGPU to radeon"

# See install/hardware/apple/fix-radeon-si.sh: amdgpu's experimental SI
# support hangs these machines, so pin Southern Islands to radeon. The flags
# only take effect in a rebuilt boot image, which is also what applies them
# on fresh installs, so rebuild here -- but only when this run changed the
# drop-in, and only ask for the reboot then.
dmi_product="${OMARCHY_DMI_PRODUCT:-/sys/class/dmi/id/product_name}"
limine_dir="${OMARCHY_LIMINE_ENTRY_TOOL_D:-/etc/limine-entry-tool.d}"
dropin="$limine_dir/radeon-si.conf"

product_name="$(cat "$dmi_product" 2>/dev/null || true)"
[[ $product_name == "MacBookPro11,5" ]] || exit 0

before=""
[[ -f $dropin ]] && before=$(md5sum <"$dropin" 2>/dev/null || true)

source "$OMARCHY_PATH/install/hardware/apple/fix-radeon-si.sh"

after=""
[[ -f $dropin ]] && after=$(md5sum <"$dropin" 2>/dev/null || true)

if [[ -n $after && $before != "$after" ]]; then
  if omarchy-cmd-present limine-mkinitcpio; then
    sudo limine-mkinitcpio
  fi
  omarchy-state set reboot-required
fi
