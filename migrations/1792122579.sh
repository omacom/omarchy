echo "Stop asusd from switching the power profile and EPP on ASUS ROG laptops"

# etc/systemd/system/asusd.service.d/10-omarchy-power-profiles.conf turns these
# off at every asusd start. Apply them to the running asusd too, so the fix does
# not wait for a reboot. asusd's D-Bus policy lets wheel and users members set
# them without root, and asusd saves them in /etc/asusd/asusd.ron.
omarchy-hw-asus-rog || exit 0
systemctl is-active --quiet asusd.service || exit 0

asusd_platform=(xyz.ljones.Asusd /xyz/ljones xyz.ljones.Platform)

for property in ChangePlatformProfileOnAc ChangePlatformProfileOnBattery PlatformProfileLinkedEpp; do
  value=$(busctl --system get-property "${asusd_platform[@]}" "$property" 2>/dev/null || true)
  if [[ $value == "b true" ]]; then
    busctl --system set-property "${asusd_platform[@]}" "$property" b false ||
      echo "Could not turn off asusd $property now; it is turned off when asusd next starts"
  fi
done
