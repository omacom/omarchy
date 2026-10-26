echo "Stop logging the fingerprint lid gate as a PAM error on every open-lid sudo"

# The clamshell gate before pam_fprintd exits 1 whenever the lid is open, and
# pam_exec logs any non-zero exit as "failed: exit code 1", so each sudo or
# polkit prompt on an open laptop wrote an error to the journal. Setup now adds
# quiet_log to the gate; this adds it to the gates earlier setups wrote. Only
# the exact line Omarchy wrote is changed, so a rerun or a hand-edited gate
# is left alone.

for pam in /etc/pam.d/sudo /etc/pam.d/polkit-1; do
  if [[ -f $pam ]] && grep -q 'pam_exec\.so quiet /usr/bin/omarchy-hw-laptop-closed' "$pam"; then
    sudo sed -i 's|pam_exec\.so quiet /usr/bin/omarchy-hw-laptop-closed|pam_exec.so quiet quiet_log /usr/bin/omarchy-hw-laptop-closed|' "$pam"
  fi
done
