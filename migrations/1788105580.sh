echo "Stop a stuck PROCHOT from pinning T2 Macs at 800 MHz"

if ! lspci -nn | grep "106b:180[12]" >/dev/null; then
  exit 0
fi

unit="${OMARCHY_T2_PROCHOT_UNIT:-/etc/systemd/system/omarchy-t2-prochot.service}"

# The unit present and enabled is the completion state another user's run
# leaves; the file alone is what a run interrupted before enabling leaves.
if [[ -f $unit ]] && systemctl is-enabled --quiet omarchy-t2-prochot.service; then
  exit 0
fi

# The SMC can leave the external PROCHOT line asserted, which pins every core
# at its minimum frequency even though the CPU's own thermal status is clear.
# Clearing BD PROCHOT at boot and after each resume makes the CPU ignore it.
omarchy-pkg-add msr-tools
sudo install -Dm644 "$OMARCHY_PATH/default/systemd/system/omarchy-t2-prochot.service" "$unit"
sudo systemctl daemon-reload
sudo systemctl enable --now omarchy-t2-prochot.service
