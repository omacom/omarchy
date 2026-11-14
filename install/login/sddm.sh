# Prevent password-based SDDM logins from creating an encrypted login keyring
# that conflicts with Omarchy's passwordless default keyring behavior. The ISO
# owns autologin/session state because it knows whether the target is encrypted.
sddm_pam="${OMARCHY_SDDM_PAM:-/etc/pam.d/sddm}"
sddm_autologin_pam="${OMARCHY_SDDM_AUTOLOGIN_PAM:-/etc/pam.d/sddm-autologin}"

if [[ -f $sddm_pam ]]; then
  sed -i '/-auth.*pam_gnome_keyring\.so/d' "$sddm_pam"
  sed -i '/-password.*pam_gnome_keyring\.so/d' "$sddm_pam"
fi

# Autologin has no password for pam_gnome_keyring to unlock with. Its session
# auto_start can still block sddm-helper for ~30s after Plymouth quits, leaving
# a black screen before the Wayland session starts (#13414). Omarchy seeds a
# passwordless Default keyring from install/user/default-keyring.sh instead.
if [[ -f $sddm_autologin_pam ]]; then
  sed -i '/pam_gnome_keyring\.so/d' "$sddm_autologin_pam"
fi
