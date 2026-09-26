#!/bin/bash
# Print busy, idle, or absent.
#
# A webcam is a v4l2 or libcamera Video/Source. Screen sharing is also a
# Video/Source, and its client is Stream/Input/Video, so those classes are
# not enough on their own.
#
# When pw-dump returns data, presence is the count of those webcam nodes.
# The camera is busy while a link leaves one of them, or while a process has
# that node's /dev/videoN open. Metadata and codec nodes do not count.
#
# A v4l2 loopback source is the Cam Link case. PipeWire records whether that
# device can capture only when the node first appears, and exclusive caps make
# it a capture device only while v4l2-relayd is writing. Count a loopback
# while its relay instance is active: that drops a node left behind after
# unplug, and still shows the camera when the relay is running but PipeWire
# never created a node. The device comes from the virtual video4linux name,
# or from the loopback node's path when that name is absent.
#
# When pw-dump fails, times out, or returns nothing, fall back to any
# /dev/videoN node.
#
# CAMERA_BUSY_DUMP replaces pw-dump. CAMERA_BUSY_DEVICES replaces the
# fallback device list. CAMERA_BUSY_RELAY_DIR and CAMERA_BUSY_VIDEO_SYSFS
# replace the relay config directory and the virtual video4linux sysfs tree.
# Leave them unset in normal use.

shopt -s nullglob

dump=$(mktemp)
trap 'rm -f "$dump"' EXIT

dump_ok=0
if [[ -v CAMERA_BUSY_DUMP ]]; then
  if [[ -n $CAMERA_BUSY_DUMP ]] && cp -- "$CAMERA_BUSY_DUMP" "$dump" 2>/dev/null && [[ -s $dump ]]; then
    dump_ok=1
  fi
elif timeout 2 pw-dump >"$dump" 2>/dev/null && [[ -s $dump ]]; then
  dump_ok=1
fi

cameras=0
linked=0
paths=()

add_path() {
  local candidate=$1 existing
  [[ $candidate =~ ^/dev/video[0-9]+$ ]] || return 0
  for existing in "${paths[@]}"; do
    [[ $existing == "$candidate" ]] && return 0
  done
  paths+=("$candidate")
}

if (( dump_ok )); then
  parsed=$(jq -r '
    def props: (.info.props // {});
    def camera:
      .type == "PipeWire:Interface:Node"
      and (props["media.class"] == "Video/Source")
      and (
        (props["device.api"] == "v4l2")
        or (props["device.api"] == "libcamera")
        or ((props["api.v4l2.path"] // "") | startswith("/dev/video"))
      );
    def loopback:
      camera and ((props["api.v4l2.cap.driver"] // "") == "v4l2 loopback");
    def consuming:
      .type == "PipeWire:Interface:Link"
      and ((.info.state // "") != "error")
      and ((.info.state // "") != "unlinked");
    . as $doc
    | [ $doc[] | select(consuming) | .info["output-node-id"] ] as $outs
    | [ $doc[] | select(camera and (loopback | not)) ] as $cams
    | [ $cams[].id ] as $ids
    | ([ $outs[] | select(. as $id | $ids | index($id) != null) ] | length) as $links
    | [ $cams[]
        | (props["api.v4l2.path"] // "")
        | select(test("^/dev/video[0-9]+$"))
      ] | unique as $paths
    | [ $doc[] | select(loopback) ] as $loops
    | (
        [ "REAL",
          ($ids | length),
          (if $links > 0 then 1 else 0 end),
          ($paths | join(","))
        ] | @tsv
      ),
      (
        $loops[]
        | . as $node
        | [ "LOOP",
            ($node | props | .["api.v4l2.path"] // ""),
            ($node | props | .["api.v4l2.cap.card"] // ""),
            (if ($outs | index($node.id)) != null then 1 else 0 end)
          ] | @tsv
      )
  ' "$dump" 2>/dev/null) || parsed=""

  declare -A loop_path_for_card=()
  declare -A loop_link_for_path=()
  real_cameras=""
  real_linked=""
  saw_real=0
  while IFS=$'\t' read -r kind field_a field_b field_c; do
    [[ -n $kind ]] || continue
    case $kind in
    REAL)
      saw_real=1
      real_cameras=$field_a
      real_linked=$field_b
      if [[ -n $field_c ]]; then
        IFS=',' read -r -a real_path_list <<<"$field_c"
        for candidate in "${real_path_list[@]}"; do
          add_path "$candidate"
        done
      fi
      ;;
    LOOP)
      [[ -n $field_b ]] || continue
      loop_path_for_card[$field_b]=$field_a
      if [[ $field_a =~ ^/dev/video[0-9]+$ ]]; then
        loop_link_for_path[$field_a]=$field_c
      fi
      ;;
    esac
  done <<<"$parsed"

  if [[ $saw_real == 1 && $real_cameras =~ ^[0-9]+$ && $real_linked =~ ^[01]$ ]]; then
    cameras=$real_cameras
    linked=$real_linked
  else
    dump_ok=0
    cameras=0
    linked=0
    paths=()
  fi
fi

if (( dump_ok )); then
  relay_dir=${CAMERA_BUSY_RELAY_DIR:-/etc/v4l2-relayd.d}
  sysfs_root=${CAMERA_BUSY_VIDEO_SYSFS:-/sys/devices/virtual/video4linux}
  for conf in "$relay_dir"/*.conf; do
    [[ -f $conf ]] || continue
    instance=$(basename "$conf" .conf)
    [[ $instance =~ ^[A-Za-z0-9_-]+$ ]] || continue
    timeout 1 systemctl is-active --quiet "v4l2-relayd@${instance}.service" || continue

    label=$(grep -m1 '^CARD_LABEL=' "$conf" 2>/dev/null || true)
    label=${label#CARD_LABEL=}
    label=${label%\"}
    label=${label#\"}
    label=${label%\'}
    label=${label#\'}
    [[ -n $label ]] || continue

    relay_path=""
    for namefile in "$sysfs_root"/*/name; do
      [[ -f $namefile ]] || continue
      [[ $(<"$namefile") == "$label" ]] || continue
      device_name=$(basename "${namefile%/name}")
      [[ $device_name =~ ^video[0-9]+$ ]] || continue
      relay_path=/dev/$device_name
      break
    done
    if [[ -z $relay_path && -n ${loop_path_for_card[$label]:-} ]]; then
      relay_path=${loop_path_for_card[$label]}
    fi
    [[ $relay_path =~ ^/dev/video[0-9]+$ ]] || continue

    already=0
    for existing in "${paths[@]}"; do
      [[ $existing == "$relay_path" ]] && already=1
    done
    if (( already == 0 )); then
      paths+=("$relay_path")
      cameras=$((cameras + 1))
    fi
    if [[ ${loop_link_for_path[$relay_path]:-} == 1 ]]; then
      linked=1
    fi
  done
fi

if (( dump_ok == 0 )); then
  candidates=()
  if [[ -v CAMERA_BUSY_DEVICES ]]; then
    if [[ -n $CAMERA_BUSY_DEVICES ]]; then
      IFS=',' read -r -a candidates <<<"$CAMERA_BUSY_DEVICES"
    fi
  else
    candidates=(/dev/video*)
  fi
  paths=()
  linked=0
  for candidate in "${candidates[@]}"; do
    add_path "$candidate"
  done
  cameras=${#paths[@]}
fi

video_nodes=()
for candidate in "${paths[@]}"; do
  [[ $candidate =~ ^/dev/video[0-9]+$ ]] || continue
  video_nodes+=("$candidate")
done

device_open=0
if ((${#video_nodes[@]} > 0)) && fuser "${video_nodes[@]}" >/dev/null 2>&1; then
  device_open=1
fi

if (( device_open == 1 || linked == 1 )); then
  echo busy
elif (( cameras > 0 )); then
  echo idle
else
  echo absent
fi
exit 0
