# Setup user theme folder and seed the default only when no theme exists yet.
mkdir -p ~/.config/omarchy/themes

if [[ ! -s $HOME/.local/state/omarchy/current/theme.name ]]; then
  # iso-chroot and provision-owner both run without a live session to notify.
  if [[ ${OMARCHY_SETUP_CONTEXT:-runtime} != "runtime" ]]; then
    OMARCHY_THEME_HEADLESS=1 omarchy-theme-set "Tokyo Night"
    rm -f ~/.config/google-chrome/SingletonLock ~/.config/chromium/SingletonLock # otherwise archiso owns the browser singleton
  else
    omarchy-theme-set "Tokyo Night"
  fi
fi
omarchy-theme-set-pi --activate
omarchy-theme-set-fcitx5 --activate
# A headless theme set skips the retints, so the seeded config would keep its
# default icon theme until the first switch.
omarchy-theme-set-qt

# A saved theme from before OpenCode 2 can lack its palette. Rebuild it when
# the theme source is still available, then skip activation instead of failing
# finalization when no palette can be produced.
theme_dir="$HOME/.local/state/omarchy/current/theme"
theme_name_path="$HOME/.local/state/omarchy/current/theme.name"
if [[ ! -f $theme_dir/opencode.json && -s $theme_name_path ]]; then
  theme_name=$(<"$theme_name_path")
  if [[ -d $OMARCHY_PATH/themes/$theme_name || -d $HOME/.config/omarchy/themes/$theme_name ]]; then
    omarchy-theme-refresh
  fi
fi
if [[ -f $theme_dir/opencode.json ]]; then
  omarchy-theme-set-opencode --activate
else
  echo "OpenCode theme activation skipped: the active palette is unavailable; select an installed theme to enable syncing."
fi

mkdir -p ~/.config/btop/themes
ln -snf "$HOME/.local/state/omarchy/current/theme/btop.theme" ~/.config/btop/themes/current.theme
