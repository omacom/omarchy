# Device identity is portable; the full live rule is still used when granting
# access to the connection shown in the approval dialog.
usb_authorization_portable_rule() {
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
  printf '%s label "omarchy-usb-authorization-v1"\n' "${portable[*]}"
}

usb_authorization_permanent() {
  local id="$1" expected="$2" devices current="" allowed portable policy line target new_id matches rule saved=0

  [[ $id =~ ^[0-9]+$ && ( $expected == block\ * || $expected == allow\ * ) ]] || return 1
  (( ${#expected} <= 16384 )) || return 1
  devices=$(usbguard list-devices) || return 1
  while IFS= read -r line; do
    if [[ $line == "$id: "* ]]; then current=${line#"$id: "}; fi
  done <<<"$devices"
  [[ $current == "$expected" ]] || return 1
  allowed="allow ${expected#* }"
  portable=$(usb_authorization_portable_rule "$current") || return 1
  usbguard-rule-parser "$portable" >/dev/null || return 1

  # Respect earlier administrator deny rules. Do not report permanent success
  # when a saved allow would lose to an explicit block/reject on reconnect.
  policy=$(usbguard list-rules) || return 1
  while IFS= read -r line; do
    if [[ $line =~ ^[0-9]+:[[:space:]](allow|block|reject)([[:space:]]|$) ]]; then
      target=${BASH_REMATCH[1]}
      rule=${line#*: }
      # --show-devices filters by current target, hiding deny rules for a
      # temporarily allowed device. A match query compares identity instead.
      matches=$(usbguard list-devices "match${rule#"$target"}") || return 1
      if grep -Fqx -- "$id: $current" <<<"$matches"; then
        if [[ $target != "allow" ]]; then
          echo "An administrator rule blocks this device. Review that rule before saving approval." >&2
          return 1
        fi
        break
      fi
    fi
  done <<<"$policy"
  while IFS= read -r line; do
    if [[ $line =~ ^([0-9]+):[[:space:]] && ${line#*: } == "$portable" ]]; then
      saved=1
    fi
  done <<<"$policy"

  # A retry can reuse only an exact owned rule present in both the daemon and
  # its persistent file. Never remove/reorder rules around manual restrictions.
  if (( ! saved )) || ! grep -Fqx -- "$portable" /etc/usbguard/rules.conf; then
    new_id=$(usbguard append-rule "$portable") || return 1
    [[ $new_id =~ ^[0-9]+$ ]] || return 1
    grep -Fqx -- "$portable" /etc/usbguard/rules.conf || return 1
  fi
  if [[ $current == block\ * ]]; then
    usbguard allow-device "$expected" || return 1
  fi
  devices=$(usbguard list-devices --allowed) || return 1
  grep -Fqx -- "$1: $allowed" <<<"$devices"
}
