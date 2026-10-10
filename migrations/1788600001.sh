echo "Remove leftover lid gates from the fingerprint lock stack"

# Lock is its own PamContext. A leftover success=1 skip of pam_fprintd unlocks
# with the lid closed. A die-gate hides a docked or USB reader. Strip any
# omarchy-hw-laptop-closed line; leave sudo and polkit alone.

pam=/etc/pam.d/omarchy-lock-fingerprint

[[ -f $pam ]] || exit 0
grep -q 'omarchy-hw-laptop-closed' "$pam" || exit 0

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

sed '/omarchy-hw-laptop-closed/d' "$pam" >"$tmp"

if [[ -w $pam ]]; then
  cp "$tmp" "$pam"
elif (( EUID == 0 )); then
  cp "$tmp" "$pam"
else
  sudo cp "$tmp" "$pam"
fi
