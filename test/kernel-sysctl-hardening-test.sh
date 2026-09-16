#!/bin/bash

set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TMPDIR=$(mktemp -d)

pass() {
  printf 'ok - %s\n' "$1"
}

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

assert_file_contains() {
  local description="$1"
  local file="$2"
  local expected="$3"

  if ! grep -Fq "$expected" "$file"; then
    printf 'Expected file %s to contain: %s\n' "$file" "$expected" >&2
    fail "$description"
  fi

  pass "$description"
}

cleanup() {
  rm -rf "$TMPDIR"
}
trap cleanup EXIT

# Mock sudo in PATH
BINDIR="$TMPDIR/bin"
mkdir -p "$BINDIR"

cat > "$BINDIR/sudo" <<EOF
#!/bin/bash
if [[ \$1 == "tee" ]]; then
  shift
  target="$TMPDIR\$1"
  mkdir -p "\$(dirname "\$target")"
  cat > "\$target"
elif [[ \$1 == "sysctl" ]]; then
  exit 0
else
  "\$@"
fi
EOF
chmod +x "$BINDIR/sudo"

PATH="$BINDIR:$PATH" bash "$ROOT/install/config/kernel-sysctl-hardening.sh"

TEST_CONF="$TMPDIR/etc/sysctl.d/99-omarchy-security.conf"

[[ -f $TEST_CONF ]] || fail "sysctl security conf created"
pass "sysctl security conf created"

assert_file_contains "ASLR randomization enabled" "$TEST_CONF" "kernel.randomize_va_space = 2"
assert_file_contains "kernel pointer leaks restricted" "$TEST_CONF" "kernel.kptr_restrict = 2"
assert_file_contains "dmesg access restricted" "$TEST_CONF" "kernel.dmesg_restrict = 1"
assert_file_contains "unprivileged eBPF disabled" "$TEST_CONF" "kernel.unprivileged_bpf_disabled = 1"
assert_file_contains "Yama ptrace scope set" "$TEST_CONF" "kernel.yama.ptrace_scope = 1"
assert_file_contains "reverse path filtering enabled" "$TEST_CONF" "net.ipv4.conf.all.rp_filter = 1"
assert_file_contains "TCP syncookies enabled" "$TEST_CONF" "net.ipv4.tcp_syncookies = 1"
assert_file_contains "RFC1337 time-wait protection enabled" "$TEST_CONF" "net.ipv4.tcp_rfc1337 = 1"
assert_file_contains "ICMP redirects disabled" "$TEST_CONF" "net.ipv4.conf.all.accept_redirects = 0"
