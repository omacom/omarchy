echo "Offer to move the boot loader from Limine to systemd-boot"

# The switch is opt-in for now: it explains itself, checks the machine and
# asks. Machines it can't move yet, unattended updates and a "no" all leave
# Limine in place; the Setup menu keeps offering it.
[[ $(omarchy-boot-backend) == limine ]] || exit 0
# ARM machines can switch from the Setup menu; the update offers it on x86,
# where the switch has been run on real machines.
omarchy-hw-x86 || exit 0

if [[ -n ${OMARCHY_UPDATE_UNATTENDED:-} || ! -t 0 ]]; then
  echo "Run omarchy-boot-switch to move this machine to systemd-boot, the boot loader Secure Boot needs."
  exit 0
fi

omarchy-boot-switch || true
