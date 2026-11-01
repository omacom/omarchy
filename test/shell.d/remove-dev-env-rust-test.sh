#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home=$test_tmp/home
shim_bin=$test_tmp/shims
event_log=$test_tmp/events

mkdir -p "$test_home/.cargo/bin" "$test_home/.local/share/mise/installs/rust" "$shim_bin"
ln -s "$test_home/.cargo/bin" "$test_home/.local/share/mise/installs/rust/1.99.0"
touch "$event_log"

cat >"$test_home/.cargo/bin/rustup" <<'SH'
#!/bin/bash
echo "rustup $*" >>"$EVENT_LOG"
SH

# A mise shim for rustup that fails, as it does when no global rust version is set
cat >"$shim_bin/rustup" <<'SH'
#!/bin/bash
echo "shim rustup $*" >>"$EVENT_LOG"
exit 1
SH

cat >"$shim_bin/mise" <<'SH'
#!/bin/bash
echo "mise $*" >>"$EVENT_LOG"
SH

chmod +x "$test_home/.cargo/bin/rustup" "$shim_bin/rustup" "$shim_bin/mise"

HOME="$test_home" PATH="$shim_bin:/usr/bin" EVENT_LOG="$event_log" \
  "$ROOT/bin/omarchy-remove-dev-env" rust >/dev/null ||
  fail "removing Rust succeeds with the real rustup" "$(cat "$event_log")"

grep -qx "rustup self uninstall -y" "$event_log" ||
  fail "removing Rust runs the rustup in ~/.cargo/bin" "$(cat "$event_log")"
pass "removing Rust runs the rustup in ~/.cargo/bin"

! grep -q "^shim rustup" "$event_log" ||
  fail "removing Rust bypasses a rustup shim earlier on PATH" "$(cat "$event_log")"
pass "removing Rust bypasses a rustup shim earlier on PATH"

[[ ! -e $test_home/.local/share/mise/installs/rust ]] ||
  fail "removing Rust drops mise's link to the rustup toolchain"
pass "removing Rust drops mise's link to the rustup toolchain"

grep -qx "mise reshim" "$event_log" ||
  fail "removing Rust clears mise's rust shims" "$(cat "$event_log")"
pass "removing Rust clears mise's rust shims"

# A failed uninstall is reported instead of swallowed
cat >"$test_home/.cargo/bin/rustup" <<'SH'
#!/bin/bash
exit 1
SH
mkdir -p "$test_home/.local/share/mise/installs/rust"

if HOME="$test_home" PATH="$shim_bin:/usr/bin" EVENT_LOG="$event_log" \
  "$ROOT/bin/omarchy-remove-dev-env" rust >/dev/null 2>&1; then
  fail "removing Rust fails when rustup fails"
fi
pass "removing Rust fails when rustup fails"

[[ -d $test_home/.local/share/mise/installs/rust ]] ||
  fail "a failed Rust removal leaves mise's link in place"
pass "a failed Rust removal leaves mise's link in place"
