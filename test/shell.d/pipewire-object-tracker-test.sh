#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A PwObjectTracker bound straight to a live node list refs (and so binds) nodes
# while Quickshell's PwRegistry::reset() is tearing the registry down after a
# PipeWire error, and pw_registry_bind on the destroyed registry segfaults the
# shell (#15838). SettledPwObjectTracker hands its tracker each list one
# event-loop turn late, after the teardown has finished.

tracker="$ROOT/shell/Commons/SettledPwObjectTracker.qml"
direct=$(grep -rln --include=*.qml -E '(^|[^A-Za-z])PwObjectTracker[[:space:]]*\{' "$ROOT/shell" | grep -vxF "$tracker" || true)
if [[ -n $direct ]]; then
  fail "no shell QML instantiates PwObjectTracker directly; use SettledPwObjectTracker" "$direct"
fi
pass "no shell QML instantiates PwObjectTracker directly"

require_quickshell "settled PipeWire object tracker"
run_qml_fixture pipewire-object-tracker "the settled tracker takes only the latest list, one event-loop turn late" Commons
