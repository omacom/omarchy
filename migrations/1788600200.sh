echo "Cut MacBook10,1 S3 drain by disabling Wi-Fi wakeup"

# The fix is machine-wide, so a second user finds the service enabled and has nothing to escalate for.
if ! systemctl is-enabled --quiet omarchy-macbook10-sleep-drain.service 2>/dev/null; then
  source "$OMARCHY_PATH/install/hardware/apple/fix-macbook10-sleep-drain.sh"
fi
