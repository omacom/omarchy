#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

# omarchy-remove-dev-env finds rustup through CARGO_HOME. One inherited from
# the caller would point it at the real install, so keep every run in HOME.
unset CARGO_HOME RUSTUP_HOME RUSTUP_TOOLCHAIN

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

grep -qx "mise uninstall rust --all" "$event_log" && grep -qx "mise rm -g rust" "$event_log" ||
  fail "removing Rust uninstalls mise's rust and drops its global declaration" "$(cat "$event_log")"
pass "removing Rust uninstalls mise's rust and drops its global declaration"

# A relocated CARGO_HOME is where rustup lives, and ~/.cargo does not exist
cargo_home=$test_tmp/xdg-cargo
rm -rf "$test_home/.cargo"
mkdir -p "$cargo_home/bin"
cat >"$cargo_home/bin/rustup" <<'SH'
#!/bin/bash
echo "cargo-home rustup $*" >>"$EVENT_LOG"
SH
chmod +x "$cargo_home/bin/rustup"
: >"$event_log"

HOME="$test_home" CARGO_HOME="$cargo_home" PATH="$shim_bin:/usr/bin" EVENT_LOG="$event_log" \
  "$ROOT/bin/omarchy-remove-dev-env" rust >/dev/null ||
  fail "removing Rust succeeds with CARGO_HOME set" "$(cat "$event_log")"
grep -qx "cargo-home rustup self uninstall -y" "$event_log" ||
  fail "removing Rust runs the rustup in \$CARGO_HOME/bin" "$(cat "$event_log")"
pass "removing Rust runs the rustup in \$CARGO_HOME/bin"

# With no rustup left behind, removing mise's rust is enough
rm -rf "$cargo_home"
: >"$event_log"
HOME="$test_home" CARGO_HOME="$cargo_home" PATH="$shim_bin:/usr/bin" EVENT_LOG="$event_log" \
  "$ROOT/bin/omarchy-remove-dev-env" rust >/dev/null ||
  fail "removing Rust succeeds without a rustup on disk" "$(cat "$event_log")"
grep -qx "mise uninstall rust --all" "$event_log" ||
  fail "removing Rust without a rustup still uninstalls mise's rust" "$(cat "$event_log")"
pass "removing Rust succeeds without a rustup on disk"
mkdir -p "$test_home/.cargo/bin"

# A failed uninstall is reported instead of swallowed
cat >"$test_home/.cargo/bin/rustup" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$test_home/.cargo/bin/rustup"
mkdir -p "$test_home/.local/share/mise/installs/rust"

if HOME="$test_home" PATH="$shim_bin:/usr/bin" EVENT_LOG="$event_log" \
  "$ROOT/bin/omarchy-remove-dev-env" rust >/dev/null 2>&1; then
  fail "removing Rust fails when rustup fails"
fi
pass "removing Rust fails when rustup fails"

[[ -d $test_home/.local/share/mise/installs/rust ]] ||
  fail "a failed Rust removal leaves mise's link in place"
pass "a failed Rust removal leaves mise's link in place"

# Installing Rust goes through mise like the other dev envs, not rustup's script
cat >"$shim_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
echo "pkg-add $*" >>"$EVENT_LOG"
SH
cat >"$shim_bin/curl" <<'SH'
#!/bin/bash
echo "curl $*" >>"$EVENT_LOG"
exit 1
SH
chmod +x "$shim_bin/omarchy-pkg-add" "$shim_bin/curl"
: >"$event_log"

HOME="$test_home" PATH="$shim_bin:/usr/bin" EVENT_LOG="$event_log" \
  "$ROOT/bin/omarchy-install-dev-env" rust >/dev/null ||
  fail "installing Rust succeeds" "$(cat "$event_log")"
grep -qx "mise use --global rust@latest" "$event_log" ||
  fail "installing Rust selects it through mise" "$(cat "$event_log")"
! grep -q "^curl" "$event_log" ||
  fail "installing Rust does not download rustup's install script" "$(cat "$event_log")"
grep -qx "pkg-add clang" "$event_log" ||
  fail "installing Rust still installs clang for bindgen" "$(cat "$event_log")"
pass "installing Rust goes through mise"
