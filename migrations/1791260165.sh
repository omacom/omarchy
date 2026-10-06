echo "Let VPN connections use their own DNS while a DNS provider is selected"

# Older omarchy-dns pinned the provider with a NetworkManager [global-dns]
# drop-in, which overrides the DNS a VPN pushes. Retire it and install the
# dispatcher hook that pins the provider on new profiles instead.
conf=/etc/NetworkManager/conf.d/20-omarchy-dns.conf
[[ -f $conf ]] || exit 0

sudo rm -f "$conf"
sudo ln -sfn /usr/bin/omarchy-dns-dispatch /etc/NetworkManager/dispatcher.d/90-omarchy-dns
sudo nmcli general reload conf
sudo nmcli general reload dns-full
