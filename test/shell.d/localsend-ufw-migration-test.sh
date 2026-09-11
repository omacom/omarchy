#!/bin/bash

set -euo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

migration="$ROOT/migrations/1788839725.sh"
[[ -f $migration ]] || fail "the LocalSend UFW migration exists at $migration"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin" "$test_dir/failing-bin"

cat >"$test_dir/bin/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$CALLS"
exec "$@"
STUB

cat >"$test_dir/bin/ufw" <<'STUB'
#!/bin/bash
printf 'ufw %s\n' "$*" >>"$CALLS"
STUB

cat >"$test_dir/failing-bin/sudo" <<'STUB'
#!/bin/bash
echo "sudo: a terminal is required to read the password" >&2
exit 1
STUB

cp "$test_dir/bin/ufw" "$test_dir/failing-bin/ufw"
chmod +x "$test_dir/bin/"* "$test_dir/failing-bin/"*

export CALLS="$test_dir/calls"
user_rules="$test_dir/user.rules"
user6_rules="$test_dir/user6.rules"

# Fixtures are what ufw 0.36 writes: a "### tuple ###" line per rule (comment
# hex-encoded there, not as -m comment), then the iptables line with -p and
# --dport before -s. The stock rule has no source and no comment.
write_open_rules() {
  cat >"$user_rules" <<'EOF'
### tuple ### allow udp 53317 0.0.0.0/0 any 0.0.0.0/0 in
-A ufw-user-input -p udp --dport 53317 -j ACCEPT

### tuple ### allow tcp 53317 0.0.0.0/0 any 0.0.0.0/0 in
-A ufw-user-input -p tcp --dport 53317 -j ACCEPT
EOF
  cat >"$user6_rules" <<'EOF'
### tuple ### allow udp 53317 ::/0 any ::/0 in
-A ufw6-user-input -p udp --dport 53317 -j ACCEPT

### tuple ### allow tcp 53317 ::/0 any ::/0 in
-A ufw6-user-input -p tcp --dport 53317 -j ACCEPT
EOF
}

write_limited_rules() {
  local comment=6f6d61726368792d6c6f63616c73656e64 # omarchy-localsend
  : >"$user_rules"
  for cidr in 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 169.254.0.0/16; do
    for proto in udp tcp; do
      cat >>"$user_rules" <<EOF
### tuple ### allow $proto 53317 0.0.0.0/0 any $cidr in comment=$comment
-A ufw-user-input -p $proto --dport 53317 -s $cidr -j ACCEPT

EOF
    done
  done
  : >"$user6_rules"
  for cidr in fe80::/10 fc00::/7; do
    for proto in udp tcp; do
      cat >>"$user6_rules" <<EOF
### tuple ### allow $proto 53317 ::/0 any $cidr in comment=$comment
-A ufw6-user-input -p $proto --dport 53317 -s $cidr -j ACCEPT

EOF
    done
  done
}

run_migration() {
  local path=$1
  : >"$CALLS"
  OMARCHY_UFW_USER_RULES="$user_rules" \
    OMARCHY_UFW_USER6_RULES="$user6_rules" \
    PATH="$path:$ROOT/bin:$PATH" \
    bash -euo pipefail "$migration"
}

write_open_rules
run_migration "$test_dir/bin" >/dev/null
grep -q '^sudo bash -s$' "$CALLS" || fail "open rules escalate to rewrite UFW"
grep -q '^ufw --force delete allow 53317/tcp$' "$CALLS" || fail "open rules delete unrestricted TCP"
grep -q '^ufw --force delete allow 53317/udp$' "$CALLS" || fail "open rules delete unrestricted UDP"
grep -q 'ufw allow in proto tcp from 10.0.0.0/8 to any port 53317' "$CALLS" ||
  fail "open rules add RFC1918 TCP"
grep -q 'ufw allow in proto udp from 169.254.0.0/16 to any port 53317' "$CALLS" ||
  fail "open rules add IPv4 link-local UDP"
grep -q 'ufw allow in proto udp from fe80::/10 to any port 53317' "$CALLS" ||
  fail "open rules add IPv6 link-local UDP"
if grep -qE '^ufw allow 53317/' "$CALLS"; then
  fail "open rules do not re-add anywhere-allow" "$(cat "$CALLS")"
fi
pass "open LocalSend UFW rules are rewritten to private CIDRs"

write_limited_rules
run_migration "$test_dir/bin" >/dev/null
if [[ -s $CALLS ]]; then
  fail "already-limited rules do not call sudo or ufw" "$(cat "$CALLS")"
fi
pass "already-limited LocalSend UFW rules are a no-op"

write_open_rules
if PATH="$test_dir/failing-bin:$ROOT/bin:$PATH" \
  OMARCHY_UFW_USER_RULES="$user_rules" \
  OMARCHY_UFW_USER6_RULES="$user6_rules" \
  bash -euo pipefail "$migration" >/dev/null 2>"$test_dir/err"; then
  fail "missing privileges leave the migration pending"
fi
grep -q 'Administrator privileges are required' "$test_dir/err" ||
  fail "missing privileges explain how to retry" "$(cat "$test_dir/err")"
pass "missing privileges leave the LocalSend UFW migration pending"

# Arch ships the rules files 0644, but an administrator may have tightened
# them. Then the unprivileged check cannot tell, so the migration must
# escalate rather than trust a failed read. Root reads everything, so this
# only proves anything for an ordinary user.
if (( EUID != 0 )); then
  write_limited_rules
  chmod 000 "$user_rules"
  run_migration "$test_dir/bin" >/dev/null 2>"$test_dir/err"
  chmod 644 "$user_rules"
  grep -q '^sudo bash -s$' "$CALLS" || fail "unreadable rules escalate instead of assuming they are limited" "$(cat "$CALLS")"
  if [[ -s $test_dir/err ]]; then
    fail "unreadable rules escalate without grep noise" "$(cat "$test_dir/err")"
  fi
  pass "unreadable LocalSend UFW rules escalate to root"
fi
