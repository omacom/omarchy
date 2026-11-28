echo "Match ASUS LampArray keyboards (Vivobook S16 and similar) to the theme"

if ! omarchy-hw-asus-lamparray-keyboard; then
  exit 0
fi

rule_source="$OMARCHY_PATH/default/udev/asus-lamparray-keyboard.rules"
rule_target=/etc/udev/rules.d/61-asus-lamparray-keyboard.rules
if [[ ! -f $rule_target ]] || ! cmp -s "$rule_source" "$rule_target"; then
  sudo install -Dm644 "$rule_source" "$rule_target"
  sudo udevadm control --reload-rules 2>/dev/null || true
  sudo udevadm trigger --subsystem-match=hidraw 2>/dev/null || true
fi

omarchy-theme-set-keyboard-asus-lamparray
