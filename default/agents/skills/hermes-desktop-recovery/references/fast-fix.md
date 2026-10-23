# Fast fix (copy/paste)

```bash
# 1) Make sure the packaged launcher is current (5-value launch options, weak-NVIDIA handling)
omarchy-update        # or: sudo pacman -Syu hermes-desktop

# 2) Match desktop shell to agent
hermes desktop --build-only --force-build

# 3) Launch + verify
hermes-desktop &
sleep 8
rg 'backend is ready|IGNORE_EXISTING|predates|FATAL' ~/.hermes/logs/desktop.log | tail -15
```

On NVIDIA cards with ≤4 GiB VRAM the packaged launcher soft-defaults
`HERMES_DESKTOP_DISABLE_GPU=1`. Force a choice per launch, without editing any file:

```bash
HERMES_DESKTOP_DISABLE_GPU=1 hermes-desktop   # software rendering
HERMES_DESKTOP_DISABLE_GPU=0 hermes-desktop   # keep hardware GPU
```

To persist it, set `desktop.disable_gpu: true` in `~/.hermes/config.yaml`.
