echo "Install dynamic lid-close sleep policy for existing hibernation setups"

# omarchy-hibernation-setup installs the lid-close policy only on fresh setups:
# machines that already have hibernation configured hit its "already set up"
# early exit before reaching the new policy install. Backfill those machines
# here so battery lid-close becomes suspend-then-hibernate (20min delay), AC
# stays in suspend for lid-open wake, and docked stays awake for clamshell.
# New setups get both files from the setup command; this is a no-op for them.

MKINITCPIO_CONF="/etc/mkinitcpio.conf.d/omarchy_resume.conf"
if [[ ! -f $MKINITCPIO_CONF ]] || ! grep -q "^HOOKS+=(resume)$" "$MKINITCPIO_CONF"; then
  exit 0
fi

lid_source="$OMARCHY_PATH/default/systemd/logind.conf.d/99-omarchy-lid-sleep.conf"
sleep_source="$OMARCHY_PATH/default/systemd/sleep.conf.d/10-omarchy-suspend-then-hibernate.conf"
lid_dest="/etc/systemd/logind.conf.d/99-omarchy-lid-sleep.conf"
sleep_dest="/etc/systemd/sleep.conf.d/10-omarchy-suspend-then-hibernate.conf"
legacy_logind="/etc/systemd/logind.conf.d/99-suspend-then-hibernate.conf"

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

safe_stage_path() {
  local stage="$1"
  local destination="$2"
  local prefix suffix

  prefix="${destination%/*}/.${destination##*/}.omarchy."
  [[ $stage == "$prefix"* ]] || return 1
  suffix=${stage#"$prefix"}
  [[ $suffix =~ ^[[:alnum:]]{6}$ ]]
}

install_root_file() {
  local source="$1"
  local destination="$2"
  local mode="$3"
  local stage

  stage=$(as_root /usr/bin/mktemp -- "${destination%/*}/.${destination##*/}.omarchy.XXXXXX") || return 1
  safe_stage_path "$stage" "$destination" || return 1

  if as_root /usr/bin/install -m "$mode" -o root -g root -T "$source" "$stage" &&
    as_root /usr/bin/mv -Tf -- "$stage" "$destination"; then
    return 0
  else
    safe_stage_path "$stage" "$destination" && as_root /usr/bin/rm -f -- "$stage"
    return 1
  fi
}

# The package update lands sources before migrations run. A dev checkout can
# carry this migration before the sources it installs, so retry instead of
# marking complete without the policy.
if [[ ! -f $lid_source ]]; then
  echo "Lid policy source is missing ($lid_source); rerun omarchy-migrate after updating." >&2
  exit 1
fi
if [[ ! -f $sleep_source ]]; then
  echo "Sleep policy source is missing ($sleep_source); rerun omarchy-migrate after updating." >&2
  exit 1
fi

# Already on the new policy: nothing to do (avoids a pointless logind reload).
if [[ -f $lid_dest && -f $sleep_dest ]] &&
  cmp -s -- "$lid_source" "$lid_dest" &&
  cmp -s -- "$sleep_source" "$sleep_dest" &&
  [[ ! -e $legacy_logind ]]; then
  exit 0
fi

# Remove the legacy manual drop-in superseded by the policy (same as setup).
as_root rm -f -- "$legacy_logind"

if ! install_root_file "$lid_source" "$lid_dest" 0644; then
  echo "Could not install the lid-close logind policy; rerun omarchy-migrate from a terminal." >&2
  exit 1
fi
if ! install_root_file "$sleep_source" "$sleep_dest" 0644; then
  echo "Could not install the suspend-then-hibernate sleep policy; rerun omarchy-migrate from a terminal." >&2
  exit 1
fi

# logind reads drop-ins on reload (restart would tear down the session);
# sleep.conf is read per suspend, so no reload covers it. Fall back to a
# reboot request when the reload cannot run now.
if ! as_root systemctl reload systemd-logind >/dev/null 2>&1; then
  omarchy-state set reboot-required
fi
