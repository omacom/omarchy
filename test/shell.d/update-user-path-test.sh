#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-update

# Model the two exec boundaries without a host update log or a real lock.
# Both child processes inherit the environment exactly as script/lock would.
cat >"$SUDO_TEST_ROOT/bin/script" <<'STUB'
#!/bin/bash
printf 'logged-reexec\n' >>"$SUDO_TEST_LOG"
printf 'transcript:%s:%s\n' "$3" "${OMARCHY_UPDATE_LOG:-}" >>"$SUDO_TEST_LOG"
[[ $1 == "-qefc" ]] || exit 90
exec /usr/bin/bash -c "$2"
STUB
rm "$SUDO_TEST_ROOT/bin/omarchy-update-lock"
cat >"$SUDO_TEST_ROOT/bin/omarchy-update-lock" <<'STUB'
#!/bin/bash
case "$1" in
  held) [[ ${SUDO_TEST_LOCKED:-0} == "1" ]] ;;
  run)
    shift
    printf 'locked-reexec\n' >>"$SUDO_TEST_LOG"
    export SUDO_TEST_LOCKED=1
    exec "$@"
    ;;
esac
STUB
mkdir "$boundary_tmp/user commands"
cat >"$boundary_tmp/user commands/update-user-tool" <<'STUB'
#!/bin/bash
printf 'user-tool:%s\n' "$1" >>"$SUDO_TEST_LOG"
STUB
chmod +x "$SUDO_TEST_ROOT/bin/script" "$SUDO_TEST_ROOT/bin/omarchy-update-lock" "$boundary_tmp/user commands/update-user-tool"

for step in omarchy-hook omarchy-update-mise; do
  rm "$SUDO_TEST_ROOT/bin/$step"
  cat >"$SUDO_TEST_ROOT/bin/$step" <<'STUB'
#!/bin/bash
[[ -e $SUDO_TEST_CACHE ]] || exit 91
update-user-tool "${0##*/}"
STUB
  chmod +x "$SUDO_TEST_ROOT/bin/$step"
done

for entry in fresh logged locked; do
  reset_boundary
  unset OMARCHY_UPDATE_LOGGED SUDO_TEST_LOCKED
  case "$entry" in
    logged) export OMARCHY_UPDATE_LOGGED=1 ;;
    locked) export OMARCHY_UPDATE_LOGGED=1 SUDO_TEST_LOCKED=1 ;;
  esac
  PATH="$boundary_tmp/user commands:$PATH" "$SUDO_TEST_ROOT/bin/omarchy-update" -y >"$boundary_tmp/output" 2>&1 ||
    fail "$entry update lost the original user PATH" "$(<"$boundary_tmp/output")"
  grep -q '^user-tool:omarchy-hook$' "$SUDO_TEST_LOG" || fail "$entry hook could not run a user-installed tool"
  grep -q '^user-tool:omarchy-update-mise$' "$SUDO_TEST_LOG" || fail "$entry mise could not run a user-installed tool"
  if [[ $entry == "fresh" ]]; then
    grep -q '^logged-reexec$' "$SUDO_TEST_LOG" || fail "fresh update did not exercise the logging exec"
  fi
  if [[ $entry != "locked" ]]; then
    grep -q '^locked-reexec$' "$SUDO_TEST_LOG" || fail "$entry update did not exercise the lock exec"
  fi
  pass "$entry update preserves the original user PATH through logging and locking and shares its authorization"
done

# The transcript holds root-only output, so it goes to the caller's own runtime
# dir, or a private temp file without one, never shared /tmp. The analyzer is
# told which file it is.
mkdir -m 700 "$boundary_tmp/runtime" "$boundary_tmp/tmp"
for runtime in "$boundary_tmp/runtime" "$boundary_tmp/missing-runtime"; do
  reset_boundary
  unset OMARCHY_UPDATE_LOGGED SUDO_TEST_LOCKED
  PATH="$boundary_tmp/user commands:$PATH" XDG_RUNTIME_DIR="$runtime" TMPDIR="$boundary_tmp/tmp" \
    "$SUDO_TEST_ROOT/bin/omarchy-update" -y >"$boundary_tmp/output" 2>&1 ||
    fail "update with runtime dir $runtime failed" "$(<"$boundary_tmp/output")"
  IFS=: read -r _ transcript announced < <(grep '^transcript:' "$SUDO_TEST_LOG")
  [[ $transcript == "$announced" ]] || fail "update tells the analyzer which transcript it writes" "$transcript vs $announced"
  if [[ $runtime == "$boundary_tmp/runtime" ]]; then
    [[ $transcript == "$runtime/omarchy-update.log" ]] || fail "update writes its transcript to the runtime dir" "$transcript"
  else
    [[ $transcript == "$boundary_tmp/tmp/"* && $(stat -c %a "$transcript") == "600" ]] ||
      fail "update without a runtime dir writes its transcript to a private temp file" "$transcript"
  fi
done
pass "update writes its transcript privately and tells the analyzer where"

printf 'Updating linux initcpios\n' >"$boundary_tmp/transcript"
OMARCHY_UPDATE_LOG="$boundary_tmp/transcript" bash "$ROOT/bin/omarchy-update-analyze-logs" >"$boundary_tmp/output" 2>&1
grep -q "Initramfs generation may have failed" "$boundary_tmp/output" ||
  fail "analyzer reads the transcript the update names" "$(<"$boundary_tmp/output")"
pass "analyzer reads the transcript the update names"
