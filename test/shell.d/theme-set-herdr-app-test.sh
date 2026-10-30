#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

SYNC_TEST=$(mktemp -d)
trap 'rm -rf "$SYNC_TEST"' EXIT

home="$SYNC_TEST/home"
source_palette="$home/.local/state/omarchy/current/theme/herdr-app.json"
published="$home/.config/herdr-app/themes/omarchy.json"
mkdir -p "${source_palette%/*}" "$home/.config/herdr-app" "$SYNC_TEST/run"

run_sync() {
  env -u HERDR_APP_HOME -u XDG_CONFIG_HOME HOME="$home" XDG_RUNTIME_DIR="$SYNC_TEST/run" \
    "$ROOT/bin/omarchy-theme-set-herdr-app"
}

# Quick theme switches overlap. A sync still waiting for an earlier one publishes the
# theme that is current once it runs, so Herdr never ends on an older palette.
echo '{ "background": "#000000" }' >"$source_palette"
exec 8>"$SYNC_TEST/run/omarchy-theme-set-herdr-app.lock"
flock 8
run_sync &
queued=$!
sleep 0.5
echo '{ "background": "#ffffff" }' >"$source_palette"
flock -u 8
wait $queued
[[ $(<"$published") == '{ "background": "#ffffff" }' ]] || fail "a queued sync publishes the newest theme"
pass "a queued sync publishes the newest theme"
