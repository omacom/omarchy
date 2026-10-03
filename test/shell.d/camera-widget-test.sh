#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command timeout

script="$ROOT/shell/plugins/bar/widgets/camera-busy.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
bin="$tmp/bin"
log="$tmp/calls"
mkdir -p "$bin"
printf 'ok\n' >"$tmp/pw-mode"
: >"$tmp/open"
: >"$log"
echo '[]' >"$tmp/dump.json"

cat >"$bin/timeout" <<EOF
#!/bin/bash
printf 'timeout %s\n' "\$*" >>"$log"
exec /usr/bin/timeout "\$@"
EOF

cat >"$bin/pw-dump" <<EOF
#!/bin/bash
printf 'pw-dump\n' >>"$log"
mode=\$(cat "$tmp/pw-mode")
if [[ \$mode == hang ]]; then
  sleep 5
fi
if [[ \$mode == fail ]]; then
  exit 1
fi
cat "$tmp/dump.json"
EOF

cat >"$bin/fuser" <<EOF
#!/bin/bash
printf 'fuser %s\n' "\$*" >>"$log"
for arg in "\$@"; do
  if grep -qxF -- "\$arg" "$tmp/open"; then
    exit 0
  fi
done
exit 1
EOF
cat >"$bin/systemctl" <<EOF
#!/bin/bash
printf 'systemctl %s\n' "\$*" >>"$log"
[[ \$1 == is-active && \$2 == --quiet ]] || exit 1
unit=\${3#v4l2-relayd@}
unit=\${unit%.service}
grep -qxF -- "\$unit" "$tmp/active-relays" && exit 0
exit 1
EOF
chmod +x "$bin/timeout" "$bin/pw-dump" "$bin/fuser" "$bin/systemctl"

relay_dir="$tmp/relays"
sysfs_root="$tmp/sys/video4linux"

clear_relays() {
  rm -rf "$relay_dir" "$sysfs_root"
  mkdir -p "$relay_dir" "$sysfs_root"
  : >"$tmp/active-relays"
}
clear_relays

# instance.conf plus, when device is set, a virtual video4linux name file.
add_relay() {
  local instance=$1
  local label=$2
  local device=${3:-}
  local video_name

  printf 'CARD_LABEL="%s"\n' "$label" >"$relay_dir/$instance.conf"
  printf '%s\n' "$instance" >>"$tmp/active-relays"
  if [[ -n $device ]]; then
    video_name=${device#/dev/}
    mkdir -p "$sysfs_root/$video_name"
    printf '%s\n' "$label" >"$sysfs_root/$video_name/name"
  fi
}

# fixture: pw-dump body. mode: ok, fail, or hang.
# open_devices: comma-separated nodes the fuser stub reports open.
# fallback: __unset__ leaves CAMERA_BUSY_DEVICES unset; any other value,
# including empty, is passed through and stands in for the device glob.
# PROBE_KEEP_RELAYS=1 keeps a relay set up before this call.
probe() {
  local fixture=$1
  local mode=${2:-ok}
  local open_devices=${3:-}
  local fallback=${4-__unset__}

  if [[ ${PROBE_KEEP_RELAYS:-} != 1 ]]; then
    clear_relays
  fi
  cp -- "$fixture" "$tmp/dump.json"
  printf '%s\n' "$mode" >"$tmp/pw-mode"
  if [[ -n $open_devices ]]; then
    tr ',' '\n' <<<"$open_devices" >"$tmp/open"
  else
    : >"$tmp/open"
  fi
  : >"$log"

  if [[ $fallback == __unset__ ]]; then
    env -u CAMERA_BUSY_DUMP -u CAMERA_BUSY_DEVICES -u CAMERA_BUSY_OPEN_DEVICES \
      CAMERA_BUSY_RELAY_DIR="$relay_dir" \
      CAMERA_BUSY_VIDEO_SYSFS="$sysfs_root" \
      PATH="$bin:$PATH" \
      bash "$script"
  else
    env -u CAMERA_BUSY_DUMP -u CAMERA_BUSY_OPEN_DEVICES \
      CAMERA_BUSY_DEVICES="$fallback" \
      CAMERA_BUSY_RELAY_DIR="$relay_dir" \
      CAMERA_BUSY_VIDEO_SYSFS="$sysfs_root" \
      PATH="$bin:$PATH" \
      bash "$script"
  fi
}

expect() {
  local description=$1
  local actual=$2
  local wanted=$3

  [[ $actual == "$wanted" ]] || fail "$description" "actual: $actual"
  pass "$description"
}

saw_pw() {
  local description=$1

  grep -qx 'timeout 2 pw-dump' "$log" || fail "$description did not bound pw-dump" "$(cat "$log")"
  grep -qx 'pw-dump' "$log" || fail "$description did not run pw-dump" "$(cat "$log")"
}

saw_fuser() {
  local description=$1
  local wanted=$2
  local actual

  actual=$(grep '^fuser ' "$log" || true)
  [[ $actual == "$wanted" ]] || fail "$description fuser arguments" "actual: ${actual:-<none>}"
}

no_fuser() {
  local description=$1

  if grep -q '^fuser ' "$log"; then
    fail "$description called fuser" "$(cat "$log")"
  fi
}

cat >"$tmp/screencast.json" <<'EOF'
[
  {
    "id": 10,
    "type": "PipeWire:Interface:Node",
    "info": {"props": {"node.name": "xdg-desktop-portal-hyprland", "media.class": "Video/Source"}}
  },
  {
    "id": 11,
    "type": "PipeWire:Interface:Node",
    "info": {"props": {"node.name": "webrtc-consume", "media.class": "Stream/Input/Video"}}
  },
  {
    "id": 12,
    "type": "PipeWire:Interface:Link",
    "info": {"output-node-id": 10, "input-node-id": 11, "state": "active"}
  }
]
EOF

cat >"$tmp/camera-idle.json" <<'EOF'
[
  {
    "id": 58,
    "type": "PipeWire:Interface:Node",
    "info": {"props": {"media.class": "Video/Source", "device.api": "v4l2", "api.v4l2.path": "/dev/video0", "media.role": "Camera"}}
  }
]
EOF

cat >"$tmp/camera-and-screencast.json" <<'EOF'
[
  {
    "id": 58,
    "type": "PipeWire:Interface:Node",
    "info": {"props": {"media.class": "Video/Source", "device.api": "v4l2", "api.v4l2.path": "/dev/video0", "media.role": "Camera"}}
  },
  {
    "id": 10,
    "type": "PipeWire:Interface:Node",
    "info": {"props": {"node.name": "xdg-desktop-portal-hyprland", "media.class": "Video/Source"}}
  },
  {
    "id": 11,
    "type": "PipeWire:Interface:Node",
    "info": {"props": {"node.name": "webrtc-consume", "media.class": "Stream/Input/Video"}}
  },
  {
    "id": 12,
    "type": "PipeWire:Interface:Link",
    "info": {"output-node-id": 10, "input-node-id": 11, "state": "active"}
  }
]
EOF

cat >"$tmp/camera-linked.json" <<'EOF'
[
  {
    "id": 58,
    "type": "PipeWire:Interface:Node",
    "info": {"props": {"media.class": "Video/Source", "device.api": "v4l2", "api.v4l2.path": "/dev/video0"}}
  },
  {
    "id": 80,
    "type": "PipeWire:Interface:Node",
    "info": {"props": {"media.class": "Stream/Input/Video", "node.name": "ffmpeg"}}
  },
  {
    "id": 90,
    "type": "PipeWire:Interface:Link",
    "info": {"output-node-id": 58, "input-node-id": 80, "state": "active"}
  },
  {
    "id": 10,
    "type": "PipeWire:Interface:Node",
    "info": {"props": {"media.class": "Video/Source", "node.name": "xdg-desktop-portal-hyprland"}}
  },
  {
    "id": 11,
    "type": "PipeWire:Interface:Node",
    "info": {"props": {"media.class": "Stream/Input/Video", "node.name": "webrtc-consume"}}
  },
  {
    "id": 91,
    "type": "PipeWire:Interface:Link",
    "info": {"output-node-id": 10, "input-node-id": 11, "state": "paused"}
  }
]
EOF

cat >"$tmp/error-link.json" <<'EOF'
[
  {
    "id": 58,
    "type": "PipeWire:Interface:Node",
    "info": {"props": {"media.class": "Video/Source", "device.api": "v4l2"}}
  },
  {
    "id": 90,
    "type": "PipeWire:Interface:Link",
    "info": {"output-node-id": 58, "input-node-id": 80, "state": "error"}
  }
]
EOF

cat >"$tmp/libcamera.json" <<'EOF'
[
  {
    "id": 40,
    "type": "PipeWire:Interface:Node",
    "info": {"props": {"media.class": "Video/Source", "device.api": "libcamera"}}
  },
  {
    "id": 41,
    "type": "PipeWire:Interface:Node",
    "info": {"props": {"media.class": "Stream/Input/Video"}}
  },
  {
    "id": 42,
    "type": "PipeWire:Interface:Link",
    "info": {"output-node-id": 40, "input-node-id": 41, "state": "negotiating"}
  }
]
EOF

cat >"$tmp/loopback.json" <<'EOF'
[
  {
    "id": 70,
    "type": "PipeWire:Interface:Node",
    "info": {"props": {
      "node.name": "v4l2_input.loopback",
      "media.class": "Video/Source",
      "device.api": "v4l2",
      "api.v4l2.path": "/dev/video2",
      "api.v4l2.cap.driver": "v4l2 loopback",
      "api.v4l2.cap.card": "Cam Link 4K"
    }}
  }
]
EOF

cat >"$tmp/loopback-linked.json" <<'EOF'
[
  {
    "id": 70,
    "type": "PipeWire:Interface:Node",
    "info": {"props": {
      "media.class": "Video/Source",
      "device.api": "v4l2",
      "api.v4l2.path": "/dev/video2",
      "api.v4l2.cap.driver": "v4l2 loopback",
      "api.v4l2.cap.card": "Cam Link 4K"
    }}
  },
  {
    "id": 71,
    "type": "PipeWire:Interface:Node",
    "info": {"props": {"media.class": "Stream/Input/Video", "node.name": "firefox"}}
  },
  {
    "id": 72,
    "type": "PipeWire:Interface:Link",
    "info": {"output-node-id": 70, "input-node-id": 71, "state": "active"}
  }
]
EOF

cat >"$tmp/two-cameras.json" <<'EOF'
[
  {
    "id": 1,
    "type": "PipeWire:Interface:Node",
    "info": {"props": {"media.class": "Video/Source", "device.api": "v4l2", "api.v4l2.path": "/dev/video2"}}
  },
  {
    "id": 2,
    "type": "PipeWire:Interface:Node",
    "info": {"props": {"media.class": "Video/Source", "device.api": "v4l2", "api.v4l2.path": "/dev/video0"}}
  }
]
EOF

cat >"$tmp/odd-path.json" <<'EOF'
[
  {
    "id": 7,
    "type": "PipeWire:Interface:Node",
    "info": {"props": {"media.class": "Video/Source", "device.api": "v4l2", "api.v4l2.path": "/tmp/not-a-camera"}}
  }
]
EOF

echo '[]' >"$tmp/empty.json"
printf 'not-json\n' >"$tmp/garbage.json"

actual=$(probe "$tmp/screencast.json")
expect "screen sharing with no webcam is absent" "$actual" "absent"
saw_pw "screen sharing with no webcam"
no_fuser "screen sharing with no webcam"

actual=$(probe "$tmp/screencast.json" ok "/dev/video0" "/dev/video0")
expect "a non-camera video node is not a webcam when pw-dump returned data" "$actual" "absent"
saw_pw "non-camera video node"
no_fuser "non-camera video node"

actual=$(probe "$tmp/loopback.json" ok "/dev/video2")
expect "a loopback source left behind after unplug is absent" "$actual" "absent"
saw_pw "unplugged loopback"
no_fuser "unplugged loopback"

add_relay camlink "Cam Link 4K" /dev/video2
actual=$(PROBE_KEEP_RELAYS=1 probe "$tmp/loopback.json")
expect "a loopback source counts while its relay is running" "$actual" "idle"
saw_pw "relayed loopback"
saw_fuser "relayed loopback" "fuser /dev/video2"
clear_relays

add_relay camlink "Cam Link 4K" /dev/video2
actual=$(PROBE_KEEP_RELAYS=1 probe "$tmp/loopback-linked.json")
expect "a link from a relayed loopback is busy" "$actual" "busy"
saw_pw "linked relayed loopback"
saw_fuser "linked relayed loopback" "fuser /dev/video2"
clear_relays

add_relay camlink "Cam Link 4K" /dev/video2
actual=$(PROBE_KEEP_RELAYS=1 probe "$tmp/screencast.json" ok "/dev/video2")
expect "a running relay counts when PipeWire has no loopback node" "$actual" "busy"
saw_pw "relay without a node"
saw_fuser "relay without a node" "fuser /dev/video2"
clear_relays

add_relay camlink "Cam Link 4K" /dev/video2
actual=$(PROBE_KEEP_RELAYS=1 probe "$tmp/screencast.json")
expect "a running relay with nobody capturing is idle" "$actual" "idle"
saw_pw "idle relay without a node"
saw_fuser "idle relay without a node" "fuser /dev/video2"
clear_relays

add_relay camlink "Cam Link 4K"
actual=$(PROBE_KEEP_RELAYS=1 probe "$tmp/loopback.json")
expect "a running relay uses the loopback node path when sysfs has no name" "$actual" "idle"
saw_pw "relay without sysfs"
saw_fuser "relay without sysfs" "fuser /dev/video2"
clear_relays

actual=$(probe "$tmp/camera-and-screencast.json")
expect "screen sharing leaves a plugged-in webcam idle" "$actual" "idle"
saw_pw "webcam idle during screen sharing"
saw_fuser "webcam idle during screen sharing" "fuser /dev/video0"

actual=$(probe "$tmp/camera-idle.json")
expect "an unlinked v4l2 camera is idle" "$actual" "idle"
saw_pw "unlinked v4l2 camera"
saw_fuser "unlinked v4l2 camera" "fuser /dev/video0"

actual=$(probe "$tmp/camera-linked.json")
expect "a link from the v4l2 camera is busy during screen sharing" "$actual" "busy"
saw_pw "linked v4l2 camera"
saw_fuser "linked v4l2 camera" "fuser /dev/video0"

actual=$(probe "$tmp/camera-idle.json" ok "/dev/video0")
expect "a process holding the camera node is busy without a PipeWire link" "$actual" "busy"
saw_pw "open camera node"
saw_fuser "open camera node" "fuser /dev/video0"

actual=$(probe "$tmp/camera-idle.json" ok "/dev/video1")
expect "a process holding a different video node leaves the webcam idle" "$actual" "idle"
saw_pw "other video node open"
saw_fuser "other video node open" "fuser /dev/video0"

actual=$(probe "$tmp/error-link.json")
expect "an errored camera link is not in use" "$actual" "idle"
saw_pw "errored camera link"
no_fuser "errored camera link"

actual=$(probe "$tmp/libcamera.json")
expect "a libcamera source with a negotiating link is busy" "$actual" "busy"
saw_pw "libcamera source"
no_fuser "libcamera source"

actual=$(probe "$tmp/two-cameras.json" ok "/dev/video2")
expect "one open camera among several is busy" "$actual" "busy"
saw_pw "two cameras"
saw_fuser "two cameras" "fuser /dev/video0 /dev/video2"

actual=$(probe "$tmp/odd-path.json" ok "/tmp/not-a-camera")
expect "a camera node with a non-video path does not check that path" "$actual" "idle"
saw_pw "odd camera path"
no_fuser "odd camera path"

actual=$(probe "$tmp/empty.json")
expect "an empty pw-dump with no webcam is absent" "$actual" "absent"
saw_pw "empty pw-dump"
no_fuser "empty pw-dump"

actual=$(probe "$tmp/garbage.json" ok "" "/dev/video0")
expect "unreadable pw-dump falls back to the device list" "$actual" "idle"
saw_pw "unreadable pw-dump"
saw_fuser "unreadable pw-dump" "fuser /dev/video0"

actual=$(probe "$tmp/screencast.json" fail "" "/dev/video0")
expect "failed pw-dump falls back to a video node" "$actual" "idle"
saw_pw "failed pw-dump with a device"
saw_fuser "failed pw-dump with a device" "fuser /dev/video0"

actual=$(probe "$tmp/screencast.json" fail "/dev/video0" "/dev/video0")
expect "failed pw-dump reports an open fallback node as busy" "$actual" "busy"
saw_pw "failed pw-dump open device"
saw_fuser "failed pw-dump open device" "fuser /dev/video0"

actual=$(probe "$tmp/screencast.json" fail "" "")
expect "failed pw-dump with no fallback devices is absent" "$actual" "absent"
saw_pw "failed pw-dump without devices"
no_fuser "failed pw-dump without devices"

shopt -s nullglob
live=(/dev/video*)
shopt -u nullglob
live_nodes=()
for node in "${live[@]}"; do
  [[ $node =~ ^/dev/video[0-9]+$ ]] || continue
  live_nodes+=("$node")
done
actual=$(probe "$tmp/empty.json" fail)
if ((${#live_nodes[@]} > 0)); then
  expect "failed pw-dump falls back to local video nodes" "$actual" "idle"
  saw_fuser "local video nodes" "fuser ${live_nodes[*]}"
else
  expect "failed pw-dump with no local video nodes is absent" "$actual" "absent"
  no_fuser "no local video nodes"
fi
saw_pw "local video nodes"

start=$SECONDS
actual=$(probe "$tmp/screencast.json" hang "" "/dev/video0")
elapsed=$((SECONDS - start))
expect "a hung pw-dump falls back to the device list" "$actual" "idle"
if (( elapsed >= 5 )); then
  fail "pw-dump is bounded by timeout" "elapsed ${elapsed}s"
fi
pass "pw-dump is bounded by timeout"
saw_pw "hung pw-dump"
saw_fuser "hung pw-dump" "fuser /dev/video0"

printf 'fail\n' >"$tmp/pw-mode"
: >"$log"
actual=$(env -u CAMERA_BUSY_DEVICES -u CAMERA_BUSY_OPEN_DEVICES \
  CAMERA_BUSY_DUMP="$tmp/screencast.json" \
  CAMERA_BUSY_RELAY_DIR="$relay_dir" \
  CAMERA_BUSY_VIDEO_SYSFS="$sysfs_root" \
  PATH="$bin:$PATH" \
  bash "$script")
expect "CAMERA_BUSY_DUMP replaces pw-dump" "$actual" "absent"
if grep -q 'pw-dump' "$log"; then
  fail "CAMERA_BUSY_DUMP still ran pw-dump" "$(cat "$log")"
fi
pass "CAMERA_BUSY_DUMP does not run pw-dump"

: >"$log"
printf 'ok\n' >"$tmp/pw-mode"
cp -- "$tmp/camera-idle.json" "$tmp/dump.json"
: >"$tmp/open"
actual=$(env -u CAMERA_BUSY_DUMP -u CAMERA_BUSY_DEVICES \
  CAMERA_BUSY_OPEN_DEVICES="/dev/video9" \
  CAMERA_BUSY_RELAY_DIR="$relay_dir" \
  CAMERA_BUSY_VIDEO_SYSFS="$sysfs_root" \
  PATH="$bin:$PATH" \
  bash "$script")
expect "CAMERA_BUSY_OPEN_DEVICES does not by itself mean busy" "$actual" "idle"
saw_fuser "ignored open-devices override" "fuser /dev/video0"

qml="$ROOT/shell/plugins/bar/widgets/Camera.qml"
if grep -q 'pipewireCamera' "$qml"; then
  fail "camera widget does not treat every Video/Source as a webcam"
fi
pass "camera widget does not treat every Video/Source as a webcam"
