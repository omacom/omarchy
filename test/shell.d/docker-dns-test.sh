#!/bin/bash
#
# Docker's bridge, the containers' DNS server, the systemd-resolved stub they
# query and the firewall rules that let them reach it must all name one
# address, and it must not be 172.17.0.1: a stub listener there makes resolved
# refuse a router at 172.17.0.1 as "Configured DNS server loops back to us".
# The migration moves an existing install's firewall rules and resolved stub
# over, once per machine; sudo, ufw and systemctl are stubbed.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command jq

migration="$ROOT/migrations/1791897817.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

bip=$(jq -r '.bip' "$ROOT/etc/docker/daemon.json")
gateway=${bip%/*}

[[ $gateway != 172.17.* ]] || fail "Docker's bridge is still on 172.17.0.0/16" "bip: $bip"
pass "Docker's bridge is off 172.17.0.0/16"

# Omarchy files that still name the old address. The migration has to, to find
# the old rules, and so does this test.
stale=$(grep -rnIF --exclude-dir=.git --exclude=1791897817.sh --exclude=docker-dns-test.sh '172.17.0.1' "$ROOT" || true)
[[ -z $stale ]] || fail "Omarchy files still use 172.17.0.1 for Docker DNS" "$stale"
pass "no Omarchy file uses 172.17.0.1 for Docker DNS"

[[ $(jq -c '.dns' "$ROOT/etc/docker/daemon.json") == "[\"$gateway\"]" ]] ||
  fail "daemon.json sends containers to a DNS server other than the bridge gateway $gateway"
pass "daemon.json sends containers to the bridge gateway for DNS"

stub=$(sed -n 's/^DNSStubListenerExtra=//p' "$ROOT/etc/systemd/resolved.conf.d/20-docker-dns.conf")
[[ $stub == "$gateway" ]] || fail "resolved listens on $stub, not the bridge gateway $gateway"
pass "resolved's extra stub listens on the bridge gateway"

firewall_rules=$(grep "allow-docker-dns" "$ROOT/install/config/firewall.sh")
[[ -n $firewall_rules ]] || fail "firewall.sh no longer lets containers reach the DNS stub"
if grep -v -- " to $gateway port 53 " <<<"$firewall_rules"; then
  fail "a firewall rule for container DNS names an address other than $gateway"
fi
pass "the firewall rules for container DNS name the bridge gateway"

# The 3.x upgrade writes its own copy of the two files.
upgrade="$ROOT/bin/omarchy-upgrade-to-quattro"
grep -qxF "DNSStubListenerExtra=$gateway" "$upgrade" &&
  grep -qF "\"dns\": [\"$gateway\"]," "$upgrade" &&
  grep -qF "\"bip\": \"$bip\"" "$upgrade" ||
  fail "omarchy-upgrade-to-quattro writes Docker DNS settings that differ from the packaged ones"
pass "omarchy-upgrade-to-quattro writes the packaged Docker DNS settings"

grep -qx "new_gateway=$gateway" "$migration" || fail "the migration moves the rules somewhere other than $gateway"
pass "the migration moves the rules to the bridge gateway"

stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

# sudo records that it was needed and drops the prefix.
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
echo "$*" >>"${SUDO_CALLS:?}"
exec "$@"
STUB

# ufw keeps its added rules in a file and prints them as `ufw show added`
# does: `allow in ... proto udp` comes back as `allow ... port 53 proto udp`.
cat >"$stub_bin/ufw" <<'STUB'
#!/bin/bash
[[ -z ${UFW_FAILS:-} ]] || exit 1
[[ ${UFW_FAILS_ON:-} != "$1" ]] || exit 1
rules=${UFW_RULES:?}

rule() {
  local action=$1 from="" to="" port="" proto="" comment=""
  shift
  while (( $# )); do
    case $1 in
      in) shift ;;
      from) from=$2; shift 2 ;;
      to) to=$2; shift 2 ;;
      port) port=$2; shift 2 ;;
      proto) proto=$2; shift 2 ;;
      comment) comment=$2; shift 2 ;;
      *) echo "ufw stub: unexpected $1" >&2; exit 2 ;;
    esac
  done
  printf "ufw %s from %s to %s port %s proto %s comment '%s'\n" "$action" "$from" "$to" "$port" "$proto" "$comment"
}

case $1 in
  show)
    echo "Added user rules (see 'ufw status' for running firewall):"
    cat "$rules"
    ;;
  delete)
    shift
    line=$(rule "$@")
    grep -vxF "$line" "$rules" >"$rules.new" || true
    mv "$rules.new" "$rules"
    ;;
  allow)
    line=$(rule "$@")
    grep -qxF "$line" "$rules" || echo "$line" >>"$rules"
    ;;
  *) echo "ufw stub: unexpected $1" >&2; exit 2 ;;
esac
STUB

# systemctl records what it was asked; Docker is running when told to be.
cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
echo "$*" >>"${SYSTEMCTL_CALLS:?}"
if [[ $1 == "is-active" ]]; then
  [[ -n ${DOCKER_ACTIVE:-} ]]
fi
STUB

# A machine without ufw, even when the one running the test has it.
cat >"$stub_bin/omarchy-cmd-present" <<'STUB'
#!/bin/bash
[[ $1 == "ufw" && -n ${UFW_MISSING:-} ]] && exit 1
command -v "$1" >/dev/null
STUB
chmod +x "$stub_bin"/*

localsend="ufw allow 53317/udp"
old_rules=$(printf '%s\n' \
  "$localsend" \
  "ufw allow from 172.16.0.0/12 to 172.17.0.1 port 53 proto udp comment 'allow-docker-dns'" \
  "ufw allow from 192.168.0.0/16 to 172.17.0.1 port 53 proto udp comment 'allow-docker-dns'")

migrate() {
  PATH="$stub_bin:$PATH" UFW_RULES="$test_dir/rules" SUDO_CALLS="$test_dir/sudo" \
    SYSTEMCTL_CALLS="$test_dir/systemctl" OMARCHY_DOCKER_DNS_MARKER="$test_dir/marker" \
    OMARCHY_DOCKER_DNS_DAEMON_JSON="$test_dir/daemon.json" \
    OMARCHY_DOCKER_DNS_RESOLVED_DROPIN="$test_dir/20-docker-dns.conf" \
    bash -euo pipefail "$migration"
}

run() { # starting rules, then optionally the installed daemon.json and drop-in; prints what the migration printed
  printf '%s\n' "$1" >"$test_dir/rules"
  cp "${2:-$ROOT/etc/docker/daemon.json}" "$test_dir/daemon.json"
  cp "${3:-$ROOT/etc/systemd/resolved.conf.d/20-docker-dns.conf}" "$test_dir/20-docker-dns.conf"
  : >"$test_dir/sudo"
  : >"$test_dir/systemctl"
  migrate
}

# What a fresh install's firewall.sh adds, run through the same stub.
: >"$test_dir/rules"
while read -r command; do
  eval "UFW_RULES=$test_dir/rules $stub_bin/$command"
done <<<"$firewall_rules"
fresh_rules=$(<"$test_dir/rules")

if UFW_FAILS=1 run "$old_rules" >/dev/null 2>&1; then
  fail "a ufw that could not be read was reported as a success"
fi
[[ ! -e $test_dir/marker ]] || fail "a failed firewall move was marked as done"
pass "a ufw failure stops the migration and leaves no marker"

# A run cut short between adding a new rule and removing the old one leaves
# the old one in place to be found again.
if UFW_FAILS_ON=allow run "$old_rules" >/dev/null 2>&1; then
  fail "a ufw allow that failed was reported as a success"
fi
[[ ! -e $test_dir/marker ]] || fail "a failed rule move was marked as done"
grep -qF "to 172.17.0.1 " "$test_dir/rules" || fail "an interrupted run lost the old rule it still had to move"
migrate >/dev/null
grep -qF "to 172.17.0.1 " "$test_dir/rules" && fail "a rerun after an interrupted move left the old rule"
[[ $(grep -v "$localsend" "$test_dir/rules") == "$fresh_rules" ]] ||
  fail "a rerun after an interrupted move did not finish it" "$(cat "$test_dir/rules")"
pass "an interrupted firewall move stays pending and finishes on the next run"

rm "$test_dir/marker"
run "$old_rules" >"$test_dir/out"
! grep -qF "to 172.17.0.1 " "$test_dir/rules" || fail "an old firewall rule was left behind"
[[ $(grep -v "$localsend" "$test_dir/rules") == "$fresh_rules" ]] ||
  fail "the migrated firewall rules differ from a fresh install's" "$(cat "$test_dir/rules")"
grep -qxF "$localsend" "$test_dir/rules" || fail "the migration dropped an unrelated firewall rule"
grep -qxF "try-restart systemd-resolved.service" "$test_dir/systemctl" ||
  fail "resolved was not restarted, so it still listens on 172.17.0.1"
[[ -e $test_dir/marker ]] || fail "the machine was not marked as migrated"
pass "the old rules are replaced with a fresh install's and resolved is restarted"

if grep -q "restart docker" "$test_dir/out" || grep -q "restart docker" "$test_dir/systemctl"; then
  fail "Docker was restarted or flagged while it was not running"
fi
pass "a stopped Docker is left to pick up the new bridge when it starts"

run "$old_rules" >/dev/null
[[ ! -s $test_dir/sudo && $(<"$test_dir/rules") == "$old_rules" ]] ||
  fail "a second account repeated the machine-wide move"
pass "the move runs once per machine, not once per user"

rm "$test_dir/marker"
run "$localsend" >/dev/null
[[ $(<"$test_dir/rules") == "$localsend" ]] || fail "rules the owner had deleted were added back"
grep -qxF "try-restart systemd-resolved.service" "$test_dir/systemctl" || fail "resolved was not restarted"
pass "a machine without the old rules gets none added, and resolved is still restarted"

rm "$test_dir/marker"
UFW_MISSING=1 run "$old_rules" >/dev/null
[[ $(<"$test_dir/rules") == "$old_rules" && -e $test_dir/marker ]] ||
  fail "a machine without ufw was not handled"
grep -qxF "try-restart systemd-resolved.service" "$test_dir/systemctl" || fail "resolved was not restarted"
pass "a machine without ufw only restarts resolved"

rm "$test_dir/marker"
DOCKER_ACTIVE=1 run "$old_rules" >"$test_dir/out"
grep -qF "sudo systemctl restart docker" "$test_dir/out" || fail "a running Docker was not flagged for a restart"
! grep -q "restart docker" "$test_dir/systemctl" || fail "a running Docker was restarted, stopping its containers"
pass "a running Docker is flagged for a restart, not restarted"

rm "$test_dir/marker"
run "$old_rules" >/dev/null
[[ $(<"$test_dir/daemon.json") == "$(<"$ROOT/etc/docker/daemon.json")" ]] ||
  fail "the migration rewrote a daemon.json the package had already moved"
pass "a daemon.json the package moved is left alone"

# pacman keeps an edited copy and writes the new defaults to a .pacnew beside it.
jq '. + {"data-root": "/srv/docker", "dns": ["172.17.0.1", "9.9.9.9"], "bip": "172.17.0.1/16"}' \
  "$ROOT/etc/docker/daemon.json" >"$test_dir/edited-daemon.json"
printf '[Resolve]\nDNSStubListenerExtra = 172.17.0.1\nDNSStubListenerExtra=10.0.0.1\n' >"$test_dir/edited-dropin.conf"
rm "$test_dir/marker"
run "$old_rules" "$test_dir/edited-daemon.json" "$test_dir/edited-dropin.conf" >/dev/null
[[ $(jq -c '[.dns, .bip, ."data-root"]' "$test_dir/daemon.json") == "[[\"$gateway\",\"9.9.9.9\"],\"$bip\",\"/srv/docker\"]" ]] ||
  fail "an edited daemon.json was not moved onto $gateway with the owner's settings kept" "$(cat "$test_dir/daemon.json")"
[[ $(<"$test_dir/20-docker-dns.conf") == $'[Resolve]\nDNSStubListenerExtra='"$gateway"$'\nDNSStubListenerExtra=10.0.0.1' ]] ||
  fail "an edited resolved drop-in was not moved onto $gateway with the owner's settings kept" "$(cat "$test_dir/20-docker-dns.conf")"
pass "edited copies of daemon.json and the drop-in are moved, keeping the owner's settings"

echo '{ "dns": ["172.17.0.1"], ' >"$test_dir/broken-daemon.json"
rm "$test_dir/marker"
run "$old_rules" "$test_dir/broken-daemon.json" >"$test_dir/out" 2>&1
grep -qF "point its dns and bip at $gateway by hand" "$test_dir/out" || fail "a daemon.json jq could not read was not reported"
[[ $(<"$test_dir/daemon.json") == "$(<"$test_dir/broken-daemon.json")" && -e $test_dir/marker ]] ||
  fail "a daemon.json jq could not read was changed, or held up the migration"
pass "a daemon.json that is not JSON is reported and left alone"
