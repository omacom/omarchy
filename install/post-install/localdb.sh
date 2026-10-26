# Update localdb so locate can find the installed system files immediately.
# Match the scheduled service while installation runs without a system manager.
updatedb --prune-bind-mounts=no --add-prunepaths=/.snapshots --add-prunefs="fuse.rclone smb3 ceph"
