#!/bin/bash
# in-guest-provision.sh — firstboot provisioner (runs inside real VM via
# bootstrap-firstboot.service). Installs cached debs, places configs, users,
# perms, firewall exception, mounts verity weights, unpacks hermes.
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
LOG=/var/log/provision.log
exec > >(tee -a "$LOG") 2>&1
set -x

echo "PHASE:debs"
cd /var/cache/apt/archives 2>/dev/null && tar xzf debs.tar.gz 2>/dev/null && rm -f debs.tar.gz
dpkg -i /var/cache/apt/archives/*.deb 2>/dev/null || dpkg --configure -a || true

# Fallback: no debs staged -> apt over Whonix Tor (works, just slower)
if ! command -v apache2 >/dev/null 2>&1 || ! command -v firejail >/dev/null 2>&1; then
  echo "PHASE:apt-fallback"
  apt-get update -qq && apt-get install -y -qq \
    openssh-server firejail apache2 libapache2-mod-security2 tmux jq socat \
    apparmor-utils dmsetup cryptsetup || echo "FAIL:apt-fallback"
fi

echo "PHASE:moves"
mkdir -p /etc/ssh/sshd_config.d /etc/apache2/conf-available /etc/apache2/conf-enabled
mv /etc/compartment/sshd_config.d-agent.conf /etc/ssh/sshd_config.d/50-agent.conf 2>/dev/null || echo "FAIL:sshd-conf"
mv /etc/compartment/apache-fw.conf /etc/apache2/conf-available/context-firewall.conf 2>/dev/null || echo "FAIL:apache-conf"
ln -sf /etc/apache2/conf-available/context-firewall.conf /etc/apache2/conf-enabled/context-firewall.conf 2>/dev/null || true

echo "PHASE:users"
id agent 2>/dev/null || useradd -m -s /bin/bash agent || echo "FAIL:useradd-agent"
id llmserve 2>/dev/null || useradd -r -s /usr/sbin/nologin llmserve || echo "FAIL:useradd-llmserve"
id fw 2>/dev/null || useradd -r -s /usr/sbin/nologin fw || echo "FAIL:useradd-fw"

echo "PHASE:perms"
chown -R agent:agent /home/agent || echo "FAIL:chown-home"
mkdir -p /home/agent/.ssh
touch /home/agent/.ssh/authorized_keys
chown -R agent:agent /home/agent/.ssh && chmod 700 /home/agent/.ssh && chmod 600 /home/agent/.ssh/authorized_keys
chmod 755 /usr/local/bin/vm-exec /usr/local/bin/agent-sandbox /usr/local/bin/vm-seal-local /usr/local/bin/llama-server /usr/local/bin/mount-models.sh
chown -R root:fw /etc/modsecurity/dlp && chmod 750 /etc/modsecurity/dlp && chmod 640 /etc/modsecurity/dlp/* || echo "FAIL:dlp-perms"

echo "PHASE:apache"
a2enmod proxy proxy_http security2 >/dev/null 2>&1 || echo "FAIL:a2enmod"
a2enconf context-firewall >/dev/null 2>&1 || echo "FAIL:a2enconf"

echo "PHASE:final"
printf "agent ALL=(root) NOPASSWD: /usr/local/bin/wazuh-vm-seal.sh, /usr/local/bin/vm-seal-local\n" > /etc/sudoers.d/agent-seal
chmod 440 /etc/sudoers.d/agent-seal
iptables -I INPUT 1 -s 10.152.152.222 -p tcp --dport 22 -j ACCEPT 2>/dev/null || true
mkdir -p /etc/iptables 2>/dev/null
iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
echo "net.ipv4.ip_forward=0" > /etc/sysctl.d/90-noforward.conf
sed -i "s/--threads %j/--threads 10/" /etc/systemd/system/llama-server.service
passwd -l agent 2>/dev/null || true

echo "PHASE:mount+hermes"
bash /usr/local/bin/mount-models.sh || echo "FAIL:mount-models"
mkdir -p /home/agent
[ -f /opt/bootstrap/hermes-agent.tar.zst ] && tar -C /home/agent -xzf /opt/bootstrap/hermes-agent.tar.zst || true
cp -n /opt/bootstrap/dlp/*.txt /etc/modsecurity/dlp/ 2>/dev/null || true
chown -R agent:agent /home/agent/hermes-agent 2>/dev/null || true

systemctl enable models-mount llama-server context-firewall hermes-backend compartment-ssh-fw ssh 2>/dev/null || true
systemctl start ssh 2>/dev/null || true
# agent CLIs + hermes venv — offline pack first (reliable), npm-over-Tor fallback
echo "PHASE:agents"
if [ -f /var/lib/agent-pack.tar.gz ]; then
  mkdir -p /opt/agent-pack && tar -C /opt/agent-pack -xzf /var/lib/agent-pack.tar.gz \
    && for a in /opt/agent-pack/bin/*; do ln -sf "$a" "/usr/local/bin/$(basename "$a")"; done \
    && chown -R agent:agent /opt/agent-pack && echo "agent-pack installed" || echo "FAIL:agent-pack"
else
  bash /usr/local/bin/provision-agents.sh || echo "FAIL:provision-agents"
fi
if [ -f /var/lib/hermes-pack.tar.gz ]; then
  tar -C / -xzf /var/lib/hermes-pack.tar.gz \
    && chown -R agent:agent /home/agent/hermes-agent \
    && echo "hermes-pack installed" || echo "FAIL:hermes-pack"
  mkdir -p /home/agent/.hermes && chown agent:agent /home/agent/.hermes
fi

mkdir -p /var/lib && touch /var/lib/bootstrap.done && sync /var/lib/bootstrap.done
echo "PROVISION_DONE"
