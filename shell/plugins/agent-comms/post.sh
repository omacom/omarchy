#!/bin/bash
# Append one agent comm so the bar ticker picks it up.
#   post.sh agent "build finished"         # the agent said this
#   post.sh --in agent "check the ticker"  # this was said to the agent
set -euo pipefail

role="out"
if [[ ${1-} == "--in" ]]; then
  role="in"
  shift
fi

if (( $# < 2 )); then
  echo "usage: post.sh [--in] <agent> <text>" >&2
  exit 2
fi

agent="$1"
shift
text="$*"

dir="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/agent-comms"
mkdir -p "$dir"
AGENT="$agent" ROLE="$role" TEXT="$text" python3 - "$dir/inbox.jsonl" <<'PY'
import json
import os
import sys
import time

path = sys.argv[1]
record = {
  "ts": time.time(),
  "agent": os.environ["AGENT"],
  "role": os.environ["ROLE"],
  "text": os.environ["TEXT"],
}
with open(path, "a", encoding="utf-8") as handle:
  handle.write(json.dumps(record, ensure_ascii=False) + "\n")
PY
