#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

dns="$ROOT/bin/omarchy-dns"

# NetworkManager runs dispatcher.d entries as root, so both ends of the hook
# must name packaged paths, never a checkout a dev link could point at.
if [[ ${1:-} != "--inside" ]]; then
  grep -Fx 'NM_DISPATCHER_TARGET=/usr/bin/omarchy-dns-dispatch' "$dns" >/dev/null ||
    fail "omarchy-dns links the dispatcher hook to the packaged path"
  grep -F 'exec /usr/bin/omarchy-dns --pin-connection' "$ROOT/bin/omarchy-dns-dispatch" >/dev/null ||
    fail "dispatcher hook hands off to the packaged omarchy-dns"
  [[ -x $ROOT/bin/omarchy-dns-dispatch ]] ||
    fail "dispatcher hook is executable so NetworkManager can run it"
  pass "DNS dispatcher hook only runs packaged code"

  # omarchy-dns pins PATH and reads /etc/systemd/resolved.conf as root, so run
  # the rest once inside a private user+mount namespace with an nmcli stub over
  # /usr/local/bin and a scratch resolved.conf bound over the real one.
  if ! unshare --user --map-root-user --mount true 2>/dev/null; then
    skip "dns dispatcher checks need unprivileged user and mount namespaces"
    exit 0
  fi
  exec unshare --user --map-root-user --mount bash "$0" --inside
fi

uuid=11111111-2222-3333-4444-555555555555
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

mkdir -p "$work/bin"
cat >"$work/bin/nmcli" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$STUB_LOG"
if [[ $* == "-g connection.type,ipv4.ignore-auto-dns,ipv6.ignore-auto-dns connection show "* ]]; then
  printf '%s\n%s\n%s\n' "$STUB_TYPE" "$STUB_IGNORE4" "$STUB_IGNORE6"
fi
SH
cat >"$work/bin/systemctl" <<'SH'
#!/bin/bash
# Report every unit inactive so the provider path skips its NetworkManager
# reloads; reload/restart of resolved just succeed.
[[ $1 != "is-active" ]]
SH
chmod +x "$work/bin/nmcli" "$work/bin/systemctl"
touch "$work/resolved.conf"
mount --bind "$work/bin" /usr/local/bin
mount --bind "$work/resolved.conf" /etc/systemd/resolved.conf
mkdir -p "$work/lock" "$work/NetworkManager"
mount --bind "$work/lock" /run/lock
mount --bind "$work/NetworkManager" /etc/NetworkManager

cloudflare='[Resolve]
DNS=1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com 2606:4700:4700::1001#cloudflare-dns.com'
dhcp='[Resolve]
DNSOverTLS=no'

# pin <resolved.conf body> <connection type> <ipv4.ignore-auto-dns> [ipv6.ignore-auto-dns]
pin() {
  printf '%s\n' "$1" >"$work/resolved.conf"
  : >"$work/log"
  STUB_LOG="$work/log" STUB_TYPE="$2" STUB_IGNORE4="$3" STUB_IGNORE6="${4:-$3}" bash "$dns" --pin-connection "$uuid" wlan0
}

refute_modify() {
  if grep -q '^connection modify' "$work/log"; then
    fail "$1" "log: $(cat "$work/log")"
  fi
  pass "$1"
}

modify="connection modify $uuid ipv4.ignore-auto-dns yes ipv4.dns 1.1.1.1 1.0.0.1 ipv6.ignore-auto-dns yes ipv6.dns 2606:4700:4700::1111 2606:4700:4700::1001"

for type in 802-11-wireless 802-3-ethernet; do
  pin "$cloudflare" "$type" no
  grep -Fx "$modify" "$work/log" >/dev/null ||
    fail "dispatcher pins the provider on a new $type profile" "log: $(cat "$work/log")"
  grep -Fx 'device reapply wlan0' "$work/log" >/dev/null ||
    fail "dispatcher reapplies the device so the pinned DNS takes effect now"
done
pass "dispatcher pins the provider on Wi-Fi and Ethernet profiles that still take DHCP DNS"

for type in vpn tun wireguard; do
  pin "$cloudflare" "$type" no
  refute_modify "dispatcher leaves $type connections to the DNS they push"
done

pin "$cloudflare" 802-11-wireless yes no
grep -Fx "$modify" "$work/log" >/dev/null ||
  fail "dispatcher pins a profile whose IPv6 DNS is still automatic" "log: $(cat "$work/log")"
pass "dispatcher pins a profile whose IPv6 DNS is still automatic"

pin "$cloudflare" 802-11-wireless yes
refute_modify "dispatcher leaves an already pinned profile alone"

pin "$dhcp" 802-11-wireless no
refute_modify "dispatcher does nothing while DHCP DNS is the selected provider"

# Provider switches and the hook share one lock, so a hook can't pin servers
# from a resolved.conf a switch is about to replace. Hold the lock, start each
# side in the background, and check it has done nothing while blocked, then
# that it finishes the job once the lock is released. The child must not
# inherit the held descriptor, or releasing it here would not unlock.
hold_lock() {
  exec {held}>"$work/lock/omarchy-dns.lock"
  flock -x "$held"
}

release_lock() {
  exec {held}>&-
}

printf '%s\n' "$cloudflare" >"$work/resolved.conf"
: >"$work/log"
hold_lock
STUB_LOG="$work/log" STUB_TYPE=802-11-wireless STUB_IGNORE4=no STUB_IGNORE6=no \
  bash "$dns" --pin-connection "$uuid" wlan0 {held}>&- &
pid=$!
sleep 0.5
[[ ! -s $work/log ]] || fail "dispatcher leaves profiles alone while a provider change holds the lock" "log: $(cat "$work/log")"
release_lock
wait "$pid" || fail "dispatcher finishes once the lock is released"
grep -Fx "$modify" "$work/log" >/dev/null ||
  fail "dispatcher pins the profile once the lock is released" "log: $(cat "$work/log")"
pass "dispatcher waits for an in-flight provider change, then pins"

printf '%s\n' "$dhcp" >"$work/resolved.conf"
hold_lock
STUB_LOG="$work/log" bash "$dns" Cloudflare {held}>&- </dev/null >/dev/null 2>&1 &
pid=$!
sleep 0.5
if grep -q '^DNS=' "$work/resolved.conf"; then
  fail "provider switch leaves resolved.conf alone while the hook holds the lock"
fi
release_lock
wait "$pid" || fail "provider switch finishes once the lock is released"
grep -q '^DNS=1.1.1.1#cloudflare-dns.com' "$work/resolved.conf" ||
  fail "provider switch writes resolved.conf once the lock is released" "got: $(cat "$work/resolved.conf")"
pass "provider switch waits for an in-flight hook, then applies"
