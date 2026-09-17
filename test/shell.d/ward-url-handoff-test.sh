#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if [[ ${OMARCHY_TEST_SYSTEMD:-} != "1" ]]; then
  pass "Ward detached URL handoff requires OMARCHY_TEST_SYSTEMD=1; skipping"
  exit 0
fi

scratch=$(mktemp -d)
trap 'rm -f "$scratch/bin/omarchy-launch-browser" "$scratch/bin/omarchy-launch-webapp" "$scratch/record"; rmdir "$scratch/bin" "$scratch"' EXIT
mkdir "$scratch/bin"
for mode in browser webapp; do
  # Keep the real handoff script and service manager, replacing only the final
  # launcher with a generic delayed recorder. No browser or network is used.
  ln -s "$ROOT/test/shell.d/fixtures/ward-url-launcher" "$scratch/bin/omarchy-launch-$mode"
done
url="https://example.test/--private?literal=quoted&value=1"
for mode in browser webapp; do
  OMARCHY_PATH="$scratch" \
    "$ROOT/bin/omarchy-plugin-url-open" test.handoff "$mode" "$url"
  for (( attempt = 0; attempt < 50; attempt++ )); do
    [[ -f $scratch/record ]] && break
    sleep 0.05
  done
  [[ -f $scratch/record && $(<"$scratch/record") == "$url" ]] || fail "$mode detached handoff was killed"
  rm "$scratch/record"
done
pass "browser and webapp handoffs retain detached children"
