# Hermes Desktop Recovery — Verification Checklist

Use after any desktop fix attempt. Check each item before declaring the desktop healthy.

## Path & Launch

- [ ] `pacman -Q hermes-desktop` — package is current (`omarchy-update`)
- [ ] `pgrep -af "linux-unpacked/Hermes"` — process running from unpacked build when available

## Env Vars & GPU

- [ ] On weak NVIDIA (≤4 GiB): `HERMES_DESKTOP_DISABLE_GPU=1` in `/proc/<pid>/environ`
- [ ] `HERMES_DESKTOP_IGNORE_EXISTING` NOT set
- [ ] With DISABLE_GPU: `ps aux | grep Hermes | grep -- '--type=gpu-process'` is empty

## Logs (no errors since last launch)

- [ ] `rg 'predates server' ~/.hermes/logs/gui.log | tail` — empty
- [ ] `rg 'IGNORE_EXISTING' ~/.hermes/logs/desktop.log | tail` — empty
- [ ] `rg 'skew' ~/.hermes/logs/desktop.log | tail` — empty
- [ ] `rg 'GPU process.*failed|error_code=1002|FATAL.*GPU' ~/.hermes/logs/desktop-chromium.log` — empty since last launch

## Backend

- [ ] `rg 'backend listening' ~/.hermes/logs/desktop.log` shows a port
- [ ] Backend HTTP responds: `curl -s http://127.0.0.1:<port>/` returns 200

## No new crashes

- [ ] `coredumpctl list | rg Hermes | tail -5` — no SIGTRAP since last launch

## Skill integration

- [ ] `~/.hermes/skills/hermes-desktop-recovery` links to Omarchy default agents skills
- [ ] SIA/MEMORY note persisted for the host-specific GPU choice
