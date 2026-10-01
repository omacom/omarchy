echo "Remove hibernation setup on Apple T2 Macs: it can hang the machine mid-hibernate and needs a hard power-off (https://github.com/omacom/omarchy/issues/9237)"

if omarchy-hw-t2; then
  omarchy-hibernation-remove
fi
