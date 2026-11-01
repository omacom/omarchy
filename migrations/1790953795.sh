echo "Give the ASUS ProArt P14 (NVIDIA N1x) the RAM its firmware reserves for Windows' GPU"

# See install/hardware/asus/fix-asus-proart-p14-gpu-memory.sh. The kernel option
# takes effect with linux-omarchy-n1x; older N1x kernels ignore it.
dropin="${OMARCHY_PROART_GPU_MEMORY_CONF:-/etc/limine-entry-tool.d/omarchy-n1x-gpu-memory.conf}"
iomem="${OMARCHY_IOMEM:-/proc/iomem}"
running_cmdline="${OMARCHY_RUNNING_CMDLINE:-/proc/cmdline}"
rebuild_marker="${OMARCHY_LIMINE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1790953795}"

if ! omarchy-hw-match "H7407BA"; then
  exit 0
fi

if [[ ! -f $dropin ]]; then
  # /proc/iomem only shows addresses to root.
  sudo grep -qx '1fd000000-119fffffff : reserved' "$iomem" || exit 0

  sudo install -Dm644 /dev/stdin "$dropin" <<'EOF'
# ASUS ProArt P14: use the idle part of the firmware's Windows GPU memory as RAM;
# see install/hardware/asus/fix-asus-proart-p14-gpu-memory.sh.
KERNEL_CMDLINE[default]+=" efi_reclaim_reserved=58G@8G,3968M@67712M"
EOF
fi

# The running kernel keeps its command line until reboot, so a marker records
# the machine-wide rebuild: another user's run must not repeat it, while a
# missing marker still retries an interrupted rebuild.
[[ ! -e $rebuild_marker ]] || exit 0
[[ " $(<"$running_cmdline") " != *" efi_reclaim_reserved="* ]] || exit 0

sudo limine-mkinitcpio
sudo install -Dm644 /dev/null "$rebuild_marker"
