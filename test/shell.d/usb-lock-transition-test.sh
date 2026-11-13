#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"
if (( EUID != 0 )); then
  if unshare --user --map-root-user true 2>/dev/null; then
    exec unshare --user --map-root-user bash "$0"
  fi
  skip "no unprivileged user namespace; skipping combined root transitions"
  exit 0
fi

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
# Execute the protected production entrypoint, replacing only fixed installed
# paths and the two service boundaries. No host services or policies are used.
sed -e "s|/usr/bin/omarchy-security-functions|$ROOT/bin/omarchy-security-functions|" \
  -e "s|/usr/share/omarchy/install/helpers/usb-lock.sh|$scratch/usb|" \
  -e "s|/usr/share/omarchy/install/helpers/thunderbolt-lock.sh|$scratch/bolt|" \
  -e "s|/run/lock/omarchy-usb-lock.lock|$scratch/root.lock|" \
  "$ROOT/bin/omarchy-usb-lock-state" >"$scratch/state"
chmod 755 "$scratch/state"
for name in usb bolt; do
  function_name=usb_lock_change
  [[ $name != "bolt" ]] || function_name=tb_lock_change
  cat >"$scratch/$name" <<SH
$function_name() {
  printf '%s\n' '$name' >>'$scratch/calls'
  [[ ! -e '$scratch/fail-$name' ]] || return 1
  printf '%s\n' "\$1" >'$scratch/applied-$name'
  if [[ $name == usb ]]; then
    if [[ \$1 == lock ]]; then echo locked; else echo unlocked; fi
  fi
}
SH
done

for action in lock unlock; do
  for outage in bolt usb both none; do
    rm -f "$scratch"/{fail-*,applied-*,calls}
    [[ $outage != "bolt" && $outage != "both" ]] || touch "$scratch/fail-bolt"
    [[ $outage != "usb" && $outage != "both" ]] || touch "$scratch/fail-usb"
    result=0
    "$scratch/state" "$action" >"$scratch/reply" || result=$?
    [[ $(<"$scratch/calls") == $'usb\nbolt' ]] || fail "$outage outage skipped a transition or delayed USB behind Bolt"
    for name in usb bolt; do
      if [[ ! -e $scratch/fail-$name ]]; then
        [[ $(<"$scratch/applied-$name") == "$action" ]] || fail "$outage outage prevented $name $action"
      fi
    done
    if [[ $outage == "none" ]]; then
      (( result == 0 )) && [[ $(<"$scratch/reply") == "${action}ed" ]] || fail "successful combined transition was not acknowledged"
    else
      (( result != 0 )) || fail "partial protection was acknowledged as complete"
      [[ ! -s $scratch/reply ]] || fail "partial transition emitted a success reply"
    fi
    pass "$action attempts both policies and reports $outage failure accurately"
  done
done
