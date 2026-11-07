echo "Keep the T2 internal keyboard in the linux-t2 initramfs"

# The installer writes zz-omarchy-kernel-modules.conf with every module any
# installed kernel lacks, then removes those names while building every
# kernel. linux-omarchy has no t2bce_vhci, so the linux-t2 image lost it and
# the internal keyboard could not enter the LUKS passphrase.
# etc/mkinitcpio.conf.d/zz-omarchy-t2-keyboard.conf puts those modules back
# when the kernel being built ships them. This rewrites a filter the installer
# already wrote so the filter itself keeps a module that kernel ships, then
# rebuilds the boot image once.

filter="${OMARCHY_INITRAMFS_MODULES_CONF:-/etc/mkinitcpio.conf.d/zz-omarchy-kernel-modules.conf}"
marker="${OMARCHY_T2_KEYBOARD_INITRAMFS_MARKER:-/var/lib/omarchy/migrations/1794052134}"
boot_images="${OMARCHY_T2_BOOT_IMAGES:-/boot/EFI/Linux:/efi/EFI/Linux}"

[[ -f $filter ]] || exit 0
[[ ! -e $marker ]] || exit 0
grep -Eq '(^|[[:space:](])t2bce_vhci([[:space:])]|$)' "$filter" || exit 0

# The generated file is one assignment plus an unconditional drop. Anything
# else was edited after install and is left as it is; the later drop-in still
# restores the keyboard modules on the rebuild below.
unconditional='  [[ " ${_omarchy_absent[*]} " == *" $_omarchy_module "* ]] || _omarchy_kept+=("$_omarchy_module")'
if [[ $(head -n 1 "$filter") == "# Written by the Omarchy installer. The installed kernel has no such" ]] &&
  grep -Fxq "$unconditional" "$filter"; then
  absent_line=$(grep -E '^_omarchy_absent=\([A-Za-z0-9_-]+( [A-Za-z0-9_-]+)*\)$' "$filter") || true
  absent=${absent_line#'_omarchy_absent=('}
  absent=${absent%')'}
  if [[ $absent_line == _omarchy_absent=\(*\) && " $absent " == *" t2bce_vhci "* ]]; then
    rewritten=$(mktemp)
    cat >"$rewritten" <<'EOF'
# Written by the Omarchy installer. A module is left out only when the kernel
# being built does not ship it, so mkinitcpio does not fail on a missing name
# and linux-t2 keeps t2bce_vhci for the internal keyboard.
_omarchy_absent=(@ABSENT@)
_omarchy_kept=()
for _omarchy_module in "${MODULES[@]}"; do
  if [[ " ${_omarchy_absent[*]} " == *" $_omarchy_module "* ]] &&
    [[ $(modinfo -k "${KERNELVERSION:-$(uname -r)}" -F filename "$_omarchy_module" 2>/dev/null) != /* ]]; then
    continue
  fi
  _omarchy_kept+=("$_omarchy_module")
done
MODULES=("${_omarchy_kept[@]}")
unset _omarchy_absent _omarchy_kept _omarchy_module
EOF
    sed -i "s/@ABSENT@/${absent}/" "$rewritten"
    sudo cp "$rewritten" "$filter"
    sudo chmod 644 "$filter"
    rm -f "$rewritten"
  fi
fi

if ! omarchy-cmd-present limine-mkinitcpio; then
  echo "limine-mkinitcpio is not installed; the T2 boot image was not rebuilt" >&2
  exit 1
fi

echo "The installer filter was dropping t2bce_vhci from linux-t2; rebuilding the boot image"
sudo limine-mkinitcpio

# limine-mkinitcpio can return success after skipping a kernel it could not
# build. When a linux-t2 image is there, done means that image carries
# t2bce_vhci. A machine whose boot files live somewhere else has nothing to
# inspect and is taken at the rebuild's word.
if omarchy-cmd-present lsinitcpio; then
  IFS=':' read -r -a boot_dirs <<<"$boot_images"
  found=0
  present=0
  for dir in "${boot_dirs[@]}"; do
    [[ -n $dir && -d $dir ]] || continue
    for uki in "$dir"/*linux-t2*.efi; do
      [[ -f $uki ]] || continue
      found=1
      listing=$(sudo lsinitcpio "$uki") || continue
      if [[ $listing == *t2bce_vhci* ]]; then
        present=1
      fi
    done
  done
  if (( found && !present )); then
    echo "The linux-t2 boot image still has no t2bce_vhci after the rebuild" >&2
    exit 1
  fi
fi

sudo install -Dm644 /dev/null "$marker"
