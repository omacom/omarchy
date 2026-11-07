#!/bin/bash
#
# The fingerprint setup puts a clamshell gate directly above pam_fprintd, and
# the removal takes it out again. Another module may gate its own lines on the
# same lid check, so each wizard must recognize its gate by position, not by
# the command it runs: the setup gates pam_fprintd even when the stack already
# has some other gate, and the removal leaves every other gate in place.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
pam="$scratch/etc/pam.d"
mkdir -p "$scratch/bin" "$scratch/fprint" "$pam"

for wizard in setup remove; do
  sed -e "s|/etc/pam.d/|$pam/|g" -e "s|/var/lib/fprint/|$scratch/fprint/|g" \
    -e "s|/usr/lib/systemd/|$scratch/usr-systemd/|g" -e "s|/etc/systemd/|$scratch/etc-systemd/|g" \
    "$ROOT/bin/omarchy-$wizard-security-fingerprint" >"$scratch/$wizard.sh"
done

# Privileged file edits run for real, but only on a target inside the scratch
# tree, which is each command's last argument.
cat >"$scratch/bin/sudo" <<'STUB'
#!/bin/bash
case "$1" in
  sed | tee | rm | rmdir)
    if [[ ${!#} != "$TEST_SCRATCH"/* ]]; then
      echo "Privileged call outside the scratch tree: $*" >&2
      exit 98
    fi
    exec "$@"
    ;;
  fprintd-enroll) exec "$@" ;;
  *) echo "Unexpected privileged call: $*" >&2; exit 99 ;;
esac
STUB
cat >"$scratch/bin/omarchy-apply-lock" <<'STUB'
#!/bin/bash
touch "$TEST_PAM/omarchy-lock-fingerprint"
STUB
for command in omarchy-hw-fingerprint fprintd-enroll fprintd-verify omarchy-pkg-drop; do
  printf '#!/bin/bash\nexit 0\n' >"$scratch/bin/$command"
done
printf '#!/bin/bash\nexit 1\n' >"$scratch/bin/omarchy-pkg-missing"
chmod +x "$scratch/bin/"*

run() {
  local wizard=$1

  TEST_SCRATCH="$scratch" TEST_PAM="$pam" OMARCHY_PATH="$scratch" PATH="$scratch/bin:$ROOT/bin:$PATH" \
    bash "$scratch/$wizard.sh" >"$scratch/output" 2>&1 ||
    fail "fingerprint $wizard succeeds" "$(cat "$scratch/output")"
}

stack() {
  printf '%s\n' "$@" | tee "$pam/sudo" >"$pam/polkit-1"
}

assert_stack() {
  local description=$1 expected
  shift
  expected=$(printf '%s\n' "$@")

  for file in sudo polkit-1; do
    [[ $(cat "$pam/$file") == "$expected" ]] ||
      fail "$description ($file)" "$(diff <(printf '%s\n' "$expected") "$pam/$file")"
  done
}

fprintd_gate='auth      [success=1 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed'
fprintd='auth      sufficient pam_fprintd.so'
other_gate='auth      [success=2 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed'
other_hint='auth      optional pam_exec.so seteuid quiet stdout /usr/bin/omarchy-face-match --hint'
other_match='auth      sufficient pam_exec.so seteuid quiet stdout expose_authtok /usr/bin/omarchy-face-match'
base=('auth      include system-auth' 'account   include system-auth' 'session   include system-auth')

stack "${base[@]}"
run setup
assert_stack "setup gates pam_fprintd" "$fprintd_gate" "$fprintd" "${base[@]}"
run setup
assert_stack "setup twice adds nothing twice" "$fprintd_gate" "$fprintd" "${base[@]}"
pass "setup gates pam_fprintd once"

stack "$other_gate" "$other_hint" "$other_match" "${base[@]}"
run setup
assert_stack "setup gates pam_fprintd beside another module's gate" \
  "$fprintd_gate" "$fprintd" "$other_gate" "$other_hint" "$other_match" "${base[@]}"
run setup
assert_stack "setup beside another module's gate adds nothing twice" \
  "$fprintd_gate" "$fprintd" "$other_gate" "$other_hint" "$other_match" "${base[@]}"
pass "setup gates pam_fprintd when another module already gates its own lines"

stack "$fprintd" "$other_gate" "$other_hint" "$other_match" "${base[@]}"
run setup
assert_stack "setup gates an ungated pam_fprintd" \
  "$fprintd_gate" "$fprintd" "$other_gate" "$other_hint" "$other_match" "${base[@]}"
pass "setup repairs a pam_fprintd that an earlier run left ungated"

stack "$fprintd_gate" "$fprintd" "${base[@]}"
run remove
assert_stack "removal takes pam_fprintd and its gate" "${base[@]}"
pass "removal takes pam_fprintd and its gate"

stack "$fprintd_gate" "$fprintd" "$other_gate" "$other_hint" "$other_match" "${base[@]}"
run remove
assert_stack "removal keeps another module's gate below" "$other_gate" "$other_hint" "$other_match" "${base[@]}"
stack "$other_gate" "$other_hint" "$other_match" "$fprintd_gate" "$fprintd" "${base[@]}"
run remove
assert_stack "removal keeps another module's gate above" "$other_gate" "$other_hint" "$other_match" "${base[@]}"
pass "removal leaves another module's gate in place"
