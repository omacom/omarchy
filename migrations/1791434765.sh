echo "Remove stale ACPI RTC alarm drop-in that forced use_acpi_alarm on all systems"

# The commit ecf48a3 added an /etc/limine-entry-tool.d/rtc-alarm.conf that
# unconditionally set rtc_cmos.use_acpi_alarm=1. That was reverted in
# PR #14113 (deferring to the kernel's use_acpi_alarm_quirks), but
# omarchy-hibernation-setup only removes the file during a re-run of the
# command. Existing installs that already had hibernation set up would keep
# the stale file forever.
#
# This migration cleans those up with a content hash check so that anyone
# who edited the file keeps their version. Removing the drop-in already
# makes this migration a no-op for every later run.

rtc_alarm_drop_in="/etc/limine-entry-tool.d/rtc-alarm.conf"
expected_hash="c9469cd9ba4c0f74f8ce6fe4afeac4414741a3536ce8693838047f15487fd1c8"

[[ -f $rtc_alarm_drop_in ]] || exit 0
[[ $(sha256sum "$rtc_alarm_drop_in" | awk '{print $1}') == "$expected_hash" ]] || exit 0

echo "Removing stale ACPI RTC alarm drop-in ($rtc_alarm_drop_in)"
sudo rm -f -- "$rtc_alarm_drop_in"
if omarchy-cmd-present limine-mkinitcpio; then
  sudo limine-mkinitcpio || {
    echo "Error: Failed to rebuild boot entries after removing stale RTC drop-in" >&2
    exit 1
  }
  omarchy-state set reboot-required
fi
