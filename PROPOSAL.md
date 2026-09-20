# Night Light: Sunrise/Sunset Mode

## What

Replaces Omarchy's static 07:00/20:00 night-light schedule with a
location-aware one. The new mode (default) auto-switches the screen tint at
the user's actual sunrise and sunset for the day. Static times remain
available via a `manual` mode.

## Why

The shipped `bin/omarchy-toggle-nightlight` toggles between two fixed
temperatures on a hand-edited `hyprsunset.conf` with two static profiles
(07:00 / 20:00). Users in non-UTC+0 timezones, or anyone who wants their
display tint to track daylight, currently have to hand-edit the conf
whenever they travel or the seasons change.

## User-facing changes

### Toggle menu: Nightlight now has a submenu

`Trigger → Toggle → Nightlight` used to be a single on/off toggle. It is
now a submenu with:

- **Toggle** — same one-key on/off as before (preserved for muscle memory)
- **Mode**
  - **Sunrise / Sunset** (default, ✓ shown when active) — auto-switch
  - **Manual** — fixed times, hand-edit `~/.config/hypr/hyprsunset.conf`
- **Day Temperature** — prompt for K value (1000..6500, current value shown)
- **Night Temperature** — same, for night

State file: `~/.local/state/omarchy/settings/nightlight.json`

### State persists across reboots and logouts

The mode and temperatures are saved; the daily systemd user timer regenerates
per-day sunrise/sunset timers at 04:00 (Persistent=true, so missed fires on
sleep are caught up on wake).

### Manual mode is still the original Omarchy UX

Setting mode to `manual` restores Omarchy's stock `hyprsunset.conf`
(`omarchy refresh hyprsunset`) and stops scheduling auto-switches. The
toggle and the SUPER+CTRL+N keybind continue to work.

### Bar indicator reads custom temperatures

The Quickshell nightlight service previously hardcoded 6500 / 4000K. With
this PR it reads `dayTemperature` / `nightTemperature` from the state file
via `omarchy toggle nightlight --status`, so the bar reflects user-set
values without restarting the shell.

## Files

| Path | Action |
|---|---|
| `bin/omarchy-toggle-nightlight` | modified — added `--mode`, `--day-temp`, `--night-temp`, `--refresh` flags; added per-day timer scheduling; added state file |
| `default/omarchy/omarchy-menu.jsonc` | modified — `trigger.toggle.nightlight` row becomes submenu |
| `default/systemd/user/omarchy-nightlight-refresh.{service,timer}` | new — daily 04:00 regeneration |
| `shell/plugins/services/nightlight/Service.qml` | modified — read custom temperatures from the state file |
| `migrations/1789855234.sh` | new — idempotent install of state, hook, daily timer, autostart |
| `install/user/first-run/enable-user-units.sh` | modified — enable the new daily timer for fresh installs |

User-side files (created on first `omarchy update` that runs the migration):

- `~/.local/state/omarchy/settings/nightlight.json`
- `~/.config/omarchy/hooks/post-boot.d/omarchy-nightlight-refresh`
- `~/.config/hypr/autostart.lua` gains `o.launch_on_start("hyprsunset")`

## Internal details

### State file schema

```jsonc
{
  "mode":            "sunrise-sunset",   // or "manual"
  "dayTemperature":  6500,
  "nightTemperature": 4000
}
```

Default mode is `sunrise-sunset` (per the feature request). The file is
absent on first run; the script creates it on first write.

### `--refresh` flow

1. Read coordinates from `~/.local/state/omarchy/settings/weather.json`
   (same file the weather widget uses). Fall back to IP geolocation.
2. Fetch today's sunrise/sunset from Open-Meteo (`forecast_days=2` to
   handle day rollover).
3. Overwrite `~/.config/hypr/hyprsunset.conf` with two profiles:
   identity at sunrise, current night temperature at sunset.
4. Generate per-day systemd user timers:
   `omarchy-nightlight-{sunrise,sunset}-<hash>.{service,timer}`.
   Hash on the times so unit filenames change daily. `Persistent=true`
   so missed fires on sleep are caught up on wake.
5. `daemon-reload` + `enable --now` for the new timers.

Exit codes:
- 0 success
- 1 invalid argument
- 2 state file could not be read or written
- 4 network/location lookup failed

### Manual mode flow

When mode is `manual`, `--refresh` (and the daily timer) restores Omarchy's
stock `hyprsunset.conf` from `$OMARCHY_PATH/config/hypr/hyprsunset.conf`
and clears all per-day auto-mode timers.

### Why `hyprctl hyprsunset temperature` instead of restarting hyprsunset

The existing toggle uses `setsid uwsm-app -- hyprsunset` when hyprsunset
isn't running, which can race with the uwsm-app daemon's systemd scope
cleanup (the new process receives SIGINT ~0.5s after starting). Avoiding
hyprsunset restarts entirely sidesteps this; the bar indicator's QML service
is told to refresh after each temperature change via
`omarchy-shell -q nightlight refresh`.

### QML service change

`Service.qml` gains a `settingsProbe` that calls
`omarchy toggle nightlight --status` at startup and uses the JSON's
`dayTemperature` and `nightTemperature` values (instead of the hardcoded
6500/4000) when applying temperatures. The properties change from
`readonly property int` to `property int` so the probe can write them.
Existing identity threshold check (`< 6000`) is preserved.

### Migration idempotency

All four steps are safe to re-run:
- State file: only created if missing
- Hook file: overwritten (content is idempotent)
- Daily timer: `enable --now` is harmless if already enabled
- Autostart: `grep -q` check prevents double-appending the line

### Disabling

`OMARCHY_NIGHTLIGHT_DISABLED=1 omarchy toggle nightlight --refresh` does
nothing. The post-boot hook also checks this env var.

## Privacy / network

Two outbound HTTPS calls in `--refresh`:
- `https://ipapi.co/json/` — only when `weather.json` is missing (one-time
  per session on a fresh install)
- `https://api.open-meteo.com/v1/forecast` — once per refresh

No telemetry. No tracking. Both are HTTPS to well-known geocoding / weather
providers already used by the Omarchy weather widget.

## Testing

- `omarchy toggle nightlight --help` shows the new flag surface
- `omarchy toggle nightlight --status` returns JSON with mode, day/night
  temperatures, identity threshold, and live state
- Setting `--mode` toggles between auto-mode (per-day timers scheduled)
  and manual mode (Omarchy stock conf restored, timers cleared)
- Setting `--day-temp` / `--night-temp` validates (1000..6500, integer)
  and triggers a refresh
- Bare invocation toggles between the configured day and night
  temperatures on the running hyprsunset, with the existing
  retry-until-it-sticks loop
- Manual fire of the per-day sunrise/sunset timers flips the live
  temperature correctly
- Manual fire of the daily refresh timer regenerates today's timers
  without leaving stale `WantedBy` symlinks (`disable --now` is run
  before `rm`)
- Migration is idempotent on re-run: state file preserved, autostart.lua
  not duplicated, systemd units re-copied

Verified on Omarchy 4.0.4 (older snapshot) with hyprsunset v0.4.0; rebased
onto `basecamp/quattro` for this submission.