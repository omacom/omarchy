# Shared helpers for the omarchy-user-* commands.
#
# A login account is one in the UID_MIN..UID_MAX range with a login shell.
# Administrators are the members of wheel: the group Omarchy's sudoers and
# polkit (unix-group:wheel) trust, and the only privilege switch these commands
# use.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/as-root.sh"

# The person running the command, also when it runs under sudo.
user_accounts_self() {
  printf '%s\n' "${SUDO_USER:-$(id -un)}"
}

user_accounts_login_def() {
  local value
  value=$(awk -v key="$1" '$1 == key { print $2; exit }' "${OMARCHY_LOGIN_DEFS:-/etc/login.defs}" 2>/dev/null || true)
  if [[ $value =~ ^[0-9]+$ ]]; then
    printf '%s\n' "$value"
  else
    printf '%s\n' "$2"
  fi
}

# Prints "name<TAB>uid<TAB>gid" for every login account.
user_accounts_login_users() {
  local uid_min uid_max
  uid_min=$(user_accounts_login_def UID_MIN 1000)
  uid_max=$(user_accounts_login_def UID_MAX 60000)

  getent passwd | while IFS=: read -r name _ uid gid _ _ shell; do
    (( uid >= uid_min && uid <= uid_max )) || continue
    [[ $shell == */nologin || $shell == */false ]] && continue
    printf '%s\t%s\t%s\n' "$name" "$uid" "$gid"
  done
}

user_accounts_is_login_user() {
  user_accounts_login_users | awk -F '\t' -v user="$1" '$1 == user { found = 1 } END { exit !found }'
}

# Whether account $1 is in group $2, as a member or through its primary group.
user_accounts_in_group() {
  local group gid
  group=$(getent group "$2" || true)
  [[ ",$(cut -d: -f4 <<<"$group")," == *",$1,"* ]] && return 0
  gid=$(getent passwd "$1" | cut -d: -f4)
  [[ -n $gid && $gid == "$(cut -d: -f3 <<<"$group")" ]]
}

user_accounts_is_admin() {
  user_accounts_in_group "$1" wheel
}

# Prints the login accounts that are administrators, one per line.
user_accounts_admins() {
  local name
  user_accounts_login_users | while IFS=$'\t' read -r name _ _; do
    if user_accounts_is_admin "$name"; then
      printf '%s\n' "$name"
    fi
  done
}

user_accounts_has_programs() {
  pgrep -u "$1" >/dev/null
}

user_accounts_programs_end() {
  local _
  for _ in {1..10}; do
    user_accounts_has_programs "$1" || return 0
    sleep 0.5
  done
  return 1
}

# Ends the user's login sessions, then any programs that outlive them, such as
# ones started with su or cron. Fails if something is still running.
user_accounts_sign_out() {
  as_root loginctl terminate-user "$1" 2>/dev/null || true
  if ! user_accounts_programs_end "$1"; then
    as_root pkill -KILL -u "$1" || true
    user_accounts_programs_end "$1"
  fi
}

# Lowercase letter or underscore first, then lowercase letters, digits, _ or -,
# at most 32 characters. No dots: sudo ignores sudoers.d files whose names
# contain one, and no trailing $ (machine accounts).
user_accounts_valid_name() {
  [[ $1 =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]
}

# One plain-language line per change, so `journalctl -t omarchy-user` reads as
# a history of who did what.
user_accounts_log() {
  logger -t omarchy-user -- "$*" 2>/dev/null || true
}

user_accounts_sudoers_dir() {
  printf '%s\n' "${OMARCHY_SUDOERS_DIR:-/etc/sudoers.d}"
}

# Omarchy's first-boot provisioning gives wheel sudo with this drop-in, but an
# install from the ISO grants it to the owner by name instead (archinstall's
# NN_<owner>), so a second administrator would get none. Adding one writes the
# same drop-in; like provisioning, it doesn't look for an equivalent grant,
# since a duplicate is harmless.
user_accounts_ensure_wheel_sudo() {
  local rule staged
  rule="$(user_accounts_sudoers_dir)/00-omarchy-wheel"

  if as_root test -e "$rule"; then
    return 0
  fi

  # sudo skips files whose names contain a dot, so the staged copy stays inert.
  staged="$rule.new"
  if printf '%s\n' '%wheel ALL=(ALL:ALL) ALL' | as_root tee "$staged" >/dev/null &&
    as_root chmod 0440 "$staged" && as_root visudo -cqf "$staged"; then
    as_root mv -f "$staged" "$rule" || return 1
    user_accounts_log "administrators in wheel now get sudo from $rule"
  else
    as_root rm -f "$staged"
    return 1
  fi
}

# Prints the files the installer wrote to grant this user sudo by name: NN_<name>
# holding nothing but "<name> ALL=(ALL) ALL". Anything else is left alone. Fails
# when the directory or a file can't be read, rather than finding nothing.
user_accounts_installer_grants() {
  local found file content
  found=$(as_root find "$(user_accounts_sudoers_dir)" -maxdepth 1 -type f -name "[0-9][0-9]_$1") || return 1
  while IFS= read -r file; do
    [[ -n $file ]] || continue
    content=$(as_root cat "$file") || return 1
    if [[ $(grep -v '^[[:space:]]*$' <<<"$content") == "$1 ALL=(ALL) ALL" ]]; then
      printf '%s\n' "$file"
    fi
  done <<<"$found"
}

user_accounts_drop_installer_grants() {
  local files file
  files=$(user_accounts_installer_grants "$1") || return 1
  while IFS= read -r file; do
    [[ -n $file ]] || continue
    as_root rm -f "$file" || return 1
    user_accounts_log "removed the installer's sudo grant for '$1' ($file)"
  done <<<"$files"
}

# True when sudo lets the user run any command as root.
user_accounts_has_full_sudo() {
  local privileges
  privileges=$(as_root sudo -l -U "$1" 2>/dev/null) || return 1
  # Root among the users it may run as, with any group after them, any tags
  # (NOPASSWD:, SETENV:, NOEXEC:...) and any exceptions after a comma, still
  # runs anything else as root.
  grep -qE '^[[:space:]]+\(([^):]*,[[:space:]]*)?(ALL|root)([[:space:]]*,[^):]*)?([[:space:]]*:[^)]*)?\) ([A-Z_]+:[[:space:]]*)*ALL(,|$)' <<<"$privileges"
}

user_accounts_login_count() {
  user_accounts_login_users | wc -l
}

# One change to the accounts at a time: what a command checks (how many
# accounts there are, who the administrators are) must still hold when it
# acts, so the checks and the changes happen under one machine-wide lock.
# Only root can open the file, so only an administrator can hold the lock: a
# root process holds it for as long as this command runs (it reads our pipe
# and ends when the command does, however the command ends). This comes after
# sudo is open and before any check.
user_accounts_lock() {
  local lock=${OMARCHY_USER_LOCK:-/run/lock/omarchy-user.lock} held
  as_root sh -c 'umask 077 && : >>"$1" && chmod 0600 "$1"' _ "$lock" || return 1
  coproc user_accounts_lock_holder { as_root flock -n "$lock" sh -c 'echo held && cat >/dev/null'; }
  read -r held <&"${user_accounts_lock_holder[0]}" 2>/dev/null && [[ $held == "held" ]]
}

# The lowest free UID that owns nothing under /home, so the files of an
# account whose home folder was kept never pass to a later account.
user_accounts_free_uid() {
  local uid_min uid_max
  uid_min=$(user_accounts_login_def UID_MIN 1000)
  uid_max=$(user_accounts_login_def UID_MAX 60000)
  { getent passwd | cut -d: -f3; stat -c '%u' "${OMARCHY_HOME_ROOT:-/home}"/* 2>/dev/null; } |
    awk -v min="$uid_min" -v max="$uid_max" '{ taken[$1] = 1 } END { for (uid = min; uid <= max; uid++) if (!(uid in taken)) { print uid; exit } }' |
    grep .
}

# Omarchy's passwordless-sudo grants (omarchy-sudo-passwordless) name the
# account by UID, so a UID handed to a later account would carry them along.
user_accounts_drop_passwordless_grants() { # NAME UID
  local file removed
  for file in "$(user_accounts_sudoers_dir)/99-omarchy-nopasswd-$2" "$(user_accounts_sudoers_dir)/99-omarchy-permanent-nopasswd-$2"; do
    # One call that fails on any error, and says when it removed something.
    removed=$(as_root rm -fv -- "$file") || return 1
    [[ -z $removed ]] || user_accounts_log "removed the passwordless sudo grant of '$1' ($file)"
  done
}

# The LUKS device holding /, or nothing on an unencrypted install: the walk
# omarchy-drive-password does. Like it, this fails when / sits on an encryption
# layer whose LUKS device can't be told, because then nobody can say which
# password opens the disk, and the switch must not guess.
user_accounts_root_luks() {
  local source ancestry device
  source=$(findmnt -no SOURCE / 2>/dev/null) && [[ -n $source ]] || return 1
  ancestry=$(lsblk -nsrpo NAME,TYPE,FSTYPE "${source%%[*}" 2>/dev/null) || return 1
  device=$(awk '$3 == "crypto_LUKS" { print $1; exit }' <<<"$ancestry")
  if [[ -n $device ]]; then
    readlink -f "$device"
  elif awk '$2 == "crypt" { found = 1 } END { exit !found }' <<<"$ancestry"; then
    return 1
  fi
}

user_accounts_root_luks_or_explain() {
  user_accounts_root_luks || { echo "Couldn't tell which drive holds the system, so no password can be checked against the disk." >&2; return 1; }
}

# Whether password $2 opens disk $1: prints "opens" or "refused". cryptsetup
# tries enrolled tokens before the key, so allow only a token type none has, as
# omarchy-drive-password does. It reports a wrong passphrase as status 2; any
# other failure (an I/O or memory error, a busy device, sudo itself) is neither
# answer, so this fails and the caller stops. An empty password opens nothing.
user_accounts_try_disk_password() {
  local status=0
  if [[ -z $2 ]]; then
    echo refused
    return 0
  fi
  printf '%s' "$2" | as_root cryptsetup open --test-passphrase --token-type passphrase-only --key-file - "$1" >/dev/null 2>&1 || status=$?
  case $status in
  0) echo opens ;;
  2) echo refused ;;
  *)
    echo "Couldn't check a password against $1 (cryptsetup status $status)." >&2
    return 1
    ;;
  esac
}

# Whether the password is the user's login password, checked against its hash.
user_accounts_password_is() {
  local hash
  hash=$(as_root getent shadow "$1" | cut -d: -f2) || return 1
  [[ -n $hash && $hash != '!'* && $hash != '*'* ]] || return 1
  printf '%s\n' "$2" | HASH="$hash" perl -e 'my $p = <STDIN>; chomp $p; exit(crypt($p, $ENV{HASH}) eq $ENV{HASH} ? 0 : 1)'
}

user_accounts_autologin_conf() {
  printf '%s\n' "${OMARCHY_SDDM_AUTOLOGIN:-/etc/sddm.conf.d/autologin.conf}"
}

# The same file the installer writes.
user_accounts_autologin_on() {
  printf '[Autologin]\nUser=%s\nSession=omarchy.desktop\n' "$1" | as_root tee "$(user_accounts_autologin_conf)" >/dev/null
}

user_accounts_autologin_off() {
  as_root rm -f "$(user_accounts_autologin_conf)"
}

user_accounts_root_locked() {
  [[ $(as_root passwd -S root 2>/dev/null | awk '{ print $2 }') == "L" ]]
}

# Asks until the user types their own login password, and prints it. It also
# opens sudo with it, so the steps that follow don't ask again; the hash check
# stands even when sudo needs no password.
# Three tries, as sudo gives: every wrong one counts towards the login lockout
# (pam_faillock), which would turn an unbounded loop into a locked account.
user_accounts_ask_own_password() {
  local password attempt
  for attempt in 1 2 3; do
    password=$(gum input --password --prompt "$(omarchy-i18n user.yourPassword "$1")") || { echo "Cancelled." >&2; return 1; }
    if printf '%s\n' "$password" | sudo -S -p '' true 2>/dev/null && user_accounts_password_is "$1" "$password"; then
      printf '%s\n' "$password"
      return 0
    fi
    if (( attempt < 3 )); then
      echo "That isn't your password. Try again." >&2
    fi
  done
  echo "That isn't your password. Nothing was changed." >&2
  return 1
}

# Asks for a new password twice until both match and the check in $2 (a
# function given the arguments after it, then the password) accepts it, and
# prints it. The check returns 1 to ask again; any other failure stops.
user_accounts_ask_new_password() {
  local prompt=$1 check=$2 password confirmation status
  shift 2
  while true; do
    password=$(gum input --password --prompt "$prompt") || return 1
    confirmation=$(gum input --password --prompt "$(omarchy-i18n user.repeatIt)") || return 1
    if [[ -z $password ]]; then
      echo "The password can't be empty." >&2
    elif [[ $password != "$confirmation" ]]; then
      echo "The passwords don't match. Try again." >&2
    else
      status=0
      "$check" "$@" "$password" || status=$?
      if (( status == 0 )); then
        printf '%s\n' "$password"
        return 0
      fi
      (( status == 1 )) || return 1
    fi
  done
}

# What going from one login account to two changes, and the go-ahead for it.
# The checks user_accounts_go_multi asks with: the shared disk password must
# be neither the administrator's own ($1) nor the new account's ($2), and a new
# own password must not open the disk ($1).
_user_accounts_not_this_one() {
  [[ $3 != "$1" ]] || { echo "That's your own password; the disk needs a different one." >&2; return 1; }
  [[ -z $2 || $3 != "$2" ]] || { echo "That's the new account's password; the disk needs a different one." >&2; return 1; }
}

_user_accounts_not_the_disk_key() {
  local result
  result=$(user_accounts_try_disk_password "$1" "$2") || return 2
  [[ $result == "refused" ]] || { echo "That one unlocks the disk; choose one that doesn't." >&2; return 1; }
}

user_accounts_explain_multi() {
  local disk
  disk=$(user_accounts_root_luks_or_explain) || return 1
  echo "This will be the second account on this computer, so:"
  if [[ -n $disk ]]; then
    echo "  • the disk password is shared with everyone who starts the computer, so it must differ from your password"
  fi
  echo "  • the login screen asks for a user name, instead of logging you in automatically"
  echo "  • root is locked; administrators use sudo"
  gum confirm --affirmative "$(omarchy-i18n common.yes)" --negative "$(omarchy-i18n common.no)" "$(omarchy-i18n user.continue)"
}

# Before the second login account: one person no longer owns everything. The
# disk password, which everyone who starts the computer types, must stop being
# the first administrator's own password; root is locked; and the login screen
# asks who is logging in instead of logging the owner in automatically. $2 is
# the administrator's password, already checked, and $3 the new account's.
user_accounts_go_multi() {
  local self=$1 mine=$2 theirs=${3:-} disk choice new share own output opens="" changed
  disk=$(user_accounts_root_luks_or_explain) || return 1
  if [[ -n $disk ]]; then
    user_accounts_own_change_finished || return 2
    opens=$(user_accounts_try_disk_password "$disk" "$mine") || return 1
  fi
  if [[ $opens == "opens" ]]; then
    share=$(omarchy-i18n user.choiceShareDisk)
    own=$(omarchy-i18n user.choiceNewOwn)
    choice=$(gum choose --header "$(omarchy-i18n user.whichPassword)" "$share" "$own") || return 1
    if [[ $choice == "$share" ]]; then
      new=$(user_accounts_ask_new_password "$(omarchy-i18n user.newDiskPassword)" _user_accounts_not_this_one "$mine" "$theirs") || return 1
      # An earlier change that stopped part way must be finished by a person
      # (omarchy-drive-password keeps a record of it and refuses until then):
      # status 2, so the caller can say what to do.
      if ! output=$(printf '%s\n%s\n' "$mine" "$new" | omarchy-drive-password --system-stdin 2>&1); then
        printf '%s\n' "$output" >&2
        [[ $output != *"stopped part way"* ]] || return 2
        return 1
      fi
      [[ -z $output ]] || printf '%s\n' "$output"
      opens=$(user_accounts_try_disk_password "$disk" "$mine") || return 1
      changed=$(user_accounts_try_disk_password "$disk" "$new") || return 1
      if [[ $opens == "opens" || $changed == "refused" ]]; then
        echo "The disk password didn't change." >&2
        return 1
      fi
      user_accounts_log "disk password changed by $self, so it no longer matches their login password"
    else
      new=$(user_accounts_ask_new_password "$(omarchy-i18n user.newOwnPassword)" _user_accounts_not_the_disk_key "$disk") || return 1
      printf '%s:%s\n' "$self" "$new" | as_root chpasswd || return 1
      user_accounts_log "login password of $self changed, so it no longer matches the disk password"
    fi
  fi

  if ! user_accounts_root_locked; then
    as_root passwd -l root >/dev/null || return 1
    user_accounts_log "root account locked by $self: a second login account is being added"
  fi
  if as_root test -e "$(user_accounts_autologin_conf)"; then
    user_accounts_autologin_off || return 1
    user_accounts_log "automatic login turned off by $self: a second login account is being added"
  fi
}

# Back to one login account: a normal single-user Omarchy again, as the
# installer leaves it. One password for the login, root and the disk, and on an
# encrypted install automatic login once the disk is unlocked. $2 is the
# remaining administrator's password, already checked.
user_accounts_go_single() {
  local self=$1 mine=$2 disk current output opens="" keys
  disk=$(user_accounts_root_luks_or_explain) || return 1
  if [[ -n $disk ]]; then
    user_accounts_own_change_finished || return 2
    opens=$(user_accounts_try_disk_password "$disk" "$mine") || return 1
  fi
  if [[ $opens == "refused" ]]; then
    while true; do
      current=$(gum input --password --prompt "$(omarchy-i18n user.currentDiskPassword)") || return 1
      opens=$(user_accounts_try_disk_password "$disk" "$current") || return 1
      [[ $opens != "opens" ]] || break
      echo "That doesn't unlock the disk. Try again." >&2
    done
    # As in user_accounts_go_multi: an earlier change that stopped part way
    # must be finished by a person first, status 2.
    if ! output=$(printf '%s\n%s\n' "$current" "$mine" | omarchy-drive-password --system-stdin 2>&1); then
      printf '%s\n' "$output" >&2
      [[ $output != *"stopped part way"* ]] || return 2
      return 1
    fi
    [[ -z $output ]] || printf '%s\n' "$output"
    opens=$(user_accounts_try_disk_password "$disk" "$mine") || return 1
    if [[ $opens != "opens" ]]; then
      echo "Your password doesn't unlock the disk yet. Run omarchy-drive-password and use your own password as the new one." >&2
      return 1
    fi
    user_accounts_log "disk password set to $self's login password: the only account left"
  fi
  printf 'root:%s\n' "$mine" | as_root chpasswd || return 1
  user_accounts_log "root password set to $self's login password: the only account left"
  if [[ -n $disk ]]; then
    # Automatic login lets whoever unlocks the disk into this desktop, so it
    # comes back only when this password is the disk's one key, as the
    # installer leaves it. Another key, left by a password change that stopped
    # part way or added on purpose, keeps it off.
    keys=$(user_accounts_disk_key_count "$disk") || return 1
    if (( keys == 1 )); then
      user_accounts_autologin_on "$self" || return 1
      user_accounts_log "automatic login turned on for $self: the only account left"
      echo "Your password unlocks the disk and root again, and you'll be logged in automatically."
    else
      if as_root test -e "$(user_accounts_autologin_conf)"; then
        user_accounts_autologin_off || return 1
      fi
      user_accounts_log "automatic login left off for $self: the disk has $keys keys"
      echo "Your password unlocks the disk and root again. The disk also opens with another key, so you won't be logged in automatically: anyone who knows that key could start the computer into your desktop."
      echo "To have automatic login back, remove that key (or finish an interrupted change with omarchy-drive-password), then add and remove an account."
    fi
  else
    echo "Root has your password again."
  fi
}

# Whether a disk password change this account started has finished: until it
# has, omarchy-drive-password keeps its note at this path, and the disk's keys
# or their record may be half changed. The switches stop with status 2 (finish
# it first) rather than trust the disk's password while it's there, even where
# they'd have no new change to make.
user_accounts_own_change_finished() {
  [[ ! -e ${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/drive-password.state ]]
}

# How many keys the disk holds, read from its header the way luks_dump_slots
# in install/provisioning/luks-rekey.sh reads them. Fails when the header can't
# be read.
user_accounts_disk_key_count() {
  local dump
  dump=$(as_root cryptsetup luksDump "$1") || return 1
  awk '
    /^[^ \t]/ { keyslots = ($0 == "Keyslots:") }
    keyslots && /^ +[0-9]+: luks2/ { count++ }
    /^Key Slot [0-9]+: ENABLED/ { count++ }
    END { print count + 0 }' <<<"$dump"
}
