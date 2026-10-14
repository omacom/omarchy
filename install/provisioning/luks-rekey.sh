# Resumable re-key of the root LUKS volume from the staged install key to the
# owner's password. Sourcing performs no setup.
#
# Caller contract:
# - Set PROVISIONING_DIR (holds the staged luks-key), REKEY_STATE, LOG_FILE and
#   password. Secrets reach cryptsetup through key files and process
#   substitution, never argv, and the entry points turn tracing off.
# - Define luks_boot_layout, printing a fingerprint of the keyboard layout the
#   boot files ask for the disk password in (the same value while it is
#   unchanged, and never the layout's name).
# - Define log_step and say, plus the platform's boot-time unlock:
#   luks_auto_unlock_present succeeds while any boot-time copy of the staged
#   key or its unlock configuration remains; luks_auto_unlock_drop removes
#   them and rebuilds the boot files, restoring the unlock before it fails.
#   luks_record_slots <owner> records the kept slot wherever the platform's
#   boot checks look for it, and succeeds where nothing does.
#
# The journal (REKEY_STATE) records only the phase, slot numbers and the layout
# fingerprint, never key material. Phases advance staged → owner → boot → done, each written durably
# after its step, so an attempt interrupted anywhere resumes from the last one;
# the retire and record steps before done are idempotent. A retry may still
# choose a new password while the staged key opens the disk, even after the
# boot step, so the kept slot is recorded only once it is final. The
# caller removes the journal with the rest of its provisioning state, so until
# then a retry can only use the password the disk holds.

# cryptsetup open tries enrolled tokens (TPM2, FIDO2, keyring) before the key
# and reports a token's slot whatever key it was given. Restricting it to a
# token type no token has leaves only the key to decide.
luks_key_slot() {
  local out
  out=$(LC_ALL=C cryptsetup open --test-passphrase --verbose --token-type passphrase-only --key-file "$1" "$2" 2>&1) || return 0
  grep -o 'Key slot [0-9]* unlocked' <<<"$out" | grep -o '[0-9]*' | head -1 || true
}

luks_slot_for() {
  local -
  set +x
  luks_key_slot <(printf '%s' "$1") "$2"
}

# LUKS2 lists keyslots under "Keyslots:", and a luks2-keyring token under
# "Tokens:" looks the same, so read only the keyslot section.
luks_dump_slots() {
  cryptsetup luksDump "$1" | awk '
    /^[^ \t]/ { keyslots = ($0 == "Keyslots:") }
    keyslots && /^ +[0-9]+: luks2/ { sub(":", "", $1); print $1 }
    /^Key Slot [0-9]+: ENABLED/ { sub(":", "", $3); print $3 }'
}

rekey_state_get() {
  [[ -f $REKEY_STATE ]] || return 1
  awk -F= -v k="$1" '$1 == k { print $2; exit }' "$REKEY_STATE"
}

# Set key/value pairs, keeping every other recorded key.
rekey_state_put() {
  local line key tmp
  local -A updates=()
  local -a lines=()

  while (( $# >= 2 )); do
    updates[$1]=$2
    shift 2
  done

  if [[ -f $REKEY_STATE ]]; then
    while IFS= read -r line || [[ -n $line ]]; do
      if [[ -n $line && -z ${updates[${line%%=*}]+set} ]]; then
        lines+=("$line")
      fi
    done <"$REKEY_STATE"
  fi
  for key in "${!updates[@]}"; do
    lines+=("$key=${updates[$key]}")
  done

  tmp=$(mktemp "$REKEY_STATE.XXXXXX") || return 1
  if printf '%s\n' "${lines[@]}" >"$tmp" && chmod 600 "$tmp" && sync "$tmp" && mv -f "$tmp" "$REKEY_STATE"; then
    sync "$(dirname "$REKEY_STATE")"
    return
  fi
  rm -f "$tmp"
  return 1
}

staged_key_slot() {
  [[ -f $PROVISIONING_DIR/luks-key ]] || return 0
  luks_key_slot "$PROVISIONING_DIR/luks-key" "$1"
}

# The staged key or its boot-time auto-unlock is still on this machine.
luks_staged_unlock_remains() {
  [[ -e $PROVISIONING_DIR/luks-key ]] || luks_auto_unlock_present
}

# Re-key work is due while the staged unlock remains or the journal is open.
luks_rekey_pending() {
  [[ -e $REKEY_STATE ]] || luks_staged_unlock_remains
}

# Whether an interrupted re-key can finish with $password. Until the staged key
# is retired it can add any password; afterwards only one the disk holds.
luks_rekey_accepts_password() {
  local -
  set +x
  local device=$1

  [[ -f $REKEY_STATE ]] || return 0
  [[ -n $(luks_slot_for "$password" "$device") || -n $(staged_key_slot "$device") ]]
}

# Record the slot $password opens, adding it with the staged key when none does.
# A retry after a crash between the add and the journal write finds the slot
# instead of adding a duplicate, and a retry with a new password adds its own
# while the staged key still works; the retire step removes the stale one.
luks_rekey_owner() {
  local device=$1 phase=$2 owner

  owner=$(luks_slot_for "$password" "$device")
  if [[ -z $owner ]]; then
    if [[ -z $(staged_key_slot "$device") ]]; then
      log_step "the password opens no LUKS slot and the staged key no longer unlocks $device"
      say --foreground 1 "Use the disk password chosen earlier in setup."
      return 1
    fi
    if ! cryptsetup luksAddKey --key-file "$PROVISIONING_DIR/luks-key" "$device" <(printf '%s' "$password"); then
      log_step "could not add the owner's key to $device"
      say --foreground 1 "Could not add your password to the disk; will retry."
      return 1
    fi
    owner=$(luks_slot_for "$password" "$device")
    if [[ -z $owner ]]; then
      log_step "could not identify the owner's LUKS slot after adding it"
      say --foreground 1 "Could not confirm the LUKS re-key; will retry."
      return 1
    fi
  fi

  if [[ $owner == "$(rekey_state_get staged_slot || true)" ]]; then
    log_step "the owner's password is the staged install key; refusing to keep it"
    say --foreground 1 "Choose a disk password different from the temporary install key."
    return 1
  fi

  if [[ $phase == "staged" ]]; then
    rekey_state_put owner_slot "$owner" phase owner
  else
    rekey_state_put owner_slot "$owner"
  fi
}

luks_rekey_retire() {
  local device=$1 owner slot slots

  owner=$(rekey_state_get owner_slot || true)
  if [[ -z $owner ]]; then
    log_step "no owner slot is recorded; refusing to retire LUKS slots"
    return 1
  fi

  if ! slots=$(luks_dump_slots "$device"); then
    log_step "luksDump failed while retiring slots; keeping the staged key for retry"
    say --foreground 1 "Could not enumerate LUKS slots; will retry."
    return 1
  fi
  for slot in $slots; do
    [[ $slot == "$owner" ]] && continue
    if ! cryptsetup luksKillSlot -q --key-file <(printf '%s' "$password") "$device" "$slot"; then
      log_step "failed to kill LUKS slot $slot; keeping the staged key for retry"
      say --foreground 1 "Could not remove the throwaway LUKS key; will retry."
      return 1
    fi
  done
}

# The staged key must open nothing before it is destroyed: only the owner slot
# remains and no boot-time copy or unlock configuration is left behind.
luks_rekey_verify() {
  local device=$1 owner slots

  owner=$(rekey_state_get owner_slot || true)
  if ! slots=$(luks_dump_slots "$device") || [[ -z $owner || $slots != "$owner" ]]; then
    log_step "LUKS slots other than the owner's remain on $device"
    return 1
  fi
  if [[ -n $(staged_key_slot "$device") ]]; then
    log_step "the staged LUKS key still unlocks $device"
    return 1
  fi
  if luks_auto_unlock_present; then
    log_step "the boot-time auto-unlock is still configured"
    return 1
  fi
}

# The boot files carry the console keyboard layout the disk password is typed
# in at boot, so rebuild them again when the owner chose another layout since
# they were built, or when an older journal recorded none. The phase stays.
luks_rekey_boot_layout() {
  local layout=$1

  [[ $(rekey_state_get boot_layout || true) != "$layout" ]] || return 0
  log_step "the boot files were not built with the current keyboard layout; rebuilding them"
  if ! luks_auto_unlock_drop; then
    say --foreground 1 "Could not rebuild the boot files for your keyboard layout; will retry."
    return 1
  fi
  sync
  rekey_state_put boot_layout "$layout"
}

# Order: record the staged slot, add the owner's key, rebuild boot without the
# auto-unlock (keeping the staged slot as the fallback while that can fail),
# retire every other slot, then verify, record the kept slot for the platform,
# destroy the staged key and record done.
# Failing is loud: silently keeping the staged key would leave the disk
# effectively unencrypted.
luks_rekey() {
  local -
  set +x
  local device=$1 phase staged layout

  if ! layout=$(luks_boot_layout) || [[ -z $layout ]]; then
    log_step "could not fingerprint the keyboard layout for the boot files"
    say --foreground 1 "Could not read the keyboard layout for the boot files; will retry."
    return 1
  fi

  phase=$(rekey_state_get phase || true)
  case $phase in
    "")
      staged=$(staged_key_slot "$device")
      if [[ -z $staged ]]; then
        log_step "the staged LUKS key is missing or does not unlock $device"
        say --foreground 1 "The staged LUKS key no longer unlocks $device."
        return 1
      fi
      rekey_state_put staged_slot "$staged" phase staged || return 1
      phase=staged
      ;;
    staged | owner | boot | done) ;;
    *)
      log_step "unknown LUKS re-key phase '$phase' in $REKEY_STATE"
      say --foreground 1 "The LUKS re-key journal is unreadable."
      return 1
      ;;
  esac

  if [[ $phase != "done" ]]; then
    luks_rekey_owner "$device" "$phase" || return 1
    [[ $phase == "staged" ]] && phase=owner

    if [[ $phase == "owner" ]] || luks_auto_unlock_present; then
      if ! luks_auto_unlock_drop; then
        say --foreground 1 "Could not rebuild the boot files without the install key; will retry."
        return 1
      fi
      sync
      rekey_state_put phase boot boot_layout "$layout" || return 1
    else
      luks_rekey_boot_layout "$layout" || return 1
    fi

    luks_rekey_retire "$device" || return 1
  else
    if [[ $(luks_slot_for "$password" "$device") != "$(rekey_state_get owner_slot || true)" ]]; then
      log_step "the password does not open the owner slot the finished re-key recorded on $device"
      say --foreground 1 "Use the disk password chosen earlier in setup."
      return 1
    fi
    luks_rekey_boot_layout "$layout" || return 1
  fi

  if ! luks_rekey_verify "$device"; then
    say --foreground 1 "Could not confirm the temporary install key was removed; will retry."
    return 1
  fi
  if ! luks_record_slots "$(rekey_state_get owner_slot)"; then
    log_step "the platform could not record the kept LUKS slot"
    say --foreground 1 "Could not record the disk's key slot for the boot checks; will retry."
    return 1
  fi

  if [[ -e $PROVISIONING_DIR/luks-key ]]; then
    shred -u "$PROVISIONING_DIR/luks-key" 2>/dev/null || rm -f "$PROVISIONING_DIR/luks-key" || return 1
  fi
  rm -f "$REKEY_STATE".??????
  [[ $phase == "done" ]] || rekey_state_put phase done
}
