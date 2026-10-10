echo "Rebuild the boot image so USB autosuspend stays off"

# omarchy-defaults.conf now sets usbcore.autosuspend=-1, because the
# modprobe.d option Omarchy shipped for it never reached the built-in usbcore.
# The package only updates the Limine config; the boot entries keep their old
# command line until the image is rebuilt, so rebuild it once when the booted
# kernel doesn't have the parameter yet.

defaults_conf="${OMARCHY_LIMINE_DEFAULTS_CONF:-/etc/limine-entry-tool.d/omarchy-defaults.conf}"
default_limine="${OMARCHY_DEFAULT_LIMINE:-/etc/default/limine}"
running_cmdline="${OMARCHY_RUNNING_CMDLINE:-/proc/cmdline}"
rebuild_marker="${OMARCHY_LIMINE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1790963359}"
param="usbcore.autosuspend=-1"

omarchy-cmd-present limine-mkinitcpio || exit 0
[[ -f $defaults_conf && -r $running_cmdline ]] || exit 0

# The running kernel keeps its old command line until reboot, so a marker
# records the machine-wide rebuild instead: another user's migration must not
# repeat it before then, while a missing marker still retries a failed rebuild.
[[ ! -e $rebuild_marker ]] || exit 0
[[ " $(<"$running_cmdline") " != *" $param "* ]] || exit 0

# The last usbcore.autosuspend= value on a command line, which the kernel uses.
# limine-entry-tool decides which value comes last, and every later rebuild
# (a kernel update) follows the same order, so the migration only applies it.
autosuspend_value() {
  local word value=""

  for word in $1; do
    [[ $word == usbcore.autosuspend=* ]] && value=${word#usbcore.autosuspend=}
  done
  printf '%s\n' "$value"
}

effective=$(sudo limine-entry-tool --get-cmdline default)

# omarchy-defaults.conf is a backup file, so where it was edited (1784917531
# appended to it) the update landed in a .pacnew beside it and nothing sets the
# parameter. Add it the same way, on its own line and only once, unless
# /etc/default/limine replaces the drop-ins' command line, where it couldn't
# take effect.
line="KERNEL_CMDLINE[default]+=\" $param\""
if [[ -z $(autosuspend_value "$effective") && -e $defaults_conf.pacnew ]] &&
  ! grep -Fxq "$line" "$defaults_conf" &&
  ! grep -Eqs '^[[:space:]]*KERNEL_CMDLINE\[default\][[:space:]]*=' "$default_limine"; then
  printf '\n%s\n' "$line" | sudo tee -a "$defaults_conf" >/dev/null
  effective=$(sudo limine-entry-tool --get-cmdline default)
fi

value=$(autosuspend_value "$effective")
if [[ $value == "-1" ]]; then
  echo "The booted kernel is missing $param; rebuilding the boot image"
  sudo limine-mkinitcpio
  omarchy-state set reboot-required
  sudo install -Dm644 /dev/null "$rebuild_marker"
elif [[ -n $value ]]; then
  echo "Limine sets usbcore.autosuspend=$value, which overrides Omarchy's $param; leaving it"
else
  echo "Limine's kernel command line doesn't take $param (check /etc/default/limine), so USB autosuspend stays on"
fi
