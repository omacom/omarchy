echo "Let VPN connections use their own DNS while a DNS provider is selected"

# Older omarchy-dns pinned the provider with a NetworkManager [global-dns]
# drop-in, which overrides the DNS a VPN pushes. Retire it and install the
# dispatcher hook that pins the provider on new profiles instead. The hook goes
# in first so a run that stops partway still finds the drop-in and retries.
conf=/etc/NetworkManager/conf.d/20-omarchy-dns.conf
hook=/etc/NetworkManager/dispatcher.d/90-omarchy-dns

if [[ ! -f $conf ]] && { [[ -L $hook ]] || [[ $(omarchy-dns) == "DHCP" ]]; }; then
  exit 0
fi

sudo ln -sfn /usr/bin/omarchy-dns-dispatch "$hook"
sudo rm -f "$conf"
sudo nmcli general reload conf
sudo nmcli general reload dns-full
