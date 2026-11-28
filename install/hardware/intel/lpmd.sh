# Install Intel Low Power Mode Daemon for supported hybrid Intel CPUs (Alder Lake and newer)
# Supported models: Alder Lake (151/154), Meteor Lake (170/172), Arrow Lake-U (181),
# Raptor Lake (183/186/191), Lunar Lake (189), Panther Lake (204), Wildcat Lake (213)

if omarchy-hw-intel && omarchy-battery-present; then
  cpu_model=$(grep -m1 "^model\s*:" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | tr -d ' ')
  if [[ $cpu_model =~ ^(151|154|170|172|181|183|186|189|191|204|213)$ ]]; then
    if [[ -n ${OMARCHY_PKG_QUEUE_FILE:-} && -n ${OMARCHY_SERVICE_QUEUE_FILE:-} ]]; then
      OMARCHY_PKG_DEFER=1 omarchy-pkg-add intel-lpmd
      printf '%s\n' intel_lpmd.service >>"$OMARCHY_SERVICE_QUEUE_FILE"
    else
      omarchy-pkg-add intel-lpmd
      sudo systemctl enable intel_lpmd.service
    fi

    # Upstream intel-lpmd ships Meteor Lake-L/P/U/H (F6_M170) disabled by default
    # (BalancedDef=-1, PowersaverDef=-1); model 172 (Meteor Lake-S) has no F6_M172
    # upstream WLT Proxy profile and is left untouched. Point intel_lpmd at
    # /etc/intel_lpmd/omarchy-mtl.xml (Mode=-1, BalancedDef=0, PowersaverDef=0)
    # via -c so package upgrades never overwrite it and all TDP SKUs use it.
    # Flags mirror upstream intel_lpmd.service (--systemd --dbus-enable).
    if [[ $cpu_model == "170" ]]; then
      mkdir -p /etc/systemd/system/intel_lpmd.service.d
      cat >/etc/systemd/system/intel_lpmd.service.d/10-omarchy-mtl.conf <<'CONF'
[Service]
ExecStart=
ExecStart=/usr/bin/intel_lpmd --systemd --dbus-enable -c /etc/intel_lpmd/omarchy-mtl.xml
CONF
    fi
  fi
fi
