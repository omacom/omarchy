echo "Tell the user when pam_faillock has locked the account"

# Fresh installs drop `silent` from the preauth line via
# install/config/increase-lockout-limit.sh. Existing machines still have
# `preauth silent`, so a lockout looks like a wrong password forever (#13185).
pam=/etc/pam.d/system-auth
if [[ -f $pam ]] && grep -Eq 'pam_faillock\.so[[:space:]]+preauth[[:space:]]+silent' "$pam"; then
  sudo sed -i -E 's/(pam_faillock\.so[[:space:]]+preauth)[[:space:]]+silent/\1/' "$pam"
fi
