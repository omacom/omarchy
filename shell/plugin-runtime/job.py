"""Owned foreground subprocesses shared by both plugin runtime backends."""
import base64
import ctypes
import json
import os
import selectors
import signal
import subprocess
import sys
import time

LIMIT = 2 * 1024 * 1024
child = None


class Outcome(Exception):
  def __init__(self, status, message):
    self.status = status
    super().__init__(message)


def stop_child():
  if child is not None:
    try:
      os.killpg(child.pid, signal.SIGKILL)
    except ProcessLookupError:
      pass
    child.wait()


def cancel(number, frame):
  # A signal can interrupt Popen.wait while its waitpid lock is held. Kill
  # here, then reap in run's finally after the interrupted frame unwinds.
  if child is not None:
    try:
      os.killpg(child.pid, signal.SIGKILL)
    except ProcessLookupError:
      pass
  raise SystemExit(128 + number)


def parent_lifetime(parent=None):
  if parent is None:
    parent = os.getppid()
  if ctypes.CDLL(None, use_errno=True).prctl(1, signal.SIGTERM, 0, 0, 0) != 0:
    raise OSError(ctypes.get_errno(), "Cannot attach plugin process lifetime")
  if parent == 1 or os.getppid() != parent:
    raise Outcome("unavailable", "Plugin caller has exited")


def run_child(argv, *, capture=True, local=False, environment=None):
  global child
  try:
    # Publish the child before delivering cancellation. These CLI helpers are
    # single-threaded; the child restores the caller's mask before exec.
    previous = signal.pthread_sigmask(signal.SIG_BLOCK, {signal.SIGTERM, signal.SIGINT, signal.SIGHUP})
    try:
      child = subprocess.Popen(argv, stdin=None if local else subprocess.DEVNULL,
        stdout=subprocess.PIPE if capture else None, stderr=subprocess.PIPE if capture else None,
        cwd=None if local else "/", env=environment, start_new_session=True,
        preexec_fn=lambda: signal.pthread_sigmask(signal.SIG_SETMASK, previous))
    finally:
      signal.pthread_sigmask(signal.SIG_SETMASK, previous)
    if not capture:
      code = child.wait()
      return {"exitCode": code} if code >= 0 else {"signal": -code}
    output = {"stdout": bytearray(), "stderr": bytearray()}
    with selectors.DefaultSelector() as poll:
      for name in output:
        stream = getattr(child, name)
        os.set_blocking(stream.fileno(), False)
        poll.register(stream, selectors.EVENT_READ, name)
      exited_at = None
      while poll.get_map():
        if child.poll() is not None:
          if exited_at is None:
            exited_at = time.monotonic()
            stop_child()
          elif time.monotonic() - exited_at > 1:
            raise Outcome("failed", "Command output remained open after exit")
        for key, _ in poll.select(0.1):
          chunk = os.read(key.fd, 65536)
          if not chunk:
            poll.unregister(key.fileobj)
          else:
            output[key.data].extend(chunk)
            if len(output[key.data]) > LIMIT:
              raise Outcome("failed", "Plugin command output exceeded 2 MiB")
    code = child.wait()
    return dict({"exitCode": code} if code >= 0 else {"signal": -code},
      stdout=bytes(output["stdout"]), stderr=bytes(output["stderr"]))
  finally:
    stop_child()
    child = None


def run(argv, *, capture=True, local=False, environment=None):
  # QProcess kills its direct child with SIGKILL on QObject destruction.
  # A separate guardian survives that uncatchable signal long enough to kill
  # and reap the owned process group. It is bound to this exact parent before
  # launching anything, including when destruction races with startup.
  reader, writer = os.pipe()
  parent = os.getpid()
  guardian = os.fork()
  if guardian == 0:
    os.close(reader)
    try:
      parent_lifetime(parent)
      try:
        value = run_child(argv, capture=capture, local=local, environment=environment)
        for name in ("stdout", "stderr"):
          if name in value:
            value[name] = base64.b64encode(value[name]).decode("ascii")
        reply = {"result": value}
      except (Outcome, OSError, ValueError) as error:
        reply = {"error": str(error), "status": error.status if isinstance(error, Outcome) else "failed"}
      with os.fdopen(writer, "w") as output:
        json.dump(reply, output)
    finally:
      os._exit(0)
  os.close(writer)
  try:
    with os.fdopen(reader) as source:
      reply = json.load(source)
    if "error" in reply:
      raise Outcome(reply["status"], reply["error"])
    result = reply["result"]
    for name in ("stdout", "stderr"):
      if name in result:
        result[name] = base64.b64decode(result[name])
    return result
  finally:
    try:
      os.kill(guardian, signal.SIGTERM)
    except ProcessLookupError:
      pass
    os.waitpid(guardian, 0)


def binary(value):
  if isinstance(value, bytes):
    try:
      return value.decode("utf-8")
    except UnicodeDecodeError:
      return {"base64": base64.b64encode(value).decode("ascii")}
  raise TypeError("Unknown output type")


def setup():
  for number in (signal.SIGTERM, signal.SIGINT, signal.SIGHUP):
    signal.signal(number, cancel)
  parent_lifetime()


def main():
  setup()
  try:
    if not sys.argv[1:]:
      raise Outcome("invalid", "A local command is required")
    result = run(sys.argv[1:], local=True)
    print(json.dumps(dict(version=1, status="completed", **result), default=binary))
    return 0
  except (Outcome, OSError, ValueError) as error:
    print(json.dumps(dict(version=1, status=error.status if isinstance(error, Outcome) else "failed")))
    return 1


if __name__ == "__main__":
  sys.exit(main())
