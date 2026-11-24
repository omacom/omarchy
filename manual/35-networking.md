# Networking

Networking in Omarchy is handled by NetworkManager, and you drive it from the network icon in the [top bar](05-the-top-bar.md) or with `Super + Ctrl + N`.

That panel scans for Wi-Fi networks, shows signal strength, and connects. Ethernet needs nothing at all — plug it in and it works. If you'd rather stay in the terminal, `nmtui` gives you the same controls, and there's an `omarchy network` command group too.

## Sharing your Wi-Fi

Rather than reading a long password out loud, run _Setup > Network > QR Code_ while you're on Wi-Fi. That puts a QR code on screen that any phone camera can scan to join. It's one of those things you'll use more than you'd expect once you know it's there.

If you actually need the password itself, `omarchy network password <interface>` prints it.

## DNS

Omarchy uses whatever DNS your network hands out over DHCP. You can override that for the whole machine under _Setup > Network > DNS_, where Cloudflare and Google are one click away. Pick _Custom_ to type in your own servers.

From the terminal, `omarchy dns` prints the current provider and `omarchy dns Cloudflare` sets one.

## Pinning the Wi-Fi band

If your router puts 2.4GHz, 5GHz, and 6GHz on the same network name, your laptop will sometimes cling to the slow one. `omarchy network band` shows which band you're on, and `omarchy network band 5` pins it. Use `auto` to let it choose again.

This pins the band rather than a specific access point, so you keep roaming between APs normally.

## How fast is it?

_Trigger > Speed Test > Network Speed Test_ measures your actual up and down speed with a pair of dials. From the terminal it's `omarchy network speedtest down` or `up`. It measures against Omarchy's own service and counts only its test transfers. Other downloads can compete for bandwidth, but they aren't added to the speed-test result. (There's a disk speed test sitting next to it in that menu, if you're benchmarking the other bottleneck.)

## The firewall

The firewall is on by default and blocks all incoming traffic, with one exception: port 53317, so [LocalSend](22-guis.md) works out of the box.

SSH is off until you turn it on with _Setup > Security > SSHD_, which starts the daemon, opens port 22 rate-limited against brute force, and authorizes a key. Docker is locked down too, so containers can't accidentally expose themselves to the world. See [security](48-security.md) for the whole story.

## VPN

VPNs you set up in NetworkManager show up in the network panel under _VPN_: up front while you're connected, and at the bottom of the panel, past the Wi-Fi networks, while you aren't. A long list scrolls, and so does the panel on a short screen. Click one to connect it, and again to disconnect it or to call off a connect that's taking too long. While a VPN is up, the network icon in the bar gets a lock, and hovering it names the VPN.

WireGuard works out of the box: `nmcli connection import type wireguard file wg0.conf` brings in a config. For OpenVPN, install the plugin with `omarchy pkg add networkmanager-openvpn`, then `nmcli connection import type openvpn file work.ovpn`. If the profile has no user name yet, or doesn't keep its password, the row asks for them right in the panel; a new user name is saved to the profile, the password is used for that connection only. Anything else a VPN needs to ask (a certificate password, a one-time code) opens a terminal that asks for it.

[Tailscale](#tailscale) is listed there too while its bar widget is on the bar and Tailscale is running. Clicking it opens the Tailscale widget, which connects, signs in and picks exit nodes; if Tailscale needs you to sign in, the sign-in page opens in your browser as well. When Tailscale only takes orders from root, the widget asks for your password once to make you its operator, then carries on. It only puts the lock on the icon while an exit node carries your traffic, since without one it reaches just your own machines.

## Tailscale

[Tailscale](https://tailscale.com/) is a mesh VPN that makes reaching all your computers and servers over the internet simple and secure. Install it with _Install > Service > Tailscale_.

That gives you a Tailscale panel in the bar, which connects and disconnects the tailnet, switches accounts, and picks an exit node — your own machines and Mullvad regions both show up in the list. It also browses your machines, and that's where Taildrop lives: select a machine and press `s` to send it files, or `c`, `n`, and `d` to copy its IP, name, or full DNS name. The terminal equivalent is `omarchy tailscale send <machine> [file...]`, and files sent to you land in `~/Downloads` automatically. The notification announcing an arrival waits until you click it open or dismiss it, so a file that turns up while you're away from the machine is still there to answer when you get back.

Installing it also adds a web app for the Tailscale admin console.

## When it stops working

Before rebooting, try restarting the offending piece on its own. _Update > Hardware_ has Wi-Fi, Bluetooth, Audio, and Trackpad, and reloading one of those clears up most "it worked five minutes ago" situations. See [troubleshooting](45-troubleshooting.md).
