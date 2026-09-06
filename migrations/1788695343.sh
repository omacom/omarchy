echo "Make the keyboard-backlight and force-igpu sleep hooks executable so systemd-sleep runs them"

# omarchy-hibernation-setup and omarchy-toggle-hybrid-gpu copied these hooks
# with cp -p from a 644 file, so the installed copies were never executable and
# systemd-sleep silently skipped them: the keyboard LEDs stayed on into S4 (which
# the hook exists to prevent on ASUS keyboards) and force-igpu never detached
# the dGPU before hibernate. Both scripts now use install -m755; repair the
# copies already on disk.
hook_dir="${OMARCHY_SYSTEM_SLEEP_DIR:-/usr/lib/systemd/system-sleep}"

for hook in "$hook_dir/keyboard-backlight" "$hook_dir/force-igpu"; do
  [[ -f $hook && ! -x $hook ]] || continue
  if [[ -O $hook ]]; then
    chmod 755 "$hook"
  else
    sudo chmod 755 "$hook"
  fi
done
