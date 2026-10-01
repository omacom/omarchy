#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/disk" "$test_tmp/inherited"
export CALLS="$test_tmp/calls"
cat >"$test_tmp/bin/coredumpctl" <<'SH'
#!/bin/bash
printf 'dump\n' >>"$CALLS"
[[ ${DUMP_FAIL:-0} == "0" ]] || exit 1
printf 'core bytes' >"${3#--output=}"
SH
cat >"$test_tmp/bin/gdb" <<'SH'
#!/bin/bash
printf 'gdb mode=%s\n' "$(stat -c %a "$3")" >>"$CALLS"
SH
chmod +x "$test_tmp/bin/"*
export PATH="$test_tmp/bin:$PATH"
block=$(sed -n '/^core=\$(mktemp/,/^```/{ /^```/d; p; }' "$ROOT/default/agents/skills/diagnose-crash/SKILL.md")
block=${block//<pid>/4242}
block=${block//<executable>/\/usr\/bin\/true}

run_extract() {
  : >"$CALLS"
  TMPDIR="$test_tmp/inherited" bash -c "${block//\/var\/tmp/$1}" >"$test_tmp/out" 2>&1
}
run_extract "$test_tmp/disk"
grep -Fxq 'gdb mode=600' "$CALLS" || fail "the extracted core is private"
[[ -z $(find "$test_tmp/disk" "$test_tmp/inherited" -type f -print -quit) ]] || fail "the core is removed and TMPDIR is unused"
pass "crash extraction uses a private disk file and cleans it up"

if run_extract "$test_tmp/missing"; then fail "mktemp failure stops extraction"; fi
[[ ! -s $CALLS ]] || fail "no tools run without a core path"
if DUMP_FAIL=1 run_extract "$test_tmp/disk"; then fail "dump failure stops symbolization"; fi
! grep -q '^gdb' "$CALLS" || fail "gdb does not run on a failed dump"
[[ -z $(find "$test_tmp/disk" -type f -print -quit) ]] || fail "failed dumps clean up their temporary file"
pass "crash extraction stops cleanly when allocation or dumping fails"
