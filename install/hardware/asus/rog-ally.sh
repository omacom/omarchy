# This leaf also runs offline on an image's first boot, before a user exists.
# Keep optional gaming setup in the user session; never prompt or install a
# handheld control daemon here.
if omarchy-hw-rog-ally; then
  echo "ROG Ally RC71L: skipping ROG laptop asusctl setup. Steam is optional under Install > Gaming."
fi
