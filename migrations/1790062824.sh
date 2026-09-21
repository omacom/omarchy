echo "Narrow the LocalSend firewall rules to private networks"

# install/config/firewall.sh used to run
#   ufw allow 53317/udp
#   ufw allow 53317/tcp
# which UFW stores as ALLOW ... Anywhere for both IPv4 and IPv6. Installs
# carrying those keep the broad exception even once the installer is fixed, so
# narrow them here too.
#
# Deleting by rule spec rather than by parsing `ufw status`: the spec
# "allow 53317/udp" matches only the unrestricted rule, so a scoped or
# hand-written rule for the same port is left alone, and one delete clears both
# the IPv4 and the IPv6 entry. ufw exits 0 whether or not it found anything, so
# its output is what says which happened.
omarchy-cmd-present ufw || return 0 2>/dev/null || exit 0
sudo ufw status >/dev/null 2>&1 || return 0 2>/dev/null || exit 0

removed=false
for proto in udp tcp; do
  if sudo ufw --force delete allow "53317/${proto}" 2>&1 | grep -q '^Rule deleted'; then
    removed=true
  fi
done

# Idempotent: UFW skips a rule it already holds, so re-running adds nothing.
for cidr in 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16; do
  sudo ufw allow in proto udp from "$cidr" to any port 53317 comment 'omarchy-localsend' >/dev/null
  sudo ufw allow in proto tcp from "$cidr" to any port 53317 comment 'omarchy-localsend' >/dev/null
done

sudo ufw reload >/dev/null 2>&1 || true

if $removed; then
  echo "Replaced the unrestricted port 53317 rules with private-network-scoped ones."
else
  echo "LocalSend firewall rules are already scoped to private networks."
fi
