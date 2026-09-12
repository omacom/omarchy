echo "Restore lock screen fingerprint auth for pre-quattro fingerprint setups"

# Quattro replaced hyprlock with the Quickshell-native lock screen, which
# authenticates fingerprint through its own PAM service,
# /etc/pam.d/omarchy-lock-fingerprint (see shell/plugins/lock/Service.qml).
# That file is only ever written by omarchy-setup-security-fingerprint.
#
# A fingerprint set up before the quattro upgrade has pam_fprintd wired into
# /etc/pam.d/sudo (and usually polkit-1) but never went through today's
# setup_lock_fingerprint_pam, so omarchy-lock-fingerprint was never created.
# hyprlock — and whatever PAM stack it read fingerprint through — was dropped
# from the default package set by the upgrade, so the lock screen silently
# lost fingerprint auth while sudo and polkit kept working. Recreate the file
# for exactly that population; a machine with no prior fingerprint setup has
# no pam_fprintd in /etc/pam.d/sudo and is left for the setup wizard as usual.
if [[ -f /etc/pam.d/sudo ]] &&
  grep -q 'pam_fprintd\.so' /etc/pam.d/sudo &&
  [[ ! -f /etc/pam.d/omarchy-lock-fingerprint ]]; then
  echo "Configuring lock screen for fingerprint authentication..."
  sudo tee /etc/pam.d/omarchy-lock-fingerprint >/dev/null <<'EOF'
#%PAM-1.0
auth       required                    pam_fprintd.so
account    include                     system-local-login
EOF
fi
