echo "Silence the fingerprint clamshell PAM gate on the common lid-open path"

# The previous gate ran omarchy-hw-laptop-closed with [success=1 default=ignore].
# Lid open (the usual case) exited 1, and pam_exec logged that at LOG_ERR on
# every sudo/polkit auth. Flip to omarchy-hw-laptop-open with
# [success=ignore default=1] so control flow stays the same but the common
# path exits 0.
#
# Lock is a separate PamContext whose only auth module is pam_fprintd.
# Skipping it would unlock. Leave that stack alone; leftover lock lid lines
# are stripped by 1788600001.sh.

gate='auth      [success=ignore default=1] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-open'

for pam in /etc/pam.d/sudo /etc/pam.d/polkit-1; do
  [[ -f $pam ]] || continue
  grep -q 'pam_fprintd\.so' "$pam" || continue

  if grep -q 'omarchy-hw-laptop-open' "$pam"; then
    continue
  fi

  sudo sed -i -e '/omarchy-hw-laptop-closed/d' -e '/omarchy-hw-laptop-open/d' "$pam"
  if ! grep -q 'omarchy-hw-laptop-open' "$pam"; then
    sudo sed -i "/pam_fprintd\.so/i $gate" "$pam"
  fi
done
