#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The real command against a scratch fstab, /proc/swaps and swap subvolume,
# with the Btrfs and swap tools stubbed so nothing touches the machine.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"

cat >"$tmp/bin/findmnt" <<'SH'
#!/bin/bash
echo "${FSTYPE:-btrfs}"
SH
cat >"$tmp/bin/df" <<'SH'
#!/bin/bash
printf 'Avail\n%s\n' "${AVAIL_KB:-500000000}"
SH
cat >"$tmp/bin/btrfs" <<'SH'
#!/bin/bash
echo "btrfs $*" >>"$LOG"
case "$1 $2" in
  "subvolume show") [[ -f $3/.subvolume ]] ;;
  "subvolume create") mkdir -p "$3" && touch "$3/.subvolume" ;;
  "filesystem mkswapfile") echo "$4" >"$5" ;;
esac
SH
cat >"$tmp/bin/swaplabel" <<'SH'
#!/bin/bash
[[ -s $1 ]]
SH
cat >"$tmp/bin/swapon" <<'SH'
#!/bin/bash
echo "swapon $*" >>"$LOG"
SH
printf '#!/bin/bash\nexit 0\n' >"$tmp/bin/chattr"
chmod +x "$tmp"/bin/*

export PATH="$tmp/bin:$PATH"
export LOG="$tmp/log"
export OMARCHY_SWAP_SUBVOLUME="$tmp/swap"
export OMARCHY_FSTAB="$tmp/fstab"
export OMARCHY_SWAPS_PATH="$tmp/swaps"
export OMARCHY_MEMINFO="$tmp/meminfo"

zram_only='Filename				Type		Size		Used		Priority
/dev/zram0                              partition	8388604		0		100'

reset() {
  rm -rf "$tmp/swap" "$LOG"
  printf 'UUID=abcd / btrfs rw,subvol=/@ 0 0\n' >"$tmp/fstab"
  printf '%s\n' "$zram_only" >"$tmp/swaps"
  printf 'MemTotal:       16000000 kB\n' >"$tmp/meminfo"
}

apply() {
  "$ROOT/bin/omarchy-apply-swapfile" >"$tmp/out" 2>&1
}

swap_line="$tmp/swap/swapfile none swap defaults,nofail,pri=0 0 0"

# A fresh Btrfs install gets a RAM-sized swapfile at pri=0 that survives boot.
reset
apply || fail "apply on a fresh Btrfs root" "$(<"$tmp/out")"
grep -Fxq "$swap_line" "$tmp/fstab" || fail "the swapfile is added to fstab with nofail at pri=0" "$(<"$tmp/fstab")"
grep -Fq "filesystem mkswapfile -s 16000000k $tmp/swap/swapfile" "$LOG" || fail "the swapfile is the size of RAM" "$(<"$LOG")"
grep -Fq "swapon -p 0 $tmp/swap/swapfile" "$LOG" || fail "the swapfile is switched on" "$(<"$LOG")"
pass "a fresh Btrfs root gets a RAM-sized swapfile behind zram"

# Running again changes nothing.
apply || fail "a second apply" "$(<"$tmp/out")"
(( $(grep -Fc "$tmp/swap/swapfile" "$tmp/fstab") == 1 )) || fail "a second apply adds no second fstab line" "$(<"$tmp/fstab")"
(( $(grep -c mkswapfile "$LOG") == 1 )) || fail "a second apply makes no second swapfile" "$(<"$LOG")"
pass "applying twice is a no-op"

# Not Btrfs, existing disk swap, a foreign /swap or a nearly full disk: hands off.
reset
FSTYPE=ext4 apply || fail "apply on ext4" "$(<"$tmp/out")"
[[ ! -e $LOG ]] && ! grep -q swap "$tmp/fstab" || fail "an ext4 root is left alone" "$(<"$tmp/fstab")"

reset
printf 'UUID=ef01 none swap defaults 0 0\n' >>"$tmp/fstab"
apply || fail "apply with a swap partition" "$(<"$tmp/out")"
! grep -Fq "$tmp/swap/swapfile" "$tmp/fstab" || fail "a configured swap partition is left in charge" "$(<"$tmp/fstab")"

reset
printf '%s\n/swapfile file 4194300 0 -2\n' "$zram_only" >"$tmp/swaps"
apply || fail "apply with an active swapfile" "$(<"$tmp/out")"
! grep -Fq "$tmp/swap/swapfile" "$tmp/fstab" || fail "an active swapfile outside fstab is left in charge" "$(<"$tmp/fstab")"

reset
mkdir -p "$tmp/swap"
apply || fail "apply with a plain /swap directory" "$(<"$tmp/out")"
! grep -Fq "$tmp/swap/swapfile" "$tmp/fstab" || fail "a /swap that is not a subvolume is left alone" "$(<"$tmp/fstab")"

reset
AVAIL_KB=40000000 apply || fail "apply on a nearly full disk" "$(<"$tmp/out")"
! grep -Fq "$tmp/swap/swapfile" "$tmp/fstab" || fail "a disk with less than three times RAM free gets no swapfile" "$(<"$tmp/fstab")"
pass "non-Btrfs roots, existing swap, a foreign /swap and nearly full disks are left alone"

# A swapfile hibernation setup already made is kept and switched on.
reset
mkdir -p "$tmp/swap" && touch "$tmp/swap/.subvolume" && echo 16000000k >"$tmp/swap/swapfile"
printf '%s/swap/swapfile none swap defaults,pri=0 0 0\n' "$tmp" >>"$tmp/fstab"
apply || fail "apply over a hibernation swapfile" "$(<"$tmp/out")"
! grep -q mkswapfile "$LOG" && (( $(grep -Fc "$tmp/swap/swapfile" "$tmp/fstab") == 1 )) ||
  fail "a hibernation swapfile is reused, not recreated" "$(<"$tmp/fstab")"
grep -Fq "swapon -p 0 $tmp/swap/swapfile" "$LOG" || fail "an inactive hibernation swapfile is switched on" "$(<"$LOG")"
pass "a swapfile from hibernation setup is reused"
