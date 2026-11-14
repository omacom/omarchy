echo "Install Osaka Jade from its own repo for anyone still on it"

# Osaka Jade moved to its own repo under the same name. Dated before 1787481315 so
# a 4.0 upgrade installs it before that refresh swaps it for the default, and a 4.5
# install the refresh left with no colors.toml still gets it.
theme_name_path="$HOME/.local/state/omarchy/current/theme.name"
user_theme="$HOME/.config/omarchy/themes/osaka-jade"
repo="https://github.com/omacom/omarchy-osaka-jade-theme"

[[ -s $theme_name_path && $(<"$theme_name_path") == "osaka-jade" ]] || exit 0

[[ -f $OMARCHY_PATH/themes/osaka-jade/colors.toml ]] && exit 0

if [[ -f $user_theme/colors.toml ]]; then
  [[ -f $HOME/.local/state/omarchy/current/theme/colors.toml ]] || omarchy-theme-set osaka-jade
  exit 0
fi

if [[ -d $user_theme ]]; then
  # Overrides that were layered on the bundled theme: give back its palette, icons
  # and wallpapers beside them, never over them, rather than replacing the directory.
  clone=$(mktemp -d)
  if GIT_TERMINAL_PROMPT=0 git clone -q --depth 1 -- "$repo" "$clone"; then
    [[ -L $user_theme/backgrounds ]] || cp -rn "$clone/backgrounds" "$user_theme/"
    cp -n "$clone/icons.theme" "$clone/colors.toml" "$user_theme/"
    rm -rf "$clone"
    omarchy-theme-set osaka-jade
    exit 0
  fi
  rm -rf "$clone"
elif GIT_TERMINAL_PROMPT=0 omarchy-theme-install "$repo"; then
  exit 0
fi

echo "Could not install Osaka Jade; applying Jade Horse, which replaced it"
omarchy-theme-set "Jade Horse"
