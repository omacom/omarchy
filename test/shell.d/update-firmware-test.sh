#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub_dir="$tmpdir/bin"
log_file="$tmpdir/fwupdmgr.log"
mkdir -p "$stub_dir"

# fwupdmgr exits 2 for "nothing to do", which is what an up-to-date machine
# gets. Every other code the stub reports is a real failure.
cat >"$stub_dir/fwupdmgr" <<'EOF'
#!/bin/bash
printf '%s %s\n' "$1" "$FwupdStatus" >>"$FWUPDMGR_LOG"
if [[ $1 == "update" ]]; then
  exit "${FwupdStatus:-0}"
fi
exit 0
EOF
chmod +x "$stub_dir/fwupdmgr"

# sudo is only allowed to run fwupdmgr here: the EFI binary copy under
# /usr/lib/fwupd would otherwise install into the test machine's /boot.
cat >"$stub_dir/sudo" <<'EOF'
#!/bin/bash
if [[ $1 == "install" ]]; then
  exit 0
fi
exec "$@"
EOF
chmod +x "$stub_dir/sudo"

run_firmware() {
  local status=$1

  FwupdStatus="$status" \
    FWUPDMGR_LOG="$log_file" \
    PATH="$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-update-firmware"
}

run_and_capture() {
  local status=$1

  if run_firmware "$status" >"$tmpdir/out" 2>&1; then
    printf '0'
  else
    printf '%s' "$?"
  fi
}

assert_exit_status() {
  local description=$1
  local expected=$2
  local fwupd_status=$3
  local actual

  actual=$(run_and_capture "$fwupd_status")
  if [[ $actual != "$expected" ]]; then
    printf 'fwupdmgr update exit %s made the script exit %s, expected %s\n' \
      "$fwupd_status" "$actual" "$expected" >&2
    printf 'Output:\n%s\n' "$(cat "$tmpdir/out")" >&2
    fail "$description"
  fi

  pass "$description"
}

: >"$log_file"
assert_exit_status "firmware update succeeds when a current machine has nothing to do" 0 2
assert_exit_status "firmware update still succeeds when everything was already current" 0 0
assert_exit_status "firmware update reports a real fwupdmgr failure" 1 1
assert_exit_status "firmware update reports a permission failure" 3 3
grep -Fxq 'update 2' "$log_file" || fail "firmware update must run fwupdmgr update, not only refresh"

# refresh runs before update on every path, including the one that exits 2.
[[ -n $(sed -n '1p' "$log_file") ]] || fail "firmware update must refresh metadata first"
