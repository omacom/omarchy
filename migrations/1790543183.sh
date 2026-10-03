echo "Hibernate on critical battery when Omarchy hibernation is set up"

# CriticalPowerAction=Auto follows logind Sleep() (suspend-then-hibernate) at
# PercentageAction=2%. With Omarchy hibernation configured, hibernate directly
# at a higher threshold so the image write can finish before the pack dies.
# Machines without the Omarchy resume hook keep the stock Auto policy.

resume_conf="${OMARCHY_MKINITCPIO_RESUME_CONF:-/etc/mkinitcpio.conf.d/omarchy_resume.conf}"
source_dropin="$OMARCHY_PATH/default/UPower/UPower.conf.d/70-omarchy-critical-hibernate.conf"
destination="${OMARCHY_UPOWER_CRITICAL_HIBERNATE_CONF:-/etc/UPower/UPower.conf.d/70-omarchy-critical-hibernate.conf}"

[[ -f $resume_conf ]] || exit 0
grep -q '^HOOKS+=(resume)$' "$resume_conf" || exit 0
[[ -f $source_dropin ]] || exit 0

if [[ -f $destination ]] && cmp -s "$source_dropin" "$destination"; then
  exit 0
fi

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

as_root mkdir -p "${destination%/*}"
as_root install -m 644 -T "$source_dropin" "$destination"
as_root systemctl try-restart upower.service >/dev/null 2>&1 || true
