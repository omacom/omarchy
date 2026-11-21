echo "Ensure Limine default cmdline still carries root= after omarchy-defaults += drop-ins"

# TEMPORARY (remove after ~2027-03 or once #6951 has been in a stable release
# long enough that leftover unpinned /etc/default/limine boxes are gone):
# one-shot repair for machines already on quattro whose default cmdline never
# pinned root=. Fresh ISO installs and finished upgrades that ran
# preserve_kernel_cmdline_root do not need this. See #9826 / #6894 / #6951.
#
# Migrations run as the user, but /boot (a umask=0077 ESP) and
# /etc/default/limine are root-only, so every check and write goes through
# as_root. A repair that cannot finish exits non-zero so it stays pending.

limine_conf=${OMARCHY_LIMINE_CONF:-/boot/limine.conf}
default_conf=${OMARCHY_LIMINE_DEFAULT_CONF:-/etc/default/limine}
uki_dir=${OMARCHY_LIMINE_UKI_DIR:-/boot/EFI/Linux}
proc_cmdline=${OMARCHY_PROC_CMDLINE:-/proc/cmdline}

as_root() {
  if ((EUID == 0)); then
    "$@"
  else
    sudo "$@"
  fi
}

has_root_param() {
  grep -qE '(^|[[:space:]])root='
}

# The cmdline that boots is the one in limine.conf and embedded in each UKI, so
# a successful limine-mkinitcpio exit alone does not prove the repair landed
# (it maps per-kernel build failures to success).
built_entries_missing_root() {
  local uki uki_cmdline uki_sections
  local missing=()

  as_root grep -qE '(^|[[:space:]])root=' "$limine_conf" || missing+=("$limine_conf")

  if command -v objcopy >/dev/null 2>&1; then
    while read -r uki; do
      [[ -n $uki ]] || continue
      # Secure Boot with Snapper builds UKIs without .cmdline, so they boot the
      # limine.conf cmdline checked above.
      if uki_sections=$(as_root objdump -h "$uki" 2>/dev/null) && [[ $uki_sections != *" .cmdline "* ]]; then
        continue
      fi
      # Capture first: under pipefail, grep -q closing the pipe early could
      # SIGPIPE objcopy and read as a missing root=.
      uki_cmdline=$(as_root objcopy -O binary --only-section=.cmdline "$uki" /dev/stdout 2>/dev/null | tr -d '\0') || uki_cmdline=""
      has_root_param <<<"$uki_cmdline" || missing+=("$uki")
    done < <(as_root find "$uki_dir" -maxdepth 1 -name 'omarchy_linux*.efi' 2>/dev/null)
  fi

  ((${#missing[@]})) || return 1
  echo "${missing[*]}"
}

command -v limine-entry-tool >/dev/null 2>&1 || exit 0
command -v limine-mkinitcpio >/dev/null 2>&1 || exit 0

# A denied prompt must leave this migration pending rather than read as "no
# Limine here", so authentication failure stops it before the check.
as_root true
as_root test -f "$limine_conf" || exit 0

if ! effective=$(as_root limine-entry-tool --get-cmdline default 2>/dev/null); then
  echo "Error: limine-entry-tool --get-cmdline default failed; the Limine root= pin was not checked." >&2
  exit 1
fi

if has_root_param <<<"$effective"; then
  # Already pinned. Only a machine whose built entries still lack root= (for
  # example after an earlier rebuild failed) needs the rebuild below.
  built_entries_missing_root >/dev/null || exit 0
else
  boot_params=()
  have_root=0
  have_mount_mode=0
  have_unlock=0

  cmdline=$(cat "$proc_cmdline" 2>/dev/null || true)
  for param in $cmdline; do
    key=${param%%=*}
    case $key in
      root)
        have_root=1
        boot_params+=("$param")
        ;;
      rw | ro)
        have_mount_mode=1
        boot_params+=("$param")
        ;;
      cryptdevice | cryptkey | rd.luks.name | rd.luks.uuid | rd.luks.options | rd.luks.key | rd.luks.crypttab | dm-mod.create)
        have_unlock=1
        boot_params+=("$param")
        ;;
      rootflags | rootfstype | rootwait | rootdelay | resume | resume_offset | rd.lvm.lv | rd.lvm.vg | rd.md.uuid | rd.dm.uuid)
        boot_params+=("$param")
        ;;
    esac
  done

  if ((!have_root)); then
    root_source=$(findmnt -no SOURCE --nofsroot / 2>/dev/null || true)
    # An lsblk failure must not read as "no crypt layer".
    if ! root_stack=$(lsblk -nso TYPE "$root_source" 2>/dev/null); then
      echo "Error: could not inspect the root device stack; add root= to $default_conf by hand, then run limine-mkinitcpio." >&2
      exit 1
    fi
    if grep -qx crypt <<<"$root_stack" && ((!have_unlock)); then
      echo "Error: root is on dm-crypt and $proc_cmdline has no unlock parameters. Add root= and the matching cryptdevice or rd.luks.* parameters to $default_conf by hand, then run limine-mkinitcpio." >&2
      exit 1
    fi

    root_uuid=$(findmnt -no UUID / 2>/dev/null || true)
    if [[ -z $root_uuid ]]; then
      echo "Error: could not determine the root filesystem UUID; add root= to $default_conf by hand, then run limine-mkinitcpio." >&2
      exit 1
    fi

    boot_params=("root=UUID=$root_uuid" "${boot_params[@]}")
    ((have_mount_mode)) || boot_params+=(rw)

    if [[ $(findmnt -no FSTYPE / 2>/dev/null) == btrfs ]]; then
      subvol=$(findmnt -no FSROOT / 2>/dev/null || true)
      if [[ -n $subvol && $subvol != / ]]; then
        boot_params+=("rootflags=subvol=${subvol#/}")
      fi
    fi
  fi

  as_root mkdir -p "$(dirname "$default_conf")"
  # omarchy:heredoc-expands paths=none -- ${boot_params[*]} is the kernel
  # cmdline fragment assembled above from /proc/cmdline and findmnt output
  # (root=, rootflags=, rw), not a filesystem path this script controls.
  as_root tee -a "$default_conf" >/dev/null <<EOF_CONF

# Written by migration 1789840720: omarchy-defaults.conf uses KERNEL_CMDLINE[default]+=,
# which suppresses limine-entry-tool's fallback to /proc/cmdline. Pin boot-critical
# parameters explicitly (see #9826).
KERNEL_CMDLINE[default]+=" ${boot_params[*]}"
EOF_CONF
fi

if ! as_root limine-mkinitcpio; then
  echo "Error: limine-mkinitcpio failed after pinning root=; the boot entries were not regenerated. Do not reboot until it succeeds." >&2
  exit 1
fi

if unrepaired=$(built_entries_missing_root); then
  echo "Error: root= is still missing from $unrepaired after the rebuild. Do not reboot until the kernel cmdline is repaired, or the system will drop to an emergency shell." >&2
  exit 1
fi
