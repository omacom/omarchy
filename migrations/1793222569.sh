echo "Let the login screen find the account by its password"

# The login screen now asks for a password alone and tries each account in
# turn. omarchy-login-match ends an attempt early when the password is another
# account's, so trying the wrong account first is neither slow nor counted as
# a failed login. pam_exec needs the literal /usr/bin path.

# It goes before the first auth line, whatever its indentation, and only an
# active line counts as already there.
login_match="auth        [success=die default=ignore] pam_exec.so quiet expose_authtok /usr/bin/omarchy-login-match"
if [[ -f /etc/pam.d/sddm ]] && ! grep -Eq '^[[:space:]]*auth[[:space:]].*/usr/bin/omarchy-login-match' /etc/pam.d/sddm; then
  if grep -Eq '^[[:space:]]*-?auth[[:space:]]' /etc/pam.d/sddm; then
    sudo sed -E -i "0,/^[[:space:]]*-?auth[[:space:]]/s||$login_match\n&|" /etc/pam.d/sddm
  else
    echo "No auth line in /etc/pam.d/sddm; the login screen will count a wrong account as a failed login." >&2
  fi
fi
