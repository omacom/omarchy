echo "Install T2 Broadcom Wi-Fi firmware when macOS left none behind"

# Exit 1 from --check means this machine does not need the firmware. Any other
# failure must stay pending instead of being recorded as finished.
set +e
omarchy-hw-t2-wifi --check
check_status=$?
set -e

if (( check_status == 1 )); then
  exit 0
fi
if (( check_status != 0 )); then
  echo "Could not decide whether this Mac needs T2 Wi-Fi firmware" >&2
  exit "$check_status"
fi

if (( EUID == 0 )); then
  omarchy-hw-t2-wifi
else
  sudo omarchy-hw-t2-wifi
fi
