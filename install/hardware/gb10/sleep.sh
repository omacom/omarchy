# NVIDIA ships DGX OS with system sleep off, and suspend has not been shown to
# work on GB10 machines. Match that until it is supported.
sleep_config_dir=${OMARCHY_SLEEP_CONFIG_DIR:-/etc/systemd/sleep.conf.d}

if omarchy-hw-aarch64-gb10; then
  mkdir -p "$sleep_config_dir"
  cat >"$sleep_config_dir/omarchy-sleep-disabled.conf" <<'CONF'
[Sleep]
AllowSuspend=no
AllowHibernation=no
AllowSuspendThenHibernate=no
AllowHybridSleep=no
CONF
fi
