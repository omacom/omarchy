echo "Bring back Ghostscript, removed along with Nautilus"

# The first version of the Nautilus migration removed sushi with pacman -Rns,
# which also took Ghostscript where it had only arrived as a dependency of
# Nautilus. CUPS still picks its Ghostscript filter for driverless printers, so
# every print job failed with "gs: No such file or directory". This puts it
# back where it went, and does nothing elsewhere.
omarchy-pkg-add ghostscript
