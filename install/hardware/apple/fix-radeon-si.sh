# MacBookPro11,5's Venus XT dGPU is Southern Islands: both radeon and
# amdgpu claim it, and amdgpu's experimental SI support freezes these
# machines (hard hangs running normally, black screen on switcheroo OFF).
# Pin the arbitration to radeon, which binds cleanly and survives suspend
# cycles. Verified on MacBookPro11,5 with radeon 2.51.0; MacBookPro11,4
# carries the same dGPU and is the evident next candidate on field report.
dmi_product="${OMARCHY_DMI_PRODUCT:-/sys/class/dmi/id/product_name}"
limine_dir="${OMARCHY_LIMINE_ENTRY_TOOL_D:-/etc/limine-entry-tool.d}"
dropin="$limine_dir/radeon-si.conf"

product_name="$(cat "$dmi_product" 2>/dev/null || true)"

if [[ $product_name == "MacBookPro11,5" ]]; then
  echo "Detected MacBookPro11,5 dGPU; arbitrating Southern Islands to radeon"

  [[ -d $limine_dir ]] || sudo mkdir -p "$limine_dir"
  if [[ ! -f $dropin ]]; then
    sudo tee "$dropin" >/dev/null <<'EOF'
# MacBookPro11,5: Venus XT is Southern Islands; amdgpu's experimental SI
# support hangs these machines, so pin the arbitration to radeon.
KERNEL_CMDLINE[default]+=" radeon.si_support=1 amdgpu.si_support=0"
EOF
  fi
fi
