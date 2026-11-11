# Home on another drive: finding an existing home on the machine's other disks,
# the rules for which homes may be adopted and which disks may be erased for a
# fresh one, and (further down) mounting, merging and erasing. Sourced by the
# two places that ask where home lives — the ISO configurator's Home step and
# first-boot owner setup (omarchy-provision-owner) — by the ISO orchestrator,
# which checks the choice again before it writes anything, and by factory
# reset, so the rules cannot drift between them the way a copied list would.
#
# home_drive_scan prints one tab-separated row per finding:
#
#   status kind device fstype uuid luks_uuid subvol uid gid used_bytes disk removable others reason dir
#
#   status   adoptable | refused | locked | erasable
#   kind     home (a folder named for the user) | disk (a whole disk to erase)
#   others   comma-separated names of the other homes beside it
#   reason   why a row is refused or locked (home_drive_check's codes,
#            not-a-directory, duplicate-uuid, wrong-passphrase), empty
#            otherwise
#   dir      where the user's folder is inside the filesystem (or subvolume):
#            empty at its top, "home" at home/<user> of another system's root
#            (Ubuntu's single root partition, a btrfs @ without @home)
#
# Scanning only reads: every filesystem is mounted read-only and unmounted
# again, and nothing is left mounted or open when it returns, or when it is
# interrupted (home_drive_scan_cleanup). The commands it
# runs go through the _hd_* functions below so tests can describe a machine
# without root.

HOME_DRIVE_FILESYSTEMS=" ext2 ext3 ext4 xfs btrfs f2fs "

_hd_lsblk() {
  lsblk -bpPo NAME,TYPE,SIZE,RM,TRAN,FSTYPE,UUID,PKNAME,RO,HOTPLUG
}

# Mount read-only without replaying a journal: the scan must not write to a
# filesystem it is only looking at.
_hd_mount_ro() {
  local device=$1 dir=$2 fstype=$3 subvol=${4:-} options=ro
  case $fstype in
    xfs | f2fs) options+=,norecovery ;;
    ext3 | ext4) options+=,noload ;;
    btrfs) options+=,rescue=nologreplay ;;
  esac
  if [[ -n $subvol ]]; then
    options+=,subvol=$subvol
  elif [[ $fstype == "btrfs" ]]; then
    # The top level, so every subvolume is visible beneath it.
    options+=,subvolid=5
  fi
  mount -t "$fstype" -o "$options" "$device" "$dir" 2>/dev/null
}

_hd_umount() {
  umount "$1"
}

_hd_is_mounted() {
  mountpoint -q "$1" 2>/dev/null
}

# Every device-mapper name on the machine.
_hd_dm_names() {
  local path
  for path in /dev/mapper/*; do
    [[ -e $path && ${path##*/} != "control" ]] && printf '%s\n' "${path##*/}"
  done
  return 0
}

# "uid gid" for a directory, "notdir" for anything else in its place, "missing"
# when nothing is there. A symlink is never a home: following it would adopt
# whatever it points at.
_hd_owner() {
  local path=$1
  if [[ -L $path ]]; then
    echo notdir
  elif [[ -d $path ]]; then
    stat -c '%u %g' "$path"
  elif [[ -e $path ]]; then
    echo notdir
  else
    echo missing
  fi
}

_hd_used() {
  df --output=used -B1 "$1" 2>/dev/null | tail -n1 | tr -d ' ' || true
}

# findmnt -r writes a space or a tab in a path as \x20 or \x09; the scan
# needs the path itself.
_hd_unescape() {
  local path
  printf -v path '%b' "$1"
  printf '%s' "$path"
}

# Where a device is already mounted, if anywhere (the live system may have it).
_hd_mountpoint() {
  _hd_unescape "$(findmnt -nro TARGET -S "$1" 2>/dev/null | head -n1 || true)"
}

# "fstype uuid" of a device the scan opened itself (a LUKS mapping, an LV).
_hd_probe() {
  local fstype uuid
  fstype=$(blkid -o value -s TYPE "$1" 2>/dev/null) || true
  uuid=$(blkid -o value -s UUID "$1" 2>/dev/null) || true
  printf '%s %s' "$fstype" "$uuid"
}

_hd_btrfs_subvols() {
  btrfs subvolume list "$1" 2>/dev/null | awk '{ print $NF }' || true
}

_hd_luks_open() {
  local device=$1 name=$2 password=$3
  [[ -n $password ]] || return 1
  printf '%s' "$password" | cryptsetup open --readonly --key-file=- "$device" "$name" 2>/dev/null
}

# Whether a passphrase opens a LUKS volume, without opening it.
_hd_luks_test() {
  [[ -n $2 ]] || return 1
  printf '%s' "$2" | cryptsetup open --test-passphrase --key-file=- "$1" 2>/dev/null
}

# home_drive_luks_passphrase <device> <passphrases>
#
# The first of the newline-separated passphrases that opens the LUKS volume.
home_drive_luks_passphrase() {
  local device=$1 password
  while IFS= read -r password; do
    if _hd_luks_test "$device" "$password"; then
      printf '%s' "$password"
      return 0
    fi
  done <<<"$2"
  return 1
}

# Where a mounted filesystem's mount begins inside it (a btrfs subvolume).
_hd_mount_fsroot() {
  _hd_unescape "$(findmnt -nro FSROOT -S "$1" 2>/dev/null | head -n1 || true)"
}

_hd_luks_close() {
  cryptsetup close "$1"
}

# The mapping of a LUKS volume something already opened, if any (a retry after
# a failed install or first boot leaves it open).
_hd_luks_mapped() {
  lsblk -nrpo NAME,TYPE "$1" 2>/dev/null | awk '$2 == "crypt" { print $1; exit }' || true
}

# Home subvolumes by the distribution that lays them out that way: Omarchy and
# Arch (@home), Fedora (home), openSUSE (@/home).
HOME_DRIVE_SUBVOLUMES=" @home home @/home "

# One KEY="value" field from a line of lsblk -P output.
_hd_field() {
  local line=$1 key=$2
  if [[ $line =~ (^|[[:space:]])$key=\"([^\"]*)\" ]]; then
    printf '%s' "${BASH_REMATCH[2]}"
  fi
}

_hd_internal_disk_name() {
  [[ $1 =~ ^/dev/(sd|hd|vd|nvme|mmcblk|xv) ]]
}

# Whether uid/gid may own an adopted home on a system whose accounts are in
# passwd_file and group_file. Prints the reason and returns 1 when not. Without
# account files (the live ISO, before the image is written) only the static
# rules apply: a regular uid, and a regular gid or the shared users group.
home_drive_check() {
  local uid=$1 gid=$2 passwd_file=${3:-} group_file=${4:-}

  if ((uid < 1000)); then
    echo uid-below-1000
    return 1
  fi
  if ((gid < 1000 && gid != 100)); then
    echo gid-taken
    return 1
  fi
  if [[ -n $passwd_file && -r $passwd_file ]] && awk -F: -v uid="$uid" '$3 == uid { found = 1 } END { exit !found }' "$passwd_file"; then
    echo uid-taken
    return 1
  fi
  if ((gid != 100)) && [[ -n $group_file && -r $group_file ]] && awk -F: -v gid="$gid" '$3 == gid { found = 1 } END { exit !found }' "$group_file"; then
    echo gid-taken
    return 1
  fi
  return 0
}

_hd_row() {
  local IFS=$'\t'
  printf '%s\n' "$*"
}

# Other homes beside the user's: top-level folders owned by a regular uid.
# Only names an account could have: the rows are tab- and newline-separated,
# so any other folder name could forge a row of its own.
_hd_others() {
  local root=$1 username=$2 path name owner others=()
  for path in "$root"/*; do
    [[ -d $path ]] || continue
    name=${path##*/}
    [[ $name =~ ^[a-z_][a-z0-9_-]*[$]?$ ]] || continue
    [[ $name == "$username" ]] && continue
    owner=$(_hd_owner "$path")
    [[ $owner == notdir || $owner == missing ]] && continue
    ((${owner%% *} >= 1000)) && others+=("$name")
  done
  local IFS=,
  printf '%s' "${others[*]}"
}

# Look for <username>/ at the top of a mounted filesystem, or in its <dir>
# folder, and print its row.
_hd_scan_mounted() {
  local root=$1 username=$2 device=$3 fstype=$4 uuid=$5 luks_uuid=$6 subvol=$7 disk=$8 removable=$9 dir=${10:-}
  local owner uid gid reason status used others parent=$1

  if [[ -n $dir ]]; then
    parent=$root/$dir
    # A link in place of the folder would be followed out of the filesystem
    # being scanned (to the live system's own /home).
    [[ -d $parent && ! -L $parent ]] || return 0
  fi
  owner=$(_hd_owner "$parent/$username")
  [[ $owner == missing ]] && return 0
  # Inside another system, only a real folder is a home: anything else at
  # home/<user> is that system's business, not a home that was meant here.
  [[ -n $dir && $owner == notdir ]] && return 0

  used=$(_hd_used "$root")
  others=$(_hd_others "$parent" "$username")

  if [[ $owner == notdir ]]; then
    _hd_row refused home "$device" "$fstype" "$uuid" "$luks_uuid" "$subvol" "" "" "$used" "$disk" "$removable" "$others" not-a-directory "$dir"
    return 0
  fi

  uid=${owner%% *}
  gid=${owner##* }
  if reason=$(home_drive_check "$uid" "$gid" "${HOME_DRIVE_PASSWD:-}" "${HOME_DRIVE_GROUP:-}"); then
    status=adoptable
  else
    status=refused
  fi
  _hd_row "$status" home "$device" "$fstype" "$uuid" "$luks_uuid" "$subvol" "$uid" "$gid" "$used" "$disk" "$removable" "$others" "$reason" "$dir"
}

# Look for the home at the top of a mounted filesystem and, on btrfs, inside
# each home subvolume (visible as directories from the top-level mount). Only
# when neither has it, look for home/<user> as another system's root keeps it:
# at the top, and in each btrfs subvolume at the top level (@, root) that is
# not a home subvolume. Nested subvolumes are left out: they are snapshots
# (snapper's @/.snapshots/N/snapshot), whose copy of the home is not the home.
_hd_scan_root() {
  local root=$1 device=$2 fstype=$3 uuid=$4 luks_uuid=$5 disk=$6 removable=$7 username=$8
  local subvol subvols="" rows

  [[ $fstype == "btrfs" ]] && subvols=$(_hd_btrfs_subvols "$root")
  rows=$(
    _hd_scan_mounted "$root" "$username" "$device" "$fstype" "$uuid" "$luks_uuid" "" "$disk" "$removable"
    while IFS= read -r subvol; do
      [[ -n $subvol && $HOME_DRIVE_SUBVOLUMES == *" $subvol "* ]] || continue
      _hd_scan_mounted "$root/$subvol" "$username" "$device" "$fstype" "$uuid" "$luks_uuid" "$subvol" "$disk" "$removable"
    done <<<"$subvols"
  )
  if [[ -n $rows ]]; then
    printf '%s\n' "$rows"
    return 0
  fi

  _hd_scan_mounted "$root" "$username" "$device" "$fstype" "$uuid" "$luks_uuid" "" "$disk" "$removable" home
  while IFS= read -r subvol; do
    _hd_system_subvolume "$subvol" || continue
    _hd_scan_mounted "$root/$subvol" "$username" "$device" "$fstype" "$uuid" "$luks_uuid" "$subvol" "$disk" "$removable" home
  done <<<"$subvols"
}

# Whether a btrfs subvolume may be another system's root: one at the top
# level that is not a home subvolume.
_hd_system_subvolume() {
  [[ -n $1 && $1 != */* && $HOME_DRIVE_SUBVOLUMES != *" $1 "* ]]
}

# Read one filesystem where it is already mounted, or mount it read-only under
# the scan directory, look, and unmount. One that will not mount is skipped.
_hd_scan_filesystem() {
  local device=$1 fstype=$2 uuid=$3 luks_uuid=$4 disk=$5 removable=$6 username=$7
  local dir mountpoint subvol fsroot rows

  mountpoint=$(_hd_mountpoint "$device")
  if [[ -n $mountpoint && $fstype != "btrfs" ]]; then
    # Mounted only as a bind of one of its folders: what shows there is that
    # folder, not the top of the filesystem, so it is mounted afresh below.
    fsroot=$(_hd_mount_fsroot "$device")
    [[ -z $fsroot || $fsroot == "/" ]] || mountpoint=""
  fi
  if [[ -n $mountpoint ]]; then
    if [[ $fstype == "btrfs" ]]; then
      # Mounted at some subvolume: read it as that subvolume, since the others
      # are not reachable from there.
      subvol=$(_hd_mount_fsroot "$device")
      subvol=${subvol#/}
      if [[ -z $subvol ]]; then
        # The top level: the home subvolumes are reachable beneath it.
        _hd_scan_root "$mountpoint" "$device" "$fstype" "$uuid" "$luks_uuid" "$disk" "$removable" "$username"
      else
        rows=$(_hd_scan_mounted "$mountpoint" "$username" "$device" "$fstype" "$uuid" "$luks_uuid" "$subvol" "$disk" "$removable")
        if [[ -z $rows ]] && _hd_system_subvolume "$subvol"; then
          rows=$(_hd_scan_mounted "$mountpoint" "$username" "$device" "$fstype" "$uuid" "$luks_uuid" "$subvol" "$disk" "$removable" home)
        fi
        [[ -z $rows ]] || printf '%s\n' "$rows"
      fi
    else
      _hd_scan_root "$mountpoint" "$device" "$fstype" "$uuid" "$luks_uuid" "$disk" "$removable" "$username"
    fi
    return 0
  fi

  dir=$(mktemp -d "$HOME_DRIVE_SCAN_DIR/fs.XXXXXX")
  if _hd_mount_ro "$device" "$dir" "$fstype"; then
    _hd_scan_root "$dir" "$device" "$fstype" "$uuid" "$luks_uuid" "$disk" "$removable" "$username"
    # Left for home_drive_scan_cleanup to try again at the end of the scan.
    if ! _hd_umount "$dir"; then
      echo "home drive scan: could not unmount $dir; trying again after the scan" >&2
    fi
  fi
  rmdir "$dir" 2>/dev/null || true
}

# One block device by what it holds: a filesystem is scanned, a LUKS volume is
# opened with the password (and offered as locked when it will not open), and
# an LVM physical volume is skipped for now.
_hd_scan_device() {
  local device=$1 fstype=$2 uuid=$3 luks_uuid=$4 disk=$5 removable=$6 username=$7 password=$8
  local name probe pw opened=false

  # A drive to leave alone (the last factory reset kept it) is not even opened.
  if [[ -n $uuid && " ${HOME_DRIVE_IGNORE:-} " == *" $uuid "* ]]; then
    return 0
  fi

  case $fstype in
    crypto_LUKS)
      [[ -z $luks_uuid ]] || return 0
      name=$(_hd_luks_mapped "$device")
      if [[ -n $name ]]; then
        probe=$(_hd_probe "$name")
        _hd_scan_device "$name" "${probe%% *}" "${probe#* }" "$uuid" "$disk" "$removable" "$username" "$password" |
          sed "s|\t$name\t|\t$device\t|"
        return 0
      fi
      HOME_DRIVE_LUKS_COUNT=$((${HOME_DRIVE_LUKS_COUNT:-0} + 1))
      name=omarchy-home-scan-$HOME_DRIVE_LUKS_COUNT
      while IFS= read -r pw; do
        if _hd_luks_open "$device" "$name" "$pw"; then
          opened=true
          break
        fi
      done <<<"$password"
      if [[ $opened == "true" ]]; then
        probe=$(_hd_probe "/dev/mapper/$name")
        _hd_scan_device "/dev/mapper/$name" "${probe%% *}" "${probe#* }" "$uuid" "$disk" "$removable" "$username" "$password" |
          sed "s|\t/dev/mapper/$name\t|\t$device\t|"
        if ! _hd_luks_close "$name"; then
          echo "home drive scan: could not close $name; trying again after the scan" >&2
        fi
      else
        _hd_row locked home "$device" crypto_LUKS "" "$uuid" "" "" "" "" "$disk" "$removable" "" wrong-passphrase ""
      fi
      ;;
    LVM2_member)
      # Not offered yet: activating a volume group read-only for the scan, and
      # at boot on the installed system, is not verified.
      return 0
      ;;
    *)
      [[ $HOME_DRIVE_FILESYSTEMS == *" $fstype "* ]] || return 0
      _hd_scan_filesystem "$device" "$fstype" "$uuid" "$luks_uuid" "$disk" "$removable" "$username"
      ;;
  esac
}

# A home whose uuid (or LUKS uuid) more than one device has, a cloned disk
# say, is refused: fstab and crypttab name it by that uuid and could get
# either. Devices come from lsblk ("device<TAB>uuid" lines in HD_PAIRS) and
# from the rows themselves, for the filesystems inside LUKS.
_hd_mark_duplicates() {
  awk -F'\t' -v OFS='\t' '
    function add(uuid, device) {
      if (uuid == "" || (uuid SUBSEP device) in seen) return
      seen[uuid SUBSEP device] = 1
      count[uuid]++
    }
    BEGIN {
      n = split(ENVIRON["HD_PAIRS"], pairs, "\n")
      for (i = 1; i <= n; i++) if (split(pairs[i], pair, "\t") == 2) add(pair[2], pair[1])
    }
    { rows[NR] = $0; add($5, $3); add($6, $3) }
    END {
      for (i = 1; i <= NR; i++) {
        $0 = rows[i]
        if ($2 == "home" && (count[$5] > 1 || count[$6] > 1)) { $1 = "refused"; $14 = "duplicate-uuid" }
        print
      }
    }'
}

# home_drive_scan_cleanup
#
# Unmount whatever a scan left mounted under the scan directory and close the
# LUKS mappings it left open, for a scan that was interrupted or could not
# unmount. Only the scan's own omarchy-home-scan-* mappings are touched. Safe
# to call at any time; home_drive_scan calls it before and after it looks.
home_drive_scan_cleanup() {
  local dir=${HOME_DRIVE_SCAN_DIR:-/run/omarchy-home-scan} path name
  for path in "$dir"/fs.*; do
    [[ -e $path || -L $path ]] || continue
    if _hd_is_mounted "$path" && ! _hd_umount "$path"; then
      echo "home drive scan: could not unmount $path" >&2
    fi
    rmdir "$path" 2>/dev/null || true
  done
  # After the unmounts: a mapping cannot close while its filesystem is mounted.
  while IFS= read -r name; do
    [[ $name == omarchy-home-scan-* ]] || continue
    _hd_luks_close "$name" 2>/dev/null || echo "home drive scan: could not close $name" >&2
  done < <(_hd_dm_names)
  return 0
}

# Ctrl+C or a kill during a scan: clean up, give the caller its own traps back,
# and let the signal do what it would have done.
_hd_scan_interrupted() {
  local signal=$1 saved=$2
  home_drive_scan_cleanup
  rmdir "${HOME_DRIVE_SCAN_DIR:-/run/omarchy-home-scan}" 2>/dev/null || true
  trap - INT TERM
  [[ -z $saved ]] || eval "$saved"
  kill -s "$signal" "$BASHPID"
}

# home_drive_scan <username> <password> <exclude_disk>...
#
# Rows for every adoptable or refused home named <username> on the machine's
# disks, and an erasable row for every internal disk, except the excluded ones
# (the install target and the boot medium). <password> is tried on encrypted
# partitions. Removable disks are only ever offered for a home found on them.
home_drive_scan() {
  local username=$1 password=$2
  shift 2
  local -a excluded=("$@")
  local line name type size rm tran ro hotplug fstype uuid pkname disk removable
  local -A disk_removable=()
  local -a disks=() parts=()
  local pairs="" rows _hd_saved_traps

  HOME_DRIVE_SCAN_DIR=${HOME_DRIVE_SCAN_DIR:-/run/omarchy-home-scan}
  HOME_DRIVE_LUKS_COUNT=0
  mkdir -p "$HOME_DRIVE_SCAN_DIR"
  # A scan that was interrupted may have left mounts and mappings behind, and
  # a leftover mapping would take the name this scan opens a drive under.
  home_drive_scan_cleanup
  _hd_saved_traps=$(trap -p INT TERM)
  trap '_hd_scan_interrupted INT "$_hd_saved_traps"' INT
  trap '_hd_scan_interrupted TERM "$_hd_saved_traps"' TERM

  while IFS= read -r line; do
    [[ -n $line ]] || continue
    name=$(_hd_field "$line" NAME)
    type=$(_hd_field "$line" TYPE)
    size=$(_hd_field "$line" SIZE)
    rm=$(_hd_field "$line" RM)
    tran=$(_hd_field "$line" TRAN)
    ro=$(_hd_field "$line" RO)
    hotplug=$(_hd_field "$line" HOTPLUG)
    uuid=$(_hd_field "$line" UUID)
    if [[ -n $uuid && ( $type == "part" || $type == "disk" ) ]]; then
      pairs+=$name$'\t'$uuid$'\n'
    fi
    if [[ $type == "disk" ]]; then
      _hd_internal_disk_name "$name" || continue
      ((${size:-0} > 0)) || continue
      [[ " ${excluded[*]} " == *" $name "* ]] && continue
      # Nothing can be written to a read-only disk, and an eMMC's boot areas
      # (mmcblk0boot0) belong to the firmware, not to anyone's home.
      [[ $ro == "1" || $name =~ boot[0-9]$ ]] && continue
      # An SD card in a built-in reader is not on USB, but it comes and goes
      # like a stick does.
      if [[ $rm == "1" || $tran == "usb" || ( $tran == "mmc" && $hotplug == "1" ) ]]; then
        disk_removable[$name]=1
      else
        disk_removable[$name]=0
      fi
      disks+=("$name")
    fi
    parts+=("$line")
  done < <(_hd_lsblk)

  rows=$(for disk in "${disks[@]}"; do
    removable=${disk_removable[$disk]}
    for line in "${parts[@]}"; do
      name=$(_hd_field "$line" NAME)
      type=$(_hd_field "$line" TYPE)
      pkname=$(_hd_field "$line" PKNAME)
      fstype=$(_hd_field "$line" FSTYPE)
      uuid=$(_hd_field "$line" UUID)
      if [[ $type == "part" && $pkname == "$disk" ]] || [[ $type == "disk" && $name == "$disk" && -n $fstype ]]; then
        _hd_scan_device "$name" "$fstype" "$uuid" "" "$disk" "$removable" "$username" "$password"
      fi
    done
    if ((removable == 0)); then
      _hd_row erasable disk "$disk" "" "" "" "" "" "" "" "$disk" 0 "" "" ""
    fi
  done)
  [[ -z $rows ]] || HD_PAIRS=$pairs _hd_mark_duplicates <<<"$rows"

  home_drive_scan_cleanup
  rmdir "$HOME_DRIVE_SCAN_DIR" 2>/dev/null || true
  trap - INT TERM
  [[ -z $_hd_saved_traps ]] || eval "$_hd_saved_traps"
  return 0
}

# The Omarchy lines a layered config needs at its top: the user's own settings
# below them still win. Prints nothing for files that are not layered.
_hd_join_lines() {
  local skel_file=$1 relative=$2 bootstrap
  case $relative in
    .bashrc)
      # Not Omarchy's "return unless interactive" guard: in the user's file
      # it would also cut off their own lines for scripts and ssh commands.
      # The source line is the marker that the join is done.
      bootstrap=$(grep -m1 'env-bootstrap' "$skel_file" || true)
      [[ -z $bootstrap ]] || printf '%s\n%s\n' "$bootstrap" '[[ $- == *i* ]] && source "$OMARCHY_PATH/default/bash/rc"'
      ;;
    .config/kitty/kitty.conf) grep -m1 '^include .*current/theme/kitty.conf' "$skel_file" || true ;;
    .config/ghostty/config) grep -m1 '^config-file =' "$skel_file" || true ;;
    .config/foot/foot.ini) grep -m1 '^include=' "$skel_file" || true ;;
  esac
}

HOME_DRIVE_JOINED_FILES=(.bashrc .config/kitty/kitty.conf .config/ghostty/config .config/foot/foot.ini)

# Put the Omarchy lines on top of one of the user's layered configs, keeping
# the original beside it. Edits in place (through a symlink too) so the file
# keeps its inode and mode; a file or symlink target the user does not own is
# left alone. Prints the record line.
_hd_join() {
  local home=$1 skel=$2 relative=$3
  local file=$home/$relative lines target marker
  lines=$(_hd_join_lines "$skel/$relative" "$relative")
  [[ -n $lines ]] || return 0
  marker=$(tail -n1 <<<"$lines")
  # Run on the system the home belongs to (the ISO runs it inside the target),
  # so links resolve where their owner meant them to.
  target=$(readlink -f -- "$file") || target=""
  # Every step is checked before the original is touched: without a backup
  # and a complete joined copy it is left exactly as it was, and a write that
  # fails part way is undone from the backup. A backup is never overwritten.
  local joined="" backup=$file.before-omarchy n=1 made_backup=false unfinished=false
  # A join cut short after its backup was made leaves the file holding the
  # start of the joined copy (or nothing), which may be all of Omarchy's lines
  # and only some of the user's: looked for first, so those lines alone do not
  # pass for a finished join.
  if [[ -n $target && ( -e $backup || -L $backup ) ]] && joined=$(mktemp 2>/dev/null); then
    if _hd_joined_copy "$lines" "$backup" >"$joined" 2>/dev/null && _hd_is_prefix "$target" "$joined" && ! cmp -s -- "$target" "$joined"; then
      unfinished=true
    fi
  fi
  if [[ $unfinished == "false" && -n $target ]] && grep -qxF -- "$marker" "$target"; then
    rm -f -- "$joined"
    echo "kept $relative"
    return 0
  fi
  if [[ -z $target || ! -O $target || ! -w $target ]]; then
    rm -f -- "$joined"
    echo "skipped-join $relative not-writable-by-owner"
    return 0
  fi
  if [[ -z $joined ]] && ! joined=$(mktemp 2>/dev/null); then
    echo "skipped-join $relative cannot-join"
    return 0
  fi
  if [[ -e $backup || -L $backup ]]; then
    # Finish a join that was cut short from its backup. A file that is
    # anything else is the user's since, and gets a backup of its own.
    if [[ $unfinished == "true" ]]; then
      lines=""
    else
      while [[ -e $file.before-omarchy.$n || -L $file.before-omarchy.$n ]]; do
        n=$((n + 1))
      done
      backup=$file.before-omarchy.$n
    fi
  fi
  if [[ -n $lines ]]; then
    if ! cp -- "$target" "$backup" 2>/dev/null; then
      rm -f -- "$joined" "$backup"
      echo "skipped-join $relative cannot-back-up"
      return 0
    fi
    made_backup=true
    if ! _hd_joined_copy "$lines" "$backup" >"$joined" 2>/dev/null; then
      rm -f -- "$joined" "$backup"
      echo "skipped-join $relative cannot-join"
      return 0
    fi
  fi
  if ! cat -- "$joined" >"$target" 2>/dev/null; then
    [[ $made_backup == "false" ]] || cat -- "$backup" >"$target" 2>/dev/null || true
    rm -f -- "$joined"
    echo "skipped-join $relative cannot-write"
    return 0
  fi
  rm -f -- "$joined"
  echo "joined $relative backup ${backup#"$home"/}"
}

# Omarchy's lines, a blank line, then the user's file.
_hd_joined_copy() {
  printf '%s\n\n' "$1" && cat -- "$2"
}

# Whether <file> holds the start of <whole> (all of it, or nothing).
_hd_is_prefix() {
  local size
  size=$(stat -c %s -- "$1") || return 1
  ((size <= $(stat -c %s -- "$2"))) && cmp -s -n "$size" -- "$1" "$2"
}

# Whether a folder on the way to <relative> is, in the home, a link (dangling
# too) or something other than a folder: the user's own layout, which a
# default is never copied through or over.
_hd_parent_is_users() {
  local home=$1 relative=$2 parent="" part
  local -a parts
  [[ $relative == */* ]] || return 1
  IFS=/ read -r -a parts <<<"${relative%/*}"
  for part in "${parts[@]}"; do
    parent+=${parent:+/}$part
    if [[ -L $home/$parent ]] || [[ -e $home/$parent && ! -d $home/$parent ]]; then
      return 0
    fi
  done
  return 1
}

# home_drive_merge <skel_dir> <home_dir>
#
# Bring Omarchy's defaults into a home that already has a life. Run as the
# home's owner. The user's files win: a path the home already has is never
# replaced, and Omarchy's version stays in the skel (and $OMARCHY_PATH/config)
# to compare with. The layered configs get Omarchy's include lines joined in on
# top. A home with no Omarchy state gets the migration markers like any new
# user; a previous Omarchy home keeps its own history, so Omarchy's migrations
# bring it up to date. Merging again (a reinstall that adopts the same home)
# replaces none of the user's files, joins nothing twice, brings in defaults
# that are new since, and lets that home's migrations run.
#
# Returns 0 when done, 3 when done except for defaults that could not be
# copied (each a failed-copy line in the record), and 1 when the record
# itself cannot be written. A default under a folder the user made a link or
# a file is theirs (kept-parent), not a failure.
home_drive_merge() {
  local skel=$1 home=$2
  local record=$home/.local/state/omarchy/adopted-home
  local had_state=false relative line failed=0
  local -a records=()
  local -A joined=()

  [[ -d $home/.local/state/omarchy ]] && had_state=true

  for relative in "${HOME_DRIVE_JOINED_FILES[@]}"; do
    if [[ ( -e $home/$relative || -L $home/$relative ) && -e $skel/$relative ]]; then
      line=$(_hd_join "$home" "$skel" "$relative")
      if [[ -n $line ]]; then
        records+=("$line")
        joined[$relative]=1
      fi
    fi
  done

  while IFS= read -r -d '' relative; do
    relative=${relative#./}
    if [[ $had_state == true && $relative == .local/state/omarchy/migrations* ]]; then
      continue
    fi
    if [[ -e $home/$relative || -L $home/$relative ]]; then
      [[ -d $skel/$relative || -n ${joined[$relative]:-} ]] || records+=("kept $relative")
    elif _hd_parent_is_users "$home" "$relative"; then
      records+=("kept-parent $relative")
    elif ! (cd "$skel" && cp -a --parents -- "$relative" "$home/") 2>/dev/null; then
      # Setup warns instead of finishing as if the home had every default.
      records+=("failed-copy $relative")
      failed=3
    fi
  done < <(cd "$skel" && find . -mindepth 1 \( -type f -o -type l \) -print0 | sort -z)

  if [[ $had_state == true ]]; then
    # This machine's first-login steps (audio tuning, user units, platform
    # setup) still have to run for a home that comes from another machine.
    rm -f "$home/.local/state/omarchy/done/first-run-user"
    records+=("markers kept")
  else
    records+=("markers copied")
  fi
  records+=("omarchy-defaults /etc/skel \$OMARCHY_PATH/config")

  if ! { mkdir -p "${record%/*}" && printf '%s\n' "${records[@]}" >"$record"; } 2>/dev/null; then
    echo "home_drive_merge: cannot write $record" >&2
    return 1
  fi
  return "$failed"
}

# home_drive_choices <scan>
#
# The rows a Home step offers, as "choice<TAB>row-number" in the order to show
# them: the user's existing homes, home on the install disk (row 0), drives
# that need a passphrase, and disks to erase for a fresh home last, so the
# first row, which Enter picks, never erases or asks for a passphrase. Refused rows are not choices;
# callers explain them from the scan.
home_drive_choices() {
  local scan=$1
  if [[ -n $scan ]]; then
    awk -F'\t' '$1 == "adoptable" { print "adopt\t" NR }' <<<"$scan"
  fi
  printf 'disk\t0\n'
  if [[ -n $scan ]]; then
    awk -F'\t' '$1 == "locked" { print "locked\t" NR }' <<<"$scan"
    awk -F'\t' '$1 == "erasable" { print "fresh\t" NR }' <<<"$scan"
  fi
}

HOME_DRIVE_MAPPER=home
HOME_DRIVE_KEYFILE=/etc/cryptsetup-keys.d/home.key

_hd_luks_add_key() {
  local device=$1 password=$2 keyfile=$3
  printf '%s' "$password" | cryptsetup luksAddKey --key-file=- "$device" "$keyfile"
}

_hd_luks_test_key() {
  cryptsetup open --test-passphrase --key-file="$2" "$1" 2>/dev/null
}

# Drop every line mounting /home (comments stay), then append the new one.
_hd_fstab_set_home() {
  local fstab=$1 line=$2
  local kept=""
  [[ -f $fstab ]] && kept=$(awk '/^[[:space:]]*#/ || $2 != "/home"' "$fstab")
  # In place, so the file keeps its owner and mode.
  { [[ -n $kept ]] && printf '%s\n' "$kept"; [[ -n $line ]] && printf '%s\n' "$line"; } >"$fstab.new"
  cat "$fstab.new" >"$fstab"
  rm -f "$fstab.new"
}

# home_drive_mount_entries <root> <uuid> <fstype> <subvol> <luks_uuid> <root_encrypted> <dir> <luks_password>
#
# Make the system at <root> mount its home from another drive: fstab mounts the
# filesystem <uuid> (inside LUKS when <luks_uuid> is set) at /home, replacing
# the image's @home line, with nofail so a missing drive still boots. With
# <dir> (a home inside another system's root) only that folder of it is
# mounted at /home, through libmount's X-mount.subdir, so nothing else of
# that system is reachable from the new one. An
# encrypted home gets a crypttab line; on an encrypted root it also gets a
# keyfile, kept on that root and added to the home's LUKS, so boot asks for one
# passphrase. On an unencrypted root a keyfile would sit in the clear, so boot
# asks for the home's passphrase instead.
#
# Boot opens an encrypted home before it goes on to the login screen, where
# the prompt would be out of sight and a login would find no home. The wait
# for a drive that is not there is crypttab's, ten seconds; fstab then mounts
# the opened mapping rather than the filesystem's uuid, which has no time
# limit of its own, so a passphrase can take as long as it takes to type.
home_drive_mount_entries() {
  local root=$1 uuid=$2 fstype=$3 subvol=$4 luks_uuid=$5 root_encrypted=$6 dir=$7 password=$8
  local source=UUID=$uuid options=defaults,nofail pass=2 crypttab key kept

  if [[ -n $luks_uuid ]]; then
    source=/dev/mapper/$HOME_DRIVE_MAPPER
  else
    options+=,x-systemd.device-timeout=10s
  fi

  if [[ $fstype == "btrfs" ]]; then
    # Mounted like the image's own subvolumes.
    pass=0
    options+=,noatime,compress=zstd
    if [[ -n $subvol ]]; then
      options+=,subvol=$subvol
    else
      # The top level itself, not whatever the default subvolume is.
      options+=,subvolid=5
    fi
  fi
  [[ -z $dir ]] || options+=,X-mount.subdir=$dir
  _hd_fstab_set_home "$root/etc/fstab" "$source /home $fstype $options 0 $pass"

  [[ -n $luks_uuid ]] || return 0

  crypttab=$root/etc/crypttab
  kept=""
  [[ -f $crypttab ]] && kept=$(awk -v name="$HOME_DRIVE_MAPPER" '$1 != name' "$crypttab")
  if [[ $root_encrypted == "true" ]]; then
    key=$root$HOME_DRIVE_KEYFILE
    if [[ ! -s $key ]]; then
      mkdir -p "${key%/*}"
      chmod 700 "${key%/*}"
      (umask 077 && head -c 64 /dev/urandom >"$key")
      chmod 400 "$key"
    fi
    # Enrolled now unless it already opens the drive (an earlier attempt);
    # without it boot would ask for a second passphrase.
    if ! _hd_luks_test_key "/dev/disk/by-uuid/$luks_uuid" "$key"; then
      _hd_luks_add_key "/dev/disk/by-uuid/$luks_uuid" "$password" "$key" || return 1
    fi
    { [[ -n $kept ]] && printf '%s\n' "$kept"; printf '%s UUID=%s %s luks,x-systemd.device-timeout=10s\n' "$HOME_DRIVE_MAPPER" "$luks_uuid" "$HOME_DRIVE_KEYFILE"; } >"$crypttab"
  else
    { [[ -n $kept ]] && printf '%s\n' "$kept"; printf '%s UUID=%s none luks,x-systemd.device-timeout=10s\n' "$HOME_DRIVE_MAPPER" "$luks_uuid"; } >"$crypttab"
  fi
}

# home_drive_unmount_entries <root>
#
# Undo home_drive_mount_entries on the system at <root>: no /home line in
# fstab, no home line in crypttab, no keyfile. Prints the LUKS uuid the keyfile
# was added to, if any, so the caller can remove that key slot from the drive.
home_drive_unmount_entries() {
  local root=$1 crypttab=$1/etc/crypttab luks_uuid=""
  _hd_fstab_set_home "$root/etc/fstab" ""
  if [[ -f $crypttab ]]; then
    luks_uuid=$(awk -v name="$HOME_DRIVE_MAPPER" '$1 == name { sub(/^UUID=/, "", $2); print $2; exit }' "$crypttab")
    awk -v name="$HOME_DRIVE_MAPPER" '$1 != name' "$crypttab" >"$crypttab.new"
    cat "$crypttab.new" >"$crypttab"
    rm -f "$crypttab.new"
  fi
  rm -f "$root$HOME_DRIVE_KEYFILE"
  [[ -n $luks_uuid ]] && printf '%s\n' "$luks_uuid"
  return 0
}

# home_drive_restore_home_subvolume <root>
#
# Give the system at <root> back the image's own home: the @home subvolume of
# its btrfs root, spelled like the root line (genfstab's options), when no
# line mounts /home. For factory reset, after home_drive_unmount_entries.
home_drive_restore_home_subvolume() {
  local fstab=$1/etc/fstab line
  [[ -f $fstab ]] || return 0
  awk '!/^[[:space:]]*#/ && $2 == "/home" { found = 1 } END { exit !found }' "$fstab" && return 0
  line=$(awk '!/^[[:space:]]*#/ && $2 == "/" && $3 == "btrfs" { print; exit }' "$fstab")
  [[ -n $line ]] || return 0
  line=$(awk '{
    $2 = "/home"
    n = split($4, options, ",")
    out = ""
    named = 0
    for (i = 1; i <= n; i++) {
      if (options[i] ~ /^subvolid=/) continue
      if (options[i] ~ /^subvol=/) { options[i] = "subvol=/@home"; named = 1 }
      out = out (out == "" ? "" : ",") options[i]
    }
    # A root named by subvolid= alone: without its own subvol= the home line
    # would mount the default subvolume.
    if (!named) out = out (out == "" ? "" : ",") "subvol=/@home"
    $4 = out
    print
  }' <<<"$line")
  printf '%s\n' "$line" >>"$fstab"
}

_hd_cryptsetup() { cryptsetup "$@"; }
_hd_wipefs() { wipefs "$@"; }
_hd_blkdiscard() { blkdiscard "$@"; }
_hd_discard_supported() {
  local max
  max=$(lsblk -dbno DISC-MAX "$1" 2>/dev/null | tr -d ' ') || true
  ((${max:-0} > 0))
}

# Active swap devices and files.
_hd_swaps() {
  swapon --show=NAME --noheadings 2>/dev/null || true
}

# The disks under a block device (several for LVM or RAID), nothing for a file.
_hd_disks_of() {
  lsblk -nsrpo NAME,TYPE "$1" 2>/dev/null | awk '$2 == "disk" { print $1 }' || true
}

# home_drive_system_disks
#
# The disks the running system needs: those under /, the ESP (/boot, /efi,
# /boot/efi) and active swap. Never a home drive, never erased. Prints
# "unknown" when / cannot be traced to a disk, so callers treat every disk
# as the system's rather than none.
home_drive_system_disks() {
  local mountpoint source disks
  {
    for mountpoint in / /boot /efi /boot/efi; do
      source=$(findmnt -no SOURCE "$mountpoint" 2>/dev/null) || source=""
      disks=""
      [[ -z $source ]] || disks=$(_hd_disks_of "${source%%\[*}")
      if [[ -n $disks ]]; then
        printf '%s\n' "$disks"
      elif [[ $mountpoint == "/" ]]; then
        echo unknown
      fi
    done
    while IFS= read -r source; do
      [[ -n $source ]] && _hd_disks_of "$source"
    done < <(_hd_swaps)
  } | sort -u
}

# The device and everything stacked on it, as lsblk -P lines.
_hd_lsblk_tree() {
  lsblk -npPo NAME,TYPE,PKNAME,MOUNTPOINT "$1" 2>/dev/null
}

# home_drive_in_use <device>
#
# Whether a disk or partition is mounted (or swapped on), or held by
# something stacked on it (an open LUKS mapping, LVM, RAID), itself or any of
# its partitions. A disk's own partitions do not hold it.
home_drive_in_use() {
  local device=$1 line name
  while IFS= read -r line; do
    [[ -n $line ]] || continue
    name=$(_hd_field "$line" NAME)
    [[ -z $(_hd_field "$line" MOUNTPOINT) ]] || return 0
    [[ $name == "$device" ]] && continue
    [[ $(_hd_field "$line" TYPE) == "part" && $(_hd_field "$line" PKNAME) == "$device" ]] && continue
    return 0
  done < <(_hd_lsblk_tree "$device")
  return 1
}

# home_drive_erase <disk-or-partition>
#
# Erase a home drive for good, as factory reset's Erase does: every LUKS header
# is destroyed (without it the data cannot be decrypted), every filesystem and
# partition signature is wiped, and the whole device is discarded where it
# supports that. A disk takes its partitions with it; a partition is erased
# on its own. On a drive that was never encrypted this is deletion, not
# forensic erasure. Nothing stacked on it is touched: callers refuse a drive
# that is in use.
home_drive_erase() {
  local disk=$1 line name fstype failed=0
  local -a parts=()
  while IFS= read -r line; do
    name=$(_hd_field "$line" NAME)
    [[ ( $(_hd_field "$line" TYPE) == "part" && $(_hd_field "$line" PKNAME) == "$disk" ) || $name == "$disk" ]] || continue
    fstype=$(_hd_field "$line" FSTYPE)
    [[ $name == "$disk" ]] || parts+=("$name")
    # LUKS on a partition or straight on the disk.
    if [[ $fstype == "crypto_LUKS" ]]; then
      _hd_cryptsetup erase --batch-mode "$name" || failed=1
    fi
  done < <(_hd_lsblk)
  for name in "${parts[@]}"; do
    _hd_wipefs -a "$name" || failed=1
  done
  _hd_wipefs -a "$disk" || failed=1
  # Discarding is a bonus where the disk supports it; the headers and
  # signatures above are what the erase cannot do without.
  if _hd_discard_supported "$disk"; then
    _hd_blkdiscard -f "$disk" || true
  fi
  return "$failed"
}
