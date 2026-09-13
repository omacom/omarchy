echo "Install the Omarchy Panther Lake kernel and prefer Omarchy kernels in Limine"

omarchy-pkg-present linux-ptl || exit 0

limine_conf="${OMARCHY_PTL_LIMINE_CONF:-/etc/default/limine}"
limine_drop_ins="${OMARCHY_PTL_LIMINE_DROP_INS:-/etc/limine-entry-tool.d}"
rebuild_marker="${OMARCHY_PTL_REBUILD_MARKER:-/var/lib/omarchy/migrations/1789095456}"
kernel="linux-omarchy-ptl-novrr-mm"

# Completion is machine-wide even though migrations run once per user. Leave
# the old kernel installed so it remains available if the new one cannot boot.
[[ ! -e $rebuild_marker ]] || exit 0
omarchy-pkg-add "$kernel" "$kernel-headers"

# /etc/default/limine and the Dell drop-ins were written by the installer.
# omarchy-settings ships omarchy-defaults.conf, but pacman's backup protection
# can leave its update in a .pacnew when other settings were customized. Repair
# only the old boot order in the active files, preserving custom orders and
# unrelated settings, including the root filesystem's kernel command line.
for conf in "$limine_conf" \
  "$limine_drop_ins/omarchy-defaults.conf" \
  "$limine_drop_ins/dell-xps-panther-lake.conf" \
  "$limine_drop_ins/zz-dell-xps-panther-lake.conf"; do
  if [[ -f $conf ]]; then
    sudo sed -i -E \
      's/^([[:space:]]*BOOT_ORDER=)"(\*|linux-ptl\*), \*fallback, Snapshots"([[:space:]]*(#.*)?)$/\1"linux-omarchy-*, *, *fallback, Snapshots"\3/' \
      "$conf"
  fi
done

# Package hooks ran before the config repair. Rebuild the new kernel's image
# and boot entry explicitly, including on retries after a failed rebuild.
sudo limine-mkinitcpio "$kernel"

# limine-mkinitcpio can return success after skipping a failed kernel build.
# Do not mark the migration complete unless the new kernel is in the menu.
if ! sudo limine-entry-tool --tree | grep -F "$kernel" >/dev/null; then
  echo "The new Panther Lake kernel has no Limine boot entry; rerun omarchy-migrate after fixing the boot image build." >&2
  exit 1
fi

# Keeping the running kernel installed prevents the updater from detecting a
# kernel replacement, so request the reboot explicitly.
omarchy-state set reboot-required
sudo install -Dm644 /dev/null "$rebuild_marker"
