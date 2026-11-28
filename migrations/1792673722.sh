echo "Put splash back so the Plymouth LUKS prompt stays graphical"

# omarchy-settings ships omarchy-defaults.conf as a backed-up file, so pacman
# keeps the copy a user changed and writes no .pacnew while the packaged
# content stays the same. A copy whose KERNEL_CMDLINE[default]+= line lost
# `splash` still carries every parameter the other guards look for, so they all
# no-op and nothing reports the drift. Plymouth then skips every graphical
# renderer and serves the LUKS passphrase from the text `details` plugin: no
# logo, a plain console prompt, and no warning. Put the token back on Omarchy's
# own line, and rebuild the boot image once per machine.

defaults_conf="${OMARCHY_LIMINE_DEFAULTS_CONF:-/etc/limine-entry-tool.d/omarchy-defaults.conf}"
running_cmdline="${OMARCHY_RUNNING_CMDLINE:-/proc/cmdline}"
limine_defaults="${OMARCHY_LIMINE_DEFAULT_CONF:-/etc/default/limine}"
rebuild_marker="${OMARCHY_LIMINE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1792673722}"
rebuild_lock="${OMARCHY_LIMINE_REBUILD_LOCK:-/var/lib/omarchy/migrations/limine-rebuild.lock}"

omarchy-cmd-present limine-mkinitcpio || exit 0
[[ -f $defaults_conf && -r $defaults_conf ]] || exit 0

# Omarchy's own quiet line, recognised by the tokens it ships beside splash. A
# command line someone wrote themselves is not ours to add splash to, and the
# other KERNEL_CMDLINE[default] lines this file carries are left as they are.
# The `|| [[ -n $line ]]` keeps a last line that has no newline.
file_has_splash=false
repaired=false
lines=()
while IFS= read -r line || [[ -n $line ]]; do
  words=${line//\"/}
  if [[ $line == 'KERNEL_CMDLINE[default]+="'*'"' ]]; then
    if [[ " $words " == *" splash "* ]]; then
      file_has_splash=true
    elif [[ " $words " == *" quiet "* && " $words " == *" loglevel=0 "* &&
      " $words " == *" vt.global_cursor_default=0 "* ]]; then
      # Append before the closing quote: where the token sits on the line is
      # the file's, and a copy that reordered the tokens is still Omarchy's.
      line="${line%\"} splash\""
      repaired=true
      file_has_splash=true
    fi
  elif [[ $line == 'KERNEL_CMDLINE[default]'* ]]; then
    [[ " $words " != *" splash "* ]] || file_has_splash=true
  fi
  lines+=("$line")
done <"$defaults_conf"

# Stage the rewrite in a file of this run and rename it over, so a write cut
# short cannot leave a partial boot command line behind. The name is unique per
# run because two users updating at once would otherwise share one staging file
# and keep writing to the copy the other has already renamed into place.
if [[ $repaired == true ]]; then
  staged=$(sudo mktemp "$defaults_conf.XXXXXX") || exit 1
  printf '%s\n' "${lines[@]}" | sudo tee "$staged" >/dev/null || exit 1
  sudo chmod 644 "$staged" || exit 1
  sudo mv -f -- "$staged" "$defaults_conf" || exit 1
  echo "Restored splash in $defaults_conf"
fi

# A command line that never carried splash is the user's own; nothing to
# rebuild. One that already boots with it needs no rebuild either.
[[ $file_has_splash == true ]] || exit 0
[[ -r $running_cmdline ]] || exit 0
[[ " $(<"$running_cmdline") " != *" splash "* ]] || exit 0

# omarchy-migrate runs migrations per user, so a machine where the booted
# command line lacks splash has every user's migration wanting this rebuild at
# once, and two limine-mkinitcpio runs writing the same boot images leave one
# nothing can boot. One machine-wide lock, held until the migration exits,
# makes the marker check below mean what it says.
if omarchy-cmd-present flock; then
  # touch, not install: install replaces the file, and two runs replacing it
  # would each lock an inode of their own. The mode is set after, because a
  # user's umask 077 would leave a lock no other user can open, and the
  # directory has to stay traversable for them to reach it.
  sudo install -d -m 755 "$(dirname "$rebuild_lock")" || exit 1
  sudo touch "$rebuild_lock" || exit 1
  sudo chmod 644 "$rebuild_lock" || exit 1
  exec {rebuild_lock_fd}<"$rebuild_lock" || exit 1
  flock -w 300 "$rebuild_lock_fd" || exit 1
fi

# The running kernel keeps its command line until reboot, so a marker records
# the machine-wide rebuild: another user's migration must not repeat it before
# then, while a missing marker still retries an interrupted rebuild.
[[ ! -e $rebuild_marker ]] || exit 0

echo "The booted kernel is missing splash; rebuilding the boot image"
rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT
sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0, so
# read its log rather than the menu: with UKIs the menu has no command lines to
# read, and the other distributions FIND_BOOTLOADERS adds to it carry none of
# Omarchy's tokens. A kernel left out keeps the migration pending, and the next
# update tries again.
if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

# A plain KERNEL_CMDLINE[default]= in /etc/default/limine replaces what
# omarchy-defaults.conf appends, which limine-entry-tool's own README suggests,
# so the rebuilt image can still boot without splash. That command line is the
# administrator's: say how to keep Omarchy's defaults rather than edit it, and
# leave the migration complete so the queue keeps moving.
defaults_replaced=false
replaced_with_splash=false
if [[ -r $limine_defaults ]]; then
  while IFS= read -r line; do
    [[ $line == 'KERNEL_CMDLINE[default]='* ]] || continue
    defaults_replaced=true
    [[ " ${line//\"/} " != *" splash "* ]] || replaced_with_splash=true
  done <"$limine_defaults"
fi
if [[ $defaults_replaced == true && $replaced_with_splash == false ]]; then
  echo "The Limine kernel command line leaves out splash; use += rather than = in /etc/default/limine to keep Omarchy's defaults"
fi

sudo install -Dm644 /dev/null "$rebuild_marker"
