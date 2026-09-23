echo "Scope the dev-link sudoers drop-in to the linking user"

# omarchy-dev-link used to write /etc/sudoers.d/omarchy-dev-path as a plain
#   Defaults secure_path="<checkout>/bin:/usr/local/sbin:/usr/local/bin:/usr/bin"
# A plain Defaults applies to every sudoer on the machine, so a checkout one
# developer linked sat ahead of /usr/bin for root's own `sudo -i` and for any
# other admin account that never ran `omarchy dev link`. dev-link now writes
# Defaults:<user>; rewrite an existing global drop-in into the same shape.
#
# Only touch a file that is exactly what dev-link generated. An admin who wrote
# their own secure_path there keeps it, and is told instead.
sudoers_file=/etc/sudoers.d/omarchy-dev-path

# `sudo test -f` returns non-zero both when the file is absent and when sudo
# could not be asked at all. Exiting 0 on the second case would have the runner
# record this migration as applied and never retry it, leaving the global rule
# in place for good. A control probe tells the two apart: if sudo can run
# anything, the drop-in genuinely is not there and there is nothing to do.
if ! sudo test -f "$sudoers_file"; then
  if sudo test -d /; then
    exit 0
  fi
  echo "Could not inspect $sudoers_file. Leaving this migration pending so it retries." >&2
  exit 1
fi

# grep exits 1 for "no lines matched" and greater than 1 for a real error. Only
# the second means the inspection failed, and must not be read as an empty file.
active=$(sudo grep -vE '^[[:space:]]*(#|$)' "$sudoers_file") && grep_status=0 || grep_status=$?
if (( grep_status > 1 )); then
  echo "Could not read $sudoers_file. Leaving this migration pending so it retries." >&2
  exit 1
fi

generated='^Defaults[[:space:]]+secure_path="([^"]*)/bin:/usr/local/sbin:/usr/local/bin:/usr/bin"$'

if (( $(printf '%s\n' "$active" | grep -c .) != 1 )) || [[ ! $active =~ $generated ]]; then
  # Already scoped, or something else entirely. Either way, not ours to rewrite.
  exit 0
fi

# Captured out of the sudoers string still carrying whatever backslash escaping
# was written into it. A path plain enough to have needed none round-trips
# unchanged; one that did not will fail the stat below and be left alone.
checkout=${BASH_REMATCH[1]}

# The rule belongs to whoever owns the checkout, not to whoever happens to be
# logged in running migrations — on a machine with two developers those are
# different people, and guessing wrong would hand the checkout to the wrong one.
# Stat it through sudo: a checkout under another user's 0700 home is exactly the
# case this migration exists for, and is the one the caller cannot read.
owner=$(sudo stat -c '%U' "$checkout" 2>/dev/null || true)

if [[ -z $owner || $owner == UNKNOWN ]]; then
  echo "Left $sudoers_file alone: cannot tell which user $checkout belongs to."
  echo "Re-run 'omarchy dev link $checkout' as that user, or 'omarchy dev unlink'."
  exit 0
fi

if [[ $owner == root ]]; then
  # Nothing to scope to: a root-owned checkout is no more writable than
  # /usr/bin, and pinning the rule to root would not describe who linked it.
  echo "Left $sudoers_file alone: $checkout is owned by root."
  exit 0
fi

# sudoers wants a backslash escape for a user name outside its unquoted
# alphabet, and reads a leading '#' as a uid. Rather than reimplement that here,
# leave an exotic name to dev-link, which does escape it.
if [[ ! $owner =~ ^[A-Za-z0-9_.-]+$ ]]; then
  echo "Left $sudoers_file alone: '$owner' needs sudoers escaping this migration does not do."
  echo "Re-run 'omarchy dev link $checkout' as that user to rewrite it."
  exit 0
fi

staged=$(mktemp)
trap 'rm -f "$staged"' EXIT

printf 'Defaults:%s secure_path="%s/bin:/usr/local/sbin:/usr/local/bin:/usr/bin"\n' \
  "$owner" "$checkout" >"$staged"

if ! visudo -cf "$staged" >/dev/null; then
  echo "Left $sudoers_file alone: a scoped rule for '$owner' does not parse."
  exit 0
fi

sudo install -Dm440 -o root -g root "$staged" "$sudoers_file"

echo "Scoped $sudoers_file to $owner."
echo "Other sudo users no longer resolve commands from $checkout/bin."
