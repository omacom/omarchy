"""Portable operation backend for explicitly trusted, in-process plugins.

This is not a sandbox or a second Ward policy engine. Host-owned installation
mode authorizes this path. Sandbox-native plugins always use the Ward worker.
An isolated plugin never falls back here when a broker is missing or denies it.
"""
import json
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys
import tempfile
import urllib.parse

ROOT_NAMES = ("HOME", "XDG_CONFIG_HOME", "XDG_DATA_HOME", "XDG_STATE_HOME", "XDG_CACHE_HOME", "XDG_RUNTIME_DIR", "PATH")


sys.path.insert(0, str(Path(os.environ["OMARCHY_PATH"]) / "shell/plugin-runtime"))
from job import Outcome, binary, run, setup


def restore_host_environment():
  # Only our local-process adapter sets these. They are convenience context,
  # never proof of trust: installation provenance is checked independently.
  if "OMARCHY_PLUGIN_HOST_HOME" in os.environ:
    for name in ROOT_NAMES:
      value = os.environ.pop("OMARCHY_PLUGIN_HOST_" + name, "")
      if value:
        os.environ[name] = value
      else:
        os.environ.pop(name, None)


def read_json(command):
  try:
    result = subprocess.run(command, capture_output=True, check=True, timeout=10)
    return json.loads(result.stdout)
  except (OSError, ValueError, subprocess.SubprocessError) as error:
    raise Outcome("unavailable", "Plugin installation state is unavailable") from error


def context(identity):
  if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]{0,95}", identity) or ".." in identity:
    raise Outcome("invalid", "Invalid plugin identity")
  records = read_json(["omarchy-plugin-installation", "list"])
  record = next((record for record in records if record.get("id") == identity), None)
  if not record or record.get("mode") not in ("yolo", "trusted-local") or record.get("error"):
    raise Outcome("denied", "This operation requires an explicitly trusted installation")
  if identity in read_json(["omarchy-plugin-isolation", "retained"]):
    raise Outcome("denied", "Retained Ward identity cannot use the trusted runtime")
  bundle = Path.home() / ".config/omarchy/plugins" / identity
  try:
    manifest = json.loads((bundle / "manifest.json").read_text())
    if manifest.get("id") != identity:
      raise ValueError("identity changed")
    if "sandbox" in manifest:
      raise Outcome("denied", "Sandbox-native plugins require a Ward worker")
  except (OSError, ValueError, AttributeError) as error:
    raise Outcome("unavailable", "Plugin manifest is unavailable") from error
  data = Path(os.environ.get("XDG_STATE_HOME", str(Path.home() / ".local/state"))) / "omarchy/plugins" / identity
  runtime_root = os.environ.get("XDG_RUNTIME_DIR", "")
  if not data.is_absolute() or not runtime_root.startswith("/"):
    raise Outcome("unavailable", "Plugin state and session runtime require absolute paths")
  runtime = Path(runtime_root) / "omarchy/plugins" / identity
  return bundle, data, runtime


def trusted_grants():
  result = {name: True for name in ("storage", "network", "notifications",
    "audioPlayback", "microphone", "audioCapture", "desktopGeometry", "openUrls")}
  result.update(networkProxy=False, filesystem={}, http={}, exec={},
    settings={"read": [], "write": []}, media=None)
  return result


def local_environment(identity, bundle, data, runtime):
  environment = dict(os.environ)
  for name in ROOT_NAMES:
    environment["OMARCHY_PLUGIN_HOST_" + name] = environment.get(name, "")
  for directory in (data, data / ".config", data / ".cache", data / ".local/share", data / ".local/state", runtime):
    directory.mkdir(mode=0o700, parents=True, exist_ok=True)
  environment.update(HOME=str(data), XDG_CONFIG_HOME=str(data / ".config"), XDG_CACHE_HOME=str(data / ".cache"),
    XDG_DATA_HOME=str(data / ".local/share"), XDG_STATE_HOME=str(data / ".local/state"), XDG_RUNTIME_DIR=str(runtime),
    OMARCHY_PLUGIN_ID=identity, OMARCHY_PLUGIN_PATH=str(bundle), OMARCHY_PLUGIN_DATA=str(data))
  return environment


def valid_url(value, limit):
  if not isinstance(value, str) or len(value.encode()) > limit or any(c.isspace() or ord(c) < 32 or c == "\\" for c in value):
    return False
  parsed = urllib.parse.urlsplit(value)
  return parsed.scheme in ("http", "https") and bool(parsed.hostname) and not parsed.username and not parsed.password


def execute(identity, args, structured):
  bundle, data, runtime = context(identity)
  operation, *values = args
  if operation == "--grants" and not values and not structured:
    print(json.dumps(trusted_grants()))
    return None
  if operation == "--local" and values:
    environment = local_environment(identity, bundle, data, runtime)
    with tempfile.TemporaryDirectory(prefix="links-", dir=runtime) as directory:
      prefix = [str(Path(os.environ["OMARCHY_PATH"]) / "bin/omarchy-plugin-runtime"), identity]
      for mode in ("browser", "webapp"):
        path = Path(directory) / ("omarchy-launch-" + mode)
        path.write_text("#!/bin/bash\nexec " + shlex.join(prefix + ["--open-url", mode]) + ' "$@"\n')
        path.chmod(0o700)
      environment["PATH"] = directory + ":" + str(Path(os.environ["OMARCHY_PATH"]) / "bin") + ":" + environment["PATH"]
      return run(values, capture=structured, local=True, environment=environment)
  if operation in ("--exec", "--http"):
    raise Outcome("invalid", "Named resources require a sandbox declaration and Ward worker")
  if operation == "--notify" and len(values) == 2:
    title, body = values
    if not 1 <= len(title.encode()) <= 160 or len(body.encode()) > 2048 or any(ord(c) < 32 and c not in "\n\t" for c in title + body):
      raise Outcome("invalid", "Invalid notification text")
    result = run(["omarchy-notification-send", "--app-name", "Plugin " + identity, "--", title, body])
  elif operation == "--open-url" and len(values) == 2 and values[0] in ("browser", "webapp") and valid_url(values[1], 2048):
    result = run(["omarchy-launch-" + values[0], values[1]])
  elif operation == "--settings" and len(values) == 1:
    value = json.loads(values[0])
    if len(values[0].encode()) > 65536 or not isinstance(value, dict) or set(value) & {"id", "sandbox", "sandboxPresentation", "__proto__", "constructor", "prototype"}:
      raise Outcome("invalid", "Invalid plugin settings")
    result = run(["omarchy-shell", "shell", "saveTrustedPluginSettings", identity, values[0]])
    if result.get("stdout", b"").strip() != b"ok":
      raise Outcome("failed", "Plugin settings were not saved")
  elif operation in ("--audio-playback", "--microphone", "--audio-capture") and not values and not structured:
    playback = operation == "--audio-playback"
    properties = {"application.name": "Plugin " + identity, "stream.capture.sink": operation == "--audio-capture",
      "node.stream.restore-props": False}
    result = run(["pw-cat", "--playback" if playback else "--record", "--raw", "--format=s16", "--rate=48000",
      "--channels=2", "--channel-map=stereo", "--latency=100ms", "--target=auto", "--properties", json.dumps(properties), "-"], capture=False, local=playback)
    if not playback:
      raise Outcome("unavailable", "Audio capture ended unexpectedly")
    return result
  else:
    raise Outcome("invalid", "Unknown or malformed plugin operation")
  if result.get("exitCode") != 0:
    raise Outcome("failed", "Plugin operation failed")
  return {}


def main():
  args = sys.argv[1:]
  identity = args.pop(0) if args else ""
  structured = bool(args and args[0] == "--json")
  if structured:
    args.pop(0)
  try:
    restore_host_environment()
    # Clear process-local resource tokens before invoking host commands. A
    # command receives the desktop environment, not the plugin's private HOME.
    for name in ("OMARCHY_PLUGIN_ID", "OMARCHY_PLUGIN_PATH", "OMARCHY_PLUGIN_DATA"):
      os.environ.pop(name, None)
    setup()
    if not args:
      raise Outcome("invalid", "A plugin operation is required")
    result = execute(identity, args, structured)
    if result is None:
      return 0
    if structured:
      print(json.dumps(dict(version=1, status="completed", **result), default=binary))
      return 0
    for name in ("stdout", "stderr"):
      if name in result:
        getattr(sys, name).buffer.write(result[name])
    if "body" in result:
      sys.stdout.buffer.write(result["body"])
      return int(result["httpStatus"] >= 400)
    return result.get("exitCode", 128 + result["signal"] if "signal" in result else 0)
  except (Outcome, OSError, ValueError, KeyError, TypeError, AttributeError, RecursionError) as error:
    status = error.status if isinstance(error, Outcome) else "timed_out" if isinstance(error, TimeoutError) else "invalid" if isinstance(error, json.JSONDecodeError) else "failed"
    if structured:
      print(json.dumps(dict(version=1, status=status)))
    else:
      print(f"omarchy-plugin-runtime: {error}", file=sys.stderr)
    return 1


if __name__ == "__main__":
  sys.exit(main())
