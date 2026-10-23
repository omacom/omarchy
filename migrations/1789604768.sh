echo "Stop Alpine Ridge Thunderbolt from waking T1 MacBooks out of S3"

fix="$OMARCHY_PATH/install/hardware/apple/fix-suspend-alpine-ridge.sh"
[[ -f $fix ]] || exit 0

# The installer leaf is meant to be sourced; it returns when the DMI id does
# not match so a migration on any other machine is a no-op.
source "$fix"
