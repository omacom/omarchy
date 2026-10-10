echo "Harden Hermes Desktop launcher for agent skew and weak NVIDIA GPUs"

# Hermes Desktop is an upstream Electron app Omarchy installs. After agent updates,
# the packaged shell can lag the CLI (arity + protocol skew). Stock launchers that
# set HERMES_DESKTOP_IGNORE_EXISTING=1 also skip the installed runtime.
# Install a user-PATH override (Omarchy already prefers ~/.config/omarchy/bin).

omarchy-pkg-present hermes-desktop || exit 0

mkdir -p "$HOME/.config/omarchy/bin"
target="$HOME/.config/omarchy/bin/hermes-desktop"

# Do not clobber a newer user-maintained override if it already handles 5-tuple,
# has no IGNORE_EXISTING trap, and includes weak-NVIDIA / software-GPU handling.
if [[ -x $target ]] && grep -q 'renderer_a11y\|renderer_accessibility' "$target" \
  && grep -qE 'HERMES_DESKTOP_DISABLE_GPU|memory\.total' "$target" \
  && ! grep -q '^export HERMES_DESKTOP_IGNORE_EXISTING=1' "$target"; then
  :
else
  cat >"$target" <<'WRAPPER'
#!/bin/bash
# User override: hermes-desktop package unpacks 4 launch options, but
# hermes-agent CLI now returns 5 (adds renderer_accessibility).
set -euo pipefail

unset ELECTRON_RUN_AS_NODE PYTHONPATH PYTHONHOME
# Do NOT set HERMES_DESKTOP_IGNORE_EXISTING=1 here — that skips ~/.hermes/hermes-agent
# and leaves Desktop on first-run setup. Only pass --ignore-existing when testing.
# Weak NVIDIA (≤4 GiB, e.g. GTX 1050): hardware GL/EGL mid-boot abort → SIGTRAP/FATAL;
# SwiftShader alone still hit GPU process error_code=1002 later. Soft-default full
# software GPU disable + SwiftShader. Override with HERMES_DESKTOP_DISABLE_GPU=0.
# Markers: ~/.config/Hermes/{nvidia-egl-fallback,linux-gpu-fallback}.json
if command -v nvidia-smi >/dev/null 2>&1; then
  _hermes_vram=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' ')
  if [[ ${_hermes_vram:-99999} -le 4096 ]]; then
    export HERMES_DESKTOP_NVIDIA_SWIFTSHADER="${HERMES_DESKTOP_NVIDIA_SWIFTSHADER:-1}"
    export HERMES_DESKTOP_DISABLE_GPU="${HERMES_DESKTOP_DISABLE_GPU:-1}"
  fi
  unset _hermes_vram
fi

if command -v omarchy-install-hermes-cli >/dev/null 2>&1; then
  omarchy-install-hermes-cli >/dev/null 2>&1 || true
fi

hermes_home=$(realpath -ms -- "${HERMES_HOME:-$HOME/.hermes}")
parent=${hermes_home%/*}
if [[ ${parent##*/} == [Pp][Rr][Oo][Ff][Ii][Ll][Ee][Ss] ]]; then
  hermes_home=${parent%/*}
  hermes_home=${hermes_home:-/}
fi
export HERMES_HOME="$hermes_home"
runtime="$hermes_home/hermes-agent"
native="$runtime/apps/desktop/release/linux-unpacked/Hermes"
if [[ ! -x $native || ! -x $runtime/venv/bin/hermes ]]; then
  native=/opt/hermes-desktop/Hermes
fi

if ! timeout 5 unshare --user --map-root-user true 2>/dev/null; then
  echo "Hermes Desktop requires working unprivileged user namespaces for its sandbox." >&2
  exit 1
fi

python=/usr/bin/python
if [[ -x $runtime/venv/bin/python && -f $runtime/hermes_cli/main.py ]]; then
  python="$runtime/venv/bin/python"
else
  runtime=""
fi

exec "$python" - "$native" "$runtime" "$@" <<'PY'
import os
from pathlib import Path
import sys

native, runtime, *args = sys.argv[1:]
env = os.environ.copy()
flags, gpu, store, ozone, renderer_a11y = [], "auto", "auto", "auto", True
if runtime:
    sys.path.insert(0, runtime)
    try:
        if Path(runtime, "hermes_cli/main_desktop.py").is_file():
            from hermes_cli.main_desktop import _desktop_launch_options
        else:
            from hermes_cli.main import _desktop_launch_options
        from hermes_constants import with_hermes_node_path

        opts = _desktop_launch_options()
        if len(opts) >= 5:
            flags, gpu, store, ozone, renderer_a11y = opts[:5]
        else:
            flags, gpu, store, ozone = opts[:4]
        env = with_hermes_node_path(env)
    except ImportError:
        print("Could not load Hermes desktop settings; using launch defaults.", file=sys.stderr)

env["HERMES_DESKTOP_CWD"] = os.getcwd()
if gpu != "auto":
    env.setdefault("HERMES_DESKTOP_DISABLE_GPU", gpu)
if ozone != "auto":
    env.setdefault("ELECTRON_OZONE_PLATFORM_HINT", ozone)
if not renderer_a11y:
    env.setdefault("HERMES_DESKTOP_RENDERER_ACCESSIBILITY", "0")
env.setdefault("HERMES_DESKTOP_PASSWORD_STORE", store if store != "auto" else "gnome-libsecret")

if (env.get("WAYLAND_DISPLAY") or env.get("XDG_SESSION_TYPE") == "wayland") and (
    "ELECTRON_OZONE_PLATFORM_HINT" not in env
    and not any(arg.startswith(("--ozone-platform=", "--ozone-platform-hint=")) for arg in flags + args)
):
    flags.insert(0, "--ozone-platform=wayland")
os.execve(native, [native, "--disable-setuid-sandbox", *flags, *args], env)
PY
WRAPPER
  chmod +x "$target"
fi

# Skills migration may already have completed before this skill shipped — link it now.
OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
skill_src="$OMARCHY_PATH/default/agents/skills/hermes-desktop-recovery"
if [[ -d $skill_src ]]; then
  mkdir -p "$HOME/.hermes/skills"
  ln -sfn "$skill_src" "$HOME/.hermes/skills/hermes-desktop-recovery"
  if [[ -d $HOME/.hermes/profiles ]]; then
    for profile in "$HOME"/.hermes/profiles/*/; do
      [[ -d $profile ]] || continue
      mkdir -p "$profile/skills"
      ln -sfn "$skill_src" "$profile/skills/hermes-desktop-recovery"
    done
  fi
fi

# Users on weak NVIDIA GPUs should also set desktop.disable_gpu: true in Hermes config
# (Hermes Desktop Settings or config.yaml). Rebuild matched shell with:
#   hermes desktop --build-only
