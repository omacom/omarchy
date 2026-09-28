# Blackwell / SteelSeries compatibility profile

This is a narrowly matched workaround proposal, not a confirmed fix for an NVIDIA driver defect. It reproduces retained audio and browser settings from one system that passed bounded GPU, transfer, overlay, and active-audio tests. Sustained real Chromium/WebRTC frame correctness and reproduction across additional machines remain release gates; the implementation should stay draft until those are satisfied.

## Matching and delivery

`omarchy setup blackwell-audio auto` runs during per-user installation and through a migration for existing users. It requires all of these checks to pass:

- Gigabyte Technology Co., Ltd. B650I AORUS ULTRA, BIOS F42.
- AMD Ryzen 9 7950X3D 16-Core Processor.
- NVIDIA display controller PCI ID `10de:2c34` (RTX PRO 4000 Blackwell).
- Connected USB device `1038:12e0` (SteelSeries Arctis Nova Pro Wireless).
- Installed upstream versions: nvidia-utils and nvidia-open-dkms 615.71.09, linux 7.2.3.arch1, PipeWire 1.6.8, WirePlumber 0.5.17, Chromium 152.0.7977.82. Packaging release/epoch suffixes do not affect matching.
- Running kernel `7.2.3-arch1-3`. An old installed kernel package alongside a different booted kernel is not a match. Finalization under another live/installer kernel skips the profile; apply explicitly after booting the tested kernel if appropriate.

Detection reads cached sysfs identities, not PCI registers, bus numbers, DRM card numbers, display connector names, or serial numbers. Missing information is a non-match. This deliberately does not select every Blackwell GPU, every SteelSeries headset, or untested driver releases. The originating board is revision 1.0; its reported DMI board name does not encode that revision, so the detector cannot certify PCB revision from this string. The tests used X3D Turbo Mode (8 CPUs), two 4K60 displays, and Gen4 x8 bifurcation with a ConnectX6 present. Those are evidence context, not settings this profile changes; a NIC without an active link is not production ST2110 validation.

Package checks gate initial application/reapplication, not runtime behavior. A package upgrade does not automatically undo already installed settings. `status` reports when versions no longer match. Broadening or retiring the profile requires follow-up validation; exact-version matching is intentional for this draft.

## Settings and tradeoffs

- PipeWire: 48 kHz, default/minimum quantum 1024, maximum 2048. A 1024-frame cycle is about 21.3 ms at 48 kHz; the minimum affects the whole graph, not only the headset. This trades latency for scheduling margin and did not alone eliminate the original stalls.
- WirePlumber: only the headset's analog-stereo playback node receives period-size 1024, headroom 2048, IRQ scheduling (`api.alsa.disable-tsched = true`), and suspend timeout zero. IRQ mode on microphone capture failed testing and is not applied. Added headroom increases latency; disabling suspend can increase idle power.
- Chromium: native Wayland, ANGLE OpenGL, `WaylandLinuxDrmSyncobj`, and the retained disabled accelerated-video-decoding paths. Existing unrelated feature-list entries, extension flags, and other settings are preserved. Software video decode consumes more CPU and may be unsuitable for high-density feeds. This is not a browser throughput optimization or a claim of universal WebRTC correctness.

The local `--ignore-gpu-blocklist` flag is deliberately not distributed: bypassing Chromium's safety decisions is not required merely to select the fallback. This makes the packaged browser configuration a conservative candidate rather than a byte-for-byte copy of that machine's entire flags file, and it needs live workload validation before release.

Compact shell overlays are a separate general optimization in [PR #11394](https://github.com/omacom/omarchy/pull/11394). They are not installed as private plugin clones by this hardware profile. No monitor modes, workspace layouts, firmware, boot arguments, IRQ affinity, power limits, GPU clock locks, or PCIe service/register changes are made. In particular, `threadirqs` is not part of the passing normal boot, and the old local forced-Gen3 service is not an Omarchy default to reproduce or remove globally.

## Ownership, activation, and rollback

The command runs as the desktop user and writes only two dedicated user audio drop-ins and the user's `chromium-flags.conf`. Existing custom audio tuning in user or `/etc` configuration, conflicting browser flags, symlinks, non-files, or occupied target paths cause the whole profile to be skipped. It does not replace a dotfile manager's files. It cannot account for arbitrary runtime audio metadata overrides; this is a configuration profile, not a runtime enforcement service.

An exact original/applied snapshot and file modes are saved privately at `${XDG_STATE_HOME:-~/.local/state}/omarchy/blackwell-audio/state.json` before configuration changes. Each replacement is atomic, calls are serialized, and interrupted application can be resumed or rolled back. Files edited after application are never overwritten on reapplication or rollback; resolve those conflicts using the retained backup. Do not upload this state file: browser flags may contain private paths.

```
omarchy setup blackwell-audio status
omarchy setup blackwell-audio on
omarchy setup blackwell-audio off
```

`off` restores exact originals/removes only newly created profile files and records a persistent opt-out. Automatic install/migration calls honor it; explicit `on` can opt back in if hardware/software still match. No command restarts audio, closes a browser, interrupts a call, or reboots. Configuration takes effect after a convenient logout/login and full Chromium restart, including background browser processes. Rollback also needs those restarts before the running applications return to their previous settings.

If a headset is absent during installation or the migration, the command does nothing. It is not a hotplug daemon; reconnecting it later requires an explicit `on` if the remaining match conditions still hold. Installed buffering/browser settings remain until rollback even if the headset is subsequently unplugged.

## Evidence and limitations

On the originating system, switching only headset playback to IRQ scheduling held Chromium/Cava error counts constant through repeated checks, five capture/OSD cycles, and a 25-second 4K30 CUDA decode workload. Microphone errors still increased in that earlier run; IRQ capture was reverted.

Later, with the complete retained configuration, a five-minute active output/microphone/WebRTC observation recorded no new audio errors. Simultaneous GPU compute and transfers passed data verification. The original roughly 100 ms NVIDIA hard-interrupt intervals were absent in bounded normal-boot traces. However, normal boot was already clean before the local PCIe Gen3 cap was removed, and earlier failures occurred with several of these same settings present. This does not identify which change or reboot-dependent state ended the stalls, or prove this bundle sufficient on a fresh installation.

The automated tests validate detection, narrow version gates, feature-list merging, collision handling, exact rollback, opt-out, interrupted application, and install/migration integration. They do not establish hardware efficacy. Before marking the PR ready: exercise installation and rollback on a disposable equivalent setup, validate the candidate browser flags under real Chromium/WebRTC load, and repeat across cold boots. No raw desktop captures, browser URLs, serial numbers, network credentials, or diagnostic archives belong in the PR.

References: [WirePlumber ALSA rules](https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/alsa.html), [PipeWire ALSA scheduling and buffering properties](https://docs.pipewire.org/page_man_pipewire-props_7.html), and [PipeWire graph configuration](https://docs.pipewire.org/page_man_pipewire_conf_5.html).
