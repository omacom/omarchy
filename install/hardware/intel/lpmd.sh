# Install Intel Low Power Mode Daemon for supported hybrid Intel CPUs (Alder Lake and newer)
# Supported models: Alder Lake (151/154), Raptor Lake (183/186/191),
# Meteor Lake (170/172), Lunar Lake (189), Panther Lake (204)

if omarchy-hw-intel && omarchy-battery-present; then
  cpuinfo_path=${OMARCHY_CPUINFO_PATH:-/proc/cpuinfo}
  cpu_model=$(grep -m1 "^model[[:space:]]*:" "$cpuinfo_path" 2>/dev/null | cut -d: -f2 | tr -d ' ')
  if [[ "$cpu_model" =~ ^(151|154|170|172|183|186|189|191|204)$ ]]; then
    if [[ -n ${OMARCHY_PKG_QUEUE_FILE:-} && -n ${OMARCHY_SERVICE_QUEUE_FILE:-} ]]; then
      OMARCHY_PKG_DEFER=1 omarchy-pkg-add intel-lpmd
      printf '%s\n' intel_lpmd.service >>"$OMARCHY_SERVICE_QUEUE_FILE"
    else
      omarchy-pkg-add intel-lpmd
      sudo systemctl enable intel_lpmd.service
    fi

    # Upstream intel-lpmd ships Meteor Lake (F6_M170) disabled by default
    # (BalancedDef=-1, PowersaverDef=-1). Ship an Omarchy config enabling WLT
    # Proxy dynamic EPP/EPB switching in balanced and power-saver while keeping
    # Mode=-1 (no cpuset confinement: Mode=0 with WLTProxy traps bursts on the
    # two LP-E cores because WLTProxy reads P/E-core load to exit LP mode).
    # Point the service at it via -c so package upgrades never overwrite it and
    # all TDP SKUs (T0/T9/T15/T28/T45) use the same config.
    if [[ $cpu_model == "170" ]]; then
      lpmd_conf_dir=${OMARCHY_INTEL_LPMD_CONF_DIR:-/etc/intel_lpmd}
      lpmd_unit_dir=${OMARCHY_INTEL_LPMD_UNIT_DIR:-/etc/systemd/system/intel_lpmd.service.d}
      lpmd_conf_path="$lpmd_conf_dir/omarchy-mtl.xml"

      mkdir -p "$lpmd_conf_dir" "$lpmd_unit_dir"

      cat >"$lpmd_conf_path" <<'XML'
<?xml version="1.0"?>

<!--
Omarchy configuration for Intel Energy Optimizer (LPMD) on Meteor Lake (F6_M170).
Enables WLT Proxy dynamic EPP/EPB switching in Balanced and Power-saver modes
without cgroup cpuset confinement (Mode=-1).
-->

<Configuration>
    <lp_mode_cpus></lp_mode_cpus>
    <Mode>-1</Mode>
    <PerformanceDef>-1</PerformanceDef>
    <BalancedDef>0</BalancedDef>
    <PowersaverDef>0</PowersaverDef>
    <HfiLpmEnable>0</HfiLpmEnable>
    <WLTHintEnable>1</WLTHintEnable>
    <WLTProxyEnable>1</WLTProxyEnable>
    <HfiSuvEnable>0</HfiSuvEnable>
    <util_entry_threshold></util_entry_threshold>
    <util_exit_threshold></util_exit_threshold>
    <EntryDelayMS>0</EntryDelayMS>
    <ExitDelayMS>0</ExitDelayMS>
    <EntryHystMS>0</EntryHystMS>
    <ExitHystMS>0</ExitHystMS>
    <IgnoreITMT>0</IgnoreITMT>
    <IntelPstateMode>0</IntelPstateMode>

    <States>
        <CPUFamily> 6 </CPUFamily>
        <CPUModel> 170 </CPUModel>
        <CPUConfig> * </CPUConfig>
        <State>
            <ID> 1 </ID>
            <Name> WLT_IDLE </Name>
            <WLTType> 0 </WLTType>
            <EPP> 255 </EPP>
            <EPB> 15 </EPB>
            <MinPollInterval>2000</MinPollInterval>
            <ITMTState> -1 </ITMTState>
            <IRQMigrate> -1 </IRQMigrate>
        </State>
        <State>
            <ID> 2 </ID>
            <Name> WLT_BATTERY_LIFE </Name>
            <WLTType> 1 </WLTType>
            <EPP> 178 </EPP>
            <EPB> 6 </EPB>
            <MinPollInterval>2000</MinPollInterval>
            <ITMTState> -1 </ITMTState>
            <IRQMigrate> -1 </IRQMigrate>
        </State>
        <State>
            <ID> 3 </ID>
            <Name> WLT_SUSTAINED </Name>
            <WLTType> 2 </WLTType>
            <EPP> 64 </EPP>
            <EPB> 6 </EPB>
            <MinPollInterval>2000</MinPollInterval>
            <ITMTState> -1 </ITMTState>
            <IRQMigrate> -1 </IRQMigrate>
        </State>
        <State>
            <ID> 4 </ID>
            <Name> WLT_BURSTY </Name>
            <WLTType> 3 </WLTType>
            <EPP> 64 </EPP>
            <EPB> 4 </EPB>
            <MinPollInterval>2000</MinPollInterval>
            <ITMTState> -1 </ITMTState>
            <IRQMigrate> -1 </IRQMigrate>
        </State>
    </States>
</Configuration>
XML

      cat >"$lpmd_unit_dir/10-omarchy-mtl.conf" <<'CONF'
[Service]
ExecStart=
ExecStart=/usr/bin/intel_lpmd --systemd --dbus-enable -c /etc/intel_lpmd/omarchy-mtl.xml
CONF
    fi
  fi
fi
