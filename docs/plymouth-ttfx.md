# Native TTFX boot animation

This integration is based on the current `quattro` boot/provisioning and shell interfaces. It adds a Plymouth 26 native pixel plugin backed by vendored TTFX 0.5.1, effect/playback helpers, an Appearance > Bootloader submenu beside the existing Unlock picker, and transactional activation with classic-initramfs/UKI verification.

## Safe package defaults

`default/plymouth/omarchy.plymouth` selects `ModuleName=script` and also carries the initial TTFX selector values. The normal script therefore remains usable when a package does not include the native renderer. A package may ship a compiled payload at `/usr/lib/omarchy/plymouth/ttfx-plymouth.so`; target finalization, deferred owner provisioning, and the one-time migration activate it through `omarchy-plymouth-ttfx-install`. They never compile or replace live boot state merely because the source package was unpacked into an ISO.

A root wrapper that already holds the shared Plymouth lock may pass its inherited descriptor as `OMARCHY_PLYMOUTH_LOCK_FD`; the native helper checks the trusted lock path, device/inode identity, and exclusive nonblocking flock before reuse. An unrelated or separately opened descriptor takes the normal lock path and cannot bypass another owner.

The installer verifies the exact Plymouth ABI and module exports/hardening, stages static recovery, serializes mutations on `/run/lock/omarchy-plymouth.lock`, rebuilds the active boot artifacts, and rolls back on failure. `omarchy-plymouth-ttfx-build stage` explicitly selects the native renderer only after validating the supplied module. Packaging a runtime payload and publishing it are separate release steps.

Branding changes retain the existing validated effect, seed, colors, and playback mode. They preserve a selected native renderer only while a trusted native module is installed. Selecting an effect without that module fails before the descriptor is changed. The current `quattro` script, including late-display prompt recentering, is retained as the fallback.

## Runtime and handoff

The default is decrypt at 240 Hz with two engine frames per tick. Input Only plays once and holds completion, speeding up when the password is submitted; Full Animated loops. All playback uses `ttfx_engine_draw_logo`. The effect picker omits Off and keeps Random. The Unlock theme picker remains available. The native renderer draws only the Omarchy wordmark, so choosing a theme's unlock logo there switches the boot to the script renderer, which shows that logo, with the effect still recorded; choosing any effect under Appearance > Bootloader turns the animation back on.

The handoff to the desktop has no blank frame and no console in between:

- **Plymouth only deactivates.** `plymouth-quit.service` (drop-in `10-omarchy-retain-splash.conf`) runs `plymouth deactivate`, as GDM does: Plymouth stops drawing and drops DRM master but keeps its device open, so its last frame stays scanned out, with no `drm_lastclose` console restore flashing in between. The native module publishes its handoff as it deactivates: the last frame in `/run/omarchy-plymouth-handoff.raw` and the effect, colors and outro mode in `/run/omarchy-plymouth-handoff.state`. A failed deactivate quits Plymouth at once.
- **Plymouth quits once the compositor has drawn.** `omarchy-plymouth-reap.service` (`bin/omarchy-plymouth-reap`), started without holding up the login screen, notes the framebuffer each lit CRTC scans out, waits until each scans out another (the compositor's first frame), and quits Plymouth with `--retain-splash`, since `multi-user.target` waits for it. It quits after 20 seconds anyway.
- **Hyprland adopts the frame.** With Omarchy's aquamarine, `AQ_SPLASH_ADOPT=1` makes Hyprland take over the lit display, picture and all, without a modeset or an unrendered first frame. `default/uwsm/env.d/10-omarchy` sets it only for the first session of a boot that left the handoff frame, with the continuity client installed (a mark in `~/.local/state/omarchy/plymouth-adopted-boot` holds the boot id), since after a logout what is lit is the login screen's or the console's picture.
- **The continuity client covers the startup.** `omarchy-plymouth-handoff --launch-shell` (Hyprland's autostart) starts `/usr/lib/omarchy/plymouth/omarchy-plymouth-continuity-run` before the shell when the frame exists. The client shows the frame as an overlay layer (`omarchy-plymouth-continuity`) from Hyprland's first frame until the wallpaper engine's intro plays, then fades out; with `[ttfx] Outro=desktop` it plays the reverse outro there instead of in Plymouth. `default/hypr/plymouth-handoff.lua` draws that layer above the shell's startup cover with no fade in, turns off the `monitorAdded` zoom, and with Omarchy's Hyprland holds the adopted frame until the layer is opaque (`misc:startup_hold_layer`) with no cursor over it (`cursor:hide_at_startup`). Without the frame or the client, the shell starts as usual.

`omarchy-plymouth-ttfx-build build --continuity-output FILE` builds the client with the module, and `stage --continuity FILE` installs it and its launcher under `/usr/lib/omarchy/plymouth/`.

What is left on Apple Silicon is a brightness step while the splash shows, when `systemd-backlight` restores the saved backlight level.

## Validation

Run the focused shell tests `test/shell.d/plymouth-*-test.sh` and `test/shell.d/menu-test.sh`, then the native Rust and C suites described in `native/plymouth-ttfx-engine/UPSTREAM.md` and `native/plymouth-ttfx-plugin/README.md`, on the target architecture. Keep fixtures and build output on disk under `/var/tmp`; fixtures are retained and symlink targets stay inside their own fixture directory.

These checks establish module/API, pixelbuffer, selector, theme refresh, rollback, provisioning, and menu contracts. They do not prove visible LUKS input or the physical boot-to-desktop transition. Those require a coordinated installation and reboot or an independent disposable boot environment.
