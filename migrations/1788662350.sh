echo "Repair user-owned system-sleep hooks and hybrid GPU service configuration"

system_sleep_dir=/usr/lib/systemd/system-sleep
supergfxd_drop_in=/etc/systemd/system/supergfxd.service.d/delay-start.conf
quarantine_root=/var/lib/omarchy/migrations/1788662350-system-sleep
reload_needed_marker=/var/lib/omarchy/migrations/1788662350-systemd-reload-needed
keyboard_source="$OMARCHY_PATH/default/systemd/system-sleep/keyboard-backlight"
force_igpu_source="$OMARCHY_PATH/default/systemd/system-sleep/force-igpu"
supergfxd_source="$OMARCHY_PATH/default/systemd/system/supergfxd.service.d/delay-start.conf"
legacy_keyboard_sha256=f313a81e47401f0d38b8602e5997f52c5286d5e97f74027564ddd515b3d16511
legacy_force_igpu_sha256=d604e7c4903829563e45fc52188fc5602c3f1bc66e247f0a2cc0a974ed6e57db

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

path_is_root_controlled() {
  local path="$1"
  local current=/ component candidate file_mode link metadata part status uid gid mode
  local missing_depth=0 symlink_count=0
  local -a pending resolved link_components

  [[ $path == /* ]] || return 1
  IFS=/ read -r -a pending <<<"$path"
  # A non-root group is harmless when neither it nor everyone else can write.
  # Resolve symlinks component by component so an indirect link cannot hide an
  # intermediate directory controlled by an unprivileged user.
  metadata=$(path_metadata /) || return 1
  read -r file_mode uid gid mode <<<"$metadata"
  (( uid == 0 && (8#$mode & 8#022) == 0 )) || return 1

  while ((${#pending[@]})); do
    component=${pending[0]}
    pending=("${pending[@]:1}")
    [[ -n $component ]] || continue
    [[ $component == "." ]] && continue

    if [[ $component == ".." ]]; then
      if ((${#resolved[@]})); then
        unset 'resolved[-1]'
      fi

      current=/
      for part in "${resolved[@]}"; do
        if [[ $current == "/" ]]; then
          current="/$part"
        else
          current="$current/$part"
        fi
      done
      if (( missing_depth > 0 && ${#resolved[@]} < missing_depth )); then
        missing_depth=0
      fi
      continue
    fi

    if [[ $current == "/" ]]; then
      candidate="/$component"
    else
      candidate="$current/$component"
    fi

    if (( missing_depth > 0 )); then
      # The first missing component makes descendants inactive today, but keep
      # consuming the lexical suffix. A later .. can escape back into an
      # existing user-controlled path that would become active if an
      # administrator creates the missing directory.
      resolved+=("$component")
      current=$candidate
      continue
    elif metadata=$(path_metadata "$candidate"); then
      read -r file_mode uid gid mode <<<"$metadata"
    else
      status=$?
      if (( status == 2 )); then
        resolved+=("$component")
        current=$candidate
        missing_depth=${#resolved[@]}
        continue
      else
        return 1
      fi
    fi
    if (( (16#$file_mode & 16#f000) == 16#a000 )); then
      ((++symlink_count <= 40)) || return 1
      link=$(readlink_with_privilege "$candidate") || return 1
      IFS=/ read -r -a link_components <<<"$link"
      pending=("${link_components[@]}" "${pending[@]}")
      if [[ $link == /* ]]; then
        resolved=()
        current=/
      fi
      continue
    fi

    (( uid == 0 && (8#$mode & 8#022) == 0 )) || return 1
    resolved+=("$component")
    current=$candidate
  done
}

path_metadata() {
  local path="$1"
  local metadata parent

  if /usr/bin/stat -c '%f %u %g %a' -- "$path" 2>/dev/null; then
    return 0
  elif [[ ! -e $path && ! -L $path ]]; then
    parent=${path%/*}
    [[ -n $parent ]] || parent=/
    # Avoid asking for sudo for ordinary ENOENT. If the parent is searchable,
    # the absence is conclusive; an inaccessible root-only chain still needs a
    # privileged metadata check so safe administrator symlinks are preserved.
    [[ -x $parent ]] && return 2
    if metadata=$(as_root /usr/bin/stat -c '%f %u %g %a' -- "$path" 2>/dev/null); then
      printf '%s\n' "$metadata"
      return 0
    elif as_root /usr/bin/test -x "$parent"; then
      # The privileged probe could search the protected parent, so stat's
      # failure identifies a target that does not exist yet.
      return 2
    else
      return 1
    fi
  else
    as_root /usr/bin/stat -c '%f %u %g %a' -- "$path"
  fi
}

readlink_with_privilege() {
  local path="$1"

  if /usr/bin/readlink -- "$path" 2>/dev/null; then
    return 0
  else
    as_root /usr/bin/readlink -- "$path"
  fi
}

privileged_entry_is_safe() {
  local path="$1"

  path_is_root_controlled "$path"
}

file_matches_source() {
  local source="$1"
  local destination="$2"

  [[ -f $destination && ! -L $destination ]] || return 1

  if [[ -r $destination ]]; then
    /usr/bin/cmp -s -- "$source" "$destination"
  else
    as_root /usr/bin/cmp -s -- "$source" "$destination"
  fi
}

file_matches_sha256() {
  local destination="$1"
  local expected="$2"
  local digest

  [[ -f $destination && ! -L $destination ]] || return 1
  if [[ -r $destination ]]; then
    digest=$(/usr/bin/sha256sum -- "$destination") || return 1
  else
    digest=$(as_root /usr/bin/sha256sum -- "$destination") || return 1
  fi
  [[ ${digest%% *} == "$expected" ]]
}

safe_stage_path() {
  local stage="$1"
  local destination="$2"
  local prefix suffix

  prefix="${destination%/*}/.${destination##*/}.omarchy."
  [[ $stage == "$prefix"* ]] || return 1
  suffix=${stage#"$prefix"}
  [[ $suffix =~ ^[[:alnum:]]{6}$ ]]
}

install_root_file() {
  local source="$1"
  local destination="$2"
  local mode="$3"
  local stage

  stage=$(as_root /usr/bin/mktemp -- "${destination%/*}/.${destination##*/}.omarchy.XXXXXX") || return 1
  safe_stage_path "$stage" "$destination" || return 1

  if as_root /usr/bin/install -m "$mode" -o root -g root -T "$source" "$stage" &&
    as_root /usr/bin/mv -Tf -- "$stage" "$destination"; then
    return 0
  else
    safe_stage_path "$stage" "$destination" && as_root /usr/bin/rm -f -- "$stage"
    return 1
  fi
}

preserve_unsafe_customization() {
  local path="$1"
  local label="$2"
  local backup_dir backup

  if ! as_root /usr/bin/install -d -m 0700 -o root -g root "$quarantine_root"; then
    echo "Could not create the root-only system-sleep quarantine at $quarantine_root" >&2
    return 1
  fi
  if ! backup_dir=$(as_root /usr/bin/mktemp -d -- "$quarantine_root/${label}.XXXXXX"); then
    echo "Could not reserve a quarantine path for $path" >&2
    return 1
  fi
  backup="$backup_dir/original"

  if as_root /usr/bin/cp -a --no-dereference -T -- "$path" "$backup"; then
    printf '%s\n' "$backup"
  else
    as_root /usr/bin/rm -rf -- "$backup_dir"
    echo "Could not preserve unsafe custom content from $path before repairing it" >&2
    return 1
  fi
}

repair_unsafe_privileged_entry() {
  local source="$1"
  local destination="$2"
  local mode="$3"
  local label="$4"
  local legacy_sha256="${5:-}"
  local backup current_mode

  [[ -e $destination || -L $destination ]] || return 0
  [[ -f $destination || -L $destination ]] || return 0

  if file_matches_source "$source" "$destination"; then
    current_mode=$(/usr/bin/stat -c '%a' -- "$destination" 2>/dev/null) ||
      current_mode=$(as_root /usr/bin/stat -c '%a' -- "$destination") || return 1
    if privileged_entry_is_safe "$destination" && [[ $current_mode == "${mode#0}" ]]; then
      return 0
    fi
  elif [[ -n $legacy_sha256 ]] && file_matches_sha256 "$destination" "$legacy_sha256"; then
    :
  else
    privileged_entry_is_safe "$destination" && return 0
    backup=$(preserve_unsafe_customization "$destination" "$label") || return 1
  fi

  if install_root_file "$source" "$destination" "$mode"; then
    if [[ -n ${backup:-} ]]; then
      echo "Preserved unsafe custom content from $destination at $backup for administrator review" >&2
    fi
  else
    if [[ -n ${backup:-} ]]; then
      echo "Preserved unsafe custom content from $destination at $backup, but could not repair the active path" >&2
    fi
    return 1
  fi
}

# Replace rather than chown an unsafe destination: its current owner may have
# already changed the contents or kept a writable file descriptor open. The
# root-owned staging inode makes the final rename an atomic trust transition.
repair_unsafe_privileged_entry "$keyboard_source" \
  "$system_sleep_dir/keyboard-backlight" 0755 keyboard-backlight "$legacy_keyboard_sha256"

force_igpu="$system_sleep_dir/force-igpu"
repair_unsafe_privileged_entry "$force_igpu_source" "$force_igpu" 0755 force-igpu "$legacy_force_igpu_sha256"

systemd_reload_needed=false
if [[ -e $reload_needed_marker || -L $reload_needed_marker ]]; then
  systemd_reload_needed=true
fi

if [[ -e $supergfxd_drop_in || -L $supergfxd_drop_in ]]; then
  if ! privileged_entry_is_safe "$supergfxd_drop_in"; then
    # Replacing the drop-in and reloading systemd are one repair. Record the
    # second half before changing the file so failure or interruption cannot
    # be forgotten when a retry sees only the trusted replacement on disk.
    if ! as_root /usr/bin/install -Dm0644 -o root -g root /dev/null "$reload_needed_marker"; then
      echo "Could not persist the pending systemd reload for the repaired supergfxd configuration" >&2
      exit 1
    fi
    systemd_reload_needed=true
    repair_unsafe_privileged_entry "$supergfxd_source" "$supergfxd_drop_in" 0644 delay-start.conf
  fi
fi

if $systemd_reload_needed; then
  if ! as_root /usr/bin/systemctl daemon-reload; then
    echo "Could not reload systemd after repairing the supergfxd configuration; the migration will retry" >&2
    exit 1
  fi
  if ! as_root /usr/bin/rm -f -- "$reload_needed_marker"; then
    echo "Could not clear the pending systemd reload marker; the migration will retry" >&2
    exit 1
  fi
fi
