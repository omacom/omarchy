# Prevent password-based SDDM logins from creating an encrypted login keyring
# that conflicts with Omarchy's passwordless default keyring behavior. The ISO
# owns autologin/session state because it knows whether the target is encrypted.
if [[ -f /etc/pam.d/sddm ]]; then
  sed -i '/-auth.*pam_gnome_keyring\.so/d' /etc/pam.d/sddm
  sed -i '/-password.*pam_gnome_keyring\.so/d' /etc/pam.d/sddm
fi

# The login screen asks for a password alone and tries each account in turn;
# omarchy-login-match ends an attempt early when the password is another
# account's, so only a password that is nobody's counts as a failed login.
# It goes before the first auth line, whatever its indentation, and only an
# active line counts as already there.
login_match="auth        [success=die default=ignore] pam_exec.so quiet expose_authtok /usr/bin/omarchy-login-match"
if [[ -f /etc/pam.d/sddm ]] && ! grep -Eq '^[[:space:]]*auth[[:space:]].*/usr/bin/omarchy-login-match' /etc/pam.d/sddm; then
  if grep -Eq '^[[:space:]]*-?auth[[:space:]]' /etc/pam.d/sddm; then
    sed -E -i "0,/^[[:space:]]*-?auth[[:space:]]/s||$login_match\n&|" /etc/pam.d/sddm
  else
    echo "No auth line in /etc/pam.d/sddm; the login screen will count a wrong account as a failed login." >&2
  fi
fi
