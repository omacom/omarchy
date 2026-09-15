#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$stub_bin" "$test_home"

adapter_dir="$ROOT/default/omarchy/update-bin"
run_bin="$ROOT/bin/omarchy-update-run"

[[ -x $run_bin ]] || fail "omarchy-update-run is installed executable"
pass "omarchy-update-run is installed executable"
[[ -x $adapter_dir/sudo ]] || fail "sudo adapter is installed executable"
pass "sudo adapter is installed executable"
[[ -x $adapter_dir/pkexec ]] || fail "pkexec adapter is installed executable"
pass "pkexec adapter is installed executable"

fake_log="$test_tmp/fake-sudo.log"
stub_pkexec_log="$test_tmp/stub-pkexec.log"
: >"$fake_log"
: >"$stub_pkexec_log"

cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
log="${FAKE_SUDO_LOG:-/dev/null}"
printf '%q ' "$@" >>"$log"
printf '\n' >>"$log"
if [[ ${1:-} != "-n" ]]; then
  echo "fake sudo: missing -n: $*" >&2
  exit 99
fi
shift
while (( $# > 0 )) && [[ ${1:-} == "-n" ]]; do
  shift
done
if (( $# > 0 )) && [[ ${1:-} == "--" ]]; then
  shift
fi
if (( $# == 1 )) && [[ ${1:-} == "-v" ]]; then
  exit 0
fi
if (( $# >= 3 )) && [[ ${1:-} == "-u" ]]; then
  shift 2
fi
if (( $# == 0 )); then
  echo "fake sudo: no command" >&2
  exit 99
fi
exec "$@"
STUB
chmod +x "$stub_bin/sudo"

cat >"$stub_bin/pkexec" <<STUB
#!/bin/bash
printf '%s\n' "\$*" >>"$stub_pkexec_log"
echo "stub pkexec must not run unattended" >&2
exit 99
STUB
chmod +x "$stub_bin/pkexec"

reset_env() {
  unset OMARCHY_UPDATE_REAL_SUDO || true
  unset OMARCHY_UPDATE_ENV_READY || true
}

# Missing args exits 2.
reset_env
set +e
OMARCHY_PATH="$ROOT" "$run_bin" >"$test_tmp/missing.out" 2>"$test_tmp/missing.err"
missing_status=$?
set -e
(( missing_status == 2 )) || fail "omarchy-update-run with no args exits 2" "got $missing_status"
pass "omarchy-update-run with no args exits 2"

# Interactive execs argv unchanged with no PATH change.
reset_env
interactive_path=$(PATH="$stub_bin:$PATH" OMARCHY_PATH="$ROOT" env -u OMARCHY_UPDATE_UNATTENDED -u OMARCHY_UPDATE_REAL_SUDO -u OMARCHY_UPDATE_ENV_READY "$run_bin" bash -c 'printf "%s" "$PATH"')
[[ $interactive_path == "$stub_bin:"* ]] || fail "interactive run keeps caller PATH" "$interactive_path"
[[ $interactive_path != *"$adapter_dir"* ]] || fail "interactive run does not add adapters" "$interactive_path"
pass "interactive run keeps caller PATH with no adapters"

reset_env
interactive_ready=$(PATH="$stub_bin:$PATH" OMARCHY_PATH="$ROOT" env -u OMARCHY_UPDATE_UNATTENDED -u OMARCHY_UPDATE_REAL_SUDO -u OMARCHY_UPDATE_ENV_READY "$run_bin" bash -c 'printf "%s" "${OMARCHY_UPDATE_ENV_READY:-unset}"')
[[ $interactive_ready == "unset" ]] || fail "interactive run does not set ENV_READY" "$interactive_ready"
pass "interactive run does not set ENV_READY"

# Unattended exact -n argv.
reset_env
: >"$fake_log"
out=$(OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" FAKE_SUDO_LOG="$fake_log" "$run_bin" sudo printf '%s' hello)
[[ $out == "hello" ]] || fail "unattended sudo runs the command" "$out"
grep -q '^-n printf ' "$fake_log" || fail "unattended sudo injects exactly one -n" "$(cat "$fake_log")"
pass "unattended sudo injects exactly one -n"

# Stdin pipe preserved through sudo tee.
reset_env
: >"$fake_log"
printf 'hello-stdin\n' | OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" FAKE_SUDO_LOG="$fake_log" "$run_bin" sudo tee "$test_tmp/tee-out" >/dev/null
[[ $(<"$test_tmp/tee-out") == "hello-stdin" ]] || fail "sudo tee preserves stdin" "$(cat "$test_tmp/tee-out" 2>/dev/null)"
pass "sudo tee preserves stdin"

# Stdout, stderr, and exit 37 propagate.
reset_env
set +e
OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" FAKE_SUDO_LOG="$fake_log" "$run_bin" sudo sh -c 'echo out-msg; echo err-msg >&2; exit 37' >"$test_tmp/prop.out" 2>"$test_tmp/prop.err"
prop_status=$?
set -e
(( prop_status == 37 )) || fail "sudo preserves exit 37" "got $prop_status"
grep -q "out-msg" "$test_tmp/prop.out" || fail "sudo preserves stdout" "$(cat "$test_tmp/prop.out")"
grep -q "err-msg" "$test_tmp/prop.err" || fail "sudo preserves stderr" "$(cat "$test_tmp/prop.err")"
pass "sudo preserves stdout stderr and exit 37"

# Nested bash, env, xargs, and mock migration as_root inherit adaptation.
reset_env
: >"$fake_log"
OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" FAKE_SUDO_LOG="$fake_log" "$run_bin" bash -c 'sudo printf "%s" nested-ok' >"$test_tmp/nested.out"
grep -q "nested-ok" "$test_tmp/nested.out" || fail "nested bash sudo runs" "$(cat "$test_tmp/nested.out")"
grep -q '^-n printf ' "$fake_log" || fail "nested bash sudo uses -n" "$(cat "$fake_log")"
pass "nested bash sudo inherits adaptation"

reset_env
: >"$fake_log"
OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" FAKE_SUDO_LOG="$fake_log" "$run_bin" env sudo printf '%s' env-ok >"$test_tmp/env.out"
grep -q "env-ok" "$test_tmp/env.out" || fail "env sudo runs" "$(cat "$test_tmp/env.out")"
grep -q '^-n printf ' "$fake_log" || fail "env sudo uses -n" "$(cat "$fake_log")"
pass "env sudo inherits adaptation"

reset_env
: >"$fake_log"
printf 'xargs-ok\n' >"$test_tmp/xargs-in"
OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" FAKE_SUDO_LOG="$fake_log" "$run_bin" xargs -a "$test_tmp/xargs-in" sudo printf '%s' >"$test_tmp/xargs-out"
grep -q "xargs-ok" "$test_tmp/xargs-out" || fail "xargs sudo runs" "$(cat "$test_tmp/xargs-out")"
grep -q '^-n printf ' "$fake_log" || fail "xargs sudo uses -n" "$(cat "$fake_log")"
pass "xargs sudo inherits adaptation"

reset_env
: >"$fake_log"
cat >"$test_tmp/mock-migration.sh" <<'MIG'
#!/bin/bash
as_root() {
  sudo "$@"
}
as_root printf '%s' migration-ok
MIG
chmod +x "$test_tmp/mock-migration.sh"
OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" FAKE_SUDO_LOG="$fake_log" "$run_bin" bash "$test_tmp/mock-migration.sh" >"$test_tmp/mig.out"
grep -q "migration-ok" "$test_tmp/mig.out" || fail "mock migration as_root runs" "$(cat "$test_tmp/mig.out")"
grep -q '^-n printf ' "$fake_log" || fail "mock migration as_root uses -n" "$(cat "$fake_log")"
pass "mock migration as_root inherits adaptation"

# sudo -v and -u value pass without corrupting values.
reset_env
: >"$fake_log"
OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" FAKE_SUDO_LOG="$fake_log" "$run_bin" sudo -v
grep -q '^-n -v' "$fake_log" || fail "sudo -v passes through with -n" "$(cat "$fake_log")"
pass "sudo -v passes through with -n"

reset_env
: >"$fake_log"
OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" FAKE_SUDO_LOG="$fake_log" "$run_bin" sudo -u testuser printf '%s' u-ok >"$test_tmp/u.out"
grep -q "u-ok" "$test_tmp/u.out" || fail "sudo -u runs the command" "$(cat "$test_tmp/u.out")"
grep -q -- '-u testuser' "$fake_log" || fail "sudo -u value is not corrupted" "$(cat "$fake_log")"
pass "sudo -u value is not corrupted"

# Reentry twice keeps a single adapter PATH and the original sudo.
reset_env
: >"$fake_log"
reentry_env=$(OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" FAKE_SUDO_LOG="$fake_log" "$run_bin" "$run_bin" bash -c 'printf "%s\n%s\n%s\n%s" "$PATH" "$OMARCHY_UPDATE_REAL_SUDO" "${OMARCHY_UPDATE_ENV_READY:-unset}" "$(type -P sudo)"')
reentry_path=$(printf '%s' "$reentry_env" | sed -n '1p')
reentry_real=$(printf '%s' "$reentry_env" | sed -n '2p')
reentry_ready=$(printf '%s' "$reentry_env" | sed -n '3p')
reentry_which=$(printf '%s' "$reentry_env" | sed -n '4p')
[[ $reentry_ready == "1" ]] || fail "reentry keeps ENV_READY=1" "$reentry_ready"
[[ $reentry_real == "$stub_bin/sudo" ]] || fail "reentry preserves original sudo" "$reentry_real"
[[ $reentry_which == "$adapter_dir/sudo" ]] || fail "reentry resolves sudo to the adapter" "$reentry_which"
adapter_count=$(printf '%s' "$reentry_path" | grep -F -o "$adapter_dir" | wc -l)
(( adapter_count == 1 )) || fail "reentry has a single adapter PATH" "$reentry_path"
[[ $reentry_path == "$adapter_dir:"* ]] || fail "reentry keeps adapters at the front" "$reentry_path"
pass "reentry twice keeps single adapter PATH and original sudo"

# Recursive and invalid real paths fail safely.
reset_env
set +e
OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" OMARCHY_UPDATE_REAL_SUDO="$adapter_dir/sudo" OMARCHY_UPDATE_ENV_READY=1 "$run_bin" bash -c 'echo should-not-run' >"$test_tmp/rec.out" 2>"$test_tmp/rec.err"
rec_status=$?
set -e
(( rec_status != 0 )) || fail "adapter real path is rejected"
grep -qi "recurs" "$test_tmp/rec.err" || fail "recursive real path reports recursion" "$(cat "$test_tmp/rec.err")"
pass "adapter real path is rejected"

reset_env
set +e
OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" OMARCHY_UPDATE_REAL_SUDO="$test_tmp/does-not-exist" OMARCHY_UPDATE_ENV_READY=1 "$run_bin" bash -c 'echo should-not-run' >"$test_tmp/bad.out" 2>"$test_tmp/bad.err"
bad_status=$?
set -e
(( bad_status != 0 )) || fail "invalid real path is rejected"
pass "invalid real path is rejected"

reset_env
ln -sf "$adapter_dir/sudo" "$stub_bin/sudo-link"
set +e
OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" OMARCHY_UPDATE_REAL_SUDO="$stub_bin/sudo-link" OMARCHY_UPDATE_ENV_READY=1 "$run_bin" bash -c 'echo should-not-run' >"$test_tmp/link.out" 2>"$test_tmp/link.err"
link_status=$?
set -e
(( link_status != 0 )) || fail "symlinked adapter real path is rejected"
pass "symlinked adapter real path is rejected"

reset_env
set +e
OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$adapter_dir:$stub_bin:$PATH" env -u OMARCHY_UPDATE_REAL_SUDO -u OMARCHY_UPDATE_ENV_READY "$run_bin" bash -c 'echo should-not-run' >"$test_tmp/cap.out" 2>"$test_tmp/cap.err"
cap_status=$?
set -e
(( cap_status != 0 )) || fail "captured adapter sudo is rejected"
pass "captured adapter sudo is rejected"

# pkexec never delegates.
reset_env
: >"$stub_pkexec_log"
set +e
OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" STUB_PKEXEC_LOG="$stub_pkexec_log" FAKE_SUDO_LOG="$fake_log" "$run_bin" pkexec true >"$test_tmp/pkexec.out" 2>"$test_tmp/pkexec.err"
pkexec_status=$?
set -e
(( pkexec_status == 1 )) || fail "pkexec adapter exits 1" "got $pkexec_status"
grep -qi "graphical prompt" "$test_tmp/pkexec.err" || fail "pkexec adapter reports graphical prompt" "$(cat "$test_tmp/pkexec.err")"
[[ ! -s $stub_pkexec_log ]] || fail "pkexec adapter never delegates" "$(cat "$stub_pkexec_log")"
pass "pkexec adapter fails closed without delegating"

# Prompt-enabling flags are rejected.
reset_env
for flag in "-S" "-A" "--stdin" "--askpass" "--prompt" "-p"; do
  : >"$fake_log"
  set +e
  OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" FAKE_SUDO_LOG="$fake_log" "$run_bin" bash -c "sudo $flag printf '%s' hi" >"$test_tmp/rej.out" 2>"$test_tmp/rej.err"
  rej_status=$?
  set -e
  (( rej_status != 0 )) || fail "sudo $flag is rejected" "exit 0"
  [[ ! -s $fake_log ]] || fail "sudo $flag never reaches real sudo" "$(cat "$fake_log")"
done
pass "prompt-enabling sudo flags are rejected"

reset_env
: >"$fake_log"
set +e
OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" FAKE_SUDO_LOG="$fake_log" "$run_bin" bash -c 'sudo -Sn printf "%s" hi' >"$test_tmp/rej2.out" 2>"$test_tmp/rej2.err"
rej2_status=$?
set -e
(( rej2_status != 0 )) || fail "combined -Sn is rejected"
[[ ! -s $fake_log ]] || fail "combined -Sn never reaches real sudo" "$(cat "$fake_log")"
pass "combined prompt-enabling sudo flags are rejected"

# Target-command arguments that look like prompt flags are not rejected.
reset_env
: >"$fake_log"
OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" FAKE_SUDO_LOG="$fake_log" "$run_bin" sudo -- printf '%s' --askpass >"$test_tmp/allow.out" 2>"$test_tmp/allow.err"
[[ $(<"$test_tmp/allow.out") == "--askpass" ]] || fail "sudo -- passes target args" "$(cat "$test_tmp/allow.out")"
pass "sudo -- passes target args untouched"

reset_env
OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" FAKE_SUDO_LOG="$fake_log" "$run_bin" sudo printf '%s' --askpass >"$test_tmp/allow2.out" 2>"$test_tmp/allow2.err"
[[ $(<"$test_tmp/allow2.out") == "--askpass" ]] || fail "command args named like prompt flags pass" "$(cat "$test_tmp/allow2.out")"
pass "command args named like prompt flags pass"

# Argv with spaces is preserved.
reset_env
spaced=$(OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" FAKE_SUDO_LOG="$fake_log" "$run_bin" sudo printf '%s|' "a b" "c d")
[[ $spaced == "a b|c d|" ]] || fail "spaced argv is preserved" "$spaced"
pass "spaced argv is preserved"

# Manual adapter call without a captured path fails safely.
reset_env
set +e
env -u OMARCHY_UPDATE_REAL_SUDO "$adapter_dir/sudo" printf '%s' hi >"$test_tmp/manual.out" 2>"$test_tmp/manual.err"
manual_status=$?
set -e
(( manual_status != 0 )) || fail "manual sudo adapter call fails safely"
pass "manual sudo adapter call fails safely"

# Missing adapter installation fails with a useful error.
reset_env
set +e
OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$test_tmp/empty" PATH="$stub_bin:$PATH" "$run_bin" bash -c 'echo should-not-run' >"$test_tmp/noinst.out" 2>"$test_tmp/noinst.err"
noinst_status=$?
set -e
(( noinst_status != 0 )) || fail "missing adapter installation fails"
grep -q "adapter" "$test_tmp/noinst.err" || fail "missing adapter reports installation" "$(cat "$test_tmp/noinst.err")"
pass "missing adapter installation fails"

# No parent PATH or environment pollution.
reset_env
parent_path="$PATH"
parent_real="${OMARCHY_UPDATE_REAL_SUDO:-unset}"
parent_ready="${OMARCHY_UPDATE_ENV_READY:-unset}"
OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" FAKE_SUDO_LOG="$fake_log" "$run_bin" bash -c 'true'
[[ $PATH == "$parent_path" ]] || fail "parent PATH is unchanged"
[[ ${OMARCHY_UPDATE_REAL_SUDO:-unset} == "$parent_real" ]] || fail "parent REAL_SUDO is unchanged"
[[ ${OMARCHY_UPDATE_ENV_READY:-unset} == "$parent_ready" ]] || fail "parent ENV_READY is unchanged"
pass "parent PATH and environment are unchanged"
