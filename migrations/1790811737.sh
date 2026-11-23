echo "Limit the LocalSend firewall rule to private and local networks"

omarchy-cmd-present ufw || exit 0

# Installs before this opened 53317 to Anywhere, which on IPv6 is usually the
# whole internet. Replace only that exact rule, so a machine that removed it is left alone.
added=$(sudo ufw show added)
nets=(10.0.0.0/8 172.16.0.0/12 192.168.0.0/16)

# ufw refuses IPv6 rules when IPv6 is off in its config or the kernel, so ask it first.
if sudo ufw --dry-run allow from fe80::/10 to any port 53317 >/dev/null 2>&1; then
  nets+=(fc00::/7 fe80::/10)
elif sudo test -f /etc/ufw/user6.rules; then
  # ufw cannot touch its IPv6 rules then, so drop the unscoped ones from its file or they return with IPv6.
  sudo sed -i -E '/^### tuple ### allow (udp|tcp) 53317 ::\/0 any ::\/0 in$/{N;/\n-A ufw6-user-input -p (udp|tcp) --dport 53317 -j ACCEPT$/d}' /etc/ufw/user6.rules
fi

for proto in udp tcp; do
  if grep -Fqx "ufw allow 53317/$proto" <<<"$added"; then
    for net in "${nets[@]}"; do
      sudo ufw allow in proto "$proto" from "$net" to any port 53317 comment 'localsend' >/dev/null
    done
    sudo ufw delete allow "53317/$proto" >/dev/null
  fi
done
