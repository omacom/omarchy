#!/bin/bash
set -uo pipefail
cd "$OMARCHY_PATH" || exit 1
failed=()
for suite in test/shell.d/netclaw-test.sh test/shell.d/netclaw-credentials-test.sh test/shell.d/netclaw-workspace-test.sh test/shell.d/netclaw-markmap-test.sh test/shell.d/netclaw-launch-test.sh test/cli test/shell.d/default-agent-test.sh test/shell.d/menu-test.sh test/shell.d/menu-guards-test.sh test/shell.d/launch-openclaw-test.sh test/shell.d/restart-shell-test.sh; do
  echo "Running $suite"
  if ! bash "$suite"; then
    failed+=("$suite")
  fi
done
if (( ${#failed[@]} )); then
  printf 'Failed suite: %s\n' "${failed[@]}" >&2
  exit 1
fi
echo "All NetClaw container suites passed."
