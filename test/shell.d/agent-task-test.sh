#!/bin/bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export HOME="$tmp/home" CAPTURE="$tmp/capture"
mkdir -p "$HOME/.config/omarchy/agents/tasks" "$tmp/bin"
export PATH="$tmp/bin:$PATH"
cat > "$tmp/bin/omarchy-agent" <<'MOCK'
#!/bin/bash
printf '%s\0' "$@" > "$CAPTURE"
exit "${AGENT_STATUS:-0}"
MOCK
chmod +x "$tmp/bin/omarchy-agent"
run() { bash "$ROOT/bin/omarchy-agent-task" "$@"; }
[[ -z $(run) ]] || fail 'empty task directory lists nothing'
printf '%s' 'Review changes; $(touch should-not-exist) `false`' > "$HOME/.config/omarchy/agents/tasks/review.md"
printf 'ignore' > "$HOME/.config/omarchy/agents/tasks/bad name.md"
[[ $(run) == review ]] || fail 'list valid task names'
run --inline review 'Keep spaces' $'and\nnewlines'
python3 - <<'PY'
import os
args=open(os.environ['CAPTURE'],'rb').read().split(b'\0')
assert args == [b'--inline',b'--prompt',b'Review changes; $(touch should-not-exist) `false`\n\nAdditional instructions:\nKeep spaces and\nnewlines',b''],args
PY
pass 'task text and extra instructions reach the harness literally'
for name in ../review missing --help; do
  rm -f "$CAPTURE"
  if run "$name" 2>/dev/null; then fail "reject $name"; fi
  [[ ! -e $CAPTURE ]] || fail 'invalid task launched agent'
done
printf ' \n\t' > "$HOME/.config/omarchy/agents/tasks/empty.md"
if run empty 2>/dev/null; then fail 'reject empty task'; fi
python3 -c 'import sys;sys.stdout.write("a"*32769)' > "$HOME/.config/omarchy/agents/tasks/large.md"
if run large 2>/dev/null; then fail 'reject oversized task'; fi
if AGENT_STATUS=7 run review; then fail 'propagate launch failure'; else [[ $? == 7 ]] || fail 'wrong launch status'; fi
pass 'invalid, missing, empty and oversized tasks do not launch; launch failures propagate'
