#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/pam" "$scratch/home" "$scratch/tmp"
export VERIFY_LOG="$scratch/log" VERIFY_COUNT="$scratch/count"
export HOME="$scratch/home" TMPDIR="$scratch/tmp"
export PATH="$scratch/bin:$PATH" OMARCHY_PATH="$scratch"

# Relocate only the PAM filesystem boundary, as in fingerprint-package-test.
# Run the complete production setup flow; no host authentication files change.
setup_script="$scratch/setup"
sed "s|/etc/pam.d/|$scratch/pam/|g" "$ROOT/bin/omarchy-setup-security-fingerprint" >"$setup_script"

cat >"$scratch/bin/omarchy-hw-fingerprint" <<'STUB'
#!/bin/bash
exit 0
STUB
cat >"$scratch/bin/omarchy-pkg-missing" <<'STUB'
#!/bin/bash
exit 1
STUB
cat >"$scratch/bin/sudo" <<'STUB'
#!/bin/bash
case "$1" in
  -n) exit 0 ;;
  fprintd-enroll) echo enroll >>"$VERIFY_LOG" ;;
  sed) echo pam >>"$VERIFY_LOG" ;;
  tee) echo pam >>"$VERIFY_LOG"; cat >/dev/null ;;
  *) echo unexpected >>"$VERIFY_LOG"; exit 99 ;;
esac
STUB
cat >"$scratch/bin/busctl" <<'STUB'
#!/bin/bash
exit 1
STUB
cat >"$scratch/bin/omarchy-apply-lock" <<'STUB'
#!/bin/bash
echo apply-lock >>"$VERIFY_LOG"
touch "$OMARCHY_PATH/pam/omarchy-lock-fingerprint"
STUB
cat >"$scratch/bin/sleep" <<'STUB'
#!/bin/bash
printf 'sleep %s\n' "$*" >>"$VERIFY_LOG"
STUB
cat >"$scratch/bin/fprintd-verify" <<'STUB'
#!/bin/bash
count=0
[[ -f $VERIFY_COUNT ]] && read -r count <"$VERIFY_COUNT"
(( count += 1 ))
printf '%s\n' "$count" >"$VERIFY_COUNT"
printf 'verify %s\n' "$count" >>"$VERIFY_LOG"

# Match the command's actual stdout contracts, not generic "device busy" text.
case "$VERIFY_MODE" in
  claim-then-match)
    if (( count < 3 )); then
      echo 'failed to claim device: GDBus.Error:net.reactivated.Fprint.Error.Internal: Open failed'
      exit 1
    fi
    ;;
  no-match)
    echo 'Verify result: verify-no-match (done)'
    exit 1
    ;;
  always-claim)
    echo 'failed to claim device: GDBus.Error:net.reactivated.Fprint.Error.AlreadyInUse: Device was already claimed'
    exit 1
    ;;
  start-failure)
    echo 'VerifyStart failed: GDBus.Error:net.reactivated.Fprint.Error.Internal: device busy'
    exit 1
    ;;
  wait-for-cancel)
    touch "$VERIFY_READY"
    exec /usr/bin/sleep 30
    ;;
  match) ;;
  *) exit 99 ;;
esac
echo 'Verify result: verify-match (done)'
echo verified >>"$VERIFY_LOG"
STUB
chmod +x "$scratch/bin/"*

run_setup() {
  local mode="$1" attempts="$2" sleeps="$3" matched="$4"
  : >"$VERIFY_LOG"
  rm -f "$VERIFY_COUNT" "$scratch/pam/omarchy-lock-fingerprint"
  local status=0
  VERIFY_MODE="$mode" bash "$setup_script" >"$scratch/output" 2>&1 || status=$?
  if [[ $matched == "yes" ]]; then
    (( status == 0 )) || fail "$mode setup completes" "$(cat "$scratch/output")"
  else
    (( status == 1 )) || fail "$mode setup exits 1 when verification fails" "$(cat "$scratch/output")"
  fi
  [[ $(<"$VERIFY_COUNT") == "$attempts" ]] || fail "$mode verification count" "$(cat "$VERIFY_LOG")"
  (( $(grep -c '^sleep 0.5$' "$VERIFY_LOG") == sleeps )) || fail "$mode settle count" "$(cat "$VERIFY_LOG")"
  if grep -q '^unexpected$' "$VERIFY_LOG"; then
    fail "$mode uses only declared privileged boundaries"
  fi
  if [[ $matched == "yes" ]]; then
    grep -q '^pam$' "$VERIFY_LOG" || fail "$mode configures PAM after a match"
    (( $(grep -c '^apply-lock$' "$VERIFY_LOG") == 1 )) || fail "$mode applies lock once"
    local verified=no event
    while read -r event; do
      [[ $event != "verified" ]] || verified=yes
      if [[ $event == "pam" || $event == "apply-lock" ]]; then
        [[ $verified == "yes" ]] || fail "$mode changes authentication only after a match"
      fi
    done <"$VERIFY_LOG"
    grep -q 'Perfect!' "$scratch/output" || fail "$mode reports successful configuration"
  else
    if grep -Eq '^(pam|apply-lock)$' "$VERIFY_LOG" || grep -q 'Perfect!' "$scratch/output"; then
      fail "$mode must not configure or promise authentication"
    fi
    grep -q 'Verification failed' "$scratch/output" || fail "$mode reports verification failure"
  fi
  [[ -z $(find "$scratch/tmp" -mindepth 1 -print -quit) ]] || fail "$mode removes verification logs"
}

run_setup claim-then-match 3 3 yes
pass "claim failures retry and configure PAM only after a match"

run_setup no-match 1 1 no
pass "a wrong fingerprint is verified once and never configures PAM"

run_setup always-claim 5 5 no
pass "claim retry exhaustion is bounded and never configures PAM"

run_setup start-failure 1 1 no
pass "busy text outside a Claim failure does not restart verification"

run_setup match 1 1 yes
pass "a first successful verification configures PAM and lock once"

require_command python3
for signal_name in SIGINT SIGTERM; do
  : >"$VERIFY_LOG"
  rm -f "$VERIFY_COUNT" "$scratch/verify-ready" "$scratch/pam/omarchy-lock-fingerprint"
  VERIFY_MODE=wait-for-cancel VERIFY_READY="$scratch/verify-ready" \
    python3 - "$setup_script" "$scratch/output" "$signal_name" <<'PY' || fail "$signal_name cancels setup"
import os
import signal
import subprocess
import sys
import time

setup_script, output_path, signal_name = sys.argv[1:]
cancel_signal = getattr(signal, signal_name)
with open(output_path, "w") as output:
    process = subprocess.Popen(["bash", setup_script], stdout=output, stderr=output, start_new_session=True)
    try:
        deadline = time.monotonic() + 5
        while not os.path.exists(os.environ["VERIFY_READY"]):
            if process.poll() is not None or time.monotonic() >= deadline:
                raise RuntimeError("verification did not start")
            time.sleep(0.01)
        os.killpg(process.pid, cancel_signal)
        status = process.wait(timeout=5)
        if status not in (-cancel_signal, 128 + cancel_signal):
            raise RuntimeError(f"unexpected cancellation status: {status}")
    finally:
        if process.poll() is None:
            os.killpg(process.pid, signal.SIGKILL)
            process.wait()
PY
  [[ $(<"$VERIFY_COUNT") == 1 ]] || fail "$signal_name does not retry verification"
  if grep -Eq '^(pam|apply-lock)$' "$VERIFY_LOG"; then
    fail "$signal_name must not configure authentication"
  fi
  [[ -z $(find "$scratch/tmp" -mindepth 1 -print -quit) ]] || fail "$signal_name removes verification logs"
  pass "$signal_name removes verification logs without configuring authentication"
done
