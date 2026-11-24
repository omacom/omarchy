# Networking

Networking in Omarchy is handled by NetworkManager, and you drive it from the network icon in the [top bar](05-the-top-bar.md) or with `Super + Ctrl + N`.

That panel scans for Wi-Fi networks, shows signal strength, and connects. Ethernet needs nothing at all — plug it in and it works. If you'd rather stay in the terminal, `nmtui` gives you the same controls, and there's an `omarchy network` command group too.

## Sharing your Wi-Fi

Rather than reading a long password out loud, run _Setup > Network > QR Code_ while you're on Wi-Fi. That puts a QR code on screen that any phone camera can scan to join. It's one of those things you'll use more than you'd expect once you know it's there.

If you actually need the password itself, `omarchy network password <interface>` prints it.

## DNS

Omarchy uses whatever DNS your network hands out over DHCP. You can override that for the whole machine under _Setup > Network > DNS_, where Cloudflare and Google are one click away. Pick _Custom_ to type in your own servers.

From the terminal, `omarchy dns` prints the current provider and `omarchy dns Cloudflare` sets one.

### Per-connection DNS profiles

If an office uses private DNS names, you can opt into saved profiles on the network panel. The system part requires NetworkManager 1.44 or later, systemd-resolved's stub resolver and the Python GObject bindings for libnm. Run the setup from a local terminal after recording any existing manual DNS settings. Installing it reloads DNS for the machine. A recognized Omarchy global DNS preset is backed up. The regular provider picker is the default on installations that have not opted in.

```sh
cd /usr/share/omarchy/shell/plugins/panels/network/profiles
sudo ./setup-system install
omarchy bar set omarchy.network connectionDnsProfiles true --json
```

Open the network panel and choose **Work**. Enter internal domains or individual hostnames separated by spaces, the DNS servers that answer them, and a public provider for other queries. For example, enter `corp.example admin.example.org` to route a private domain and one public-facing service name to office DNS. **Home** and **Home office** each remember a DNS provider. A VPN supplies its own private routes. **Automatic** uses the connection's network-supplied DNS. Settings are saved separately for each NetworkManager connection, and later selections apply without prompting.

Use **Edit DNS profiles** to change a saved choice. Edits to the active mode apply immediately. Other edits take effect when that mode is next selected. To check a result, run `resolvectl status` and `resolvectl query --cache=no your.internal.name`. If the panel shows limited access while sites work, compare the system lookup with `resolvectl -i INTERFACE query PROBE_HOST` for NetworkManager's configured connectivity-check hostname. On a split-DNS connection, you can add that hostname to the Work list if the internal DNS server can resolve it.

Work requires at least one internal DNS server whose IP family is enabled on the connection. If the panel no longer highlights Work after an IP family is disabled, open **Edit DNS profiles** and enter an internal resolver address for an enabled family.

To remove the integration, first select Automatic or restore the original DNS settings on each connection you changed. Run the following from the same directory. Removing the system integration restores the saved Omarchy global preset when present. Repeat the install step after an update that changes the dispatcher helper.

```sh
omarchy bar set omarchy.network connectionDnsProfiles false --json
sudo ./setup-system remove
```

## Pinning the Wi-Fi band

If your router puts 2.4GHz, 5GHz, and 6GHz on the same network name, your laptop will sometimes cling to the slow one. `omarchy network band` shows which band you're on, and `omarchy network band 5` pins it. Use `auto` to let it choose again.

This pins the band rather than a specific access point, so you keep roaming between APs normally.

## How fast is it?

_Trigger > Speed Test > Network Speed Test_ measures your actual up and down speed with a pair of dials. From the terminal it's `omarchy network speedtest down` or `up`. It measures against Omarchy's own service and counts only its test transfers. Other downloads can compete for bandwidth, but they aren't added to the speed-test result. (There's a disk speed test sitting next to it in that menu, if you're benchmarking the other bottleneck.)

## The firewall

The firewall is on by default and blocks all incoming traffic, with one exception: port 53317, so [LocalSend](22-guis.md) works out of the box.

SSH is off until you turn it on with _Setup > Security > SSHD_, which starts the daemon, opens port 22 rate-limited against brute force, and authorizes a key. Docker is locked down too, so containers can't accidentally expose themselves to the world. See [security](48-security.md) for the whole story.

## Tailscale

[Tailscale](https://tailscale.com/) is a mesh VPN that makes reaching all your computers and servers over the internet simple and secure. Install it with _Install > Service > Tailscale_.

That gives you a Tailscale panel in the bar, which connects and disconnects the tailnet, switches accounts, and picks an exit node — your own machines and Mullvad regions both show up in the list. It also browses your machines, and that's where Taildrop lives: select a machine and press `s` to send it files, or `c`, `n`, and `d` to copy its IP, name, or full DNS name. The terminal equivalent is `omarchy tailscale send <machine> [file...]`, and files sent to you land in `~/Downloads` automatically. The notification announcing an arrival waits until you click it open or dismiss it, so a file that turns up while you're away from the machine is still there to answer when you get back.

Installing it also adds a web app for the Tailscale admin console.

## When it stops working

Before rebooting, try restarting the offending piece on its own. _Update > Hardware_ has Wi-Fi, Bluetooth, Audio, and Trackpad, and reloading one of those clears up most "it worked five minutes ago" situations. See [troubleshooting](45-troubleshooting.md).
