# Plan: Boot time — show "Time taken to boot" on every boot

Revision 1. Drafted against `origin/quattro` at 8ea51516 (the fingerprint branch in this checkout is 6420 commits behind and is not the base for this work).

## Problem

Omarchy tells the user nothing about how long the machine took to come up. The data is already there — systemd records firmware, loader, kernel and userspace timestamps, and Hyprland knows the moment the desktop starts — but nobody stitches it together or shows it. A user who wants to know whether a kernel update, a new initramfs hook, or a firmware setting made boot slower has to remember to run `systemd-analyze` by hand, and even that stops at `graphical.target`, before SDDM, Hyprland and the shell have started.

The ask: on every boot, once the desktop is up, show a notification reading `Time taken to boot: 43s`.

## What "time taken to boot" means

Power button to usable desktop, as one number in whole seconds. Measured on this machine (`slovakdirect`, Omarchy 4.0.0.r2083, UKI via limine, LUKS root, SDDM autologin):

| Phase | Source | This machine |
|---|---|---|
| Firmware + loader (pre-kernel) | `systemctl show -p FirmwareTimestampMonotonic` (µs) | 26.9s |
| Kernel + initrd + userspace to `graphical.target` | `/proc/uptime` at the moment Hyprland starts | 16.1s |
| Desktop startup (Hyprland → shell up) | `/proc/uptime` when the notification fires, minus the above | ~2–4s |
| **Total** | pre-kernel offset + `/proc/uptime` at Hyprland start | **~43s** |

Two facts drive the design:

- `CLOCK_MONOTONIC` (what `/proc/uptime` reports) starts at kernel entry, so everything before the kernel has to come from systemd's firmware/loader timestamps. Those are only populated on EFI boots where the loader passes them along (limine does here). When `FirmwareTimestampMonotonic` is `0` the number is "since kernel start" and the notification says so.
- `hyprland.start` fires on every Hyprland start, not just the first after boot: logout/login, a compositor crash, or `omarchy dev link` reboots all re-run `autostart.lua`. Without a once-per-boot guard, a re-login at 3pm would announce a "boot time" of nine hours.

Caveat that stays in the docs, not in the code: if the LUKS passphrase is typed in the initrd, the time the user spends typing it is inside the kernel/initrd phase and inside the total. There is no clean way to subtract it, and pretending otherwise would misreport. The breakdown line lets the user see it.

## Rejected approaches

- **Parse `systemd-analyze time` text output.** Human-formatted, locale-sensitive, changes shape when initrd is or is not reported separately, and stops at `graphical.target` — it does not know when the desktop was actually usable. `systemctl show -p …Monotonic --value` gives the same numbers as plain integers.
- **Post-boot hook sample only** (`config/omarchy/hooks/post-boot.d/boot-time.sample`, like `weather.sample`). Opt-in by design: the user has to rename the file, and existing installs only receive new samples through the config refresh manifest. The request is "every boot", which means on by default. A sample is kept as the fallback if upstream does not want it default-on (see Rollout).
- **Bar widget** (Quickshell QML under `shell/plugins/bar/widgets/`). Persistent display is nice but it is a second product: manifest, QML, shell tests, visual verification in a VM, and a `shell.json` layout change for existing users. Listed as a follow-on, not the first cut.
- **fastfetch line** (`/etc/fastfetch/config.jsonc` already has `uptime`). Only appears when a terminal opens, and not on boot.
- **Measuring at the end of the `sleep 2 && omarchy-hook post-boot` line.** Simplest, but folds the 2s sleep plus whatever the user's own post-boot hooks take into the number. Recording the timestamp at the top of `hyprland.start` and notifying later keeps the measurement honest and the display reliable (the notification daemon is part of `omarchy-launch-shell`, which is not up yet at the top of `hyprland.start`).
- **systemd user unit / timer instead of Hyprland autostart.** `graphical-session.target` is reached before Hyprland has finished starting the shell, and the repo's convention is that desktop-start work lives in `default/hypr/autostart.lua`.

## Design

### New command: `bin/omarchy-system-boot-time`

Joins the existing `system` group (`omarchy system stats`, `omarchy system lock`, …), so it is `omarchy system boot time` on the CLI. Bash, `#!/bin/bash`, metadata comments per `agents/skills/command-metadata.md`:

```bash
# omarchy:summary=Show how long this boot took, from power-on to desktop
# omarchy:group=system
# omarchy:args=[--record|--notify|--breakdown]
```

Modes:

- **`--record`** (hidden from users in practice; called from autostart). Reads `/proc/sys/kernel/random/boot_id`, `/proc/uptime` and `FirmwareTimestampMonotonic`. If `~/.local/state/omarchy/boot-time` already holds this `boot_id`, exits 0 without touching it — this is the once-per-boot guard. Otherwise writes:

  ```
  boot_id=<uuid>
  prekernel_us=<FirmwareTimestampMonotonic>
  desktop_uptime=<first field of /proc/uptime>
  finish_us=<FinishTimestampMonotonic>
  notified=0
  ```

  `~/.local/state/omarchy/` is the directory the repo already uses for per-user runtime state (`first-run.mode`, `migrations/`, `toggles`), and unlike `$XDG_RUNTIME_DIR` it survives a logout, which is exactly the case the guard exists for.

- **`--notify`**. Reads the state file. If `boot_id` does not match the running kernel's or `notified=1`, exits 0 silently. Otherwise sends, via `omarchy-notification-send` (never `notify-send`, per AGENTS.md):

  ```
  headline:    Time taken to boot: 43s
  description: firmware 19.0s · loader 7.9s · kernel 11.6s · system 4.4s · desktop 3.1s
  urgency:     low   glyph: 󱎫 (or whatever the icon-font has for a stopwatch/rocket)
  ```

  then rewrites the state file with `notified=1`. The headline is the thing the user asked for; the breakdown is what makes the number actionable.

- **no args** (terminal use). Prints the same headline and breakdown to stdout from the state file, so `omarchy system boot time` answers the question later in the day. If no state file exists for this boot (e.g. on a machine where autostart has not run), it computes a "since kernel start" figure from live data and says so.

Arithmetic (all integer microseconds until the final format, `awk` or bash `(( ))`, no `bc`):

```
total_s    = (prekernel_us / 1e6) + desktop_uptime
firmware_s = (prekernel_us - loader_us) / 1e6
loader_s   = loader_us / 1e6
kernel_s   = userspace_us / 1e6                   # kernel + initrd (+ LUKS prompt)
system_s   = (finish_us - userspace_us) / 1e6     # userspace until systemd finished
desktop_s  = desktop_uptime - finish_us / 1e6     # SDDM + Hyprland + shell
```

When `prekernel_us == 0` the headline becomes `Time taken to boot: 16s (since kernel start)` and the firmware/loader terms are dropped from the breakdown.

### Wiring: `default/hypr/autostart.lua`

```lua
hl.on("hyprland.start", function()
  hl.exec_cmd("omarchy-system-boot-time --record")   -- first line: stamp "desktop started"
  ...existing lines unchanged...
  -- Run post-boot hooks after startup config has loaded.
  hl.exec_cmd("sleep 2 && omarchy-hook post-boot")
  hl.exec_cmd("sleep 2 && omarchy-system-boot-time --notify")
end)
```

`--record` is two file reads and one `systemctl show`; it does not delay the shell launch measurably. `--notify` is a separate `exec_cmd` rather than chained onto the hook line so a slow or failing user hook cannot suppress it.

### Docs and metadata

- `manual/10-notices.md` or `manual/14-omarchy-cli.md`: one paragraph on the boot-time notification and `omarchy system boot time`, including the "includes your passphrase typing time" caveat.
- `GROUP_DESCRIPTIONS[system]` in `bin/omarchy` already reads "System status, reboot, shutdown, logout, and lock" — no change needed.
- No migration: the command ships in `bin/` (covered by `$OMARCHY_PATH`) and the autostart change is in `default/hypr/`, which every install reads directly. Nothing lands in `~/.config`.

### Tests

- `./test/cli` already validates metadata for every file in `bin/`; the new command must pass it (routing to `omarchy system boot time`, help text present).
- Add a focused test alongside the CLI suite that runs `omarchy-system-boot-time --notify` with `HOME` pointed at a temp dir and a fabricated state file, and asserts: (a) mismatched `boot_id` → no notification call and exit 0; (b) `notified=1` → no call; (c) fresh file → one call with a headline matching `^Time taken to boot: [0-9]+s`. `omarchy-notification-send` is stubbed via `PATH` (the suite already exports `$ROOT/bin` first, so a temp bin ahead of it works).
- Manual: `omarchy dev link ~/Work/omarchy` (see Rollout), reboot, confirm the toast, then `omarchy system logout` → log in → confirm **no** second toast, then `omarchy system boot time` in a terminal prints the same figure.

## Rollout

1. In `~/Work`, this checkout (`omarchy-fingerprint`) is on `fix/fingerprint-edge-driver`, 6420 commits behind `origin/quattro`. Don't build on it. Either add a worktree — `git worktree add ../omarchy-boot-time -b feat/boot-time origin/quattro` — or clone fresh into `~/Work/omarchy`. Keep the fingerprint branch untouched.
2. Implement `bin/omarchy-system-boot-time`, the autostart change, the test, the manual paragraph. Four files, one atomic commit per AGENTS.md ("succinct, one coherent change").
3. `./test/cli` locally. Then `omarchy dev link <checkout>` and reboot to verify on this machine (the link only affects `$OMARCHY_PATH` trees, and both `bin/` and `default/hypr/` are covered, so no package rebuild is needed). `omarchy dev unlink` when done.
4. Push `feat/boot-time` to `fork` (`powderluv/omarchy`) and open a PR against `omacom/omarchy:quattro`. If maintainers want it opt-in rather than default-on, the fallback is mechanical: drop the `--notify` line from `autostart.lua`, keep `--record`, and add `config/omarchy/hooks/post-boot.d/boot-time.sample` containing `omarchy-system-boot-time --notify`. The command and the once-per-boot guard stay the same either way.

Follow-ons, only if wanted after the first cut lands:

- A hotkey notice (`Super + Ctrl + Alt + …`) that re-shows the boot-time toast, matching the date/weather/battery notices in `manual/10-notices.md`.
- A bar widget that shows the figure for the first N minutes after boot, then hides.
- Keeping a per-boot history in the state file so the toast can say "3s slower than last boot".

## Open questions

- Should the toast auto-dismiss (`-t 8000`) or stay until clicked, like the weather sample (default `-1`)? Draft uses the default so a user who looked away still sees it.
- Glyph: the repo's icon font is in `default/fonts/omarchy/omarchy.ttf`; pick an existing Nerd Font stopwatch glyph rather than adding one (`agents/skills/icon-font.md` is for branded glyphs only).
- Whether upstream wants the breakdown in the description at all, or just the headline. Cheap to strip.
