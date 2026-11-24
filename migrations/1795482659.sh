echo "Shorten the Limine boot menu wait from 1 second to half a second"

# The shipped limine.conf waited a full second for a key press before booting.
# Half a second still lets any key press reveal the menu (quiet mode) and shaves
# 0.5s off every boot. Only the shipped value is changed; a timeout the user
# set themselves is left alone.

esp=$(sed -n 's/^ESP_PATH=["'\'']\?\([^"'\'']*\).*/\1/p' /etc/default/limine 2>/dev/null | tail -1)
esp=${esp:-/boot}
conf=$esp/limine.conf

if sudo grep -qx 'timeout: 1' "$conf" 2>/dev/null; then
  sudo sed -i 's/^timeout: 1$/timeout: 0.5/' "$conf"
fi
