# Framework 16 Ryzen AI 300 speaker volume

On the tested Framework 16 (Ryzen AI 300, Realtek ALC285 subsystem `f111000d`), desktop volume turned down both channels of `Speaker` while leaving `Bass Speaker` at 0 dB. Their relative levels changed, making the sound thin at low volume.

The labels **appear swapped**: repeated isolated-tone recordings found `Speaker` supplied most of the low and mid-frequency output, while `Bass Speaker` was comparatively weighted toward treble. At 300 Hz, `Speaker` was 34–37 dB stronger; at 1 kHz, about 23 dB stronger. These built-in-microphone measurements establish acoustic contributions, not the identity of individual physical drivers.

## Fix

Enable software volume for the affected codec and set `Master`, `Speaker`, and `Bass Speaker` to 0 dB. Desktop volume then scales the complete output without changing its tonal balance. Both speaker controls receive the same setting, so swapping their names later will not affect the fix.

The installer and migration install a per-user WirePlumber rule and create a `wireplumber.service.wants` link to `/usr/lib/systemd/user/omarchy-framework16-speaker-levels.service`. The unit stays package-owned, so future package updates apply to existing users. Setup works without a live user manager. Existing mixer files and symlinks stay in place; custom or unavailable mixer configuration is preserved without enabling the service. A missing mixer rule is copied atomically so interrupted setup can finish on retry. Setup never writes a top-level user service definition or changes an existing override or mask.

The `omarchy-settings` and `omarchy-settings-dev` recipes in `omarchy-pkgs` must include the vendor-unit install entry before packages containing this setup and migration ship.

Normal user finalization and the migration each run once. Explicitly rerunning setup reapplies the enablement link, including after `systemctl --user disable`; a user mask continues to prevent the service from running. Reboot applies the setup without interrupting playback during installation.

After WirePlumber starts, the initializer discovers the card, verifies software volume is active and all required controls exist, then sets their levels. Discovery timeouts retry after five seconds, subject to a systemd limit of four total starts within five minutes. Successful starts and manual or WirePlumber-triggered restarts also consume this allowance; it is a start-rate limit rather than a fresh discovery retry budget for each invocation. Once exhausted, automatic retries stop. A later requested start can run after the interval expires, or the counter can be cleared explicitly. Each attempt has a 30-second startup timeout; control failures and hung attempts remain failed without retrying. Desktop volume and mute are preserved.

After correcting a persistent discovery or configuration failure, or when rapid audio-service restarts exhaust the start-rate limit, reset the failed service and start it again:

```bash
systemctl --user reset-failed omarchy-framework16-speaker-levels.service
systemctl --user start omarchy-framework16-speaker-levels.service
```

## Validation

Focused setup and initializer checks cover hardware gating, offline enablement of the packaged unit without a local service copy, recovery from interrupted mixer copying and enablement, custom mixer preservation, existing service overrides and masks, and safe hardware initialization. Native WirePlumber checks load the shipped rule and verify matching and excluded devices using its configuration parser and matching engine; these checks require a C compiler and WirePlumber 0.5 development files and report a skip when unavailable. Systemd policy checks use isolated transient services and fake audio commands to verify delayed recovery, stopping after four failed discovery attempts, no retry after control failure, and termination of hung discovery; they report a skip when no user manager is reachable. A temporary systemd service on the laptop also verified recovery after a simulated discovery timeout and successful initialization of the real hardware on retry.

Hardware checks confirm startup initialization, stable 0 dB speaker levels across desktop volume changes, and persistence across an Off-to-HiFi profile cycle, suspend/resume, and reboot. After suspend/resume and reboot, the software mixer remained active and `Master`, `Speaker`, and `Bass Speaker` were unmuted at 0 dB; desktop volume remained at 55% and unmuted. The startup initializer completed successfully after reboot.

[Upstream volume issue](https://github.com/NixOS/nixos-hardware/issues/1743) · [Framework discussion](https://community.frame.work/t/framework-16-speaker-volume-curve-issue/78591?page=2)
