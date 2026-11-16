# The Marvell Wi-Fi firmware is for x86 Surfaces only; Snapdragon Surfaces use Qualcomm Wi-Fi.
if omarchy-hw-surface && omarchy-hw-x86; then
  omarchy-pkg-add linux-firmware-marvell
fi
