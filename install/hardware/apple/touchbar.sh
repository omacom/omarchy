if omarchy-hw-touchbar; then
  touchbar_owner=()
  if [[ -n ${OMARCHY_INSTALL_USER:-} ]]; then
    touchbar_owner=(--user "$OMARCHY_INSTALL_USER")
  fi
  omarchy-setup-touchbar-system "${touchbar_owner[@]}"
fi
