echo "Unhide SSPM on the ASUS ProArt P16 H7607BA so its keyboard, touchpad and touchscreen power on"

# ASUS's P16 firmware hides \_SB.SSPM when Linux claims Windows 2022, which
# leaves the I2C keyboard, touchpad and touchscreen unpowered. New installs get
# this from install/hardware/n1x.sh, which also says why this laptop drops
# every Windows claim (acpi_osi=!) rather than only Windows 2022.
omarchy-hw-aarch64-n1x || exit 0
omarchy-hw-match "H7607BA" || exit 0

dropin=/etc/limine-entry-tool.d/00-omarchy-n1x-asus-osi.conf
boot_order=/etc/limine-entry-tool.d/zz-omarchy-n1x-boot-order.conf
rebuild_marker=/var/lib/omarchy/migrations/1792977100
param='acpi_osi=!'

sudo install -Dm644 /dev/stdin "$dropin" <<'EOF'
# ASUS ProArt P16 N1x: firmware hides SSPM from an OS that claims Windows 2022,
# which leaves the I2C keyboard, touchpad and touchscreen unpowered. Claim no
# Windows version at all, so ASUS's own version check still sees Windows 8 or
# later. See install/hardware/n1x.sh.
KERNEL_CMDLINE[default]+=" acpi_osi=!"
EOF

if [[ -f $boot_order ]] && ! grep -Fq "$param" "$boot_order"; then
  printf '%s\n' 'KERNEL_CMDLINE[fallback]+=" acpi_osi=!"' | sudo tee -a "$boot_order" >/dev/null
fi

# Machine-wide rebuild. Another user's run must not repeat it; a missing
# marker still retries an interrupted rebuild.
[[ ! -e $rebuild_marker ]] || exit 0

rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT
sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
# That kernel still boots without the parameter, so the migration stays
# pending. Where the menu is readable, also make sure an entry carries it.
if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

# acpi_osi=! has no quotes or spaces, so a plain word match finds it.
carries_param() {
  local words word
  read -ra words <<<"$1"
  for word in "${words[@]}"; do
    [[ $word == $param ]] && return 0
  done
  return 1
}

esp=""
if [[ -r /etc/default/limine ]]; then
  esp=$(sed -n 's/^ESP_PATH=["'\'']\?\([^"'\'']*\).*/\1/p' /etc/default/limine | tail -n 1)
fi
limine_conf="${esp:-/boot}/limine.conf"

built=0
menu_cmdlines=$(sudo grep -E '^[[:space:]]*cmdline:' "$limine_conf" 2>/dev/null) || menu_cmdlines=""
while IFS= read -r menu_cmdline; do
  [[ -n $menu_cmdline ]] || continue
  carries_param "${menu_cmdline#*cmdline:}" && built=1
done <<<"$menu_cmdlines"

# --get-cmdline reads the configuration, not the built menu: it tells a failed
# rebuild from a config that leaves the parameter out, which no rebuild changes.
if [[ -n $menu_cmdlines ]] && ((!built)); then
  configured=0
  for entry in linux-omarchy linux-omarchy-fallback; do
    kernel_cmdline=$(sudo limine-entry-tool --get-cmdline "$entry" 2>/dev/null | tail -n 1) || continue
    carries_param "$kernel_cmdline" && configured=1
  done

  if ((configured)); then
    echo "The boot image still has no entry with $param after the rebuild" >&2
    exit 1
  fi

  echo "The Limine kernel command line leaves out $param; use += rather than = in /etc/default/limine to keep it"
fi
sudo install -Dm644 /dev/null "$rebuild_marker"
