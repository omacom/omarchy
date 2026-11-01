# PAM creates an encrypted login keyring when a login password is available.
# Autologin enrolls through GNOME's password prompt in the graphical first run.
# Never replace an existing collection or change its default alias here.
keyring_dir="${XDG_DATA_HOME:-$HOME/.local/share}/keyrings"
if [[ ! -d $keyring_dir && -d $HOME/.gnome2/keyrings ]]; then
  keyring_dir="$HOME/.gnome2/keyrings"
fi
install -d -m 700 "$keyring_dir"
