# The Marvell Wi-Fi firmware is for x86 Surfaces only; Snapdragon Surfaces use Qualcomm Wi-Fi.
if omarchy-hw-surface && [[ $(uname -m) == "x86_64" ]]; then
  omarchy-pkg-add linux-firmware-marvell
fi
