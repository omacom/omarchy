#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-boot-cmdline writes each named group of kernel parameters in the
# format of every boot loader omarchy-boot-backend says is managed. A Limine
# machine must get exactly the drop-in its leaves wrote by hand before.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"
cat >"$tmp/bin/omarchy-boot-backend" <<'SH'
#!/bin/bash
printf '%s\n' $BOOT_MANAGED
SH
chmod +x "$tmp/bin/omarchy-boot-backend"

limine=$tmp/limine-entry-tool.d
cmdline=$tmp/cmdline.d

boot_cmdline() {
  BOOT_MANAGED=$managed PATH="$tmp/bin:$ROOT/bin:$PATH" \
    OMARCHY_BOOT_LIMINE_DROPINS="$limine" OMARCHY_BOOT_CMDLINE_DIR="$cmdline" \
    omarchy-boot-cmdline "$@"
}

managed=limine
boot_cmdline set t2-mac intel_iommu=on iommu=pt
[[ $(<"$limine/t2-mac.conf") == 'KERNEL_CMDLINE[default]+=" intel_iommu=on iommu=pt"' && ! -e $cmdline ]] ||
  fail "on Limine, set writes a Limine drop-in only" "$(cat "$limine/t2-mac.conf")"
[[ $(boot_cmdline get t2-mac) == "intel_iommu=on iommu=pt" ]] || fail "on Limine, get reads the drop-in back"
# A drop-in written before, with a comment over the line, reads the same.
printf '# Intel Panther Lake FRED support\nKERNEL_CMDLINE[default]+=" fred=on"\n' >"$limine/fred.conf"
[[ $(boot_cmdline get fred) == "fred=on" ]] || fail "get skips a drop-in's comments"
[[ -z $(boot_cmdline get missing) ]] || fail "get prints nothing for a group that is not set"
pass "on Limine, set and get use the drop-in format Limine's entry tool reads"

rm -rf "$limine" "$cmdline"
managed=systemd-boot
boot_cmdline set resume resume=UUID=1234 resume_offset=42
[[ $(<"$cmdline/resume.conf") == "resume=UUID=1234 resume_offset=42" && ! -e $limine ]] ||
  fail "on systemd-boot, set writes plain parameters only" "$(cat "$cmdline/resume.conf")"
[[ $(boot_cmdline get resume) == "resume=UUID=1234 resume_offset=42" ]] || fail "on systemd-boot, get reads them back"
printf '# kept for later\n' >"$cmdline/later.conf"
out=$(boot_cmdline get later) && [[ -z $out ]] || fail "on systemd-boot, get reads a group of only comments as empty"
pass "on systemd-boot, set and get use plain /etc/cmdline.d files"

# While a switch is on trial both loaders boot, so both files are kept, and
# unset removes the group from both.
rm -rf "$limine" "$cmdline"
managed="limine systemd-boot"
boot_cmdline set rtc-alarm rtc_cmos.use_acpi_alarm=1
[[ -f $limine/rtc-alarm.conf && -f $cmdline/rtc-alarm.conf ]] || fail "during a trial, set writes both loaders' files"
boot_cmdline unset rtc-alarm
[[ ! -e $limine/rtc-alarm.conf && ! -e $cmdline/rtc-alarm.conf ]] || fail "unset removes both loaders' files"
pass "during a trial, set keeps both loaders current and unset clears both"
