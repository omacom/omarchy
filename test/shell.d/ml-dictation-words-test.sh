#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
export XDG_CONFIG_HOME="$test_tmp/config"
export XDG_STATE_HOME="$test_tmp/state"
export XDG_RUNTIME_DIR="$test_tmp/runtime"
mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$XDG_STATE_HOME" "$XDG_RUNTIME_DIR"

stub="$test_tmp/bin"
mkdir -p "$stub"
cat > "$stub/pw-record" <<'SH'
#!/bin/bash
touch "${@: -1}"
sleep 30
SH
cat > "$stub/whisper-cli" <<'SH'
#!/bin/bash
printf '%s\n' "$*" > "$WHISPER_ARGV"
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
cat > "$stub/ollama" <<'SH'
#!/bin/bash
exit 0
SH
cat > "$stub/xdg-terminal-exec" <<'SH'
#!/bin/bash
printf '%s\n' "$*" > "$CHAT_LOG"
SH
chmod +x "$stub/pw-record" "$stub/whisper-cli" "$stub/wtype" "$stub/ollama" "$stub/xdg-terminal-exec"

model="$test_tmp/model.bin"
printf 'model\n' > "$model"
"$ROOT/bin/omarchy-dictation-whisper-cli" model "$model" >/dev/null
"$ROOT/bin/omarchy-dictation-whisper-cli" language en >/dev/null
"$ROOT/bin/omarchy-dictation-whisper-cli" word Omarchy >/dev/null
"$ROOT/bin/omarchy-dictation-whisper-cli" word --app Alacritty kubectl >/dev/null
"$ROOT/bin/omarchy-dictation-whisper-cli" word --drop Omarchy >/dev/null

export WHISPER_ARGV="$test_tmp/whisper.argv"
export WHISPER_LOG="$test_tmp/whisper.log"
export PATH="$stub:$ROOT/bin:$PATH"
export OMARCHY_ML_APP_CLASS=Alacritty
unset OMARCHY_WHISPER_MODEL
"$ROOT/bin/omarchy-dictation-whisper-cli" start
"$ROOT/bin/omarchy-dictation-whisper-cli" stop
grep -q -- '-l en' "$WHISPER_ARGV" || fail "dictation uses the language you set" "$(cat "$WHISPER_ARGV")"
grep -q -- '--prompt kubectl' "$WHISPER_ARGV" || fail "the focused app adds its own words" "$(cat "$WHISPER_ARGV")"
if grep -q 'Omarchy' "$WHISPER_ARGV"; then
  fail "a dropped word is not sent to whisper" "$(cat "$WHISPER_ARGV")"
fi

export OMARCHY_ML_APP_CLASS=firefox
"$ROOT/bin/omarchy-dictation-whisper-cli" start
"$ROOT/bin/omarchy-dictation-whisper-cli" stop
if grep -q 'kubectl' "$WHISPER_ARGV"; then
  fail "another app does not inherit the words" "$(cat "$WHISPER_ARGV")"
fi

export CHAT_LOG="$test_tmp/chat.log"
"$ROOT/bin/omarchy-ml-chat" model qwen2.5 >/dev/null
"$ROOT/bin/omarchy-ml-chat"
grep -q 'ollama run qwen2.5' "$CHAT_LOG" || fail "chat opens the model you named" "$(cat "$CHAT_LOG")"
grep -Fq '"trigger.ml.chat-model"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "the menu can set the chat model"
grep -Fq '"setup.default.dictation.whisper-language"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "the menu can set the dictation language"
pass "dictation words and the chat model are yours to set"
