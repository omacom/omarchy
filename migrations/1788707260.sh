echo "Apply internal keyboard fix for Acer Aspire Go 15 laptops"

drop_in="${OMARCHY_ACER_ASPIRE_LIMINE_CONF:-/etc/limine-entry-tool.d/acer-aspire-keyboard.conf}"
running_cmdline="${OMARCHY_RUNNING_CMDLINE:-/proc/cmdline}"
rebuild_marker="${OMARCHY_ACER_ASPIRE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1788707260}"

if omarchy-hw-acer-aspire-go-15; then
  needs_rebuild=0
  if [[ ! -f $drop_in ]] || ! grep -q 'i8042\.reset' "$drop_in"; then
    source "$OMARCHY_PATH/install/hardware/acer/fix-aspire-keyboard.sh"
    needs_rebuild=1
  fi

  # The drop-in alone does not prove the boot entries were rebuilt, so a marker
  # records the rebuild: a failed one retries, another user's skips it.
  if (( needs_rebuild )) || [[ ! -e $rebuild_marker ]]; then
    sudo rm -f "$rebuild_marker"
    if omarchy-cmd-present limine-update; then
      sudo limine-update
    else
      sudo limine-mkinitcpio
    fi
    sudo install -Dm644 /dev/null "$rebuild_marker"
  fi

  # reboot-required is per user, so ask even when another user did the rebuild.
  if [[ ! -r $running_cmdline ]] || ! grep -q 'i8042\.reset' "$running_cmdline"; then
    omarchy-state set reboot-required
  fi
fi
