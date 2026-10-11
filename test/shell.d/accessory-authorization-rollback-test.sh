#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"
source "$ROOT/install/helpers/accessory-authorization-rollback.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
ACCESSORY_ROOT_ADMIN=fixture-admin

fixture() {
  rm -rf "$scratch"/*
  mkdir -p "$scratch/root/etc/systemd/system/graphical-session.target.wants" "$scratch/user/.config/systemd"
  ln -s "$scratch/root/etc/systemd/system" "$scratch/user/.config/systemd/user"
  ACCESSORY_USER_HOME=$scratch/user
  unit_dir=$ACCESSORY_USER_HOME/.config/systemd/user
  : >"$scratch/calls"
  failure=""
}
sudo() {
  [[ $1 == fixture-admin && ( $2 == 0 || $2 == 1 ) ]] || return 90
  echo "root $2" >>"$scratch/calls"
  [[ $failure != root ]]
}
systemctl() {
  printf '%s\n' "$*" >>"$scratch/calls"
  [[ $1 == --user ]] || return 90
  case "$2" in
    show) if [[ -e $unit_dir/$3 ]]; then echo loaded; else echo not-found; fi ;;
    is-active) [[ $failure == active ]] ;;
    disable) [[ $failure != stop ]] ;;
    daemon-reload) return 0 ;;
    *) return 91 ;;
  esac
}

fixture
accessory_authorization_rollback
[[ $(head -1 "$scratch/calls") == 'root 0' ]] || fail "root rollback always inspects protected recovery state"
pass "root recovery runs even when the user has no enrollment markers"

for unit in omarchy-usb-authorization.service omarchy-thunderbolt-authorization.service; do
  fixture
  ln -s /missing/checkout/unit "$unit_dir/$unit"
  ln -s "../$unit" "$unit_dir/graphical-session.target.wants/$unit"
  mkdir -p "$unit_dir/example.target.requires"
  ln -s "../$unit" "$unit_dir/example.target.requires/$unit"
  ln -s /missing/unrelated "$unit_dir/graphical-session.target.wants/unrelated.service"
  if /usr/bin/systemctl --root="$scratch/root" is-enabled "$unit" >"$scratch/enabled" 2>&1; then
    fail "fixture must reproduce not-found for the dangling enabled unit"
  fi
  grep -q not-found "$scratch/enabled" || fail "native systemctl must classify the fixture as not-found"
  accessory_authorization_rollback
  [[ ! -L $unit_dir/$unit && ! -L $unit_dir/graphical-session.target.wants/$unit && ! -L $unit_dir/example.target.requires/$unit ]] || fail "all retired watcher links must be removed"
  [[ -L $unit_dir/graphical-session.target.wants/unrelated.service ]] || fail "unrelated dependency remains"
  if [[ $unit == omarchy-usb-authorization.service ]]; then
    grep -qx 'root 1' "$scratch/calls" || fail "dangling USB watcher identifies enrollment"
  fi
  accessory_authorization_rollback
  pass "$unit dangling main, wants and requires links retire on every run"
done

for failure_case in root stop active; do
  fixture
  unit=omarchy-thunderbolt-authorization.service
  touch "$unit_dir/$unit"
  ln -s "../$unit" "$unit_dir/graphical-session.target.wants/$unit"
  failure=$failure_case
  if accessory_authorization_rollback; then fail "$failure_case failure must leave the migration pending"; fi
  [[ -e $unit_dir/$unit && -L $unit_dir/graphical-session.target.wants/$unit ]] || fail "failure must retain the watcher"
  failure=""
  accessory_authorization_rollback
  [[ ! -e $unit_dir/$unit && ! -L $unit_dir/graphical-session.target.wants/$unit ]] || fail "retry removes the watcher"
  pass "$failure_case failure preserves approval fallback and can retry"
done

fixture
unit=omarchy-thunderbolt-authorization.service
touch "$unit_dir/graphical-session.target.wants/$unit"
if accessory_stop_user_unit "$unit" 2>/dev/null; then fail "regular administrator dependency must not be removed"; fi
[[ -f $unit_dir/graphical-session.target.wants/$unit ]] || fail "regular dependency preserved"
pass "manual regular dependency files are preserved with a reported failure"

fixture
unit=omarchy-thunderbolt-authorization.service
mkdir "$scratch/outside"
ln -s /missing/checkout/unit "$scratch/outside/$unit"
ln -s "$scratch/outside" "$unit_dir/example.target.requires"
if accessory_stop_user_unit "$unit"; then fail "linked dependency directory must not be followed"; fi
[[ -L $scratch/outside/$unit ]] || fail "external dependency preserved"
pass "cleanup does not follow dependency directories outside the user's unit directory"

fixture
sed -e "s|source /usr/bin/omarchy-security-functions|source $ROOT/bin/omarchy-security-functions|" \
  -e 's|source /usr/share/omarchy/install/helpers/thunderbolt-policy.sh|exit 126|' \
  "$ROOT/bin/omarchy-accessory-authorization-rollback" >"$scratch/entry"
chmod 755 "$scratch/entry"
printf 'set -p\n' >"$scratch/decoy"
if BASH_ENV="$scratch/decoy" /usr/bin/bash "$scratch/entry" -p; then fail "ordinary Bash startup with decoy -p is rejected"; fi
printf 'touch "%s"\n' "$scratch/injected" >"$scratch/startup"
if BASH_ENV="$scratch/startup" "$scratch/entry" >/dev/null 2>&1; then fail "fixture stops before root work"; fi
if /usr/bin/env 'BASH_FUNC_source%%=() { touch "$USB_TEST_INJECTED"; }' USB_TEST_INJECTED="$scratch/injected" "$scratch/entry" >/dev/null 2>&1; then fail "fixture stops before root work"; fi
[[ ! -e $scratch/injected ]] || fail "root startup executes caller code"
pass "root rollback rejects BASH_ENV, exported functions and a decoy privileged flag"

# Exercise the real entrypoint's lock in two processes. Replace only installed
# sources, root identity/directory checks and the privileged work with fixtures.
cat >"$scratch/lock-fixture" <<SH
omarchy_security_prepare_private_root_directory() { mkdir -p "\$1"; }
accessory_rollback_root() {
  printf 'enter %s\n' "\$\$" >>"$scratch/lock-events"
  sleep 0.1
  printf 'leave %s\n' "\$\$" >>"$scratch/lock-events"
}
SH
sed -e "s|source /usr/bin/omarchy-security-functions|source $ROOT/bin/omarchy-security-functions|" \
  -e 's/EUID == 0 \&\& //' \
  -e 's|source /usr/share/omarchy/install/helpers/thunderbolt-policy.sh|:|' \
  -e 's|source /usr/share/omarchy/install/helpers/thunderbolt-setup.sh|:|' \
  -e 's|source /usr/bin/omarchy-usb-authorization-boot|:|' \
  -e "s|source /usr/share/omarchy/install/helpers/accessory-authorization-rollback-root.sh|source $scratch/lock-fixture|" \
  -e "s|/run/omarchy-accessory-authorization-rollback|$scratch/locked|g" \
  "$ROOT/bin/omarchy-accessory-authorization-rollback" >"$scratch/locked-entry"
chmod 755 "$scratch/locked-entry"
"$scratch/locked-entry" 0 & first=$!
"$scratch/locked-entry" 0 & second=$!
wait "$first"
wait "$second"
awk '$1 == "enter" { if (++active != 1) exit 1; owner=$2 } $1 == "leave" { if ($2 != owner || --active != 0) exit 1 } END { if (NR != 4 || active != 0) exit 1 }' "$scratch/lock-events" || fail "cross-user root work must never overlap"
pass "the complete root rollback is serialized across concurrent invocations"
