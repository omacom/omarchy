echo "Add themed mpv controls for users without an existing mpv setup"

# Existing configurations are an explicit opt-in. This also avoids writing
# through Stow links or installing a second controller alongside uosc/ModernZ.
if [[ -L $HOME/.config || -e $HOME/.config/mpv || -L $HOME/.config/mpv ]]; then
  echo "Keeping existing mpv configuration; themed controls require explicit opt-in"
else
  mpv_theme="$HOME/.local/state/omarchy/current/theme"
  if [[ -f $mpv_theme/colors.toml ]]; then
    (
      mpv_tmp=$(mktemp -d)
      mpv_palette=''
      mpv_config=''
      trap 'rm -rf "$mpv_tmp"; [[ -z $mpv_config ]] || rm -rf "$mpv_config"; [[ -z $mpv_palette ]] || rm -f "$mpv_palette"' EXIT
      if [[ ! -e $mpv_theme/mpv-theme.conf ]]; then
        mkdir -p "$mpv_tmp/.local/state/omarchy/current/next-theme"
        cp "$mpv_theme/colors.toml" "$mpv_tmp/.local/state/omarchy/current/next-theme/"
        if [[ -f $mpv_theme/light.mode ]]; then
          cp "$mpv_theme/light.mode" "$mpv_tmp/.local/state/omarchy/current/next-theme/"
        fi
        HOME="$mpv_tmp" PATH="$OMARCHY_PATH/bin:$PATH" bash "$OMARCHY_PATH/bin/omarchy-theme-set-templates"
        # Rename on the same filesystem so a running reader sees a whole file.
        mpv_palette=$(mktemp "$mpv_theme/.mpv-theme.XXXXXX")
        cp "$mpv_tmp/.local/state/omarchy/current/next-theme/mpv-theme.conf" "$mpv_palette"
        mv "$mpv_palette" "$mpv_theme/mpv-theme.conf"
      fi
      mkdir -p "$HOME/.config"
      mpv_config=$(mktemp -d "$HOME/.config/.mpv-controls.XXXXXX")
      cp -a "$OMARCHY_PATH/config/mpv/." "$mpv_config/"
      mv "$mpv_config" "$HOME/.config/mpv"
    )
  else
    echo "No active theme colors found; choose a theme before opting into mpv controls"
  fi
fi
