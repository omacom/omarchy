echo "Keep the ThinkPad T14 Gen 2i panel from blanking itself"

# The install-time leaf only reaches machines set up after it shipped, and a
# kernel parameter in a Limine drop-in only reaches the boot entries on a
# rebuild. The marker stops another user's run from repeating the machine-wide
# rebuild, while a missing marker retries an interrupted one.
limine_config_dir=${OMARCHY_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}
config_file=$limine_config_dir/thinkpad-t14-display-power.conf
rebuild_marker=${OMARCHY_THINKPAD_T14_DISPLAY_POWER_MARKER:-/var/lib/omarchy/migrations/1792574886}
expected='KERNEL_CMDLINE[default]+=" i915.enable_dc=0 i915.enable_fbc=0"'

omarchy-hw-match "ThinkPad T14 Gen 2i" || exit 0
omarchy-cmd-present limine-mkinitcpio || exit 0
[[ ! -e $rebuild_marker ]] || exit 0

# The drop-in is written whenever it does not already carry the parameter, not
# only when it is missing: an interrupted write can leave a file that exists
# but does not carry it, and because omarchy-migrate stops on a failed
# migration, a file that only exists would block every later run. Writing it
# again repairs that.
if ! grep -Fxq "$expected" "$config_file" 2>/dev/null; then
  # sudo resets the environment, so the directory the leaf writes to is passed
  # in rather than inherited: the leaf and the check below must name the same
  # one, or the migration would verify a file the leaf never wrote.
  sudo bash -c 'OMARCHY_LIMINE_CONFIG_DIR="$1" bash "$2"' bash \
    "$limine_config_dir" \
    "$OMARCHY_PATH/install/hardware/lenovo/fix-thinkpad-t14-display-power.sh"
fi

if ! grep -Fxq "$expected" "$config_file" 2>/dev/null; then
  echo "Couldn't apply the ThinkPad T14 Gen 2i display setting; leaving the boot migration pending" >&2
  exit 1
fi

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0,
# so neither its exit status nor its output alone decides whether the boot
# image carries the setting: the status says whether the tool failed, and the
# output says whether a kernel was left unbuilt. The marker stops every later
# retry, so a rebuild that did not rebuild has to leave the migration pending.
# The output is captured rather than piped, so the status of the rebuild is
# the rebuild's own and not a pipe's: a pipeline reports the last command, and
# the shell options this migration happens to run under are not its own.
rebuild_output=$(sudo limine-mkinitcpio 2>&1) && rebuild_status=0 || rebuild_status=$?
printf '%s\n' "$rebuild_output"

if (( rebuild_status != 0 )); then
  echo "Couldn't rebuild the boot entries; leaving the ThinkPad T14 Gen 2i display migration pending" >&2
  exit 1
fi

if grep -q 'mkinitcpio failed for kernel' <<<"$rebuild_output"; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

sudo install -Dm644 /dev/null "$rebuild_marker"

omarchy-state set reboot-required
