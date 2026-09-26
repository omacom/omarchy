#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/bin/omarchy-setup-security-fingerprint"
apply="$ROOT/bin/omarchy-apply-lock"
migration="$ROOT/migrations/1789261001.sh"

# sudo/polkit still get the silent lid-open gate; the lock PAM file must not.
grep -A30 'setup_pam_with_fprintd\|fprintd_gate\|pam.d/sudo' "$setup" | grep -Fq 'omarchy-hw-laptop-open' ||
  fail "fingerprint setup still gates sudo/polkit with omarchy-hw-laptop-open"

python3 - "$setup" <<'PY' || fail "setup_lock_fingerprint_pam must not write a lid gate"
import pathlib, sys
text = pathlib.Path(sys.argv[1]).read_text()
start = text.find("setup_lock_fingerprint_pam()")
if start < 0:
    raise SystemExit("setup_lock_fingerprint_pam missing")
# Next top-level function or end of interesting block
body = text[start : start + 800]
if "omarchy-hw-laptop-open" in body:
    raise SystemExit("lock setup still references omarchy-hw-laptop-open")
if "pam_fprintd.so" not in body:
    raise SystemExit("lock setup must still write pam_fprintd")
PY
pass "setup writes ungated lock fingerprint PAM"

python3 - "$apply" <<'PY' || fail "apply-lock must not gate omarchy-lock-fingerprint"
import pathlib, sys
text = pathlib.Path(sys.argv[1]).read_text()
start = text.find("omarchy-lock-fingerprint")
if start < 0:
    raise SystemExit("apply-lock missing lock fingerprint path")
chunk = text[start : start + 500]
if "omarchy-hw-laptop-open" in chunk:
    raise SystemExit("apply-lock still writes the lid gate into lock PAM")
if "pam_fprintd.so" not in chunk:
    raise SystemExit("apply-lock must still write pam_fprintd")
PY
pass "apply-lock writes ungated lock fingerprint PAM"

grep -Fq 'omarchy-lock-fingerprint' "$migration" ||
  fail "migration targets omarchy-lock-fingerprint"
grep -Fq 'omarchy-hw-laptop-open' "$migration" ||
  fail "migration removes the laptop-open gate"
grep -Fq "sed -i '/omarchy-hw-laptop-open/d'" "$migration" ||
  grep -Fq 'omarchy-hw-laptop-open/d' "$migration" ||
  fail "migration deletes the lid-open line from lock PAM"
pass "migration strips the unlock-on-lid-closed gate from lock PAM"
