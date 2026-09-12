echo "Apply internal keyboard fix for Acer Aspire Go 15 laptops"

drop_in="${OMARCHY_ACER_ASPIRE_LIMINE_CONF:-/etc/limine-entry-tool.d/acer-aspire-keyboard.conf}"
running_cmdline="${OMARCHY_RUNNING_CMDLINE:-/proc/cmdline}"

if omarchy-hw-acer-aspire-go-15; then
  needs_rebuild=0
  if [[ ! -f $drop_in ]] || ! grep -q 'i8042\.reset' "$drop_in"; then
    source "$OMARCHY_PATH/install/hardware/acer/fix-aspire-keyboard.sh"
    needs_rebuild=1
  fi

  if (( needs_rebuild )); then
    if omarchy-cmd-present limine-update; then
      sudo limine-update
    elif omarchy-cmd-present limine-mkinitcpio; then
      sudo limine-mkinitcpio
    fi

    if [[ ! -r $running_cmdline ]] || ! grep -q 'i8042\.reset' "$running_cmdline"; then
      omarchy-state set reboot-required
    fi
  fi
fi
