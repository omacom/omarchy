---
name: omarchy-lab
description: Operate Omarchy Lab's disposable VM for guest-side development, branch deployment, checkpoints, screenshots, and debugging. Use when the user asks to use or test in Lab; do not redirect ordinary host customization or replace the Omarchy ISO acceptance harness.
---

# Omarchy Lab

Use the Lab guest to exercise authorized changes without changing the active host desktop. The native and standalone distributions normally control the same domain, disks, and state; installing both does not create two independent Labs.

## Find the controller

Set `LAB_SKILL` to the directory containing this SKILL.md (use the path supplied by the skill loader). The bundled `scripts/lab` helper prefers the installed standalone controller at `~/.config/omarchy/plugins/acrogenesis.lab/bin/omarchy-labctl`, then the native commands under the existing `$OMARCHY_PATH/bin`. It fails with installation guidance if neither exists; it never installs anything. If the user explicitly selects a distribution, invoke that controller directly.

Run these on the **host** to establish state before making changes:

```bash
bash "$LAB_SKILL/scripts/lab" viewer status --json
bash "$LAB_SKILL/scripts/lab" health --json
bash "$LAB_SKILL/scripts/lab" checkout list --json
```

Inspect `installed`, `domainRunning`, `viewerActive`, and health's `guest.reachable` separately. Successful JSON output can still report an unhealthy or absent guest. Health is bounded and read-only; do not use `vm ssh` or `vm session` for background polling because those paths can start a stopped VM and wait for SSH.

Do not assume the optional `omarchy-labctl` PATH symlink exists. Do not change the host checkout, dev-link the host, or re-export `OMARCHY_PATH` just to access Lab. Read command-specific help before unfamiliar operations:

```bash
bash "$LAB_SKILL/scripts/lab" checkout --help
bash "$LAB_SKILL/scripts/lab" checkpoint --help
```

## Start, deploy, and verify

When opening Lab is requested, use `viewer launch`: it starts a stopped guest, reopens its viewer, or focuses the existing viewer. Avoid standalone `launch` for mere discovery: that entry point can offer installation when Lab is absent.

```bash
bash "$LAB_SKILL/scripts/lab" viewer launch
bash "$LAB_SKILL/scripts/lab" checkout branches --json
```

For deployment, identify the actual **Omarchy source checkout**, not the standalone plugin repository. Branch mode deploys committed content; path mode is for the requested working-tree changes. Deploy normally reboots the guest, so capture any requested baseline/checkpoint first. Do not silently commit dirty work or fetch an unrelated remote branch.

```bash
bash "$LAB_SKILL/scripts/lab" checkout deploy --branch feature/my-change --repository /path/to/omarchy --json
bash "$LAB_SKILL/scripts/lab" checkout deploy /path/to/omarchy --json
bash "$LAB_SKILL/scripts/lab" checkout sync --json
```

These are alternatives, not a sequence to run indiscriminately. After deployment, verify health and deployed identity; a host command finishing is not evidence that the guest desktop works.

For commands inside the graphical guest, use `vm session` so the guest's Wayland, D-Bus and Omarchy environment are available. Quote the remote command to avoid expansion by the host shell. Bare host `hyprctl`, `omarchy dev link`, or package commands affect the host, not the guest.

```bash
bash "$LAB_SKILL/scripts/lab" vm session 'omarchy version; hyprctl configerrors'
bash "$LAB_SKILL/scripts/lab" vm session 'hyprctl monitors -j'
bash "$LAB_SKILL/scripts/lab" capture screenshot --json
bash "$LAB_SKILL/scripts/lab" health --json
```

Inspect the returned screenshot artifact, not just its filename. Exercise the requested UI path and check for guest errors. For ISO/finalization/package-layout acceptance, retain the source repository's `agents/skills/acceptance-tests.md` and `omarchy-iso` harness; an existing Lab desktop is not a substitute for a fresh ISO test.

## Checkpoints and destructive actions

Check scope and existing data before mutations. Permission to inspect or test is not blanket permission to reset, rebuild, promote gold, replace a checkpoint, install packages, or delete a VM. Respect explicit disposable-VM authorization when given, and preserve host boundaries.

- Checkpoint creation briefly stops the VM. Restore replaces the active overlay.
- Reset discards the active overlay and returns to gold. Rebuild reinstalls the guest. Promotion changes the baseline; do not promote test changes merely to repair tools.
- Checkpoints preserve disk contents but do not roll back the shared virtual TPM.
- Privileged actions need authentication. Use a visible terminal or the plugin's terminal handoff; do not wait for a hidden sudo prompt. A terminal-ready acknowledgment is not operation completion.
- Offline networking deliberately breaks SSH. Do not turn an unavailable health report into repeated startup or network changes without permission.
- Missing display tools in legacy gold are repaired on reset/aspect changes in the current overlay. With missing package databases this may run a full **guest** Omarchy update; it needs connectivity and may require a reboot.

After authorization, choose only the operation required:

```bash
bash "$LAB_SKILL/scripts/lab" checkpoint create before-change --json
bash "$LAB_SKILL/scripts/lab" checkpoint restore before-change --yes
bash "$LAB_SKILL/scripts/lab" vm reset
```

The Lab is not a malware sandbox: default guest credentials are lab/lab, sudo is passwordless, and NAT reaches networks the host can reach. Diagnostic bundles, recordings and transfers can contain private data. Recordings capture a composited host-screen region; keep the viewer unobscured and review captures before sharing.

## Reporting and recovery

Report the selected distribution, target guest, deployed branch/commit, tests actually run, and final VM/viewer state. Distinguish unit tests from live guest verification and list untested paths. Do not reset or rebuild as a generic response to a launch/SSH failure: inspect viewer status, bounded health, network status and command errors first.

If editing Lab itself, follow the repository's AGENTS.md and paired-repository guide. Runtime skill installation is separate from plugin installation; keep the installed skill current when its source changes.
