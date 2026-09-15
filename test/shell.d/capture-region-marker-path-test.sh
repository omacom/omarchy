#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

script="$ROOT/bin/omarchy-capture-region"

if grep -Fq '${XDG_RUNTIME_DIR:-/tmp}/omarchy-capture-region-fullscreen' "$script"; then
  fail "capture-region fullscreen marker no longer falls back to /tmp"
fi
if grep -Fq '${XDG_RUNTIME_DIR:-/tmp}/omarchy-capture-region-window' "$script"; then
  fail "capture-region window marker no longer falls back to /tmp"
fi

grep -Fq 'private_marker_root' "$script" || fail "capture-region resolves a private marker root"
grep -Fq 'XDG_STATE_HOME' "$script" || fail "capture-region falls back to XDG_STATE_HOME when runtime dir is unset"
grep -Fq 'chmod 700' "$script" || fail "capture-region enforces mode 0700 on the private marker root"
pass "capture-region marker paths avoid world-writable /tmp"
