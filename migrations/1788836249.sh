echo "Enable whatsapp:// links in the WhatsApp web app"

whatsapp_desktop="$HOME/.local/share/applications/WhatsApp.desktop"

if [[ -f $whatsapp_desktop ]]; then
  cp "$OMARCHY_PATH/applications/WhatsApp.desktop" "$whatsapp_desktop"
  update-desktop-database "$HOME/.local/share/applications"
fi
