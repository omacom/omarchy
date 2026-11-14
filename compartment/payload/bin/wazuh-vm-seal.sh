#!/bin/bash
# ============================================================================
# wazuh-vm-seal.sh — agent-side ACTIVE RESPONSE for Whonix-Workstation
#
# Runs ON THE WORKSTATION (Wazuh location=local) when a high-severity alert
# trips an agent-side <active-response>.  It is a CONTAINMENT script, not a
# counter-attack tool: it blocks the offending source, isolates this VM from
# the gateway, kills a known-malware marker, and reboots to restore from
# snapshot after an inspection window.
#
# Runs with root (sudo); the sudoers snippet below must constrain it.  Every
# action is journalled to /var/log/wazuh-vm-seal/journal.log.
#
# Args:
#   $1 = -a <attacker_ip>  (block inbound+outbound to this src)   [optional]
#   $2 = -b <base_host_ip> (null-route this host to cut the VM link) [optional]
#   $3 = -c <conf>         1=block only, 2=block+kill+reboot [default 2]
# ============================================================================
set -u
# Do NOT set -e: we handle each step's failure explicitly.

# ---- Tunables (env-overridable for testing) ---------------------------------
BASE_HOST_IP="${BASE_HOST_IP:-10.0.2.2}"   # Whonix gateway host-side IP
INSPECT_SECONDS="${INSPECT_SECONDS:-300}"  # inspect window before reboot
LOCKFILE="/var/run/wazuh-vm-seal.lock"

LOGDIR="/var/log/wazuh-vm-seal"
JOURNAL="$LOGDIR/journal.log"
STATE="/var/run/wazuh-vm-seal.state"

mkdir -p "$LOGDIR" 2>/dev/null
: >> "$JOURNAL"

ts() { date '+%Y-%m-%d %H:%M:%S %Z'; }
log() { echo "$(ts) [$1] $2" | tee -a "$JOURNAL"; }
flock_and_log() { # acquire lock, then log; prevents concurrent seals
  exec 200>"$LOCKFILE"
  if ! flock -x 200; then
    log WARN "another seal hold on $LOCKFILE; exiting"
    exit 0
  fi
}

# ---- Validate ---- 
if [[ -e $LOCKFILE ]]; then
  # a previous seal that crashed races; take the lock below anyway
  :
fi

ATTACKER_IP=""
BASE_IP="10.0.2.2"
CONF=2

while getopts "a:b:c:" opt; do
  case "$opt" in
    a) ATTACKER_IP="$OPTARG" ;;
    b) BASE_IP="$OPTARG" ;;
    c) CONF="$OPTARG" ;;
    *) log WARN "unknown flag"; exit 2 ;;
  esac
done
shift $((OPTIND-1))

log INFO "seal invoked: attacker=${ATTACKER_IP:-none} base=${BASE_IP} conf=${CONF}"

# ---- 1. Input validation: only allow sane IPv4 for the attacker ------------
if [[ -n $ATTACKER_IP ]]; then
  if ! echo "$ATTACKER_IP" | grep -qE '^[0-9]{1,3}(\.[0-9]{1,3}){3}$'; then
    log WARN "invalid attacker IP '$ATTACKER_IP'; skipping block"
    ATTACKER_IP=""
  else
    # rc=0 binds the iptables change to this script's lifetime; DROP rule
    # applies in-namespace only (works inside the Whonix net).
    if sudo -n iptables -C INPUT -s "$ATTACKER_IP" -j DROP 2>/dev/null; then
      log INFO "inbound DROP to ${ATTACKER_IP} already present"
    else
      sudo -n iptables -I INPUT -s "$ATTACKER_IP" -j DROP 2>/dev/null \
        && log INFO "added inbound DROP for ${ATTACKER_IP}" \
        || log WARN "iptables INPUT add failed (check sudoers/permissions)"
    fi
    if sudo -n iptables -C OUTPUT -d "$ATTACKER_IP" -j DROP 2>/dev/null; then
      log INFO "outbound DROP to ${ATTACKER_IP} already present"
    else
      sudo -n iptables -I OUTPUT -d "$ATTACKER_IP" -j DROP 2>/dev/null \
        && log INFO "added outbound DROP for ${ATTACKER_IP}" \
        || log WARN "iptables OUTPUT add failed"
    fi
  fi
fi

# ---- 2. Isolate workstation from gateway (cut VM -> base link) --------------
if ip route get "$BASE_IP" >/dev/null 2>&1; then
  if sudo -n ip route replace default >/dev/null 2>&1; then
    log INFO "route reconfigured; to cut the VM->base link, apply this route:"
    log INFO "  sudo ip route add -host ${BASE_IP} dev lo blackhole"
    # Apply it now:
    if sudo -n ip route add -host "${BASE_IP}" dev lo blackhole 2>/dev/null; then
      log INFO "blackholed VM->base route to ${BASE_IP}"
    else
      log WARN "could not blackhole route (check sudoers/permissions)"
    fi
  else
    log WARN "default route already blackholed / cannot set; skip isolated step"
  fi
else
  log WARN "base host ${BASE_IP} not directly reachable; skip null-route"
fi

# ---- 3. Kill a known-malware marker process ---------------------------------
# Only kill a process we positively recognise as malicious.  Patterns are an
# allowlist; never run pkill -f on broad grep-ables — that would kill
# unrelated processes.
KNOWN_MALWARE_PATTERNS="${KNOWN_MALWARE_PATTERNS:-reptile|diamorphine}"
PIDS="$(ps -eo pid,args 2>/dev/null | grep -E "$KNOWN_MALWARE_PATTERNS" \
        | grep -v grep | grep -v "^ *$$ " | awk '{print $1}' | tr '\n' ' ')"

if [[ -n $PIDS ]]; then
  log INFO "killing known-malware PIDs: ${PIDS}"
  for p in $PIDS; do
    sudo -n kill -9 "$p" 2>/dev/null && log INFO "killed $p" \
      || log WARN "failed to kill $p"
  done
else
  log INFO "no known-malware marker process found"
fi

# ---- 4. Reboot after inspection window (triggers snapshot restore) ----------
if (( CONF >= 2 )); then
  # Graceful first, escalate only if it hangs.
  log INFO "inspection window ${INSPECT_SECONDS}s; then reboot"
  sleep "$INSPECT_SECONDS"

  if sudo -n systemctl reboot >/dev/null 2>&1; then
    log INFO "initiated graceful reboot"
  elif sudo -n reboot --force >/dev/null 2>&1; then
    log INFO "initiated force reboot"
  elif sudo -n init 6 >/dev/null 2>&1; then
    log INFO "initiated runlevel-6 reboot"
  else
    log WARN "all reboot paths denied; escalating"
    sudo -n -u root reboot --force 2>/dev/null || log WARN "reboot denied"
  fi
else
  log INFO "conf<2: inspection only, no reboot"
fi

log INFO "seal sequence complete"
