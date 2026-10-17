echo "Repair a polkit stack whose lid gate hid it from the system-auth migration"

polkit=/etc/pam.d/polkit-1

# migrations/1788256455.sh repairs an Omarchy polkit file that lists pam_unix
# directly, but only when its clamshell gate is the old lid-closed line. A
# machine that already flipped that gate to omarchy-hw-laptop-open still has
# the bare pam_unix lines, and the shipped repair leaves it alone. This catches
# that file, and a vulnerable file that still has the closed gate.
#
# The allowlist is the shipped one plus the lid-open gate. Any other directive
# means an administrator edited the file, so it is left untouched. A file that
# already includes system-auth is left to the earlier migrations. A closed gate
# on a stack this does rewrite is swapped to the lid-open line.

is_unrepaired_omarchy_stack() {
  local file=$1 line
  local re_gate_closed='^auth[[:space:]]+\[success=1 default=ignore\][[:space:]]+pam_exec\.so quiet /usr/bin/omarchy-hw-laptop-closed[[:space:]]*$'
  local re_gate_open='^auth[[:space:]]+\[success=ignore default=1\][[:space:]]+pam_exec\.so quiet /usr/bin/omarchy-hw-laptop-open[[:space:]]*$'
  local re_fprintd='^auth[[:space:]]+sufficient[[:space:]]+pam_fprintd\.so[[:space:]]*$'
  local re_u2f='^auth[[:space:]]+sufficient[[:space:]]+pam_u2f\.so cue authfile=/etc/fido2/fido2[[:space:]]*$'
  local re_bare='^(auth|account|password|session)[[:space:]]+required[[:space:]]+pam_unix\.so[[:space:]]*$'
  local phase

  if grep -qE '^(auth|account|password|session)[[:space:]]+include[[:space:]]+system-auth' "$file"; then
    return 1
  fi

  for phase in auth account password session; do
    grep -qE "^${phase}[[:space:]]+required[[:space:]]+pam_unix\.so[[:space:]]*\$" "$file" || return 1
  done

  while IFS= read -r line || [[ -n $line ]]; do
    [[ -z ${line//[[:space:]]/} ]] && continue
    [[ $line == \#* ]] && continue
    [[ $line =~ $re_gate_closed || $line =~ $re_gate_open || $line =~ $re_fprintd || $line =~ $re_u2f || $line =~ $re_bare ]] && continue
    return 1
  done <"$file"

  return 0
}

if [[ -f $polkit ]] && is_unrepaired_omarchy_stack "$polkit"; then
  echo "Rewriting $polkit to defer to system-auth without losing the lid-open gate..."

  backup="$polkit.omarchy-bak.$(date +%s)"
  if ! sudo cp -a "$polkit" "$backup"; then
    echo "Could not back up $polkit; leaving it unchanged so the migration retries." >&2
    exit 1
  fi

  if ! sudo sed -i -E \
    -e 's/^(auth|account|password|session)([[:space:]]+)required[[:space:]]+pam_unix\.so[[:space:]]*$/\1\2include system-auth/' \
    -e 's|^auth[[:space:]]+\[success=1 default=ignore\][[:space:]]+pam_exec\.so quiet /usr/bin/omarchy-hw-laptop-closed[[:space:]]*$|auth      [success=ignore default=1] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-open|' \
    "$polkit"; then
    echo "Could not rewrite $polkit; restoring the original file." >&2
    sudo cp -a "$backup" "$polkit"
    exit 1
  fi

  if grep -qE '^auth[[:space:]]+include[[:space:]]+system-auth' "$polkit" &&
    ! grep -q 'omarchy-hw-laptop-closed' "$polkit"; then
    echo "Restored polkit brute-force protection. Previous file saved at $backup."
  else
    echo "polkit repair could not be verified; restoring the original file." >&2
    sudo cp -a "$backup" "$polkit"
    exit 1
  fi
fi
