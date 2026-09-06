# Setup user theme folder and seed the default only when no theme exists yet.
mkdir -p ~/.config/omarchy/themes

if [[ ! -s $HOME/.local/state/omarchy/current/theme.name ]]; then
  # iso-chroot and provision-owner both run without a live session to notify.
  if [[ ${OMARCHY_SETUP_CONTEXT:-runtime} != "runtime" ]]; then
    OMARCHY_THEME_HEADLESS=1 omarchy-theme-set "Tokyo Night"
    rm -f ~/.config/BraveSoftware/Brave-Origin/SingletonLock # otherwise archiso owns the browser singleton
  else
    omarchy-theme-set "Tokyo Night"
  fi
fi
omarchy-theme-set-pi --activate

mkdir -p ~/.config/btop/themes
ln -snf "$HOME/.local/state/omarchy/current/theme/btop.theme" ~/.config/btop/themes/current.theme
