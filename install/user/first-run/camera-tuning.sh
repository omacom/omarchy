#!/bin/bash

# Apply the userland camera relay and image tuning for this laptop. Runs at
# first-run rather than finalize-user so the user systemd session and PipeWire
# are up. A no-op on machines no tuning matches.

set -euo pipefail

omarchy-camera-tuning on
