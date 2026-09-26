# Session-side notification and terminal dialog functions.

tb_requests() {
  TB_REQUESTS="$HOME/.local/state/omarchy/thunderbolt-authorization/requests"
  mkdir -p -m 700 "$TB_REQUESTS"
  chmod 700 "${TB_REQUESTS%/*}" "$TB_REQUESTS"
}

tb_safe_text() {
  jq -r 'gsub("[\u0000-\u001f\u007f-\u009f\u202a-\u202e\u2066-\u2069]"; "?")'
}

tb_notify() {
  local token=$1 retry=${2:-false} title='Thunderbolt accessory blocked' description
  description='Click to review it. Keep it blocked unless you recognize the device.'
  if [[ $retry == "true" ]]; then
    title='Thunderbolt approval needs retry'
    description='The last approval could not be confirmed. Click to retry it.'
  fi
  omarchy-notification-wait 1 >/dev/null || return 1
  timeout 10 omarchy-notification-send --app-name omarchy-action --urgency critical --glyph '󱐋' \
    "$title" "$description" --exec omarchy-launch-floating-terminal-with-presentation \
    omarchy-thunderbolt-authorization-review "$token"
}

tb_attention() {
  omarchy-notification-wait 1 >/dev/null || return 1
  timeout 10 omarchy-notification-send --app-name omarchy-action --urgency critical \
    'Thunderbolt protection needs attention' 'The approval or firmware policy could not be confirmed. Click for details.' \
    --exec omarchy-launch-floating-terminal-with-presentation omarchy-setup-security-thunderbolt-authorization status
}

tb_setup_notice() {
  omarchy-notification-wait 1 >/dev/null || return 1
  timeout 10 omarchy-notification-send --app-name omarchy-action --urgency critical \
    'Finish Thunderbolt protection setup' 'A connected accessory needs secure enrollment. Protection is not enabled. Click to finish safely.' \
    --exec omarchy-launch-floating-terminal-with-presentation omarchy-setup-security-thunderbolt-authorization
}

tb_token() {
  local digest
  digest=$(jq -cS --arg watch "$2" '{watch:$watch,identity:.}' <<< "$1" | sha256sum) || return 1
  printf 'request-%s\n' "${digest%% *}"
}

tb_request_read() {
  [[ -f $1 && ! -L $1 ]] || return 1
  jq -ce 'select(.identity | type == "object")' "$1"
}

tb_deliver() {
  local path=$1 request token
  request=$(tb_request_read "$path") || return 1
  if ! jq -e '.notified // false' <<< "$request" >/dev/null; then
    token=${path##*/}
    if tb_notify "${token%.json}" "$(jq -r '.approval != null' <<< "$request")"; then
      jq '.notified=true' <<< "$request" | tb_json_write "$path"
    else
      return 1
    fi
  fi
}

tb_request_apply() {
  # The watcher has no terminal. Polkit permits this one fixed helper for an
  # active local administrator; it cannot dispatch general setup operations.
  pkexec --disable-internal-agent /usr/bin/omarchy-thunderbolt-authorization-approve "$1" "$2"
}

tb_request_process() {
  local path=$1 request identity permanent result error_file error
  request=$(tb_request_read "$path") || return 1
  if jq -e '.pending // false' <<< "$request" >/dev/null; then
    identity=$(jq -c .identity <<< "$request")
    permanent=$(jq -r '.approval == "Always allow this device"' <<< "$request")
    error_file=$(mktemp "$TB_REQUESTS/.error.XXXXXX") || return 1
    if result=$(tb_request_apply "$permanent" "$identity" 2> "$error_file") &&
      jq -e --argjson identity "$identity" --argjson permanent "$permanent" \
        'any(.devices[]; .identity==$identity and (.status | IN("authorized","authorized-newkey","authorized-secure")) and
          ($permanent == false or .trusted))' <<< "$result" >/dev/null; then
      jq --argjson result "$result" '.pending=false | .result=$result | del(.error)' <<< "$request" |
        tb_json_write "$path" || return 1
    else
      error=$(cat "$error_file")
      [[ -n $error ]] || error='Could not confirm approval. Click the retry notification.'
      jq --arg error "$error" '.pending=false | .notified=false | .error=$error' <<< "$request" |
        tb_json_write "$path" || return 1
    fi
    rm -f -- "$error_file"
  fi
  tb_deliver "$path"
}

tb_scan() {
  local watch=$1 snapshot path request device identity token existing
  snapshot=$(tb_public_snapshot) || return 1
  (
    flock -x 9
    for path in "$TB_REQUESTS"/request-*.json; do
      [[ -e $path || -L $path ]] || continue
      if ! request=$(tb_request_read "$path"); then
        rm -f -- "$path"
        continue
      fi
      identity=$(jq -c .identity <<< "$request")
      device=$(jq -c --argjson identity "$identity" '.devices[] | select(.identity==$identity)' <<< "$snapshot") || exit 1
      if [[ -z $device ]] || { ! jq -e '.status | IN("connected","auth-error")' <<< "$device" >/dev/null &&
        ! jq -e '.approval != null' <<< "$request" >/dev/null; }; then
        rm -- "$path"
        continue
      fi
      if [[ $(jq -r .watch <<< "$request") != "$watch" ]]; then
        rm -- "$path"
        # Resume an interrupted attempt only for the same exact connection.
        jq -e '.approval != null and .result == null' <<< "$request" >/dev/null || continue
        token=$(tb_token "$identity" "$watch") || exit 1
        path="$TB_REQUESTS/$token.json"
        request=$(jq -c --arg watch "$watch" '.watch=$watch | .notified=false' <<< "$request") || exit 1
        tb_json_write "$path" <<< "$request" || exit 1
      fi
      tb_request_process "$path" || true
    done
    snapshot=$(tb_public_snapshot) || exit 1
    while IFS= read -r device; do
      identity=$(jq -c .identity <<< "$device")
      token=$(tb_token "$identity" "$watch") || exit 1
      path="$TB_REQUESTS/$token.json"
      if [[ ! -f $path ]]; then
        jq -cn --argjson identity "$identity" --arg watch "$watch" \
          '{identity:$identity,watch:$watch,notified:false}' | tb_json_write "$path" || exit 1
        if ! tb_deliver "$path"; then
          rm -f -- "$path"
        fi
      fi
    done < <(jq -c '.devices[] | select((.trusted | not) and (.status | IN("connected","auth-error")) and
      (.flags | contains("nopcie") | not))' <<< "$snapshot")
  ) 9> "$TB_REQUESTS/.lock" || return 1
  printf '%s\n' "$snapshot"
}

tb_watch() {
  local watch snapshot warning warned='' failures=0
  tb_requests
  watch=$(cat /proc/sys/kernel/random/uuid)
  while true; do
    if [[ -f $TB_PENDING && ! -f $TB_MARKER ]]; then
      if [[ $warned != "pending" ]] && tb_setup_notice; then warned=pending; fi
      sleep 2
      continue
    fi
    if snapshot=$(tb_scan "$watch"); then
      failures=0
      warning=$(jq -c '[.generation,.warnings,.error]' <<< "$snapshot")
      if jq -e '(.warnings | length > 0) or .error != ""' <<< "$snapshot" >/dev/null; then
        if [[ $warning != "$warned" ]] && tb_attention; then
          warned=$warning
        fi
      else
        warned=''
      fi
    else
      failures=$((failures + 1))
      if (( failures >= 3 )) && [[ $warned != "unavailable" ]] && tb_attention; then
        warned=unavailable
      fi
    fi
    sleep 2
  done
}

tb_find_device() {
  local snapshot
  snapshot=$(tb_public_snapshot) || return 1
  jq -ce --argjson identity "$1" '.devices[] | select(.identity==$identity)' <<< "$snapshot" ||
    tb_fail 'That Thunderbolt device was removed or changed. Open its latest notification.'
}

tb_review() {
  local token=$1 path request identity device choice latest index
  [[ $token =~ ^request-[0-9a-f]{64}$ ]] || { tb_fail 'Invalid or expired Thunderbolt request'; return 1; }
  tb_requests
  path="$TB_REQUESTS/$token.json"
  request=$(tb_request_read "$path") || return 1
  identity=$(jq -c .identity <<< "$request")
  device=$(tb_find_device "$identity") || return 1
  choice=$(jq -r '.approval // empty' <<< "$request")
  if [[ -z $choice ]]; then
    jq -e '.status | IN("connected","auth-error")' <<< "$device" >/dev/null || { tb_fail 'This device is no longer blocked'; return 1; }
    gum style --foreground 212 --bold 'Blocked Thunderbolt accessory'
    printf '\nThese details come from the device and can be forged:\n'
    for index in Name Vendor Uid; do
      printf '%s: ' "$index"
      jq --arg key "$index" '.[$key]' <<< "$identity" | tb_safe_text
    done
    printf '\nApproval gives this accessory access to its PCIe drivers.\n\n'
    choice=$(gum choose 'Allow once' 'Always allow this device' 'Keep blocked') || return 0
  fi
  case "$choice" in
    'Allow once'|'Always allow this device'|'Keep blocked') ;;
    *) tb_fail 'Invalid approval choice'; return 1 ;;
  esac
  (
    flock -x 9
    latest=$(tb_request_read "$path") || exit 1
    [[ $latest == "$request" ]] || { tb_fail 'This request changed. Open the latest notification.'; exit 1; }
    device=$(tb_find_device "$identity") || exit 1
    if [[ $choice == "Keep blocked" ]]; then
      printf 'Thunderbolt accessory remains blocked.\n'
    else
      if ! jq -e '.approval != null' <<< "$request" >/dev/null; then
        jq -e '.status | IN("connected","auth-error")' <<< "$device" >/dev/null || exit 1
      fi
      jq --arg choice "$choice" '.approval=$choice | .pending=true | del(.error,.result)' <<< "$request" |
        tb_json_write "$path"
    fi
  ) 9> "$TB_REQUESTS/.lock" || return 1
  if [[ $choice != "Keep blocked" ]]; then
    for ((index=0; index<60; index++)); do
      latest=$(tb_request_read "$path") || return 1
      if jq -e '.result != null' <<< "$latest" >/dev/null; then
        rm -- "$path"
        if [[ $choice == "Always allow this device" ]]; then
          printf 'Thunderbolt accessory trusted.\n'
        else
          printf 'Thunderbolt accessory allowed for this connection.\n'
        fi
        return 0
      elif jq -e '.error != null' <<< "$latest" >/dev/null; then
        jq .error <<< "$latest" | tb_safe_text >&2
        return 1
      fi
      sleep 1
    done
    tb_fail 'Approval is still pending. The watcher will retain and retry the request.'
  fi
}

tb_status() {
  local snapshot
  if [[ -f $TB_PENDING && ! -f $TB_MARKER ]]; then
    printf 'Thunderbolt protection is deferred. Previous Bolt behavior remains active.\nKeep a keyboard/input device available independently of Thunderbolt. Safely disconnect the Thunderbolt accessories, then run Setup > Security > Thunderbolt. Reconnect each accessory and choose Always allow to save its secure key.\n'
    return 0
  fi
  snapshot=$(tb_public_snapshot) || return 1
  printf 'Thunderbolt device approval is enabled.\nTrusted accessories reconnect automatically; new accessories require approval.\n'
  if jq -e '.domains | length == 0' <<< "$snapshot" >/dev/null; then
    printf 'No Thunderbolt controller is currently visible. Its firmware policy will be checked when it appears.\n'
  fi
  jq '.warnings[], (.error | select(. != ""))' <<< "$snapshot" | while IFS= read -r warning; do
    printf 'Attention: '
    tb_safe_text <<< "$warning"
  done
  printf 'Firmware boot access is separate; see the Security manual before relying on pre-boot protection.\n'
}
