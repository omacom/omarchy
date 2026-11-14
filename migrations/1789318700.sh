echo "Strip CAP_SYS_ADMIN from gsr-kms-server"

# Arch's gpu-screen-recorder package re-applies cap_sys_admin=ep on every
# upgrade. Strip it now and install a pacman hook so upgrades stay stripped.
# omarchy-capture-screenrecording uses the portal backend when the helper no
# longer has the capability, avoiding gpu-screen-recorder's pkexec fallback.

if [[ -x /usr/bin/gsr-kms-server ]] && command -v setcap >/dev/null 2>&1; then
  if getcap /usr/bin/gsr-kms-server 2>/dev/null | grep -q .; then
    sudo setcap -r /usr/bin/gsr-kms-server
  fi
fi

hook=/etc/pacman.d/hooks/90-omarchy-strip-gsr-kms-caps.hook
if [[ ! -f $hook ]]; then
  sudo mkdir -p /etc/pacman.d/hooks
  sudo install -Dm644 /dev/stdin "$hook" <<'HOOK'
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = gpu-screen-recorder

[Action]
Description = Stripping file capabilities from gsr-kms-server...
When = PostTransaction
Exec = /usr/bin/omarchy-strip-gsr-kms-caps
HOOK
fi
