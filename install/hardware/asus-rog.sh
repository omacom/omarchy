# RC71L is a handheld; do not apply the ROG laptop setup.
if omarchy-hw-asus-rog && ! omarchy-hw-rog-ally; then
  omarchy-pkg-add asusctl
fi
