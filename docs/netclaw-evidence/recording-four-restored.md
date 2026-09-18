# Recording-Four Readiness Check (VPN Restored)

**Purpose:** Fresh, post-VPN-restoration readiness check via the actual pyATS MCP server —
no reuse of prior/older evidence. Read-only collection only; no configuration commands issued.

- **Testbed:** `omarchy-routing-lab` (`/home/netclaw/.config/netclaw/testbed.yaml`)
- **Collection method:** `pyats_list_devices` (inventory) + `pyats_pcall_show_command` (upstream pcall, one process per device)
- **Scope:** R1, R2, SW1, SW2 only. The retired `iosxe-sandbox` device is confirmed **not present** in this testbed.
- **Timeouts used:** configured long timeouts (MCP tool response ceiling 1800s / exec ceiling 2100s); both collections completed well under ceiling.
- **NetBox / ServiceNow:** intentionally **not queried** per operator instruction (screenshots complete, validation records already cleaned up).
- **Redaction:** chassis serial numbers and any licensing identifiers are withheld from this report.

---

## 1. Device Inventory (`pyats_list_devices`)

| Alias | OS | Type | Platform | Connection |
|---|---|---|---|---|
| R1 | iosxe | router | router | cli |
| R2 | iosxe | router | router | cli |
| SW1 | iosxe | switch | switch | cli |
| SW2 | iosxe | switch | switch | cli |

All four aliases resolved from live inventory discovery — matches the requested collection order (R1, R2, SW1, SW2).

---

## 2. Collection Timestamps (UTC)

| Command | Start | End | Duration |
|---|---|---|---|
| `show version` (pcall, 4 devices) | 2026-09-10T18:03:46Z | 2026-09-10T18:04:02Z | ~16s |
| `show ip interface brief` (pcall, 4 devices) | 2026-09-10T18:04:10Z | 2026-09-10T18:04:25Z | ~15s |

Collections were run sequentially (not concurrently against the same devices), per the omarchy collection runtime guidance.

---

## 3. `show version` Summary — Real Model / Software

| Device | OS | IOS-XE Version | Image ID | Platform/Location | Uptime | Compiled | Ethernet Interfaces |
|---|---|---|---|---|---|---|---|
| R1 | IOS | 17.15.1 | X86_64BI_LINUX-ADVENTERPRISEK9-M | IOSXE (router) | 2h 57m | Sun 11-Aug-24 22:07 | 4 |
| R2 | IOS | 17.15.1 | X86_64BI_LINUX-ADVENTERPRISEK9-M | IOSXE (router) | 2h 57m | Sun 11-Aug-24 22:07 | 4 |
| SW1 | IOS | 17.15.1 | X86_64BI_LINUX_L2-ADVENTERPRISEK9-M | IOSXE (switch) | 2h 57m | Sun 11-Aug-24 22:06 | 4 |
| SW2 | IOS | 17.15.1 | X86_64BI_LINUX_L2-ADVENTERPRISEK9-M | IOSXE (switch) | 2h 57m | Sun 11-Aug-24 22:06 | 4 |

*Chassis serial numbers and licensing/config-register identifiers withheld per sanitization requirement.*

Collection result: **4/4 succeeded, 0 failed** (`pcall` summary: total=4, success=4, failed=0).

---

## 4. `show ip interface brief` Summary — Interface Status Counts

| Device | Total Interfaces | up/up | admin-down/down | Other |
|---|---|---|---|---|
| R1 | 8 | 7 | 1 | 0 |
| R2 | 8 | 7 | 1 | 0 |
| SW1 | 5 | 4 | 1 | 0 |
| SW2 | 5 | 4 | 1 | 0 |

Collection result: **4/4 succeeded, 0 failed** (`pcall` summary: total=4, success=4, failed=0).

### R1 — Interface Detail

| Interface | IP Address | Status | Protocol |
|---|---|---|---|
| Ethernet0/0 | unassigned | up | up |
| Ethernet0/0.10 | 10.100.10.1 | up | up |
| Ethernet0/0.20 | 10.100.20.1 | up | up |
| Ethernet0/0.999 | unassigned | up | up |
| Ethernet0/1 | 10.255.255.0 | up | up |
| Ethernet0/2 | 10.10.20.171 | up | up |
| Ethernet0/3 | unassigned | administratively down | down |
| Loopback0 | 10.255.0.1 | up | up |

### R2 — Interface Detail

| Interface | IP Address | Status | Protocol |
|---|---|---|---|
| Ethernet0/0 | unassigned | up | up |
| Ethernet0/0.30 | 10.100.30.1 | up | up |
| Ethernet0/0.40 | 10.100.40.1 | up | up |
| Ethernet0/0.999 | unassigned | up | up |
| Ethernet0/1 | 10.255.255.1 | up | up |
| Ethernet0/2 | 10.10.20.172 | up | up |
| Ethernet0/3 | unassigned | administratively down | down |
| Loopback0 | 10.255.0.2 | up | up |

### SW1 — Interface Detail

| Interface | IP Address | Status | Protocol |
|---|---|---|---|
| Ethernet0/0 | unassigned | up | up |
| Ethernet0/1 | unassigned | up | up |
| Ethernet0/2 | unassigned | up | up |
| Ethernet0/3 | 10.10.20.173 | up | up |
| Loopback0 | unassigned | administratively down | down |

### SW2 — Interface Detail

| Interface | IP Address | Status | Protocol |
|---|---|---|---|
| Ethernet0/0 | unassigned | up | up |
| Ethernet0/1 | unassigned | up | up |
| Ethernet0/2 | unassigned | up | up |
| Ethernet0/3 | 10.10.20.174 | up | up |
| Loopback0 | unassigned | administratively down | down |

---

## 5. Readiness Verdict

| Check | Result |
|---|---|
| VPN / SSH reachability to all 4 devices | ✅ PASS — 4/4 connected via pcall |
| `show version` collection | ✅ PASS — 4/4 succeeded, 0 failed |
| `show ip interface brief` collection | ✅ PASS — 4/4 succeeded, 0 failed |
| Management interfaces (Ethernet0/2 on R1/R2, Ethernet0/3 on SW1/SW2) | ✅ up/up on all four |
| Retired `iosxe-sandbox` device | ✅ Confirmed absent from testbed — not queried |
| Configuration commands issued | None — read-only collection only |
| NetBox / ServiceNow queried or modified | None — intentionally skipped per operator instruction |

**Overall: READY.** All four devices (R1, R2, SW1, SW2) are reachable post-VPN-restoration, running consistent IOS-XE 17.15.1 software, with all core/management interfaces up/up and only the expected administratively-down interfaces (R1/R2 Ethernet0/3, SW1/SW2 Loopback0) present. No failures to preserve — both pcall collections returned a clean 4/4 success summary.

---

*Report generated by NetClaw. Source: live pyATS MCP (`pyats_list_devices`, `pyats_pcall_show_command`) against `omarchy-routing-lab` testbed. Serial numbers and licensing identifiers redacted.*
