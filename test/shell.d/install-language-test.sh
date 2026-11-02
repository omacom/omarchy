#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export OMARCHY_PATH="$scratch/omarchy" OMARCHY_INSTALL="$ROOT/install" COMMAND_LOG="$scratch/commands"
mkdir -p "$OMARCHY_PATH/bin"
for command in omarchy-locale-generate omarchy-language; do
  printf '#!/bin/bash\nprintf "%%s %%s\\n" "${0##*/}" "$*" >>"$COMMAND_LOG"\n' >"$OMARCHY_PATH/bin/$command"
  chmod +x "$OMARCHY_PATH/bin/$command"
done
export OMARCHY_LANGUAGE_MARKER="$scratch/language"

system_step() { : >"$COMMAND_LOG"; bash -e -c 'source "$1"' bash "$ROOT/install/config/language.sh" 2>"$scratch/err"; }

system_step
[[ ! -s $COMMAND_LOG ]] || fail "no preset language generates no locale"
printf 'zh-CN\n' >"$OMARCHY_LANGUAGE_MARKER"
system_step
[[ $(<"$COMMAND_LOG") == "omarchy-locale-generate zh-CN" ]] || fail "a preset language generates its locale" "$(<"$COMMAND_LOG")"
for bad in 'zh_CN' '../x' 'zh-CN; reboot' '$(touch NEVER)'; do
  printf '%s\n' "$bad" >"$OMARCHY_LANGUAGE_MARKER"
  system_step
  [[ ! -s $COMMAND_LOG ]] || fail "a malformed preset is never passed on: $bad" "$(<"$COMMAND_LOG")"
done
pass "the system step generates only a well-formed preset language's locale"

grep -qxF '[[ -r /etc/omarchy/language ]] && read -r code </etc/omarchy/language' "$ROOT/install/user/language.sh" ||
  fail "the user step reads the preset as data"
! grep -qE '(^|[^a-z])(source|\.) .*/etc/omarchy/language' "$ROOT/install/user/language.sh" "$ROOT/install/config/language.sh" ||
  fail "neither step sources the preset"
pass "neither finalization step runs the preset as code"

# The user step's `omarchy-language seed`: the real command, with the outside
# world stubbed, so it is seen to elevate and notify nothing.
work=$scratch/seed
mkdir -p "$work/stubs"
export XDG_CONFIG_HOME=$work/config OMARCHY_LANGUAGE_FILE=$work/language SEED_LOG=$work/log
for command in sudo pkexec locale-gen omarchy-notification-send dbus-update-activation-environment; do
  printf '#!/bin/bash\necho "%s $*" >>"$SEED_LOG"\n' "$command" >"$work/stubs/$command"
done
chmod +x "$work/stubs/"*
seed() { : >"$SEED_LOG"; OMARCHY_PATH=$ROOT PATH="$work/stubs:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-language" seed "$@" </dev/null; }
seed zh-CN
[[ $(<"$OMARCHY_LANGUAGE_FILE") == zh-CN ]] || fail "seeding persists the preset language"
grep -qx 'export LANG=zh_CN.UTF-8' "$XDG_CONFIG_HOME/uwsm/env.d/50-omarchy-language" || fail "seeding sets the session LANG for the first login"
! grep -qE '^(sudo|pkexec|locale-gen|omarchy-notification-send) ' "$SEED_LOG" || fail "seeding elevates, generates and notifies nothing" "$(<"$SEED_LOG")"
if seed xx 2>/dev/null; then fail "seeding rejects unknown codes"; fi
printf 'da\n' >"$OMARCHY_LANGUAGE_FILE"
seed zh-CN
[[ $(<"$OMARCHY_LANGUAGE_FILE") == da ]] || fail "seeding keeps a language the user already chose"
! grep -q '^dbus-update-activation-environment ' "$SEED_LOG" || fail "seeding needs no session bus" "$(<"$SEED_LOG")"
pass "seeding sets the user's language and session LANG without elevating or notifying"

# A deferred install's region, settled at first boot against the owner's
# timezone; the function is taken from owner setup itself.
eval "$(sed -n '/^configure_region() {$/,/^}$/p' "$ROOT/bin/omarchy-provision-owner")"
region_root=$scratch/region
mkdir -p "$region_root/omarchy/default/regions/cn" "$region_root/omarchy/bin" "$region_root/etc/omarchy"
printf 'Asia/Shanghai\nAsia/Urumqi\n' >"$region_root/omarchy/default/regions/cn/timezones"
printf '#!/bin/bash\necho "apply $*" >>"$REGION_LOG"\n' >"$region_root/omarchy/bin/omarchy-apply-pacman"
chmod +x "$region_root/omarchy/bin/omarchy-apply-pacman"
export OMARCHY_FORM_DEFAULTS=$region_root/etc/omarchy/form-defaults OMARCHY_REGION_FILE=$region_root/etc/omarchy/region \
  OMARCHY_PACMAN_CONF=$region_root/etc/pacman.conf OMARCHY_REGION_TARGET=$region_root REGION_LOG=$region_root/log
printf '[omarchy]\nServer = https://pkgs.omarchy.cn/stable/$arch\nServer = https://pkgs.omarchy.org/stable/$arch\n' >"$OMARCHY_PACMAN_CONF"
settle() {
  timezone=$1
  printf 'cn\n' >"$OMARCHY_REGION_FILE"
  : >"$REGION_LOG"
  OMARCHY_PATH=$region_root/omarchy configure_region
  [[ -e $OMARCHY_REGION_FILE ]] && cat "$OMARCHY_REGION_FILE" || echo global
}
printf 'KEYBOARD=Chinese (Simplified, Pinyin)\nTIMEZONE=Asia/Shanghai\nREGION=cn\n' >"$OMARCHY_FORM_DEFAULTS"
for case in Asia/Shanghai:cn UTC:cn Europe/Copenhagen:cn Asia/Hong_Kong:global Hongkong:global Asia/Macau:global Asia/Macao:global Asia/Taipei:global ROC:global; do
  [[ $(settle "${case%%:*}") == "${case#*:}" ]] || fail "an owner in ${case%%:*} gets the ${case#*:} region"
  if [[ ${case#*:} == global ]]; then
    grep -qx "apply stable $region_root" "$REGION_LOG" || fail "leaving China re-renders pacman for the installed channel" "$(cat "$REGION_LOG")"
  else
    [[ ! -s $REGION_LOG ]] || fail "keeping the region leaves pacman alone"
  fi
done
printf 'KEYBOARD=English (US)\n' >"$OMARCHY_FORM_DEFAULTS"
[[ $(settle Asia/Taipei) == cn && ! -s $REGION_LOG ]] || fail "a region the media did not choose is left alone"
pass "a deferred install settles the media's region against the owner's timezone, and Hong Kong, Macau and Taiwan are always World"
