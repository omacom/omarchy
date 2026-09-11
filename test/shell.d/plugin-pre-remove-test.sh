#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Supervision cases require a real systemd user manager and take about 65 seconds
# concurrently. GNU timeout is only an outer safety net, never the supervisor.
for command in jq python3 git timeout realpath; do
  require_command "$command"
done

TMPDIR=$(mktemp -d)
cleanup() {
  # Check both process identity and scratch-directory ownership before killing
  # a stranded fixture. Hooks execute by relative path, not absolute argv.
  python3 - "$TMPDIR" <<'PY'
import os
from pathlib import Path
import signal
import sys
root = Path(sys.argv[1])
for record in root.glob("**/fixture-pids"):
    for value in record.read_text().splitlines():
        pid, started = value.split()
        pid = int(pid)
        try:
            stat = Path(f"/proc/{pid}/stat").read_text().rsplit(")", 1)[1].split()
            cwd = Path(f"/proc/{pid}/cwd").resolve()
            if stat[19] == started and cwd.is_relative_to(root):
                os.kill(pid, signal.SIGKILL)
        except (FileNotFoundError, ProcessLookupError):
            pass
PY
  rm -rf "$TMPDIR"
}
trap cleanup EXIT

stub_dir="$TMPDIR/stubs"
mkdir -p "$stub_dir"
cat >"$stub_dir/omarchy-shell" <<'STUB'
#!/bin/bash
set -euo pipefail
case "$*" in
  'shell listPlugins')
    if [[ -e $HOME/enabled ]]; then
      printf '[{"id":"acme.cleanup","enabled":true}]\n'
    else
      printf '[{"id":"acme.cleanup","enabled":false}]\n'
    fi
    ;;
  'shell setPluginEnabled acme.cleanup false')
    touch "$HOME/disabled"
    rm -f "$HOME/enabled"
    ;;
  'shell rescanPlugins') touch "$HOME/rescanned" ;;
  *) exit 99 ;;
esac
STUB
chmod +x "$stub_dir/omarchy-shell"
export PATH="$stub_dir:$ROOT/bin:$PATH"
export OMARCHY_PATH="$ROOT"
export EXPECTED_UID
EXPECTED_UID=$(id -u)
export PRE_REMOVE_INHERITED='ordinary inherited environment: $HOME ${MISSING} %n %i %%'

new_plugin() {
  export HOME="$TMPDIR/$1"
  plugins="$HOME/.config/omarchy/plugins"
  target="$plugins/acme.cleanup"
  mkdir -p "$target/bin" "$HOME/external-registry"
  touch "$target/checkout-present" "$HOME/enabled"
  printf '{"plugin":"acme.cleanup","checkout":"installed"}\n' >"$HOME/external-registry/plugin.json"
  cat >"$target/manifest.json" <<'JSON'
{"schemaVersion":1,"id":"acme.cleanup","name":"Cleanup fixture","version":"1.0.0","kinds":["service"],"entryPoints":{"service":"Service.qml"},"hooks":{"preRemove":"bin/cleanup"}}
JSON
  touch "$target/Service.qml"
  cat >"$target/bin/cleanup" <<'PY'
#!/usr/bin/env python3
import json
import os
from pathlib import Path
import sys
home = Path.home()
checkout = Path(__file__).resolve().parent.parent
assert Path.cwd() == checkout
assert (checkout / "checkout-present").is_file()
assert os.getuid() == int(os.environ["EXPECTED_UID"])
assert os.environ["PRE_REMOVE_INHERITED"] == "ordinary inherited environment: $HOME ${MISSING} %n %i %%"
assert sys.stdin.read() == ""
assert not (home / "disabled").exists()
with (home / "attempts").open("a") as attempts:
    attempts.write("cleanup\n")
(home / "external-registry/plugin.json").unlink(missing_ok=True)
if (home / "block-cleanup").exists():
    sys.exit(23)
(home / "receipt.json").write_text(json.dumps({"cwd": str(Path.cwd()), "enabled": (home / "enabled").exists()}))
assert len(sys.argv) == 1
PY
  chmod +x "$target/bin/cleanup"
}

remove_plugin() {
  "$ROOT/bin/omarchy-plugin-remove" acme.cleanup "$@" </dev/null 2>&1
}

assert_retained() {
  [[ -f $target/checkout-present && ! -e $HOME/disabled && ! -e $HOME/rescanned ]] \
    || fail "failed removal retains checkout without disabling or rescanning" "${output:-}"
}

assert_removed() {
  [[ ! -e $target && ! -L $target && -e $HOME/rescanned ]] \
    || fail "successful removal removes installed path and rescans" "${output:-}"
}

new_plugin unconfirmed
output=$(remove_plugin) && fail "noninteractive removal requires confirmation" "$output"
assert_retained
[[ ! -e $HOME/attempts && -e $HOME/external-registry/plugin.json ]] \
  || fail "refusal without confirmation never executes cleanup"
pass "unconfirmed removal never executes plugin code"

new_plugin never-enabled
rm "$HOME/enabled"
output=$(remove_plugin --yes) && fail "--yes alone cannot authorize plugin code" "$output"
assert_retained
[[ ! -e $HOME/attempts && ! -e $HOME/receipt.json && -e $HOME/external-registry/plugin.json ]] \
  || fail "noninteractive consent refusal leaves never-enabled plugin untouched"
pass "--yes alone retains never-enabled checkout without running code"

new_plugin caller-path
cat >"$target/jq" <<'HOOK'
#!/bin/bash
printf 'executed\n' >"$HOME/plugin-jq-ran"
exit 99
HOOK
chmod +x "$target/jq"
output=$(cd "$HOME" && PATH=".:$PATH" "$ROOT/bin/omarchy-plugin-pre-remove" "$target" --check 2>&1) \
  || fail "--check safely accepts caller PATH containing dot" "$output"
[[ $output == "bin/cleanup" && ! -e $HOME/plugin-jq-ran && ! -e $HOME/attempts ]] \
  || fail "--check does not resolve host utilities inside plugin checkout" "$output"
pass "--check never executes plugin-owned jq through caller PATH"

# The approval describes one checkout state, not permission for whatever hook
# happens to be declared later. Every mutation remains otherwise valid.
for mutation in added added-empty added-missing dropped dropped-manifest replaced bytes manifest identity mode root; do
  new_plugin "snapshot-$mutation"
  case "$mutation" in
  added) jq 'del(.hooks)' "$target/manifest.json" >"$HOME/manifest" ;;
  added-empty) jq '.hooks = {}' "$target/manifest.json" >"$HOME/manifest" ;;
  added-missing) rm "$target/manifest.json" ;;
  mode) chmod 755 "$target/bin/cleanup" ;;
  esac
  [[ ! -f $HOME/manifest ]] || mv "$HOME/manifest" "$target/manifest.json"
  snapshot=$("$ROOT/bin/omarchy-plugin-pre-remove" "$target" --snapshot 2>&1) \
    || fail "capture valid checkout before mutation: $mutation" "$snapshot"
  [[ ! -e $HOME/attempts && -e $HOME/external-registry/plugin.json ]] \
    || fail "snapshot never runs plugin code"
  case "$mutation" in
  added | added-empty)
    jq '.hooks = {"preRemove":"bin/cleanup"}' "$target/manifest.json" >"$HOME/manifest"
    ;;
  added-missing)
    printf '{"hooks":{"preRemove":"bin/cleanup"}}\n' >"$HOME/manifest"
    ;;
  dropped) jq 'del(.hooks)' "$target/manifest.json" >"$HOME/manifest" ;;
  dropped-manifest) rm "$target/manifest.json" ;;
  replaced)
    cp "$target/bin/cleanup" "$target/bin/replacement"
    jq '.hooks.preRemove = "bin/replacement"' "$target/manifest.json" >"$HOME/manifest"
    ;;
  bytes) printf '\n# Changed after approval.\n' >>"$target/bin/cleanup" ;;
  manifest) printf '\n' >>"$target/manifest.json" ;;
  identity)
    cp -p "$target/bin/cleanup" "$target/bin/replacement"
    mv "$target/bin/replacement" "$target/bin/cleanup"
    ;;
  mode) chmod 700 "$target/bin/cleanup" ;;
  root)
    cp -a "$target" "$HOME/replacement-checkout"
    mv "$target" "$HOME/original-checkout"
    mv "$HOME/replacement-checkout" "$target"
    ;;
  esac
  [[ ! -f $HOME/manifest ]] || mv "$HOME/manifest" "$target/manifest.json"
  output=$("$ROOT/bin/omarchy-plugin-pre-remove" "$target" --expect "$snapshot" 2>&1) \
    && fail "stale snapshot refuses changed checkout: $mutation" "$output"
  assert_retained
  [[ ! -e $HOME/attempts && ! -e $HOME/receipt.json && -e $HOME/external-registry/plugin.json && -e $HOME/enabled ]] \
    || fail "stale snapshot never runs code or changes plugin state: $mutation"
done
pass "stale approval rejects declaration, executable, manifest, and root changes"

for declaration in absent empty missing-manifest; do
  new_plugin "no-hook-$declaration"
  git -C "$target" init -q
  case "$declaration" in
  absent) jq 'del(.hooks)' "$target/manifest.json" >"$HOME/manifest" ;;
  empty) jq '.hooks = {}' "$target/manifest.json" >"$HOME/manifest" ;;
  missing-manifest) rm "$target/manifest.json" ;;
  esac
  [[ ! -f $HOME/manifest ]] || mv "$HOME/manifest" "$target/manifest.json"
  output=$(remove_plugin --yes) || fail "no-hook recovery works: $declaration" "$output"
  assert_removed
  [[ ! -e $HOME/attempts && -e $HOME/external-registry/plugin.json && -e $HOME/disabled ]] \
    || fail "no-hook removal does not infer cleanup from executable presence: $declaration"
done
pass "absent hooks, empty hooks, and absent manifests retain no-hook removal behavior"

new_plugin dangling-root
rm -rf "$target"
ln -s "$HOME/missing-checkout" "$target"
snapshot=$("$ROOT/bin/omarchy-plugin-pre-remove" "$target" --snapshot)
rm "$target"
ln -s "$HOME/different-missing-checkout" "$target"
output=$("$ROOT/bin/omarchy-plugin-pre-remove" "$target" --expect "$snapshot" 2>&1) \
  && fail "retargeted dangling root rejects stale approval" "$output"
[[ -L $target && ! -e $HOME/disabled && ! -e $HOME/rescanned ]] \
  || fail "retargeted dangling root remains untouched"
output=$(remove_plugin --yes) || fail "dangling installed root remains removable" "$output"
assert_removed
pass "dangling-root recovery revalidates the link before unlinking"

# Every malformed declaration must fail both --check and destructive removal.
# NUL must be rejected before shell command substitution can discard it.
while IFS= read -r hooks; do
  new_plugin invalid-declaration
  # Existing control-character filenames distinguish unsafe-path rejection
  # from merely reporting a missing executable.
  for suffix in $'\n' $'\t' $'\177'; do
    cp "$target/bin/cleanup" "$target/bin/cleanup$suffix"
  done
  jq --argjson hooks "$hooks" '.hooks = $hooks' "$target/manifest.json" >"$HOME/manifest"
  mv "$HOME/manifest" "$target/manifest.json"
  output=$("$ROOT/bin/omarchy-plugin-pre-remove" "$target" --check 2>&1) \
    && fail "helper refuses unsafe declaration: $hooks" "$output"
  output=$(remove_plugin --yes --run-pre-remove) && fail "removal refuses unsafe declaration: $hooks" "$output"
  assert_retained
  [[ ! -e $HOME/attempts && -e $HOME/external-registry/plugin.json ]] \
    || fail "invalid declaration never executes code: $hooks"
  rm -rf "$HOME"
done <<'JSON'
null
[]
"bin/cleanup"
{"preRemove":null}
{"preRemove":7}
{"preRemove":false}
{"preRemove":[]}
{"preRemove":{}}
{"preRemove":""}
{"preRemove":"/bin/true"}
{"preRemove":"../bin/cleanup"}
{"preRemove":"bin/../bin/cleanup"}
{"preRemove":"bin/clean\u0000up"}
{"preRemove":"bin/cleanup\n"}
{"preRemove":"bin/cleanup\t"}
{"preRemove":"bin/cleanup\u007f"}
JSON
pass "invalid hook types and unsafe paths fail before cleanup or destructive actions"

for manifest in malformed null directory; do
  new_plugin "bad-manifest-$manifest"
  case "$manifest" in
  malformed) printf '{"hooks":' >"$target/manifest.json" ;;
  null) printf 'null\n' >"$target/manifest.json" ;;
  directory)
    rm "$target/manifest.json"
    mkdir "$target/manifest.json"
    ;;
  esac
  output=$(remove_plugin --yes --run-pre-remove) && fail "present invalid manifest cannot bypass cleanup: $manifest" "$output"
  assert_retained
  [[ ! -e $HOME/attempts && -e $HOME/external-registry/plugin.json ]] \
    || fail "present invalid manifest leaves external registration untouched"
done
pass "malformed and non-file present manifests cannot silently bypass cleanup"

# Validation is not authorization to execute later: rerun path checks after
# replacing a previously valid executable with each unsafe filesystem state.
for mutation in missing nonexecutable directory symlink-file symlink-parent internal-symlink-file internal-symlink-parent; do
  new_plugin "tampered-$mutation"
  output=$("$ROOT/bin/omarchy-plugin-pre-remove" "$target" --check 2>&1) \
    || fail "helper accepts valid hook before tampering" "$output"
  output=$("$ROOT/bin/omarchy-plugin-validate" "$target" 2>&1) \
    || fail "validator accepts valid hook before tampering" "$output"
  [[ ! -e $HOME/attempts && -e $HOME/external-registry/plugin.json ]] \
    || fail "validation never executes hook"
  case "$mutation" in
  missing) rm "$target/bin/cleanup" ;;
  nonexecutable) chmod -x "$target/bin/cleanup" ;;
  directory)
    rm "$target/bin/cleanup"
    mkdir "$target/bin/cleanup"
    ;;
  symlink-file)
    mv "$target/bin/cleanup" "$HOME/outside-cleanup"
    ln -s "$HOME/outside-cleanup" "$target/bin/cleanup"
    ;;
  symlink-parent)
    mv "$target/bin" "$HOME/outside-bin"
    ln -s "$HOME/outside-bin" "$target/bin"
    ;;
  internal-symlink-file)
    mv "$target/bin/cleanup" "$target/bin/real-cleanup"
    ln -s real-cleanup "$target/bin/cleanup"
    ;;
  internal-symlink-parent)
    mv "$target/bin" "$target/real-bin"
    ln -s real-bin "$target/bin"
    ;;
  esac
  output=$(remove_plugin --yes --run-pre-remove) && fail "runtime rejects tampered hook: $mutation" "$output"
  assert_retained
  [[ ! -e $HOME/attempts && -e $HOME/external-registry/plugin.json ]] \
    || fail "tampered hook is not executed: $mutation"
done
pass "runtime rechecks missing, nonexecutable, non-file, and symlink hooks after validation"

if ! command -v systemd-run >/dev/null || ! systemctl --user show-environment >/dev/null 2>&1; then
  pass "no systemd user manager; skipping supervised hook execution"
  exit 0
fi

# A real non-shell executable removes an external registration while its
# checkout and enabled state still exist; the CLI then deletes the git checkout.
new_plugin enabled-git
git -C "$target" init -q
expected_checkout=$(realpath "$target")
output=$(remove_plugin --yes --run-pre-remove) || fail "enabled plugin cleanup succeeds" "$output"
assert_removed
[[ ! -e $HOME/external-registry/plugin.json && -e $HOME/disabled ]] \
  || fail "enabled cleanup removes registration and then disables plugin"
jq -e --arg cwd "$expected_checkout" '.cwd == $cwd and .enabled == true' "$HOME/receipt.json" >/dev/null \
  || fail "hook runs in checkout before disable"
pass "enabled git plugin cleans external registration before disable and checkout deletion"

# Root install symlinks are supported, even though internal symlinks are not.
new_plugin disabled-symlink
rm "$HOME/enabled"
checkout="$HOME/developer checkout"
mv "$target" "$checkout"
ln -s "$checkout" "$target"
output=$(remove_plugin --yes --run-pre-remove) || fail "disabled linked plugin cleanup succeeds" "$output"
assert_removed
[[ -f $checkout/checkout-present && ! -e $HOME/external-registry/plugin.json && ! -e $HOME/disabled ]] \
  || fail "disabled plugin hook runs while only installed symlink is removed"
jq -e --arg cwd "$(realpath "$checkout")" '.cwd == $cwd and .enabled == false' "$HOME/receipt.json" >/dev/null \
  || fail "linked hook uses canonical checkout"
pass "authorized disabled removal cleans up, unlinks install, and retains canonical checkout"

new_plugin plain-backup
output=$(remove_plugin --yes --run-pre-remove) || fail "plain directory cleanup succeeds" "$output"
assert_removed
backups=("$plugins"/.acme.cleanup.bak.*)
(( ${#backups[@]} == 1 )) && [[ -f ${backups[0]}/checkout-present && ! -e $HOME/external-registry/plugin.json ]] \
  || fail "plain directory moves intact to one backup after cleanup"
pass "plain plugin directory is backed up only after cleanup"

# Cleanup may have partial external effects. Failure must retain the checkout
# and enabled state, allowing the user to correct the cause and retry.
new_plugin retry
git -C "$target" init -q
touch "$HOME/block-cleanup"
output=$(remove_plugin --yes --run-pre-remove) && fail "cleanup failure aborts removal" "$output"
assert_retained
[[ -e $HOME/enabled && ! -e $HOME/external-registry/plugin.json && ! -e $HOME/receipt.json ]] \
  || fail "failed cleanup preserves plugin state without undoing external effects"
rm "$HOME/block-cleanup"
output=$(remove_plugin --yes --run-pre-remove) || fail "corrected cleanup can be retried" "$output"
assert_removed
(( $(wc -l <"$HOME/attempts") == 2 )) && [[ -e $HOME/receipt.json && -e $HOME/disabled ]] \
  || fail "retry reruns cleanup and completes removal"
pass "partial cleanup failure retains enabled checkout and supports correction and retry"

# Supply actual input so this checks the helper's EOF boundary, not the caller's.
new_plugin stdin-eof
snapshot=$("$ROOT/bin/omarchy-plugin-pre-remove" "$target" --snapshot)
output=$("$ROOT/bin/omarchy-plugin-pre-remove" "$target" --expect "$snapshot" \
  <<<"caller input must not reach cleanup" 2>&1) || fail "hook receives EOF rather than caller input" "$output"
[[ -e $HOME/receipt.json && ! -e $HOME/external-registry/plugin.json ]] \
  || fail "cleanup completes with stdin isolated from caller input"
pass "hook stdin is EOF even when the caller supplies input"

# A successful leader must not let removal race a still-running child. The child
# checks the checkout and enabled state after its parent has exited.
new_plugin leader-exit
git -C "$target" init -q
cat >"$target/bin/cleanup" <<'PY'
#!/usr/bin/env python3
import os
from pathlib import Path
import subprocess
import sys
import time
home = Path.home()
if len(sys.argv) > 1:
    (home / "child-ready").touch()
    while not (home / "leader-exiting").exists():
        time.sleep(0.01)
    time.sleep(2)
    assert Path("checkout-present").is_file()
    assert (home / "enabled").exists()
    assert not (home / "disabled").exists()
    (home / "child-completed").touch()
    sys.exit(0)
child = subprocess.Popen([sys.executable, str(Path(__file__).resolve()), "child"])
with (home / "fixture-pids").open("w") as record:
    for pid in (os.getpid(), child.pid):
        started = Path(f"/proc/{pid}/stat").read_text().rsplit(")", 1)[1].split()[19]
        record.write(f"{pid} {started}\n")
while not (home / "child-ready").exists():
    time.sleep(0.01)
(home / "leader-exiting").touch()
PY
chmod +x "$target/bin/cleanup"
output=$(timeout --kill-after=5s 15s "$ROOT/bin/omarchy-plugin-remove" acme.cleanup --yes --run-pre-remove </dev/null 2>&1) \
  || fail "successful leader waits for its child before removal" "$output"
assert_removed
[[ -e $HOME/child-completed && -e $HOME/disabled ]] \
  || fail "child finishes while checkout is still installed and enabled"
pass "successful leader exit waits for remaining child before disable and deletion"

# The default-TERM parent exposes the process-group timeout escape: after the
# parent dies, its TERM-resistant child must still be killed. Also retain the
# both-resistant case. Isolated homes let the real 60s deadlines overlap.
run_timeout_case() (
  trap - EXIT
  new_plugin "timeout-$1"
  export RESISTANT_PARENT="$1"
  git -C "$target" init -q
  cat >"$target/bin/cleanup" <<'PY'
#!/usr/bin/env python3
import os
from pathlib import Path
import signal
import subprocess
import sys
import time
home = Path.home()
if len(sys.argv) > 1:
    signal.signal(signal.SIGTERM, signal.SIG_IGN)
    (home / "child-ready").touch()
    while True:
        time.sleep(0.1)
if os.environ["RESISTANT_PARENT"] == "yes":
    signal.signal(signal.SIGTERM, signal.SIG_IGN)
child = subprocess.Popen([sys.executable, str(Path(__file__).resolve()), "child"])
assert os.getpgid(child.pid) == os.getpgrp()
with (home / "fixture-pids").open("w") as record:
    for pid in (os.getpid(), child.pid):
        started = Path(f"/proc/{pid}/stat").read_text().rsplit(")", 1)[1].split()[19]
        record.write(f"{pid} {started}\n")
while not (home / "child-ready").exists():
    time.sleep(0.01)
(home / "timeout-started").touch()
child.wait()
PY
  chmod +x "$target/bin/cleanup"
  started=$SECONDS
  # A separate outer timeout remains only a safety net for a broken supervisor.
  status=0
  timeout --kill-after=5s 90s "$ROOT/bin/omarchy-plugin-remove" acme.cleanup --yes --run-pre-remove \
    </dev/null >"$HOME/timeout-output" 2>&1 || status=$?
  elapsed=$((SECONDS - started))
  output=$(cat "$HOME/timeout-output")
  (( status != 0 && elapsed >= 64 && elapsed < 85 )) \
    || fail "real deadline kills resistant child with resistant-parent=$1" "status=$status elapsed=${elapsed}s $output"
  assert_retained
  [[ -e $HOME/enabled && -e $HOME/timeout-started && -e $HOME/external-registry/plugin.json ]] \
    || fail "timeout retains enabled checkout and external registration"
  python3 - "$HOME/fixture-pids" <<'PY' || fail "timeout terminates both hook and descendant"
from pathlib import Path
import sys
import time
pids = [line.split() for line in Path(sys.argv[1]).read_text().splitlines()]
for _ in range(100):
    live = []
    for pid, started in pids:
        try:
            # Ignore PID reuse and terminated zombies awaiting init reaping.
            stat = Path(f"/proc/{pid}/stat").read_text().rsplit(")", 1)[1].split()
            if stat[19] == started and stat[0] != "Z":
                live.append(pid)
        except FileNotFoundError:
            pass
    if not live:
        break
    time.sleep(0.01)
else:
    sys.exit(f"fixture processes survived timeout: {live}")
PY
  pass "real supervision kills resistant child with resistant-parent=$1 and aborts removal"
)

run_timeout_case no &
default_parent_case=$!
run_timeout_case yes &
resistant_parent_case=$!
timeout_failures=0
wait "$default_parent_case" || timeout_failures=$((timeout_failures + 1))
wait "$resistant_parent_case" || timeout_failures=$((timeout_failures + 1))
(( timeout_failures == 0 )) || fail "all supervised timeout cases succeed"
