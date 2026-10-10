echo "Strip password keyring auth from the SDDM autologin PAM stack"

# Autologin uses /etc/pam.d/sddm-autologin, not sddm. Existing installs that
# already ran install/login/sddm.sh still have gnome-keyring auth/password
# modules on the autologin stack, which create an encrypted login keyring
# against Omarchy's passwordless default.

pam=/etc/pam.d/sddm-autologin
[[ -f $pam ]] || exit 0

if ! grep -qE -- '-auth.*pam_gnome_keyring\.so|-password.*pam_gnome_keyring\.so' "$pam"; then
  exit 0
fi

if (( EUID == 0 )); then
  sed -i '/-auth.*pam_gnome_keyring\.so/d' "$pam"
  sed -i '/-password.*pam_gnome_keyring\.so/d' "$pam"
else
  sudo sed -i '/-auth.*pam_gnome_keyring\.so/d' "$pam"
  sudo sed -i '/-password.*pam_gnome_keyring\.so/d' "$pam"
fi
