#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

WORKDIR=$(mktemp -d)
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

mkdir -p "$WORKDIR/bin"
cat >"$WORKDIR/bin/omarchy-file-select" <<SH
#!/bin/bash
touch "$WORKDIR/picker-opened"
SH
chmod +x "$WORKDIR/bin/omarchy-file-select"

for flag in -h --help; do
  output=$(PATH="$WORKDIR/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-tailscale-send" "$flag") ||
    fail "tailscale send $flag succeeds"
  [[ $output == "Usage: omarchy-tailscale-send <machine> [file...]" ]] || fail "tailscale send $flag prints usage" "$output"
  [[ ! -e $WORKDIR/picker-opened ]] || fail "tailscale send $flag opens no file picker"
done
pass "tailscale send -h and --help print usage without opening the file picker"
