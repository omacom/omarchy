#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

sysctl_conf="$ROOT/etc/sysctl.d/99-omarchy-sysctl.conf"
modules_conf="$ROOT/etc/modules-load.d/bbr.conf"

grep -Eq '^[[:space:]]*net\.core\.default_qdisc[[:space:]]*=[[:space:]]*fq' "$sysctl_conf" || fail "default_qdisc is set to fq in 99-omarchy-sysctl.conf"
pass "default_qdisc is set to fq"

grep -Eq '^[[:space:]]*net\.ipv4\.tcp_congestion_control[[:space:]]*=[[:space:]]*bbr' "$sysctl_conf" || fail "tcp_congestion_control is set to bbr in 99-omarchy-sysctl.conf"
pass "tcp_congestion_control is set to bbr"

grep -Eq '^[[:space:]]*net\.ipv4\.tcp_notsent_lowat[[:space:]]*=[[:space:]]*16384' "$sysctl_conf" || fail "tcp_notsent_lowat is set to 16384 in 99-omarchy-sysctl.conf"
pass "tcp_notsent_lowat is set to 16384"

grep -Eq '^[[:space:]]*net\.ipv4\.tcp_slow_start_after_idle[[:space:]]*=[[:space:]]*0' "$sysctl_conf" || fail "tcp_slow_start_after_idle is set to 0 in 99-omarchy-sysctl.conf"
pass "tcp_slow_start_after_idle is set to 0"


[[ -f $modules_conf ]] || fail "bbr.conf exists in etc/modules-load.d/"
grep -Eq '^[[:space:]]*tcp_bbr[[:space:]]*$' "$modules_conf" || fail "tcp_bbr module is loaded in etc/modules-load.d/bbr.conf"
pass "tcp_bbr is listed in etc/modules-load.d/bbr.conf"
