echo "Install the Apple SMC charge policy unit without enabling it"

# Existing machines never rerun hardware setup. Install only a missing unit
# so an administrator's copy survives an upgrade. Do not enable or start it:
# until somebody starts the unit, the kernel's own charge limits stay in effect.
# New installs take the same path in install/hardware/apple/charge-policy.sh.

omarchy-hw-aarch64-apple || exit 0

unit_src="${OMARCHY_CHARGE_POLICY_UNIT_SRC:-$OMARCHY_PATH/default/systemd/system/omarchy-charge-policy.service}"
unit_dst="${OMARCHY_CHARGE_POLICY_UNIT_DST:-/etc/systemd/system/omarchy-charge-policy.service}"

if [[ -f $unit_src && ! -e $unit_dst ]]; then
  echo "Installing the Apple SMC charge policy unit"
  sudo install -Dm644 "$unit_src" "$unit_dst"
fi
