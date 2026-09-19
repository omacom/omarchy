#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

recovery="$ROOT/bin/omarchy-hw-recover-amd-soundwire"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
state_file="$tmpdir/profile"
command_log="$tmpdir/commands"
message_log="$tmpdir/messages"
mkdir -p "$mock_bin"

cat >"$mock_bin/sleep" <<'SH'
#!/bin/bash
true
SH

cat >"$mock_bin/logger" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$MESSAGE_LOG"
SH

cat >"$mock_bin/pw-dump" <<'SH'
#!/bin/bash

if [[ ${NO_DEVICE:-0} == 1 ]]; then
  echo '[]'
  exit 0
fi

profile=$(<"$STATE_FILE")
if [[ $profile == 0 ]]; then
  nodes=''
else
  nodes=',
    {"id":60,"type":"PipeWire:Interface:Node","info":{"props":{"device.id":59,"media.class":"Audio/Sink"}}},
    {"id":62,"type":"PipeWire:Interface:Node","info":{"props":{"device.id":59,"media.class":"Audio/Source"}}}'
fi

printf '[
  {"id":59,"type":"PipeWire:Interface:Device","info":{"props":{"alsa.card_name":"amd-soundwire","alsa.driver_name":"snd_acp_sdw_legacy_mach"},"params":{"Profile":[{"index":%s}]}}}%s
]\n' "$profile" "$nodes"
SH

cat >"$mock_bin/pw-cli" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$COMMAND_LOG"
profile=$(sed -n 's/.*index: \([0-9][0-9]*\).*/\1/p' <<<"$*")
if [[ ${FAIL_RESTORE:-0} == 1 && $profile != 0 ]]; then
  exit 1
fi
printf '%s\n' "$profile" >"$STATE_FILE"
SH

cat >"$mock_bin/flock" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$COMMAND_LOG"
SH

chmod +x "$mock_bin"/*

run_recovery() {
  PATH="$mock_bin:$PATH" \
    STATE_FILE="$state_file" \
    COMMAND_LOG="$command_log" \
    MESSAGE_LOG="$message_log" \
    OMARCHY_AUDIO_RECOVERY_SETTLE_SECONDS=0 \
    OMARCHY_AUDIO_RECOVERY_DEVICE_ATTEMPTS=2 \
    OMARCHY_AUDIO_RECOVERY_DEVICE_RETRY_SECONDS=0 \
    OMARCHY_AUDIO_RECOVERY_RESET_SECONDS=0 \
    OMARCHY_AUDIO_RECOVERY_VERIFY_ATTEMPTS=2 \
    OMARCHY_AUDIO_RECOVERY_VERIFY_RETRY_SECONDS=0 \
    "$@" "$recovery" --recover
}

printf '1\n' >"$state_file"
run_recovery env

[[ $(<"$state_file") == 1 ]] || fail "SoundWire recovery restores the active profile"
[[ $(sed -n '1p' "$command_log") == *'{ index: 0, save: false }' ]] ||
  fail "SoundWire recovery closes only the selected device"
[[ $(sed -n '2p' "$command_log") == *'{ index: 1, save: false }' ]] ||
  fail "SoundWire recovery restores the profile without persisting it"
[[ $(wc -l <"$command_log") == 2 ]] || fail "SoundWire recovery performs one bounded reset when it succeeds"
pass "SoundWire recovery resets only the affected device profile"

: >"$command_log"
: >"$message_log"
printf '1\n' >"$state_file"
run_recovery env NO_DEVICE=1

[[ ! -s $command_log ]] || fail "missing SoundWire hardware must not change another audio device"
grep -F 'left audio services untouched' "$message_log" >/dev/null ||
  fail "missing SoundWire hardware is reported as a safe no-op"
pass "SoundWire recovery leaves unrelated audio hardware untouched"

: >"$command_log"
: >"$message_log"
printf '0\n' >"$state_file"
run_recovery env

[[ ! -s $command_log ]] || fail "an intentionally disabled SoundWire profile must stay disabled"
grep -F 'already off' "$message_log" >/dev/null || fail "disabled SoundWire state is explained"
pass "SoundWire recovery preserves an intentionally disabled profile"

: >"$command_log"
: >"$message_log"
printf '1\n' >"$state_file"
if run_recovery env FAIL_RESTORE=1; then
  fail "an unrestorable SoundWire profile must report failure"
fi

[[ $(grep -c 'index: 0' "$command_log") == 2 ]] || fail "failed recovery retries only once"
[[ $(grep -c 'index: 1' "$command_log") == 3 ]] || fail "failed recovery makes a final best-effort restore"
grep -F 'left PipeWire and other audio devices untouched' "$message_log" >/dev/null ||
  fail "failed recovery documents its containment boundary"
pass "SoundWire recovery fails without restarting the audio stack"

: >"$command_log"
printf '%s\n' \
  '/org/freedesktop/login1: org.freedesktop.login1.Manager.PrepareForSleep (true,)' \
  '/org/freedesktop/login1: org.freedesktop.login1.Manager.PrepareForSleep (false,)' |
  PATH="$mock_bin:$PATH" \
  COMMAND_LOG="$command_log" \
  OMARCHY_AUDIO_RECOVERY_LOCK_FILE="$tmpdir/recovery.lock" \
  "$recovery" --consume

[[ $(wc -l <"$command_log") == 1 ]] || fail "resume monitor must ignore the suspend edge"
grep -F -- '--recover' "$command_log" >/dev/null || fail "resume monitor runs recovery on the wake edge"
pass "SoundWire recovery runs once on resume"
