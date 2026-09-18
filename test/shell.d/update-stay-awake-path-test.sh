#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

stub_bin="$tmp/bin"
mkdir -p "$stub_bin" "$tmp/home" "$tmp/run" "$tmp/state"

cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == systemd-inhibit ]] && exit 1
exit 1
SH

cat >"$stub_bin/omarchy-toggle-idle" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$stub_bin"/*
export PATH="$stub_bin:$PATH"
export HOME="$tmp/home"
unset XDG_RUNTIME_DIR
export XDG_STATE_HOME="$tmp/state"

script="$ROOT/bin/omarchy-update-stay-awake"

# Tip still names /tmp/omarchy-$UID; the tip-ready body must not.
if grep -q '/tmp/omarchy-\$UID\|/tmp/omarchy-$UID' "$script"; then
  fail "stay-awake no longer falls back to /tmp/omarchy-\$UID"
fi
pass "stay-awake source does not name /tmp/omarchy-\$UID"

# Without XDG_RUNTIME_DIR, start must stage under the private state home.
bash "$script" start >/dev/null

state_dir="$XDG_STATE_HOME/omarchy/omarchy-update-stay-awake"
[[ -d $state_dir ]] || fail "creates state under XDG_STATE_HOME/omarchy" "$(find "$tmp" -type d)"
pass "creates state under XDG_STATE_HOME/omarchy"

mode=$(stat -c '%a' "$XDG_STATE_HOME/omarchy" 2>/dev/null || stat -f '%Lp' "$XDG_STATE_HOME/omarchy")
[[ $mode == 700 ]] || fail "private root is mode 0700" "mode=$mode"
pass "private root is mode 0700"

[[ ! -e /tmp/omarchy-$UID/omarchy-update-stay-awake ]] ||
  fail "does not create /tmp/omarchy-\$UID/omarchy-update-stay-awake"
pass "does not create /tmp/omarchy-\$UID/omarchy-update-stay-awake"

# With XDG_RUNTIME_DIR set, prefer it.
export XDG_RUNTIME_DIR="$tmp/run"
bash "$script" stop >/dev/null 2>&1 || true
bash "$script" start >/dev/null
[[ -d $XDG_RUNTIME_DIR/omarchy-update-stay-awake ]] ||
  fail "prefers XDG_RUNTIME_DIR when set"
pass "prefers XDG_RUNTIME_DIR when set"
