# Native TTFX boot animation

This integration is based on the current `quattro` boot/provisioning and shell interfaces. It adds a Plymouth 26 native pixel plugin backed by vendored TTFX 0.5.1, effect/playback helpers, an Appearance > Bootloader submenu beside the existing Unlock picker, and transactional activation with classic-initramfs/UKI verification.

## Safe package defaults

`default/plymouth/omarchy.plymouth` selects `ModuleName=script` and also carries the initial TTFX selector values. The normal script therefore remains usable when a package does not include the native renderer. A package may ship a compiled payload at `/usr/lib/omarchy/plymouth/ttfx-plymouth.so`; target finalization, deferred owner provisioning, and the one-time migration activate it through `omarchy-plymouth-ttfx-install`. They never compile or replace live boot state merely because the source package was unpacked into an ISO.

A root wrapper that already holds the shared Plymouth lock may pass its inherited descriptor as `OMARCHY_PLYMOUTH_LOCK_FD`; the native helper checks the trusted lock path, device/inode identity, and exclusive nonblocking flock before reuse. An unrelated or separately opened descriptor takes the normal lock path and cannot bypass another owner.

The installer verifies the exact Plymouth ABI and module exports/hardening, stages static recovery, serializes mutations on `/run/lock/omarchy-plymouth.lock`, rebuilds the active boot artifacts, and rolls back on failure. `omarchy-plymouth-ttfx-build stage` explicitly selects the native renderer only after validating the supplied module. Packaging a runtime payload and publishing it are separate release steps.

Branding changes retain the existing validated effect, seed, colors, and playback mode. They preserve a selected native renderer only while a trusted native module is installed. Selecting an effect without that module fails before the descriptor is changed. The current `quattro` script, including late-display prompt recentering, is retained as the fallback.

## Runtime and handoff

The default is decrypt at 240 Hz with two engine frames per tick. Input Only plays once and holds completion, speeding up when the password is submitted; Full Animated loops. All playback uses `ttfx_engine_draw_logo`. The effect picker omits Off and keeps Random. The Unlock theme picker remains available.

Plymouth deactivates before quitting, retains its last splash through compositor startup, and has a bounded reap timer. A desktop renderer may opt in with `OMARCHY_TTFX_BG_LAUNCHER`; without one, normal shell startup proceeds immediately. There is no dependency on a personal desktop plugin. The background layer emits a readiness marker once after a settled frame, without idle polling.

## Validation

Run the focused shell tests `test/shell.d/plymouth-*-test.sh` and `test/shell.d/menu-test.sh`, then the native Rust and C suites described in `native/plymouth-ttfx-engine/UPSTREAM.md` and `native/plymouth-ttfx-plugin/README.md`, on the target architecture. Keep fixtures and build output on disk under `/var/tmp`; fixtures are retained and symlink targets stay inside their own fixture directory.

These checks establish module/API, pixelbuffer, selector, theme refresh, rollback, provisioning, and menu contracts. They do not prove visible LUKS input or the physical boot-to-desktop transition. Those require a coordinated installation and reboot or an independent disposable boot environment.
