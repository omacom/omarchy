echo "Remember Bluetooth on and off through the rfkill soft block"

marker=/var/lib/omarchy/migrations/1786380259
main_conf=/etc/bluetooth/main.conf

repair_machine() {
  local controllers="" controller details powered=0 daemon status
  [[ ! -e $marker ]] || return 0

  # bluetoothd runs only with an adapter present and the service allowed.
  # Status 3 also covers failed and transitional states, so inspect the state
  # itself before treating the adapter as off. Only an inactive or absent
  # service may complete without asking bluetoothd.
  daemon=$(/usr/bin/systemctl is-active bluetooth.service 2>/dev/null) && status=0 || status=$?
  case "$daemon:$status" in
    active:0)
      controllers=$(/usr/bin/timeout 2s /usr/bin/bluetoothctl list) || {
        echo "Could not read Bluetooth power state; leaving the migration pending." >&2
        return 1
      }
      ;;
    inactive:3 | inactive:4) ;;
    *)
      echo "Could not inspect a stable bluetooth.service state; leaving the migration pending." >&2
      return 1
      ;;
  esac
  while read -r _ controller _; do
    [[ -n ${controller:-} ]] || continue
    details=$(/usr/bin/timeout 2s /usr/bin/bluetoothctl show "$controller") || {
      echo "Could not read Bluetooth controller $controller; leaving the migration pending." >&2
      return 1
    }
    [[ $details == *"Powered: yes"* ]] && powered=1
  done <<<"$controllers"

  if (( powered )); then
    /usr/bin/omarchy-bluetooth-power on || return 1
  else
    /usr/bin/omarchy-bluetooth-power off || return 1
  fi
  if [[ -f $main_conf ]]; then
    /usr/bin/sed -i 's/^AutoEnable=false$/#AutoEnable=true/' "$main_conf" || return 1
  fi
  /usr/bin/install -Dm644 /dev/null "$marker" || return 1
}

if (( $# == 0 )); then
  [[ ! -e $marker ]] || exit 0
  /usr/bin/sudo -N -- /usr/bin/flock --exclusive --no-fork /run/omarchy-bluetooth-state-migration.lock \
    /usr/bin/env -i PATH=/usr/bin:/bin \
    /usr/bin/bash -p -euo pipefail /usr/share/omarchy/migrations/1786380259.sh --machine
elif (( $# == 1 && EUID == 0 )) && [[ $1 == "--machine" ]]; then
  repair_machine
else
  echo "This migration accepts no arguments; its machine phase requires root." >&2
  exit 1
fi
