#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v sshd >/dev/null; then
  skip "no SSH server; skipping real theme sync connection reuse"
  exit 0
fi
require_command python3
require_command ssh
require_command ssh-keygen

python3 "$SHELL_TEST_DIR/fixtures/theme-set-herdr-ssh-reuse.py"
