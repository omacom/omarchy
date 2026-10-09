#!/bin/bash

# Start the watcher that saves dots edits as they happen. Installing enabled
# dots inside the chroot, where no user manager runs to start it.

set -euo pipefail

if omarchy-dots-enabled; then
  mise bootstrap services apply --yes
fi
