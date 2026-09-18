#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

hook="$ROOT/default/libalpm/hooks/70-omarchy-powerprofilesctl-shebang.hook"
fix_script="$ROOT/install/config/fix-powerprofilesctl-shebang.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

stub_dir="$tmp_dir/stub"
mkdir -p "$stub_dir"

# The script elevates with sudo only as a non-root caller, as the migration
# path does. The stub records the call and performs the edit for real so the
# transformation itself is exercised end to end.
export TEST_LOG="$stub_dir/sudo.log"
cat >"$stub_dir/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$TEST_LOG"
shift
exec /usr/bin/sed "$@"
STUB
chmod +x "$stub_dir/sudo"

run_fix() {
  OMARCHY_POWERPROFILESCTL_PATH="$1" PATH="$stub_dir:$PATH" \
    bash -eE -c 'source "$1"' bash "$fix_script"
}

write_target() {
  printf '%s\n' "$1" >"$tmp_dir/powerprofilesctl"
  chmod 755 "$tmp_dir/powerprofilesctl"
}

# A packaged shebang is rewritten to the system python3 interpreter.
write_target '#!/usr/bin/env python3'
: >"$TEST_LOG"
run_fix "$tmp_dir/powerprofilesctl"
[[ $(head -n1 "$tmp_dir/powerprofilesctl") == "#!/bin/python3" ]] ||
  fail "packaged shebang is rewritten" "actual: $(head -n1 "$tmp_dir/powerprofilesctl")"
pass "packaged shebang is rewritten"
(( $(wc -l <"$TEST_LOG") == 1 )) ||
  fail "non-root fix elevates exactly once" "log: $(cat "$TEST_LOG")"
pass "non-root fix elevates exactly once"

# An already-fixed file is left alone, so re-runs and second users do not
# reach for privileges at all.
: >"$TEST_LOG"
run_fix "$tmp_dir/powerprofilesctl"
[[ $(head -n1 "$tmp_dir/powerprofilesctl") == "#!/bin/python3" ]] ||
  fail "already-fixed shebang is preserved"
[[ ! -s $TEST_LOG ]] ||
  fail "already-fixed shebang skips elevation" "log: $(cat "$TEST_LOG")"
pass "already-fixed shebang skips elevation"

# A shebang that never resolved python through env is not ours to touch.
write_target '#!/bin/sh'
: >"$TEST_LOG"
run_fix "$tmp_dir/powerprofilesctl"
[[ $(head -n1 "$tmp_dir/powerprofilesctl") == "#!/bin/sh" ]] ||
  fail "foreign shebang is preserved"
[[ ! -s $TEST_LOG ]] ||
  fail "foreign shebang skips elevation" "log: $(cat "$TEST_LOG")"
pass "foreign shebang skips elevation"

# An absent client is a no-op, not an error, so the hook stays quiet on
# systems that never had the package.
: >"$TEST_LOG"
run_fix "$tmp_dir/absent"
[[ ! -s $TEST_LOG ]] ||
  fail "absent client skips elevation" "log: $(cat "$TEST_LOG")"
pass "absent client skips elevation"

# The hook re-applies the fix whenever the daemon package is installed or
# upgraded, and never aborts a package transaction over its failure.
[[ -f $hook ]] || fail "libalpm hook ships in default/libalpm/hooks"
grep -Fq 'Operation = Install' "$hook" &&
  grep -Fq 'Operation = Upgrade' "$hook" ||
  fail "hook triggers on daemon install and upgrade"
grep -Fq 'Type = Package' "$hook" || fail "hook trigger is package-typed"
grep -Fq 'Target = power-profiles-daemon' "$hook" ||
  fail "hook targets power-profiles-daemon"
grep -Fq 'When = PostTransaction' "$hook" || fail "hook runs post-transaction"
grep -Fq 'Exec = /bin/bash /usr/share/omarchy/install/config/fix-powerprofilesctl-shebang.sh' "$hook" ||
  fail "hook execs the packaged fix script"
! grep -Fq 'AbortOnFail' "$hook" ||
  fail "hook failure does not abort the transaction"
pass "libalpm hook re-applies the fix on daemon install and upgrade"

# Install still wires the script in as the initial application.
grep -Fq 'config/fix-powerprofilesctl-shebang.sh' "$ROOT/install/config/all.sh" ||
  fail "install wires the fix into install/config/all.sh"
pass "install wires the fix into install/config/all.sh"

# One migration repairs installs whose upgrade already reverted the fix, by
# sourcing the packaged script whose own guard keeps the elevation away from
# machines and users that are already fixed.
mapfile -t referencing_migrations < <(grep -lF 'fix-powerprofilesctl-shebang' "$ROOT"/migrations/*.sh || true)
(( ${#referencing_migrations[@]} == 1 )) ||
  fail "exactly one migration references the fix script" \
    "found: ${referencing_migrations[*]:-none}"
migration=${referencing_migrations[0]}
grep -Fq 'source "$OMARCHY_PATH/install/config/fix-powerprofilesctl-shebang.sh"' "$migration" ||
  fail "migration sources the packaged fix script"
pass "migration repairs already-reverted installs"
