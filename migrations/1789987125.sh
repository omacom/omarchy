echo "Install bluez-obex for Bluetooth file receiving"

# obexd carries the Object Push profile the Bluetooth panel's file switch
# drives. It is a base package now, but installs that predate it need it
# pulled in before the unit can start.
omarchy-pkg-add bluez-obex
