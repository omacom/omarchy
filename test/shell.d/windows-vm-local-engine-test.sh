#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

set -- help
source "$ROOT/bin/omarchy-windows-vm" >/dev/null

# An empty remote engine must never authorize removal of an active local disk.
# Stub all mount/destructive operations; no real engine or filesystem changes.
export CONTAINER_HOST=unix:///tmp/omarchy-test-remote.sock
USERS_DIR=/fixture/users
CALLER_UID=1000
CALLER_DATA_ROOT="$USERS_DIR/$CALLER_UID"
EXPECTED_STORAGE="$USERS_DIR/$CALLER_UID/storage"
EXPECTED_SHARED="$USERS_DIR/$CALLER_UID/shared"
assert_mounts_safe() { :; }
mount_layer_count() { echo 1; }
mount_descendant_count() { echo 0; }
mounts_ready() { :; }
removal_trees_disjoint() { :; }
deleted=0
find() { [[ $* != *-delete* ]] || deleted=1; }
umount() { :; }
rm() { :; }
rmdir() { :; }
podman-compose() {
  [[ $1 == --podman-args=--remote=false ]] || fail "Windows Compose can use a remote engine"
  # Simulate an apparently successful down that left the local container.
  return 0
}
podman() {
  if [[ $1 == --remote=false ]]; then
    shift
    # Local container is still present; removal must refuse to delete its disk.
    [[ $1 != inspect ]] || return 0
  else
    # The unrelated remote is healthy but has no matching Windows container.
    [[ $1 != inspect ]] || return 1
  fi
  return 0
}

__priv_remove 2>/dev/null && fail "empty remote state authorized local Windows disk removal"
(( deleted == 0 )) || fail "local Windows disk was deleted while its container remained"
pass "Windows Compose and removal inspect the local engine despite a remote endpoint"
