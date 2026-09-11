echo "Limit LocalSend firewall port 53317 to private networks"

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

if omarchy-cmd-missing ufw; then
  exit 0
fi

ufw_user_rules=${OMARCHY_UFW_USER_RULES:-/etc/ufw/user.rules}
ufw_user6_rules=${OMARCHY_UFW_USER6_RULES:-/etc/ufw/user6.rules}

# Arch ships /etc/ufw/user.rules 0644 and ufw keeps that mode on rewrite, so
# a second user on an already-repaired machine can see there is nothing to do
# and no-op without a password. If the files are not readable here, escalate
# and let root decide.
already_limited() {
  local rules=$1 v6=$2
  [[ -r $rules ]] || return 1
  if grep -- '-A ufw-user-input' "$rules" | grep 53317 | grep -v -- '-s ' | grep -q ACCEPT; then
    return 1
  fi
  grep 53317 "$rules" | grep -q '10.0.0.0/8' || return 1
  grep 53317 "$rules" | grep -q '172.16.0.0/12' || return 1
  grep 53317 "$rules" | grep -q '192.168.0.0/16' || return 1
  grep 53317 "$rules" | grep -q '169.254.0.0/16' || return 1
  [[ -e $v6 ]] || return 0
  [[ -r $v6 ]] || return 1
  if grep -- '-A ufw6-user-input' "$v6" | grep 53317 | grep -v -- '-s ' | grep -q ACCEPT; then
    return 1
  fi
  grep 53317 "$v6" | grep -q 'fe80::/10' || return 1
  grep 53317 "$v6" | grep -q 'fc00::/7' || return 1
}

if already_limited "$ufw_user_rules" "$ufw_user6_rules"; then
  exit 0
fi

if ! as_root true; then
  echo "Administrator privileges are required to tighten the LocalSend firewall rules. Run omarchy-migrate again from a terminal." >&2
  exit 1
fi

as_root bash -s <<'EOS'
set -euo pipefail

# Stock rule is "allow 53317/tcp" (and udp) from anywhere, v4+v6.
# Source-limited rules do not match this delete.
ufw --force delete allow 53317/tcp >/dev/null 2>&1 || true
ufw --force delete allow 53317/udp >/dev/null 2>&1 || true

for cidr in 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 169.254.0.0/16; do
  ufw allow in proto udp from "$cidr" to any port 53317 comment 'omarchy-localsend' >/dev/null
  ufw allow in proto tcp from "$cidr" to any port 53317 comment 'omarchy-localsend' >/dev/null
done

for cidr in fe80::/10 fc00::/7; do
  ufw allow in proto udp from "$cidr" to any port 53317 comment 'omarchy-localsend' >/dev/null
  ufw allow in proto tcp from "$cidr" to any port 53317 comment 'omarchy-localsend' >/dev/null
done

ufw reload >/dev/null
EOS
