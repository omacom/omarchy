echo "Keep T2 Mac USB-C ports awake after suspend"

if ! lspci -nn | grep "106b:180[12]" >/dev/null; then
  exit 0
fi

rule="${OMARCHY_T2_USBC_RULE:-/etc/udev/rules.d/99-omarchy-t2-usbc-hotplug.rules}"

# The Titan Ridge USB-C host controllers lose power in deep sleep and, once
# reinitialized on resume, no longer wake on hot-plug from runtime suspend.
# Holding them on keeps the ports usable after every sleep. Only the copy is
# skipped when the rule is already in place: a run that failed after copying
# it still owes the reload and the trigger, and both are harmless to repeat.
[[ -f $rule ]] || sudo install -Dm644 "$OMARCHY_PATH/default/udev/t2-usbc-hotplug.rules" "$rule"
sudo udevadm control --reload
sudo udevadm trigger --action=add --subsystem-match=pci \
  --attr-match=vendor=0x8086 --attr-match=device=0x15ec
