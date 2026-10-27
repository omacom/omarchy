#!/bin/bash

# Runs only from `omarchy bundle project new`, after you confirm.
set -euo pipefail

name=$(basename -- "$PROJECT_DIR")
git init
cat > README.md <<EOF
# ${name}

# TODO: Cloudflare setup
EOF
