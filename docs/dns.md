# DNS provider selection

`omarchy dns Cloudflare`, `Google`, and `Custom` select upstream servers for NetworkManager-managed ordinary network links. `omarchy dns DHCP` removes the selection and restores each active connection's own DNS settings, including manually configured DNS. The name DHCP is retained for compatibility; it does not erase static DNS or force a DHCP lease renewal.

## Why per-link DNS

Investigation for [PR #8908](https://github.com/omacom/omarchy/pull/8908) found two different problems. Reapplying a connection after changing its DNS settings can restart DHCP, and NetworkManager's `systemd-resolved` backend does not apply its global DNS override to resolved's per-link server lists. Writing `DNS=` into resolved's global configuration also leaves per-link DNS eligible for queries.

The latter was reproduced with NetworkManager 1.58.1 and systemd 261.3 in an isolated network namespace: adding `[global-dns-domain-*]` and reloading DNS left the connection's original upstream in use. Changing the live resolved link changed the server actually answering queries. Reloading NetworkManager's DNS restored the original link configuration without reapplying the connection. The upstream implementation is in [nm-dns-systemd-resolved.c](https://github.com/NetworkManager/NetworkManager/blob/1.58.1/src/core/dns/nm-dns-systemd-resolved.c); its `update()` accepts `global_config` but constructs link updates from the connection data.

## Other distributions and upstream guidance

| Approach | What it establishes | Decision for Omarchy |
| --- | --- | --- |
| [Fedora's resolved integration](https://fedoramagazine.org/systemd-resolved-introduction-to-split-dns/) | NetworkManager supplies per-link DNS and domain routing; the most specific domain wins. | Preserve those routing decisions and change only eligible ordinary links' live upstreams. |
| [Ubuntu's network configuration](https://ubuntu.com/server/docs/explanation/networking/configuring-networks/) | Persistent nameservers belong to per-interface Netplan configuration; `resolvectl` manages runtime resolved state. | Separate the temporary provider override from saved connection profiles. |
| [RHEL DNS priorities](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/configuring_and_managing_networking/configuring-the-order-of-dns-servers) | VPN and ordinary DNS have different priorities; negative priorities can exclude other DNS configurations. | Keep NetworkManager's computed domains and default-route flags, including suppressed links. |
| [ArchWiki resolved configuration](https://wiki.archlinux.org/title/Systemd-resolved) | Global DNS can be routed with `Domains=~.`; specific per-link domains still take precedence. | Avoid a new global `~.` route, which can compete with a privacy VPN's equally specific route. |
| [Fedora's optional dnsconfd/Unbound setup](https://fedoramagazine.org/enabling-system-wide-dns-over-tls/) | An exclusive global resolver policy is available through a different NetworkManager backend and resolver service. | Keep Omarchy's existing resolver stack; replacing it entails a separate packaging, VPN, and boot integration project. |

These distributions do not all implement an identical global provider selector. Omarchy's runtime overlay is a design choice based on their per-network configuration model and [systemd's VPN guidance](https://github.com/systemd/systemd/blob/main/docs/RESOLVED-VPNS.md), not a claim that another distribution ships this helper.

## Implementation and lifetime

The root-owned selection lives in `/etc/omarchy/dns.json`. The helper at `/usr/share/omarchy/default/dns/dns.py` uses the existing Python/GObject runtime and the NetworkManager/resolved D-Bus APIs. The command and lifecycle hooks invoke `/usr/bin/python3 -I` with that fixed packaged path. Privileged code does not load from a user's development checkout or Python environment.

Only active, NetworkManager-managed ordinary links are eligible. VPN, WireGuard, tun/tap, unmanaged, and externally assumed connections are excluded. The helper preserves search domains, routing domains, DNSSEC, and DNS-over-TLS. A default uplink without any native DNS receives a default DNS route, unless negative DNS priorities forbid it. Links suppressed by NetworkManager's routing decisions remain suppressed.

The [NetworkManager dispatcher](https://networkmanager.dev/docs/api/latest/NetworkManager-dispatcher.html) reapplies the policy after DNS updates, reconnects, DHCP renewals, and VPN changes. A `pre-up` hook also applies it before NetworkManager reports a connection fully activated. Hooks read current state because queued dispatcher events can be stale. The resolved `ExecStartPost` hook asks NetworkManager to republish DNS before applying the selection after a resolver restart. At early boot NetworkManager may not be running yet; this hook is allowed to fail without stopping resolved, and the subsequent network activation applies the selection.

DHCP removes only Omarchy's selection, then calls NetworkManager's DNS-only reload. There are no connection writes, `Device.Reapply` calls, or network service restarts. Concurrent helper invocations are serialized. Policy writes are atomic. A failed explicit selection restores the preceding files and asks NetworkManager to restore DNS, then reapplies the preceding selection if one existed. Recovery failures are reported rather than hidden.

On an explicit provider selection, exact legacy Omarchy global configuration is backed up in `/var/lib/omarchy/dns-backup/` and its global server directives removed. Existing encryption settings are retained. Unrecognized configuration is preserved; conflicting global DNS produces an error and rollback. Old per-profile values have no ownership marker and are never guessed away. Upgrading the package alone does not rewrite existing resolver configuration; selecting a provider opts into the new behavior.

The helper and hooks ship in `omarchy-settings`, alongside the updated command in `omarchy`; install matching packages. No new resolver service or daemon is introduced.

## Behavior and limits

- VPN DNS follows its existing routing policy. A split VPN continues to answer its private domains; a privacy VPN with `~.` handles general queries. The menu's provider describes the ordinary-link preference, not a guarantee that every query bypasses VPN DNS.
- Choosing a public provider replaces ordinary links' local DNS at runtime. Router-only names, captive portals, or networks that block public resolvers may require selecting DHCP. Saved static DNS is restored intact.
- DNS-over-TLS is controlled by the existing network/resolver policy. Presets supply their TLS server names, but selecting a provider no longer turns opportunistic encryption on globally or turns enforced encryption off. Custom accepts literal IPv4/IPv6 addresses, with whitespace or comma separators; it does not accept URLs, ports, or interface suffixes.
- Dispatcher-based reapplication is asynchronous after some network changes. This is a DNS preference, not a firewall or a guarantee against every transient DNS leak. Applications using their own DoH resolver bypass the system choice.
- The supported stack is NetworkManager with `dns=systemd-resolved`. An independently customized DNS backend or competing global DNS requires explicit reconciliation rather than silent overwrites.

## Verification

Run the portable policy/security tests with:

```bash
bash test/shell.d/dns-policy-test.sh
bash test/shell.d/dns-sudoers-test.sh
```

During the PR investigation, a disposable network-namespace lab also verified actual IPv4/IPv6 DNS answers, saved-profile preservation, split DNS and WireGuard routing, reconnects, resolver restart, and DHCP lease renewal without a new transaction or address change. The lab was used for one-off validation; it is not part of the maintained test suite.

For release validation on a disposable Omarchy system, switch providers while watching `resolvectl status` and the NetworkManager DHCP journal. Confirm that a fresh lookup uses the selected provider, saved connection settings and the address stay unchanged, reconnecting retains the selection, and DHCP restores the connection's own DNS. With a VPN connected, also check private-domain resolution and its default DNS route. A full boot and physical Wi-Fi/VPN interoperability remain release-validation tasks.
