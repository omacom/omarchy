#!/bin/bash

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
mkdir -p "$fake_bin"

marker="$test_tmp/marker"

# The hook calls root-owned absolute paths and keeps its marker under /run.
# Neither is writable from a test, so run a copy with the /usr/bin prefix
# dropped and the marker moved. Both edits are textual; the case blocks, the
# set -e behavior and the switch_mode order are the shipped ones.
hook="$test_tmp/force-igpu"
sed -e "s#/usr/bin/supergfxctl#$fake_bin/supergfxctl#g" \
  -e 's#/usr/bin/##g' \
  -e "s#^restore_marker=.*#restore_marker=$marker#" \
  "$ROOT/default/systemd/system-sleep/force-igpu" >"$hook"
chmod +x "$hook"

cat >"$fake_bin/sleep" <<'STUB'
#!/bin/bash
:
STUB

# Request every mode successfully, but never report Vfio back. That is the
# failure in the journal on #11808: "Could not confirm the GPU transition to
# Vfio mode".
cat >"$fake_bin/supergfxctl" <<'STUB'
#!/bin/bash
case "$1" in
  -m)
    printf '%s\n' "$2" >>"$TEST_TMP/requested"
    ;;
  -g)
    echo Hybrid
    ;;
esac
STUB

chmod +x "$fake_bin"/*

: >"$marker"
rm -f "$test_tmp/requested"

set +e
output=$(TEST_TMP="$test_tmp" PATH="$fake_bin:$PATH" "$hook" post suspend 2>&1)
set -e

grep -qxF 'Vfio' "$test_tmp/requested" ||
  fail "resume hook detaches the dGPU through Vfio first" "$output"
grep -qxF 'Integrated' "$test_tmp/requested" ||
  fail "resume hook restores Integrated after an unconfirmed Vfio switch" "$(<"$test_tmp/requested")"
pass "resume hook restores Integrated even when the Vfio switch is not confirmed"

# The restore itself did not confirm either, so the marker has to survive for
# the next resume to retry.
[[ -f $marker ]] || fail "resume hook keeps its marker when the restore fails"
pass "resume hook keeps its marker for the next attempt"
