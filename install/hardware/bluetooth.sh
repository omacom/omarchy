systemctl enable bluetooth.service

# Leave AutoEnable at its stock default. The graphical session restores the
# saved power preference without rfkill-blocking the radio, so other clients
# can still turn Bluetooth on through BlueZ.
