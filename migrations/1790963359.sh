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
modules_dir="${OMARCHY_KERNEL_MODULES_DIR:-/usr/lib/modules}"
limine_functions="${OMARCHY_LIMINE_FUNCTIONS:-/usr/lib/limine/limine-common-functions}"
param="usbcore.autosuspend=-1"

# Whether a command line carries the parameter as the kernel reads it: split on
# whitespace outside double quotes, which it drops, the last assignment winning.
carries_param() {
  local cmdline=$1 word="" last="" quoted=0 char i
  for ((i = 0; i < ${#cmdline}; i++)); do
    char=${cmdline:i:1}
    if [[ $char == '"' ]]; then
      quoted=$((!quoted))
    elif ((!quoted)) && [[ $' \t\n\r' == *"$char"* ]]; then
      [[ $word != "${param%%=*}="* ]] || last=$word
      word=""
    else
      word+=$char
    fi
  done
  [[ $word != "${param%%=*}="* ]] || last=$word
  [[ $last == "$param" ]]
}

omarchy-cmd-present limine-mkinitcpio || exit 0
[[ -f $defaults_conf && -r $running_cmdline ]] || exit 0

# The running kernel keeps its old command line until reboot, so a marker
# records the machine-wide rebuild instead: another user's migration must not
# repeat it before then, while a missing marker still retries a failed rebuild.
[[ ! -e $rebuild_marker ]] || exit 0
! carries_param "$(<"$running_cmdline")" || exit 0

# The last usbcore.autosuspend= value on a command line, which the kernel uses.
# limine-entry-tool decides which value comes last, and every later rebuild
# (a kernel update) follows the same order, so the migration only applies it.
autosuspend_value() {
  local word value=""

  for word in $1; do
    word=${word//\"/}
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
  rebuild_log=$(mktemp)
  trap 'rm -f "$rebuild_log"' EXIT
  sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

  # limine-mkinitcpio carries on past a kernel it could not build, a full boot
  # partition for one, and still exits 0, so the migration stays pending.
  if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
    echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
    exit 1
  fi

  # Done also means a boot entry has the parameter. A menu with no command
  # lines in it (they are inside the boot images then) is taken at its word.
  limine_conf="${OMARCHY_LIMINE_CONF:-}"
  if [[ -z $limine_conf ]]; then
    esp=""
    if [[ -r /etc/default/limine ]]; then
      esp=$(sed -n 's/^ESP_PATH=["'\'']\?\([^"'\'']*\).*/\1/p' /etc/default/limine | tail -n 1)
    fi
    limine_conf="${esp:-/boot}/limine.conf"
  fi

  menu_cmdlines=$(sudo grep -E '^[[:space:]]*cmdline:' "$limine_conf" 2>/dev/null) || menu_cmdlines=""
  built=0
  while IFS= read -r menu_cmdline; do
    ! carries_param "${menu_cmdline#*cmdline:}" || built=1
  done <<<"$menu_cmdlines"

  if [[ -n $menu_cmdlines ]] && ((!built)); then
    # Unless per-kernel keys leave it out of every kernel the rebuild builds,
    # which no rebuild can change. Ask limine-entry-tool for each, as 1791581004 does.
    # shellcheck disable=SC2016
    fallback=$(sudo bash -c 'source "$1" && load_config >/dev/null && printf "%s\n" "${MKINITCPIO_FALLBACK:-}"' _ "$limine_functions")
    configured=0
    shopt -s nullglob
    for kernel_dir in "$modules_dir"/*/; do
      [[ -f ${kernel_dir}modules.builtin ]] || continue
      kernel_name=$(pacman -Qqo "${kernel_dir}modules.builtin" 2>/dev/null) || continue
      entries=("$kernel_name")
      [[ $fallback != "yes" && $fallback != "$kernel_name" ]] || entries+=("$kernel_name-fallback")
      for entry in "${entries[@]}"; do
        kernel_cmdline=$(sudo limine-entry-tool --get-cmdline "$entry" | tail -n 1)
        ! carries_param "$kernel_cmdline" || configured=1
      done
    done
    shopt -u nullglob

    if ((configured)); then
      echo "The boot menu still has no entry with $param after the rebuild" >&2
      exit 1
    fi

    echo "Limine's per-kernel command lines leave out $param, so USB autosuspend stays on"
  fi

  omarchy-state set reboot-required
  sudo install -Dm644 /dev/null "$rebuild_marker"
elif [[ -n $value ]]; then
  echo "Limine sets usbcore.autosuspend=$value, which overrides Omarchy's $param; leaving it"
else
  echo "Limine's kernel command line doesn't take $param (check /etc/default/limine), so USB autosuspend stays on"
fi
