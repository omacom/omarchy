#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command flock

python3 - <<'PY'
from pathlib import Path
import os
import signal
import subprocess
import tempfile
import time

root = Path(os.environ["ROOT"])
runner = root / "bin/omarchy-migrate"


def check(condition, description):
  if not condition:
    raise SystemExit("not ok - " + description)


def wait_for(predicate, description):
  deadline = time.monotonic() + 5
  while not predicate():
    check(time.monotonic() < deadline, description)
    time.sleep(0.02)


class Fixture:
  def __enter__(self):
    self.temp = tempfile.TemporaryDirectory(prefix="omarchy-migrate-lock-")
    self.path = Path(self.temp.name)
    self.source = self.path / "source"
    self.migrations = self.source / "migrations"
    self.state = self.path / "markers"
    self.events = self.path / "events"
    self.processes = []
    for directory in (self.migrations, self.path / "home", self.path / "runtime", self.path / "bin"):
      directory.mkdir(parents=True)
    notification = self.path / "bin/omarchy-notification-dismiss"
    notification.write_text("#!/bin/bash\nexit 0\n")
    notification.chmod(0o755)
    self.env = dict(os.environ, HOME=str(self.path / "home"), OMARCHY_PATH=str(self.source),
                    OMARCHY_MIGRATION_STATE=str(self.state), XDG_RUNTIME_DIR=str(self.path / "runtime"),
                    TEST_CASE=str(self.path), TEST_EVENTS=str(self.events),
                    PATH=f"{self.path / 'bin'}:{root / 'bin'}:{os.environ['PATH']}")
    self.env.pop("OMARCHY_UPDATE_LOCK_FD", None)
    (self.migrations / "100-first.sh").write_text('''printf '%s:100\\n' "$TEST_RUNNER" >>"$TEST_EVENTS"
if [[ $TEST_RUNNER == "first" ]]; then
  touch "$TEST_CASE/started"
  while [[ ! -f $TEST_CASE/release ]]; do sleep 0.02; done
  [[ ${TEST_FAIL_FIRST:-0} != "1" ]] || exit 17
fi
''')
    (self.migrations / "200-second.sh").write_text('printf "%s:200\\n" "$TEST_RUNNER" >>"$TEST_EVENTS"\n')
    return self

  def __exit__(self, *args):
    # Each runner has its own process group, including any fixture children it
    # leaves behind. A failed assertion must not strand a blocked migration.
    for process in self.processes:
      try:
        os.killpg(process.pid, signal.SIGKILL)
      except ProcessLookupError:
        pass
      process.wait()
    self.temp.cleanup()

  def start(self, name, update=False, **overrides):
    command = [str(runner)]
    if update:
      command = [str(root / "bin/omarchy-update-lock"), "run", *command]
    with (self.path / (name + ".out")).open("w") as output:
      process = subprocess.Popen(command, env=dict(self.env, TEST_RUNNER=name, **overrides),
                                 stdout=output, stderr=subprocess.STDOUT, start_new_session=True)
    self.processes.append(process)
    return process

  def output(self, name):
    return (self.path / (name + ".out")).read_text()

  def calls(self):
    return self.events.read_text().splitlines() if self.events.exists() else []

  def pending(self):
    return subprocess.run([str(runner), "--pending"], env=self.env, capture_output=True,
                          text=True, timeout=2)

  def started(self):
    wait_for(lambda: (self.path / "started").exists(), "first migration starts")

  def release(self):
    (self.path / "release").touch()


for first_update, second_update in ((False, False), (True, False), (False, True)):
  with Fixture() as fixture:
    pending = fixture.pending()
    check(pending.returncode == 0 and pending.stdout.splitlines() == ["100-first.sh", "200-second.sh"],
          "pending lists migrations before the state directory exists")
    check(not fixture.state.exists(), "pending does not create migration state or a lock")
    first = fixture.start("first", update=first_update)
    fixture.started()
    second = fixture.start("second", update=second_update)
    wait_for(lambda: "Waiting for another Omarchy migration run" in fixture.output("second")
             or "second:100" in fixture.calls(), "second runner reaches the migration queue")
    check(fixture.calls() == ["first:100"], "concurrent runners do not execute the same migration")
    check(second.poll() is None, "second runner waits for the active migration queue")
    pending = fixture.pending()
    check(pending.returncode == 0 and pending.stdout.splitlines() == ["100-first.sh", "200-second.sh"],
          "pending stays responsive while migrations hold the lock")
    fixture.release()
    check(first.wait(timeout=5) == 0, "first migration runner succeeds")
    check(second.wait(timeout=5) == 0, "waiting migration runner succeeds after release")
    check(fixture.calls() == ["first:100", "first:200"], "waiting runner rechecks completion markers")
    check(all((fixture.state / name).is_file() for name in ("100-first.sh", "200-second.sh")),
          "successful migrations receive completion markers")
    check(fixture.pending().returncode == 1, "all migrations are complete after both runners exit")
    print(f"ok - migration queue is serialized (first update={first_update}, second update={second_update})")

with Fixture() as fixture:
  touch = fixture.path / "bin/touch"
  touch.write_text('''#!/bin/bash
if [[ $1 == "$OMARCHY_MIGRATION_STATE/100-first.sh" ]]; then
  echo marking >"$TEST_CASE/marking"
  while [[ ! -f $TEST_CASE/release-marker ]]; do sleep 0.02; done
fi
exec /usr/bin/touch "$@"
''')
  touch.chmod(0o755)
  first = fixture.start("first")
  fixture.started()
  fixture.release()
  wait_for(lambda: (fixture.path / "marking").exists(), "runner reaches the completion marker write")
  second = fixture.start("second")
  wait_for(lambda: "Waiting for another Omarchy migration run" in fixture.output("second")
           or "second:100" in fixture.calls(), "second runner attempts migration before its marker is written")
  check(fixture.calls() == ["first:100"], "lock covers the interval between migration exit and marker write")
  check(not (fixture.state / "100-first.sh").exists(), "completion marker is still waiting to be written")
  (fixture.path / "release-marker").touch()
  check(first.wait(timeout=5) == 0 and second.wait(timeout=5) == 0, "both runners finish after marker publication")
  check(fixture.calls() == ["first:100", "first:200"], "marker publication prevents duplicate execution")
  print("ok - migration lock stays held through completion marker writes")

with Fixture() as fixture:
  first = fixture.start("first", TEST_FAIL_FIRST="1")
  fixture.started()
  fixture.release()
  check(first.wait(timeout=5) == 17, "failed migration preserves its failure status")
  check(not (fixture.state / "100-first.sh").exists(), "failed migration is not marked complete")
  check(not (fixture.state / "200-second.sh").exists(), "failure stops the remaining queue")
  retry = fixture.start("retry")
  check(retry.wait(timeout=5) == 0, "failed runner releases the lock for a retry")
  check(fixture.calls() == ["first:100", "retry:100", "retry:200"], "retry completes the failed migration and the queue")
  print("ok - failed migration releases its lock and remains retryable")

for termination_signal in (signal.SIGHUP, signal.SIGINT, signal.SIGTERM):
  with Fixture() as fixture:
    first = fixture.start("first")
    fixture.started()
    first.send_signal(termination_signal)
    second = fixture.start("second")
    wait_for(lambda: "Waiting for another Omarchy migration run" in fixture.output("second")
             or "second:100" in fixture.calls(), "second runner attempts the interrupted queue")
    check(fixture.calls() == ["first:100"], "runner-only termination cannot overlap an active migration")
    check(first.poll() is None, "interrupted runner holds its lock until the active migration exits")
    fixture.release()
    check(first.wait(timeout=5) == 128 + termination_signal, "runner preserves the termination status")
    check(second.wait(timeout=5) == 0, "waiting runner proceeds after the interrupted migration exits")
    check(fixture.calls() == ["first:100", "second:100", "second:200"],
          "interrupted migration remains retryable without concurrent execution")
    print(f"ok - runner-only {termination_signal.name} retains the lock until its migration exits")

with Fixture() as fixture:
  first = fixture.start("first")
  fixture.started()
  other = fixture.start("other", HOME=str(fixture.path / "other-home"),
                        OMARCHY_MIGRATION_STATE=str(fixture.path / "other-markers"))
  check(other.wait(timeout=5) == 0, "a different user's migration state is not blocked")
  check(first.poll() is None, "first user's migration is still running independently")
  fixture.release()
  check(first.wait(timeout=5) == 0, "first user finishes its own queue")
  print("ok - independent migration state directories do not contend")

with Fixture() as fixture:
  (fixture.migrations / "100-first.sh").write_text('sleep 30 &\necho $! >"$TEST_CASE/child"\n')
  first = fixture.start("first")
  check(first.wait(timeout=5) == 0, "runner finishes when a migration leaves a background child")
  child_pid = int((fixture.path / "child").read_text())
  os.kill(child_pid, 0)
  (fixture.migrations / "300-later.sh").write_text('echo later >>"$TEST_EVENTS"\n')
  second = fixture.start("second")
  check(second.wait(timeout=5) == 0, "a migration's background child cannot keep the lock held")
  check("later" in fixture.calls(), "a new pending migration runs while the background child lives")
  print("ok - migration children do not inherit the migration lock")
PY
