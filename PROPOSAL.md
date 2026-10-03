# Night light: location-aware scheduling

## What this PR adds

Two flags on `omarchy-toggle-nightlight`:

- `omarchy toggle nightlight --setup` — write `~/.config/hypr/hyprsunset.conf`
  with sunrise/sunset profiles at the user's location, and start hyprsunset.
- `omarchy toggle nightlight --reset` — restore Omarchy's stock conf (the
  no-tint default) and back up any user edits.

A migration that runs `--setup` once on `omarchy update` for existing users,
plus a single menu entry under `Setup → Config → Nightlight Schedule`.

The bare toggle (`omarchy toggle nightlight`) and `--status` are unchanged
from upstream.

## Why

The current stock `hyprsunset.conf` ships with a single `time = 07:00
identity = true` profile — i.e. **night light does nothing by default**. The
night-tint profile is commented out. Users who want any tint have to hand-edit
the conf.

This PR keeps the hand-edit path available (just edit `hyprsunset.conf` directly)
and adds `--setup` for the much more common case: "I want my screen to tint at
my actual sunset, not at 8 PM, and I don't want to think about it."

## How it works

The bare toggle (`omarchy toggle nightlight`) keeps the existing upstream
behavior: flip between on/off temperatures on the running hyprsunset.

`--setup` does three things:

1. Resolve the user's location. Prefers the stored
   `~/.local/state/omarchy/settings/weather.json` (set by
   `omarchy weather location --set`); falls back to `omarchy-weather-location`,
   which does wttr.in IP-detection when nothing is stored.
2. Fetch today's sunrise/sunset from Open-Meteo for those coords. Times come
   back in UTC ISO 8601; `date -d` converts to machine-local HH:MM.
3. Write `~/.config/hypr/hyprsunset.conf` with two profiles at those times
   and start hyprsunset. hyprsunset's built-in profile scheduler applies each
   profile at its time daily, so there's no per-day timer needed.

`--reset` copies Omarchy's stock `config/hypr/hyprsunset.conf` into place,
backing up any existing user-edited conf as `hyprsunset.conf.bak.<ts>`.

## What we deliberately do NOT do

This is a deliberately small PR. Earlier revisions of this work added:

- A new state file at `~/.local/state/omarchy/settings/nightlight.json`
- A daily systemd timer to regenerate the conf every night
- A post-boot hook
- A `--mode` flag for manual vs. sunrise-sunset
- A `--day-temp` / `--night-temp` flag pair
- A menu submenu with mode + temperature entries
- A QML service reading custom temperatures from the state file
- An `OMARCHY_NIGHTLIGHT_DISABLED` env var

All of that was cut. The above list describes a feature with a daily-refresh
state machine, a migration with pruning logic, and a multi-mode CLI surface
for what is, fundamentally, "edit one config file once." None of it earns
its complexity. If a user wants a non-default temperature, they can edit
`hyprsunset.conf` directly. If they want to disable night light entirely,
they disable hyprsunset. There is no state to lose and no migration to
write.

The reviewer (an automated Opus + GPT-6 community review) flagged ten
substantive issues with the larger design, several of which broke the feature
silently for default-mode users. Cutting the surface eliminates the
corresponding failure modes.

## Files changed

```
bin/omarchy-toggle-nightlight        +157 lines   (--setup / --reset added; toggle unchanged)
migrations/1790000000.sh             +29 lines    (one-shot --setup on omarchy update)
default/omarchy/omarchy-menu.jsonc   +1 line      (Setup → Config → Nightlight Schedule)
test/shell.d/nightlight-test.sh      +122 lines   (covers --setup / --reset / polar / no-network)
```

Total: **+309 lines, -1 line.**

## Reviewer findings (from the prior PR #12571 review)

All ten reviewer findings are addressed by this design, mostly by virtue of
the feature surface being smaller:

| # | Finding | Resolution |
|---|---|---|
| 1 | `--refresh` aborts for users without stored weather.json | No `--refresh`. `--setup` is one-shot and prints a clear hint. |
| 2 | Fresh installs don't get the timer; first-run enable breaks existing units | No timer. No enable call. |
| 3 | Per-day timers fight hyprsunset's built-in profile scheduler | Single scheduler (hyprsunset's). No timers. |
| 4 | Manual mode overwrites hand-edited hyprsunset.conf | No manual mode. Hand-edits survive `--setup`'s no-op-on-existing check. |
| 5 | Toggle threshold wrong for unusual user values | Toggle unchanged from upstream — uses fixed 4000/6500. |
| 6 | Location times applied in machine TZ instead of location's | `--setup` asks Open-Meteo for UTC, converts via `date -d`. |
| — | Corrupt state recovery uses invalid jq | No state file. |
| — | `OMARCHY_NIGHTLIGHT_DISABLED` only honored by post-boot hook | No env var; disable hyprsunset. |
| — | `ipapi.co` not used elsewhere in Omarchy | wttr.in only, via `omarchy-weather-location`. |
| — | Literal `null` sunrise/sunset written into conf | `--setup` rejects null with exit 1 before writing. |

## Behavior matrix

| User state | `--setup` does |
|---|---|
| `weather.json` has lat/lon | Uses them. Writes conf. |
| `weather.json` has only a name | Geocodes via wttr.in, writes conf. |
| No `weather.json`, wttr.in reachable | IP-detects city, geocodes, writes conf. |
| No `weather.json`, wttr.in down | Exits 1 with `omarchy weather location --set` hint. |
| Polar region (lat > 66 or whatever) | Exits 1, no conf written, "polar region?" message. |
| `hyprsunset.conf` already exists with hand-edits | Skips. Migration is no-op; user runs `--setup` explicitly if they want to switch. |

## Trade-offs

- **No per-day refresh.** The schedule advances by month, not by day. Hyprsunset
  reads the conf at startup and applies each profile at its listed time daily;
  rewriting the conf would require either a daily timer (what we removed) or
  gammastep. This is what gammastep users tolerate when they set static
  times, and the precision difference vs. daily refresh is ~5 minutes
  month-to-month.
- **VPN.** wttr.in IP geolocation gives the VPN endpoint's location. Same as
  the upstream weather panel. If a user wants their home city while travelling,
  `omarchy weather location --set "Portland"` overrides.
- **No QML changes.** The bar indicator still shows "night light on" using
  the same `< 6000K` heuristic as upstream. The `--setup` night profile uses
  4000K so the indicator works out of the box.

## Migration behavior

The migration runs `omarchy toggle nightlight --setup` once. It is a no-op
if the user already has a hand-edited `hyprsunset.conf` (we detect this by
looking for the `# Generated by ...` marker our own writes leave behind).
On a headless run with no network, `--setup` fails silently and the user
can run it themselves later from a TTY. No blocker.

## Testing

`./test/shell.d/nightlight-test.sh` covers:
- Upstream `NightlightModel.js` and `--status` behavior (unchanged).
- Bare toggle flipping 6500 → 4000 → 6500 and nudging the shell nightlight service (unchanged).
- `--setup` from a stored `weather.json` writes a valid conf.
- `--setup` writes machine-local HH:MM (not raw ISO timestamps).
- `--setup` rejects literal-null sunrise/sunset (polar) without writing.
- `--setup` exits 1 with a useful hint when no location is reachable.
- `--reset` restores Omarchy's stock conf.
- `--reset` backs up the user's previous conf before clobbering it.

21 tests pass.

## Notes for maintainers

This replaces PR #12571. The earlier PR was significantly larger (8 files,
+755 lines) and added a state file, daily timer, mode switching, and a menu
submenu. The reviewer (Opus + GPT-6 community review) flagged ten issues,
several of which broke the feature silently for default-mode users. This
revision cuts the surface to the minimum that delivers the user-visible
benefit: a one-shot "set this up for me" command that schedules the screen
tint at the user's actual sunrise/sunset. Everything else (mode switching,
per-day timer, custom temperatures via CLI, OMARCHY_NIGHTLIGHT_DISABLED) was
complexity for its own sake.
