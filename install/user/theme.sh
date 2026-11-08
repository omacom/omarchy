# Setup user theme folder and seed the default only when no theme exists yet.
mkdir -p ~/.config/omarchy/themes

if [[ ! -s $HOME/.local/state/omarchy/current/theme.name ]]; then
  # iso-chroot and provision-owner both run without a live session to notify.
  if [[ ${OMARCHY_SETUP_CONTEXT:-runtime} != "runtime" ]]; then
    OMARCHY_THEME_HEADLESS=1 omarchy-theme-set "Tokyo Night"
    rm -f ~/.config/chromium/SingletonLock # otherwise archiso owns the Chromium singleton
  else
    omarchy-theme-set "Tokyo Night"
  fi
fi
omarchy-theme-set-pi --activate
omarchy-theme-set-fcitx5 --activate

# A see-through GTK app asks the compositor for blur through its gtk.css, which
# follows the window mode, so a fresh install needs it written once too.
omarchy-theme-set-glass

mkdir -p ~/.config/btop/themes
ln -snf "$HOME/.local/state/omarchy/current/theme/btop.theme" ~/.config/btop/themes/current.theme
