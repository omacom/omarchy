# Ward pen-test — malicious plugin assets

The **offensive** artifacts of the Ward threat model are the plugins a
white-box (code-reading) or black-box (docs-only) attacker would try to run.
They are kept in the `jacob-vincent-mink/omarchy` fork on the
`security/ward-pen-test` branch and are **not** merged into mainline, because
the point is to keep live attack code out of the product.

This document stays in mainline as the record of what those assets are. The
**negative tests** that prove the host-side boundary contains each asset live in
[`native/ward/tests/pen_test.rs`](../../../native/ward/tests/pen_test.rs) and
[`native/ward/tests/pen_test_blackbox.rs`](../../../native/ward/tests/pen_test_blackbox.rs)
and **do** ship in mainline, because they are regression guards.

The reports in `docs/threat-model/pen-test/` (mainline) summarize what each
asset tries and how it is contained.

## Assets (on the fork branch)

| Asset | Attack intent | Boundary under test | Result |
| --- | --- | --- | --- |
| `path-traversal/` | Read `/etc/passwd` via the plugin-path token | TB-8 exec / TB-4 sandbox | Contained: traversal rejected; the token resolves only within the pinned directory |
| `http-origin-escape/` | Hit an origin the reviewer did not approve | TB-8 http | Contained: origin/method/path match is exact; a different origin is rejected |
| `settings-write/` | Write a host-structure or read-only key | TB-8 settings | Contained: write is bounded to approved keys; host-structure keys rejected |
| `notification-markup/` | Smuggle markup or a command into a notification | TB-8 notification | Contained: control/RTL rejected; body escaped; title prefixed |
| `exec-arg-smuggle/` | Add arguments to a reviewed command | TB-8 exec | Contained: a complete argv path is required; extra arguments are rejected |

Each asset is a `manifest.json` plus a `main.qml` — the concrete thing a plugin
author writes. The matching negative test asserts the host-side boundary
contains it.

## How an asset is contained

Every asset's request reaches a host-side gate that **fails closed**:

- The manifest can only *request*; it approves nothing. The grant is a separate,
  ed25519-signed, reviewer-approved record that must cover the request exactly
  (TB-1, TB-2).
- A request reaches the host only through a peer-authenticated, rate-limited,
  per-request re-checked broker (TB-5).
- A granted exec is matched by a positive-only argv tree with whole-argument
  regex and a path-traversal guard (TB-8).
- A granted http origin/method/path/query is matched exactly; the resolved
  address is pinned to defeat DNS rebinding (TB-8).

A capability whose socket is not admitted cannot be connected at all; a
malformed or oversized record is rejected, not truncated.
