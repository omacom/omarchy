echo "Stop pam_gnome_keyring from blocking SDDM autologin"

# sddm-autologin ships `-session optional pam_gnome_keyring.so auto_start`. With
# no password available that step can stall ~30s after Plymouth, leaving a black
# screen before Hyprland starts (#13414). Fresh installs drop the line from
# install/login/sddm.sh; existing machines need the same edit once.

autologin_pam="${OMARCHY_SDDM_AUTOLOGIN_PAM:-/etc/pam.d/sddm-autologin}"

[[ -f $autologin_pam ]] || exit 0
grep -q 'pam_gnome_keyring\.so' "$autologin_pam" || exit 0

# Migrations run as the desktop user; /etc/pam.d is root-owned.
if [[ -w $autologin_pam ]]; then
  sed -i '/pam_gnome_keyring\.so/d' "$autologin_pam"
else
  sudo sed -i '/pam_gnome_keyring\.so/d' "$autologin_pam"
fi
