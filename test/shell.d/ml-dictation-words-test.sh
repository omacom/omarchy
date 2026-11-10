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
exec sleep 30
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


# A settings error must still stop the owned recording.
printf '{\n' > "$XDG_CONFIG_HOME/omarchy/ml/dictation.json"
rm -f "$WHISPER_ARGV" "$WHISPER_LOG"
"$ROOT/bin/omarchy-dictation-whisper-cli" start
recorder_pid=$(<"$XDG_RUNTIME_DIR/omarchy-whisper/record.pid")
stop_status=0
"$ROOT/bin/omarchy-dictation-whisper-cli" stop 2>"$test_tmp/settings.err" || stop_status=$?
for attempt in {1..20}; do
  kill -0 "$recorder_pid" 2>/dev/null || break
  sleep 0.05
done
if kill -0 "$recorder_pid" 2>/dev/null; then
  kill "$recorder_pid" 2>/dev/null || true
  fail "invalid settings leave the recorder running"
fi
(( stop_status != 0 )) || fail "invalid settings are reported"
[[ ! -e $XDG_RUNTIME_DIR/omarchy-whisper/record.pid && ! -e $WHISPER_ARGV && ! -e $WHISPER_LOG ]] ||
  fail "invalid settings clear the recorder without transcribing or typing"
grep -Fq "Cannot read dictation settings" "$test_tmp/settings.err" ||
  fail "dictation names the settings error" "$(cat "$test_tmp/settings.err")"
pass "dictation stops recording before reporting invalid settings"

export CHAT_LOG="$test_tmp/chat.log"
"$ROOT/bin/omarchy-ml-chat" model qwen2.5 >/dev/null
"$ROOT/bin/omarchy-ml-chat"
grep -q 'ollama run qwen2.5' "$CHAT_LOG" || fail "chat opens the model you named" "$(cat "$CHAT_LOG")"
grep -Fq '"trigger.ml.chat-model"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "the menu can set the chat model"
grep -Fq '"setup.default.dictation.whisper-language"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "the menu can set the dictation language"
pass "dictation words and the chat model are yours to set"
