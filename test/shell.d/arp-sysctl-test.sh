#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"
export CALL_LOG="$tmp_dir/calls"
export PATH="$tmp_dir/bin:$PATH"

conf="$ROOT/etc/sysctl.d/90-omarchy-arp.conf"
migration="$ROOT/migrations/1791147791.sh"

# The kernel takes the higher of conf/all and conf/<interface>, so "all" has to
# carry the values for interfaces that exist at boot, and "default" for the
# ones a dock or Wi-Fi adapter brings later.
for key in all default; do
  grep -Fxq "net.ipv4.conf.$key.arp_ignore=1" "$conf" && pass "$key interfaces answer ARP only for their own address" || fail "$key interfaces answer ARP only for their own address"
  grep -Fxq "net.ipv4.conf.$key.arp_announce=2" "$conf" && pass "$key interfaces announce their own address" || fail "$key interfaces announce their own address"
done
[[ -z $(grep -Ev '^(#|$|net\.ipv4\.conf\.(all|default)\.arp_(ignore|announce)=[0-9]$)' "$conf") ]] && pass "the file only sets the ARP keys" || fail "the file only sets the ARP keys"
if [[ -e /proc/sys/net/ipv4/conf/all/arp_ignore ]]; then
  [[ -e /proc/sys/net/ipv4/conf/all/arp_announce && -e /proc/sys/net/ipv4/conf/default/arp_ignore ]] && pass "the keys exist on this kernel" || fail "the keys exist on this kernel"
fi

cat > "$tmp_dir/bin/sysctl" <<'SH'
#!/bin/bash
if [[ $1 == "-n" ]]; then
  case $2 in
    net.ipv4.conf.all.arp_ignore) echo "$ARP_IGNORE" ;;
    net.ipv4.conf.all.arp_announce) echo "$ARP_ANNOUNCE" ;;
  esac
else
  echo "sysctl $*" >> "$CALL_LOG"
  [[ ${SYSCTL_FAILS:-0} == 0 ]]
fi
SH
printf '#!/bin/bash\n"$@"\n' > "$tmp_dir/bin/sudo"
printf '#!/bin/bash\necho "omarchy-state $*" >> "$CALL_LOG"\n' > "$tmp_dir/bin/omarchy-state"
chmod +x "$tmp_dir/bin/"*

run_migration() {
  : > "$CALL_LOG"
  ARP_IGNORE=$1 ARP_ANNOUNCE=$2 OMARCHY_ARP_SYSCTL_CONF="$conf" bash -euo pipefail "$migration" >/dev/null 2>&1
}

run_migration 0 0
grep -Fxq "sysctl -p $conf" "$CALL_LOG" && pass "the running system gets the shipped values" || fail "the running system gets the shipped values"

run_migration 1 2
[[ ! -s $CALL_LOG ]] && pass "an applied system is left alone" || fail "an applied system is left alone"

run_migration 1 0
grep -Fxq "sysctl -p $conf" "$CALL_LOG" && pass "a half-applied system is completed" || fail "a half-applied system is completed"

SYSCTL_FAILS=1 run_migration 0 0
grep -Fxq 'omarchy-state set reboot-required' "$CALL_LOG" && pass "a failed apply asks for a reboot instead" || fail "a failed apply asks for a reboot instead"
