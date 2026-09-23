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
# No ufw at all is a genuine no-op: there is no rule to narrow.
omarchy-cmd-present ufw || return 0 2>/dev/null || exit 0

# A failing status query is not the same thing. The runner records any zero exit
# as applied, so exiting 0 here would retire the migration permanently while the
# unrestricted rules stayed in place. Leave it pending instead.
if ! sudo ufw status >/dev/null 2>&1; then
  echo "Could not query ufw. Leaving this migration pending so it retries." >&2
  exit 1
fi

removed=false
for proto in udp tcp; do
  # Two different questions, kept apart: the exit status says whether ufw ran,
  # and the output says whether it found a rule to delete. Reading them off one
  # pipeline made a backend failure look like "there was nothing to delete".
  if ! output=$(sudo ufw --force delete allow "53317/${proto}" 2>&1); then
    echo "Could not delete the unrestricted 53317/${proto} rule. Leaving this migration pending so it retries." >&2
    exit 1
  fi

  if grep -q '^Rule deleted' <<<"$output"; then
    removed=true
  fi
done

# Idempotent: UFW skips a rule it already holds, so re-running adds nothing.
for cidr in 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16; do
  for proto in udp tcp; do
    # A half-applied rule set is worse than a pending migration: the broad rules
    # are already gone by this point, so failing here has to stay retryable.
    if ! sudo ufw allow in proto "$proto" from "$cidr" to any port 53317 comment 'omarchy-localsend' >/dev/null; then
      echo "Could not add the scoped ${proto} rule for ${cidr}. Leaving this migration pending so it retries." >&2
      exit 1
    fi
  done
done

sudo ufw reload >/dev/null 2>&1 || true

if $removed; then
  echo "Replaced the unrestricted port 53317 rules with private-network-scoped ones."
else
  echo "LocalSend firewall rules are already scoped to private networks."
fi
