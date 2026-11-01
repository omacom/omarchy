#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

python3 - "$ROOT" <<'PY'
import copy
import importlib.util
import os
from pathlib import Path
import socket
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

root = Path(sys.argv.pop())
spec = importlib.util.spec_from_file_location("parallels", root / "default/hypr/parallels.py")
parallels = importlib.util.module_from_spec(spec)
spec.loader.exec_module(parallels)


class Compositor:
  def __init__(self):
    self.outputs = [{"name": "Virtual-1", "width": 1024, "height": 768,
      "scale": 2, "x": 0, "y": 0, "transform": 0, "disabled": False,
      "dpmsStatus": True, "mirrorOf": "none"}]
    self.applied = []

  def monitors(self):
    return copy.deepcopy(self.outputs)

  def configure(self, monitor, mode, scale):
    self.applied.append((monitor["name"], mode, scale))
    width, height = parallels.parse_mode(mode)
    output = next(output for output in self.outputs if output["name"] == monitor["name"])
    output.update(width=width, height=height, scale=scale)


class ResizeTests(unittest.TestCase):
  def setUp(self):
    self.scratch = tempfile.TemporaryDirectory()
    self.addCleanup(self.scratch.cleanup)
    self.directory = Path(self.scratch.name)
    environment = patch.dict(os.environ, {"HOME": str(self.directory),
      "XDG_CONFIG_HOME": str(self.directory / ".config"),
      "XDG_STATE_HOME": str(self.directory / ".local/state")})
    environment.start()
    self.addCleanup(environment.stop)
    self.drm = self.directory / "drm"
    self.drm.mkdir()
    self.scale_log = self.directory / "monitor-scaling.log"
    self.compositor = Compositor()
    self.bridge = parallels.ResizeBridge(self.compositor, self.drm, self.scale_log)
    self.mode("Virtual-1", "6400x3600")

  def mode(self, output, mode, card=7):
    connector = self.drm / f"card{card}-{output}"
    connector.mkdir(exist_ok=True)
    connector.joinpath("modes").write_text(mode + "\n1024x768\n")

  def preference(self, scale, effective=None, sequence=1):
    self.scale_log.write_text(f"at={sequence}\trequested={scale}\tnew={effective or scale}\tmonitor=Virtual-1\n")

  def test_resize_and_reload_keep_the_host_mode_without_writing_config(self):
    personal_config = self.directory / ".config/hypr/monitors.lua"
    personal_config.parent.mkdir(parents=True)
    personal_config.write_text('hl.monitor({output="", mode="preferred", scale=2})\n')
    original = personal_config.read_bytes()
    self.assertTrue(self.bridge.reconcile({"startup"}))
    self.assertEqual(self.compositor.applied[-1], ("Virtual-1", "6400x3600", 2))
    # A config reload restores the old preferred resolution. The next event
    # must restore the host request even though that request has not changed.
    self.compositor.outputs[0].update(width=1024, height=768)
    self.assertTrue(self.bridge.reconcile({"config"}))
    self.assertEqual(self.compositor.outputs[0]["width"], 6400)
    self.assertEqual(personal_config.read_bytes(), original)

  def test_fractional_preference_survives_a_size_that_needs_rounding(self):
    self.preference(1.25)
    self.compositor.outputs[0].update(scale=1.25, width=6400, height=3600)
    self.bridge.reconcile({"startup"})
    self.mode("Virtual-1", "1744x1092")
    self.assertTrue(self.bridge.reconcile({"hotplug"}))
    rounded = self.compositor.applied[-1][2]
    self.assertGreaterEqual(rounded, 1.25)
    self.assertAlmostEqual(1744 / rounded, round(1744 / rounded), places=4)
    self.assertAlmostEqual(1092 / rounded, round(1092 / rounded), places=4)
    self.mode("Virtual-1", "6400x3600")
    self.bridge.reconcile({"hotplug"})
    self.assertEqual(self.compositor.applied[-1][2], 1.25)

  def test_scaling_controls_override_a_previous_preference(self):
    self.bridge.reconcile({"startup"})
    self.preference(1.6)
    self.compositor.outputs[0]["scale"] = 1.6
    self.bridge.reconcile({"scale"})
    self.mode("Virtual-1", "2560x1600")
    self.bridge.reconcile({"hotplug"})
    self.assertEqual(self.compositor.applied[-1][2], 1.6)

  def test_reload_and_restart_keep_requested_scale_instead_of_saved_rounding(self):
    self.preference(1.25, effective=4 / 3)
    self.mode("Virtual-1", "1744x1092")
    self.compositor.outputs[0].update(width=1744, height=1092, scale=4 / 3)
    self.bridge.reconcile({"startup"})
    self.mode("Virtual-1", "6400x3600")
    self.bridge.reconcile({"hotplug"})
    self.assertEqual(self.compositor.outputs[0]["scale"], 1.25)
    self.compositor.outputs[0]["scale"] = 4 / 3
    self.bridge.reconcile({"config"})
    self.assertEqual(self.compositor.outputs[0]["scale"], 1.25)
    self.compositor.outputs[0]["scale"] = 4 / 3
    restarted = parallels.ResizeBridge(self.compositor, self.drm, self.scale_log)
    restarted.reconcile({"startup"})
    self.assertEqual(self.compositor.outputs[0]["scale"], 1.25)

  def test_manual_scale_reload_does_not_revert_to_a_stale_audit_record(self):
    self.preference(2)
    self.bridge.reconcile({"startup"})
    self.compositor.outputs[0]["scale"] = 1.6
    self.bridge.reconcile({"config"})
    self.mode("Virtual-1", "2560x1600")
    self.bridge.reconcile({"hotplug"})
    self.assertEqual(self.compositor.applied[-1][2], 1.6)
    self.compositor.outputs[0]["scale"] = 2
    self.bridge.reconcile({"config"})
    self.mode("Virtual-1", "1920x1080")
    self.bridge.reconcile({"hotplug"})
    self.assertEqual(self.compositor.applied[-1][2], 2)

  def test_disabled_mirrored_and_physical_outputs_are_left_alone(self):
    self.compositor.outputs[0]["disabled"] = True
    self.compositor.outputs.extend([
      dict(self.compositor.outputs[0], name="DP-1", disabled=False),
      dict(self.compositor.outputs[0], name="Virtual-2", disabled=False, mirrorOf="Virtual-1")])
    self.mode("DP-1", "1920x1080")
    self.mode("Virtual-2", "1920x1080")
    self.assertTrue(self.bridge.reconcile({"startup"}))
    self.assertEqual(self.compositor.applied, [])

  def test_ambiguous_connectors_are_not_guessed(self):
    self.mode("Virtual-1", "1920x1080", card=8)
    self.assertFalse(self.bridge.reconcile({"hotplug"}))
    self.assertEqual(self.compositor.applied, [])

  def test_invalid_modes_and_scale_log_values_are_rejected(self):
    self.preference("nan")
    self.mode("Virtual-1", '6400x3600); os.execute("false")')
    self.assertFalse(self.bridge.reconcile({"hotplug"}))
    self.assertEqual(self.compositor.applied, [])

  def test_nonfinite_scale_records_cannot_replace_the_current_scale(self):
    self.preference("nan")
    self.bridge.reconcile({"startup"})
    self.assertEqual(self.compositor.applied[-1][2], 2)

  def test_unrelated_and_forged_kernel_events_are_ignored(self):
    event = b"change@/devices/test\0ACTION=change\0SUBSYSTEM=drm\0HOTPLUG=1\0"
    self.assertTrue(parallels.drm_hotplug(event, 0))
    self.assertFalse(parallels.drm_hotplug(event, 1000))
    self.assertFalse(parallels.drm_hotplug(event.replace(b"drm", b"net"), 0))

  def test_verified_resize_does_not_apply_again_on_unrelated_events(self):
    self.bridge.reconcile({"startup"})
    self.bridge.reconcile({"resume"})
    self.assertEqual(len(self.compositor.applied), 1)


class EventTests(unittest.TestCase):
  def watcher(self, successful, ready=True):
    watcher = parallels.EventLoop.__new__(parallels.EventLoop)
    self.delays = []
    self.stopped = []
    watcher.GLib = SimpleNamespace(timeout_add=lambda delay, callback: self.delays.append(delay) or len(self.delays))
    watcher.bridge = SimpleNamespace(reconcile=lambda reasons: successful)
    watcher.loop = SimpleNamespace(quit=lambda: self.stopped.append(True))
    watcher.pending = {"hotplug"}
    watcher.timeout_id = 0
    watcher.attempt = 0
    watcher.ready = ready
    watcher.startup_failed = False
    return watcher

  def test_migrated_scale_log_is_read_and_its_changes_are_watched(self):
    with tempfile.TemporaryDirectory() as directory:
      state = Path(directory) / "omarchy/monitors"
      state.mkdir(parents=True)
      (state / "scaling").write_text("monitor=Virtual-1\tpreferred=1.25\tnew=1.333333\n")
      with patch.dict(os.environ, {"XDG_STATE_HOME": directory,
          "XDG_RUNTIME_DIR": directory, "HYPRLAND_INSTANCE_SIGNATURE": "test"}), \
          patch.object(parallels, "EventLoop") as loop:
        parallels.main()
      bridge, instance_path, watched_directory = loop.call_args.args
      self.assertEqual(parallels.scale_records(bridge.scale_log)["Virtual-1"].preferred, 1.25)
      # Gio directory monitors are not recursive: the file must be an immediate child.
      self.assertEqual(watched_directory, bridge.scale_log.parent)
      watcher = self.watcher(True)
      watcher.pending.clear()
      watcher.scale_event(None, SimpleNamespace(get_basename=lambda: "settings"), None, None)
      self.assertEqual(watcher.pending, set())
      watcher.scale_event(None, SimpleNamespace(get_basename=lambda: "scaling"), None, None)
      self.assertEqual(watcher.pending, {"scale"})

  def test_successful_refresh_leaves_no_idle_timer(self):
    watcher = self.watcher(True)
    watcher.flush()
    self.assertEqual(self.delays, [])
    self.assertEqual(watcher.pending, set())

  def test_failed_refresh_has_bounded_retries_instead_of_polling_forever(self):
    watcher = self.watcher(False)
    for attempt in range(len(watcher.RETRIES) + 2):
      watcher.flush()
    self.assertEqual(len(self.delays), len(watcher.RETRIES))
    self.assertEqual(watcher.pending, set())

  def test_readiness_is_sent_only_after_a_verified_initial_refresh(self):
    with tempfile.TemporaryDirectory() as directory:
      address = str(Path(directory) / "notify")
      with socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM) as receiver:
        receiver.bind(address)
        receiver.settimeout(1)
        with patch.dict(os.environ, {"NOTIFY_SOCKET": address}):
          watcher = self.watcher(False, ready=False)
          watcher.flush()
          self.assertFalse(watcher.ready)
          watcher.bridge.reconcile = lambda reasons: True
          watcher.flush()
          self.assertEqual(receiver.recv(64), b"READY=1")
          self.assertTrue(watcher.ready)


unittest.main(verbosity=2)
PY

pass "Parallels mode reconciliation and scale preferences"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
fixture_home="$test_tmp/home with spaces"
fixture_state="$test_tmp/services"
calls="$test_tmp/calls"
mkdir -p "$stub_bin"

cat >"$stub_bin/systemd-detect-virt" <<'SH'
#!/bin/bash
printf '%s\n' "${TEST_VIRTUALIZATION:-parallels}"
SH
cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ ${TEST_MISSING_TOOLS:-0} == "0" ]]
SH
cat >"$stub_bin/install" <<'SH'
#!/bin/bash
if [[ ${TEST_FILE_FAILURE:-} == "install" ]]; then
  if [[ ${TEST_EDIT_DURING_FAILURE:-0} == "1" ]]; then
    printf '[Desktop Entry]\nExec=my-edited-agent\n' >"$XDG_CONFIG_HOME/autostart/prlcc.desktop"
  fi
  exit 1
fi
if [[ -n ${TEST_INSTALL_GATE:-} ]]; then
  : >"$TEST_INSTALL_GATE/entered"
  IFS= read -r release <"$TEST_INSTALL_GATE/release"
fi
exec /usr/bin/install "$@"
SH
cat >"$stub_bin/mktemp" <<'SH'
#!/bin/bash
if [[ ${TEST_FILE_FAILURE:-} == "mktemp" && $* == *"/autostart/.prlcc."* ]]; then exit 1; fi
exec /usr/bin/mktemp "$@"
SH
cat >"$stub_bin/mv" <<'SH'
#!/bin/bash
if [[ ${TEST_FILE_FAILURE:-} == "mv" && ${!#} == "$XDG_CONFIG_HOME/autostart/prlcc.desktop" ]]; then exit 1; fi
exec /usr/bin/mv "$@"
SH
cat >"$stub_bin/flock" <<'SH'
#!/bin/bash
if [[ ${TEST_RACE_ACTOR:-} == "off" ]]; then
  : >"$TEST_RACE_GATE/off-lock-attempt"
fi
exec /usr/bin/flock "$@"
SH
cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_CALLS"
case "$*" in
  '--user is-active --quiet app-prlcc@autostart.service') [[ -f $TEST_SERVICES/stock ]] ;;
  '--user is-active --quiet omarchy-parallels.service') [[ -f $TEST_SERVICES/feature ]] ;;
  '--user stop app-prlcc@autostart.service') rm -f "$TEST_SERVICES/stock" ;;
  '--user start app-prlcc@autostart.service') touch "$TEST_SERVICES/stock" ;;
  '--user daemon-reload') exit 0 ;;
  '--user reset-failed '*) exit 0 ;;
  '--user link '*)
    [[ ${TEST_FAIL:-} != "link" ]] || exit 1
    shift 2
    for source in "$@"; do
      destination="$XDG_CONFIG_HOME/systemd/user/${source##*/}"
      [[ -L $destination ]] || ln -s "$source" "$destination"
    done
    ;;
  '--user enable --now omarchy-parallels.service')
    [[ ${TEST_FAIL:-} != "enable" ]] || exit 1
    if [[ ${TEST_FAIL:-} != "inactive" ]]; then
      touch "$TEST_SERVICES/feature"
    fi
    ;;
  '--user disable --now omarchy-parallels.service')
    if [[ ${TEST_RACE_ACTOR:-} == "off" ]]; then
      : >"$TEST_RACE_GATE/off-mutation"
    fi
    # Disabling can fail before a failed activation has linked any unit.
    [[ -f $TEST_SERVICES/feature ]] || exit 1
    rm -f "$TEST_SERVICES/feature"
    ;;
  *) echo "unexpected systemctl call: $*" >&2; exit 1 ;;
esac
SH
chmod +x "$stub_bin"/*

reset_fixture() {
  rm -rf "$fixture_home" "$fixture_state"
  mkdir -p "$fixture_home/config/autostart" "$fixture_state"
  : >"$calls"
  : >"$fixture_state/stock"
  printf '[Desktop Entry]\nExec=prlcc -v\n' >"$fixture_home/config/autostart/prlcc.desktop"
  cp "$fixture_home/config/autostart/prlcc.desktop" "$test_tmp/original.desktop"
}

run_setup() {
  HOME="$fixture_home" XDG_CONFIG_HOME="$fixture_home/config" XDG_STATE_HOME="$fixture_home/state" \
    OMARCHY_PATH="${TEST_OMARCHY_PATH:-$ROOT}" \
    DISPLAY="${TEST_DISPLAY-:0}" WAYLAND_DISPLAY=wayland-test HYPRLAND_INSTANCE_SIGNATURE=fixture \
    TEST_SERVICES="$fixture_state" TEST_CALLS="$calls" PATH="$stub_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-hyprland-parallels" "$@"
}

reset_fixture
if TEST_VIRTUALIZATION=qemu run_setup on >"$test_tmp/rejected.log" 2>&1; then
  fail "Parallels integration refuses other VMs"
fi
[[ ! -s $calls && ! -d $fixture_home/state ]] || fail "other hardware is unchanged"
pass "Parallels integration refuses other hardware before changing files or services"

reset_fixture
if TEST_MISSING_TOOLS=1 run_setup on >"$test_tmp/rejected.log" 2>&1; then
  fail "Parallels integration requires the optional Tools installation"
fi
if TEST_DISPLAY='' run_setup on >"$test_tmp/rejected.log" 2>&1; then
  fail "Parallels integration requires the graphical session"
fi
[[ ! -s $calls && ! -d $fixture_home/state ]] || fail "unavailable prerequisites are unchanged"
pass "missing Tools and graphical environment are rejected without side effects"

reset_fixture
run_setup on
run_setup on
run_setup off
cmp -s "$test_tmp/original.desktop" "$fixture_home/config/autostart/prlcc.desktop" || fail "original Tools autostart is restored"
[[ -f $fixture_state/stock && ! -f $fixture_state/feature ]] || fail "original Tools agent is restarted"
[[ ! -d $fixture_home/state/omarchy/parallels ]] || fail "restored autostart backup is retired"
pass "repeated activation preserves the original autostart and restores it on disable"

reset_fixture
symlink_target="$test_tmp/autostart-[target]*"
cp "$test_tmp/original.desktop" "$symlink_target"
rm "$fixture_home/config/autostart/prlcc.desktop"
ln -s "$symlink_target" "$fixture_home/config/autostart/prlcc.desktop"
run_setup on
cmp -s "$test_tmp/original.desktop" "$symlink_target" || fail "autostart symlink target is unchanged"
run_setup off
case $(readlink "$fixture_home/config/autostart/prlcc.desktop") in
  "$symlink_target") ;;
  *) fail "autostart symlink is restored" ;;
esac
pass "activation replaces a symlink without modifying its target"

for stage in link enable inactive; do
  reset_fixture
  if TEST_FAIL="$stage" run_setup on >"$test_tmp/failed-$stage.log" 2>&1; then
    fail "activation reports a failed $stage operation"
  fi
  cmp -s "$test_tmp/original.desktop" "$fixture_home/config/autostart/prlcc.desktop" || fail "failed $stage restores autostart"
  [[ -f $fixture_state/stock ]] || fail "failed $stage restarts the original agent"
done
pass "activation failures roll back even when the new service cannot be disabled"

for operation in mktemp install mv; do
  for original in present absent symlink dangling; do
    reset_fixture
    case $original in
      absent) rm "$fixture_home/config/autostart/prlcc.desktop" ;;
      symlink | dangling)
        rm "$fixture_home/config/autostart/prlcc.desktop"
        target="$test_tmp/original-$original"
        [[ $original == "dangling" ]] || cp "$test_tmp/original.desktop" "$target"
        ln -s "$target" "$fixture_home/config/autostart/prlcc.desktop"
        ;;
    esac
    if TEST_FILE_FAILURE="$operation" run_setup on >"$test_tmp/file-failure.log" 2>&1; then
      fail "initial $operation failure is reported"
    fi
    [[ ! -d $fixture_home/state/omarchy/parallels ]] || fail "initial $operation failure retires unfinished activation state"
    [[ -f $fixture_state/stock && ! -f $fixture_state/feature ]] || fail "file failure leaves services unchanged"
    run_setup on
    run_setup off
    if [[ $original == "absent" ]]; then
      [[ ! -e $fixture_home/config/autostart/prlcc.desktop ]] || fail "retry keeps original absence"
    elif [[ $original == "present" ]]; then
      cmp -s "$test_tmp/original.desktop" "$fixture_home/config/autostart/prlcc.desktop" || fail "retry preserves original bytes"
    else
      [[ -L $fixture_home/config/autostart/prlcc.desktop && $(readlink "$fixture_home/config/autostart/prlcc.desktop") == "$target" ]] || fail "retry preserves original symlink"
    fi
  done
done
pass "initial mktemp, install and rename failures preserve originals and allow retry"

reset_fixture
if TEST_FILE_FAILURE=install TEST_EDIT_DURING_FAILURE=1 run_setup on >"$test_tmp/edited-failure.log" 2>&1; then
  fail "failed installation with an external edit is reported"
fi
cp "$fixture_home/config/autostart/prlcc.desktop" "$test_tmp/edited-failure.desktop"
for action in on off; do
  if run_setup "$action" >"$test_tmp/edited-failure-$action.log" 2>&1; then fail "external edit blocks $action"; fi
done
cmp -s "$test_tmp/edited-failure.desktop" "$fixture_home/config/autostart/prlcc.desktop" || fail "external edit survives failed setup"
cmp -s "$test_tmp/original.desktop" "$fixture_home/state/omarchy/parallels/original-autostart" || fail "external edit keeps the original backup"
pass "an edit made during failed installation preserves the edited file and original backup"

reset_fixture
mkdir -p "$fixture_home/config/systemd/user"
printf '[Service]\nExecStart=my-custom-agent\n' >"$fixture_home/config/systemd/user/omarchy-parallels.service"
cp "$fixture_home/config/systemd/user/omarchy-parallels.service" "$test_tmp/custom-unit"
if run_setup on >"$test_tmp/custom-unit.log" 2>&1; then
  fail "activation refuses custom unit overrides"
fi
[[ ! -s $calls && ! -d $fixture_home/state/omarchy/parallels ]] || fail "custom unit leaves services and managed backup state unchanged"
cmp -s "$test_tmp/custom-unit" "$fixture_home/config/systemd/user/omarchy-parallels.service" || fail "custom unit contents are preserved"
pass "custom systemd units are preserved before activation"

reset_fixture
run_setup on
printf '[Desktop Entry]\nExec=my-custom-agent\n' >"$fixture_home/config/autostart/prlcc.desktop"
cp "$fixture_home/config/autostart/prlcc.desktop" "$test_tmp/edited.desktop"
if run_setup off >"$test_tmp/edited.log" 2>&1; then
  fail "edited autostart is reported instead of silently overwritten"
fi
cmp -s "$test_tmp/edited.desktop" "$fixture_home/config/autostart/prlcc.desktop" || fail "edited autostart is preserved"
cmp -s "$test_tmp/original.desktop" "$fixture_home/state/omarchy/parallels/original-autostart" || fail "original backup remains available"
pass "disabling preserves an autostart override edited after activation"

# Losing the managed override must not strand its saved original or unit links.
for original in present absent; do
  for action in on off; do
    reset_fixture
    if [[ $original == "absent" ]]; then
      rm "$fixture_home/config/autostart/prlcc.desktop"
    fi
    run_setup on
    rm "$fixture_home/config/autostart/prlcc.desktop"
    run_setup "$action"
    if [[ $action == "on" ]]; then
      run_setup off
    fi
    if [[ $original == "present" ]]; then
      cmp -s "$test_tmp/original.desktop" "$fixture_home/config/autostart/prlcc.desktop" || fail "missing override restores the original startup"
    else
      [[ ! -e $fixture_home/config/autostart/prlcc.desktop ]] || fail "missing override stays absent without an original"
    fi
    for unit in omarchy-parallels.service omarchy-parallels-agent.service omarchy-parallels-helper@.service; do
      [[ ! -L $fixture_home/config/systemd/user/$unit ]] || fail "missing override cleans up unit links"
    done
    [[ ! -d $fixture_home/state/omarchy/parallels && -f $fixture_state/stock && ! -f $fixture_state/feature ]] || fail "missing override finishes restoration"
  done
done
pass "missing managed autostart permits reactivation and full deactivation"

# A dangling symlink is still a user edit, not a missing override.
reset_fixture
run_setup on
rm "$fixture_home/config/autostart/prlcc.desktop"
ln -s "$test_tmp/missing-target" "$fixture_home/config/autostart/prlcc.desktop"
if run_setup off >"$test_tmp/dangling.log" 2>&1; then
  fail "dangling user override is reported"
fi
[[ -L $fixture_home/config/autostart/prlcc.desktop && -f $fixture_home/state/omarchy/parallels/original-autostart ]] || fail "dangling override and original backup are preserved"
pass "dangling user override is not mistaken for an absent file"

# Pause a real repeated activation at its filesystem boundary, then overlap
# deactivation. Pass-through flock exposes its wait point without replacing
# the real OS lock; the assertion is the user's restored startup file.
reset_fixture
run_setup on
python3 - "$ROOT" "$stub_bin" "$fixture_home" "$fixture_state" "$calls" "$test_tmp" <<'PY'
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

root, binaries, home, services, calls, directory = map(Path, sys.argv[1:])
gate = directory / "race"
gate.mkdir()
fifo = gate / "release"
os.mkfifo(fifo)
release_descriptor = os.open(fifo, os.O_RDWR | os.O_NONBLOCK)
environment = dict(os.environ, HOME=str(home), XDG_CONFIG_HOME=str(home / "config"),
  XDG_STATE_HOME=str(home / "state"), OMARCHY_PATH=str(root), DISPLAY=":0",
  WAYLAND_DISPLAY="wayland-test", HYPRLAND_INSTANCE_SIGNATURE="fixture",
  TEST_SERVICES=str(services), TEST_CALLS=str(calls), TEST_RACE_GATE=str(gate),
  PATH=f"{binaries}:{root}/bin:{os.environ['PATH']}")
command = [str(root / "bin/omarchy-hyprland-parallels")]
workers = []

def wait_for(predicate):
  deadline = time.monotonic() + 5
  while not predicate():
    assert time.monotonic() < deadline, "concurrent command did not reach its test barrier"
    time.sleep(0.01)

try:
  with (gate / "on.log").open("w") as on_log, (gate / "off.log").open("w") as off_log:
    activation = subprocess.Popen(command + ["on"], env=dict(environment,
      TEST_INSTALL_GATE=str(gate), TEST_RACE_ACTOR="on"), stdout=on_log,
      stderr=subprocess.STDOUT, start_new_session=True)
    workers.append(activation)
    wait_for(lambda: gate.joinpath("entered").exists())
    deactivation = subprocess.Popen(command + ["off"], env=dict(environment,
      TEST_RACE_ACTOR="off"), stdout=off_log, stderr=subprocess.STDOUT, start_new_session=True)
    workers.append(deactivation)
    wait_for(lambda: gate.joinpath("off-mutation").exists() or gate.joinpath("off-lock-attempt").exists())
    if gate.joinpath("off-mutation").exists():
      assert deactivation.wait(timeout=5) == 0
    os.write(release_descriptor, b"continue\n")
    assert activation.wait(timeout=5) == 0, (gate / "on.log").read_text()
    assert deactivation.wait(timeout=5) == 0, (gate / "off.log").read_text()
  original = directory.joinpath("original.desktop").read_bytes()
  restored = home.joinpath("config/autostart/prlcc.desktop").read_bytes()
  assert restored == original, "concurrent on/off lost the original Tools startup file"
  assert not services.joinpath("feature").exists(), "deactivation did not remain effective"
finally:
  os.close(release_descriptor)
  for worker in workers:
    if worker.poll() is None:
      os.killpg(worker.pid, signal.SIGKILL)
      worker.wait(timeout=5)
PY
pass "overlapping activation and deactivation preserve the original startup file"

# Package data can change while the user keeps an activation enabled. Neither
# replaying on nor turning it off should mistake that update for a user edit.
for action in on off; do
  reset_fixture
  package="$test_tmp/package-$action"
  mkdir -p "$package/default/systemd/user"
  cp -a "$ROOT/default/parallels" "$package/default/"
  for unit in omarchy-parallels.service omarchy-parallels-agent.service omarchy-parallels-helper@.service; do
    cp "$ROOT/default/systemd/user/$unit" "$package/default/systemd/user/"
  done
  TEST_OMARCHY_PATH="$package" run_setup on
  printf '\nComment=Updated packaged template\n' >>"$package/default/parallels/prlcc.desktop"
  TEST_OMARCHY_PATH="$package" run_setup "$action"
  if [[ $action == "on" ]]; then
    TEST_OMARCHY_PATH="$package" run_setup off
  fi
  cmp -s "$test_tmp/original.desktop" "$fixture_home/config/autostart/prlcc.desktop" || fail "package update preserves the original startup file"
done
pass "package template updates do not prevent replaying or disabling an activation"
