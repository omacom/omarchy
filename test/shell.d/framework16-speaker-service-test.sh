#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! timeout 2 systemctl --user show-environment >/dev/null 2>&1; then
  skip "Framework speaker retry policy requires a reachable user systemd manager"
  exit 0
fi

scratch=$(mktemp -d)
units=()
cleanup() {
  for unit in "${units[@]}"; do
    systemctl --user stop "$unit" >/dev/null 2>&1 || true
    systemctl --user reset-failed "$unit" >/dev/null 2>&1 || true
  done
  rm -rf "$scratch"
}
trap cleanup EXIT
mkdir "$scratch/bin"
cat > "$scratch/bin/omarchy-hw-framework16" <<'STUB'
#!/bin/bash
true
STUB
cp "$scratch/bin/omarchy-hw-framework16" "$scratch/bin/omarchy-hw-match"
cp "$scratch/bin/omarchy-hw-framework16" "$scratch/bin/sleep"
cat > "$scratch/bin/pw-dump" <<'STUB'
#!/bin/bash
count=0
[[ ! -e $SERVICE_COUNT ]] || count=$(<"$SERVICE_COUNT")
count=$((count + 1))
printf '%s\n' "$count" > "$SERVICE_COUNT"
if [[ $SERVICE_SCENARIO == "hung-discovery" ]]; then
  /usr/bin/sleep 60
fi
if [[ $SERVICE_SCENARIO == "unavailable" ]] ||
  { [[ $SERVICE_SCENARIO == "delayed" ]] && (( count <= 50 )); }; then
  printf '[]\n'
else
  printf '%s\n' '[{"type":"PipeWire:Interface:Device","info":{"props":{"alsa.components":"HDA:10ec0285,f111000d,00100002","api.alsa.card":9,"api.alsa.soft-mixer":true}}}]'
fi
STUB
cat > "$scratch/bin/amixer" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >> "$SERVICE_LOG"
[[ $SERVICE_SCENARIO != "control-error" ]]
STUB
chmod +x "$scratch/bin/"*

# Apply the shipped unit's execution and retry policy in isolated transient
# units. Fake ALSA/PipeWire commands exercise the real initializer without
# touching the running audio session. Only discovery sleeps are accelerated.
properties=()
while IFS= read -r line; do
  case "$line" in
    Type=*|TimeoutStartSec=*|RemainAfterExit=*|RestartForceExitStatus=*|RestartSec=*|StartLimitIntervalSec=*|StartLimitBurst=*)
      properties+=(--property="$line") ;;
  esac
done < "$ROOT/default/systemd/user/omarchy-framework16-speaker-levels.service"

for scenario in delayed unavailable control-error hung-discovery; do
  unit="omarchy-framework16-test-$$-$scenario.service"
  units+=("$unit")
  count_file="$scratch/$scenario.count"
  log_file="$scratch/$scenario.log"
  systemd-run --user --no-block --unit="$unit" "${properties[@]}" \
    --setenv="PATH=$scratch/bin:$ROOT/bin:/usr/bin" --setenv="OMARCHY_PATH=$ROOT" \
    --setenv="SERVICE_COUNT=$count_file" --setenv="SERVICE_LOG=$log_file" \
    --setenv="SERVICE_SCENARIO=$scenario" \
    "$ROOT/bin/omarchy-hw-framework16-speaker-levels" >/dev/null 2>&1
  for ((attempt=0; attempt<200; attempt++)); do
    state=$(systemctl --user show "$unit" --property=ActiveState --value)
    result=$(systemctl --user show "$unit" --property=Result --value)
    if [[ $scenario == "delayed" && $state == "active" ]] ||
      [[ $scenario == "unavailable" && $result == "start-limit-hit" ]] ||
      [[ $scenario == "control-error" && $state == "failed" ]] ||
      [[ $scenario == "hung-discovery" && $state == "failed" ]]; then
      break
    fi
    /usr/bin/sleep 0.2
  done
  case "$scenario" in
    delayed)
      [[ $state == "active" && $(<"$count_file") == 51 ]] || fail "systemd retries delayed discovery successfully"
      [[ $(systemctl --user show "$unit" --property=NRestarts --value) == 1 ]] || fail "delayed discovery retries once"
      [[ $(rg -c ' sset ' "$log_file") == 3 ]] || fail "recovery initializes all three controls"
      pass "systemd retries delayed discovery successfully" ;;
    unavailable)
      [[ $state == "failed" && $result == "start-limit-hit" ]] || fail "persistent discovery failure reaches the start limit"
      [[ $(<"$count_file") == 200 && ! -e $log_file ]] || fail "persistent discovery failure stops after four attempts without mixer writes"
      /usr/bin/sleep 6
      [[ $(<"$count_file") == 200 ]] || fail "persistent discovery failure stays stopped"
      pass "systemd stops persistent discovery failure after four attempts" ;;
    control-error)
      [[ $state == "failed" ]] || fail "control failure remains failed"
      /usr/bin/sleep 6
      [[ $(<"$count_file") == 1 ]] || fail "control failure is not retried"
      if rg -q ' sset ' "$log_file"; then
        fail "control failure does not write hardware levels"
      fi
      pass "systemd does not retry mixer control failures" ;;
    hung-discovery)
      [[ $state == "failed" && $result == "timeout" ]] || fail "hung discovery is terminated by the startup timeout"
      /usr/bin/sleep 6
      [[ $(<"$count_file") == 1 && ! -e $log_file ]] || fail "hung discovery stops without retries or mixer writes"
      pass "systemd stops hung discovery without retries" ;;
  esac
done
