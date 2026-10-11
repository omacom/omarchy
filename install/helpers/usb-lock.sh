# Root-only policy for the opt-in lock-screen prototype. The privileged
# entrypoints set a fixed PATH and source this installed file, never a checkout.
USB_LOCK_DIR=/run/omarchy-usb-lock
USB_LOCK_ENABLED=/etc/omarchy/usb-lock.enabled
USB_LOCK_SERVICE=omarchy-usb-lock.service

usb_lock_wait_ready() {
  local attempt
  for (( attempt=0; attempt<40; attempt++ )); do
    if systemctl is-active --quiet "$USB_LOCK_SERVICE" && usbguard list-devices >/dev/null 2>&1; then return 0; fi
    sleep 0.05
  done
  return 1
}

usb_lock_write_policy() {
  local temporary
  temporary=$(mktemp "$USB_LOCK_DIR/.rules.XXXXXX") || return 1
  if cat >"$temporary" && usbguard-rule-parser -f "$temporary" >/dev/null &&
    chmod 600 "$temporary" && mv -fT "$temporary" "$USB_LOCK_DIR/rules.conf"; then
    return 0
  else
    rm -f "$temporary"
    return 1
  fi
}

usb_lock_prepare() {
  install -d -m 700 "$USB_LOCK_DIR" || return 1
  if [[ ! -e $USB_LOCK_DIR/rules.conf ]]; then
    printf '# unlocked\nallow\n' | usb_lock_write_policy || return 1
  fi
  # /run survives a daemon restart but not a reboot. Boot and the login screen
  # start permissively. No kernel command line or permanent device rules change.
  cat >"$USB_LOCK_DIR/daemon.conf" <<EOF
RuleFile=$USB_LOCK_DIR/rules.conf
ImplicitPolicyTarget=block
PresentDevicePolicy=apply-policy
PresentControllerPolicy=keep
InsertedDevicePolicy=apply-policy
AuthorizedDefault=none
RestoreControllerDeviceState=false
IPCAllowedUsers=root
EOF
  chmod 600 "$USB_LOCK_DIR/daemon.conf"
}

usb_lock_change() {
  local action=$1 inventory line rule policy first
  [[ $action == "lock" || $action == "unlock" ]] || return 64
  if [[ ! -e $USB_LOCK_ENABLED ]]; then echo off; return 0; fi
  systemctl is-active --quiet "$USB_LOCK_SERVICE" || return 1
  [[ -f $USB_LOCK_DIR/rules.conf ]] || return 1
  read -r first <"$USB_LOCK_DIR/rules.conf" || return 1

  if [[ $action == "lock" ]]; then
    # A repeated lock, shell restart or interrupted transition must reuse the
    # frozen identity list, never enroll devices that arrived while locked.
    if [[ $first != "# locked" ]]; then
      inventory=$(usbguard list-devices) || return 1
      policy=$'# locked\n'
      while IFS= read -r line; do
        [[ -n $line ]] || continue
        [[ $line =~ ^[0-9]+:[[:space:]](allow|block|reject)[[:space:]] ]] || return 1
        if [[ $line =~ ^[0-9]+:[[:space:]]allow[[:space:]] ]]; then
          rule=$(usb_authorization_portable_rule "${line#*: }") || return 1
          policy+="$rule"$'\n'
        fi
      done <<<"$inventory"
      policy+='block'
      printf '%s\n' "$policy" | usb_lock_write_policy || return 1
    fi
  else
    printf '# unlocked\nallow\n' | usb_lock_write_policy || return 1
  fi

  # Kernel default-deny remains in force while USBGuard restarts. Existing
  # devices are re-evaluated against the new policy before we acknowledge it.
  # The service preserves /run state, including the locked snapshot, on restart.
  systemctl restart "$USB_LOCK_SERVICE" || return 1
  usb_lock_wait_ready || return 1
  if [[ $action == "lock" ]]; then echo locked; else echo unlocked; fi
}

usb_lock_enable() {
  if systemctl is-active --quiet usbguard.service || systemctl is-enabled --quiet usbguard.service; then
    echo "Remove the previous Omarchy USB policy, or disable your own USBGuard service, before trying USB while locked." >&2
    return 1
  fi
  if [[ -e /etc/limine-entry-tool.d/usb-authorization.conf ]]; then
    echo "Remove USB at Boot before trying USB while locked." >&2
    return 1
  fi
  usb_lock_prepare || return 1
  install -Dm644 /dev/null "$USB_LOCK_ENABLED" || return 1
  systemctl daemon-reload || return 1
  systemctl enable --now "$USB_LOCK_SERVICE" || return 1
  usb_lock_wait_ready
}

usb_lock_disable() {
  [[ -e $USB_LOCK_ENABLED ]] || return 0
  if systemctl is-active --quiet usbguard.service; then
    echo "Another USBGuard service is active; its policy was left unchanged." >&2
    return 1
  fi
  # Reauthorize connected devices before stopping the daemon. On failure keep
  # both its enable marker and service so removal can be retried.
  if systemctl is-active --quiet "$USB_LOCK_SERVICE"; then
    usb_lock_change unlock || return 1
  fi
  systemctl disable --now "$USB_LOCK_SERVICE" || return 1
  if systemctl is-active --quiet "$USB_LOCK_SERVICE"; then return 1; fi
  omarchy-usb-authorization-restore-default || return 1
  rm -f "$USB_LOCK_ENABLED" || return 1
  rm -f "$USB_LOCK_DIR/rules.conf" "$USB_LOCK_DIR/daemon.conf"
}
