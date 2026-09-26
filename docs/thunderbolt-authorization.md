# Thunderbolt authorization

Omarchy uses Bolt for Thunderbolt/USB4 PCIe authorization. USB functions remain separate and need USB authorization. The end-user controls and firmware limitations are documented in [the Security manual](../manual/48-security.md#thunderbolt-device-authorization).

## Policy and services

Bolt's default IOMMU policy can enroll new devices without asking. Omarchy keeps `AuthMode=disabled` in `/var/lib/boltd/boltd.conf` and authorizes individual devices through Bolt's D-Bus API. This does not disable Bolt or prevent explicit authorization. Setting only `DefaultPolicy=manual` would still leave IOMMU auto-enrollment enabled.

The root `omarchy-thunderbolt-authorization.service` holds explicit consent in `/var/lib/omarchy/thunderbolt-authorization/policy.json`. Bolt can import devices authorized by firmware, so its database is not treated as consent. Initial setup captures currently connected accessories; subsequent enables preserve that inventory, including an initially empty inventory. Always-allow approvals authorize, read back the real status, enroll with manual policy, verify storage, and save consent. Trusted devices are restored even without an unlocked graphical session. No operation globally enables Bolt to authorize one device.

The Bolt startup drop-in sets the persisted mode before hardware enumeration whenever `/etc/omarchy/thunderbolt-authorization.enabled` exists. The Omarchy service checks the live mode again. Firmware security `none` remains a bypass: software cannot prevent driver loading after firmware has already opened a PCIe tunnel. This produces a warning instead of disconnecting active storage.

Secure-capable devices require both a stored Bolt record and a saved key for automatic trust. An explicit permanent approval pins the current sysfs directory and key descriptor, seeds an empty kernel key before authorization, and verifies Bolt imported it before saving consent. Automatic reconciliation cannot initialize a missing key and retains its read-only sysfs sandbox. First activation is deferred when a captured secure-capable device lacks a saved Bolt key: the `.pending` marker starts a setup notification, while existing Bolt configuration and services remain untouched. Installation can finish; only explicit setup after safe disconnection clears the pending state. Initial identity capture uses Bolt's numeric device/vendor fallback when descriptive sysfs attributes are absent.

The runtime is Bash, with `busctl --json=short` for Bolt's structured D-Bus replies and `jq` for JSON. The root daemon publishes a root-owned snapshot in `/run/omarchy-thunderbolt-authorization`. The user service polls that snapshot and refuses unavailable, stale, or mismatched generations. It does not infer final policy from presence signals. Requests use opaque tokens and bind the policy-service generation, Bolt bus owner, device path, connection timestamp, sysfs inode, and device identity. The inode distinguishes same-second reconnects. Device text is displayed as untrusted data. Failed delivery retries; lost approval responses retain intent and offer another notification. Watcher restarts preserve unfinished intent only while the exact connection and policy-service incarnation remain unchanged. A changed device or daemon requires a new request.

The terminal dialog saves an approval intent; the background watcher submits it through `pkexec` to the fixed installed `/usr/bin/omarchy-thunderbolt-authorization-approve` helper. Polkit grants active local wheel users this individual approval action. The helper validates its arguments and the live connection, then independently verifies authorization and any saved trust before returning success. Root entrypoints use protected Bash startup and fixed installed libraries; they discard caller-supplied D-Bus addresses. A shared lock serializes setup, reconciliation, and approvals. General setup uses a separate administrator command invoked with `sudo` from the terminal. Blanket Bolt management requires administrator authentication while protection is enabled. These controls protect against unsolicited accessories, not malicious software already running as an administrator. Identifiers can be forged; Bolt's secure connection keys provide additional verification on supported hardware.

## Firmware boot access

The optional boot control applies only to online controllers with a firmware BootACL in `user` or `secure` mode. It captures connected accessories, changes stored policies to manual, clears each allowlist, and independently reads back the results. Reconciliation keeps firmware imports and returning controllers from silently restoring automatic boot permissions. Unsupported or offline controllers produce explicit warnings/errors.

Changes retain the previous policy and firmware lists. A failed transition restores matching state, or leaves a recovery checkpoint and reports failure. Device-authorization setup has a separate checkpoint that includes service state and firmware settings when boot protection was active. Restore commands are described in the manual. Firmware modified by another OS or an older snapshot is outside the current system's control; this is not an early-boot kernel authorization switch.

Deferred owner setup leaves ordinary Bolt behavior in place until the owner finishes provisioning. Factory reset disables the copied service and removes previous-owner trust, recovery data, Bolt identities, and keys from both staged and retained roots. It does not change the live daemon.

## Validation

Run policy, notification, rollback, deferred-owner, and real offline-systemctl tests with:

```sh
bash test/shell.d/thunderbolt-authorization-test.sh
```

The optional integration suite runs the installed `boltd` against upstream's UMockdev Thunderbolt fixture and a private D-Bus. Its hardware simulator uses Python/GObject; all Omarchy policy code and test assertions execute Bash. It needs `python-gobject`, `python-dbusmock`, `umockdev`, Bolt, and a Bolt source checkout (validated with 0.9.11):

```sh
umockdev-wrapper env BOLT_TEST_SOURCE=/path/to/bolt bash test/shell.d/thunderbolt-authorization-test.sh
```

It covers user/secure modes, IOMMU default denial, verified permanent and one-time approval, daemon restart, stale requests, firmware ACL restoration, and a separate Bash daemon publishing status after reconnecting to Bolt. These tests simulate kernel devices and firmware. They do not demonstrate physical DMA isolation or real firmware enforcement during boot. Systemd packaging, the installed approval helper, and the actual desktop Polkit rules require installed-guest validation; source-only dev linking does not install system units or rules.
