echo "Switch pre-T2 Apple Mac hibernation to shutdown mode"

# Hibernate on pre-T2 Apple Macs writes the image but then reboots instead of
# powering off: systemd tries the platform (ACPI S4) mode first, which fails
# on this hardware. HibernateMode=shutdown uses the working power-off path
# instead, and resume still works from the swap signature on next boot.
# See install/hardware/apple/fix-pre-t2-hibernate.sh.
source "$OMARCHY_PATH/install/hardware/apple/fix-pre-t2-hibernate.sh"
