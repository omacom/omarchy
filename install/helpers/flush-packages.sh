# Install hardware packages queued by hardware leaves, then enable any services
# whose unit files were queued alongside them.
if [[ -n ${OMARCHY_PKG_QUEUE_FILE:-} && -s $OMARCHY_PKG_QUEUE_FILE ]]; then
  OMARCHY_PKG_DEFER=0 omarchy-pkg-add
fi

if [[ -n ${OMARCHY_SERVICE_QUEUE_FILE:-} && -s $OMARCHY_SERVICE_QUEUE_FILE ]]; then
  services=()
  declare -A seen_services=()
  while IFS= read -r service; do
    [[ -n $service && -z ${seen_services[$service]+x} ]] || continue
    seen_services[$service]=1
    services+=("$service")
  done <"$OMARCHY_SERVICE_QUEUE_FILE"

  if (( ${#services[@]} > 0 )); then
    if (( EUID == 0 )); then
      systemctl enable "${services[@]}"
    else
      sudo systemctl enable "${services[@]}"
    fi
  fi
  : >"$OMARCHY_SERVICE_QUEUE_FILE"
fi
