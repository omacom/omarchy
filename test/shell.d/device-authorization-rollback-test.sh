#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"
source "$ROOT/migrations/retired-device-authorization/rollback.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
original_support=$da_support
root_runner=()
if (( EUID != 0 )) && unshare --user --map-root-user true 2>/dev/null; then
  root_runner=(unshare --user --map-root-user)
fi

# End the fixture after startup validation, before any real rollback work, even when this suite runs as root.
sed -e "s|source /usr/bin/omarchy-security-functions|source $ROOT/bin/omarchy-security-functions|" \
  -e '/^  \[\[ $(\/usr\/bin\/readlink /c\  exit 127' \
  "$original_support/rollback.sh" >"$scratch/entry"
chmod 755 "$scratch/entry"
printf 'set -p\n' >"$scratch/decoy"
if BASH_ENV="$scratch/decoy" "${root_runner[@]}" /bin/bash "$scratch/entry" -p rollback 0 >"$scratch/entrypoint-error" 2>&1; then
  fail "ordinary Bash with a decoy -p argument must not enter root rollback"
else
  [[ $? == 126 ]] || fail "unprotected startup is rejected before the fixture boundary"
fi
printf 'touch "%s"\n' "$scratch/injected" >"$scratch/startup"
BASH_ENV="$scratch/startup" "$scratch/entry" >/dev/null 2>&1 && fail "startup crossed the fixture boundary"
[[ ! -e $scratch/injected ]] || fail "privileged entrypoint ran BASH_ENV"
env 'BASH_FUNC_source%%=() { touch "$DA_INJECTED"; }' DA_INJECTED="$scratch/injected" \
  "$scratch/entry" >/dev/null 2>&1 && fail "exported function crossed the fixture boundary"
[[ ! -e $scratch/injected ]] || fail "privileged entrypoint imported an exported function"
pass "root rollback rejects unsafe Bash startup before the safe fixture boundary"

sed -e "s|source /usr/bin/omarchy-security-functions|source $ROOT/bin/omarchy-security-functions|" \
  -e '/^source .*thunderbolt-policy.sh/c\exit 127' \
  "$original_support/rollback.sh" >"$scratch/checkout-entry"
if "${root_runner[@]}" /bin/bash -p "$scratch/checkout-entry" guard >/dev/null 2>&1; then
  fail "root recovery accepted a checkout entrypoint"
else
  [[ $? == 126 ]] || fail "package-path enforcement must reject checkout code before the fixture boundary"
fi
pass "root recovery refuses a caller-selected checkout before loading controller code"

for name in usb-authorization-approve thunderbolt-authorization-approve thunderbolt-authorization-admin thunderbolt-authorization-daemon; do
  sed -e "s|source /usr/bin/omarchy-security-functions|source $ROOT/bin/omarchy-security-functions|" \
    -e '/^source .*retired-device-authorization/c\exit 127' "$ROOT/bin/omarchy-$name" >"$scratch/approval-entry"
  chmod 755 "$scratch/approval-entry"
  if BASH_ENV="$scratch/decoy" /bin/bash "$scratch/approval-entry" -p >"$scratch/error" 2>&1; then
    fail "$name accepts ordinary Bash with a decoy -p"
  fi
  BASH_ENV="$scratch/startup" "$scratch/approval-entry" >/dev/null 2>&1 && fail "$name crossed the fixture boundary"
  env 'BASH_FUNC_source%%=() { touch "$DA_INJECTED"; }' DA_INJECTED="$scratch/injected" \
    "$scratch/approval-entry" >/dev/null 2>&1 && fail "$name crossed the fixture boundary"
  [[ ! -e $scratch/injected ]] || fail "$name executes caller startup code"
done
pass "retained approval and guard entrypoints reject startup injection"

fixture() {
  rm -rf "$scratch"/*
  mkdir -p "$scratch/etc/systemd/system/bolt.service.d" "$scratch/etc/usbguard" "$scratch/run/systemd/system" \
    "$scratch/sys/bus/usb/devices/usb1" "$scratch/sys/bus/usb/devices/1-1" "$scratch/proc" "$scratch/support"
  da_support=$scratch/support
  DA_ROOT=$scratch DA_STATE=$scratch/var/lib/omarchy/retired-device-authorization
  mkdir -p "$scratch/var/lib/omarchy"
  touch "$scratch/etc/passwd"
  echo unit >"$scratch/etc/systemd/system/usbguard.service"
  TB_STATE=$scratch/policy.json TB_CONFIG=$scratch/boltd.conf TB_MARKER=$scratch/enabled
  TB_PENDING=$scratch/pending TB_LOCK=$scratch/root.lock TB_SERVICE=omarchy-thunderbolt-authorization.service
  : >"$scratch/proc/cmdline"
  : >"$scratch/units"
  printf '0\n' >"$scratch/sys/bus/usb/devices/usb1/authorized_default"
  printf '0\n' >"$scratch/sys/bus/usb/devices/1-1/authorized"
  cat >"$da_support/usb-boot.sh" <<'SH'
echo boot >>"${BASH_SOURCE[0]%/*}/../units"
[[ ! -f ${BASH_SOURCE[0]%/*}/../boot-failure ]]
SH
  echo '{"version":1,"enabled":true,"original_authmode":"enabled","trusted":{"ours":{"Uid":"ours","Name":"Dock","Vendor":"Vendor"}},"enrolled":{"ours":{"Uid":"ours","Name":"Dock","Vendor":"Vendor","StoreTime":100}}}' >"$TB_STATE"
  echo '[config]' >"$TB_CONFIG"
  echo 'AuthMode=disabled' >>"$TB_CONFIG"
  touch "$TB_MARKER"
  cat >"$scratch/inventory" <<'JSON'
{"owner":":1.5","manager":{"AuthMode":"disabled"},"domains":[{"Uid":"host","SysfsPath":"/sys/domain","path":"/domain","SecurityLevel":"user","BootACL":["ours",""]}],"stored":[{"Uid":"ours","Name":"Dock","Vendor":"Vendor","StoreTime":100,"Policy":"manual","path":"/ours","Key":"have","Status":"disconnected"},{"Uid":"other","Name":"Manual","Vendor":"Vendor","StoreTime":200,"Policy":"manual","path":"/other","Key":"have"}],"devices":[]}
JSON
}

edit_inventory() {
  jq "$@" "$scratch/inventory" >"$scratch/next"
  mv "$scratch/next" "$scratch/inventory"
}
tb_inventory() {
  if [[ -f $scratch/cold-boot && ! -f $scratch/bolt-started ]]; then return 1; fi
  cat "$scratch/inventory"
}
tb_properties() { jq -c --arg path "$2" '(.stored + .domains)[] | select(.path==$path)' "$scratch/inventory"; }
tb_bus() {
  local path=$3 member=$5 value
  if [[ $member == "Authorize" ]]; then
    edit_inventory --arg path "$path" '(.devices[] | select(.path==$path)).Status="authorized"'
    return
  fi
  [[ ! -f $scratch/policy-failure ]] || return 1
  if [[ $member == "Policy" ]]; then
    value=$(jq -cn --arg value "$7" '$value')
  else
    shift 7
    value=$(jq -cn '$ARGS.positional' --args "$@")
  fi
  edit_inventory --arg path "$path" --arg key "$member" --argjson value "$value" \
    '((.stored[], .domains[]) | select(.path==$path))[$key]=$value'
}
systemctl() {
  printf '%s\n' "$*" >>"$scratch/units"
  case $1 in
    show)
      case $* in
        *LoadState*) if [[ -f $scratch/missing-unit ]]; then echo not-found; else echo loaded; fi ;;
        *ActiveState*) echo active ;;
        *FragmentPath*)
          if [[ ! -f $scratch/missing-unit ]]; then
            printf '%s/etc/systemd/system/%s\n' "$scratch" "${!#}"
          fi ;;
        *) printf '%s\n' 'ActiveState=active' 'UnitFileState=enabled' ;;
      esac ;;
    stop) [[ ! -f $scratch/stop-failure ]] ;;
    is-active|is-enabled) [[ -f $scratch/stop-failure ]] ;;
    is-failed|reset-failed) [[ -f $scratch/failed-unit ]] ;;
    disable) [[ ! -f $scratch/stop-failure ]] ;;
    start)
      if [[ $2 == "bolt.service" ]]; then
        touch "$scratch/bolt-started"
        edit_inventory --arg mode "$(tb_config_authmode "$TB_CONFIG")" '.manager.AuthMode=$mode'
      fi ;;
  esac
}
reject() { if ("$@") >"$scratch/error" 2>&1; then fail "unexpected rollback success: $*"; fi; }

for kind in usb thunderbolt; do
  [[ ! -e $ROOT/bin/omarchy-setup-security-$kind-authorization ]] || fail "retired setup must not return"
  for command in watch review approve; do
    [[ -x $ROOT/bin/omarchy-$kind-authorization-$command ]] || fail "pending removal needs $kind $command"
  done
  [[ -f $ROOT/default/polkit/org.omarchy.$kind.policy &&
    -f $ROOT/etc/polkit-1/rules.d/40-omarchy-$kind.rules &&
    -f $ROOT/default/systemd/user/omarchy-$kind-authorization.service ]] || fail "approval permissions and watcher definitions must survive the update"
done
for path in "$ROOT"/bin/omarchy-{usb,thunderbolt}-authorization-*; do
  while IFS= read -r dependency; do
    dependency=${dependency/\/usr\/share\/omarchy/$ROOT}
    dependency=${dependency/\$OMARCHY_PATH/$ROOT}
    [[ -f $dependency ]] || fail "missing compatibility dependency: $dependency"
  done < <(sed -nE 's/^source "?([^" ]*\/(install|migrations)\/[^" ]*).*/\1/p' "$path")
done
[[ -x $ROOT/bin/omarchy-thunderbolt-authorization-daemon && -x $ROOT/bin/omarchy-thunderbolt-authorization-admin &&
  -x $ROOT/bin/omarchy-usb-authorization-event ]] || fail "existing service and callback entrypoints must survive the update"
if "$ROOT/bin/omarchy-thunderbolt-authorization-admin" enable >/dev/null 2>&1; then
  fail "compatibility must not re-enable Thunderbolt protection"
fi
pass "setup stays removed while packaged approval dependencies remain available"

fixture
unit=omarchy-usb-authorization.service
directory=$scratch/etc/systemd/system
mkdir -p "$directory/graphical-session.target.wants" "$directory/example.target.requires"
ln -s /missing/retired-unit "$directory/$unit"
ln -s "../$unit" "$directory/graphical-session.target.wants/$unit"
ln -s "../$unit" "$directory/example.target.requires/$unit"
if /usr/bin/systemctl --root="$scratch" is-enabled "$unit" >"$scratch/native-enabled" 2>&1; then
  fail "native systemd fixture must report a missing unit"
fi
grep -q not-found "$scratch/native-enabled" || fail "fixture must exercise native not-found enablement"
da_remove_unit_links "$directory" "$unit"
[[ ! -L $directory/graphical-session.target.wants/$unit && ! -L $directory/example.target.requires/$unit ]] || fail "both dangling dependency links must be removed"
touch "$directory/example.target.requires/$unit"
reject da_remove_unit_links "$directory" "$unit"
[[ -f $directory/example.target.requires/$unit ]] || fail "regular administrator dependency must survive"
rm "$directory/example.target.requires/$unit"
mkdir "$scratch/outside"
ln -s /missing/retired-unit "$scratch/outside/$unit"
ln -s "$scratch/outside" "$directory/redirected.target.wants"
reject da_remove_unit_links "$directory" "$unit"
[[ -L $scratch/outside/$unit ]] || fail "cleanup must not follow a linked dependency directory"
pass "native dangling dependencies are removed without following links or deleting manual files"

fixture
da_remove_usb 1
[[ -f $DA_STATE/usb-completed ]] || fail "USB cleanup must record its own completion"
: >"$scratch/units"
da_remove_usb 1
[[ ! -s $scratch/units ]] || fail "another subsystem's retry must not repeat completed USB cleanup"
pass "completed USB removal stays complete across retries of other subsystems"

fixture
touch "$scratch/etc/limine-entry-tool.d-placeholder"
mkdir -p "$scratch/etc/limine-entry-tool.d"
touch "$scratch/etc/limine-entry-tool.d/usb-authorization.conf" "$scratch/boot-failure"
reject da_remove_usb 1
! grep -q 'disable.*usbguard' "$scratch/units" || fail "USB blocking stops only after permissive boot succeeds"
[[ $(<"$scratch/sys/bus/usb/devices/1-1/authorized") == "0" ]] || fail "failed boot rollback must not authorize devices"
rm "$scratch/boot-failure"
da_remove_usb 1
[[ $(<"$scratch/sys/bus/usb/devices/usb1/authorized_default") == "1" &&
  $(<"$scratch/sys/bus/usb/devices/1-1/authorized") == "1" ]] || fail "USB rollback restores root hubs and connected devices"
da_remove_usb 1
pass "USB rollback verifies boot before stopping protection and can retry"

fixture
touch "$scratch/stop-failure"
reject da_remove_usb 1
[[ $(<"$scratch/sys/bus/usb/devices/1-1/authorized") == "0" ]] || fail "a failed USBGuard stop retains device authorization"
pass "USB rollback fails if USBGuard is still active"

fixture
printf '%s\n' 'allow id 1234:5678 serial "independent"' 'block' >"$scratch/etc/usbguard/rules.conf"
da_remove_usb 0
! grep -q 'usbguard' "$scratch/units" || fail "an unrelated USBGuard install is left alone"
[[ $(<"$scratch/sys/bus/usb/devices/1-1/authorized") == "0" ]] || fail "independent blocked devices must stay blocked"
echo 'allow id 1234:0001 label "omarchy-usb-authorization-v1"' >"$scratch/etc/usbguard/rules.conf"
da_remove_usb 0
grep -q 'disable.*usbguard' "$scratch/units" || fail "Omarchy policy identifies machine-wide USB setup"
pass "USB rollback targets Omarchy enrollment"

fixture
mkdir -p "$scratch/etc/limine-entry-tool.d"
touch "$scratch/etc/limine-entry-tool.d/usb-authorization.conf" "$scratch/boot-failure"
reject da_remove_usb 0
rm "$scratch/etc/limine-entry-tool.d/usb-authorization.conf" "$scratch/boot-failure"
da_remove_usb 0
grep -q '^boot$' "$scratch/units" || fail "the root checkpoint must recover an interrupted boot removal"
[[ ! -e $DA_STATE/usb-boot-pending ]] || fail "verified images clear the boot checkpoint"
pass "Omarchy boot rollback can retry after its drop-in disappears"

fixture
printf '%s\n' '[Service]' 'ExecStartPre=/usr/bin/omarchy-thunderbolt-authorization-admin guard' >"$scratch/etc/systemd/system/bolt.service.d/omarchy-authorization.conf"
touch "$scratch/cold-boot"
da_remove_thunderbolt
jq -e '.enabled==false and .enrolled==null' "$TB_STATE" >/dev/null || fail "Thunderbolt state is disabled"
jq -e '.manager.AuthMode=="enabled" and .stored[0].Policy=="auto" and .stored[1].Policy=="manual" and all(.stored[]; .Key=="have")' \
  "$scratch/inventory" >/dev/null || fail "handoff preserves independent manual policies and keys, including disconnected accessories"
[[ ! -f $TB_MARKER && -f $scratch/etc/systemd/system/bolt.service.d/omarchy-authorization.conf.retired ]] || fail "obsolete Bolt guard is archived"
da_remove_thunderbolt
pass "Thunderbolt rollback hands our records to Bolt and preserves manual policies and keys"

fixture
touch "$scratch/policy-failure"
reject da_remove_thunderbolt
jq -e .enabled "$TB_STATE" >/dev/null || fail "failed handoff preserves active protection"
[[ -f $TB_MARKER ]] || fail "failed handoff retains the marker"
TB_RUNTIME=$scratch/runtime
mkdir "$TB_RUNTIME"
echo generation >"$TB_RUNTIME/generation"
edit_inventory '.devices=[{Uid:"new",Name:"Dock",Vendor:"Vendor",path:"/new",inode:"1",Parent:"host",SysfsPath:"/sys/new",ConnectTime:1,Status:"connected",Stored:false,Secure:false,AuthFlags:""}]'
identity=$(tb_snapshot | jq -c '.devices[0].identity')
tb_approve "$identity" false >"$scratch/approved-snapshot"
jq -e '.devices[0].status=="authorized"' "$scratch/approved-snapshot" >/dev/null || fail "failed Thunderbolt handoff must still permit an individual approval"
pass "Thunderbolt approvals remain usable after failed policy restoration"
rm "$scratch/policy-failure"
da_remove_thunderbolt
pass "Thunderbolt rollback failure remains recoverable and retry succeeds"

fixture
eval "$(declare -f tb_json_write | sed '1s/tb_json_write/real_tb_json_write/')"
tb_json_write() {
  if [[ $1 == "$TB_STATE" && -f $scratch/state-write-failure ]]; then return 1; fi
  real_tb_json_write "$@"
}
mv() {
  if [[ ${!#} == "$TB_STATE" && -f $scratch/state-write-failure ]]; then return 1; fi
  command mv "$@"
}
findmnt() { echo ext4; }
touch "$scratch/state-write-failure"
reject da_main 0
[[ ! -e $TB_MARKER && -f $scratch/setup-recovery.json && ! -e $DA_STATE/completed ]] || fail "failed removal must preserve markerless recovery without claiming completion"
reject da_main 0
[[ -f $scratch/setup-recovery.json ]] || fail "repeated failure must retain recovery data"
rm "$scratch/state-write-failure"
da_main 0
[[ ! -e $scratch/setup-recovery.json && ! -e $TB_MARKER && -f $DA_STATE/completed ]] || fail "retry must finish recovery and removal before recording completion"
jq -e '.enabled==false' "$TB_STATE" >/dev/null || fail "recovered policy must finish disabled"
jq -e '.manager.AuthMode=="enabled" and .stored[0].Policy=="auto" and .stored[1].Policy=="manual"' "$scratch/inventory" >/dev/null || fail "recovery must preserve manual policy while handing back owned devices"
unset -f mv tb_json_write
eval "$(declare -f real_tb_json_write | sed '1s/real_tb_json_write/tb_json_write/')"
pass "markerless interrupted removal remains pending until migration-only recovery succeeds"

fixture
saved=$(tb_boot_saved <"$scratch/inventory" | jq -c --argjson state "$(cat "$TB_STATE")" '. + {state:$state}')
printf '%s\n' "$saved" >"$scratch/boot-recovery.json"
rm "$TB_MARKER"
touch "$scratch/cold-boot"
da_main 0
[[ ! -e $scratch/boot-recovery.json && ! -e $TB_MARKER && -f $DA_STATE/completed ]] || fail "boot-only recovery without a marker must complete"
jq -e '.enabled==false' "$TB_STATE" >/dev/null || fail "boot recovery must finish removal"
pass "migration-only boot recovery starts cold Bolt with the original entrypoints absent"

fixture
findmnt() { return 1; }
reject da_clean_factory
unset -f findmnt
pass "failed filesystem detection cannot silently skip factory repair"

fixture
mkdir -p "$scratch/bin" "$scratch/runtime/migrations" "$scratch/home/.config/systemd/user"
sed -e 's/\$HOME/\$ROLLBACK_USER_HOME/g' -e "s|/var/lib/omarchy/retired-device-authorization|$scratch/root-state|g" \
  -e "s|/var/lib/omarchy/thunderbolt-authorization|$scratch/system-thunderbolt|g" \
  -e "s|/etc/|$scratch/etc/|g" \
  -e "s|/usr/share/polkit-1/|$scratch/polkit/|g" \
  "$ROOT/migrations/1791670014.sh" >"$scratch/runtime/migrations/1791670014.sh"
mkdir -p "$scratch/runtime/migrations/retired-device-authorization"
sed -e 's/\$HOME/\$ROLLBACK_USER_HOME/g' -e "s|\${XDG_RUNTIME_DIR:-/run/user/\$UID}|$scratch/run|g" "$ROOT/migrations/retired-device-authorization/units.sh" >"$scratch/runtime/migrations/retired-device-authorization/units.sh"
cat >"$scratch/bin/omarchy-notification-dismiss" <<'SH'
exit 0
SH
cat >"$scratch/bin/sudo" <<'SH'
[[ $1 == /bin/bash && $2 == -p && $4 == rollback ]] || exit 90
echo "root rollback $5" >>"$ROLLBACK_TEST/calls"
[[ ! -f $ROLLBACK_TEST/root-failure ]]
SH
cat >"$scratch/bin/systemctl" <<'SH'
echo "$*" >>"$ROLLBACK_TEST/calls"
case $2 in
  show)
    if [[ $* == *ActiveState* && ! -f $ROLLBACK_TEST/user-stopped-${!#} ]]; then echo active; fi ;;
  stop) touch "$ROLLBACK_TEST/user-stopped-${!#}" ;;
  is-active|is-enabled) exit 1 ;;
esac
if [[ $1 == show && $* == *InvocationID* ]]; then echo 11111111111111111111111111111111; fi
SH
sed -e 's/\$HOME/\$ROLLBACK_USER_HOME/g' -e "s|/var/lib/pacman/db.lck|$scratch/no-pacman-lock|" "$ROOT/bin/omarchy-migrate" >"$scratch/bin/migrator"
chmod 755 "$scratch/bin/"*
ln -s /missing/retired-unit "$scratch/home/.config/systemd/user/omarchy-usb-authorization.service"
mkdir -p "$scratch/home/.config/systemd/user/default.target.wants"
ln -s /missing/retired-unit "$scratch/home/.config/systemd/user/default.target.wants/omarchy-thunderbolt-authorization.service"
run_migration() {
  PATH="$scratch/bin:$PATH" ROLLBACK_USER_HOME="$scratch/home" ROLLBACK_TEST=$scratch OMARCHY_PATH="$scratch/runtime" \
    "$scratch/bin/migrator"
}
touch "$scratch/root-failure"
reject run_migration
[[ $(grep '^root rollback' "$scratch/calls") == "root rollback 0" ]] || fail "a watcher alone must not identify ownership of a manual USB policy"
[[ ! -e $scratch/home/.local/state/omarchy/migrations/1791670014.sh ]] || fail "failed root rollback must stay pending"
[[ -f $scratch/home/.local/state/omarchy/device-authorization-rollback-pending &&
  -L $scratch/home/.config/systemd/user/omarchy-usb-authorization.service &&
  -L $scratch/home/.config/systemd/user/default.target.wants/omarchy-thunderbolt-authorization.service ]] || fail "root failures must retain watchers and the retry checkpoint"
! grep -q -- '--user stop\|--user disable' "$scratch/calls" || fail "failed removal must keep approval watchers running"
reject run_migration
! grep -q -- '--user stop\|--user disable' "$scratch/calls" || fail "repeated failure must preserve approval"
# Exercise the retained watcher callback and actual review after that failure.
# Only USBGuard and presentation are stubbed; requests and identity checks are real.
for name in omarchy-usb-authorization-event omarchy-usb-authorization-review; do
  sed 's/\$HOME/\$ROLLBACK_USER_HOME/g' "$ROOT/bin/$name" >"$scratch/bin/$name"
done
cat >"$scratch/bin/usbguard" <<'SH'
case $1 in
  watch) USBGUARD_IPC_SIGNAL=IPC.Connected "$ROLLBACK_TEST/bin/omarchy-usb-authorization-event" ;;
  list-devices)
    if [[ -f $ROLLBACK_TEST/approved ]]; then
      [[ ${2:-} == --blocked ]] || echo '17: allow id 1234:5678 name "Pending accessory"'
    else
      echo '17: block id 1234:5678 name "Pending accessory"'
    fi ;;
  allow-device)
    [[ $2 == 'block id 1234:5678 name "Pending accessory"' ]] || exit 1
    touch "$ROLLBACK_TEST/approved" ;;
esac
SH
printf 'exit 0\n' >"$scratch/bin/omarchy-notification-wait"
printf 'echo "notification $*" >>"$ROLLBACK_TEST/calls"\n' >"$scratch/bin/omarchy-notification-send"
printf '[[ $1 != choose ]] || echo "Allow once"\n' >"$scratch/bin/gum"
chmod 755 "$scratch/bin/"*
ln -s "$scratch/bin" "$scratch/runtime/bin"
(
  export PATH="$scratch/bin:$PATH" ROLLBACK_USER_HOME="$scratch/home" ROLLBACK_TEST=$scratch OMARCHY_PATH=$scratch/runtime
  "$ROOT/bin/omarchy-usb-authorization-watch"
  requests=("$scratch/home/.local/state/omarchy/usb-authorization/requests/"request-*.json)
  [[ -f ${requests[0]} ]] || fail "failed removal must still offer approval"
  token=${requests[0]##*/}
  "$scratch/bin/omarchy-usb-authorization-review" "${token%.json}" >"$scratch/review-output"
)
[[ -f $scratch/approved ]] || fail "approval after failed removal did not authorize the device"
pass "failed removal keeps the watcher-to-approval path usable"
rm "$scratch/root-failure"
run_migration
[[ -f $scratch/home/.local/state/omarchy/migrations/1791670014.sh &&
  -L $scratch/home/.config/systemd/user/omarchy-usb-authorization.service.retired ]] || fail "successful migration retires dangling user units"
grep -q 'root rollback 0' "$scratch/calls" || fail "a watcher alone must not identify ownership of a manual USB policy"
grep -q -- '--user stop omarchy-thunderbolt-authorization.service' "$scratch/calls" || fail "the not-found running Thunderbolt watcher must stop"
[[ ! -L $scratch/home/.config/systemd/user/default.target.wants/omarchy-thunderbolt-authorization.service ]] || fail "the user watcher must lose its dangling enable link"
before=$(wc -l <"$scratch/calls")
run_migration
[[ $(wc -l <"$scratch/calls") == "$before" ]] || fail "a completed migration is not run twice"
pass "migration retries root failures, handles dangling user units, and marks only complete rollback"

mkdir -p "$scratch/root-state"
echo 'Omarchy accessory rollback complete' >"$scratch/root-state/completed"
chmod 644 "$scratch/root-state/completed"
stat() { if [[ $* == *root-state/completed* ]]; then echo 0:644; else command stat "$@"; fi; }
export -f stat
ROLLBACK_USER_HOME="$scratch/another-home" PATH="$scratch/bin:$PATH" OMARCHY_PATH="$scratch/runtime" ROLLBACK_TEST=$scratch \
  bash -euo pipefail "$scratch/runtime/migrations/1791670014.sh"
unset -f stat
[[ $(grep -c '^root rollback' "$scratch/calls") == 3 ]] || fail "a completed machine must not ask another user for sudo"
pass "machine completion allows later users to clean their units without sudo"

rm "$scratch/root-state/completed"
rmdir "$scratch/root-state"
ROLLBACK_USER_HOME="$scratch/fresh-home" PATH="$scratch/bin:$PATH" OMARCHY_PATH="$scratch/runtime" ROLLBACK_TEST=$scratch \
  bash -euo pipefail "$scratch/runtime/migrations/1791670014.sh"
[[ $(grep -c '^root rollback' "$scratch/calls") == 3 ]] || fail "fresh machines with no retired state must not prompt for sudo"
pass "fresh machines with no retired state need no root action"

# History is the same after first-install stamping and successful removal.
mkdir -p "$scratch/fresh-home/.local/state/omarchy/migrations"
touch "$scratch/fresh-home/.local/state/omarchy/migrations/1789433473.sh" \
  "$scratch/fresh-home/.local/state/omarchy/device-authorization-rollback-pending"
ROLLBACK_USER_HOME="$scratch/fresh-home" PATH="$scratch/bin:$PATH" OMARCHY_PATH="$scratch/runtime" ROLLBACK_TEST=$scratch \
  bash -euo pipefail "$scratch/runtime/migrations/1791670014.sh"
[[ $(tail -n 1 <(grep '^root rollback' "$scratch/calls")) == "root rollback 0" ]] || fail "history must not claim independent USBGuard ownership"
pass "stale migration history preserves independent USB ownership during a pending repair"

mkdir -p "$scratch/fresh-home/.local/state/omarchy/usb-authorization"
touch "$scratch/fresh-home/.local/state/omarchy/usb-authorization/policy-generated-by-omarchy"
ROLLBACK_USER_HOME="$scratch/fresh-home" PATH="$scratch/bin:$PATH" OMARCHY_PATH="$scratch/runtime" ROLLBACK_TEST=$scratch \
  bash -euo pipefail "$scratch/runtime/migrations/1791670014.sh"
[[ $(tail -n 1 <(grep '^root rollback' "$scratch/calls")) == "root rollback 1" ]] || fail "current enrollment must still identify Omarchy USB policy"
pass "current USB enrollment still invokes removal"
