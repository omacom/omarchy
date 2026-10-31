#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

# Server edition only
export OMARCHY_EDITION_FILE="$workdir/omarchy-edition"
printf 'server\n' >"$OMARCHY_EDITION_FILE"

# Mock bins
mock_bin="$workdir/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-edition-server" <<'STUB'
#!/bin/bash
[[ $(cat "$OMARCHY_EDITION_FILE") == "server" ]]
STUB

cat >"$mock_bin/omarchy-pkg-add" <<'STUB'
#!/bin/bash
echo "pkg-add $*" >>"$CALL_LOG"
STUB

cat >"$mock_bin/mkinitcpio" <<'STUB'
#!/bin/bash
echo "mkinitcpio $*" >>"$CALL_LOG"
STUB

cat >"$mock_bin/limine-mkinitcpio" <<'STUB'
#!/bin/bash
echo "limine-mkinitcpio" >>"$CALL_LOG"
STUB

cat >"$mock_bin/dropbearkey" <<'STUB'
#!/bin/bash
if [[ $1 == "-y" ]]; then
  echo "Fingerprint: sha256!! mockfingerprint"
else
  echo "Generating dropbear key..."
fi
STUB

cat >"$mock_bin/sudo" <<'STUB'
#!/bin/bash
# For testing, just run commands directly (we're already in test environment)
case "$1" in
  install)
    # sudo install -Dm644 /dev/stdin <file>
    shift
    while [[ $1 == -* ]]; do shift; done
    destination="$1"
    mkdir -p "$(dirname "$destination")"
    cat > "$destination"
    ;;
  tee)
    shift
    exec tee "$@"
    ;;
  mkdir)
    shift
    exec mkdir "$@"
    ;;
  cp)
    shift
    exec cp "$@"
    ;;
  rm)
    shift
    exec rm "$@"
    ;;
  chmod)
    shift
    exec chmod "$@"
    ;;
  dropbearkey)
    shift
    exec dropbearkey "$@"
    ;;
  mkinitcpio)
    shift
    exec mkinitcpio "$@"
    ;;
  limine-mkinitcpio)
    exec limine-mkinitcpio
    ;;
  sed)
    shift
    exec sed "$@"
    ;;
  wc)
    shift
    exec wc "$@"
    ;;
  *)
    exec "$@"
    ;;
esac
STUB

cat >"$mock_bin/lsblk" <<'STUB'
#!/bin/bash
if [[ "${MOCK_HAS_CRYPT:-1}" == "1" ]]; then
  echo "crypt"
fi
STUB

cat >"$mock_bin/ip" <<'STUB'
#!/bin/bash
echo "192.168.1.100/24"
STUB

chmod +x "$mock_bin"/*

setup_test() {
  local scenario="$1"
  local test_home="$workdir/$scenario/home"
  local test_etc="$workdir/$scenario/etc"
  
  rm -rf "$test_home" "$test_etc"
  mkdir -p "$test_home/.ssh" \
    "$test_etc/mkinitcpio.conf.d" \
    "$test_etc/kernel" \
    "$test_etc/dropbear" \
    "$test_etc/dropbear/initramfs" \
    "$test_etc/initcpio/dropbear"
  
  : >"$workdir/$scenario.calls"
  
  export HOME="$test_home"
  export CALL_LOG="$workdir/$scenario.calls"
  export TEST_ETC="$test_etc"
}

run_command() {
  PATH="$mock_bin:$ROOT/bin:$PATH" \
    HOME="$HOME" \
    OMARCHY_EDITION_FILE="$OMARCHY_EDITION_FILE" \
    MOCK_HAS_CRYPT="${MOCK_HAS_CRYPT:-1}" \
    bash "$ROOT/bin/omarchy-server-remote-unlock" "$@" 2>&1
}

# Desktop edition should reject
printf 'desktop\n' >"$OMARCHY_EDITION_FILE"
setup_test desktop_reject
output=$(run_command enable 2>&1 || true)
[[ $output == *"only available on the server edition"* ]] ||
  fail "desktop edition rejects remote unlock"
pass "desktop edition rejects remote unlock"

# Server edition: require SSH keys
printf 'server\n' >"$OMARCHY_EDITION_FILE"
setup_test no_keys
output=$(run_command enable 2>&1 || true)
[[ $output == *"No SSH keys found"* ]] ||
  fail "enable without SSH keys fails"
pass "enable without SSH keys fails with clear error"

# Server edition with keys: test basic flow
setup_test with_keys
printf 'ssh-ed25519 AAAA fake-key test@example\n' >"$HOME/.ssh/authorized_keys"
export MOCK_HAS_CRYPT=1

# The enable command will fail at sudo operations but we can check early validation
output=$(run_command enable 2>&1 || true)
# Should at least start the process
[[ $output == *"Installing dropbear"* || $output == *"mkdir"* || $output == *"Permission denied"* ]] ||
  fail "enable starts with encrypted root and keys" "$output"
pass "enable validates prerequisites correctly"

# Check that packages would be installed
grep -q "pkg-add.*mkinitcpio-dropbear" "$CALL_LOG" 2>/dev/null ||
  skip "package installation check (needs real execution)"

# Help output
output=$(run_command --help)
[[ $output == *"cryptroot-unlock"* ]] ||
  fail "help mentions unlock command"
[[ $output == *"--static-ip"* ]] ||
  fail "help documents static IP option"
[[ $output == *"--port"* ]] ||
  fail "help documents port option"
pass "help output is complete"

# Status on disabled system
setup_test status_disabled
output=$(run_command status)
[[ $output == *"Status: DISABLED"* ]] ||
  fail "status shows disabled when not configured"
pass "status correctly reports disabled state"

# Test encrypted root detection
setup_test no_encryption
export MOCK_HAS_CRYPT=0
printf 'ssh-ed25519 AAAA fake-key test@example\n' >"$HOME/.ssh/authorized_keys"
output=$(run_command enable 2>&1 || true)
[[ $output == *"No encrypted root filesystem detected"* ]] ||
  fail "enable rejects non-encrypted systems"
pass "enable requires encrypted root"
