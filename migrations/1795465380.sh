echo "Pin Electron and Cursor password stores to gnome-libsecret on Hyprland"

# Electron cannot tell Hyprland from a desktop with no keyring. Arch's electronN
# launcher reads electronN-flags.conf when that file exists, and electron-flags.conf
# otherwise. A versioned file with no pin hides the fallback, so an existing one
# is pinned too. An uncommented --password-store= line is left alone. A
# commented-out flag is not a choice, so the pin is still added.
#
# x86_64 cursor-bin launches through that same code.sh, so the electron pin
# reaches it unless a versioned file shadows the fallback. aarch64 cursor-bin
# keeps Cursor's bundled launcher, which never reads those files. argv.json is
# what both launchers honor. Create it only when Cursor is installed; when it
# already exists, add the key without treating a comment as a setting.

pin_electron_flags() {
  local flags_file="$1"

  if [[ ! -f $flags_file ]] || ! grep -Eq '^[[:space:]]*--password-store=' "$flags_file"; then
    mkdir -p "${flags_file%/*}"

    if [[ -f $flags_file && -n $(tail -c1 "$flags_file") ]]; then
      echo >>"$flags_file"
    fi

    echo '--password-store=gnome-libsecret' >>"$flags_file"
  fi
}

config_dir=${XDG_CONFIG_HOME:-$HOME/.config}
pin_electron_flags "$config_dir/electron-flags.conf"

shopt -s nullglob
for flags_file in "$config_dir"/electron[0-9]*-flags.conf; do
  pin_electron_flags "$flags_file"
done
shopt -u nullglob

argv=$HOME/.cursor/argv.json
if [[ -f $argv ]] || omarchy-pkg-present cursor-bin || omarchy-cmd-present cursor; then
  omarchy-cmd-cursor-password-store "$argv"
fi
