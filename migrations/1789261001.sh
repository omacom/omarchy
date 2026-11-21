echo "Drop the lid gate from lock-screen fingerprint PAM"

# An earlier revision of this migration (and setup/apply-lock) inserted
# omarchy-hw-laptop-open with [success=ignore default=1] before pam_fprintd.
# On the lock PamContext that skip is PAM success and unlocks with the lid
# closed. Remove the gate; lid policy stays in the lock service (#10393).

pam=/etc/pam.d/omarchy-lock-fingerprint

if [[ -f $pam ]] && grep -q 'omarchy-hw-laptop-open' "$pam"; then
  sudo sed -i '/omarchy-hw-laptop-open/d' "$pam"
fi
