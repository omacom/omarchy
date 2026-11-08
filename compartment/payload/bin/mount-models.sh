#!/bin/bash
# mount-models.sh — open the dm-verity weights set, mount /mnt/weights, and
# bind /opt/models + /opt/bootstrap from it.
# Devices resolve by label/exclusion — PCI enumeration order varies by slot.
set -euo pipefail
ROOT_HASH=$(jq -r .root_hash /etc/compartment/verity-manifest.json)
[ -n "$ROOT_HASH" ] && [ "$ROOT_HASH" != null ] || { echo "no root hash"; exit 1; }

DATA_DEV=$(blkid -L llm-weights) || { echo "no llm-weights device"; exit 1; }
# verity disk = the other virtio disk that is neither the root disk nor data
ROOT_SRC=$(findmnt -n -o SOURCE / | sed 's/[0-9]*$//;s/p$//')
VERITY_DEV=""
for d in /dev/vd?; do
  [ "$d" = "$DATA_DEV" ] && continue
  [ "$d" = "$ROOT_SRC" ] && continue
  VERITY_DEV="$d"; break
done
[ -n "$VERITY_DEV" ] || { echo "no verity device"; exit 1; }
echo "data=$DATA_DEV verity=$VERITY_DEV root=$ROOT_SRC"

if ! dmsetup status models-verity >/dev/null 2>&1; then
  veritysetup open "$DATA_DEV" models-verity "$VERITY_DEV" "$ROOT_HASH"
fi
mkdir -p /mnt/weights /opt/models /opt/bootstrap
mountpoint -q /mnt/weights || \
  mount -o ro,noexec,nosuid,nodev /dev/mapper/models-verity /mnt/weights
mountpoint -q /opt/models || \
  mount --bind -o ro,noexec,nosuid,nodev /mnt/weights/opt/models /opt/models
mountpoint -q /opt/bootstrap || \
  mount --bind -o ro /mnt/weights/opt/bootstrap /opt/bootstrap

cd /opt/models && sha256sum -c --quiet MODELS.SHA256 \
  && echo "models verified" || echo "WARN: model hash check failed"
