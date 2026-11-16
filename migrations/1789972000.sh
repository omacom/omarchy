echo "Repair hibernation drop-ins with an empty resume= device"

drop_in=/etc/limine-entry-tool.d/resume.conf
hook=/etc/mkinitcpio.conf.d/omarchy_resume.conf
pending=/var/lib/omarchy/hibernation-resume-rebuild

if [[ ! -e $pending ]]; then
  [[ -f $drop_in ]] && grep -Eq 'resume=[[:space:]]+resume_offset=' "$drop_in" || exit 0
fi

# omarchy-hibernation-remove leaves the drop-in behind; without the hook, setup
# would create the swapfile again.
[[ -f $hook ]] && grep -q '^HOOKS+=(resume)$' "$hook" || exit 0

# Setup repairs the drop-in atomically and keeps this migration pending if the
# device is unavailable or the boot image could not be rebuilt.
omarchy-hibernation-setup --force
