#!/bin/bash

# Browser profiles can arrive after shipped migrations were stamped complete.
# Quiet first-run repair leaves open profiles for a later login to repair.

set -euo pipefail

omarchy-cmd-repair-chromium-copy-url
