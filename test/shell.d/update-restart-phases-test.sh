#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
rm "$SUDO_TEST_ROOT/bin/omarchy-update-restart"
copy_boundary_file bin/omarchy-update-restart
for step in omarchy-state omarchy-restart-sshd omarchy-restart-shell omarchy-system; do
  ln -s test-step "$SUDO_TEST_ROOT/bin/$step"
done
cat >"$SUDO_TEST_ROOT/bin/gum" <<'STUB'
#!/bin/bash
printf 'prompt:%s\n' "$*" >>"$SUDO_TEST_LOG"
exit 1
STUB
chmod +x "$SUDO_TEST_ROOT/bin/gum"
mkdir -p "$SUDO_TEST_HOME/.local/state/omarchy"
touch "$SUDO_TEST_HOME/.local/state/omarchy/reboot-required" "$SUDO_TEST_HOME/.local/state/omarchy/restart-sshd-required"

for mode in --services-only --reboot-only; do
  reset_boundary
  PATH="$SUDO_TEST_ROOT/bin:$PATH" "$SUDO_TEST_ROOT/bin/omarchy-update-restart" "$mode" >"$boundary_tmp/output" 2>&1
  if [[ $mode == "--services-only" ]]; then
    grep -q '^step:omarchy-restart-sshd ' "$SUDO_TEST_LOG" || fail "service phase did not restart a marked service"
    grep -q '^step:omarchy-restart-shell ' "$SUDO_TEST_LOG" || fail "service phase did not restart the shell"
    if grep -q '^prompt:' "$SUDO_TEST_LOG"; then fail "service phase offered a reboot before update cleanup"; fi
  else
    grep -q '^prompt:' "$SUDO_TEST_LOG" || fail "reboot phase did not offer the required reboot"
    if grep -q '^step:omarchy-restart-' "$SUDO_TEST_LOG"; then fail "reboot phase performed later service work"; fi
  fi
  pass "restart $mode performs only its selected phase"
done
reset_boundary
OMARCHY_UPDATE_UNATTENDED=1 PATH="$SUDO_TEST_ROOT/bin:$PATH" "$SUDO_TEST_ROOT/bin/omarchy-update-restart" --reboot-only >"$boundary_tmp/output" 2>&1
if grep -Eq "^(prompt:|step:omarchy-restart-|step:omarchy-system)" "$SUDO_TEST_LOG"; then
  fail "unattended reboot phase prompted or performed service work"
fi
pass "unattended reboot phase reports a required reboot without prompting"

# The service phase remains best-effort so hooks and boot verification still
# run, but must never announce plugin success after a refused restart.
rm "$SUDO_TEST_ROOT/bin/omarchy-restart-shell"
cat >"$SUDO_TEST_ROOT/bin/omarchy-restart-shell" <<'STUB'
#!/bin/bash
echo "Refusing to restart Omarchy shell while the session is locked." >&2
exit 1
STUB
chmod +x "$SUDO_TEST_ROOT/bin/omarchy-restart-shell"
PATH="$SUDO_TEST_ROOT/bin:$PATH" "$SUDO_TEST_ROOT/bin/omarchy-update-restart" --services-only >"$boundary_tmp/output" 2>&1
grep -q 'Shell restart did not complete' "$boundary_tmp/output" || fail "update surfaces an incomplete shell restart"
if grep -q 'Shell startup loads are ready\|All plugins have been reloaded' "$boundary_tmp/output"; then
  fail "update must not announce success before a successful shell restart"
fi
pass "update reports a refused shell restart without aborting later update phases"
