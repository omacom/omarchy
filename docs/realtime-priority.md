# Realtime scheduling

Audio and video want threads at `SCHED_FIFO`/`SCHED_RR`, and the budget for those threads does not come from the app that asks for one. It comes from `rtkit-daemon` through `xdg-desktop-portal`, and `libpipewire-module-rt` turns it into the process's `RLIMIT_RTTIME` and `RLIMIT_RTPRIO` before PipeWire starts its threads:

```
rtkit-daemon
  └─ xdg-desktop-portal (org.freedesktop.portal.Realtime)
       └─ libpipewire-module-rt (module-rt in client.conf)
            └─ RLIMIT_RTTIME and RLIMIT_RTPRIO on every PipeWire client
```

Two properties describe the budget: `RTTimeUSecMax`, the per-thread realtime runtime, and `MaxRealtimePriority`, the highest realtime priority allowed. With `rtkit` installed the portal answers `200000` and `20`. Without it the portal answers `0` and `0`, because the daemon that grants the budget is not there to ask.

## Why a missing rtkit kills apps

A zero budget is not a refusal. `module-rt` applies it as a hard `RLIMIT_RTTIME` of `0` on the client, and the kernel's realtime watchdog (`check_thread_timers` → `check_rlimit` in `kernel/time/posix-cpu-timers.c`) sends `SIGKILL` the first time a thread passes through the per-thread CPU-timer path, since the accumulated runtime is trivially `>= hard`.

That kill is easy to misread:

- It comes from the kernel in the victim's own context (`SI_KERNEL`), so no journal line names a sender.
- It leaves no core dump, `systemd-oomd` never logs a kill, and the cgroup OOM counters stay at zero.
- Chromium and Electron report it as `reason: 'killed', code: 9`, the same `9` a crashed Chrome tab shows as "Aw, Snap!".

The shell is a PipeWire client, so this is not confined to audio. `omarchy-shell` takes the zero limit at startup, every app launched from the launcher inherits it, and so does everything those apps start — a terminal opened from the menu carries the zero into its shells. Browsers, editors and Electron apps then die at random, while an app started from a Hyprland keybinding descends from Hyprland instead and keeps `unlimited`.

## The invariant

`rtkit` belongs in the base install on every platform, and `xdg-desktop-portal` has to be restarted after it is installed, because the portal caches the budget when it starts:

```bash
sudo pacman -S rtkit
systemctl --user restart xdg-desktop-portal.service
omarchy-restart-shell
```

The shell only picks up the new budget when it restarts, and apps already running keep the old limit until they are relaunched, or until `prlimit --pid <pid> --rttime=unlimited:unlimited` is applied to each of their processes as root, zygotes included.

`rtkit` has to come from the base list. `install/omarchy-aarch64.packages` carries it with a comment saying nothing else pulls it in; the x86 lists cannot rely on a platform-specific file for it.

## Checking an install

```bash
busctl --user get-property org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop \
  org.freedesktop.portal.Realtime RTTimeUSecMax
grep 'Max realtime timeout' /proc/"$(pgrep -x quickshell | head -1)"/limits
```

Both should report `200000`, or `unlimited` from the workaround below. A `0` in either place means every app launched from the menu is exposed.

## Working around it without root

Stopping the kills does not need `rtkit`. Keeping `module-rt` out of the shell's process is enough, since the module cannot set a limit it never applies:

```bash
mkdir -p ~/.config/pipewire/client.conf.d
echo 'context.properties = { module.rt = false }' \
  > ~/.config/pipewire/client.conf.d/50-no-module-rt.conf
omarchy-restart-shell
```

`RLIMIT_RTTIME` then stays `unlimited`. The cost is that no client gets realtime scheduling, which is already the case without `rtkit`: `module-rt` logs `failed to set realtime policy: Operation not permitted` and only the portal's budget, zero, reaches the process. Install `rtkit` and remove the drop-in when root is available.
