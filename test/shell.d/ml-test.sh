#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
export XDG_CONFIG_HOME="$test_tmp/config"
export XDG_STATE_HOME="$test_tmp/state"
export XDG_RUNTIME_DIR="$test_tmp/runtime"
export OMARCHY_PATH="$ROOT"
mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$XDG_STATE_HOME" "$XDG_RUNTIME_DIR"

intent() {
  "$ROOT/bin/omarchy-ml-intent" --print "$@"
}

[[ $(intent "dim the laptop screen") == "omarchy-brightness-display 20%-" ]] ||
  fail "asking to dim the laptop screen lowers the brightness"
[[ $(intent "shot the left monitor") == "omarchy-capture-screenshot" ]] ||
  fail "asking for a shot runs the screenshot command"
[[ $(intent "clipboard history") == "omarchy-shell shell summon omarchy.clipboard" ]] ||
  fail "a sentence can land on the clipboard history action"

notes="$HOME/Notes"
mkdir -p "$notes"
note="$notes/yesterday.txt"
printf 'ship the patch\n' > "$note"
OMARCHY_ML_TODAY="2026-10-19" python3 - "$note" <<'PY'
import datetime, os, sys
yesterday = datetime.date.fromisoformat("2026-10-19") - datetime.timedelta(days=1)
stamp = datetime.datetime.combine(yesterday, datetime.time(15, 0)).timestamp()
os.utime(sys.argv[1], (stamp, stamp))
PY
quoted=$(OMARCHY_ML_NOTES="$notes" OMARCHY_ML_TODAY="2026-10-19" intent "open yesterday's notes")
[[ $quoted == "xdg-open $note" ]] || fail "yesterday's note opens that file" "$quoted"
pass "intent launcher maps sentences onto commands that already exist"

notify_dir="$test_tmp/notifications"
mkdir -p "$notify_dir"
write_note() {
  local name=$1 app=$2 summary=$3 body=$4
  python3 - "$notify_dir/$name.json" "$app" "$summary" "$body" <<'PY'
import json, sys
path, app, summary, body = sys.argv[1:]
with open(path, "w", encoding="utf-8") as handle:
    json.dump({"app": app, "summary": summary, "body": body}, handle)
PY
}
write_note ci-1 GitHub "build failed" "main"
write_note ci-2 GitHub "build failed" "api"
write_note ci-3 GitHub "pipeline failed" "web"
for n in $(seq 1 12); do
  write_note "chat-$n" Slack "new message" "#ops"
done
write_note reminder Omarchy "stand up" ""

digest=$("$ROOT/bin/omarchy-ml-notify-fold" "$notify_dir")
[[ $digest == "3 failed builds, 12 messages from #ops" ]] ||
  fail "notifications fold into one line" "$digest"

node_digest=$(node -e '
const fold = require(process.argv[1])
const rows = []
rows.push({app:"GitHub", summary:"build failed", body:"main"})
rows.push({app:"GitHub", summary:"build failed", body:"api"})
rows.push({app:"GitHub", summary:"pipeline failed", body:"web"})
for (let i = 0; i < 12; i++) rows.push({app:"Slack", summary:"new message", body:"#ops"})
rows.push({app:"Omarchy", summary:"stand up", body:"", ts: 4, key: "reminder"})
const folded = fold.fold(rows)
if (folded[0].summary !== "3 failed builds, 12 messages from #ops") process.exit(1)
if (folded[0].key !== "ml-fold") process.exit(3)
if (folded.length !== 2 || folded[1].summary !== "stand up") process.exit(2)
if (folded[1].ts !== 4) process.exit(4)
' "$ROOT/shell/plugins/notifications/NotificationFold.js") ||
  fail "history replay keeps the reminder and folds the rest"
pass "notification fold collapses CI and chat"

shot_dir="$test_tmp/shots"
mkdir -p "$shot_dir"
export OMARCHY_ML_SHOT_INDEX="$test_tmp/shots.jsonl"
red="$shot_dir/red.png"
python3 - "$red" <<'PY'
import struct, sys, zlib
def chunk(kind, data):
    return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)
ihdr = struct.pack(">IIBBBBB", 1, 1, 8, 2, 0, 0, 0)
raw = zlib.compress(b"\x00\xff\x00\x00")
png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", raw) + chunk(b"IEND", b"")
open(sys.argv[1], "wb").write(png)
PY
"$ROOT/bin/omarchy-ml-shot" index --path "$red" --text "segfault red error dialog" --mtime "$(python3 -c 'import datetime; print(datetime.datetime(2026,10,13,12,0).timestamp())')" >/dev/null
"$ROOT/bin/omarchy-ml-shot" index --path "$shot_dir/blue.png" --text "calendar" --colors blue --mtime "$(python3 -c 'import datetime; print(datetime.datetime(2026,10,14,12,0).timestamp())')" >/dev/null
found=$("$ROOT/bin/omarchy-ml-shot" search "red")
[[ $found == "$red" ]] || fail "a red png is found from its pixels" "$found"
found=$("$ROOT/bin/omarchy-ml-shot" search "that red error from Tuesday")
[[ $found == "$red" ]] || fail "screenshot search finds the red Tuesday capture" "$found"
pass "screenshot search matches color, words, and weekday"

clients="$test_tmp/clients.json"
cat > "$clients" <<'EOF'
[
  {"class": "Alacritty", "workspace": {"id": 1}, "address": "0x1"},
  {"class": "firefox", "workspace": {"id": 1}, "address": "0x2"},
  {"class": "code", "workspace": {"id": 1}, "address": "0x3"}
]
EOF
OMARCHY_ML_CLIENTS="$clients" "$ROOT/bin/omarchy-ml-workspace" record
OMARCHY_ML_CLIENTS="$clients" "$ROOT/bin/omarchy-ml-workspace" record
cat > "$clients" <<'EOF'
[{"class": "Alacritty", "workspace": {"id": 2}, "address": "0x9"}]
EOF
OMARCHY_ML_CLIENTS="$clients" "$ROOT/bin/omarchy-ml-workspace" record
suggestion=$(OMARCHY_ML_CLIENTS="$clients" "$ROOT/bin/omarchy-ml-workspace" suggest)
[[ $suggestion == $'1\tAlacritty,firefox,code' ]] ||
  fail "the usual window set wins" "$suggestion"
restore=$("$ROOT/bin/omarchy-ml-workspace" restore --print)
grep -Fq "omarchy-launch-or-focus firefox firefox" <<<"$restore" ||
  fail "restore prints a launch for each app" "$restore"
train=$("$ROOT/bin/omarchy-ml-workspace" train --print)
grep -Fq "workspace 9" <<<"$train" ||
  fail "training workspace opens the notebook on workspace 9" "$train"
grep -Fq "http://127.0.0.1:8888" <<<"$train" ||
  fail "training workspace opens the notebook" "$train"
grep -Eq "btop|nvtop" <<<"$train" ||
  fail "training workspace opens a gpu monitor" "$train"
cat > "$clients" <<'EOF'
[{"class": "Alacritty", "workspace": {"id": 9}, "address": "0xabc"}]
EOF
park=$(OMARCHY_ML_CLIENTS="$clients" "$ROOT/bin/omarchy-ml-workspace" park --print)
[[ $park == *"special:mltrain,address:0xabc"* ]] ||
  fail "parking moves the training windows off the current workspace" "$park"
pass "workspace restore learns the sets you reopen"

[[ $(OMARCHY_ML_GPU_STATUS="86% 14/24G 71°" "$ROOT/bin/omarchy-ml-gpu-status") == "86% 14/24G 71°" ]] ||
  fail "gpu status prints the bar line"
if OMARCHY_ML_GPU_STATUS="" "$ROOT/bin/omarchy-ml-gpu-status" >/dev/null 2>&1; then
  fail "gpu status stays quiet when no card answers"
fi
pass "gpu status is one line for the bar"

index_line=$(OMARCHY_ML_GPU=nvidia "$ROOT/bin/omarchy-install-ml-pytorch" --print-index | head -n 1)
[[ $index_line == "https://download.pytorch.org/whl/cu132" ]] ||
  fail "pytorch names the cuda wheel index" "$index_line"
[[ $(OMARCHY_ML_GPU=rocm "$ROOT/bin/omarchy-install-ml-pytorch" --print-index | head -n 1) == "https://download.pytorch.org/whl/rocm7.1" ]] ||
  fail "pytorch names the rocm wheel index"
[[ $(OMARCHY_ML_GPU=cpu "$ROOT/bin/omarchy-install-ml-pytorch" --print-index | head -n 1) == "https://download.pytorch.org/whl/cpu" ]] ||
  fail "pytorch names the cpu wheel index"
pass "pytorch tells you which wheel index it will use"

plan=$("$ROOT/bin/omarchy-install-ml-gpu" --print-plan nvidia)
[[ $plan == *"cuda"* && $plan == *"nvidia-container-toolkit"* && $plan == *"check nvidia-smi"* ]] ||
  fail "nvidia install names the toolkit and the check" "$plan"
rocm_plan=$("$ROOT/bin/omarchy-install-ml-gpu" --print-plan rocm)
[[ $rocm_plan == *"hip-runtime-amd"* && $rocm_plan == *"rocm-smi-lib"* && $rocm_plan == *"check rocm-smi"* ]] ||
  fail "rocm install names the userland and the check" "$rocm_plan"
pass "gpu install refuses to claim success before the card answers"

"$ROOT/bin/omarchy-ml-models" >/dev/null
[[ -d $HOME/models ]] || fail "models directory is created"
mkdir -p "$HOME/.cache/huggingface"
if "$ROOT/bin/omarchy-ml-models" --link >"$test_tmp/link.err" 2>&1; then
  fail "linking refuses to hide a cache that already has a directory"
fi
grep -q "mv $HOME/.cache/huggingface" "$test_tmp/link.err" ||
  fail "the refusal tells you how to move the cache"
[[ -L $HOME/.ollama/models ]] || fail "an empty ollama cache becomes a link into models"
pass "models stay out of the root disk when you ask"

export OMARCHY_ML_DATA_ROOT="$test_tmp/missing-data"
if "$ROOT/bin/omarchy-ml-data-disk" --print >"$test_tmp/data-missing" 2>&1; then
  fail "a missing dataset disk is not treated as ready"
fi
grep -q "HF_HOME=$test_tmp/missing-data/huggingface" "$test_tmp/data-missing" ||
  fail "the dataset plan names the cache paths"
grep -q "Mount a second drive" "$test_tmp/data-missing" ||
  fail "the dataset plan says how to mount the drive"
export OMARCHY_ML_DATA_ROOT="$test_tmp/data"
mkdir -p "$OMARCHY_ML_DATA_ROOT"
"$ROOT/bin/omarchy-ml-data-disk" >/dev/null
grep -q "OLLAMA_MODELS=$test_tmp/data/models/ollama" "$XDG_CONFIG_HOME/environment.d/omarchy-ml-data.conf" ||
  fail "dataset caches are written for the next login"
pass "dataset disk layout points caches at the second drive"

[[ $(OMARCHY_ML_GPU_BUSY=1 "$ROOT/bin/omarchy-ml-long-job" once) == inhibit ]] ||
  fail "a running gpu job asks to stay awake"
[[ $(OMARCHY_ML_GPU_BUSY=0 "$ROOT/bin/omarchy-ml-long-job" once) == idle ]] ||
  fail "an idle gpu does not hold the lid"
"$ROOT/bin/omarchy-ml-long-job" limits >/dev/null
grep -q "DefaultLimitNOFILE=1048576" "$XDG_CONFIG_HOME/systemd/user.conf.d/omarchy-ml.conf" ||
  fail "long jobs raise the open file limit"
pass "long jobs hold sleep only while the gpu is busy"

stub="$test_tmp/bin"
mkdir -p "$stub"
cat > "$stub/pw-record" <<'SH'
#!/bin/bash
touch "${@: -1}"
sleep 30
SH
cat > "$stub/whisper-cli" <<'SH'
#!/bin/bash
wav=""
prev=""
for arg in "$@"; do
  if [[ $prev == "-f" ]]; then
    wav=$arg
  fi
  prev=$arg
done
printf 'hello from whisper\n' > "$wav.txt"
SH
cat > "$stub/wtype" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >> "$WHISPER_LOG"
SH
chmod +x "$stub/pw-record" "$stub/whisper-cli" "$stub/wtype"
export WHISPER_LOG="$test_tmp/whisper.log"
export OMARCHY_WHISPER_MODEL="$test_tmp/model.bin"
printf 'model\n' > "$OMARCHY_WHISPER_MODEL"
PATH="$stub:$PATH" "$ROOT/bin/omarchy-dictation-whisper-cli" start
PATH="$stub:$PATH" "$ROOT/bin/omarchy-dictation-whisper-cli" stop
[[ $(<"$WHISPER_LOG") == "-- hello from whisper" ]] ||
  fail "whisper.cpp types the transcript into the focused window" "$(cat "$WHISPER_LOG" 2>/dev/null)"
pass "hold-to-talk types what whisper.cpp heard"

[[ $("$ROOT/bin/omarchy-launch-jupyter" --print) == "http://127.0.0.1:8888/lab" ]] ||
  fail "jupyter stays on localhost"
note_line=$(grep -F 'omarchy-notification-send' "$ROOT/bin/omarchy-launch-jupyter")
[[ $note_line != *'$url'* && $note_line != *token* ]] ||
  fail "jupyter notification leaves the token out" "$note_line"
grep -Fq 'chmod 600 "$state/jupyter.url"' "$ROOT/bin/omarchy-launch-jupyter" ||
  fail "jupyter url file is owner-only"
grep -q 'SUPER + ALT + A' "$ROOT/default/hypr/bindings/ml.lua" ||
  fail "the intent launcher has a key"
grep -q 'omarchy-ml-notify-fold --notify' "$ROOT/default/hypr/bindings/ml.lua" ||
  fail "notification fold has a key"
grep -Fq '"trigger.ml.intent"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "the menu can run an action by asking"
grep -Fq '"install.ml.gpu"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "the menu can install a gpu stack"
grep -Fq 'NotificationFold.fold' "$ROOT/shell/plugins/notifications/Service.qml" ||
  fail "notification history uses the fold"
pass "menu, keys, and history are wired up"
