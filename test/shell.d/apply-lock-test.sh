#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

apply_lock="$ROOT/bin/omarchy-apply-lock"

root_path_guard=$(awk '
  /^if \(\( EUID == 0 \)\); then$/ { inside = 1 }
  inside { print }
  inside && /^fi$/ { exit }
' "$apply_lock")
grep -Fx '  export PATH=/usr/share/omarchy/bin:/usr/local/bin:/usr/bin:/bin' <<<"$root_path_guard" >/dev/null ||
  fail "the root lock helper replaces its inherited command path"
if grep -E '(\.local/bin|target_user|target_home)' <<<"$root_path_guard" >/dev/null; then
  fail "the root lock helper does not retain a user-controlled command directory"
fi
pass "the root lock helper uses only trusted command directories"

grep -F '[[ -x /usr/bin/fprintd-list ]]' "$apply_lock" >/dev/null ||
  fail "the lock helper checks the trusted fprintd-list executable"
grep -F '/usr/bin/fprintd-list "$target_user"' "$apply_lock" >/dev/null ||
  fail "the lock helper invokes fprintd-list by its trusted absolute path"
if grep -F 'omarchy-cmd-present fprintd-list' "$apply_lock" >/dev/null ||
  grep -E '(^|[[:space:];&|])fprintd-list([[:space:]]|$)' "$apply_lock" >/dev/null ||
  grep -E 'command[[:space:]]+-v[[:space:]]+fprintd-list' "$apply_lock" >/dev/null; then
  fail "the lock helper does not resolve fprintd-list through PATH"
fi
pass "the lock helper pins fprintd-list to its packaged system path"

# Model an unprivileged caller whose privileged probe can traverse PAM's parent.
if (( EUID != 0 )); then
  python3 - "$apply_lock" "$ROOT" <<'PYCODE'
import os, pathlib, subprocess, sys, tempfile
source = pathlib.Path(sys.argv[1]).read_text()
with tempfile.TemporaryDirectory(prefix="pam-protected-") as tmp:
    root = pathlib.Path(tmp); protected = root / "protected"; protected.mkdir()
    password = protected / "password"; finger = protected / "fingerprint"
    bindir = root / "bin"; bindir.mkdir()
    sudo = bindir / "sudo"
    sudo.write_text("""#!/bin/bash
chmod 700 "$PROTECTED_DIR"
if [[ -e $SUDO_FAIL_ONCE ]]; then rm "$SUDO_FAIL_ONCE"; chmod 000 "$PROTECTED_DIR"; exit 1; fi
if [[ $1 == systemctl ]]; then exit_code=0
elif [[ $1 == install && $3 == -o && $5 == -g ]]; then /usr/bin/install "$2" "$7" "$8"; exit_code=$?
else "$@"; exit_code=$?; fi
chmod 000 "$PROTECTED_DIR"
exit "$exit_code"
""")
    sudo.chmod(0o755)
    probe = root / "fprintd-list"
    probe.write_text('#!/bin/bash\nprintf "%s\\n" "$TEST_RESULT"\n'); probe.chmod(0o755)
    replacements = {
        "/etc/pam.d/omarchy-lock-password": str(password),
        "/etc/pam.d/omarchy-lock-fingerprint": str(finger),
        "/usr/bin/fprintd-list": str(probe),
        "/usr/lib/systemd/system-sleep/fprintd-resume": str(root / "resume"),
        "/etc/systemd/system/fprintd.service.d/10-stop-timeout.conf": str(root / "timeout"),
        "if omarchy-shell lock status >/dev/null 2>&1; then": "if false; then",
    }
    for old, new in replacements.items():
        assert old in source
        source = source.replace(old, new)
    script = root / "apply"; script.write_text(source)
    env = dict(os.environ, PATH=str(bindir) + os.pathsep + os.environ["PATH"],
               OMARCHY_PATH=sys.argv[2], PROTECTED_DIR=str(protected), SUDO_FAIL_ONCE=str(root / "fail-once"))
    password.write_text("auth required pam_deny.so\n")
    finger.write_text("auth required pam_exec.so /custom/gate\n")
    before = (password.read_bytes(), finger.read_bytes())
    (root / "fail-once").touch()
    os.chmod(protected, 0)
    try:
        run = subprocess.run(["/bin/bash", str(script)], env=dict(env, TEST_RESULT=" - #0: finger"), capture_output=True, text=True)
    finally:
        os.chmod(protected, 0o700)
    assert run.returncode != 0 and (password.read_bytes(), finger.read_bytes()) == before

    for result in (" - #0: right-index-finger", "User x has no fingers enrolled"):
        password.write_text("auth required pam_deny.so\n")
        finger.write_text("auth required pam_exec.so /custom/gate\n")
        before = (password.read_bytes(), finger.read_bytes())
        os.chmod(protected, 0)
        try:
            run = subprocess.run(["/bin/bash", str(script)], env=dict(env, TEST_RESULT=result), capture_output=True, text=True)
        finally:
            os.chmod(protected, 0o700)
        assert run.returncode == 0, run.stderr
        assert (password.read_bytes(), finger.read_bytes()) == before
        finger.unlink(); finger.symlink_to(root / "missing")
        os.chmod(protected, 0)
        try:
            run = subprocess.run(["/bin/bash", str(script)], env=dict(env, TEST_RESULT=result), capture_output=True, text=True)
        finally:
            os.chmod(protected, 0o700)
        assert run.returncode == 0, run.stderr
        assert finger.is_symlink() and not (root / "missing").exists()
        finger.unlink()
PYCODE
  pass "protected custom PAM policies and symlinks survive enrollment and removal"
fi

# Exercise the helper as real root when the suite already has it, or as root in
# an unprivileged user namespace otherwise. A hardened kernel can disable user
# namespaces, so preserve the static coverage above and skip only this probe.
root_runner=()
root_runtime_available=1
if (( EUID != 0 )); then
  if command -v unshare >/dev/null && unshare --user --map-root-user true 2>/dev/null; then
    root_runner=(unshare --user --map-root-user)
  else
    root_runtime_available=0
  fi
fi

if (( ! root_runtime_available )); then
  skip "no unprivileged user namespace; skipping the root lock-helper lookup matrix"
  exit 0
fi

# Retarget the two PAM files, the trusted fprintd-list binary, and the final
# shell status query in copies under this scratch directory. The production
# files and service stay untouched even when this suite itself runs as root.
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

poison_bin="$test_tmp/poison-bin"
trusted_root_bin="$test_tmp/trusted-root-bin"
trusted_fprintd="$test_tmp/trusted-fprintd-list"
password_pam="$test_tmp/omarchy-lock-password"
fingerprint_pam="$test_tmp/omarchy-lock-fingerprint"
attack_marker="$test_tmp/user-fprintd-list-ran"
trusted_uid="$test_tmp/trusted-fprintd-list.uid"
trusted_args="$test_tmp/trusted-fprintd-list.args"
attack_args="$test_tmp/user-fprintd-list.args"
patched_helper="$test_tmp/omarchy-apply-lock-patched"
absolute_only_helper="$test_tmp/omarchy-apply-lock-absolute-only"
root_path_only_helper="$test_tmp/omarchy-apply-lock-root-path-only"
unprotected_helper="$test_tmp/omarchy-apply-lock-unprotected"
hook_source="$test_tmp/fprintd-resume-source"
cp "$ROOT/default/systemd/system-sleep/fprintd-resume" "$hook_source"
timeout_source="$test_tmp/fprintd-stop-timeout-source"
cp "$ROOT/default/systemd/system/fprintd.service.d/10-stop-timeout.conf" "$timeout_source"
target_user=omarchy-regression-user
mkdir -p "$poison_bin" "$trusted_root_bin"

# The runtime copy pins to this isolated root path. It contains every bare
# command the exercised helper needs, but deliberately no fprintd-list.
for helper in grep rm tee install rmdir dirname cat cmp python3; do
  ln -s "/usr/bin/$helper" "$trusted_root_bin/$helper"
done

export TEST_ATTACK_ARGS="$attack_args"
export TEST_ATTACK_MARKER="$attack_marker"
export TEST_TRUSTED_ARGS="$trusted_args"
export TEST_TRUSTED_UID="$trusted_uid"

cat >"$trusted_fprintd" <<'EOF'
#!/bin/bash

printf '%s\n' "$EUID" >"$TEST_TRUSTED_UID"
printf '%s\n' "$*" >"$TEST_TRUSTED_ARGS"
printf '%s\n' "${TEST_FPRINTD_OUTPUT:- - #0: right-index-finger}"
exit "${TEST_FPRINTD_STATUS:-0}"
EOF

cat >"$poison_bin/fprintd-list" <<'EOF'
#!/bin/bash

printf '%s\n' "$EUID" >"$TEST_ATTACK_MARKER"
printf '%s\n' "$*" >"$TEST_ATTACK_ARGS"
printf '%s\n' "${TEST_FPRINTD_OUTPUT:- - #0: right-index-finger}"
exit "${TEST_FPRINTD_STATUS:-0}"
EOF

chmod +x "$trusted_fprintd" "$poison_bin/fprintd-list"

prepare_helper() {
  local destination="$1" keep_root_path="$2" use_absolute_fprintd="$3"

  awk \
    -v password_pam="$password_pam" \
    -v fingerprint_pam="$fingerprint_pam" \
    -v trusted_root_bin="$trusted_root_bin" \
    -v trusted_fprintd="$trusted_fprintd" \
    -v keep_root_path="$keep_root_path" \
    -v use_absolute_fprintd="$use_absolute_fprintd" \
    -v hook_src="$hook_source" \
    -v hook_dst="$test_tmp/system-sleep/fprintd-resume" \
    -v timeout_src="$timeout_source" \
    -v timeout_dst="$test_tmp/fprintd.service.d/10-stop-timeout.conf" '
    {
      line = $0
      gsub("/etc/pam\\.d/omarchy-lock-password", "\"" password_pam "\"", line)
      gsub("/etc/pam\\.d/omarchy-lock-fingerprint", "\"" fingerprint_pam "\"", line)

      if (line == "if (( EUID == 0 )); then" && keep_root_path == 0) {
        print "if (( 0 )); then"
        next
      }
      if (line == "  export PATH=/usr/share/omarchy/bin:/usr/local/bin:/usr/bin:/bin") {
        print "  export PATH=\"" trusted_root_bin "\""
        next
      }
      if (line == "if [[ -x /usr/bin/fprintd-list ]]; then") {
        if (use_absolute_fprintd == 1) {
          print "if [[ -x \"" trusted_fprintd "\" ]]; then"
        } else {
          print "if command -v fprintd-list >/dev/null 2>&1; then"
        }
        next
      }
      if (line == "  fingerprint_status=$(/usr/bin/fprintd-list \"$target_user\" 2>&1 || true)") {
        if (use_absolute_fprintd == 1) {
          print "  fingerprint_status=$(\"" trusted_fprintd "\" \"$target_user\" 2>&1 || true)"
        } else {
          print "  fingerprint_status=$(fprintd-list \"$target_user\" 2>&1 || true)"
        }
        next
      }
      if (line == "resume_hook_src=\"$OMARCHY_PATH/default/systemd/system-sleep/fprintd-resume\"") {
        print "resume_hook_src=\"" hook_src "\""
        next
      }
      if (line == "resume_hook_dst=/usr/lib/systemd/system-sleep/fprintd-resume") {
        print "resume_hook_dst=\"" hook_dst "\""
        next
      }
      if (line == "stop_timeout_src=\"$OMARCHY_PATH/default/systemd/system/fprintd.service.d/10-stop-timeout.conf\"") {
        print "stop_timeout_src=\"" timeout_src "\""
        next
      }
      if (line == "stop_timeout_dst=/etc/systemd/system/fprintd.service.d/10-stop-timeout.conf") {
        print "stop_timeout_dst=\"" timeout_dst "\""
        next
      }
      if (line == "  as_root systemctl daemon-reload" || line == "    as_root systemctl daemon-reload") {
        print "  :"
        next
      }
      if (line == "if omarchy-shell lock status >/dev/null 2>&1; then") {
        print "if false; then"
        next
      }

      print line
    }
  ' "$apply_lock" >"$destination"
  chmod +x "$destination"
}

prepare_helper "$patched_helper" 1 1
prepare_helper "$absolute_only_helper" 0 1
prepare_helper "$root_path_only_helper" 1 0
prepare_helper "$unprotected_helper" 0 0

for helper in "$patched_helper" "$absolute_only_helper" "$root_path_only_helper" "$unprotected_helper"; do
  if grep -F '/etc/pam.d/' "$helper" >/dev/null ||
    grep -F '/usr/bin/fprintd-list' "$helper" >/dev/null ||
    grep -F '/usr/lib/systemd/system-sleep' "$helper" >/dev/null ||
    grep -F '/etc/systemd/system/' "$helper" >/dev/null ||
    grep -F 'systemctl daemon-reload' "$helper" >/dev/null ||
    grep -F 'omarchy-shell lock status' "$helper" >/dev/null; then
    fail "the isolated root fixture redirects every live-system lock-helper target"
  fi
done

reset_runtime_files() {
  rm -f "$password_pam" "$fingerprint_pam" "$trusted_uid" "$trusted_args" "$attack_marker" "$attack_args"
}

run_as_root() {
  local helper="$1" description="$2" output

  if ! output=$(PATH="$poison_bin:/usr/bin:/bin" OMARCHY_INSTALL_USER="$target_user" \
    "${root_runner[@]}" /bin/bash "$helper" 2>&1); then
    fail "$description" "$output"
  fi
}

reset_runtime_files
run_as_root "$patched_helper" "the fully hardened lock helper runs in an isolated root context"
[[ ! -e $attack_marker ]] || fail "the hardened root lock helper executes the user-planted fprintd-list"
grep -Fx '0' "$trusted_uid" >/dev/null || fail "the trusted fprintd-list probe runs with EUID 0"
grep -Fx "$target_user" "$trusted_args" >/dev/null || fail "the trusted fprintd-list probe receives the target user"
[[ -s $password_pam && -s $fingerprint_pam ]] ||
  fail "the isolated root lock-helper run writes both scratch PAM fixtures"
[[ -x $test_tmp/system-sleep/fprintd-resume ]] ||
  fail "the lock helper installs the resume hook beside the fingerprint PAM file"
[[ -f $test_tmp/fprintd.service.d/10-stop-timeout.conf ]] ||
  fail "the lock helper installs the stop-timeout drop-in beside the resume hook"
pass "the hardened root lock helper uses the trusted fingerprint probe"

reset_runtime_files
run_as_root "$absolute_only_helper" "the absolute-path-only lock helper runs in an isolated root context"
[[ ! -e $attack_marker ]] || fail "an absolute fprintd-list path permits the user-planted command"
grep -Fx '0' "$trusted_uid" >/dev/null || fail "the absolute-path defense runs the trusted probe as root"
pass "the absolute fprintd-list path independently blocks the user-planted command"

reset_runtime_files
run_as_root "$root_path_only_helper" "the root-PATH-only lock helper runs in an isolated root context"
[[ ! -e $attack_marker ]] || fail "the trusted root path permits the user-planted fprintd-list"
pass "the trusted root path independently blocks the user-planted command"

# Mutation control: removing both protections must execute the planted command
# as UID 0, proving the matrix detects the original privilege-boundary failure.
reset_runtime_files
run_as_root "$unprotected_helper" "the unprotected mutation runs in an isolated root context"
grep -Fx '0' "$attack_marker" >/dev/null ||
  fail "the root lock-helper fixture detects a PATH-resolved fprintd-list regression"
grep -Fx "$target_user" "$attack_args" >/dev/null ||
  fail "the planted fprintd-list receives the target user"
[[ -s $fingerprint_pam ]] || fail "the planted fprintd-list controls the fingerprint PAM branch"
pass "the root lock-helper matrix rejects the vulnerable PATH lookup"

# A failed probe must retain the recovery machinery needed by a later resume.
run_as_root "$patched_helper" "restore the enrolled fingerprint fixture"
cp "$fingerprint_pam" "$test_tmp/saved-pam"
cp "$test_tmp/system-sleep/fprintd-resume" "$test_tmp/saved-hook"
cp "$test_tmp/fprintd.service.d/10-stop-timeout.conf" "$test_tmp/saved-timeout"
TEST_FPRINTD_OUTPUT="Impossible to get devices: Could not activate remote peer" TEST_FPRINTD_STATUS=1 \
  run_as_root "$patched_helper" "an unavailable daemon preserves fingerprint authentication"
for pair in "$fingerprint_pam:saved-pam" "$test_tmp/system-sleep/fprintd-resume:saved-hook" "$test_tmp/fprintd.service.d/10-stop-timeout.conf:saved-timeout"; do
  cmp -s "${pair%:*}" "$test_tmp/${pair##*:}" || fail "an unknown enrollment probe preserves existing recovery files"
done
pass "an unknown enrollment probe preserves existing recovery files"

# The device name and empty-enrollment prose both contain the word "finger".
TEST_FPRINTD_OUTPUT="User alice has no fingers enrolled for Goodix MOC Fingerprint Sensor." \
  run_as_root "$patched_helper" "an empty enrollment clears fingerprint authentication"
[[ -s $password_pam ]] || fail "password authentication remains configured without fingerprints"
[[ ! -e $fingerprint_pam && ! -e $test_tmp/system-sleep/fprintd-resume && ! -e $test_tmp/fprintd.service.d/10-stop-timeout.conf ]] ||
  fail "empty enrollment removes fingerprint PAM and resume recovery files"
pass "empty enrollment removes fingerprint authentication and its resume recovery"

# Never enable fingerprint PAM before both recovery files are installed.
for source in "$hook_source" "$timeout_source"; do
  reset_runtime_files
  mv "$source" "$source.saved"
  if PATH="$poison_bin:/usr/bin:/bin" OMARCHY_INSTALL_USER="$target_user" \
    "${root_runner[@]}" /bin/bash "$patched_helper" >"$test_tmp/failed-install" 2>&1; then
    fail "missing recovery source must fail installation"
  fi
  [[ ! -e $fingerprint_pam ]] || fail "failed recovery installation cannot create fingerprint PAM"
  mv "$source.saved" "$source"
done
pass "failed recovery installation cannot create fingerprint PAM"

# A provider or administrator can add a readiness/account policy that the
# generic helper must neither replace on a match nor erase on an empty probe.
run_as_root "$patched_helper" "restore default enrollment before custom policy"
printf 'auth requisite pam_exec.so quiet /usr/lib/example/ready\n' >>"$fingerprint_pam"
printf 'account required pam_access.so\n' >>"$password_pam"
printf '# custom recovery\n' >"$test_tmp/system-sleep/fprintd-resume"
cp "$fingerprint_pam" "$test_tmp/custom-fingerprint"
cp "$password_pam" "$test_tmp/custom-password"
for result in ' - #0: right-index-finger' 'User alice has no fingers enrolled' 'Could not activate remote peer'; do
  TEST_FPRINTD_OUTPUT="$result" run_as_root "$patched_helper" "custom authentication survives the probe"
  cmp -s "$fingerprint_pam" "$test_tmp/custom-fingerprint" || fail "keeps custom fingerprint requirements"
  cmp -s "$password_pam" "$test_tmp/custom-password" || fail "keeps custom password requirements"
  [[ $(<"$test_tmp/system-sleep/fprintd-resume") == '# custom recovery' ]] || fail "keeps custom recovery beside custom authentication"
done
pass "custom authentication and recovery survive enrolled, empty and unavailable probes"

# Recovery is customized on its own. A managed fingerprint PAM file must not
# overwrite or delete it, and a stock sibling stays managed.
rm -f "$fingerprint_pam" "$password_pam" \
  "$test_tmp/system-sleep/fprintd-resume" \
  "$test_tmp/fprintd.service.d/10-stop-timeout.conf"
TEST_FPRINTD_OUTPUT=' - #0: right-index-finger' \
  run_as_root "$patched_helper" "restore managed enrollment before custom recovery"
cp "$fingerprint_pam" "$test_tmp/managed-fingerprint"
printf '# custom hook\n' >"$test_tmp/system-sleep/fprintd-resume"
printf '# custom timeout\n' >"$test_tmp/fprintd.service.d/10-stop-timeout.conf"
rm -f "$fingerprint_pam"
TEST_FPRINTD_OUTPUT=' - #0: right-index-finger' \
  run_as_root "$patched_helper" "enrolled probe keeps custom recovery beside managed PAM"
[[ $(<"$test_tmp/system-sleep/fprintd-resume") == '# custom hook' ]] ||
  fail "enrolled probe overwrites a custom resume hook when PAM is managed"
[[ $(<"$test_tmp/fprintd.service.d/10-stop-timeout.conf") == '# custom timeout' ]] ||
  fail "enrolled probe overwrites a custom stop timeout when PAM is managed"
cmp -s "$fingerprint_pam" "$test_tmp/managed-fingerprint" ||
  fail "managed fingerprint PAM is still written beside custom recovery"
TEST_FPRINTD_OUTPUT='User alice has no fingers enrolled' \
  run_as_root "$patched_helper" "empty probe keeps custom recovery beside managed PAM"
[[ $(<"$test_tmp/system-sleep/fprintd-resume") == '# custom hook' ]] ||
  fail "empty enrollment removes a custom resume hook when PAM is managed"
[[ $(<"$test_tmp/fprintd.service.d/10-stop-timeout.conf") == '# custom timeout' ]] ||
  fail "empty enrollment removes a custom stop timeout when PAM is managed"
[[ ! -e $fingerprint_pam ]] ||
  fail "empty enrollment still removes managed fingerprint PAM when recovery is custom"

# One custom recovery file does not freeze its stock sibling.
cp "$hook_source" "$test_tmp/system-sleep/fprintd-resume"
TEST_FPRINTD_OUTPUT='User alice has no fingers enrolled' \
  run_as_root "$patched_helper" "empty probe removes a stock hook beside a custom timeout"
[[ ! -e $test_tmp/system-sleep/fprintd-resume ]] ||
  fail "empty enrollment removes a stock resume hook beside a custom stop timeout"
[[ $(<"$test_tmp/fprintd.service.d/10-stop-timeout.conf") == '# custom timeout' ]] ||
  fail "empty enrollment keeps a custom stop timeout beside a stock resume hook"
printf '# custom hook\n' >"$test_tmp/system-sleep/fprintd-resume"
rm -f "$test_tmp/fprintd.service.d/10-stop-timeout.conf"
TEST_FPRINTD_OUTPUT=' - #0: right-index-finger' \
  run_as_root "$patched_helper" "enrolled probe installs a stock timeout beside a custom hook"
[[ $(<"$test_tmp/system-sleep/fprintd-resume") == '# custom hook' ]] ||
  fail "a custom resume hook survives beside a stock stop timeout"
cmp -s "$test_tmp/fprintd.service.d/10-stop-timeout.conf" "$timeout_source" ||
  fail "a stock stop timeout is still installed beside a custom resume hook"

# A recovery symlink is configuration, and install must not replace it.
rm -f "$test_tmp/system-sleep/fprintd-resume"
printf 'kept\n' >"$test_tmp/custom-hook-target"
ln -s "$test_tmp/custom-hook-target" "$test_tmp/system-sleep/fprintd-resume"
for result in ' - #0: right-index-finger' 'User alice has no fingers enrolled'; do
  TEST_FPRINTD_OUTPUT="$result" \
    run_as_root "$patched_helper" "custom recovery symlink survives the probe"
  [[ -L $test_tmp/system-sleep/fprintd-resume && $(<"$test_tmp/custom-hook-target") == 'kept' ]] ||
    fail "does not replace a custom resume hook symlink"
done
rm -f "$test_tmp/system-sleep/fprintd-resume" "$test_tmp/custom-hook-target" \
  "$test_tmp/fprintd.service.d/10-stop-timeout.conf"
TEST_FPRINTD_OUTPUT=' - #0: right-index-finger' \
  run_as_root "$patched_helper" "restore managed recovery after custom recovery probes"
pass "custom recovery survives enrolled and empty probes when PAM is managed"

# Links are configuration too, and a dangling link must not create its target.
rm "$fingerprint_pam" "$password_pam"
cp "$test_tmp/custom-fingerprint" "$test_tmp/link-original"
ln -s "$test_tmp/custom-fingerprint" "$fingerprint_pam"
ln -s "$test_tmp/missing-password" "$password_pam"
run_as_root "$patched_helper" "custom PAM symlinks remain intact"
[[ -L $fingerprint_pam && -L $password_pam && ! -e $test_tmp/missing-password ]] || fail "does not follow custom PAM links"
cmp -s "$test_tmp/link-original" "$fingerprint_pam" || fail "linked custom fingerprint policy stays intact"
pass "PAM links and dangling links are preserved"
reset_runtime_files

run_as_root "$patched_helper" "restore enrollment before removing fprintd-list"
rm -f "$trusted_fprintd"
run_as_root "$patched_helper" "a missing fingerprint package clears fingerprint authentication"
[[ ! -e $fingerprint_pam && ! -e $test_tmp/system-sleep/fprintd-resume && ! -e $test_tmp/fprintd.service.d/10-stop-timeout.conf ]] ||
  fail "a missing fprintd-list removes fingerprint PAM and resume recovery files"
pass "a missing fprintd-list removes fingerprint authentication and its resume recovery"
