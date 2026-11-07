# Chuwi MiniBook X: keep the keyboard and touchpad from waking it.
#
# Folded into a tablet, the keyboard and touchpad face outward, and both are
# armed as wake sources, so a key or a touch in a bag wakes the laptop. Leave
# waking to the lid switch and the power button.

rules_dir=${OMARCHY_MINIBOOK_X_RULES_DIR:-/etc/udev/rules.d}

if omarchy-hw-chuwi-minibook-x; then
  mkdir -p "$rules_dir"
  cat >"$rules_dir/61-omarchy-chuwi-minibook-x-wakeup.rules" <<'RULES'
# Chuwi MiniBook X: the keyboard and touchpad face outward in tablet mode; see
# install/hardware/chuwi/fix-minibook-x-wake.sh.
ACTION=="add", SUBSYSTEM=="i2c", KERNEL=="i2c-XXXX0000:05", ATTR{power/wakeup}="disabled"
ACTION=="add", SUBSYSTEM=="serio", KERNEL=="serio0", ATTR{power/wakeup}="disabled"
RULES
fi
