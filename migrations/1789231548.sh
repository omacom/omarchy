echo "Strip file capabilities from btop"

if [[ -x /usr/bin/btop ]] && command -v setcap >/dev/null 2>&1; then
  if getcap /usr/bin/btop 2>/dev/null | grep -q .; then
    sudo setcap -r /usr/bin/btop
  fi
fi

hook=/etc/pacman.d/hooks/90-omarchy-strip-btop-caps.hook
if [[ ! -f $hook ]]; then
  sudo mkdir -p /etc/pacman.d/hooks
  sudo install -Dm644 /dev/stdin "$hook" <<'HOOK'
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = btop

[Action]
Description = Stripping file capabilities from btop...
When = PostTransaction
Exec = /usr/bin/omarchy-strip-btop-caps
HOOK
fi
