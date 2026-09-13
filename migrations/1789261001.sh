echo "Gate lock-screen fingerprint auth behind the lid state"

# Existing fingerprint setups write /etc/pam.d/omarchy-lock-fingerprint with
# pam_fprintd alone. With the lid shut the lock screen still hammers the
# unreachable reader. Insert the same pam_exec gate sudo/polkit already use.
# New setups get this from omarchy-setup-security-fingerprint / omarchy-apply-lock.

gate="auth      [success=1 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed"
pam=/etc/pam.d/omarchy-lock-fingerprint

if [[ -f $pam ]] &&
  grep -q 'pam_fprintd\.so' "$pam" &&
  ! grep -q 'omarchy-hw-laptop-closed' "$pam"; then
  sudo sed -i "/pam_fprintd\.so/i $gate" "$pam"
fi
