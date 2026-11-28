# The GB10 firmware's ACPI _LPI table says its deeper CPU idle states (LPI-1 to
# LPI-3) take 42-433 us to leave, but leaving any of them takes ~300 us or more.
# The cpuidle governor trusts the table and parks idle cores there constantly,
# so every cross-core wakeup pays it: a pipe round trip between two idle cores
# measured 250-670 us instead of 8-20 us, and with dozens of hops per frame
# between Chromium's processes, Hyprland and the input stack the desktop crawls
# (Speedometer 3.1 scored 10). Keep the cores in the shallow WFI state
# (state0) until NVIDIA fixes the table. This is a desktop on mains power;
# idle draw goes up by an amount not yet measured.
rules_dir=${OMARCHY_UDEV_RULES_DIR:-/etc/udev/rules.d}
rules_file=$rules_dir/71-omarchy-gb10-cpuidle.rules

# Root only touches the live CPUs; tests point an unprivileged run at fixtures.
cpu_root=/sys/devices/system/cpu
if (( EUID != 0 )) && [[ -n ${OMARCHY_SYS_ROOT:-} ]]; then
  cpu_root=$OMARCHY_SYS_ROOT/devices/system/cpu
fi

if omarchy-hw-aarch64-gb10; then
  # The rule covers every later boot and any core that comes back online.
  mkdir -p "$rules_dir"
  cat >"$rules_file" <<'RULES'
# GB10: the firmware understates how long its deeper CPU idle states take to
# leave, so keep each core in state0 (WFI); see install/hardware/gb10/cpuidle.sh.
ACTION=="add|online", SUBSYSTEM=="cpu", TEST=="cpuidle/state1", RUN+="/usr/bin/sh -c 'for f in /sys$devpath/cpuidle/state[1-9]*/disable; do echo 1 >$$f; done'"
RULES

  # The CPUs were already added by the time this runs, on an image's first boot
  # as much as from a migration, so apply it to the running cores as well. A
  # chroot or image build without writable CPU attributes skips this.
  for disable in "$cpu_root"/cpu[0-9]*/cpuidle/state[1-9]*/disable; do
    [[ -w $disable ]] || continue
    echo 1 >"$disable"
  done
fi
