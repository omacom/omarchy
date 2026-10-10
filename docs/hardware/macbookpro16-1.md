# MacBookPro16,1: power, graphics, and cooling reference

This is a configuration and test record for one 2019 16-inch Intel/T2 MacBook Pro, collected on 2026-09-16. It supplements the [Mac support manual](../../manual/44-mac-support.md). It documents the complete relevant tuning state, including retained settings, superseded approaches, measured outcomes, and unresolved issues. It is not a universal MacBook optimization preset or a recommendation to install an experimental governor on every machine.

The contribution does not modify Omarchy's installer, migrations, packaged settings, or default services. The adjacent source files are opt-in reference artifacts for review and reproduction; nothing installs or starts them automatically. Live-machine scripts with account-specific paths and raw logs containing identifying information are deliberately not published.

## Reference hardware and software

| Component | Tested configuration |
| --- | --- |
| Model | `MacBookPro16,1`, 2019 16-inch, Intel Core i9-9980HK |
| Integrated GPU | Intel UHD Graphics 630, `8086:3e9b`, PCI `0000:00:02.0`, `i915` |
| Discrete GPU | Radeon Pro 5500M / Navi 14, `1002:7340`, subsystem `106b:020f`, PCI `0000:03:00.0`, `amdgpu` |
| Desktop | Omarchy `4.0.4-1`, Hyprland with Lua monitor configuration and UWSM |
| Kernel | `7.2.6-arch2-Watanare-T2-1-t2`; package `linux-t2 7.2.6.arch2-1` |
| Graphics | Mesa `1:26.2.2-1` |
| Power and cooling | `power-profiles-daemon 0.30-1`, `thermald 2:2.5.12-1`, `t2fanrd r16.48baf96-1` |
| Diagnostic packages | `mesa-utils 9.0.0-7`, `vulkan-tools 1.4.357.0-1` |
| Internal display | Intel `eDP-1`, 3072×1920 at 60 Hz, scale 2 |
| Battery condition at audit | 81.8829 Wh full-charge capacity / 99.8544 Wh design, approximately 82%, 317 cycles |

The Touch Bar exposes another DRM device. During this audit Intel was `card1`, the Touch Bar `card2`, and AMD `card3`; these numbers are observations, not identifiers to hardcode. The controller deliberately rejects a different model, PCI identity, or board subsystem. The 13-inch integrated-only models, other Radeon variants, and Apple silicon are outside this test's scope.

## What improved, and what was actually measured

| Area | Previous behavior or problem | Applied change | Evidence and qualification |
| --- | --- | --- | --- |
| Desktop rendering | GPU ordering and display ownership were unreliable in earlier local setup notes | Intel panel routing and explicit compositor device with stable DRM aliases | Accelerated Intel OpenGL and the intended internal-panel topology verified; no controlled battery A/B result |
| Duplicate output | Radeon exposed a duplicate zero-resolution internal-panel connector | Disable only the identified `eDP-2` in this machine's monitor configuration | Intel `eDP-1` remains active; no isolated energy measurement attributed to this change |
| Radeon initialization | A broad DRM udev rule also matched connectors and logged missing-attribute errors | Model-specific boot preparation service sets and verifies `low` | Existing service succeeded during the audited boot; no reason to repeat connector-level GPU writes |
| Radeon performance availability | Fixed `low` remained in force even when a game selected AMD | Guarded, activity-based `low`/`high` policy | Five rendering/idle cycles boosted and recovered; no app list required; no game-FPS benchmark |
| High-state idle consumption | A bounded forced-high idle check reported about 15 W | Return to `low` after near-idle detection | About 4 W after recovery, an approximately 11 W GPU-sensor difference in short observations, not whole-system or time-averaged savings |
| Video-driver selection | Global `LIBVA_DRIVER_NAME=iHD` constrained all applications to Intel's VA-API driver | Remove the global override and let the selected device determine its driver | `vainfo` initialized Intel iHD and AMD radeonsi on their own render devices; actual playback efficiency not benchmarked |
| CPU power-profile ownership | A custom root-run udev mechanism overlapped current Omarchy's desktop policy | Preserve and disable only the audited legacy rule | Live profile and saved battery/AC preferences are balanced; distinct-profile cable-transition behavior not established |
| Sleep coordination | A new activity controller would otherwise carry state across sleep | Stop before sleep; restart only if previously active | One real suspend/resume and post-wake rendering passed; manually stopped state also preserved in a hook test |

The owner reported a cooler-feeling, more efficient machine after the earlier changes and reboot. That is subjective feedback, not a measured temperature or battery-runtime improvement. The fixed-low Radeon already idled at about 4 W before the new controller. The new improvement is demand-responsive performance while recovering that low-clock idle state, rather than a further reduction below 4 W. Boosting intentionally consumes more power while rendering.

No percentage battery-life gain, FPS increase, improved suspend-drain rate, or maximum-efficiency claim is supported by these tests. The manual's pre-existing general Mac performance claim is unrelated to this tuning record.

## Applied and retained configuration

### 1. Balanced CPU policy with performance headroom

Both saved profiles are `balanced`, in the desktop user's `${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/powerprofiles/{ac,battery}`. The live profile is also balanced. The reference CPU reports `intel_pstate`, governor `powersave`, EPP `balance_power`, minimum performance 16%, maximum performance 100%, and `no_turbo=0`. These are observed values, not a script that pins every CPU to them. Turbo remains available; the Intel P-state powersave governor is not a fixed minimum frequency.

Use Omarchy's power panel to save the desired AC/battery preferences. Run its power-profile commands as the desktop user, not as root. Current [`omarchy-powerprofiles-init`](../../bin/omarchy-powerprofiles-init) initializes the selected source's preference, and the desktop shell handles UPower source changes.

The older local `/etc/udev/rules.d/99-power-profile.rules` launched the selector as root. It originally read the wrong user's state, and was subsequently amended with a hardcoded desktop-user state directory. The final cleanup checked its exact content, preserved it as `99-power-profile.rules.disabled-20260916-demand`, and reloaded udev. That superseded root policy is not proposed for Omarchy. Do not disable unrelated custom rules merely because their filename is similar.

`powerprofilesctl list-actions` reports `amdgpu_dpm` and `amdgpu_panel_power` disabled, with `trickle_charge` enabled. These are observed action states, not proof of a new battery-charge limit. There must not be a second GPU policy writer competing with the reference controller. No TLP, auto-cpufreq, GameMode, or LACT policy was added during this work.

### 2. Route the internal panel and compositor to Intel

The installed `/etc/modprobe.d/apple-gmux.conf` setting is:

```text
options apple-gmux force_igd=y
```

The boot image was rebuilt with the installation's `limine-mkinitcpio` workflow during earlier tuning, followed by reboot. The [T2 Linux hybrid-graphics guide](https://wiki.t2linux.org/guides/hybrid-graphics/) describes the panel-routing approach. It is separate from application GPU selection and from Radeon clock policy. Reverting the option also requires rebuilding the boot image and rebooting; changing only the text file does not change the current session.

The final `/etc/udev/rules.d/30-t2-hybrid-gpu.rules` uses PCI matches and excludes connector objects:

```udev
ACTION=="add|change", KERNEL=="card[0-9]*", KERNEL!="card*-*", KERNELS=="0000:00:02.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/intel-igpu"
ACTION=="add|change", KERNEL=="card[0-9]*", KERNEL!="card*-*", KERNELS=="0000:03:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/amd-dgpu"
```

The loaded local UWSM snippet is `~/.config/uwsm/env.d/90-macbookpro16-power`:

```bash
export AQ_DRM_DEVICES=/dev/dri/intel-igpu
```

For a new installation, follow the [Hyprland multi-GPU guide](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Multi-GPU/) and its documented UWSM `env-hyprland` location, avoiding duplicate or contradictory exports. Verify the actual session environment after a new login.

**Tradeoff:** this Intel-only device list excludes AMD-connected external outputs from the compositor. The AMD driver remains loaded and applications can use it, but that does not make those outputs available to Hyprland. Listing Intel first and AMD second is a separate configuration to test with external displays, not an already-validated feature of this setup.

### 3. Internal-panel scale and duplicate-output handling

The relevant settings in `~/.config/hypr/monitors.lua` are:

```lua
hl.env("GDK_SCALE", "2")
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 2 })
hl.monitor({ output = "eDP-2", disabled = true })
```

On this machine `eDP-2` was the duplicate output, not the real Intel panel. Inspect `hyprctl monitors all` first on another installation; connector names and Lua versus legacy Hyprland configuration differ. Restore the previous monitor file if a real display is lost. Disabling this connector is not evidence of full Radeon power-off.

### 4. Radeon boot preparation and automatic clocks

The pre-existing `/usr/local/bin/mbp2019-amdgpu-power-prep` and `mbp2019-amdgpu-power-prep.service` remain enabled. Their [source and installation notes](https://github.com/novuon/mbp2019-omarchy/tree/dc5e48b9a3073505161d98aaee3f999423e7ff59) are a separate dependency, not bundled or installed by this contribution. The helper checks model/vendor/device, waits up to 60 seconds for the DPM endpoint, requests `low`, verifies it, and records state in `/run/mbp2019-amdgpu-power`; the oneshot is ordered before the graphical session. The audited boot verified it, but cold-boot testing of the newly added controller remains outstanding.

Earlier local testing of DPM `auto` was followed by an unresponsive SMU, SDMA timeout, and GPU reset. This is historical evidence for this board/topology, not a universal Navi 14 diagnosis; the failure was not deliberately reproduced in the new tests. A previous helper that selected DPM/runtime-PM `auto` is superseded and must not be copied from older staging files.

The new controller uses only the existing `low` and `high` settings. It does not write voltages, clock tables, fans, power caps, or PCI runtime-PM controls. The tested GPU cap remains 50 W. Its exact source is [mbp2019_amdgpu_demand.py](macbookpro16-1/mbp2019_amdgpu_demand.py), with SHA-256 `e7b02410541e9ff94d1a340380ea2b169efb0655751048c365264f2f7393fe9d`, matching the installed source during validation.

| Policy input | Response |
| --- | --- |
| Sampling | One sample per second |
| At least 70% GPU activity in two adjacent samples, at least one elapsed second apart | Permit `high`, subject to low-state cooldown and thermal guard |
| At most 3% activity continuously for 10 seconds | Return to `low` once the 12-second minimum high hold has elapsed |
| Recently returned to `low` | Wait at least 8 seconds before collecting a new boost trigger |
| Edge temperature at least 80°C or junction at least 90°C | Force `low` at the next sample, overriding the high-state hold |
| Thermal recovery | Require 30 continuous seconds at edge at most 70°C and junction at most 80°C before allowing another boost |
| Invalid/missing readings, changed power cap/runtime-PM policy, another DPM writer, missed sleep coordination | Exit with best-effort low-state recovery; do not automatically retry |

These are chosen conservative operating thresholds, not manufacturer's specifications or measured optimal values. The widely separated activity thresholds avoid immediately downshifting when higher clocks reduce utilization. The tradeoff is that moderate ongoing activity above 3% can retain `high`; this is not a continuous hardware governor that optimizes every workload. No application allowlist is consulted.

Live mode requires root, exact DMI/PCI/subsystem/driver matches, an identifiable AMD sensor directory, a cap no greater than 50 W, runtime-PM `on`, and a starting DPM state of `low`. A process lock prevents duplicate instances. The service starts/stops through the low-state helper, uses `Restart=no`, binds its lifetime to `thermald` and `t2fanrd`, and restricts sysfs writes to the DPM endpoint. Binding to a running cooling service is not proof of physical fan health. Status updates go to `/run/mbp2019-amdgpu-demand/status.json`; persistent journal heartbeats are once per minute plus transitions.

The sleep guard stops an active controller before `sleep.target` and verifies `low`. After wake it restarts only a controller it previously stopped, preserving a manually stopped state. Its required relationship to the sleep target makes a failed preparation an explicit sleep failure instead of proceeding unguarded. Clock comparison in the controller also detects an uncoordinated sleep longer than two seconds and stops conservatively. These checks cannot recover a hung GPU or guarantee every suspend path.

Installed/reference mapping:

| Reference artifact | Installed location or use |
| --- | --- |
| [Controller](macbookpro16-1/mbp2019_amdgpu_demand.py) | `/usr/local/libexec/mbp2019_amdgpu_demand.py`, root-owned, mode 0755 |
| [Demand unit](macbookpro16-1/mbp2019-amdgpu-demand.service) | `/etc/systemd/system/mbp2019-amdgpu-demand.service`, root-owned, mode 0644; enabled for `multi-user.target` |
| [Sleep helper](macbookpro16-1/mbp2019-amdgpu-sleep) | `/usr/local/libexec/mbp2019-amdgpu-sleep`, root-owned, mode 0755 |
| [Sleep unit](macbookpro16-1/mbp2019-amdgpu-sleep.service) | `/etc/systemd/system/mbp2019-amdgpu-sleep.service`, root-owned, mode 0644; required by `sleep.target` |
| [Policy tests](macbookpro16-1/test_policy.py), [controller tests](macbookpro16-1/test_controller.py) | Local unit tests with mocked hardware, not installed services |
| [Rendering check](macbookpro16-1/verify-installed-demand) | Optional 25-second real GPU workload followed by idle recovery; not an automatic test |
| [Rollback helper](macbookpro16-1/rollback-demand-controller) | Disable new automatic policy and restore the pre-existing fixed-low service |

The new units were installed only after a saved-work session, a bounded low/high/low trial, and temporary-controller tests. The local installer refused existing destinations, required active cooling services and `low`, verified the units, installed root-owned files, reloaded systemd, enabled both units, and checked the running controller. There is intentionally no one-command installer in this reference contribution: the existing boot helper, exact hardware, topology, permissions, and absence of competing writers must be reviewed first. It is not standalone out of the box on a stock Omarchy installation.

On another matching machine, review all artifacts and dependencies, save work, verify the baseline and a bounded transition, and test a temporary policy before choosing to install the files at the destinations above. Do not overwrite an existing custom service or turn on DPM `auto` as a shortcut. A non-writing observation mode is available with `python3 mbp2019_amdgpu_demand.py --seconds 60`, but still requires the matching hardware and low-state prerequisites.

### 5. Keep GPU selection separate from clock scaling

An app already using AMD receives the clock policy automatically. An Intel application is not migrated to AMD when it becomes busy. Select the renderer in the application or save a per-app launcher preference. For a one-off Mesa check, the tested PCI selector is:

```bash
DRI_PRIME=pci-0000_03_00_0 glxinfo -B
DRI_PRIME=pci-0000_03_00_0! vulkaninfo --summary
```

[Mesa documents the PCI-address selector and Vulkan `!` suffix](https://docs.mesa3d.org/envvars.html#envvar-DRI_PRIME). Confirm the renderer in actual games; a RetroArch GPU index alone does not identify the device. No per-session command is needed for clock control after the service is enabled, but application GPU selection remains separate.

Runtime PM is also separate: this Radeon reports `power/control=on`, `runtime_status=active`, and no accumulated runtime-suspended time at the initial audit. **Approximately 4 W is low-clock idle, not full power-off.** The controller intentionally leaves that policy alone. Kernel documentation distinguishes [AMD clock controls](https://docs.kernel.org/gpu/amdgpu/thermal.html#power-dpm-force-performance-level) from [runtime PM](https://docs.kernel.org/power/runtime_pm.html). No `vgaswitcheroo` power-off service or experimental firmware was installed.

### 6. Video decoding and browser-specific tuning

The global `LIBVA_DRIVER_NAME=iHD` export was removed from the UWSM snippet after backing it up. The variable was also cleared from the user systemd manager for subsequently launched services. Existing applications can retain inherited values until restarted; no forced logout was performed. Device-targeted `vainfo` initialized Intel iHD and AMD radeonsi with the global override absent. This removes an inappropriate global restriction; it is not proof of lower video-playback power.

An earlier Zen-specific setting is retained in that browser profile's `user.js`:

```javascript
user_pref("media.av1.enabled", false);
```

This was intended to avoid software AV1 decoding on the Intel graphics path. It is browser-specific, changes codec negotiation, and was not independently power-benchmarked. It is not proposed as an Omarchy-wide browser default. Remove the user.js override and reset the corresponding browser preference to roll it back; merely deleting the user.js line may leave the preference in prefs.js.

### 7. Cooling, wireless, USB, and boot compatibility

`thermald` and `t2fanrd` remain active. The existing `/etc/t2fand.conf` is unchanged:

```ini
[Fan1]
low_temp=55
high_temp=75
speed_curve=linear
always_full_speed=false

[Fan2]
low_temp=55
high_temp=75
speed_curve=linear
always_full_speed=false
```

No undervolting, fan-speed reduction, clock-table modification, CPU turbo disable, or GPU power-cap increase was performed. This fan curve is a retained reference setting, not a newly established best curve for every MacBook.

A legacy `/usr/local/libexec/t2-power-tune` now changes only Wi-Fi power saving; it no longer writes GPU policy. Its intended behavior is `iw ... set power_save on` on battery and `off` on AC. `/etc/udev/rules.d/99-wifi-powersave.rules` invokes it through a collected transient `t2-power-tune` systemd unit on Mains/USB power-supply events. Its comments still mention the older fixed-low GPU policy, but the code contains no GPU write. NetworkManager's existing `wifi.powersave=2` also disables Wi-Fi power saving. The final publishing audit found effective Wi-Fi power saving **off**; the intended battery override, reconnect behavior, latency, and connectivity have not been validated. These overlapping settings are recorded, not recommended as a proven optimization, and no Wi-Fi energy saving is claimed.

Similarly, two existing modprobe snippets request `options usbcore autosuspend=-1`, but `/sys/module/usbcore/parameters/autosuspend` read **2** in the publishing audit. Configuration text must not be confused with effective state; individual USB devices can have their own policies. No USB autosuspend change or peripheral validation was performed in this contribution, and the mismatch remains unresolved.

The existing boot configuration includes `pm_async=off`, `mem_sleep_default=deep`, and `initramfs_async=0`; the active sleep selection is `deep`. These compatibility settings were retained, not proved individually necessary by A/B testing. A prior Thunderbolt/kernel/ASPM experiment is not retained. There is no new ASPM-forcing parameter, kernel patch, or firmware modification in this work. Earlier notes mention other backlight/Touch Bar work, but those are not new verified power fixes and are not bundled as settings to apply.

## Validation record

### Hardware checks completed

1. Accelerated OpenGL initialized on Intel by default and on PCI-selected AMD. VA-API initialized with the matching driver for each device.
2. An eight-second manual high-clock check on AC returned safely to low. GPU sensor readings were approximately 15 W high-idle versus 4 W low-idle. This was brief, not an equilibrium thermal or energy benchmark.
3. A short low-state Vulkan workload established that the GPU was busy enough to exercise the policy; this was not a paired FPS benchmark.
4. Two synchronized 25-second Vulkan workload/idle cycles with a temporary controller automatically boosted and recovered. Sampled peaks in these cycles were 71°C edge, 73°C junction, and approximately 22–25 W GPU power.
5. A third cycle on AC verified the installed service, including actual DPM writes under its systemd restrictions.
6. A non-suspending sleep-hook test correctly stopped/restored an active controller and did not resume one that had been manually stopped.
7. A fourth rendering/idle cycle passed on battery after physically unplugging AC.
8. One actual suspend/resume passed at 14:58:59–14:59:47 local time. The successful-suspend counter increased from 0 to 1, with failure count still 0. The screen was locked using Omarchy's lock handshake. A temporary RTC wake alarm was no longer set afterward.
9. A fifth rendering/idle cycle passed on battery after wake: activity reached 99%, sampled GPU power reached 26 W, and idle recovered to approximately 4 W.
10. Targeted kernel-log searches throughout the transition tests found no new SMU failure, ring timeout, GPU reset, or CATERR matches. That is a scoped result, not a claim of an entirely error-free journal.

The workload was `vkcube --wsi wayland --width 1600 --height 1000 --present_mode 0`, with `DRI_PRIME=pci-0000_03_00_0!` and no inherited libva override. Rendering was bounded to 25 seconds, followed by 15 seconds for idle recovery. The [verification script](macbookpro16-1/verify-installed-demand) records the exact command and assertions. Save work before any actual hardware test; it opens a window and exercises the Radeon, and must not run as an unattended CI job. A simple cube is not representative of every emulator core, shader, game, or sustained thermal workload.

An early temporary trial expired while waiting for interactive authorization and therefore tested only idle; it is not counted among the five rendering cycles. The later tests synchronized workload launch with a running controller.

Vulkan enumeration also reported a direct-display surface without modes and an Intel device-open warning. The initial boot log contained AMD display-stream initialization failures. These remain undiagnosed even though the explicit Wayland rendering tests succeeded; they are not silently treated as fully fixed.

### Software and overhead checks

All 17 policy/controller unit tests passed. They cover load/idle hysteresis, thermal override and recovery, malformed readings, sensor loss restoring low, missed sleep restoring low, rejected DPM modes, and non-root live-mode rejection. The tests mock hardware and do not write real sysfs controls:

```bash
cd docs/hardware/macbookpro16-1
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest -v test_policy test_controller
```

`systemd-analyze verify` passed for the installed-context unit definitions. The controller source matched the installed file byte-for-byte. systemd recorded 5.144 seconds of CPU use over 58 minutes 51.850 seconds before a test restart, approximately 0.15% of one core on average, with 11.6 MB peak memory. This is process overhead, not a measurement of additional wakeup energy or whole-laptop efficiency.

For this reference contribution, `git diff --check`, the fenced Bash syntax checks, all relative documentation links, the three shell artifacts' syntax checks, and the 17 copied unit tests passed. The exact copied unit definitions also passed host `systemd-analyze verify`. `./test/all` was run: CLI passed, but 9 of 244 shell test files failed (`config`, `factory-reset-accounts`, `launch-about`, `locate`, `network-qr`, `omarchy-kernel-migration`, `snapper`, `unowned-system-paths`, and `update-pacman`), the same file set recorded during the earlier documentation audit. Some packaging checks require a missing sibling `omarchy-pkgs` checkout; the remaining failures have not been diagnosed here. Compositor-dependent tests were skipped in the sandbox. This is explicitly not a clean full-suite run, and no graphical acceptance suite was run on the live desktop.

## Rollback and recovery

The original fixed-low preparation service is deliberately preserved. From the reference directory, after reviewing the helper, a visible terminal can disable only the new automatic controller:

```bash
sudo bash rollback-demand-controller
```

It stops/disables the sleep guard first so a pending post-sleep action cannot restart the controller, stops/disables the demand unit, restarts the original low-state service, and verifies DPM `low`. It retains all installed files for inspection. If a command fails, inspect the services and actual DPM state instead of assuming rollback completed. Do not change to DPM `auto` as recovery on a board where it previously caused a reset.

To undo earlier configuration changes, restore the saved UWSM/monitor/gmux files only after checking for later edits. A new login is required for session environment changes; gmux changes also require rebuilding the boot image and rebooting. Restoring the old power-profile udev rule would deliberately reintroduce duplicate policy ownership and is not the preferred steady state. Browser rollback is described above. No packaged file under `/usr/share/omarchy` was modified.

## Outstanding checks before broader adoption

- Cold boot with the newly enabled controller. Unit configuration and enablement were checked; no reboot was forced after installation.
- Longer sessions with real RetroArch cores/shaders and other games, including workloads that do not cross the chosen utilization threshold or remain moderately busy afterward.
- Repeated suspend/resume, suspend drain, lid/dock behavior, Touch Bar, audio, input, and other peripherals. One successful system sleep does not establish all T2 compatibility.
- External monitors and an Intel-first/AMD-second compositor configuration. The tested Intel-only list excludes AMD-connected outputs.
- Whole-machine battery A/B measurements at fixed brightness, workload, network, and peripherals, with diagnostic processes stopped and battery health recorded. Earlier UPower samples of about 22.9–29.5 W were taken during active diagnosis, not controlled idle measurements.
- Distinct saved AC/battery profile transitions; both preferences currently equal balanced, so merely unplugging does not prove profile switching to different values.
- Resolve the effective Wi-Fi/USB policy discrepancies, plus the remaining Vulkan/display-stream warnings, before describing them as optimized or clean.
- Revalidation after kernel, Mesa, systemd, or power-management updates. Hardware checks and service restrictions reduce scope; they do not make driver transitions risk-free.

The upstream benefit is a reproducible model-specific reference: separating GPU routing, application selection, clock limits, runtime suspension, and desktop policy ownership prevents misleading advice. The controller is a reviewable workaround for this board's recorded constraint, not a replacement for fixing native driver power management or evidence of maximum attainable battery life.
