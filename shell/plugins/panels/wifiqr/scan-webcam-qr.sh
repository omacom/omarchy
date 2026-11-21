#!/bin/bash

set -uo pipefail

requested_device="${1:-}"

if ! omarchy-hw-webcam >/dev/null 2>&1; then
  printf 'error\tnoWebcam\n'
  exit 2
fi

mapfile -t raw_devices < <(omarchy-capture-webcam-list 2>/dev/null)
if (( ${#raw_devices[@]} == 0 )); then
  printf 'error\tnoWebcam\n'
  exit 2
fi

devices=()
names=()
selected_device=""
selected_name=""

for entry in "${raw_devices[@]}"; do
  dev="${entry%%[[:space:]]*}"
  label="${entry#"$dev"}"
  label="${label#"${label%%[![:space:]]*}"}"
  label="${label%:}"
  [[ -n $dev ]] || continue
  devices+=("$dev")
  names+=("${label:-$dev}")
  printf 'camera\t%s\t%s\n' "$dev" "${label:-$dev}"
  if [[ -n $requested_device && $dev == "$requested_device" ]]; then
    selected_device="$dev"
    selected_name="${label:-$dev}"
  fi
done

if [[ -z $selected_device ]]; then
  selected_device="${devices[0]}"
  selected_name="${names[0]}"
fi

runtime_base="${XDG_RUNTIME_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/omarchy}"
scan_dir="$runtime_base/omarchy-wifiqr-scan"
mkdir -p "$scan_dir" && chmod 700 "$scan_dir"
frame_file="$scan_dir/preview-$$.jpg"
pid_file="$scan_dir/ffmpeg.pid"

if [[ -r $pid_file ]]; then
  old_pid=$(<"$pid_file")
  if [[ $old_pid =~ ^[0-9]+$ ]] && kill -0 "$old_pid" 2>/dev/null; then
    kill "$old_pid" 2>/dev/null || true
    for ((i = 0; i < 20; i++)); do
      kill -0 "$old_pid" 2>/dev/null || break
      sleep 0.05
    done
  fi
  rm -f "$pid_file"
fi
rm -f "$scan_dir"/preview-* 2>/dev/null || true

ffmpeg_pid=""
cleanup() {
  if [[ -n $ffmpeg_pid ]] && kill -0 "$ffmpeg_pid" 2>/dev/null; then
    kill "$ffmpeg_pid" 2>/dev/null || true
    wait "$ffmpeg_pid" 2>/dev/null || true
  fi
  rm -f "$frame_file" "$frame_file.tmp" "$pid_file"
}
trap cleanup EXIT INT TERM HUP

printf 'active\t%s\t%s\t%s\n' "$selected_device" "$selected_name" "$frame_file"

v4l2_args=(-f v4l2)
formats_out=$(v4l2-ctl --list-formats-ext -d "$selected_device" 2>/dev/null || true)

if grep -q "'MJPG'" <<<"$formats_out"; then
  v4l2_args+=(-input_format mjpeg)
fi

for res in "1280x720" "960x540" "848x480" "640x480" "640x360"; do
  if grep -q "$res" <<<"$formats_out"; then
    v4l2_args+=(-video_size "$res")
    break
  fi
done

setpriv --pdeathsig TERM ffmpeg -nostdin -y -loglevel error \
  "${v4l2_args[@]}" -i "$selected_device" \
  -vf "fps=15" -q:v 3 \
  -f image2 -update 1 -atomic_writing 1 "$frame_file" >/dev/null 2>&1 &
ffmpeg_pid=$!
printf '%s\n' "$ffmpeg_pid" >"$pid_file"

ready_sent=0
tick=0
last_qr=""
last_qr_tick=0

while kill -0 "$ffmpeg_pid" 2>/dev/null; do
  if [[ -s $frame_file ]]; then
    if (( ! ready_sent )); then
      ready_sent=1
      printf 'ready\t%s\n' "$frame_file"
    fi

    if (( tick % 2 == 0 )); then
      decoded=$(zbarimg -q --raw -Sdisable -Sqrcode.enable "$frame_file" 2>/dev/null | head -n 1 || true)
      if [[ -n $decoded ]]; then
        if [[ $decoded != "$last_qr" ]] || (( tick - last_qr_tick >= 12 )); then
          last_qr="$decoded"
          last_qr_tick=$tick
          b64=$(printf '%s' "$decoded" | base64 -w0)
          printf 'qr\t%s\n' "$b64"
        fi
      fi
    fi
  fi

  ((tick++))
  sleep 0.15
done

if (( ! ready_sent )); then
  printf 'error\tcameraFailed\n'
  exit 1
fi
