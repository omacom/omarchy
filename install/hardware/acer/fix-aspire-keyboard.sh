# Keyboard fix for Acer Aspire Go 15 laptops.
#
# The internal keyboard drops out ~5 seconds post-boot on Linux kernels
# due to an i8042 / atkbd ACPI conflict with acer-wmi. Adding i8042.reset,
# atkbd.reset, and acpi_osi=Linux to the kernel cmdline keeps the controller
# responsive.

limine_dropin="${OMARCHY_ACER_ASPIRE_LIMINE_CONF:-/etc/limine-entry-tool.d/acer-aspire-keyboard.conf}"

if omarchy-hw-acer-aspire-go-15; then
  sudo mkdir -p "$(dirname "$limine_dropin")"
  sudo tee "$limine_dropin" >/dev/null <<'EOF'
# Acer Aspire Go 15 internal keyboard fix
KERNEL_CMDLINE[default]+=" i8042.reset atkbd.reset acpi_osi=Linux"
EOF
fi
