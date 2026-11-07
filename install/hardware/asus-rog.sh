# The original ROG Ally is a handheld. asusctl is the laptop daemon and
# conflicts with Handheld Daemon there; install/hardware/asus/rog-ally.sh
# records why. The Ally X is left on this laptop path.
if omarchy-hw-asus-rog && ! omarchy-hw-rog-ally; then
  omarchy-pkg-add asusctl
fi
