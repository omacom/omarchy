# Install the night light sunrise/sunset scheduling system

set -euo pipefail

NL_STATE_DIR="$HOME/.local/state/omarchy/settings"
NL_STATE_FILE="$NL_STATE_DIR/nightlight.json"
NL_HOOK_DIR="$HOME/.config/omarchy/hooks/post-boot.d"
NL_HOOK_FILE="$NL_HOOK_DIR/omarchy-nightlight-refresh"
NL_AUTOSTART="$HOME/.config/hypr/autostart.lua"
NL_SYSTEMD_DIR="$HOME/.config/systemd/user"
NL_SYSTEMD_SRC="${OMARCHY_PATH:-/usr/share/omarchy}/default/systemd/user"

# 1. State file: only create if missing (don't clobber user-set mode/temps).
[[ -f $NL_STATE_FILE ]] || {
  mkdir -p "$NL_STATE_DIR"
  jq -n \
    --arg mode "sunrise-sunset" \
    --argjson day 6500 \
    --argjson night 4000 \
    '{mode:$mode, dayTemperature:$day, nightTemperature:$night}' \
    >"$NL_STATE_FILE"
}

# 2. Post-boot hook. Overwriting is idempotent — the script does the same thing
#    every boot.
mkdir -p "$NL_HOOK_DIR"
cat >"$NL_HOOK_FILE" <<'HOOK'
#!/bin/bash
# Regenerate hyprsunset.conf + per-day sunrise/sunset timers after login.
# Idempotent. Skipped when OMARCHY_NIGHTLIGHT_DISABLED=1 or hyprsunset is not
# installed.

[[ ${OMARCHY_NIGHTLIGHT_DISABLED:-} == "1" ]] && exit 0
command -v hyprsunset >/dev/null || exit 0

exec omarchy toggle nightlight --refresh
HOOK
chmod 755 "$NL_HOOK_FILE"

# 3. Daily refresh timer unit. Ship the .service + .timer into
#    ~/.config/systemd/user/ for existing users (fresh installs already get
#    these from /etc/skel via omarchy-reinstall-configs). Overwriting is safe:
#    the unit content is identical to what enable-user-units.sh ships.
if [[ -d $NL_SYSTEMD_SRC ]] && [[ -f $NL_SYSTEMD_SRC/omarchy-nightlight-refresh.timer ]]; then
  mkdir -p "$NL_SYSTEMD_DIR"
  install -m 0644 "$NL_SYSTEMD_SRC/omarchy-nightlight-refresh.service" "$NL_SYSTEMD_DIR/"
  install -m 0644 "$NL_SYSTEMD_SRC/omarchy-nightlight-refresh.timer"   "$NL_SYSTEMD_DIR/"
fi

# 4. Enable and start the daily refresh timer. Conditional on hyprsunset being
#    installed (so a VM without a display doesn't fail). Re-runs are harmless
#    (idempotent); if the user has disabled it, systemctl enable is a no-op.
if command -v hyprsunset >/dev/null; then
  systemctl --user daemon-reload 2>/dev/null || true
  systemctl --user enable --now omarchy-nightlight-refresh.timer 2>/dev/null || true
fi

# 5. Autostart hyprsunset. The original Omarchy default leaves this commented
#    because it assumes the user starts hyprsunset via the Toggle. With
#    sunrise/sunset scheduling active by default, hyprsunset must be running
#    for the timers to do anything. Idempotent: skipped if the line is
#    already present (commented or uncommented).
mkdir -p "$(dirname "$NL_AUTOSTART")"
[[ -f $NL_AUTOSTART ]] || touch "$NL_AUTOSTART"
if ! grep -qE '^[^"]*launch_on_start\("hyprsunset"\)' "$NL_AUTOSTART"; then
  printf '\n-- Night light: needed for sunrise/sunset timers to take effect.\no.launch_on_start("hyprsunset")\n' >>"$NL_AUTOSTART"
fi

# 6. The new menu submenu and QML settings-aware service ship with the
#    package itself; omarchy-shell picks them up on next restart (which
#    omarchy update triggers automatically). No per-user file copy needed:
#    defaultMenuPath = $OMARCHY_PATH/default/omarchy/omarchy-menu.jsonc is
#    read directly by the Quickshell menu plugin.
echo "Night light sunrise/sunset scheduling installed."
echo "Verify: systemctl --user list-timers omarchy-nightlight-*"
echo "Menu submenu activates on next omarchy-shell restart."