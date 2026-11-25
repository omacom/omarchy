#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A swapped restore is committed by the first boot of the restored root, and
# only by it: booted into a snapshot instead, the journal waits, and @'s boot
# images aren't filtered by the snapshot's kernels.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

awk '
  /^[a-z_]+\(\) \{/ { copying = 1 }
  copying { print }
  /^}/ { copying = 0 }
' "$ROOT/bin/omarchy-boot-sync" >"$test_tmp/functions"

new_store() {
  local store=$test_tmp/store
  rm -rf "$store"
  mkdir -p "$store/restore" "$store/current" "$store/images/restored" "$store/images/old"
  printf 'PKGBASE=linux-omarchy\nKVER=7.1\n' >"$store/images/restored/manifest"
  printf 'PKGBASE=linux-omarchy\nKVER=7.2\n' >"$store/images/old/manifest"
  ln -s ../images/old "$store/current/linux-omarchy"
  printf 'preferred=linux-omarchy\n' >"$store/state"
  printf 'TX=1\nSTATE=swapped\nSOURCE=8\nSTAGED_UUID=restored-uuid\nIMAGE=restored\nBACKUP=@backup-1\nPREVIOUS_IMAGE=old\n' >"$store/restore/journal"
}

# $1: the UUID of the root this boot runs.
commit() {
  LIVE_UUID=$1 bash -c '
    set -euo pipefail
    source "$1/functions"
    STORE=$1/store TOP=$1/top
    check_store() { :; }
    mount_top() { :; }
    cmd_sync() { :; }
    subvol_uuid() { if [[ $1 == / ]]; then echo "$LIVE_UUID"; else echo restored-uuid; fi; }
    root_kernels() { echo "linux-omarchy 7.1"; }
    cmd_restore_commit
  ' _ "$test_tmp" 2>/dev/null
}

new_store
out=$(commit snapshot-uuid) || fail "a snapshot boot leaves the restore alone"
[[ -z $out ]] || fail "a snapshot boot reports nothing" "$out"
grep -qx STATE=swapped "$test_tmp/store/restore/journal" || fail "the journal waits for the restored root"
[[ $(readlink "$test_tmp/store/current/linux-omarchy") == ../images/old ]] || fail "@'s boot images stay as they are"
pass "booted into a snapshot, the restore waits for the restored root"

out=$(commit restored-uuid) || fail "the restored root commits"
[[ $out == "restored: 8" ]] || fail "the commit reports the restore" "$out"
[[ -f $test_tmp/store/restore/done-1 ]] || fail "the journal is done"
[[ $(readlink "$test_tmp/store/current/linux-omarchy") == ../images/restored ]] || fail "the restored image is current"
pass "the restored root's own boot commits the restore"
