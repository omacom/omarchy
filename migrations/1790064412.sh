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
sudoers_file="${OMARCHY_DEV_SUDOERS_FILE:-/etc/sudoers.d/omarchy-dev-path}"

# Inspect the drop-in in a single privileged call: it reports "absent", or
# "present" followed by the file body. Doing existence and read in one `sudo`
# is what makes a denied or unanswered sudo a single unambiguous failure. The
# earlier shape could not: `sudo test -f` is non-zero for both "absent" and
# "sudo refused", a `sudo test -d /` control cannot see a policy that denies
# only the first command, and `sudo cat` exits 1 for both an empty file and a
# denial. Here the call's own non-zero exit means sudo failed; a zero exit
# saying "absent" is a genuine no-op.
if ! inspect=$(sudo sh -c '
  if [ ! -f "$1" ]; then printf absent; exit 0; fi
  printf "present\n"
  cat "$1"
' sh "$sudoers_file"); then
  echo "Could not inspect $sudoers_file. Leaving this migration pending so it retries." >&2
  exit 1
fi

if [[ $inspect == absent ]]; then
  exit 0
fi

# Strip the "present" header; what remains is the file body (empty for an empty
# drop-in, since command substitution drops the trailing newline after it).
contents=${inspect#present}
contents=${contents#$'\n'}

# With the content in hand, grep's "no lines matched" is unambiguous.
active=$(printf '%s\n' "$contents" | grep -vE '^[[:space:]]*(#|$)') || true

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
# case this migration exists for, and is the one the caller cannot read. One
# sudo call again, reporting "__missing__" for an absent path, so that a denied
# sudo fails the call and leaves the migration pending rather than reading as an
# empty owner that quietly retires it with the global rule still in place.
if ! owner=$(sudo sh -c '
  if [ -e "$1" ]; then stat -c %U "$1"; else printf __missing__; fi
' sh "$checkout"); then
  echo "Could not read the owner of $checkout. Leaving this migration pending so it retries." >&2
  exit 1
fi

if [[ -z $owner || $owner == UNKNOWN || $owner == __missing__ ]]; then
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
