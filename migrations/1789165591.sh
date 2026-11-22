echo "Arbitrate MacBookPro11,5 dGPU to radeon"

# See install/hardware/apple/fix-radeon-si.sh: amdgpu's experimental SI
# support hangs these machines, so pin Southern Islands to radeon. The flags
# only take effect in a rebuilt boot image, which is also what applies them
# on fresh installs, so rebuild here and ask for the reboot. A machine-wide
# marker records the rebuild, so another user's run does not repeat it while
# an interrupted or failed rebuild is still retried.
dmi_product="${OMARCHY_DMI_PRODUCT:-/sys/class/dmi/id/product_name}"
limine_dir="${OMARCHY_LIMINE_ENTRY_TOOL_D:-/etc/limine-entry-tool.d}"
dropin="$limine_dir/radeon-si.conf"
rebuild_marker="${OMARCHY_LIMINE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1789165591}"

product_name="$(cat "$dmi_product" 2>/dev/null || true)"
[[ $product_name == "MacBookPro11,5" ]] || exit 0

source "$OMARCHY_PATH/install/hardware/apple/fix-radeon-si.sh"

if [[ -f $dropin && ! -e $rebuild_marker ]]; then
  if omarchy-cmd-present limine-mkinitcpio; then
    sudo limine-mkinitcpio
  fi
  sudo install -Dm644 /dev/null "$rebuild_marker"
  omarchy-state set reboot-required
fi
