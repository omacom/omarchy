#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/memory-watermark.sh"
shipped="$ROOT/etc/sysctl.d/99-omarchy-sysctl.conf"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
cat >"$scratch/bin/sysctl" <<'SH'
#!/bin/bash
printf 'sysctl %s\n' "$*" >>"$CALL_LOG"
SH
chmod +x "$scratch/bin/sysctl"
export CALL_LOG="$scratch/calls.log"

shipped_factor=$(sed -n 's/^vm.watermark_scale_factor=//p' "$shipped")
[[ -n $shipped_factor ]] || fail "the shipped sysctl file sets the watermark scale factor"

# Runs the setup the way run_logged does, for a machine with this much
# MemTotal in kB, and prints the factor it set, or nothing.
setup_with_meminfo() {
  mkdir -p "$scratch/proc"
  printf '%s' "$1" >"$scratch/proc/meminfo"
  : >"$CALL_LOG"
  PATH="$scratch/bin:$PATH" OMARCHY_PROC_ROOT="$scratch/proc" OMARCHY_SYSCTL_CONFIG_DIR="$scratch/sysctl.d" \
    bash -eE -c 'source "$1"' bash "$setup"
}
run() {
  setup_with_meminfo "$(printf 'MemTotal:       %s kB\nMemFree:        1024 kB\n' "$1")"
  local conf
  for conf in "$scratch"/sysctl.d/*; do
    if [[ -f $conf ]]; then
      sed -n 's/^vm.watermark_scale_factor=//p' "$conf"
    fi
  done
}

for mem_kb in 16000000 32000000 33554432; do
  [[ -z $(run "$mem_kb") ]] || fail "a ${mem_kb} kB machine keeps the shipped 1.25%"
done
pass "machines up to 32 GB keep the shipped factor"

cap_kb=$((32 * 1024 * 1024 * shipped_factor / 10000))
# 33 GiB and 64 GiB, a DGX Spark, and a 2 TiB server.
for mem_kb in 34603008 67108864 127595164 2147483648; do
  factor=$(run "$mem_kb")
  [[ -n $factor ]] || fail "a ${mem_kb} kB machine gets a capped factor"
  (( factor < shipped_factor )) || fail "the cap lowers the shipped factor on a ${mem_kb} kB machine" "$factor"
  (( factor >= 10 )) || fail "the cap stays at or above the kernel default" "$factor"
  (( mem_kb * factor / 10000 <= cap_kb || factor == 10 )) ||
    fail "a ${mem_kb} kB machine's step is no larger than a 32 GB machine's" "$factor"
done
[[ $(run 34603008) == 121 ]] || fail "a 33 GiB machine's factor scales with its memory"
[[ $(run 67108864) == 62 ]] || fail "a 64 GiB machine's factor scales with its memory"
[[ $(run 127595164) == 32 ]] || fail "a DGX Spark's step falls from ~1.5 GiB to ~400 MiB"
grep -Fxq "sysctl -q -p $scratch/sysctl.d/99-omarchy-watermark.conf" "$CALL_LOG" ||
  fail "the cap applies at once, since an image's first boot runs it after systemd-sysctl"
[[ $(run 2147483648) == 10 ]] || fail "a machine too large for the cap gets the kernel default"
pass "machines over 32 GB keep a 32 GB machine's step"

before=$(run 127595164; sha256sum "$scratch"/sysctl.d/*)
after=$(run 127595164; sha256sum "$scratch"/sysctl.d/*)
[[ $before == "$after" ]] || fail "rerunning the setup leaves the file unchanged"
[[ -z $(run 16000000) ]] || fail "a machine down to 16 GB loses the stale cap"
grep -Fxq "sysctl -q -w vm.watermark_scale_factor=$shipped_factor" "$CALL_LOG" ||
  fail "removing the stale cap restores the shipped factor at once"
pass "the setup is idempotent and follows the machine's memory"

for meminfo in "" $'MemFree:        1024 kB\n' $'MemTotal:       0 kB\n'; do
  rm -rf "$scratch/sysctl.d"
  setup_with_meminfo "$meminfo" 2>/dev/null && fail "the setup fails without a usable MemTotal" "$meminfo"
  [[ ! -e $scratch/sysctl.d ]] || fail "the setup writes nothing without a usable MemTotal" "$meminfo"
done
pass "the setup fails without a usable MemTotal instead of guessing"

# systemd-sysctl applies files in name order and the last value wins.
run 127595164 >/dev/null
cp "$shipped" "$scratch/sysctl.d/"
[[ $(cd "$scratch/sysctl.d" && printf '%s\n' * | LC_ALL=C sort | tail -n 1) != "${shipped##*/}" ]] ||
  fail "the cap is read after the shipped file"
pass "the cap overrides the shipped factor"
