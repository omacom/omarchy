#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"
export NETWORKD_TEST_DIR="$test_tmp"

cat >"$test_tmp/bin/systemctl" <<'SH'
#!/bin/bash
echo "$*" >>"$NETWORKD_TEST_DIR/systemctl.log"
[[ $1 == is-active ]] && exit 0
exit 0
SH
cat >"$test_tmp/bin/ip" <<'SH'
#!/bin/bash
[[ ${NETWORKD_TEST_ROUTE:-wlan0} == none ]] && exit 0
echo "default via 192.168.1.1 dev $NETWORKD_TEST_ROUTE proto dhcp metric 600"
SH
cat >"$test_tmp/bin/nmcli" <<'SH'
#!/bin/bash
printf '%s\n' "$NETWORKD_TEST_NM_STATES"
SH
cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH
chmod +x "$test_tmp/bin/"*

run_case() {
  local label=$1 route=$2 states=$3 expect_stop=$4
  : >"$test_tmp/systemctl.log"
  NETWORKD_TEST_ROUTE=$route NETWORKD_TEST_NM_STATES=$states OMARCHY_UPGRADE_TO_QUATTRO_LIVE=1 \
    PATH="$test_tmp/bin:$PATH" bash -euo pipefail "$ROOT/migrations/1782002156.sh" >"$test_tmp/output" 2>&1 \
    || fail "$label exits cleanly" "$(/bin/cat "$test_tmp/output")"
  if [[ $expect_stop == yes ]]; then
    grep -Fq 'disable --now systemd-networkd.service' "$test_tmp/systemctl.log" || fail "$label stops networkd"
  else
    ! grep -Fq 'disable --now' "$test_tmp/systemctl.log" || fail "$label leaves the running networkd link alone"
    grep -Fq 'disable systemd-networkd.service' "$test_tmp/systemctl.log" || fail "$label still disables networkd for next boot"
  fi
  pass "$label"
}

run_case 'NetworkManager active but default-route device unmanaged keeps networkd running' wlan0 $'wlan0:unmanaged\nlo:unmanaged' no
run_case 'NetworkManager active with no default route keeps networkd running' none 'wlan0:connected' no
run_case 'default-route device connected in NetworkManager stops networkd' wlan0 $'wlan0:connected\nlo:unmanaged' yes
