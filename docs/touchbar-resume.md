# J293 Touch Bar resume recovery candidate

This is an unenabled reference implementation for review. No installer, migration, package list, or active service uses these files. The tested local workaround is staged here so its kernel interface and packaging can be reviewed before default enablement.

## Observed failure and recovery

On the 13-inch M1 MacBook Pro (MacBookPro17,1 / apple,j293), the Touch Bar repeatedly stopped updating after multi-hour suspend. Restarting tiny-dfr, rebinding ADP, and restoring DRM modeset state did not recover it. A failed resume captured 111 samples over 1.024 seconds with no frame interrupt progress despite enabled/unmasked interrupts and active sampled power blocks.

One standard MIPI DCS EXIT_SLEEP_MODE (0x11) command through the bound host, followed by a 150 ms wait and a physical Fn test, restored visible/touch functionality without rebooting. Frame IRQ count advanced from 1597 to 2121. The exact reason the panel/link entered the stalled state remains unproven. An earlier power-mode query was ambiguous and must not be interpreted as proof the panel was asleep. Diagnostic reads preceded the first manual recovery; automatic runs use only exit-sleep.

On Omarchy 4.5.0-3 with kernel 7.2.11-14-1-ARCH, automatic post-suspend invocations succeeded after approximately 3h49m and 35m sleeps on November 5. The latter logged IRQ progression from 1338 to 1348. On November 6 the user confirmed the Touch Bar activated normally in the morning; the journal records another successful invocation at 07:59:29. Multi-day validation continues. Command success alone does not demonstrate visible recovery, nor does every successful wake prove the panel would otherwise have failed.

## Files and lifecycle

`default/touchbar-resume/` contains a small one-shot kernel module, a serialized root helper, and an optional systemd post-suspend hook. The module checks J293 and the expected bound drivers, excludes concurrent brightness operations, sends one command, waits, and exposes the result. The helper unloads it immediately and logs the outcome. No renderer restart, driver rebind, reset, diagnostic FIFO read, or brightness override is involved.

The reference helper expects a root-owned module at `/usr/local/lib/touchbar-panel-wake/$(uname -r)/touchbar_panel_wake.ko` and itself at `/usr/local/libexec/touchbar-panel-wake`. The optional hook belongs in `/usr/lib/systemd/system-sleep/`. Missing kernel builds are explicitly logged as INACTIVE and skipped, never force-loaded. These are existing local-workaround paths, not a decided distribution packaging interface. The hook shipped in this candidate accepts only `post suspend`; other sleep actions are unvalidated.

For build review, copy the module source and Makefile into a temporary directory and run `make -C /usr/lib/modules/$(uname -r)/build M=<absolute-temporary-directory> CC=clang W=1 KCFLAGS=-Werror modules`. Building does not install or execute the module. Review the helper and device assumptions before any privileged execution.

## Required before enablement

- Decide between a maintained kernel package fix and an external module with a supported kernel-update lifecycle. Manual rebuilds are not an adequate default installer experience.
- Review internal backlight lock usage and lock ordering; current trylocks abort when busy.
- A proper panel PM implementation should wake the panel before the first ADP frame request. This post-resume workaround can run after an initial kernel frame timeout.
- Add model-gated provisioning/removal only after packaging is agreed. M2 and Intel/T1/T2 are outside the tested scope.
- Continue multi-day normal-use testing and record any failure before rebooting.

Disabling an installed local hook by removing its executable bit stops automatic invocation without changing diagnostics or other services. The temporary module is not left loaded.

## Related work

[PR #17826](https://github.com/omacom/omarchy/pull/17826) addresses fresh-install renderer/plugin integration for M1/M2; its documented scope excludes suspend/clamshell behavior. This candidate complements that work.

The original driver author previously experimented with [panel sleep/wake commands](https://github.com/WhatAmISupposedToPutHere/linux/commit/502bf25d37a1ff4b9e59823bceb99fa34b9b2979). The command is not a new protocol discovery; this contribution supplies reproduced failure/recovery evidence and a reviewable implementation.
