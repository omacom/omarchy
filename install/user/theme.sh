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

# Terminal applications follow Omarchy by default while remaining free to use
# a different theme after installation.
for app in codex grok pi claude; do
  if ! omarchy-done check "theme-activate-$app"; then
    "omarchy-theme-set-$app" --activate
  fi
done
omarchy-theme-set-fcitx5 --activate

mkdir -p ~/.config/btop/themes
ln -snf "$HOME/.local/state/omarchy/current/theme/btop.theme" ~/.config/btop/themes/current.theme
