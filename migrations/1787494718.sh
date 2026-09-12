echo "Take ownership of the FIDO2 authfile so it cannot be rewritten without root"

authfile=/etc/fido2/fido2

report_unrepairable() {
  echo "  $1"
  echo "  $2"
  omarchy-notification-send -u critical -g  "FIDO2 authfile needs attention" "$1 $2" || true
}

needs_machine_repair() {
  local owner group mode authdir=${authfile%/*}
  if [[ ! -L $authfile && ! -e $authfile ]]; then
    [[ ! -L $authdir && -d $authdir && ! -x $authdir ]] && return 0
    return 1
  fi
  [[ -L $authfile ]] && return 0
  [[ -f $authfile ]] || return 0
  owner=$(/usr/bin/stat -c %U "$authfile" 2>/dev/null) || return 0
  group=$(/usr/bin/stat -c %G "$authfile" 2>/dev/null) || return 0
  mode=$(/usr/bin/stat -c %a "$authfile" 2>/dev/null) || return 0
  [[ $owner != "root" || $group != "root" || $mode != "644" ]]
}

repair_machine() (
  local owner group mode authdir=${authfile%/*} authdir_mode stage=""
  if [[ ! -L $authfile && ! -e $authfile ]]; then
    [[ ! -L $authdir && -d $authdir ]] || return 0
    if [[ ! -e $authfile && ! -L $authfile ]]; then return 0; fi
  fi
  if [[ ! -L $authdir && -d $authdir && ( -e $authfile || -L $authfile ) ]]; then
    authdir_mode=$(/usr/bin/stat -c %a "$authdir")
    if (( (10#${authdir_mode: -1} & 1) == 0 )); then
      /usr/bin/chmod 755 "$authdir"
    fi
  fi
  [[ ! -L $authfile ]] || return 20
  [[ -f $authfile ]] || return 21
  owner=$(/usr/bin/stat -c %U "$authfile")
  group=$(/usr/bin/stat -c %G "$authfile")
  mode=$(/usr/bin/stat -c %a "$authfile")
  [[ $owner != "root" || $group != "root" || $mode != "644" ]] || return 0

  stage=$(/usr/bin/mktemp "$authfile.new.XXXXXX")
  trap '[[ -z $stage ]] || /usr/bin/rm -f -- "$stage"' EXIT
  [[ $stage == "$authfile.new."* && ${stage#"$authfile.new."} =~ ^[[:alnum:]]{6}$ && -f $stage && ! -L $stage ]]
  /usr/bin/install -T -m 644 -o root -g root "$authfile" "$stage"
  /usr/bin/mv -Tf "$stage" "$authfile"
  stage=""
)

if (( $# == 0 )); then
  needs_machine_repair || exit 0
  status=0
  /usr/bin/sudo -N -- /usr/bin/flock --exclusive --no-fork /run/omarchy-fido2-authfile-migration.lock \
    /usr/bin/env -i PATH=/usr/bin:/bin \
    /usr/bin/bash -p -euo pipefail /usr/share/omarchy/migrations/1787494718.sh --machine || status=$?
  case $status in
  0) ;;
  20)
    report_unrepairable "$authfile is a symlink, not a regular file." \
      "Leaving it alone. If you did not create it, remove it and re-run Setup > Security > Fido2."
    ;;
  21)
    report_unrepairable "$authfile is not a regular file." \
      "Leaving it alone. Remove it and re-run Setup > Security > Fido2."
    ;;
  *) exit "$status" ;;
  esac
elif (( $# == 1 && EUID == 0 )) && [[ $1 == "--machine" ]]; then
  repair_machine
else
  echo "This migration accepts no arguments; its machine phase requires root." >&2
  exit 1
fi
