# USB while locked: draft policy

This is a standalone, opt-in replacement for the default-on approval flow from #11874. It includes removal of automatic enrollment and a migration that restores normal USB access and the previous Bolt policy on machines enrolled by Omarchy. It can merge directly into `quattro` as an alternative to the full rollback in #14936; that PR does not need to merge first. The migration preserves manually managed policy, repairs the factory snapshot to prevent reenrollment after a reset, and completes saved recovery even when enrollment markers are missing. Machine-wide cleanup is serialized across users; failed cleanup remains pending with the recovery tools available.

No installation hook or migration enables the replacement. After updating and completing the bundled migration, it is available under Setup > Security > USB While Locked for product and implementation review before any decision about defaults.

## User behavior

- Boot and the initial login work normally; no kernel boot parameters change.
- While unlocked, USB devices work without approval prompts.
- Locking captures the identities of devices currently allowed. Those devices keep working and may reconnect through another port or hub during that lock. A changed identity still requires unlocking.
- Unfamiliar devices connected while locked stay blocked. An existing keyboard or another existing authentication method is needed to unlock; plugging in a new keyboard cannot unlock the machine.
- Successful unlock automatically allows waiting devices. This is a deliberate UX tradeoff: an attacker can leave a malicious device connected and have it reach its driver when the user unlocks. This policy does not fix the Pegasus driver vulnerability, protect an unlocked machine, or authenticate forgeable USB descriptors.
- Thunderbolt/USB4 PCIe authorization stays with Bolt's normal policy. USB functions of a dock follow this USB policy. No PCIe/DMA protection is claimed here.

## Implementation

An independent USBGuard service owns a root-only policy under `/run/omarchy-usb-lock`. It refuses to coexist with an enabled manually managed USBGuard service. No existing `/etc/usbguard` rules or IPC grants are reused or rewritten. The policy starts with `allow` after reboot; the service preserves its runtime directory across stops and restarts within the same boot.

Before acknowledging a lock, a protected Bash helper writes a frozen identity policy, restarts USBGuard with it and verifies service/IPC availability. The kernel default for new devices remains deny during the restart. USBGuard applies the policy to devices present at restart as well as new arrivals. Retrying a lock never recaptures devices. The same identity parser used by the retained USB approval code strips only port and parent-hub constraints.

The Quickshell lock requests these transitions through a narrow Polkit helper. Only active local wheel users can invoke its fixed `lock` and `unlock` operations; administrative enable/disable still requires sudo. Software already running as that user can request unlock policy; this is an unattended physical-access policy, not a boundary against a compromised user session. The screen itself locks immediately and never waits on USB. There is a transition window until the helper acknowledges enforcement, exposed as `usbPolicyReady` in lock status; suspend preparation waits for both the screen and USB policy, within the existing delay budget. Errors trigger a visible notification and retries without unlocking the screen.

No startup signal implicitly clears a locked policy. A recovered compositor lock reuses the saved snapshot. A new session releases inherited policy only after the compositor reports an unlocked session. Rapid requests are serialized so an older unlock cannot finish after a newer lock transition. An unsuccessful daemon restart leaves the frozen policy on disk for recovery.

## Review and validation gates

The draft needs agreement on automatic allowance after unlock versus reviewing devices that arrived while locked, the transition window, and whether this should ever be default-on. Physical docking, suspend/resume, replacement input, multiple sessions/seats, controller hotplug and daemon/compositor crash scenarios need review and hardware coverage before rollout. A new controller during a daemon outage may enumerate before userspace can change its default; this is not boot-level protection.
