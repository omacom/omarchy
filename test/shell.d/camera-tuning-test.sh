#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin" "$work/config" "$work/v4l/video50" "$work/dt" "$work/dev/dma_heap"
touch "$work/dt/camera10" "$work/dev/video50" "$work/dev/dma_heap/system"
printf 'Front Camera\n' >"$work/v4l/video50/name"

CALLS="$work/calls"
WPCTL_HAS_CAMERA="$work/wpctl-has-camera"
export CALLS WPCTL_HAS_CAMERA

cat >"$work/bin/omarchy-hw-match-device-tree" <<'SH'
#!/bin/bash
[[ ${MOCK_DT_MATCH:-} == "$1" ]]
SH

cat >"$work/bin/omarchy-hw-match" <<'SH'
#!/bin/bash
exit 1
SH

cat >"$work/bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$CALLS"
case "$*" in
  *"is-active --quiet wireplumber.service"*) exit 0 ;;
  *"is-active --quiet omarchy-camera-relay.service"*)
    [[ -f ${MOCK_ACTIVE_FILE:-/nonexistent} ]] && exit 0
    exit 3
    ;;
  *"is-enabled --quiet omarchy-camera-relay.service"*)
    [[ -f ${MOCK_ACTIVE_FILE:-/nonexistent} ]] && exit 0
    exit 1
    ;;
  *"try-restart wireplumber.service"*)
    touch "$WPCTL_HAS_CAMERA"
    exit 0
    ;;
esac
exit 0
SH

cat >"$work/bin/wpctl" <<'SH'
#!/bin/bash
printf 'wpctl %s\n' "$*" >>"$CALLS"
if [[ -f $WPCTL_HAS_CAMERA ]]; then
  cat <<'OUT'
Video
 ├─ Devices:
 │      44. Front Camera                        [v4l2]
 ├─ Sources:
 │  *   48. Front Camera (V4L2)
Settings
OUT
else
  cat <<'OUT'
Video
 ├─ Devices:
 │      44. Front Camera                        [v4l2]
 ├─ Sources:
Settings
OUT
fi
SH

cat >"$work/bin/v4l2-ctl" <<'SH'
#!/bin/bash
printf 'v4l2-ctl %s\n' "$*" >>"$CALLS"
echo "	Device Caps      : 0x05200001"
echo "		Video Capture"
SH

cat >"$work/bin/mock-relayd" <<'SH'
#!/bin/bash
printf 'LIBCAMERA_IPA_CONFIG_PATH=%s\n' "${LIBCAMERA_IPA_CONFIG_PATH:-}" >"$MOCK_RELAY_OUT"
printf 'ARGS=%s\n' "$*" >>"$MOCK_RELAY_OUT"
SH

chmod +x "$work/bin/"*

# Copy the shipped tuning with a mock camera_dt_node path so tests work on any host.
mkdir -p "$work/omarchy/default/camera/tunings/anduril-bluechip/ipa/simple" \
  "$work/omarchy/default/systemd/user"
cp "$ROOT/default/camera/tunings/anduril-bluechip/ipa/simple/ov08x40.yaml" \
  "$work/omarchy/default/camera/tunings/anduril-bluechip/ipa/simple/"
sed "s|^camera_dt_node=.*|camera_dt_node=\"$work/dt/camera10\"|" \
  "$ROOT/default/camera/tunings/anduril-bluechip/tuning.conf" \
  >"$work/omarchy/default/camera/tunings/anduril-bluechip/tuning.conf"
cp "$ROOT/default/systemd/user/omarchy-camera-relay.service" \
  "$ROOT/default/systemd/user/omarchy-camera-guard.service" \
  "$work/omarchy/default/systemd/user/"

run_tuning() {
  PATH="$work/bin:$PATH" \
    OMARCHY_PATH="$work/omarchy" \
    XDG_CONFIG_HOME="$work/config" \
    MOCK_DT_MATCH="${MOCK_DT_MATCH:-anduril,bluechip}" \
    MOCK_ACTIVE_FILE="$work/relay-active" \
    "$ROOT/bin/omarchy-camera-tuning" "$@"
}

# 1. Syntax checks on all scripts
bash -n "$ROOT/bin/omarchy-camera-tuning" || fail "omarchy-camera-tuning has valid syntax"
bash -n "$ROOT/bin/omarchy-camera-relay" || fail "omarchy-camera-relay has valid syntax"
bash -n "$ROOT/bin/omarchy-camera-guard" || fail "omarchy-camera-guard has valid syntax"
bash -n "$ROOT/install/user/first-run/camera-tuning.sh" || fail "camera-tuning first-run has valid syntax"
bash -n "$ROOT/migrations/1795705800.sh" || fail "camera-tuning migration has valid syntax"
python3 -m py_compile "$ROOT/bin/omarchy-camera" || fail "omarchy-camera has valid syntax"
python3 -m py_compile "$ROOT/bin/omarchy-camera-relay-daemon" || fail "omarchy-camera-relay-daemon has valid syntax"

# 2. Non-matching laptop is a clean no-op
! MOCK_DT_MATCH="other,board" run_tuning match >/dev/null || fail "match fails on unrelated boards"
out="$(MOCK_DT_MATCH="other,board" run_tuning on)"
[[ $out == *"No camera tuning matches"* ]] || fail "on is a no-op on unrelated boards"

# 3. BlueChip matches and 'on' installs env + user units + restarts wireplumber once
matched="$(run_tuning match)"
[[ $matched == */anduril-bluechip ]] || fail "BlueChip matches its shipped tuning"

: >"$CALLS"
run_tuning on >/dev/null
[[ -r $work/config/omarchy/camera-relay.env ]] || fail "on writes camera-relay.env"
[[ -r $work/config/systemd/user/omarchy-camera-relay.service ]] || fail "on installs relay user unit"
[[ -r $work/config/systemd/user/omarchy-camera-guard.service ]] || fail "on installs guard user unit"
! grep -q '@' "$work/config/systemd/user/omarchy-camera-"*.service || fail "rendered user units have no unsubstituted placeholders"
grep -q "try-restart wireplumber.service" "$CALLS" || fail "on restarts wireplumber when Front Camera is not yet listed"
default_env="$(cat "$work/config/omarchy/camera-relay.env")"

# 4. User override via 'set' updates ~/.config/omarchy/camera.conf and re-renders env
: >"$CALLS"
run_tuning set gamma=1.65 contrast=1.1 saturation=1.3 >/dev/null
grep -qx "gamma=1.65" "$work/config/omarchy/camera.conf" || fail "set writes gamma override"
grep -qx "contrast=1.1" "$work/config/omarchy/camera.conf" || fail "set writes contrast override"
grep -qx "saturation=1.3" "$work/config/omarchy/camera.conf" || fail "set writes saturation override"
grep -q "GAMMA=1.65" "$work/config/omarchy/camera-relay.env" || fail "override gamma reaches camera-relay.env"
! grep -q "try-restart wireplumber.service" "$CALLS" || fail "set does not restart wireplumber when Front Camera is already listed"

# Invalid override is rejected cleanly
! run_tuning set gamma=bogus 2>/dev/null || fail "invalid gamma value is rejected"
! run_tuning set gamma=-1 2>/dev/null || fail "negative gamma value is rejected"
! run_tuning set warmth=bogus 2>/dev/null || fail "invalid warmth value is rejected"
! run_tuning set evil=1 2>/dev/null || fail "unknown override key is rejected"

# 4b. Live hot-apply over the Unix control socket skips restarting the relay
touch "$work/relay-active"
live_sock="$work/relay.sock"
live_rx="$work/live-rx"
python3 - "$live_sock" "$live_rx" <<'PY' &
import os, socket, sys
sock_path, out_path = sys.argv[1], sys.argv[2]
s = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
s.bind(sock_path)
s.settimeout(5.0)
data = s.recv(1024).decode("utf-8")
with open(out_path, "w", encoding="utf-8") as fh:
    fh.write(data)
s.close()
PY
rx_pid=$!
for _ in {1..30}; do
  [[ -S $live_sock ]] && break
  sleep 0.05
done
: >"$CALLS"
OMARCHY_CAMERA_RELAY_SOCKET="$live_sock" run_tuning set gamma=1.75 contrast=1.15 saturation=1.25 brightness=-0.10 warmth=0.25 tint=-0.15 >/dev/null
wait "$rx_pid" || fail "live socket receiver captured datagram"
grep -q "gamma=1.75 contrast=1.15 saturation=1.25 brightness=-0.10 warmth=0.25 tint=-0.15" "$live_rx" || fail "set sends live tuning datagram to relay socket"
grep -q "GAMMA=1.75" "$work/config/omarchy/camera-relay.env" || fail "live hot-apply still persists camera-relay.env"
grep -q "BRIGHTNESS=-0.10" "$work/config/omarchy/camera-relay.env" || fail "signed brightness persists to camera-relay.env"
grep -q "WARMTH=0.25" "$work/config/omarchy/camera-relay.env" || fail "warmth persists to camera-relay.env"
grep -q "TINT=-0.15" "$work/config/omarchy/camera-relay.env" || fail "tint persists to camera-relay.env"
! grep -q "restart omarchy-camera-relay.service" "$CALLS" || fail "live hot-apply does not restart relay service"

# Upgrading from a pre-schema env forces a one-time relay restart instead of
# hot-applying new keys against an older daemon that ignores them.
grep -v '^RELAY_SCHEMA=' "$work/config/omarchy/camera-relay.env" >"$work/legacy-env"
mv "$work/legacy-env" "$work/config/omarchy/camera-relay.env"
: >"$CALLS"
OMARCHY_CAMERA_RELAY_SOCKET="$live_sock" run_tuning set warmth=0.30 >/dev/null
grep -q "restart omarchy-camera-relay.service" "$CALLS" || fail "schema upgrade restarts older relay once instead of using live socket"
grep -qx "RELAY_SCHEMA=2" "$work/config/omarchy/camera-relay.env" || fail "schema upgrade writes RELAY_SCHEMA=2"

rm -f "$work/relay-active" "$live_sock"
run_tuning set gamma=1.65 contrast=1.1 saturation=1.3 >/dev/null

# 5. Relay wrapper builds pipeline with overrides and user IPA precedence
mkdir -p "$work/config/omarchy/camera/ipa/simple"
MOCK_RELAY_OUT="$work/relay-out"
export MOCK_RELAY_OUT
PATH="$work/bin:$PATH" \
  XDG_CONFIG_HOME="$work/config" \
  OMARCHY_V4L_VIRTUAL_PATH="$work/v4l" \
  OMARCHY_DEV_PATH="$work/dev" \
  OMARCHY_V4L2_RELAYD_BIN="$work/bin/mock-relayd" \
  "$ROOT/bin/omarchy-camera-relay"
grep -q "LIBCAMERA_IPA_CONFIG_PATH=$work/config/omarchy/camera/ipa:$work/omarchy/default/camera/tunings/anduril-bluechip/ipa" "$MOCK_RELAY_OUT" ||
  fail "user IPA dir takes precedence over shipped tuning IPA dir"
grep -q "gamma=1.65 contrast=1.1 saturation=1.3" "$MOCK_RELAY_OUT" ||
  fail "relay passes tuned gamma, contrast, and saturation to libcamerasrc"
grep -q "device=$work/dev/video50" "$MOCK_RELAY_OUT" ||
  fail "relay resolves loopback device dynamically by card_label"

# --wait-ready succeeds when v4l2-ctl reports Video Capture
PATH="$work/bin:$PATH" \
  XDG_CONFIG_HOME="$work/config" \
  OMARCHY_V4L_VIRTUAL_PATH="$work/v4l" \
  OMARCHY_DEV_PATH="$work/dev" \
  "$ROOT/bin/omarchy-camera-relay" --wait-ready || fail "--wait-ready succeeds on Video Capture"

# 6. First-class 'omarchy-camera' CLI controls read, set, reset, and live-apply
run_camera() {
  PATH="$work/bin:$PATH" \
    OMARCHY_PATH="$work/omarchy" \
    XDG_CONFIG_HOME="$work/config" \
    MOCK_DT_MATCH="${MOCK_DT_MATCH:-anduril,bluechip}" \
    MOCK_ACTIVE_FILE="$work/relay-active" \
    "$ROOT/bin/omarchy-camera" "$@"
}

status_json="$(run_camera status --json)"
jq -e '.installed == true and .label == "Front Camera" and .values.gamma == 1.65 and .defaults.gamma == 1.5' <<<"$status_json" >/dev/null ||
  fail "omarchy-camera status --json reports current values and shipped defaults"
[[ $(run_camera gamma) == "1.65" ]] || fail "omarchy-camera gamma prints current value"

# Individual control setters (including negative values) persist through omarchy-camera-tuning
run_camera brightness -- -0.15 >/dev/null
run_camera warmth 0.30 >/dev/null
run_camera tint -0.20 >/dev/null
[[ $(run_camera brightness) == "-0.15" ]] || fail "omarchy-camera brightness sets negative value"
[[ $(run_camera warmth) == "0.30" ]] || fail "omarchy-camera warmth sets value"
[[ $(run_camera tint) == "-0.20" ]] || fail "omarchy-camera tint sets negative value"

# Single-control reset restores only that control
run_camera reset warmth >/dev/null
[[ $(run_camera warmth) == "0.00" ]] || fail "omarchy-camera reset warmth restores default warmth"
[[ $(run_camera brightness) == "-0.15" ]] || fail "omarchy-camera reset warmth leaves brightness untouched"

# Range validation rejects out-of-bounds values
! run_camera brightness 2.0 2>/dev/null || fail "omarchy-camera rejects out-of-range brightness"
! run_camera gamma 0.1 2>/dev/null || fail "omarchy-camera rejects out-of-range gamma"
! run_camera unknown 1.0 2>/dev/null || fail "omarchy-camera rejects unknown command"

# --live sends directly to the relay socket without modifying camera.conf
live_sock2="$work/relay2.sock"
live_rx2="$work/live-rx2"
python3 - "$live_sock2" "$live_rx2" <<'PY' &
import socket, sys
s = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
s.bind(sys.argv[1])
s.settimeout(5.0)
data = s.recv(1024).decode("utf-8")
with open(sys.argv[2], "w", encoding="utf-8") as fh:
    fh.write(data)
s.close()
PY
rx_pid2=$!
for _ in {1..30}; do
  [[ -S $live_sock2 ]] && break
  sleep 0.05
done
OMARCHY_CAMERA_RELAY_SOCKET="$live_sock2" run_camera warmth --live 0.45 >/dev/null
wait "$rx_pid2" || fail "omarchy-camera --live delivered datagram"
grep -qx "warmth=0.45" "$live_rx2" || fail "omarchy-camera --live sent expected payload"
[[ $(run_camera warmth) == "0.00" ]] || fail "omarchy-camera --live does not overwrite saved config"
rm -f "$live_sock2"

# Fine decimal adjustments (>2 decimal places) are preserved end-to-end
run_camera brightness 0.004 >/dev/null
[[ $(run_camera brightness) == "0.004" ]] || fail "omarchy-camera preserves fine decimal adjustments"

# Full reset via omarchy-camera restores defaults
run_camera reset >/dev/null
[[ ! -e $work/config/omarchy/camera.conf ]] || fail "omarchy-camera reset removes override file"
[[ $(run_camera brightness) == "0.00" && $(run_camera gamma) == "1.50" ]] || fail "omarchy-camera reset restores defaults"

# 7. 'reset' restores shipped defaults, 'off' removes units and env
run_tuning reset >/dev/null
[[ ! -e $work/config/omarchy/camera.conf ]] || fail "reset removes user override file"
[[ $(cat "$work/config/omarchy/camera-relay.env") == "$default_env" ]] || fail "reset restores original rendered env"

run_tuning off >/dev/null
[[ ! -e $work/config/omarchy/camera-relay.env ]] || fail "off removes camera-relay.env"
[[ ! -e $work/config/systemd/user/omarchy-camera-relay.service ]] || fail "off removes relay unit"
[[ ! -e $work/config/systemd/user/omarchy-camera-guard.service ]] || fail "off removes guard unit"

echo "ok - omarchy-camera-tuning userland relay, overrides, IPA precedence, and lifecycle"
