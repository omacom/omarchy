echo "Keep Bluetooth mice and keyboards connected on Macs with UART Bluetooth"

# See bin/omarchy-bluetooth-hid-reconnect. The install-time fix only reaches
# machines set up after it shipped. Another user's run has already installed and
# enabled the service, so it is only started.
if ! omarchy-hw-apple-uart-bluetooth; then
  exit 0
fi

if [[ ! -e /etc/systemd/system/omarchy-bluetooth-hid-reconnect.service ]]; then
  sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
    source "$OMARCHY_PATH/install/hardware/apple/fix-uart-bluetooth-reconnect.sh"
  '
fi

sudo systemctl start omarchy-bluetooth-hid-reconnect.service
