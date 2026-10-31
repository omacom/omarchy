# Ignore lid events on Razer Blade laptops with broken EC/ACPI firmware.
#
# Razer Blade laptops (verified on the Blade 15 Base Model (Late 2020),
# RZ09-03519) ship with EC/ACPI firmware whose wake handshake is broken: the
# DSDT's wake methods reference a "VRTC" SystemCMOS region the kernel has no
# handler for, so \_SB.PCI0.LPCB.EC0.RTEC and the \RWAK/\_WAK wake path abort
# on every sleep cycle (xhci_hcd "xHC error in resume, USBSTS 0x401"). After
# an S3 resume the lid button state is stuck at "closed", so logind thinks
# the lid is closed even when it is open, re-suspends seconds after the lid
# opens, and omarchy-sleep-lock's pre-suspend lock restarts in a loop. The
# only functional wake source is the EC scope, which fires erratically (a
# spurious wake roughly every 35 seconds, or none at all). Razer has never
# published a BIOS or EC update for the affected models, and Razer's own
# support article documents the symptom across the Blade line. The defect is
# in the vendor firmware, not in the OS.
#
# logind's default (sleep on lid close) turns that broken flow into a
# machine that never actually sleeps and never wakes on schedule. Ignoring
# the lid events instead makes the experience stable: closing the lid
# switches the display off with the machine still running, and opening it
# brings everything back. Users who want true sleep use the power menu with
# the lid open; on battery, shutting down is the reliable option. See
# https://github.com/omacom/omarchy/issues/15649.

sys_vendor="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || true)"
product_name="$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)"

if [[ $sys_vendor == Razer* && $product_name == *Blade* ]]; then
  mkdir -p /etc/systemd/logind.conf.d
  cat > /etc/systemd/logind.conf.d/30-razer-lid-ignore.conf <<'EOF'
# Razer Blade laptops: the EC/ACPI firmware breaks the lid -> sleep path
# (stale lid state after resume, erratic EC wakes), and logind's default of
# sleeping on lid close turns that into a re-suspend loop with the lid open.
# Ignore lid events: the display switches off with the lid closed, the
# machine keeps running, and opening the lid reliably brings the display
# back. See https://github.com/omacom/omarchy/issues/15649
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
EOF
fi
