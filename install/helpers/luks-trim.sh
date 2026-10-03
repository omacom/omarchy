# Let TRIM and the dm-crypt workqueue bypass reach the SSD on encrypted installs,
# for the install path and for the migration that repairs machines installed
# before this existed.
#
# dm-crypt refuses TRIM unless its mapping was opened with allow-discards, so an
# encrypted root advertises no discard support at all (discard_granularity 0),
# and btrfs — which enables discard=async on its own since 6.2, but only for
# devices that advertise discard support — never releases a block on the SSD.
# The controller keeps treating freed blocks as live data, which costs write
# amplification and endurance. fstrim cannot help either: with the option absent
# the discard reaches dm-crypt's queue and stops there.
#
# The mkinitcpio encrypt hook — the parser Omarchy's HOOKS drop-in selects over
# the base mkinitcpio.conf — reads the kernel cmdline parameter
# cryptdevice=<device>:<name>:<options> and hands the third colon field to
# cryptsetup as a comma-separated option list, so the options belong there:
#
#   allow-discards      let TRIM reach the drive
#   no-read-workqueue   bypass dm-crypt's per-CPU read workqueue
#   no-write-workqueue  bypass dm-crypt's per-CPU write workqueue
#
# Those names are the hook's own spellings. It matches each option against a
# whitelist and warns about, but ignores, everything else, so the parameter has
# to say allow-discards rather than whatever cryptsetup takes on a command line.
# The workqueue options are what cryptsetup calls --perf-no_read_workqueue and
# --perf-no_write_workqueue. dm-crypt's queues exist to serialise reads for
# same-CPU crypto; on a modern NVMe that costs throughput and await latency for
# no gain, so they are bypassed alongside the discards they were once there to
# make safe.
#
# A machine that unlocks through rd.luks.* has no cryptdevice= parameter to
# extend and is left alone.

source "$(dirname -- "${BASH_SOURCE[0]}")/as-root.sh"

# Written in this order on the parameters that lack them.
OMARCHY_LUKS_TRIM_OPTIONS=(allow-discards no-read-workqueue no-write-workqueue)

# True when <file> exists and carries a cryptdevice= parameter.
omarchy_luks_has_cryptdevice() {
  [[ -f $1 ]] && grep -q 'cryptdevice=' "$1"
}

# True when <option> is listed on a cryptdevice= parameter. The option has to
# follow the parameter's device/name fields, so an option named in a comment or
# in an unrelated setting cannot stand in for it.
omarchy_luks_has_option() {
  local file="$1" option="$2"

  grep -Eq "cryptdevice=[^[:space:]\"']*[=:,]$option([,]|[[:space:]\"']|\$)" "$file"
}

# True when every TRIM option is already on the parameter.
omarchy_luks_has_trim_options() {
  local file="$1" option

  omarchy_luks_has_cryptdevice "$file" || return 1
  for option in "${OMARCHY_LUKS_TRIM_OPTIONS[@]}"; do
    omarchy_luks_has_option "$file" "$option" || return 1
  done
}

# Add the missing TRIM options to every cryptdevice= parameter in <file>, one
# option at a time, so a parameter that already carries some of them only gains
# the rest. An existing option list is extended with a comma; a parameter with
# just a device and a name gets the list after the name. Nothing else in the
# file is touched, and a parameter that already has an option is left as it is,
# which is what makes a repeat run change nothing.
omarchy_luks_add_trim_options() {
  local file="$1" option

  for option in "${OMARCHY_LUKS_TRIM_OPTIONS[@]}"; do
    if omarchy_luks_has_option "$file" "$option"; then
      continue
    fi

    as_root sed -i -E \
      -e "s#(cryptdevice=[^:[:space:]\"']+:[^:[:space:]\"']+:[^:[:space:]\"']+)#\1,$option#" \
      -e "s#(cryptdevice=[^:[:space:]\"']+:[^:[:space:]\"']+)([[:space:]\"']|\$)#\1:$option\2#" \
      "$file"
  done
}

# The mapping name from the cryptdevice= parameter, for refreshing a mapping
# that is already open. Fails when the parameter names no mapping.
omarchy_luks_mapping_name() {
  local spec

  spec=$(grep -oE "cryptdevice=[^[:space:]\"']+" "$1" 2>/dev/null | head -1) || true
  [[ $spec == cryptdevice=*:* ]] || return 1
  spec=${spec#cryptdevice=}
  spec=${spec#*:}
  printf '%s\n' "${spec%%:*}"
}
