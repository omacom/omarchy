# shellcheck shell=bash
# Root-only USB policy. The privileged
# entrypoints set a fixed PATH and source this installed file, never a checkout.
USB_LOCK_DIR=/run/omarchy-usb-lock
USB_LOCK_ENABLED=/etc/omarchy/usb-lock.enabled
USB_LOCK_SERVICE=omarchy-usb-lock.service
USB_LOCK_SYSFS=/sys/bus/usb/devices
USB_LOCK_UNIT=/etc/systemd/system/omarchy-usb-lock.service
USB_LOCK_POLKIT=/etc/polkit-1/rules.d/40-omarchy-usb-lock.rules
USB_LOCK_DISABLED=/etc/omarchy/usb-lock.disabled
USB_LOCK_APPROVAL=/etc/omarchy/usb-lock.approval
USB_LOCK_TRUST=/var/lib/omarchy/usb-lock
USB_LOCK_WATCH=/etc/systemd/user/omarchy-usb-lock-watch.service

# Reconnection during a lock depends on device identity, not its port or hub.
usb_lock_portable_rule() {
  local rule="$1" token="" char quoted=0 escaped=0 index
  local -a tokens=() portable=()

  # Split canonical USBGuard output without evaluating device-controlled text.
  # An attribute name inside a quoted name/serial is never a rule attribute.
  for (( index=0; index<${#rule}; index++ )); do
    char=${rule:index:1}
    if (( escaped )); then
      token+="$char"
      escaped=0
    elif (( quoted )) && [[ $char == '\' ]]; then
      token+="$char"
      escaped=1
    elif [[ $char == '"' ]]; then
      token+="$char"
      quoted=$((1 - quoted))
    elif (( ! quoted )) && [[ $char == " " ]]; then
      if [[ -n $token ]]; then tokens+=("$token"); token=""; fi
    else
      token+="$char"
    fi
  done
  (( ! quoted && ! escaped )) || return 1
  if [[ -n $token ]]; then tokens+=("$token"); fi
  [[ ${tokens[0]:-} == "allow" || ${tokens[0]:-} == "block" ]] || return 1
  portable=(allow)
  for (( index=1; index<${#tokens[@]}; index++ )); do
    case "${tokens[index]}" in
    via-port | parent-hash)
      (( ++index < ${#tokens[@]} )) || return 1
      [[ ${tokens[index]} == \"*\" ]] || return 1
      ;;
    label) return 1 ;;
    *) portable+=("${tokens[index]}") ;;
    esac
  done
  local IFS=" "
  printf '%s\n' "${portable[*]}"
}

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
  install -d -m 700 "$USB_LOCK_DIR/ipc" || return 1
  # Desktop users can observe policy, but only the protected root helper can
  # approve devices. Never grant USBGuard's broad modify privilege to wheel.
  printf 'Devices=list,listen\nPolicy=list\nExceptions=listen\n' >"$USB_LOCK_DIR/ipc/:wheel" || return 1
  chmod 600 "$USB_LOCK_DIR/ipc/:wheel" || return 1
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
IPCAccessControlFiles=$USB_LOCK_DIR/ipc
EOF
  chmod 600 "$USB_LOCK_DIR/daemon.conf"
}

usb_lock_rules() {
  local file
  for file in "$USB_LOCK_TRUST/approved.conf" "$USB_LOCK_DIR/session.conf"; do
    if [[ -f $file ]]; then cat "$file" || return 1; fi
  done
}

usb_lock_capture() {
  local inventory=$1 include_blocked=$2 line
  while IFS= read -r line; do
    [[ -n $line ]] || continue
    [[ $line =~ ^[0-9]+:[[:space:]](allow|block|reject)[[:space:]] ]] || return 1
    if [[ ${BASH_REMATCH[1]} == "allow" || ( $include_blocked == "1" && ${BASH_REMATCH[1]} == "block" ) ]]; then
      usb_lock_portable_rule "${line#*: }" || return 1
    fi
  done <<<"$inventory"
}

usb_lock_waiting_inventory() {
  local inventory=$1 line portable denied=""
  # Compare complete canonical identities, stripping only location. Moving an
  # already denied device to another port must not grant automatic approval.
  if [[ -f $USB_LOCK_DIR/denied-before-lock.conf ]]; then
    denied=$(cat "$USB_LOCK_DIR/denied-before-lock.conf") || return 1
  fi
  while IFS= read -r line; do
    [[ -n $line ]] || continue
    [[ $line =~ ^[0-9]+:[[:space:]](allow|block)[[:space:]] ]] || continue
    portable=$(usb_lock_portable_rule "${line#*: }") || return 1
    if grep -Fqx -- "$portable" <<<"$denied"; then
      continue
    fi
    printf '%s\n' "$line"
  done <<<"$inventory"
}

usb_lock_save_rules() {
  local destination=$1 temporary
  temporary=$(mktemp "${destination%/*}/.rules.XXXXXX") || return 1
  if sort -u >"$temporary" && usbguard-rule-parser -f "$temporary" >/dev/null &&
    chmod 600 "$temporary" && mv -fT "$temporary" "$destination"; then
    return 0
  else
    rm -f "$temporary"
    return 1
  fi
}

usb_lock_change() {
  local action=$1 inventory captured policy first include_blocked=0
  [[ $action == "lock" || $action == "unlock" ]] || return 64
  if [[ ! -e $USB_LOCK_ENABLED ]]; then echo off; return 0; fi
  # A failed restart can leave the service inactive or rate-limited. The saved
  # locked policy is sufficient to retry; never recapture it from new arrivals.
  if systemctl is-active --quiet usbguard.service || systemctl is-active --quiet usbguard-dbus.service; then return 1; fi
  [[ -f $USB_LOCK_DIR/rules.conf ]] || return 1
  read -r first <"$USB_LOCK_DIR/rules.conf" || return 1

  if [[ $action == "lock" ]]; then
    # A repeated lock, shell restart or interrupted transition must reuse the
    # frozen identity list, never enroll devices that arrived while locked.
    if [[ $first != "# locked" ]]; then
      inventory=$(usbguard list-devices) || return 1
      policy=$'# locked\n'
      captured=$(usb_lock_capture "$inventory" 0) || return 1
      { usb_lock_rules && printf '%s\n' "$captured"; } | usb_lock_save_rules "$USB_LOCK_DIR/session.conf" || return 1
      captured=$(usb_lock_rules) || return 1
      policy+="$captured"$'\n'
      if [[ -e $USB_LOCK_APPROVAL ]]; then
        captured=$(usbguard list-devices --blocked) || return 1
        captured=$(usb_lock_capture "$captured" 1) || return 1
        printf '%s\n' "$captured" | usb_lock_save_rules "$USB_LOCK_DIR/denied-before-lock.conf" || return 1
      else
        rm -f "$USB_LOCK_DIR/denied-before-lock.conf" || return 1
      fi
      policy+='block'
      printf '%s\n' "$policy" | usb_lock_write_policy || return 1
    fi
  else
    # Both modes retain unlock admission until reboot, even while a device is
    # disconnected. Repeated unlocks must not approve later optional arrivals.
    if [[ $first == "# locked" || ( -e $USB_LOCK_APPROVAL && $first != "# approval" ) ]]; then
      if ! systemctl is-active --quiet "$USB_LOCK_SERVICE"; then
        systemctl reset-failed "$USB_LOCK_SERVICE" || return 1
        systemctl restart "$USB_LOCK_SERVICE" || return 1
        usb_lock_wait_ready || return 1
      fi
      inventory=$(usbguard list-devices) || return 1
      if [[ $first == "# locked" ]]; then
        include_blocked=1
        inventory=$(usb_lock_waiting_inventory "$inventory") || return 1
      fi
      captured=$(usb_lock_capture "$inventory" "$include_blocked") || return 1
      { usb_lock_rules && printf '%s\n' "$captured"; } | usb_lock_save_rules "$USB_LOCK_DIR/session.conf" || return 1
    fi
    if [[ -e $USB_LOCK_APPROVAL ]]; then
      captured=$(usb_lock_rules) || return 1
      printf '# approval\n%s\n' "$captured" | usb_lock_write_policy || return 1
    else
      printf '# unlocked\nallow\n' | usb_lock_write_policy || return 1
    fi
  fi

  # Kernel default-deny remains in force while USBGuard restarts. Existing
  # devices are re-evaluated against the new policy before we acknowledge it.
  # The service preserves /run state, including the locked snapshot, on restart.
  systemctl reset-failed "$USB_LOCK_SERVICE" || return 1
  systemctl restart "$USB_LOCK_SERVICE" || return 1
  usb_lock_wait_ready || return 1
  if [[ $action == "lock" ]]; then echo locked; else echo unlocked; fi
}

usb_lock_enable() {
  local start=${1:-now}
  # These files ship in omarchy-settings' recursive /etc tree. Refuse partial
  # installs before starting enforcement or publishing the enable marker.
  if [[ ! -f $USB_LOCK_UNIT || ! -f $USB_LOCK_POLKIT || ! -f $USB_LOCK_WATCH ]]; then
    echo "USB lock service or permissions are missing. Update Omarchy before enabling this feature." >&2
    return 1
  fi
  if systemctl is-active --quiet usbguard.service || systemctl is-enabled --quiet usbguard.service ||
    systemctl is-active --quiet usbguard-dbus.service || systemctl is-enabled --quiet usbguard-dbus.service; then
    echo "Finish pending Omarchy migrations or disable your own USBGuard service before trying USB while locked." >&2
    return 1
  fi
  if [[ -e /etc/limine-entry-tool.d/usb-authorization.conf || -e /var/lib/omarchy/usb-authorization-boot.removing ]]; then
    echo "Finish the USB at Boot removal migration before trying USB while locked." >&2
    return 1
  fi
  if [[ $start == "now" ]]; then usb_lock_prepare || return 1; fi
  install -Dm644 /dev/null "$USB_LOCK_ENABLED" || return 1
  rm -f "$USB_LOCK_DISABLED" || return 1
  if [[ $start == "now" ]]; then
    systemctl daemon-reload || return 1
    systemctl enable --now "$USB_LOCK_SERVICE" || return 1
    usb_lock_wait_ready
  else
    systemctl enable "$USB_LOCK_SERVICE"
  fi
}

usb_lock_defaults() {
  # Per-user migrations must preserve the machine-wide explicit opt-out and
  # optional mode. An independently managed USBGuard service stays untouched.
  [[ ! -e $USB_LOCK_DISABLED && ! -e $USB_LOCK_ENABLED ]] || return 0
  if systemctl is-enabled --quiet usbguard.service || systemctl is-active --quiet usbguard.service ||
    systemctl is-enabled --quiet usbguard-dbus.service || systemctl is-active --quiet usbguard-dbus.service; then
    echo "Existing USBGuard policy preserved; Omarchy USB defaults were not enabled."
    return 0
  fi
  usb_lock_enable "${1:-now}"
}

usb_lock_reset_root() {
  local root=$1 directory
  # Reset consent for the new owner, but keep an independently enabled guard
  # in charge. Use the target root's unit links, never the running host state.
  for directory in etc etc/omarchy var var/lib var/lib/omarchy; do
    [[ ! -L $root/$directory ]] || { echo "Refusing a linked factory policy directory" >&2; return 1; }
  done
  rm -rf "$root/var/lib/omarchy/usb-lock" || return 1
  rm -f "$root/etc/omarchy/usb-lock.approval" "$root/etc/omarchy/usb-lock.disabled" \
    "$root/etc/omarchy/usb-lock.enabled" || return 1
  if [[ -f $root/etc/systemd/system/omarchy-usb-lock.service ]]; then
    if systemctl --root "$root" is-enabled --quiet usbguard.service ||
      systemctl --root "$root" is-enabled --quiet usbguard-dbus.service; then
      systemctl --root "$root" disable omarchy-usb-lock.service || return 1
    else
      install -Dm644 /dev/null "$root/etc/omarchy/usb-lock.enabled" || return 1
      systemctl --root "$root" enable omarchy-usb-lock.service || return 1
    fi
  fi
}

usb_lock_mode() {
  [[ -e $USB_LOCK_ENABLED ]] || usb_lock_enable || return 1
  if [[ $1 == "approval" ]]; then
    install -Dm644 /dev/null "$USB_LOCK_APPROVAL"
  else
    rm -f "$USB_LOCK_APPROVAL"
  fi
}

usb_lock_restore_defaults() {
  local attribute
  for attribute in "$USB_LOCK_SYSFS"/usb*/authorized_default "$USB_LOCK_SYSFS"/*/authorized; do
    [[ -e $attribute ]] || continue
    if ! echo 1 >"$attribute"; then
      [[ ! -e $attribute ]] || return 1
    fi
  done
}

usb_lock_disable() {
  if [[ ! -e $USB_LOCK_ENABLED ]]; then
    install -Dm644 /dev/null "$USB_LOCK_DISABLED"
    return
  fi
  if systemctl is-active --quiet usbguard.service || systemctl is-active --quiet usbguard-dbus.service; then
    echo "Another USBGuard service is active; its policy was left unchanged." >&2
    return 1
  fi
  # Leave a permissive policy for recovery, stop enforcement, then authorize
  # connected devices. Keep the enable marker until removal can be confirmed.
  printf '# unlocked\nallow\n' | usb_lock_write_policy || return 1
  systemctl disable --now "$USB_LOCK_SERVICE" || return 1
  if systemctl is-active --quiet "$USB_LOCK_SERVICE"; then return 1; fi
  usb_lock_restore_defaults || return 1
  install -Dm644 /dev/null "$USB_LOCK_DISABLED" || return 1
  rm -f "$USB_LOCK_ENABLED" || return 1
  rm -f "$USB_LOCK_APPROVAL" "$USB_LOCK_DIR/rules.conf" "$USB_LOCK_DIR/daemon.conf" "$USB_LOCK_DIR/session.conf" "$USB_LOCK_DIR/denied-before-lock.conf"
}

usb_lock_require_approval() {
  local first
  [[ -e $USB_LOCK_ENABLED && -e $USB_LOCK_APPROVAL ]] || return 1
  if systemctl is-active --quiet usbguard.service || systemctl is-active --quiet usbguard-dbus.service; then return 1; fi
  read -r first <"$USB_LOCK_DIR/rules.conf" || return 1
  [[ $first == "# approval" ]] || return 1
  if ! systemctl is-active --quiet "$USB_LOCK_SERVICE"; then
    [[ ${1:-} == "recover" ]] || return 1
    systemctl reset-failed "$USB_LOCK_SERVICE" || return 1
    systemctl restart "$USB_LOCK_SERVICE" || return 1
    usb_lock_wait_ready || return 1
  fi
}

usb_lock_approve() {
  local choice=$1 id=$2 expected=$3 generation=$4 current portable rules destination
  [[ $choice == "always" ]] || return 64
  [[ $id =~ ^[0-9]+$ && $generation =~ ^[0-9a-f]{32}$ && $expected == "block "* ]] || return 64
  (( ${#expected} <= 16384 )) || return 64
  usb_lock_require_approval || return 1
  [[ $(systemctl show "$USB_LOCK_SERVICE" --property=InvocationID --value) == $generation ]] || return 1
  current=$(usbguard list-devices --blocked) || return 1
  grep -Fqx -- "$id: $expected" <<<"$current" || return 1
  portable=$(usb_lock_portable_rule "$expected") || return 1
  usbguard-rule-parser "$portable" >/dev/null || return 1
  install -d -m 700 "$USB_LOCK_TRUST" || return 1
  destination=$USB_LOCK_TRUST/approved.conf
  { if [[ -e $destination ]]; then cat "$destination" || return 1; fi; printf '%s\n' "$portable"; } |
    usb_lock_save_rules "$destination" || return 1
  rules=$(usb_lock_rules) || return 1
  printf '# approval\n%s\n' "$rules" | usb_lock_write_policy || return 1
  # Update the live daemon without changing its invocation/device identifiers.
  usbguard append-rule --temporary "$portable" >/dev/null || return 1
  usbguard allow-device "$expected" || return 1
  current=$(usbguard list-devices --allowed) || return 1
  grep -Fqx -- "$id: allow ${expected#block }" <<<"$current"
}

usb_lock_list_approved() {
  local rules rule token
  [[ -e $USB_LOCK_TRUST/approved.conf ]] || return 0
  rules=$(cat "$USB_LOCK_TRUST/approved.conf") || return 1
  while IFS= read -r rule; do
    [[ -n $rule ]] || continue
    token=$(printf '%s' "$rule" | sha256sum) || return 1
    printf '%s\t%s\n' "${token%% *}" "$rule"
  done <<<"$rules"
}

usb_lock_without_rule() {
  local excluded=$1 rule
  while IFS= read -r rule; do
    if [[ -n $rule ]]; then
      # A saved device rule may contain glob characters; compare it literally.
      case $rule in
        "$excluded") ;;
        *) printf '%s\n' "$rule" ;;
      esac
    fi
  done
}

usb_lock_forget() {
  local token=$1 inventory line rule="" rules session=""
  [[ $token =~ ^[0-9a-f]{64}$ ]] || return 64
  usb_lock_require_approval recover || return 1
  inventory=$(usb_lock_list_approved) || return 1
  while IFS= read -r line; do
    if [[ ${line%%$'\t'*} == $token ]]; then rule=${line#*$'\t'}; break; fi
  done <<<"$inventory"
  [[ -n $rule ]] || return 1
  rules=$(usb_lock_rules) || return 1
  if [[ -e $USB_LOCK_DIR/session.conf ]]; then session=$(cat "$USB_LOCK_DIR/session.conf") || return 1; fi
  # Lock snapshots can copy permanent approvals into the temporary rules.
  # Revoke both copies, and enforce the result before removing the saved entry
  # so a failed restart leaves an approval the user can find and retry.
  usb_lock_without_rule "$rule" <<<"$session" | usb_lock_save_rules "$USB_LOCK_DIR/session.conf" || return 1
  { printf '# approval\n'; usb_lock_without_rule "$rule" <<<"$rules"; } | usb_lock_write_policy || return 1
  systemctl reset-failed "$USB_LOCK_SERVICE" || return 1
  systemctl restart "$USB_LOCK_SERVICE" || return 1
  usb_lock_wait_ready || return 1
  rules=$(cat "$USB_LOCK_TRUST/approved.conf") || return 1
  usb_lock_without_rule "$rule" <<<"$rules" | usb_lock_save_rules "$USB_LOCK_TRUST/approved.conf"
}
