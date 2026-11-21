# Pair this model's vendor-zero SPI keyboard with the internal touchpad for
# libinput disable-while-typing. Personal /etc/libinput overrides take priority.
product_name=$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)

if [[ $product_name == "MacBookPro13,3" ]]; then
  echo "Marking the MacBookPro13,3 SPI keyboard as internal for libinput"
  sudo install -Dm644 "$OMARCHY_PATH/default/libinput/99-omarchy-macbookpro13-3.quirks" \
    /usr/share/libinput/99-omarchy-macbookpro13-3.quirks
fi
