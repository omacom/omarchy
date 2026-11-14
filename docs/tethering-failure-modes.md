# Tethering and forwarding failure modes

When Omarchy forwards packets for another device — a hotspot, a shared connection, any NAT setup — a configuration that looks correct can fail in ways that present as "the network is broken". Each failure below has a distinct signature, and all of them leave the forwarding host's own connectivity working, which is what makes them confusing.

Nothing here is specific to Omarchy. It is collected because the shell, the network widget and any future sharing feature sit directly on top of it, and because every one of these costs hours to diagnose from scratch.

## Local delivery and forwarding are not the same path

A packet addressed to the host is delivered locally and its TTL is not touched. A packet addressed to a third party is forwarded, and `ip_forward` decrements the TTL before it leaves. Everything on this page exploits that difference: DHCP, DNS and the host's own browsing keep working while forwarded traffic dies.

That is the first thing to check when a shared connection "has internet" for the host but not for its guests.

## Uplinks that clamp TTL

Some uplinks — mobile carriers and phone hotspots are the common ones — hand inbound packets a TTL of 1, so that a tethered machine cannot forward them onward. The clamp is invisible to the host, because local delivery never decrements the TTL.

The signature is the kernel answering every reply with `ICMP time-exceeded` a few hundred microseconds after the reply arrives. Nothing in a firewall counter explains it, and no rule change fixes it.

| Observation | Value |
| --- | --- |
| Guests | get DHCP, resolve DNS, cannot reach the internet |
| Host | fully connected, browsing works |
| `tcpdump` on the uplink | SYN-ACK arrives, then `ICMP time exceeded in-transit` from the host, tens of microseconds later |
| SYN-ACK TTL | 1, from every server, including ones the host talks to itself |

The fix is to restore the TTL after de-NAT and before the forwarding decrement, which is the prerouting hook that runs after the NAT hook and before routing:

```
chain ttlfix {
  type filter hook prerouting priority -50; policy accept;
  iifname "wlp2s0" ip daddr 10.42.0.0/24 ip ttl set 64
}
```

Priority matters: de-NAT happens at `dstnat + 10`, so `-50` sees the guest's address rather than the host's. Setting the TTL earlier would miss the translated packets; setting it later is too late, because the decrement has already happened.

## Path MTU below 1500

Many uplinks carry overhead that reduces the usable MTU to 1492. A forwarding host that advertises 1500 tells guests their segments may be 1460 bytes of payload, which produces 1500-byte packets that the uplink silently drops.

The signature is that the failure is **size-dependent, not destination-dependent**: page loads and API calls work, file downloads and media transfers hang.

Path MTU discovery does not save the guests. The `fragmentation needed` ICMP is generated for the NATed host address, and it is either filtered or meaningless to a guest behind its own NAT.

| Check | Command |
| --- | --- |
| Real path MTU | `ping -M do -s 1464 1.1.1.1` (1464 + 28 = 1492) |
| Cached MTU | `ip route get 1.1.1.1` shows `mtu 1492` |
| Guest segments | `tcpdump -i <ap> -n -vv 'tcp[tcpflags] & (tcp-syn) != 0'` shows `mss 1460` |

The fix is threefold and should be automatic: probe the real MTU at start, set the shared interface's MTU to it, tell DHCP clients via option 26, and clamp TCP MSS to `MTU - 40` on forwarded SYNs.

```
tcp flags & syn == syn tcp option maxseg size set 1452
```

That rule must be the **first** rule in a filter chain, because nftables stops evaluating a chain at `accept`; placed after the accept rules it never runs.

## DHCP is broadcast, so address-scoped rules miss it

`DHCPDISCOVER` is sent to `255.255.255.255` from a host with no address yet. A firewall rule written as "allow UDP/67 to the gateway address" therefore never matches, the request falls through to the default deny, and guests sit at "obtaining IP address" forever.

The rule must match the interface and port only:

```
ufw allow in on <ap> to any port 67 proto udp
```

Also note that `ufw allow in on <ap> port 67` is not valid syntax — it needs `to any port` — and ufw reports success either way when its output is discarded.

## A dropped FORWARD policy ahead of your accept

On a machine that has ever run Docker, the `FORWARD` chain carries `policy drop`, installed by Docker and left behind even when Docker is inactive. A drop in an earlier base chain is final, so a higher-priority chain that would have accepted the traffic never gets a vote. The symptom is a forward counter that stays at zero while `tcpdump` shows the packets arriving.

Check for it before blaming the network:

```
nft list ruleset | grep -B2 'hook forward'
```

Two forward base chains with `policy drop` and one accept chain at a higher priority means the accepts lose. Insert the required accepts at the top of that chain, or accept that forwarding will never work on that machine.

## Diagnosing in order

1. Does the forwarding host itself have internet? If not, stop.
2. Do guests get a lease? If not, DHCP is not reaching the server — check broadcast handling and the input chain.
3. Does DNS resolve for guests? If not, the DNS path is blocked, not the forwarding path.
4. Does a small request succeed but a large one hang? Then it is MTU and MSS.
5. Does every reply arrive and vanish? Then look for `ICMP time-exceeded`, which is the TTL clamp.
6. Do new flows start but never establish, with counters at zero? Check for an earlier base chain dropping.

Counter resets are a trap: `nft` counters reset when a table is reloaded, so compare counters taken at the same moment, and remember that NAT chains are only consulted for the first packet of a flow, which makes masquerade counters look far smaller than forward counters.
