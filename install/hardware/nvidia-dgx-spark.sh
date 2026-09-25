# NVIDIA ships DGX OS with system sleep disabled on the DGX Spark, and suspend
# has not been shown to work on this hardware. Match that until it is supported.
sleep_config_dir=${OMARCHY_DGX_SPARK_SLEEP_CONFIG_DIR:-/etc/systemd/sleep.conf.d}

if omarchy-hw-dgx-spark; then
  mkdir -p "$sleep_config_dir"
  cat >"$sleep_config_dir/omarchy-dgx-spark.conf" <<'CONF'
[Sleep]
AllowSuspend=no
AllowHibernation=no
AllowSuspendThenHibernate=no
AllowHybridSleep=no
CONF
fi
