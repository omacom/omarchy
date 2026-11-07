# Chuwi MiniBook X: sleep in S3 rather than s2idle.
#
# The firmware offers both, and the kernel picks s2idle, which does not reach
# low-power residency reliably here and drains the battery overnight. S3
# ("deep") suspends and resumes cleanly. Lid close, menu suspend and idle
# suspend all go through systemd-sleep, so no kernel parameter is needed.

sleep_config_dir=${OMARCHY_MINIBOOK_X_SLEEP_CONFIG_DIR:-/etc/systemd/sleep.conf.d}

if omarchy-hw-chuwi-minibook-x; then
  mkdir -p "$sleep_config_dir"
  cat >"$sleep_config_dir/chuwi-minibook-x.conf" <<'CONF'
# Chuwi MiniBook X: s2idle drains the battery; see
# install/hardware/chuwi/fix-minibook-x-sleep.sh.
[Sleep]
MemorySleepMode=deep
CONF
fi
