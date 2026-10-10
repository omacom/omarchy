---
name: hermes-desktop-recovery
description: "Diagnose and fix Hermes Desktop launch failures, package↔agent skew, arity crashes, and SIGTRAP core loops on Linux."
version: 1.2.0
author: Hermes Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [hermes, desktop, electron, skew, crash, troubleshooting]
---

# Hermes Desktop Recovery

## When to Use

- Hermes Desktop fails to launch or crashes on startup
- Error: "Backend updated, but the desktop app package was not changed"
- Error: "client predates server→client requests"
- SIGTRAP cores from the Hermes Electron binary
- Wrapper arity mismatch (4-tuple vs 5-tuple launch options)

## Quick Diagnosis

```bash
# 1. Is the process running?
pgrep -af "linux-unpacked/Hermes"

# 2. Which launcher wins on PATH?
type -a hermes-desktop

# 3. Check logs for known failure signatures
rg -n 'predates server|IGNORE_EXISTING|skew|Fatal|GPU process' \
  ~/.hermes/logs/desktop.log ~/.hermes/logs/gui.log | tail -20

# 4. Any new cores?
coredumpctl list | rg Hermes | tail -5
```

## Root Causes (ordered by frequency)

### 1. Agent ↔ desktop package skew (most common)
The agent was updated via `hermes update` or git pull, but the desktop Electron shell is still the old pacman/pip package version. Symptoms:
- `Backend updated, but the desktop app package (AppImage/deb/rpm) was not changed`
- `the attached client predates server→client requests`
- SIGTRAP cores with bare `--disable-setuid-sandbox` cmdline

Fix: rebuild the unpacked shell from the matching agent checkout (see below).

### 2. Launch-options arity mismatch
The `hermes-cli` `_desktop_launch_options()` returns 5 values: `(flags, gpu, store, ozone, renderer_accessibility)`. Stock `/usr/bin/hermes-desktop` unpacks only 4. Fix: use the 5-tuple-safe wrapper.

### 3. HERMES_DESKTOP_IGNORE_EXISTING=1
This env var skips the installed runtime and sticks on first-run setup. Only set deliberately during initial install; remove for normal launches.

### 4. GPU process FATAL / SIGTRAP on weak NVIDIA (GTX 1050 class)
Chromium `GPU process launch failed: error_code=1002` → `GPU process isn't usable` → SIGTRAP.
ANGLE SwiftShader alone may still die after a while. The Omarchy wrapper soft-defaults software GPU when `nvidia-smi` reports ≤4 GiB VRAM:

```bash
export HERMES_DESKTOP_NVIDIA_SWIFTSHADER=1   # soft-defaulted on weak NVIDIA
export HERMES_DESKTOP_DISABLE_GPU=1          # required; SwiftShader alone is insufficient
# also in ~/.hermes/config.yaml under desktop:
#   disable_gpu: true
# Override on capable GPUs: HERMES_DESKTOP_DISABLE_GPU=0
```

Markers (Hermes-owned): `~/.config/Hermes/nvidia-egl-fallback.json`, `linux-gpu-fallback.json`.
If skew is resolved and crash persists with `int3`/TRAP, use `diagnose-crash` + `symbolize-core-dump`.

**Lesson (2026.10.06):** `HERMES_DESKTOP_NVIDIA_SWIFTSHADER=1` alone was INSUFFICIENT — crashed with GPU process `error_code=1002` / `FATAL: GPU process isn't usable`. The definitive fix was `HERMES_DESKTOP_DISABLE_GPU=1` (fully removes GPU process), combined with `--disable-setuid-sandbox --ozone-platform=wayland`.

## The Fix Procedure

### Step 1 — Rebuild the unpacked shell (resolves skew)

```bash
cd ~/.hermes/hermes-agent
hermes desktop --build-only --force-build
```

This writes to `~/.hermes/hermes-agent/apps/desktop/release/linux-unpacked/Hermes`. The wrapper natively prefers this path if the binary is executable.

### Step 2 — Verify the 5-tuple wrapper

File: `~/.config/omarchy/bin/hermes-desktop`

Ensure it:
- Unpacks with `if len(opts) >= 5: flags, gpu, store, ozone, renderer_a11y = opts[:5]` (not hard 4-tuple)
- Does NOT export `HERMES_DESKTOP_IGNORE_EXISTING=1` for normal launches
- Soft-defaults `HERMES_DESKTOP_DISABLE_GPU=1` (+ SwiftShader) when NVIDIA VRAM ≤4 GiB
- Sets `HERMES_HOME` correctly from the profile-aware path logic
- Inserts `--ozone-platform=wayland` when on Wayland

### Step 3 — Verify PATH order

```bash
type -a hermes-desktop
# ~/.config/omarchy/bin/hermes-desktop should be first hit
```

If not, fix shell `PATH` and uwsm environment. Optionally sync:
```bash
sudo cp ~/.config/omarchy/bin/hermes-desktop /usr/local/bin/hermes-desktop
sudo chmod +x /usr/local/bin/hermes-desktop
```

### Step 4 — Launch and verify

```bash
hermes-desktop &
sleep 8
# Backend should report a port:
rg 'backend listening' ~/.hermes/logs/desktop.log | tail -3
# No skew/predates lines since launch:
rg 'predates server|IGNORE_EXISTING' ~/.hermes/logs/desktop.log ~/.hermes/logs/gui.log | tail -5
```

### Step 5 — If SIGTRAP recurs after version match

Follow `diagnose-crash` skill fully:
```bash
core=$(mktemp -t hermes-XXXXXX.core)
trap 'rm -f "$core"' EXIT
coredumpctl dump <pid> --output="$core"
DEBUGINFOD_URLS="https://debuginfod.archlinux.org" \
  gdb -q /path/to/Hermes "$core" \
  -batch -ex 'set debuginfod enabled on' -ex 'bt' -ex 'thread apply all bt'
```

Then try GPU mitigations one at a time, recording which worked:
```bash
HERMES_DESKTOP_DISABLE_GPU=1 hermes-desktop
ELECTRON_OZONE_PLATFORM_HINT=x11 hermes-desktop
```

## What NOT to do

- Do **not** wipe `~/.hermes/state.db` to fix a desktop crash — the state DB is session state, not the crash cause. A backup exists from any `hermes update`.
- Do **not** set `HERMES_DESKTOP_IGNORE_EXISTING=1` on normal launch — it skips the backend runtime and traps you on first-run.
- Do **not** reinstall `/opt/hermes-desktop` unless the unpacked build is also broken — the wrapper prefers the unpacked binary over `/opt`.
- **Do not** edit `/usr/share/omarchy/` — it is read-only package tree. Use `~/.config/` overrides.
- **Do not** leave the stock pacman `/usr/bin/hermes-desktop` in place — it may still have `HERMES_DESKTOP_IGNORE_EXISTING=1` and a 4-tuple unpack. Replace or symlink it to `/usr/local/bin/hermes-desktop` to guarantee consistency across PATH resolution.

## After-fix persistence

Record a MEMORY bullet or SIA note:
```bash
sia note "Hermes Desktop: rebuilt unpacked shell from agent commit <sha>; wrapper 5-tuple safe; never set IGNORE_EXISTING on normal launch. Fix: hermes desktop --build-only --force-build." --from hermes
```

## Related skills

- `omarchy-workstation` — launcher wrapper location and PATH ordering
- `symbolize-core-dump` — core dump recovery when symbols are missing
- `diagnose-crash` — end-to-end crash diagnostic workflow
- `hermes-agent` → references/troubleshooting.md — general desktop issues
- `messaging-gateway-setup` → references/agent-fan-out.md — coordinating desktop
  fixes across multiple agent instances (Cursor, Codex, Grok) via local durable
  drop when external queues are unavailable

## References

- `references/desktop-recovery-checklist.md` — one-page verification checklist
- `references/wrapper-5-tuple.md` — the full working launcher wrapper
