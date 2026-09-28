echo "Install the VMware guest tools on VMware guests"

omarchy-hw-vmware || exit 0

# A guest the installer already set up, and every user after the first on a
# machine this repaired, has the unit enabled; neither needs sudo again.
systemctl is-enabled --quiet vmtoolsd.service && exit 0

# Completion is machine-wide even though migrations run once per user.
marker="${OMARCHY_VMWARE_TOOLS_MARKER:-/var/lib/omarchy/migrations/1789452465}"
[[ ! -e $marker ]] || exit 0

source "$OMARCHY_PATH/install/hardware/vmware.sh"

# The leaf enables the units for the next boot; start vmtoolsd now so display
# resizing works in this session, and so a broken install surfaces here. The
# drag-and-drop staging mount is optional and must not hold the queue.
sudo systemctl start vmtoolsd.service
sudo systemctl start vmware-vmblock-fuse.service || true
sudo install -Dm644 /dev/null "$marker"
