#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! timeout 2 systemctl --user show-environment >/dev/null 2>&1; then
  skip "Framework speaker retry check requires a reachable user systemd manager"
  exit 0
fi

scratch=$(mktemp -d)
unit="omarchy-framework16-test-$$.service"
cleanup() {
  systemctl --user stop "$unit" >/dev/null 2>&1 || true
  systemctl --user reset-failed "$unit" >/dev/null 2>&1 || true
  rm -rf "$scratch"
}
trap cleanup EXIT
mkdir "$scratch/bin"
printf '#!/bin/bash\ntrue\n' > "$scratch/bin/omarchy-hw-framework16"
cp "$scratch/bin/omarchy-hw-framework16" "$scratch/bin/omarchy-hw-match"
cp "$scratch/bin/omarchy-hw-framework16" "$scratch/bin/sleep"
cat > "$scratch/bin/pw-dump" <<'STUB'
#!/bin/bash
count=0
[[ ! -e $SERVICE_COUNT ]] || count=$(<"$SERVICE_COUNT")
printf '%s\n' "$((count + 1))" > "$SERVICE_COUNT"
if (( count < 50 )); then
  printf '[]\n'
else
  printf '%s\n' '[{"type":"PipeWire:Interface:Device","info":{"props":{"alsa.components":"HDA:10ec0285,f111000d,00100002","api.alsa.card":9,"api.alsa.soft-mixer":true}}}]'
fi
STUB
printf '#!/bin/bash\nprintf "%%s\\n" "$*" >> "$SERVICE_LOG"\n' > "$scratch/bin/amixer"
chmod +x "$scratch/bin/"*

# Exercise our exit-75 retry wiring once, without touching the audio session.
properties=()
while IFS= read -r line; do
  case "$line" in
    Type=*|TimeoutStartSec=*|RemainAfterExit=*|RestartForceExitStatus=*|RestartSec=*|StartLimitIntervalSec=*|StartLimitBurst=*)
      properties+=(--property="$line") ;;
    ExecStart=/usr/bin/*) initializer="$ROOT/bin/${line#ExecStart=/usr/bin/}" ;;
  esac
done < "$ROOT/default/systemd/user/omarchy-framework16-speaker-levels.service"
systemd-run --user --no-block --unit="$unit" "${properties[@]}" \
  --setenv="PATH=$scratch/bin:$ROOT/bin:/usr/bin" --setenv="OMARCHY_PATH=$ROOT" \
  --setenv="SERVICE_COUNT=$scratch/count" --setenv="SERVICE_LOG=$scratch/calls" \
  "$initializer" >/dev/null 2>&1
for ((attempt=0; attempt<100; attempt++)); do
  systemctl --user is-active --quiet "$unit" && break
  /usr/bin/sleep 0.2
done
systemctl --user is-active --quiet "$unit" || fail "delayed discovery recovers"
[[ $(<"$scratch/count") == 51 && $(systemctl --user show "$unit" --property=NRestarts --value) == 1 ]] ||
  fail "discovery timeout retries once"
[[ $(rg -c ' sset ' "$scratch/calls") == 3 ]] || fail "recovery initializes all three controls"
pass "shipped service retries delayed discovery and initializes the card"
