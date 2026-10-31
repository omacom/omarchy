#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mock_bin="$TMPDIR/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ ${1:-} == "dropbox-cli" ]]
SH

# dropbox-cli's `running` command exits 1 while running and 0 while stopped.
cat >"$mock_bin/dropbox-cli" <<'SH'
#!/bin/bash
[[ ${1:-} == "running" ]] || exit 2
[[ ${OMARCHY_TEST_DROPBOX_RUNNING:-0} == "1" ]] && exit 1
exit 0
SH

cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
[[ $* == "-x dropbox" ]] || exit 2
[[ ${OMARCHY_TEST_DROPBOX_RUNNING:-0} == "1" ]]
SH

chmod +x "$mock_bin"/*
mock_path="$mock_bin:$ROOT/bin:$PATH"

if PATH="$mock_path" OMARCHY_TEST_DROPBOX_RUNNING=0 omarchy-installed-service-dropbox; then
  fail "installed Dropbox service check rejects a stopped daemon when dropbox-cli is installed"
fi
pass "installed Dropbox service check rejects a stopped daemon when dropbox-cli is installed"

PATH="$mock_path" OMARCHY_TEST_DROPBOX_RUNNING=1 omarchy-installed-service-dropbox
pass "installed Dropbox service check accepts a running daemon when dropbox-cli is installed"
