"""Run literal command arguments, then send an optional completion notification."""

import argparse
from pathlib import Path
import signal
import subprocess
import sys


def translate(command, *args):
  return subprocess.check_output([*command.split(), *args], text=True, timeout=2).strip()


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument("--title", help="notification title (defaults to the command outcome)")
  parser.add_argument("command", nargs=argparse.REMAINDER)
  args = parser.parse_args()
  command = args.command
  if command[:1] == ["--"]:
    command = command[1:]
  if not command:
    parser.error("a command is required")

  child = None
  interrupted = None

  def forward(signum, _frame):
    nonlocal interrupted
    interrupted = signum
    if child is not None:
      try:
        child.send_signal(signum)
      except ProcessLookupError:
        pass

  handlers = {sig: signal.signal(sig, forward) for sig in (signal.SIGINT, signal.SIGTERM)}
  try:
    try:
      # Keep the caller's streams and foreground process group. In particular,
      # don't background the command with stdin redirected to /dev/null.
      child = subprocess.Popen(command)
      if interrupted is not None:
        forward(interrupted, None)
      result = child.wait()
    except OSError as error:
      print(f"{command[0]}: {error.strerror}", file=sys.stderr)
      result = 127 if isinstance(error, FileNotFoundError) else 126
    finally:
      child = None
    status = 128 - result if result < 0 else result
    # User cancellation is not a completion alert. Notification/localization
    # failures must never turn a successful command into a failed wrapper.
    if interrupted is None and result not in (-signal.SIGINT, -signal.SIGTERM):
      try:
        title = args.title or translate("omarchy-i18n notification.commandSucceeded" if status == 0
                                        else "omarchy-i18n notification.commandFailed")
        body = translate("omarchy-i18n notification.commandResult", Path(command[0]).name, str(status))
        if interrupted is None:
          subprocess.run(["omarchy-notification-send", title, body], check=False, timeout=5)
      except (OSError, subprocess.CalledProcessError, subprocess.TimeoutExpired):
        pass
    return status
  finally:
    for sig, handler in handlers.items():
      signal.signal(sig, handler)


if __name__ == "__main__":
  raise SystemExit(main())
