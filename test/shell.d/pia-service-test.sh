#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"
export TEST_LOG="$tmp_dir/log"
export LOGIN_ATTEMPTS="$tmp_dir/login-attempts"

# Package management, the daemon and the prompts are stubbed; the script's job
# is what it asks for.
for stub in omarchy-pkg-aur-add sudo; do
  cat >"$tmp_dir/bin/$stub" <<SCRIPT
#!/bin/bash
printf '%s:%s\n' "$stub" "\$*" >>"\$TEST_LOG"
SCRIPT
done

# Records how the login file arrived (pipe or file on disk) and what it held,
# failing the first LOGIN_FAILURES attempts.
cat >"$tmp_dir/bin/piactl" <<'SCRIPT'
#!/bin/bash
if [[ $1 == "login" ]]; then
  if [[ -p $2 ]]; then kind=pipe; else kind=file; fi
  printf 'piactl:login:%s:%s\n' "$kind" "$(paste -sd: "$2")" >>"$TEST_LOG"
  echo >>"$LOGIN_ATTEMPTS"
  (( $(wc -l <"$LOGIN_ATTEMPTS") > ${LOGIN_FAILURES:-0} ))
else
  printf 'piactl:%s\n' "$*" >>"$TEST_LOG"
fi
SCRIPT

cat >"$tmp_dir/bin/gum" <<'SCRIPT'
#!/bin/bash
case "$1" in
  input) if [[ " $* " == *" --password "* ]]; then echo "secret"; else echo "p1234567"; fi ;;
  confirm) exit 1 ;;
esac
SCRIPT

chmod +x "$tmp_dir/bin/"*
export PATH="$tmp_dir/bin:$PATH"

output=$("$ROOT/bin/omarchy-install-service-pia")
expected='omarchy-pkg-aur-add:piavpn-bin
sudo:systemctl enable --now piavpn.service
piactl:background enable
piactl:login:pipe:p1234567:secret'
[[ $(cat "$TEST_LOG") == "$expected" ]] ||
  fail "install adds piavpn-bin, starts the daemon, enables background mode, and logs in" "$(cat "$TEST_LOG")"
[[ $output == *"PIA installed!"* ]] ||
  fail "install says how to connect" "$output"
pass "install adds piavpn-bin, starts the daemon, and logs in through a pipe instead of a file"

: >"$TEST_LOG"
: >"$LOGIN_ATTEMPTS"
output=$(LOGIN_FAILURES=1 "$ROOT/bin/omarchy-install-service-pia")
(( $(grep -c '^piactl:login:' "$TEST_LOG") == 2 )) ||
  fail "install asks again after a failed login" "$(cat "$TEST_LOG")"
[[ $output == *"Login failed, try again."* ]] ||
  fail "install says the login failed" "$output"
pass "install asks for the login again when it fails"

# The region picker offers what piactl lists and connects to the pick.
cat >"$tmp_dir/bin/piactl" <<'SCRIPT'
#!/bin/bash
if [[ $* == "get regions" ]]; then
  printf '%s\n' auto ca-montreal us-atlanta
else
  printf 'piactl:%s\n' "$*" >>"$TEST_LOG"
fi
SCRIPT
cat >"$tmp_dir/bin/omarchy-menu-select" <<'SCRIPT'
#!/bin/bash
[[ $(paste -sd,) == "auto,ca-montreal,us-atlanta" ]] && echo "ca-montreal"
SCRIPT
chmod +x "$tmp_dir/bin/"*

: >"$TEST_LOG"
"$ROOT/bin/omarchy-menu-pia-region"
expected='piactl:set region ca-montreal
piactl:connect'
[[ $(cat "$TEST_LOG") == "$expected" ]] ||
  fail "region picker sets the picked region and connects" "$(cat "$TEST_LOG")"
pass "region picker sets the picked region and connects"
