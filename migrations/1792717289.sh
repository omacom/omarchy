echo "Unhide SSPM on the Lenovo Pro 9 15N1X11 so the internal keyboard powers on"

# Lenovo firmware hides \_SB.SSPM when Linux claims Windows 2022, which leaves
# the I2C keyboard (LENC0001) unpowered. New installs get this from
# install/hardware/n1x.sh. Dell and ASUS N1x firmware do not need it.
omarchy-hw-aarch64-n1x || exit 0
omarchy-hw-match "15N1X11" || omarchy-hw-match "83SS" || exit 0

limine_conf_dir="/etc/limine-entry-tool.d"
dropin="$limine_conf_dir/00-omarchy-n1x-lenovo-osi.conf"
boot_order="$limine_conf_dir/zz-omarchy-n1x-boot-order.conf"
rebuild_marker="/var/lib/omarchy/migrations/1792717289"

sudo install -Dm644 /dev/stdin "$dropin" <<'EOF'
# Lenovo N1x: firmware hides SSPM from an OS that claims Windows 2022, which
# leaves the I2C keyboard unpowered. The inner quotes reach the kernel as
# written and keep Windows 2022 one parameter.
KERNEL_CMDLINE[default]+=" acpi_osi="!Windows 2022""
EOF

if [[ -f $boot_order ]] && ! grep -Fq 'acpi_osi="!Windows 2022"' "$boot_order"; then
  printf '%s\n' 'KERNEL_CMDLINE[fallback]+=" acpi_osi="!Windows 2022""' | sudo tee -a "$boot_order" >/dev/null
fi

# Machine-wide rebuild. Another user's run must not repeat it; a missing
# marker still retries an interrupted rebuild.
[[ ! -e $rebuild_marker ]] || exit 0
rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT
sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
# Leave the migration pending even if another entry carries the parameter
# or the built menu cannot be read.
if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

param='acpi_osi=!Windows 2022'
carries_param() {
  local cmdline=$1 word="" last="" quote="" char i
  for ((i = 0; i < ${#cmdline}; i++)); do
    char=${cmdline:i:1}
    if [[ -z $quote && ($char == '"' || $char == "'") ]]; then
      quote=$char
    elif [[ $char == $quote ]]; then
      quote=""
    elif [[ -z $quote && $' \t\n\r' == *$char* ]]; then
      [[ $word != ${param%%=*}=* ]] || last=$word
      word=""
    else
      word+=$char
    fi
  done
  [[ $word != ${param%%=*}=* ]] || last=$word
  [[ $last == $param ]]
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
