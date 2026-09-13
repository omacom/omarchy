#!/usr/bin/env python3
"""Hostile stream fixture for the offscreen guarded-process QML tests."""
import json
import os
import signal
import sys
import time


action = sys.argv[1] if len(sys.argv) > 1 else "normal"
if action == "stdout-flood":
  os.write(1, b"x" * (300 * 1024))
elif action == "stderr-flood":
  os.write(2, b"x" * (300 * 1024))
elif action == "hang":
  signal.signal(signal.SIGTERM, signal.SIG_IGN)
  while True:
    time.sleep(1)
elif action == "malformed":
  os.write(1, b"{not-json\n")
elif action == "slow":
  time.sleep(0.15)
  os.write(1, (json.dumps({"ok": True, "data": {"fixture": action}}) + "\n").encode())
else:
  os.write(1, (json.dumps({"ok": True, "data": {"fixture": action}}) + "\n").encode())
