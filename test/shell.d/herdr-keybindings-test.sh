#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python

python - "$ROOT/config/herdr/config.toml" <<'PY'
import sys, tomllib

path = sys.argv[1]
with open(path, "rb") as handle:
    config = tomllib.load(handle)

keys = config["keys"]
close_workspace = keys["close_workspace"]
swap_pane_up = keys["swap_pane_up"]

if close_workspace == swap_pane_up:
    raise SystemExit(
        f"not ok - close_workspace still shadows swap_pane_up: {close_workspace}"
    )
if swap_pane_up != "prefix+shift+k":
    raise SystemExit(
        f"not ok - swap_pane_up moved unexpectedly: {swap_pane_up}"
    )
if close_workspace != "prefix+shift+x":
    raise SystemExit(
        f"not ok - close_workspace is not on the replacement chord: {close_workspace}"
    )

print("ok - herdr close_workspace does not shadow swap_pane_up")
PY
