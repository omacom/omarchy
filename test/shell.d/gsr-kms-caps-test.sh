#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

strip="$ROOT/bin/omarchy-strip-gsr-kms-caps"
hook="$ROOT/default/libalpm/hooks/90-omarchy-strip-gsr-kms-caps.hook"
capture="$ROOT/bin/omarchy-capture-screenrecording"

[[ -x $strip ]] || fail "missing omarchy-strip-gsr-kms-caps"
[[ -f $hook ]] || fail "missing gsr-kms-server cap-strip pacman hook"
grep -Fq 'Target = gpu-screen-recorder' "$hook" ||
  fail "cap-strip hook must trigger on gpu-screen-recorder"
grep -Fq 'Exec = /usr/bin/omarchy-strip-gsr-kms-caps' "$hook" ||
  fail "cap-strip hook must call omarchy-strip-gsr-kms-caps"
grep -Fq 'setcap -r /usr/bin/gsr-kms-server' "$strip" ||
  fail "strip helper must clear capabilities on gsr-kms-server"
pass "gsr-kms-server capability strip hook and command are present"

grep -Fq 'gsr_kms_has_sys_admin' "$capture" ||
  fail "screenrecording must detect whether gsr-kms-server still has CAP_SYS_ADMIN"
grep -Fq 'OMARCHY_SCREENRECORD_USE_KMS' "$capture" ||
  fail "screenrecording must allow forcing KMS after restoring the capability"
grep -Fq 'use_portal=true' "$capture" ||
  fail "screenrecording must fall back to portal when CAP_SYS_ADMIN is absent"
pass "screenrecording avoids pkexec when gsr-kms-server has no CAP_SYS_ADMIN"

grep -Fq 'Strip CAP_SYS_ADMIN from gsr-kms-server' "$ROOT/migrations/1789318700.sh" ||
  fail "migration must strip gsr-kms-server capabilities on existing installs"
pass "migration strips gsr-kms-server capabilities on update"
