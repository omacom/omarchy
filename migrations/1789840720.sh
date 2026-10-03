echo "Ensure Limine default cmdline still carries root= after omarchy-defaults += drop-ins"

# TEMPORARY (remove after ~2027-03 or once #6951 has been in a stable release
# long enough that leftover unpinned /etc/default/limine boxes are gone):
# one-shot repair for machines already on quattro whose default cmdline never
# pinned root=. Fresh ISO installs and finished upgrades that ran
# preserve_kernel_cmdline_root do not need this. See #9826 / #6894 / #6951.

default_conf=/etc/default/limine

command -v limine-entry-tool >/dev/null 2>&1 || exit 0
command -v limine-mkinitcpio >/dev/null 2>&1 || exit 0
[[ -f /boot/limine.conf ]] || exit 0

if limine-entry-tool --get-cmdline default 2>/dev/null | grep -qE '(^|[[:space:]])root='; then
  exit 0
fi

boot_params=()
have_root=0
have_mount_mode=0
have_unlock=0

cmdline=$(cat /proc/cmdline 2>/dev/null || true)
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
  root_stack=$(lsblk -nso TYPE "$root_source" 2>/dev/null || true)
  if grep -qx crypt <<<"$root_stack" && ((!have_unlock)); then
    echo "Skipping Limine root= repair: root is on dm-crypt and /proc/cmdline has no unlock params (fix /etc/default/limine by hand)."
    exit 0
  fi

  root_uuid=$(findmnt -no UUID / 2>/dev/null || true)
  if [[ -z $root_uuid ]]; then
    echo "Skipping Limine root= repair: could not determine root UUID."
    exit 0
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

mkdir -p "$(dirname "$default_conf")"
touch "$default_conf"
cat >>"$default_conf" <<EOF_CONF

# Written by migration 1789840720: omarchy-defaults.conf uses KERNEL_CMDLINE[default]+=,
# which suppresses limine-entry-tool's fallback to /proc/cmdline. Pin boot-critical
# parameters explicitly (see #9826).
KERNEL_CMDLINE[default]+=" ${boot_params[*]}"
EOF_CONF

limine-mkinitcpio || echo "Warning: limine-mkinitcpio failed after pinning root=; check /etc/default/limine before reboot."
