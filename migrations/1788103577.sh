echo "Keep T2 Mac USB-C ports awake after suspend"

if ! lspci -nn | grep "106b:180[12]" >/dev/null; then
  exit 0
fi

rule=/etc/udev/rules.d/99-omarchy-t2-usbc-hotplug.rules

# The Titan Ridge USB-C host controllers lose power in deep sleep and, once
# reinitialized on resume, no longer wake on hot-plug from runtime suspend.
# Holding them on keeps the ports usable after every sleep.
[[ -f $rule ]] || sudo install -Dm644 "$OMARCHY_PATH/default/udev/t2-usbc-hotplug.rules" "$rule"

# udev only applies the rule to new events, so replay one while any controller
# is still allowed to suspend. Once they are all on, another user's run is a no-op.
for controller in /sys/bus/pci/devices/*; do
  [[ $(cat "$controller/vendor" 2>/dev/null) == "0x8086" && $(cat "$controller/device" 2>/dev/null) == "0x15ec" ]] || continue
  [[ $(cat "$controller/power/control" 2>/dev/null) != "on" ]] || continue
  sudo udevadm control --reload
  sudo udevadm trigger --action=add --subsystem-match=pci \
    --attr-match=vendor=0x8086 --attr-match=device=0x15ec
  break
done
