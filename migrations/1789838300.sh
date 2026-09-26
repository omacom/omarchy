echo "Let user sudoers.d drop-ins override Omarchy passwd_tries"

# sudoers.d is last-wins by lexical name. The old omarchy-passwd-tries sorted
# after names like 99-passwd-tries (digits before letters), so a user's stricter
# Defaults passwd_tries=… never took effect (#12397). The packaged file is now
# 10-omarchy-passwd-tries. Drop the old path if it is still the stock one-liner;
# leave custom contents alone.
old="${OMARCHY_SUDOERS_DIR:-/etc/sudoers.d}/omarchy-passwd-tries"

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

[[ -e $old || -L $old ]] || exit 0

body=$(as_root cat "$old" 2>/dev/null || true)
# Strip comments/blank lines for comparison
active=$(printf '%s\n' "$body" | grep -vE '^[[:space:]]*(#|$)' || true)
if [[ $active == 'Defaults passwd_tries=10' ]]; then
  as_root rm -f "$old"
fi
