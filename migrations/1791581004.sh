echo "Stop the boot from waiting on a black screen for the console to answer"

# systemd asks the console for its size when PID 1 starts and waits for the
# reply. With Plymouth holding the screen the reply sometimes never comes, and
# about 1 boot in 10 sits on a black screen until a key is pressed.
# omarchy-defaults.conf now carries systemd.tty.term.console=dumb, which makes
# systemd skip the query. The package has already written that file by the
# time this runs; the boot image still holds the old command line until it is
# rebuilt.

defaults_conf="${OMARCHY_LIMINE_DEFAULTS_CONF:-/etc/limine-entry-tool.d/omarchy-defaults.conf}"
running_cmdline="${OMARCHY_RUNNING_CMDLINE:-/proc/cmdline}"
rebuild_marker="${OMARCHY_LIMINE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1791581004}"
modules_dir="${OMARCHY_KERNEL_MODULES_DIR:-/usr/lib/modules}"
limine_functions="${OMARCHY_LIMINE_FUNCTIONS:-/usr/lib/limine/limine-common-functions}"
param="systemd.tty.term.console=dumb"

# Whether a command line carries the parameter as systemd reads it: split on
# spaces, tabs and newlines outside single or double quotes, which it drops, the
# last assignment of the key winning, even one an unclosed quote runs to the end.
carries_param() {
  local cmdline=$1 word="" last="" quote="" char i
  for ((i = 0; i < ${#cmdline}; i++)); do
    char=${cmdline:i:1}
    if [[ -z $quote && ($char == '"' || $char == "'") ]]; then
      quote=$char
    elif [[ $char == "$quote" ]]; then
      quote=""
    elif [[ -z $quote && $' \t\n\r' == *"$char"* ]]; then
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
# records the machine-wide rebuild: another user's migration must not repeat
# it before then, while a missing marker still retries an interrupted rebuild.
[[ ! -e $rebuild_marker ]] || exit 0

# A machine that boots with it already, or whose defaults were edited to leave
# it out, has nothing to rebuild.
! carries_param "$(<"$running_cmdline")" || exit 0
grep -Eq "^KERNEL_CMDLINE\[default\]\+=\".*${param//./\\.}.*\"" "$defaults_conf" || exit 0

echo "The booted kernel is missing $param; rebuilding the boot image"
sudo limine-mkinitcpio

# The boot menu is on the ESP, which /etc/default/limine names; /boot when it
# does not, or is not there.
limine_conf="${OMARCHY_LIMINE_CONF:-}"
if [[ -z $limine_conf ]]; then
  esp=""
  if [[ -r /etc/default/limine ]]; then
    esp=$(sed -n 's/^ESP_PATH=["'\'']\?\([^"'\'']*\).*/\1/p' /etc/default/limine | tail -n 1)
  fi
  limine_conf="${esp:-/boot}/limine.conf"
fi

# limine-mkinitcpio carries on past a kernel it could not build, a full boot
# partition for one, and still exits 0. Done means a boot entry has the
# parameter: without that the migration stays pending and the next update
# tries again. A menu with no command lines in it (they are inside the boot
# images then) has nothing to look at, and is taken at its word.
menu_cmdlines=$(sudo grep -E '^[[:space:]]*cmdline:' "$limine_conf" 2>/dev/null) || menu_cmdlines=""
built=0
while IFS= read -r menu_cmdline; do
  ! carries_param "${menu_cmdline#*cmdline:}" || built=1
done <<<"$menu_cmdlines"

if [[ -n $menu_cmdlines ]] && ((!built)); then
  # Unless the Limine config leaves it out of every kernel the rebuild builds,
  # which no rebuild can change: a plain KERNEL_CMDLINE[default]= in
  # /etc/default/limine, as limine-entry-tool's README suggests, or per-kernel
  # keys. Ask limine-entry-tool, for the kernels limine-mkinitcpio builds and
  # the fallbacks it builds, read from the config the way it reads them.
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

  echo "The Limine kernel command line leaves out $param; use += rather than = in /etc/default/limine to keep Omarchy's defaults"
fi

sudo install -Dm644 /dev/null "$rebuild_marker"
