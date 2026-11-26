echo "Name the hibernation resume device by its filesystem UUID"

# Hibernation setup named an unencrypted root by its kernel name. With two NVMe
# disks that name can belong to the other disk at the next boot, and resume then
# finds no image and the session is lost. Setup now writes the filesystem UUID,
# and on a configured machine renames the device and rebuilds the boot image.
drop_in=/etc/limine-entry-tool.d/resume.conf
hook=/etc/mkinitcpio.conf.d/omarchy_resume.conf
pending=/var/lib/omarchy/hibernation-resume-rebuild

# A pending marker means setup renamed the device but the boot image was not
# rebuilt with it yet.
if [[ ! -e $pending ]]; then
  [[ -f $drop_in ]] && grep -q 'resume=/dev/' "$drop_in" && ! grep -q 'resume=/dev/mapper/' "$drop_in" || exit 0
fi

# Without the resume hook, setup would offer to set hibernation up from scratch.
[[ -f $hook ]] && grep -q '^HOOKS+=(resume)$' "$hook" || exit 0

# Setup leaves the marker if the boot image is not rebuilt and exits 1, which
# keeps this migration pending for the next omarchy-migrate.
omarchy-hibernation-setup
