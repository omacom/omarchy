echo "Hibernate on critical battery on laptops that already set up hibernation"

# omarchy-hibernation-setup now installs a UPower drop-in that hibernates on
# critical battery, but only when it runs. A laptop set up before keeps UPower's
# Auto action, which suspends into a dying battery (#13256). On a machine that
# already has hibernation, setup skips the swap and boot steps and only adds
# what is missing, and it leaves an installed drop-in alone.
resume_conf="${OMARCHY_RESUME_CONF:-/etc/mkinitcpio.conf.d/omarchy_resume.conf}"

if [[ -f $resume_conf ]] && grep -q "^HOOKS+=(resume)$" "$resume_conf" && omarchy-battery-present; then
  omarchy-hibernation-setup
fi
