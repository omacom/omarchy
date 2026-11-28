# Sleep on the 15-inch 2017 MacBook Pro (MacBookPro14,3).
#
# The Radeon drives the internal panel and cannot reload its SMU firmware after
# S3 (amdgpu_device_ip_resume fails with -22), so deep sleep resumes to a black
# screen. s2idle keeps the GPU powered and resumes. It needs the linux-omarchy
# s2idle fixes for the BCM43602 Wi-Fi, the Alpine Ridge host router and ACPI
# resume time (omarchy-pkgs #596 and #544); without them resume stalls for a
# minute and loses Wi-Fi and Thunderbolt. The T1 (05ac:8600) wakes the machine
# within minutes of s2idle, so it may not.
#
# Tested on MacBookPro14,3 only. MacBookPro13,3 has the same Radeon-on-panel
# design; widen the match after the same suspend test.
product_name=$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)

if [[ $product_name == MacBookPro14,3 ]]; then
  echo "Detected MacBook model: $product_name"

  sudo mkdir -p /etc/limine-entry-tool.d
  sudo tee /etc/limine-entry-tool.d/apple-radeon-s2idle.conf >/dev/null <<'CONF'
# MacBookPro14,3: S3 cannot resume the Radeon that drives the panel.
KERNEL_CMDLINE[default]+=" mem_sleep_default=s2idle button.lid_init_state=open"
CONF

  sudo mkdir -p /etc/udev/rules.d
  sudo tee /etc/udev/rules.d/99-omarchy-apple-t1-nowake.rules >/dev/null <<'RULES'
# The T1 raises spurious wakes during s2idle; the lid and keyboard still wake the machine.
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="05ac", ATTR{idProduct}=="8600", ATTR{power/wakeup}="disabled"
RULES
fi
