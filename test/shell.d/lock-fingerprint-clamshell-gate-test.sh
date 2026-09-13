#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/bin/omarchy-setup-security-fingerprint"
apply="$ROOT/bin/omarchy-apply-lock"

grep -F 'setup_lock_fingerprint_pam' "$setup" >/dev/null ||
  fail "setup-security-fingerprint still defines setup_lock_fingerprint_pam"

# Extract the lock PAM writer by grepping the function body for the gate.
grep -A20 'setup_lock_fingerprint_pam()' "$setup" | grep -Fq 'omarchy-hw-laptop-closed' ||
  fail "setup_lock_fingerprint_pam writes the clamshell pam_exec gate"

grep -A20 'setup_lock_fingerprint_pam()' "$setup" | grep -Fq 'pam_fprintd.so' ||
  fail "setup_lock_fingerprint_pam still requires pam_fprintd"

# Gate must come before pam_fprintd in the generated lock stack.
python3 - "$setup" <<'PY' || fail "lock PAM gate is ordered before pam_fprintd in setup"
import pathlib, re, sys
text = pathlib.Path(sys.argv[1]).read_text()
m = re.search(r"setup_lock_fingerprint_pam\(\) \{(.*?)^\}", text, re.S | re.M)
body = m.group(1)
if "omarchy-hw-laptop-closed" not in body:
    raise SystemExit(1)
# In the heredoc / tee payload, gate line must appear before pam_fprintd.
idx_gate = body.find("omarchy-hw-laptop-closed")
idx_fp = body.find("pam_fprintd.so")
if idx_gate < 0 or idx_fp < 0 or idx_gate > idx_fp:
    raise SystemExit(1)
PY
pass "setup lock fingerprint PAM includes an ordered clamshell gate"

grep -Fq 'omarchy-hw-laptop-closed' "$apply" ||
  fail "apply-lock writes the clamshell gate into omarchy-lock-fingerprint"
# Order inside apply-lock heredoc
python3 - "$apply" <<'PY' || fail "apply-lock orders the gate before pam_fprintd"
import pathlib, sys
text = pathlib.Path(sys.argv[1]).read_text()
start = text.find("omarchy-lock-fingerprint")
chunk = text[start:start+800]
if chunk.find("omarchy-hw-laptop-closed") > chunk.find("pam_fprintd.so"):
    raise SystemExit(1)
if "omarchy-hw-laptop-closed" not in chunk:
    raise SystemExit(1)
PY
pass "apply-lock lock fingerprint PAM includes an ordered clamshell gate"

migration="$ROOT/migrations/1789261001.sh"
[[ -f $migration ]] || fail "migration repairs existing lock fingerprint PAM"
grep -Fq 'omarchy-lock-fingerprint' "$migration" ||
  fail "migration targets omarchy-lock-fingerprint"
grep -Fq 'omarchy-hw-laptop-closed' "$migration" ||
  fail "migration inserts the laptop-closed gate"
pass "migration installs the lock fingerprint clamshell gate on existing installs"
