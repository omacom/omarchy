# Install Intel Low Power Mode Daemon for supported hybrid Intel CPUs (Alder Lake and newer)
# Supported models: Alder Lake (151/154), Raptor Lake (183/186/191),
# Meteor Lake (170/172), Lunar Lake (189), Panther Lake (204)

if omarchy-hw-intel && omarchy-battery-present; then
  cpu_model=$(grep -m1 "^model\s*:" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | tr -d ' ')
  if [[ "$cpu_model" =~ ^(151|154|170|172|183|186|189|191|204)$ ]]; then
    if [[ -n ${OMARCHY_PKG_QUEUE_FILE:-} && -n ${OMARCHY_SERVICE_QUEUE_FILE:-} ]]; then
      OMARCHY_PKG_DEFER=1 omarchy-pkg-add intel-lpmd
      printf '%s\n' intel_lpmd.service >>"$OMARCHY_SERVICE_QUEUE_FILE"
    else
      omarchy-pkg-add intel-lpmd
      sudo systemctl enable intel_lpmd.service
    fi
  fi
fi
