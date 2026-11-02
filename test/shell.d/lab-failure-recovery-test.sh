#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
task_tmp=$(mktemp -d)
trap 'rm -rf "$task_tmp"' EXIT
export HOME="$task_tmp/home" OMARCHY_PATH="$ROOT" OMARCHY_LAB_DATA_DIR="$task_tmp/state"
mkdir -p "$HOME"

(
  source "$ROOT/bin/omarchy-lab-action"
  require_running_lab() { :; }
  session_lab() { bash -c "$1" >"$task_tmp/argv"; }
  run_action run printf '%s\0' 'hello world' 'literal $(false); $HOME' $'first\nsecond'
  python3 - "$task_tmp/argv" <<'PY'
from pathlib import Path
import sys
assert Path(sys.argv[1]).read_bytes().split(b'\0') == [b'hello world', b'literal $(false); $HOME', b'first\nsecond', b'']
PY
)
pass "action run preserves spaces, multiline arguments and literal shell punctuation"

(
  source "$ROOT/bin/omarchy-lab-scenario"
  mkdir -p "$task_tmp/fixture/bin"
  cat >"$task_tmp/fixture/bin/omarchy-lab-transfer" <<'EOF'
#!/bin/bash
printf '%s\0' "$@" >"$ARGV_FILE"
EOF
  chmod +x "$task_tmp/fixture/bin/omarchy-lab-transfer"
  export ARGV_FILE="$task_tmp/scenario-argv"
  encoded=$(jq -cn '["transfer","clipboard-to","first\nsecond"]' | base64 -w0)
  OMARCHY_PATH="$task_tmp/fixture" LAB_ROOT="$task_tmp/fixture" run_command_array "$encoded" >/dev/null
  python3 - "$ARGV_FILE" <<'PY'
from pathlib import Path
import sys
assert Path(sys.argv[1]).read_bytes().split(b'\0') == [b'clipboard-to', b'first\nsecond', b'']
PY
  jq -cn '{schemaVersion:1,name:"bad",steps:[{command:["transfer","clipboard-to","contains\u0000nul"]}]}' >"$task_tmp/nul.json"
  if scenario_valid "$task_tmp/nul.json"; then fail "scenario accepts an unrepresentable NUL argument"; fi
)
pass "scenario dispatch preserves multiline arguments and rejects NUL data"

(
  source "$ROOT/bin/omarchy-lab-checkout"
  DEPLOYMENT_FILE="$task_tmp/deployment.json"
  printf '%s\n' '{"sourceKind":"worktree","path":"/fixture","destination":"/home/lab/fixture"}' >"$DEPLOYMENT_FILE"
  deploy_checkout() { printf '%s\n' '{"commit":"abc","branch":"feature"}'; }
  session_lab() { return 17; }
  if sync_checkout --json >"$task_tmp/sync-output"; then fail "sync hid a shell restart failure"; fi
  [[ ! -s $task_tmp/sync-output ]] || fail "sync reported successful restart JSON"
)
pass "checkout sync propagates restart failure after copying"

(
  source "$ROOT/bin/omarchy-lab-gold"
  IMAGES="$task_tmp/images" CHECKPOINT_DIR="$task_tmp/absent-checkpoints"
  mkdir -p "$IMAGES"
  require_lab() { :; }
  find_pool() { echo fixture; }
  volume_info_json() { echo '{}'; }
  domain_running() { return 1; }
  gold_status_json | jq -e '.checkpointCount == 0' >/dev/null || fail "fresh gold status did not report zero checkpoints"
)
pass "fresh gold status works before any checkpoint directory exists"

(
  source "$ROOT/bin/omarchy-lab-vm"
  mkdir -p "$(dirname "$KEY")"
  printf 'private fixture key\n' >"$KEY"
  touch "$KEY.pub" "$KNOWN_HOSTS"
  disable_lab_controls() { :; }
  close_viewers() { :; }
  domain_running() { return 1; }
  have_domain() { return 1; }
  find_pool() { return 1; }
  update-desktop-database() { :; }
  remove_lab --yes --keep-key >/dev/null
  [[ $(<"$KEY") == "private fixture key" && -f $KEY.pub && ! -e $KNOWN_HOSTS ]] || fail "rebuild removal lost the checkpoint SSH identity"
)
pass "rebuild removal preserves the SSH key and retires stale host keys"

for fault in ssh preparation update; do
  (
    source "$ROOT/bin/omarchy-lab-network"
    printf 'down\n' >"$task_tmp/live-link"
    printf 'down\n' >"$task_tmp/config-link"
    printf 'default\n' >"$task_tmp/source"
    rm -f "$task_tmp/profile-prepared"
    lab_mac() { echo 52:54:00:00:00:01; }
    domain_running() { return 0; }
    sleep() { :; }
    lab_ssh() { [[ $fault != "ssh" ]]; }
    prepare_guest_network() { touch "$task_tmp/profile-prepared"; [[ $fault != "preparation" ]]; }
    stop_guest() { fail "a failed network preparation stops the running guest"; }
    run_virsh() {
      case $1 in
      domif-getlink)
        if [[ ${4:-} == "--config" ]]; then cat "$task_tmp/config-link"; else cat "$task_tmp/live-link"; fi ;;
      domif-setlink)
        if [[ ${5:-} == "--config" ]]; then printf '%s\n' "$4" >"$task_tmp/config-link"; else printf '%s\n' "$4" >"$task_tmp/live-link"; fi ;;
      dumpxml) printf "<interface type='network'>\n<source network='%s'/>\n</interface>\n" "$(<"$task_tmp/source")" ;;
      update-device)
        [[ $fault != "update" ]] || return 9
        sed -n "s/.*<source network='\([^']*\)'.*/\1/p" >"$task_tmp/source" ;;
      *) fail "failure cleanup unexpectedly changed network source: $*" ;;
      esac
    }
    if switch_source omarchy-lab-isolated >/dev/null 2>&1; then fail "failed network change was reported as success"; fi
    [[ $(<"$task_tmp/live-link") == "down" && $(<"$task_tmp/config-link") == "down" ]] || fail "failed isolation left NAT connected"
    [[ $(<"$task_tmp/source") == "default" ]] || fail "failed preparation keeps a mismatched boot network"
    if [[ $fault == "update" && -e $task_tmp/profile-prepared ]]; then fail "rejected libvirt update changed the guest profile"; fi
  )
done
pass "failed network switches preserve the boot network, guest profile and both offline link states"

(
  source "$ROOT/bin/omarchy-lab-checkpoint"
  CHECKPOINT_DIR="$task_tmp/checkpoints"
  printf 'omarchy-lab-isolated\n' >"$task_tmp/network-source"
  printf 'up\n' >"$task_tmp/network-link"
  touch "$task_tmp/running"
  printf 'checkpoint disk\n' >"$task_tmp/current-disk"
  require_lab() { :; }
  find_pool() { echo fixture; }
  domain_running() { [[ -e $task_tmp/running ]]; }
  stop_guest() { rm -f "$task_tmp/running"; }
  lab_mac() { echo 52:54:00:00:00:01; }
  lab_ssh() { echo fixture-version; }
  wait_ssh() { [[ $(<"$task_tmp/network-source") == "omarchy-lab-isolated" ]]; }
  wait_hypr() { :; }
  flatten_checkpoint_image() { :; }
  qemu-img() { printf '%s\n' '{"virtual-size":4096}'; }
  run_virsh() {
    case $1 in
    dumpxml) printf "<interface type='network'>\n<source network='%s'/>\n</interface>\n" "$(<"$task_tmp/network-source")" ;;
    domif-getlink) cat "$task_tmp/network-link" ;;
    domif-setlink) printf '%s\n' "$4" >"$task_tmp/network-link" ;;
    vol-download) cp "$task_tmp/current-disk" "$3" ;;
    vol-upload) cp "$3" "$task_tmp/restored-disk" ;;
    update-device) sed -n "s/.*<source network='\([^']*\)'.*/\1/p" >"$task_tmp/network-source" ;;
    start) touch "$task_tmp/running" ;;
    vol-delete | vol-create-as | pool-refresh) : ;;
    *) fail "unexpected checkpoint command: $*" ;;
    esac
  }
  create_checkpoint network --json >/dev/null
  jq -e '.network == {sourceNetwork:"omarchy-lab-isolated",link:"up"}' "$CHECKPOINT_DIR/network.json" >/dev/null || fail "checkpoint lost its network source"
  printf 'default\n' >"$task_tmp/network-source"
  restore_checkpoint network --yes --json >/dev/null
  [[ $(<"$task_tmp/restored-disk") == "checkpoint disk" && $(<"$task_tmp/network-source") == "omarchy-lab-isolated" ]] || fail "restore did not restore matching disk and network"
)
pass "checkpoint metadata restores the disk's matching network before waiting for SSH"

(
  source "$ROOT/bin/omarchy-lab-viewer"
  enqueue_launch_service() { :; }
  viewer_client() { return 1; }
  sleep() { :; }
  if launch_viewer >"$task_tmp/viewer-output" 2>&1; then fail "an enqueued failed launch was reported as ready"; fi
  rg -q 'viewer did not reopen' "$task_tmp/viewer-output" || fail "startup failure has no bounded error"
)
pass "console launch waits for an actual viewer and exposes startup failure"

python3 - "$ROOT/bin/omarchy-lab-operation-lock" "$task_tmp" <<'PY'
import os
from pathlib import Path
import subprocess
import sys
import time
helper, temporary = sys.argv[1:]
p = Path(temporary)
entered, release, started = (p / name for name in ['entered', 'release', 'started'])
env = dict(os.environ, HELPER=helper, ENTERED=str(entered), RELEASE=str(release), STARTED=str(started))
holder = subprocess.Popen(['bash','-c', 'source "$HELPER"; lab_with_operation_lock bash -c \'touch "$ENTERED"; until [[ -f $RELEASE ]]; do sleep .05; done\''],env=env,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
try:
    deadline = time.monotonic() + 5
    while not entered.exists() and time.monotonic() < deadline:
        time.sleep(.03)
    assert entered.exists(), 'disk operation never acquired lock'
    launch = subprocess.Popen(['bash','-c','source "$HELPER"; lab_with_operation_lock touch "$STARTED"'],env=env,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
    resource_read = p / 'resource-read'
    env['RESOURCE_READ'] = str(resource_read)
    resource = subprocess.Popen(['bash','-c','source "$OMARCHY_PATH/bin/omarchy-lab-resource"; require_lab(){ :; }; resource_status_json(){ touch "$RESOURCE_READ"; return 17; }; set_resource_profile full'],env=env,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
    time.sleep(.2)
    assert not resource_read.exists(), 'resource configuration was read outside the shared operation lock'
    assert not started.exists(), 'launch ran while the disk operation held the lock'
    release.touch()
    assert holder.wait(timeout=5) == 0
    assert launch.wait(timeout=5) == 0 and started.exists()
    assert resource.wait(timeout=5) != 0 and resource_read.exists()
finally:
    release.touch()
    holder.wait(timeout=5)
print('ok - an independent start process waits until the disk-operation lock is released')
PY

python3 - "$ROOT" "$task_tmp" <<'PY'
import os
from pathlib import Path
import re
import signal
import subprocess
import sys
import time
root, temporary = map(Path, sys.argv[1:])
helper = root / 'bin/omarchy-lab-operation-lock'
p = temporary / 'lock-children'
p.mkdir()
setup = re.search(r'  source omarchy-sudo-keepalive[^\n]*\n  trap [^\n]+', (root / 'bin/omarchy-lab-vm').read_text()).group(0)
fixture = p / 'bin'
fixture.mkdir()
(fixture / 'omarchy-sudo-keepalive').write_text('''(sleep 30 >/dev/null 2>&1 & printf '%s' "$!" >"$CHILD_FILE"; wait) >/dev/null 2>&1 &
SUDO_KEEPALIVE_PID=$!
trap "kill $SUDO_KEEPALIVE_PID 2>/dev/null" EXIT
''')
for kind in ['normal', 'failure', 'keepalive']:
    child_file = p / (kind + '-child')
    state = p / (kind + '-state')
    env = dict(os.environ, HELPER=str(helper), OMARCHY_LAB_DATA_DIR=str(state), CHILD_FILE=str(child_file), PATH=str(fixture)+':'+os.environ['PATH'])
    if kind == 'keepalive':
        body = 'setup_keepalive(){\n'+setup+'\n}; setup_keepalive; until [[ -s $CHILD_FILE ]]; do sleep .01; done; exit 17'
    else:
        body = 'sleep 30 >/dev/null 2>&1 & printf "%s" "$!" >"$CHILD_FILE"; exit '+('17' if kind == 'failure' else '0')
    parent = subprocess.run(['bash','-c','source "$HELPER"; lab_operation_lock; '+body],env=env,capture_output=True,text=True,timeout=5)
    try:
        assert parent.returncode == (0 if kind == 'normal' else 17), (kind,parent.stderr,parent.returncode)
        assert child_file.exists()
        child = int(child_file.read_text())
        os.kill(child,0)
        assert subprocess.run(['flock','-n',str(state/'operation.lock'),'true']).returncode == 0, kind+' background child retained the completed operation lock'
    finally:
        if child_file.exists():
            try:os.kill(int(child_file.read_text()),signal.SIGTERM)
            except ProcessLookupError:pass
print('ok - successful, failed and keepalive operations explicitly unlock despite surviving children and preserve failure status')
entered, release = p/'nested-entered', p/'nested-release'
env = dict(os.environ, HELPER=str(helper), OMARCHY_LAB_DATA_DIR=str(p/'nested-state'), ENTERED=str(entered), RELEASE=str(release))
owner = subprocess.Popen(['bash','-c','source "$HELPER"; lab_operation_lock; lab_with_operation_lock true; touch "$ENTERED"; until [[ -f $RELEASE ]]; do sleep .03; done'],env=env,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
try:
    deadline = time.monotonic()+5
    while not entered.exists() and time.monotonic()<deadline:time.sleep(.02)
    assert entered.exists()
    assert subprocess.run(['flock','-n',str(p/'nested-state/operation.lock'),'true']).returncode == 1, 'a nested operation unlocked its active owner'
finally:
    release.touch()
    assert owner.wait(timeout=5)==0
print('ok - nested operations keep their owners lock until the owning operation exits')
PY

(
  source "$ROOT/bin/omarchy-lab-vm"
  have_domain() { return 0; }
  wait_ssh() { :; }
  wait_hypr() { :; }
  session_env=""
  lab_ssh() { bash -c "$1"; }
  result=$(session_lab 'printf "%s\n" "hello world"; printf "%s" "second command"')
  [[ $result == $'hello world\nsecond command' ]] || fail "session command string lost arguments or shell syntax"
)
pass "the workbench session interface executes arguments and intentional shell syntax"

(
  source "$ROOT/bin/omarchy-lab-vm"
  have_domain() { return 1; }
  wait_ssh() { touch "$task_tmp/unexpected-ssh-wait"; }
  wait_hypr() { touch "$task_tmp/unexpected-hypr-wait"; }
  lab_ssh() { touch "$task_tmp/unexpected-guest-command"; }
  if session_lab 'printf hello' >"$task_tmp/missing-output" 2>"$task_tmp/missing-error"; then fail "an uninstalled Lab accepts a workbench session"; fi
  [[ ! -e $task_tmp/unexpected-ssh-wait && ! -e $task_tmp/unexpected-hypr-wait && ! -e $task_tmp/unexpected-guest-command ]] || fail "an uninstalled Lab entered a wait or ran the command"
  rg -q 'install first' "$task_tmp/missing-error" || fail "missing Lab session did not explain how to install"
)
pass "an uninstalled Lab rejects command strings before any startup or wait"

(
  source "$ROOT/bin/omarchy-lab-gold"
  IMAGES="$task_tmp/offline-gold"
  mkdir -p "$IMAGES"
  printf 'old gold\n' >"$IMAGES/$BASE_VOL"
  printf 'current disk\n' >"$IMAGES/$OVERLAY_VOL"
  mkdir -p "$(dirname "$CONFIG_FILE")"
  printf 'DISK=1G\n' >"$CONFIG_FILE"
  touch "$task_tmp/gold-running"
  is_tty() { return 0; }
  confirm_destructive() { return 0; }
  sudo() { return 0; }
  require_lab() { :; }
  find_pool() { echo fixture; }
  preserve_checkpoints() { :; }
  domain_running() { [[ -e $task_tmp/gold-running ]]; }
  stop_guest() { rm -f "$task_tmp/gold-running"; }
  lab_mac() { echo 52:54:00:00:00:01; }
  lab_ssh() { touch "$task_tmp/offline-ssh"; return 1; }
  wait_ssh() { touch "$task_tmp/offline-ssh"; return 1; }
  wait_hypr() { touch "$task_tmp/offline-ssh"; return 1; }
  gold_status_json() { echo '{}'; }
  run_as_root() {
    case $1 in
    qemu-img) cp "$IMAGES/$OVERLAY_VOL" "$IMAGES/${BASE_VOL%.qcow2}.next.qcow2" ;;
    chown) : ;;
    *) "$@" ;;
    esac
  }
  run_virsh() {
    case $1 in
    dumpxml) printf "<interface type='network'>\n<source network='default'/>\n</interface>\n" ;;
    domif-getlink) echo down ;;
    start) touch "$task_tmp/gold-running" ;;
    pool-refresh | vol-delete | vol-create-as) : ;;
    *) fail "unexpected offline promotion command: $*" ;;
    esac
  }
  promote_gold --yes --json >"$task_tmp/offline-gold-result"
  [[ ! -e $task_tmp/offline-ssh && -e $task_tmp/gold-running ]] || fail "offline promotion attempts SSH or fails to restart"
  [[ $(<"$IMAGES/$BASE_VOL") == "current disk" ]] || fail "offline promotion does not publish the current disk"
  jq -e '.promoted == true' "$task_tmp/offline-gold-result" >/dev/null || fail "offline promotion does not report completion"
)
pass "offline gold promotion restarts the guest without waiting for SSH"
