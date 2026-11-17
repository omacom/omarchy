# Tethering and forwarding failure modes

When Omarchy forwards packets for another device — a hotspot, a shared connection, any NAT setup — a configuration that looks correct can fail in ways that present as "the network is broken". Each failure below has a distinct signature, and all of them leave the forwarding host's own connectivity working, which is what makes them confusing.

Nothing here is specific to Omarchy. It is collected because the shell, the network widget and any future sharing feature sit directly on top of it, and because every one of these costs hours to diagnose from scratch.

## Local delivery and forwarding are not the same path

A packet addressed to the host is delivered locally and its TTL is not touched. A packet addressed to a third party is forwarded, and `ip_forward` decrements the TTL before it leaves. That difference is why the host's own browsing keeps working while forwarded traffic dies, and why DHCP and DNS keep answering guests when the host serves them itself.

That is the first thing to check when a shared connection "has internet" for the host but not for its guests.

## Uplinks that clamp TTL

Some uplinks — mobile carriers and phone hotspots are the common ones — hand inbound packets a TTL of 1, so that a tethered machine cannot forward them onward. The clamp is invisible to the host, because local delivery never decrements the TTL.

The signature is the kernel answering replies with `ICMP time-exceeded` the moment they arrive (it rate-limits these, so not necessarily every one). No accept or drop rule explains it or fixes it; only rewriting the TTL, below, does.

| Observation | Value |
| --- | --- |
| Guests | get DHCP, resolve DNS, cannot reach the internet |
| Host | fully connected, browsing works |
| `tcpdump` on the uplink | SYN-ACK arrives, immediately followed by `ICMP time exceeded in-transit` from the host |
| SYN-ACK TTL | 1, from every server, including ones the host talks to itself |

The fix is to restore the TTL after de-NAT and before the forwarding TTL check, which means a prerouting chain that runs after NAT, with `<uplink>` and `10.42.0.0/24` replaced by the uplink interface and the guests' subnet:

```
chain ttlfix {
  type filter hook prerouting priority -50; policy accept;
  iifname "<uplink>" ip daddr 10.42.0.0/24 ip ttl set 64
}
```

Priority matters: replies are de-NATed at `dstnat` (-100), so a chain at `-50` sees the guest's address rather than the host's. A chain before `-100` would miss the translated packets. Any later prerouting priority also works, because the kernel checks and decrements the TTL in forwarding, after routing and before the forward hook, which is why a chain on the forward hook is too late.

## Path MTU below 1500

Some uplinks carry overhead that reduces the usable MTU below 1500; PPPoE's 1492 is the common case and the one used below. Guests on a 1500-byte link advertise an MSS of 1460, so the far end sends them 1500-byte packets that do not fit the uplink.

The signature is that the failure follows **size**: page loads and API calls work, file downloads and media transfers hang, sometimes only to some destinations, since each path has its own MTU.

Path MTU discovery is meant to handle this: the hop that cannot fit a packet returns `fragmentation needed`, and conntrack relates that error to the guest's flow and translates it through the NAT. It fails when that ICMP is filtered anywhere on the path, which is common enough that clamping the MSS is the dependable fix.

| Check | Command |
| --- | --- |
| 1492 fits the path | `ping -M do -s 1464 1.1.1.1` (1464 + 28 = 1492) |
| Learned MTU | `ip route get 1.1.1.1` shows `mtu 1492` once the kernel has cached it |
| Guest segments | `tcpdump -i <ap> -n -vv 'tcp[tcpflags] & (tcp-syn) != 0'` shows `mss 1460` |

The fix should be automatic: probe the real MTU at start, set the shared interface's MTU to it, tell DHCP clients via option 26, and clamp TCP MSS on forwarded SYNs to `MTU - 40` (IPv4; `MTU - 60` for IPv6).

```
tcp flags & syn == syn tcp option maxseg size set 1452
```

That rule must come **before** any rule in its chain that accepts the SYN, because an `accept` ends evaluation of that chain; placed after one, it never runs.

## DHCP is broadcast, so address-scoped rules miss it

`DHCPDISCOVER` is sent to `255.255.255.255` from a host with no address yet. A firewall rule written as "allow UDP/67 to the gateway address" therefore never matches, the request falls through to the default deny, and guests sit at "obtaining IP address" forever.

The rule must match the interface and port only:

```
ufw allow in on <ap> to any port 67 proto udp
```

Also note that `ufw allow in on <ap> port 67` is not valid syntax — it needs `to any port`. ufw rejects it with `Need 'from' or 'to' with 'port'` and exits 1, so a script that discards ufw's output must check its exit status, or it will not notice the rule was never added.

## A dropped FORWARD policy ahead of your accept

On Omarchy the `FORWARD` chain carries `policy drop` from the start: Omarchy enables ufw, whose `DEFAULT_FORWARD_POLICY` in `/etc/default/ufw` is `DROP`, and Docker can install the same policy when it enables IP forwarding. Every base chain on the forward hook gets a say, in ascending priority order: an `accept` ends only the chain it is in, while a drop in any chain is final. So a chain of your own that accepts the traffic cannot override one that drops it, whichever runs first. When the dropping chain runs first, the symptom is your chain's counter staying at zero while `tcpdump` shows the packets arriving.

Check for it before blaming the network:

```
nft list ruleset | grep -B2 'hook forward'
```

Every forward base chain that would drop the traffic has to accept it itself, ahead of the rule or policy that drops it; an accept in another chain changes nothing for it. For ufw's chains that is `ufw route allow in on <ap> out <uplink>`. Remove a stale chain only after confirming nothing needs it.

## Diagnosing in order

1. Does the forwarding host itself have internet? If not, stop.
2. Do guests get a lease? If not, check that the DHCP server is running and that broadcasts reach it through the input chain.
3. Does DNS resolve for guests? If not, and the host is their resolver, the DNS path is blocked rather than the forwarding path; a guest using an outside resolver sends DNS as forwarded traffic like any other.
4. Does a small request succeed but a large one hang? Then suspect MTU and MSS.
5. Does every reply arrive and vanish? Then look for `ICMP time-exceeded`, which is the TTL clamp.
6. Do new flows start but never establish, with counters at zero? Check for another base chain dropping.

Counter resets are a trap: `nft` counters reset when a table is reloaded, so compare changes over the same interval since the last reload, and remember that NAT chains are only consulted for the first packet of a flow, which makes masquerade counters look far smaller than forward counters.
