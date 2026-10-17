echo "Blacklist vxlan until the kernel FDB-flush UAF fix ships"

# Public LPE against the vxlan FDB-flush UAF (omacom/omarchy#10833) needs the
# module loaded from an unprivileged netns. Refuse new loads until Arch's
# kernel carries the stable fix (queued for 7.2.5 / 7.1.12). The matching
# drop-in under etc/modprobe.d/ ships with omarchy-settings on the next package
# cut; this migration covers installs that update scripts before that package.

conf="${OMARCHY_VXLAN_BLACKLIST_CONF:-/etc/modprobe.d/omarchy-vxlan-blacklist.conf}"

if [[ -f $conf ]] &&
  grep -Eq '^[[:space:]]*blacklist[[:space:]]+vxlan[[:space:]]*$' "$conf" &&
  grep -Eq '^[[:space:]]*install[[:space:]]+vxlan[[:space:]]+/bin/true[[:space:]]*$' "$conf"; then
  :
else
  sudo mkdir -p "$(dirname "$conf")"
  sudo tee "$conf" >/dev/null <<'EOF'
# Block the vxlan module until Arch ships a kernel with the FDB-flush UAF fix
# (queued for 7.2.5 / 7.1.12; tracked upstream as omacom/omarchy#10833).
# The public LPE builds an unprivileged netns + vxlan topology; refusing the
# module removes that first stage without disabling user namespaces wholesale
# (which would break Flatpak/bubblewrap). Reload is not required for cold
# boots; a loaded module still needs a reboot to unload safely.
blacklist vxlan
install vxlan /bin/true
EOF
fi

# Do not rmmod here — vxlan may be in use by a container runtime. The blacklist
# stops new loads; a reboot clears an already-loaded module.
if [[ -d ${OMARCHY_VXLAN_SYSFS:-/sys/module/vxlan} ]]; then
  omarchy-state set reboot-required
fi
