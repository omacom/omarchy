# Fast fix (copy/paste)

```bash
# 1) Match desktop shell to agent
hermes desktop --build-only --force-build

# 2) Install / refresh the Omarchy user launcher (do not append env lines into the script)
mkdir -p ~/.config/omarchy/bin
# Prefer the packaged migration when available:
if [[ -f ${OMARCHY_PATH:-/usr/share/omarchy}/migrations/1791324018.sh ]]; then
  bash "${OMARCHY_PATH:-/usr/share/omarchy}/migrations/1791324018.sh"
else
  # Or copy the full wrapper from references/wrapper-5-tuple.md
  echo "Copy references/wrapper-5-tuple.md into ~/.config/omarchy/bin/hermes-desktop" >&2
fi
chmod +x ~/.config/omarchy/bin/hermes-desktop

# 3) Ensure Omarchy user launcher wins on PATH
type -a hermes-desktop   # expect ~/.config/omarchy/bin/hermes-desktop first

# 4) Launch + verify
hermes-desktop &
sleep 8
rg 'backend is ready|IGNORE_EXISTING|predates|FATAL' ~/.hermes/logs/desktop.log | tail -15
```

On weak NVIDIA (≤4 GiB), the wrapper soft-defaults `HERMES_DESKTOP_DISABLE_GPU=1`.
Override with `HERMES_DESKTOP_DISABLE_GPU=0` if you need hardware GPU.

Not a HackerOne bounty: upstream Electron/Hermes crashes Omarchy merely ships (see local TRIAGE).
