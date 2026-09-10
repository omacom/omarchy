"""Launch a NetClaw component with its OS-managed private dependencies."""

import json
import os
from pathlib import Path
import sys

config = json.loads(Path(__file__).with_suffix(".json").read_text())
for key, value in config.get("environment", {}).items():
    os.environ.setdefault(key, value)
os.execv(config["python"], [config["python"], *config["args"], *sys.argv[1:]])
