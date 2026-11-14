echo "Draw the default apps' icons in the current theme's colors"

# Image Viewer, Media Player, Disks, Document Viewer and the other apps of a
# fresh install now have icon templates. Drawing them here links them in right
# away, where they would otherwise wait for the next theme switch.
omarchy-theme-set-icons || true
