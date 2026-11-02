#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-update

test_tmp="$boundary_tmp"
stub_bin="$SUDO_TEST_ROOT/bin"
migrate_env="$test_tmp/migrate-env"

# The helper test (migration-env-sanitization-test.sh) checks the sanitizer in
# isolation. This one drives the real bin/omarchy-update so the test fails if the
# call to omarchy_security_run_migrations_sanitized is ever removed from the
# update path: it reproduces a local user who exported an OMARCHY_* path override
# before running `omarchy update -y`, and records the environment omarchy-migrate
# is actually handed. Every step is stubbed, so nothing privileged runs.
steps=(
  omarchy-update-lock
  omarchy-update-requires-free-space
  omarchy-update-confirm
  omarchy-update-pkg-prune
  omarchy-snapshot
  omarchy-update-stay-awake
  omarchy-update-dev
  omarchy-update-keyring
  omarchy-update-system-pkgs
  omarchy-migrate
  omarchy-hook
  omarchy-update-aur-pkgs
  omarchy-update-mise
  omarchy-update-orphan-pkgs
  omarchy-update-analyze-logs
  omarchy-update-status
  omarchy-update-restart
)
for step in "${steps[@]}"; do
  rm -f "$stub_bin/$step"
  printf '#!/bin/bash\nexit 0\n' >"$stub_bin/$step"
  chmod +x "$stub_bin/$step"
done

# omarchy-migrate is the privileged runner the sanitizer wraps. Record whether the
# attacker-exported OMARCHY_* path seam survived to it, and whether the unattended
# flag the update legitimately exports did. OMARCHY_ZRAM_CONF is the exact seam
# migrations/1785013000.sh feeds to a root-run `sudo rm`.
rm -f "$stub_bin/omarchy-migrate"
cat >"$stub_bin/omarchy-migrate" <<'STUB'
#!/bin/bash
{
  printf 'ran=1\n'
  printf 'zram=%s\n' "${OMARCHY_ZRAM_CONF:-<unset>}"
  printf 'unattended=%s\n' "${OMARCHY_UPDATE_UNATTENDED:-<unset>}"
} >"$MIGRATE_ENV"
STUB
chmod +x "$stub_bin/omarchy-migrate"

# OMARCHY_UPDATE_LOGGED stands in for the script(1) wrapper the update re-execs
# itself under (as in update-sequence-test.sh). The OMARCHY_ZRAM_CONF export is
# the attacker-controlled override reaching the update's environment.
rm -f "$migrate_env"
OMARCHY_ZRAM_CONF=/attacker/zram \
  OMARCHY_UPDATE_LOGGED=1 \
  MIGRATE_ENV="$migrate_env" \
  PATH="$stub_bin:$PATH" \
  "$SUDO_TEST_ROOT/bin/omarchy-update" -y >"$test_tmp/out" 2>"$test_tmp/err" ||
  fail "the update did not complete" "$(cat "$test_tmp/err")"

[[ -f $migrate_env ]] ||
  fail "omarchy-migrate never ran, so the sanitizer wiring was not exercised"
grep -qx 'ran=1' "$migrate_env" || fail "omarchy-migrate did not record its run"

grep -qx 'zram=<unset>' "$migrate_env" ||
  fail "an OMARCHY_* path seam reached the root-run migration through omarchy update: $(grep '^zram=' "$migrate_env")"
pass "omarchy update strips a caller OMARCHY_* path override before omarchy-migrate"

grep -qx 'unattended=1' "$migrate_env" ||
  fail "OMARCHY_UPDATE_UNATTENDED was scrubbed, so an unattended update would stop at a migration prompt: $(grep '^unattended=' "$migrate_env")"
pass "omarchy update -y keeps OMARCHY_UPDATE_UNATTENDED through the sanitizer"
