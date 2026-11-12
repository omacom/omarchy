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
# A home adopted from another drive keeps its own Pi theme and Qt settings.
adopted_record=$HOME/.local/state/omarchy/adopted-home
if [[ ${OMARCHY_ADOPTED_HOME:-0} != "1" || ! -e $HOME/.pi/agent/settings.json ]]; then
  omarchy-theme-set-pi --activate
fi
omarchy-theme-set-fcitx5 --activate
# A headless theme set skips the retints, so the seeded config would keep its
# default icon theme until the first switch.
if [[ ${OMARCHY_ADOPTED_HOME:-0} != "1" ]] || ! grep -qx 'kept .config/qtengine/config.json' "$adopted_record" 2>/dev/null; then
  omarchy-theme-set-qt
fi

mkdir -p ~/.config/btop/themes
[[ ${OMARCHY_ADOPTED_HOME:-0} == "1" && -e ~/.config/btop/themes/current.theme ]] ||
  ln -snf "$HOME/.local/state/omarchy/current/theme/btop.theme" ~/.config/btop/themes/current.theme
