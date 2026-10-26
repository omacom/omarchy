echo "Stop logging the fingerprint lid gate as a PAM error on every open-lid sudo"

# The clamshell gate before pam_fprintd exits 1 whenever the lid is open, and
# pam_exec logs any non-zero exit as "failed: exit code 1", so each sudo or
# polkit prompt on an open laptop wrote an error to the journal. Setup now adds
# quiet_log to the gate; this adds it to the gates earlier setups wrote. Only
# the whole line Omarchy wrote is changed, so a rerun or a gate an
# administrator edited (other flags, arguments or program) is left alone.

gate='^(auth[[:space:]]+\[success=1 default=ignore\][[:space:]]+pam_exec\.so quiet) (/usr/bin/omarchy-hw-laptop-closed[[:space:]]*)$'

for pam in /etc/pam.d/sudo /etc/pam.d/polkit-1; do
  if [[ -f $pam ]] && grep -qE "$gate" "$pam"; then
    sudo sed -i -E "s|$gate|\1 quiet_log \2|" "$pam"
  fi
done
