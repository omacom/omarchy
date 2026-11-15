# MacBookPro8,2 hardware support

This integration follows the work tested on a 15-inch 2011 MacBook Pro with an i7-2760QM, Intel HD 3000 (`8086:0126`), BCM4331 (`14e4:4331`), and an LG LP154WP4-TLA1 internal panel (Apple EDID `0610:9ca3`). The AMD GPU was already disabled in firmware. Other MacBook models and machines with a working AMD GPU are outside the backlight workaround's scope.

## Existing paths reused

- `install/hardware/intel/video-acceleration.sh` installs `libva-intel-driver` for this model. The wider Intel PCI-generation detection work is tracked separately in [PR #8514](https://github.com/omacom/omarchy/pull/8514); this change does not introduce another general Intel detector.
- `omarchy-install-video-decode` handles per-user mpv settings, reusing its global-option parsing and preserving user choices. Its setup leaf moves out of the Qualcomm directory because it now serves both families.
- `install/hardware/fix-bcm43xx.sh` already installs `broadcom-wl-dkms` for BCM4331. No second Wi-Fi installer, firmware payload, driver copy or module blacklist is added.
- `omarchy-power-profiles-daemon` keeps owning the D-Bus API, profile holds, authorization, state and resume handling. Its existing cpufreq backend gains a model-gated passive Intel method in `omacom/omarchy-pkgs`. No replacement D-Bus daemon or power menu is introduced.
- `omarchy-hw-display` selects the direct LP8545 backlight ahead of gmux when it exists. The packaged module independently checks DMI, absence of AMD display controllers, the SMBus functionality and chip ID before writing registers. It does not blacklist `apple_gmux` or alter GPU power/mux/EFI state.

The companion package change supplies `lp8545-backlight-dkms` and the extended power-profile backend. The backlight package is also listed in `install/omarchy-other.packages` so the ISO builder includes it in the offline mirror. The hardware setup assumes matching headers, as other DKMS setup leaves do. DKMS rebuilds for newly installed kernels. The module is loaded at boot; deferred image provisioning also loads it because `systemd-modules-load` has already run. No internet fetch or source build is embedded in a setup leaf.

## Local prototypes and attribution

MarkPronkin's local work supplied the LP8545 driver, display-profile reconstruction and measured CPU settings. The package work preserves the existing upstream power-profile authors and licenses; the kernel module remains GPL-2.0-only.

The experimental Wi-Fi series came from [Shupeng Xue's b43-ht project](https://github.com/Xerxes-2/b43-ht), under GPL-2.0-only. Local testing initially demonstrated 5 GHz and 802.11n, but later controlled comparisons found recurring Bluetooth audio cuts with b43 and clear audio with wl. The user restored wl as the persistent default on 2026-11-06. The experimental series is therefore not shipped or relabeled as MarkPronkin's work.

The display command consumes a user-supplied archive and reports its matching override's SHA-256. It uses Apple's response tables as ICC TRCs, not GPU `vcgt` ramps, with LittleCMS adapting the colorants to D50. The monitor rule goes into the `~/.config` module tree used by `default/hypr/bootstrap.lua`. Apply, dry-run and removal reject a different `XDG_CONFIG_HOME` before writing; standalone ICC generation remains independent of the compositor's config path. No Apple plist, ICC profile, macOS audio resource or proprietary Broadcom firmware is redistributed. Tests create their own synthetic EDID, primaries and curves.

An existing installation using the local `macbook-power-profiles.service` prototype must uninstall that prototype before using the packaged backend: its installer masks `power-profiles-daemon.service`. This contribution does not delete unowned local files or unmask services during ordinary setup. Fresh installations use the packaged backend directly.

## Verification

The hardware-quirks suite covers the supported model, a healthy dual-GPU machine, unavailable PCI/DMI data, first boot, and package/module failures. The video suite covers defaults, user overrides, profile sections, repeated setup and XDG paths. The display suite checks synthetic EDID matching, exact TRCs, D50 transforms, deterministic generation and rollback. Companion package tests exercise the real power-profile daemon over private D-Bus and simulated sysfs, including profile transitions, resume and unrelated-machine guards.

Driver builds and read-only validation on the target machine complement these checks. A clean installation, reboot and suspend/resume on physical hardware remain release validation; building the new module does not establish those results.
