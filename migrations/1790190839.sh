echo "Let TRIM reach the SSD through dm-crypt on the LUKS root volume"

# Without allow-discards on the mapping, dm-crypt drops every TRIM the
# filesystem sends, so an encrypted install reports no discard support at all
# (discard_granularity 0, fstrim: "the discard operation is not supported") and
# the SSD keeps treating freed blocks as live data. btrfs enables discard=async
# on its own since 6.2, but only for devices that advertise discard support, so
# the passthrough is the whole fix.
#
# Fresh installs get the options from install/config/luks-trim.sh; this repairs
# machines installed before it. Completion is machine-wide because the repair
# is: migration markers are per-user, and a second user must not rewrite the
# boot cmdline the first one already fixed.

source "$OMARCHY_PATH/install/helpers/luks-trim.sh"

limine_conf="${OMARCHY_LUKS_TRIM_LIMINE_CONF:-/etc/default/limine}"
trim_marker="${OMARCHY_LUKS_TRIM_MARKER:-/var/lib/omarchy/migrations/1790190839}"

[[ ! -e $trim_marker ]] || exit 0

# No /etc/default/limine, or no cryptdevice= parameter in it: the root is not a
# LUKS mapping, so there is nothing to let through and nothing to change.
if ! omarchy_luks_has_cryptdevice "$limine_conf"; then
  exit 0
fi

# limine-mkinitcpio is what turns the parameter into a boot entry. A machine
# that manages its own boot keeps its boot configuration untouched.
if omarchy-cmd-missing limine-mkinitcpio; then
  exit 0
fi

if ! omarchy_luks_has_trim_options "$limine_conf"; then
  echo "Allowing TRIM through dm-crypt in $limine_conf"
  omarchy_luks_add_trim_options "$limine_conf"
fi

# The boot entry points at a UKI that embeds the cmdline, and the package hooks
# that would rebuild it ran before this repair (and do not run on a kernel that
# has not changed), so rebuild explicitly rather than assume the entry carries
# the parameter.
if ! as_root limine-mkinitcpio; then
  echo "limine-mkinitcpio failed; the boot entries were not regenerated." >&2
  exit 1
fi

# limine-mkinitcpio can return success after skipping a failed kernel build, so
# read back the cmdline the entries are generated from instead of trusting its
# exit status. Never report a repaired machine whose entries would still refuse
# TRIM.
if ! as_root limine-entry-tool --get-cmdline default 2>/dev/null | grep -q 'allow-discards'; then
  echo "The boot entries are not generated with the TRIM options; rerun omarchy-migrate after fixing the boot image build." >&2
  exit 1
fi

# Apply the options to the mapping that is open right now, so the SSD can be
# trimmed without waiting for a reboot, and record them in the LUKS2 metadata
# where a plain activation picks them up too. cryptsetup asks for the LUKS
# passphrase for both, so this needs a terminal: without one it fails with
# "Nothing to read on input" instead of prompting. The next boot applies the
# cmdline option either way.
mapping=$(omarchy_luks_mapping_name "$limine_conf") || mapping=""
trim_live=0
if [[ -n $mapping && -t 0 && -t 1 ]]; then
  if as_root cryptsetup refresh --allow-discards --persistent "$mapping"; then
    trim_live=1
  else
    echo "The running mapping was left as it is; the options apply at the next boot." >&2
  fi
fi

if (( !trim_live )); then
  omarchy-state set reboot-required
fi

as_root install -Dm644 /dev/null "$trim_marker"
