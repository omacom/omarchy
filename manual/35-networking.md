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

## VPNs

Every VPN NetworkManager knows about — WireGuard, OpenVPN, OpenConnect, and the rest — shows up in the VPN section of the network panel with three buttons:

- _Off_ disconnects it.
- _Split_ connects it, but only the VPN's own networks go through it. The rest of your traffic goes out the way it always does, which is what you want for reaching the office without routing your video calls through it.
- _Full_ sends all your traffic through it. Only one VPN can be in _Full_ at a time; switching another one to _Full_ drops the first back to _Split_ once the new one is connected. A WireGuard VPN only offers _Full_ when its config allows all traffic (`AllowedIPs = 0.0.0.0/0`), since the server decides what it will carry. If it doesn't also allow `::/0`, _Full_ blocks IPv6 so nothing leaves outside the VPN; sites still load over IPv4.

The choice is stored in the VPN's own NetworkManager profile, so `nmcli` and any other NetworkManager tool see the same thing. A small dot on the network icon tells you a VPN is up, and hovering it names which one.

If a VPN needs a password or a one-time code, a terminal opens to ask for it, and the row offers _Sign in_ until it connects.

To add one, click _Add VPN_ and import the config file your provider gave you: a WireGuard `.conf` or an OpenVPN `.ovpn` (Omarchy installs the OpenVPN add-on the first time you need it). Imported VPNs start off, so nothing reroutes until you say so. _New WireGuard connection_ opens `nmtui` to type the details in by hand. From the terminal, `omarchy network vpn` lists them, `omarchy network vpn mode <uuid> split` switches one, and `omarchy network vpn import <file>` adds one.

## Tailscale

[Tailscale](https://tailscale.com/) is a mesh VPN that makes reaching all your computers and servers over the internet simple and secure. Install it with _Install > Service > Tailscale_.

That gives you a Tailscale panel in the bar, which connects and disconnects the tailnet, switches accounts, and picks an exit node — your own machines and Mullvad regions both show up in the list. It also browses your machines, and that's where Taildrop lives: select a machine and press `s` to send it files, or `c`, `n`, and `d` to copy its IP, name, or full DNS name. The terminal equivalent is `omarchy tailscale send <machine> [file...]`, and files sent to you land in `~/Downloads` automatically. The notification announcing an arrival waits until you click it open or dismiss it, so a file that turns up while you're away from the machine is still there to answer when you get back.

Installing it also adds a web app for the Tailscale admin console.

## When it stops working

Before rebooting, try restarting the offending piece on its own. _Update > Hardware_ has Wi-Fi, Bluetooth, Audio, and Trackpad, and reloading one of those clears up most "it worked five minutes ago" situations. See [troubleshooting](45-troubleshooting.md).
