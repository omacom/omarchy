# Hibernate on pre-T2 Apple Macs writes the image but then reboots instead of
# powering off: systemd tries the platform (ACPI S4) mode first, which fails
# on this hardware, while the shutdown power-off path works fine. Kernel docs
# recommend shutdown mode for machines whose platform S4 handling is broken,
# and resume still works from the swap signature on next boot.
# References:
# https://docs.kernel.org/power/basic-pm-debugging.html
# https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate
dmi_vendor="${OMARCHY_DMI_VENDOR:-/sys/class/dmi/id/sys_vendor}"
hibernate_conf="${OMARCHY_HIBERNATE_MODE_CONF:-/etc/systemd/sleep.conf.d/hibernatemode.conf}"

sys_vendor="$(cat "$dmi_vendor" 2>/dev/null || true)"

# Every T2 Mac carries the T2 PCI ID (same probe as fix-t2.sh); its absence on
# Apple hardware means a pre-T2 Intel Mac.
if [[ $sys_vendor == Apple* ]] && ! lspci -nn 2>/dev/null | grep -q "106b:180[12]"; then
  echo "Detected pre-T2 Apple Mac; switching hibernation to shutdown mode"

  if [[ -f $hibernate_conf ]] && grep -qx 'HibernateMode=shutdown' "$hibernate_conf"; then
    echo "Hibernation is already in shutdown mode"
  else
    sudo mkdir -p "$(dirname "$hibernate_conf")"
    sudo tee "$hibernate_conf" >/dev/null <<'EOF'
[Sleep]
HibernateMode=shutdown
EOF
  fi
fi
