echo "Bring back Papers and xdg-user-dirs, removed along with Nautilus"

# The first version of the Nautilus migration removed sushi with pacman -Rns,
# which also took the dependencies nothing else needed. Where Papers and
# xdg-user-dirs had first arrived as its dependencies, they went with it, and
# PDFs fell back to whatever else claims them. That migration no longer does
# this; this puts them back where it already ran, and does nothing elsewhere.
omarchy-pkg-add papers xdg-user-dirs
