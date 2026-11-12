echo "Stop a stuck PROCHOT from pinning T2 Macs at 800 MHz"

if ! lspci -nn | grep "106b:180[12]" >/dev/null; then
  exit 0
fi

unit=/etc/systemd/system/omarchy-t2-prochot.service

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
sudo systemctl enable omarchy-t2-prochot.service

# Installing and enabling the override is what this migration owes. Clearing
# the line right away is a bonus: the unit runs again at every boot and resume,
# and on a kernel that refuses MSR writes (lockdown) it can never succeed, which
# must not hold back the migrations after this one.
sudo systemctl start omarchy-t2-prochot.service ||
  echo "Could not clear PROCHOT right now; the override runs again at the next boot and resume"
