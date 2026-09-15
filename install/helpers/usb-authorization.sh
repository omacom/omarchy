usb_authorization_config_value() {
  local config="$1" key="$2"
  local awk_command=(awk)

  if [[ ! -r $config ]]; then
    if [[ $config == "/etc/usbguard/usbguard-daemon.conf" ]]; then
      awk_command=(sudo awk)
    else
      echo "Cannot read USBGuard configuration: $config" >&2
      return 1
    fi
  fi

  "${awk_command[@]}" -F= -v key="$key" '
    /^[[:space:]]*#/ { next }
    $1 ~ "^[[:space:]]*" key "[[:space:]]*$" {
      value=$0
      sub(/^[^=]*=[[:space:]]*/, "", value)
      sub(/[[:space:]]*$/, "", value)
      print value
      exit
    }
  ' "$config"
}

usb_authorization_rules_present() {
  local rules="$1"

  if [[ -r $rules ]]; then
    [[ -s $rules ]]
  elif [[ $rules == "/etc/usbguard/rules.conf" ]]; then
    sudo test -s "$rules"
  else
    return 1
  fi
}

usb_authorization_require_secure_setting() {
  local config="$1" key="$2" expected="$3" actual

  actual=$(usb_authorization_config_value "$config" "$key")
  if [[ $actual != "$expected" ]]; then
    echo "USBGuard's $key must be '$expected' before Omarchy enables it." >&2
    echo "Current value: ${actual:-<unset>} in $config" >&2
    return 1
  fi
}

usb_authorization_require_secure_settings() {
  local config="$1"

  usb_authorization_require_secure_setting "$config" ImplicitPolicyTarget block
  usb_authorization_require_secure_setting "$config" PresentDevicePolicy apply-policy
  usb_authorization_require_secure_setting "$config" InsertedDevicePolicy apply-policy
  usb_authorization_require_secure_setting "$config" AuthorizedDefault none
  usb_authorization_require_secure_setting "$config" RestoreControllerDeviceState false
}

usb_authorization_generate_policy() {
  local policy="$1"

  if ! usbguard generate-policy >"$policy"; then
    echo "USBGuard could not enumerate devices; nothing was enabled." >&2
    return 1
  fi
  if ! grep -q '^allow ' "$policy"; then
    if grep -q '^[[:space:]]*[^#[:space:]]' "$policy"; then
      echo "USBGuard did not generate a usable policy; nothing was enabled." >&2
      return 1
    fi
    # A successful empty inventory is valid on machines without USB controllers.
    # Keep the file nonempty so re-enabling preserves this default-deny policy.
    echo '# No USB devices were present during enrollment.' >>"$policy"
  fi
}

usb_authorization_add_user() {
  local user="$1"

  # This user can inspect USBGuard events and approve the device named by an
  # event. Policy and daemon parameters remain unavailable through the IPC ACL.
  usbguard add-user "$user" \
    --devices=list,listen,modify \
    --policy=list \
    --exceptions=listen
}

usb_authorization_trust_present_devices() {
  local line id
  local count=0
  local -a devices

  mapfile -t devices < <(usbguard list-devices)

  for line in "${devices[@]}"; do
    if [[ $line =~ ^([0-9]+):[[:space:]] ]]; then
      id="${BASH_REMATCH[1]}"
      usbguard allow-device --permanent "$id"
      (( ++count ))
    fi
  done

  if (( count == 0 )); then
    echo "USBGuard did not report any connected USB devices; boot authorization was not enabled." >&2
    return 1
  fi
}
