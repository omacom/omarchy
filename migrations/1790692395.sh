echo "Install the hibernate drop-caches system-sleep hook"

# Machines set up before this hook existed already have the resume marker, and
# omarchy-hibernation-setup returns early as soon as it sees that marker, so
# re-running it never installs the hook on the machines that need it. The hook
# does nothing outside a hibernate, so installing it wherever hibernation is
# configured is harmless.
resume_conf=/etc/mkinitcpio.conf.d/omarchy_resume.conf
hook=/usr/lib/systemd/system-sleep/drop-caches

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

# Only for machines that actually hibernate: the marker omarchy-hibernation-setup
# writes, and the same one it checks.
if [[ ! -f $resume_conf ]] || ! grep -q '^HOOKS+=(resume)$' "$resume_conf"; then
  exit 0
fi

# A hook that is already there belongs to whoever put it there - a newer setup,
# or a hand edit. This migration only supplies what is missing.
if [[ -e $hook || -L $hook ]]; then
  exit 0
fi

as_root /usr/bin/install -Dm0755 "$OMARCHY_PATH/default/systemd/system-sleep/drop-caches" "$hook"
