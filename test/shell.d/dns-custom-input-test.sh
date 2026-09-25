#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

dns="$ROOT/bin/omarchy-dns"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"
getent_log="$test_tmp/getent.log"
write_log="$test_tmp/write.log"
export GETENT_LOG="$getent_log" WRITE_LOG="$write_log"

cat >"$stub_bin/getent" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"${GETENT_LOG:?}"
case "${1-}:${2-}" in
  ahostsv4:dns.example | ahostsv4:tls.example | ahostsv4:dns-tls.example)
    printf '%s\n' '192.0.2.10 dns.example' '192.0.2.10 alias.example' '192.0.2.11 dns.example'
    ;;
  ahostsv6:dns.example | ahostsv6:tls.example | ahostsv6:dns-tls.example)
    printf '%s\n' '2001:db8::10 dns.example' '2001:db8::10 alias.example' '2001:db8::11 dns.example'
    ;;
  *)
    exit 2
    ;;
esac
STUB
chmod +x "$stub_bin/getent"

for command in install tee nmcli systemctl sudo pkexec; do
  cat >"$stub_bin/$command" <<'STUB'
#!/bin/bash
printf '%s\n' "$0 $*" >>"${WRITE_LOG:?}"
exit 97
STUB
  chmod +x "$stub_bin/$command"
done

parse_input() {
  local input="$1"

  if PARSE_OUTPUT=$(printf '%s\n' "$input" | PATH="$stub_bin:$PATH" OMARCHY_DNS_PARSE_ONLY=1 bash "$dns" Custom 2>&1); then
    PARSE_STATUS=0
  else
    PARSE_STATUS=$?
  fi
}

assert_accept() {
  local input="$1" expected="$2"

  parse_input "$input"
  (( PARSE_STATUS == 0 )) || fail "accepts custom input: $input" "$PARSE_OUTPUT"
  [[ $PARSE_OUTPUT == "$expected" ]] || fail "normalizes custom input: $input" "expected: $expected"$'\n'"actual: $PARSE_OUTPUT"
}

assert_reject() {
  local input="$1"

  parse_input "$input"
  (( PARSE_STATUS != 0 )) || fail "rejects custom input: $input" "$PARSE_OUTPUT"
  [[ -z $input ]] || [[ $PARSE_OUTPUT != *"$input"* ]] || fail "does not echo rejected custom input" "$PARSE_OUTPUT"
}

assert_accept "dns.example" $'transport=dot\nservers=192.0.2.10#dns.example 192.0.2.11#dns.example 2001:db8::10#dns.example 2001:db8::11#dns.example'
assert_accept "tls://tls.example" $'transport=dot\nservers=192.0.2.10#tls.example 192.0.2.11#tls.example 2001:db8::10#tls.example 2001:db8::11#tls.example'
assert_accept "dns+tls://dns-tls.example" $'transport=dot\nservers=192.0.2.10#dns-tls.example 192.0.2.11#dns-tls.example 2001:db8::10#dns-tls.example 2001:db8::11#dns-tls.example'
assert_accept "192.0.2.30#sni.example" $'transport=dot\nservers=192.0.2.30#sni.example'
assert_accept "2001:db8::30#sni.example" $'transport=dot\nservers=2001:db8::30#sni.example'
assert_accept "[192.0.2.40]:5353" $'transport=plain\nservers=[192.0.2.40]:5353'
assert_accept "[2001:db8::40]:5353" $'transport=plain\nservers=[2001:db8::40]:5353'
assert_accept "192.0.2.50 2001:db8::50" $'transport=plain\nservers=192.0.2.50 2001:db8::50'

assert_reject ""
assert_reject " , ; : "
assert_reject "*"
assert_reject "dns*"
assert_reject "dns?"
assert_reject "dns[1]"
assert_reject "999.1.1.1"
assert_reject "256.1.1.1"
assert_reject "1.2.3"
assert_reject "1.2.3.4.5"
assert_reject "192.0.2.1:53"
assert_reject "tls://dns.example:853"
assert_reject "[192.0.2.1]"
assert_reject "[192.0.2.1]:0"
assert_reject "[192.0.2.1]:65536"
assert_reject "[192.0.2.1]:https"
assert_reject "[2001:db8::1]"
assert_reject "[2001:db8::1]:53:54"
assert_reject "[2001:db8::1]:0"
assert_reject "[2001:db8::1]:65536"
assert_reject "::"
assert_reject "2001:db8::1::2"
assert_reject "2001:db8:::1"
assert_reject "gggg::1"
assert_reject "192.0.2.1#"
assert_reject "#sni.example"
assert_reject "192.0.2.1#sni.example#extra"
assert_reject "999.0.0.1#sni.example"
assert_reject "192.0.2.1#bad_host"
assert_reject "https://user:secret@example.com/path?token=hidden"
assert_reject "http://dns.example"
assert_reject "dns+https://dns.example"
assert_reject "quic://dns.example"
assert_reject "dns+doq://dns.example"
assert_reject "udp://dns.example"
assert_reject "tcp://dns.example"
assert_reject "192.0.2.1 dns.example"
assert_reject "tls://dns.example 192.0.2.1"
assert_reject "missing.example"

long_token=$(printf '%*s' 600 '' | tr ' ' a)
assert_reject "$long_token"
too_many=
for ((index = 0; index < 33; index++)); do
  too_many+="${too_many:+ }192.0.2.$((index + 1))"
done
assert_reject "$too_many"

[[ ! -e $write_log ]] || fail "custom parsing performs no writes" "$(<"$write_log")"
pass "custom DNS parsing is hermetic"
