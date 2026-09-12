# CML Live Network Baseline — R1/R2/SW1/SW2

**Collection method:** pyATS/Genie structured show commands via the private four-device CML inventory (management addresses 10.10.20.171–174). Editorial review corrected an inherited example hostname and clarified counts and sampling limits.
**Report generated:** 2026-09-10 11:37 EDT (2026-09-10T15:37:08Z)

## Collection Timeline

Two distinct collection passes make up this report:

| Pass | Window (UTC) | Scope | Notes |
|---|---|---|---|
| **Prior run** | 2026-09-10 15:28:20Z – 15:34:53Z | 14 commands across R1, R2, SW1, SW2 | Sequential collection, retried after MCP_CALL client startup timeouts on the first attempt(s) for several commands; all 14 shown here completed successfully. The run itself timed out before its report-writing step, so results were captured to `cml-collected-tool-results.json` instead. |
| **Fresh verification** | 2026-09-10 15:37 UTC (minute precision) | R1 + R2 `show ip ospf neighbor` (2 concurrent calls) | Re-run just prior to this report to confirm OSPF adjacency is still current and FULL, not stale from the prior pass. |

Device measurements below are sourced from real output; topology and protocol explanations also use the authorized lab configuration. Serial numbers and licensing identifiers are withheld.

---

## R1 — Platform & Version

- **Hostname:** R1
- **Platform:** IOS-XE IOL (`X86_64BI_LINUX-ADVENTERPRISEK9-M`), OS family IOS, Linux-hosted image
- **Version:** 17.15.1 (17.15), RELEASE SOFTWARE (fc4)
- **Compiled:** Sun 11-Aug-24 22:07
- **Uptime at capture:** 21 minutes
- **Last reload reason:** Unknown reason
- **Interfaces:** 4 Ethernet
- *(chassis serial and flash/licensing identifiers withheld)*

## R1 — Interfaces (compact)

| Interface | IP Address | Status | Protocol |
|---|---|---|---|
| Ethernet0/0 | unassigned (trunk parent) | up | up |
| Ethernet0/0.10 | 10.100.10.1 | up | up |
| Ethernet0/0.20 | 10.100.20.1 | up | up |
| Ethernet0/0.999 | unassigned (native) | up | up |
| Ethernet0/1 | 10.255.255.0 | up | up |
| Ethernet0/2 | 10.10.20.171 | up | up |
| Ethernet0/3 | unassigned | admin down | down |
| Loopback0 | 10.255.0.1 | up | up |

**Counts:** 8 interfaces total — 7 up/up (including the unnumbered trunk parent), 1 administratively down. 0 in a down/down (non-admin) state.

---

## OSPF Adjacency — R1 ↔ R2 (verified live, this pass)

| Device | Local Interface | Neighbor RID | Neighbor Addr | State | Dead Timer |
|---|---|---|---|---|---|
| R1 | Ethernet0/1 | 10.255.0.2 | 10.255.255.1 | **FULL/ -** | 00:00:31 |
| R2 | Ethernet0/1 | 10.255.0.1 | 10.255.255.0 | **FULL/ -** | 00:00:35 |

Both sides independently confirm **FULL** state on the R1–R2 point-to-point backbone link (10.255.255.0/31-style transit) at capture time. This is a live re-check, run concurrently, superseding the prior pass's OSPF snapshot (which also showed FULL, at 15:29:15Z / 15:34:29Z respectively).

---

## BGP — iBGP Peering (AS 65000)

| Local Router | RID | Peer | Peer AS | State/PfxRcd | Up/Down | Msgs Rcvd/Sent |
|---|---|---|---|---|---|---|
| R1 | 10.255.0.1 | 10.255.0.2 | 65000 | 2 (Established) | 00:05:44 | 10 / 10 |
| R2 | 10.255.0.2 | 10.255.0.1 | 65000 | 2 (Established) | 00:07:38 | 12 / 12 |

**BGP-learned routes:**

| Route | Learned By | Next Hop | Age |
|---|---|---|---|
| 10.100.30.0/24 | R1 | 10.255.0.2 | 00:05:16 |
| 10.100.40.0/24 | R1 | 10.255.0.2 | 00:05:16 |
| 10.100.10.0/24 | R2 | 10.255.0.1 | 00:07:06 |
| 10.100.20.0/24 | R2 | 10.255.0.1 | 00:07:06 |

iBGP over the OSPF-reachable loopbacks is exchanging each router's local VLAN subnets — R1 advertises 10.100.10.0/24 and 10.100.20.0/24 (SW1's VLAN10/20), R2 advertises 10.100.30.0/24 and 10.100.40.0/24 (SW2's VLAN30/40). 2 prefixes received on each side, consistent with a healthy two-router iBGP mesh.

---

## Switching — SW1 (VLAN 10/20 side) & SW2 (VLAN 30/40 side)

| Switch | Trunk Port | Encapsulation | Status | Native VLAN | Allowed VLANs | STP Mode | Root For |
|---|---|---|---|---|---|---|---|
| SW1 | Ethernet0/2 | 802.1q | trunking | 999 | 10, 20, 999 | Rapid-PVST+ | VLAN0010, VLAN0020, VLAN0999 |
| SW2 | Ethernet0/2 | 802.1q | trunking | 999 | 30, 40, 999 | Rapid-PVST+ | VLAN0030, VLAN0040, VLAN0999 |

Both switches are STP root for all VLANs they carry, with 0 blocking/listening/learning ports on either — each shows 5 forwarding, 5 STP-active ports across 3 VLANs. This snapshot establishes the displayed forwarding state; it does not measure stability over time.

**Note:** the SW1/SW2 trunks each terminate locally at their own router (SW1↔R1, SW2↔R2). No direct SW1↔SW2 inter-switch data link was tested or is claimed in this topology — R1↔R2 connectivity is via OSPF/iBGP over Ethernet0/1, not via a switched path.

---

## DHCP Leases (4 total, all Active/Automatic)

| Router | Interface (VLAN) | Leased IP | Client ID | Expiration |
|---|---|---|---|---|
| R1 | Ethernet0/0.10 (VLAN10) | 10.100.10.100 | 0152.5400.1991.53 | Sep 11 2026 03:23 PM |
| R1 | Ethernet0/0.20 (VLAN20) | 10.100.20.100 | 0152.5400.0b00.ab | Sep 11 2026 03:23 PM |
| R2 | Ethernet0/0.30 (VLAN30) | 10.100.30.100 | 0152.5400.1293.4a | Sep 11 2026 03:24 PM |
| R2 | Ethernet0/0.40 (VLAN40) | 10.100.40.100 | 0152.5400.0e94.5c | Sep 11 2026 03:23 PM |

Each router hands out addresses for its own pair of subinterface VLANs; all four displayed leases are active and automatic.

---

## Summary

- **OSPF:** R1↔R2 adjacency FULL, confirmed by a fresh concurrent recheck at report time — not stale.
- **BGP:** iBGP session Established both directions, each side has received the other's 2 local VLAN subnets (4 routes total in the network).
- **Switching:** SW1 and SW2 both trunking cleanly, native VLAN 999, Rapid-PVST+ with no blocked ports; each switch is local to its own router only.
- **DHCP:** 4 active leases, one per VLAN (10/20 on R1, 30/40 on R2).
- **Platform:** R1 running IOS-XE 17.15.1 on IOL, 21 minutes uptime at prior-pass capture.

No configuration changes were made or proposed during this collection.
