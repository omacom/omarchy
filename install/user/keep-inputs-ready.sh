# Let applications keep microphones ready while they run, instead of waiting for
# the device to wake on every recording. WirePlumber loads the replacement suspend
# hook from its user script directory, so link it there to follow Omarchy updates.
mkdir -p ~/.local/share/wireplumber/scripts ~/.config/wireplumber/wireplumber.conf.d
ln -sfn "$OMARCHY_PATH/default/wireplumber/scripts/omarchy" ~/.local/share/wireplumber/scripts/omarchy
cp "$OMARCHY_PATH/default/wireplumber/wireplumber.conf.d/keep-inputs-ready.conf" ~/.config/wireplumber/wireplumber.conf.d/
