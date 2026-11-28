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
# timezone; the function is taken from owner setup itself. Owner setup runs as
# a systemd service, so the scripts it starts see OMARCHY_PATH only if its
# preamble hands it on. Only the lines after set -euo pipefail that start with
# an assignment are run, up to the first line that does not.
(
  unset OMARCHY_PATH
  eval "$(awk '/^set -euo pipefail$/ { on = 1; next } on && !/^(#|$|(export )?[A-Z_]+=)/ { exit } on' "$ROOT/bin/omarchy-provision-owner")"
  [[ $(bash -c 'echo "${OMARCHY_PATH:-}"') == "/usr/share/omarchy" ]]
) || fail "owner setup hands OMARCHY_PATH to the scripts it starts"
eval "$(sed -n '/^configure_region() {$/,/^}$/p' "$ROOT/bin/omarchy-provision-owner")"
region_root=$scratch/region
mkdir -p "$region_root/omarchy/bin" "$region_root/omarchy/install/config" "$region_root/etc/omarchy"
ln -s "$ROOT/default" "$region_root/omarchy/default"
printf '#!/bin/bash\necho "apply $*" >>"$REGION_LOG"\n' >"$region_root/omarchy/bin/omarchy-apply-pacman"
chmod +x "$region_root/omarchy/bin/omarchy-apply-pacman"
printf 'echo region >>"$REGION_LOG"\n' >"$region_root/omarchy/install/config/region.sh"
export OMARCHY_PATH=$region_root/omarchy OMARCHY_FORM_DEFAULTS=$region_root/etc/omarchy/form-defaults \
  OMARCHY_REGION_FILE=$region_root/etc/omarchy/region OMARCHY_PACMAN_CONF=$region_root/etc/pacman.conf \
  OMARCHY_REGION_TARGET=$region_root REGION_LOG=$region_root/log
printf '[omarchy]\nServer = https://pkgs.omarchy.cn/stable/$arch\nServer = https://pkgs.omarchy.org/stable/$arch\n' >"$OMARCHY_PACMAN_CONF"
# settle <installed region> <timezone>: the region the owner ends up with.
settle() {
  timezone=$2
  if [[ $1 == "global" ]]; then rm -f "$OMARCHY_REGION_FILE"; else printf '%s\n' "$1" >"$OMARCHY_REGION_FILE"; fi
  : >"$REGION_LOG"
  configure_region >/dev/null
  [[ -e $OMARCHY_REGION_FILE ]] && cat "$OMARCHY_REGION_FILE" || echo global
}
# media_settles <media region> <timezone:region>...
media_settles() {
  local media=$1 case
  shift
  printf 'REGION=%s\n' "$media" >"$OMARCHY_FORM_DEFAULTS"
  for case in "$@"; do
    [[ $(settle "$media" "${case%%:*}") == "${case#*:}" ]] || fail "an owner in ${case%%:*} on $media media gets the ${case#*:} region"
    if [[ ${case#*:} == "$media" ]]; then
      [[ ! -s $REGION_LOG ]] || fail "keeping the media's region leaves pacman alone"
    else
      grep -qx "apply stable $region_root" "$REGION_LOG" || fail "a new region re-renders pacman for the installed channel" "$(cat "$REGION_LOG")"
      grep -qx "region" "$REGION_LOG" || fail "a new region re-applies its mirrors" "$(cat "$REGION_LOG")"
    fi
  done
}
media_settles cn Asia/Shanghai:cn UTC:cn Europe/Copenhagen:cn \
  Asia/Hong_Kong:global Hongkong:global Asia/Macau:global Asia/Macao:global Asia/Taipei:global ROC:global
media_settles global Asia/Shanghai:cn Asia/Urumqi:cn PRC:cn UTC:global America/New_York:global \
  Asia/Hong_Kong:global Asia/Macau:global Asia/Taipei:global
printf 'KEYBOARD=English (US)\n' >"$OMARCHY_FORM_DEFAULTS"
[[ $(settle cn Asia/Taipei) == cn && ! -s $REGION_LOG ]] || fail "a region the media did not choose is left alone"
pass "a deferred install settles its media's region against the owner's timezone, and Hong Kong, Macau and Taiwan are always global"
