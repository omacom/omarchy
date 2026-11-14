echo "Remove the unused fred=on kernel command line"

# Linux 7.1 enables FRED by default and only reads fred=off. The drop-in
# install/hardware/intel/fred.sh wrote is ignored and logged as an unknown
# parameter. Delete the exact file Omarchy shipped; leave an edited copy alone.

drop_in=/etc/limine-entry-tool.d/intel-panther-lake-fred.conf
default_limine=/etc/default/limine
rebuild_needed=/var/lib/omarchy/migrations/1788521801-rebuild-needed
limine_mkinitcpio=/usr/bin/limine-mkinitcpio
install_command=/usr/bin/install
rm_command=/usr/bin/rm
sed_command=/usr/bin/sed

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

finish_pending_rebuild() {
  # omarchy-migrate records a zero exit and will not run this file again.
  # Leaving the rebuild marker in place is not a retry unless this stays pending.
  if [[ ! -x $limine_mkinitcpio ]]; then
    echo "limine-mkinitcpio is not available to rebuild the boot image after removing fred=on. The repair stays pending." >&2
    exit 1
  fi

  if ! as_root "$limine_mkinitcpio"; then
    echo "Could not rebuild the boot image after removing fred=on. Ask an administrator to run omarchy-migrate." >&2
    exit 1
  fi

  if ! as_root "$rm_command" -f -- "$rebuild_needed"; then
    echo "Could not finish the fred=on drop-in repair. Ask an administrator to run omarchy-migrate." >&2
    exit 1
  fi
}

shipped_drop_in=0
if [[ -f $drop_in ]]; then
  expected=$(mktemp)
  trap 'rm -f "$expected"' EXIT
  printf '%s\n' '# Intel Panther Lake FRED support' 'KERNEL_CMDLINE[default]+=" fred=on"' >"$expected"
  if cmp -s "$drop_in" "$expected"; then
    shipped_drop_in=1
  fi
  rm -f "$expected"
  trap - EXIT
fi

# Omarchy 3 also appended the drop-in to /etc/default/limine, which the upgrade
# to 4 carries across and which overrides every drop-in.
appended_to_default=0
if [[ -f $default_limine ]] && grep -Fxq 'KERNEL_CMDLINE[default]+=" fred=on"' "$default_limine"; then
  appended_to_default=1
fi

if (( shipped_drop_in || appended_to_default )); then
  if ! as_root "$install_command" -Dm644 /dev/null "$rebuild_needed"; then
    echo "Administrator privileges are required to remove the unused fred=on kernel command line. Ask an administrator to run omarchy-migrate." >&2
    exit 1
  fi

  if (( shipped_drop_in )) && ! as_root "$rm_command" -f -- "$drop_in"; then
    echo "Administrator privileges are required to remove the unused fred=on kernel command line. Ask an administrator to run omarchy-migrate." >&2
    exit 1
  fi

  if (( appended_to_default )) && ! as_root "$sed_command" -i \
    -e '/^# Intel Panther Lake FRED support$/d' \
    -e '/^KERNEL_CMDLINE\[default\]+=" fred=on"$/d' "$default_limine"; then
    echo "Administrator privileges are required to remove the unused fred=on kernel command line. Ask an administrator to run omarchy-migrate." >&2
    exit 1
  fi

  finish_pending_rebuild
elif [[ -e $rebuild_needed ]]; then
  finish_pending_rebuild
fi
