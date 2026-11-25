echo "Turn on CPPC autonomous frequency selection on the N1x so power profiles take effect"

# See install/hardware/n1x.sh, which sets up new installs the same way. The
# rule applies when cppc_cpufreq next loads, at the next boot, together with
# the power-profiles-daemon that relies on it.
rules="${OMARCHY_N1X_CPPC_RULES:-/etc/udev/rules.d/71-omarchy-n1x-cppc.rules}"

omarchy-hw-aarch64-n1x || exit 0

if [[ ! -f $rules ]]; then
  sudo install -Dm644 /dev/stdin "$rules" <<'EOF'
# N1x: the firmware hands over each core with its CPPC floor raised to its
# ceiling, so restore the full range and turn on autonomous selection, which
# programs the floor and ceiling from it; see install/hardware/n1x.sh.
ACTION=="add", SUBSYSTEM=="module", KERNEL=="cppc_cpufreq", RUN+="/usr/bin/sh -c 'for p in /sys/devices/system/cpu/cpufreq/policy*; do echo 0 >$$p/auto_select; cat $$p/cpuinfo_max_freq >$$p/scaling_max_freq; cat $$p/cpuinfo_min_freq >$$p/scaling_min_freq; echo 1 >$$p/auto_select; done'"
ACTION=="online", SUBSYSTEM=="cpu", TEST=="cpufreq/auto_select", ATTR{cpufreq/auto_select}="0", ATTR{cpufreq/scaling_max_freq}="$attr{cpufreq/cpuinfo_max_freq}", ATTR{cpufreq/scaling_min_freq}="$attr{cpufreq/cpuinfo_min_freq}", ATTR{cpufreq/auto_select}="1"
EOF
fi
