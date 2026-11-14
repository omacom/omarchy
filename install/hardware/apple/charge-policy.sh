# Install the Apple SMC optimized-charging unit on Apple Silicon. It is not
# enabled. Until somebody starts it, the kernel's own charge limits stay in
# effect. An existing unit is left alone so an administrator's copy survives.
# Existing machines get the same file from migrations/1792926166.sh.

omarchy-hw-aarch64-apple || return 0

unit_src="${OMARCHY_CHARGE_POLICY_UNIT_SRC:-$OMARCHY_PATH/default/systemd/system/omarchy-charge-policy.service}"
unit_dst="${OMARCHY_CHARGE_POLICY_UNIT_DST:-/etc/systemd/system/omarchy-charge-policy.service}"

if [[ -f $unit_src && ! -e $unit_dst ]]; then
  echo "Installing the Apple SMC charge policy unit without enabling it"
  sudo install -Dm644 "$unit_src" "$unit_dst"
fi
