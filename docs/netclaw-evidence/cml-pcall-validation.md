# CML pcall Validation — `pyats_pcall_show_command`

**Purpose:** Validate the upstream `pyats_pcall_show_command` MCP tool against the CML lab testbed by collecting two show commands across all four lab devices (R1, R2, SW1, SW2) in single batched pcall invocations — one call per command, four devices per call.

**Tool:** `pyats_pcall_show_command` via `$MCP_CALL` (Omarchy pyATS launcher)
**Testbed:** `$PYATS_TESTBED_PATH`
**Timeouts used:** exec timeoutSeconds 2100; MCP init allowance 180s; tool response allowance 1800s; connection/command allowance 300s (per skill defaults — not all consumed; both batches completed in seconds)
**Scope:** Read-only. No configuration commands issued.

---

## Batch 1 — `show ip interface brief`

- **Devices requested:** R1, R2, SW1, SW2 (single `device_names` list, one call)
- **Completion timestamp:** 2026-09-10T11:41:18-04:00
- **Returned concurrency mode:** `pcall (process per device)`
- **Result summary:** `total: 4, success: 4, failed: 0`

| Device | Result | Interfaces reported | Notable state |
|---|---|---|---|
| R1 | success | 8 (incl. Eth0/0.10, Eth0/0.20, Eth0/0.999, Lo0) | Eth0/3 admin down; all others up/up |
| R2 | success | 8 (incl. Eth0/0.30, Eth0/0.40, Eth0/0.999, Lo0) | Eth0/3 admin down; all others up/up |
| SW1 | success | 5 (Eth0/0–0/3, Lo0) | Lo0 admin down; Eth0/0–0/3 up/up |
| SW2 | success | 5 (Eth0/0–0/3, Lo0) | Lo0 admin down; Eth0/0–0/3 up/up |

No per-device failures in this batch.

---

## Batch 2 — `show version`

- **Devices requested:** R1, R2, SW1, SW2 (single `device_names` list, one call)
- **Completion timestamp:** 2026-09-10T11:41:41-04:00
- **Returned concurrency mode:** `pcall (process per device)`
- **Result summary:** `total: 4, success: 4, failed: 0`

| Device | Result | OS / Version | Image type | Uptime |
|---|---|---|---|---|
| R1 | success | IOS 17.15.1 (IOSXE) | production image | 35 minutes |
| R2 | success | IOS 17.15.1 (IOSXE) | production image | 35 minutes |
| SW1 | success | IOS 17.15.1 (IOSXE, L2 image) | production image | 35 minutes |
| SW2 | success | IOS 17.15.1 (IOSXE, L2 image) | production image | 35 minutes |

Chassis serial numbers and any licensing identifiers returned by the tool are **withheld** from this report per redaction policy.

No per-device failures in this batch.

---

## Overall Validation Result

| Batch | Command | Devices | Concurrency (actual, returned by tool) | Success | Failed |
|---|---|---|---|---|---|
| 1 | `show ip interface brief` | R1, R2, SW1, SW2 | pcall (process per device) | 4/4 | 0/4 |
| 2 | `show version` | R1, R2, SW1, SW2 | pcall (process per device) | 4/4 | 0/4 |

Both batches were executed exactly once as single four-device `pyats_pcall_show_command` calls (no per-device fallback calls, no external SSH, no scripts generated). No partial failures occurred in either batch, so no per-device error detail applies. Both calls returned Genie-parsed structured output (`"parsed": true` for every device/command pair).

**Conclusion:** `pyats_pcall_show_command` is validated against R1, R2, SW1, SW2 for both tested commands, running in per-device-process pcall concurrency, with 100% success (8/8 device-command pairs across both batches).
