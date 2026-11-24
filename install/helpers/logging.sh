omarchy_log_to_stdout() {
  [[ ${OMARCHY_LOG_TO_STDOUT:-} == "1" || -z ${OMARCHY_INSTALL_LOG_FILE:-} ]]
}

omarchy_log_line() {
  if omarchy_log_to_stdout; then
    echo "$1"
  else
    echo "$1" >>"$OMARCHY_INSTALL_LOG_FILE"
  fi
}

omarchy_log_timestamp() {
  printf -v "$1" '%(%Y-%m-%d %H:%M:%S)T' -1
}

start_install_log() {
  local start_time

  if ! omarchy_log_to_stdout; then
    mkdir -p "$(dirname "$OMARCHY_INSTALL_LOG_FILE")"
    touch "$OMARCHY_INSTALL_LOG_FILE"
    chmod 666 "$OMARCHY_INSTALL_LOG_FILE" 2>/dev/null || true
  fi

  omarchy_log_timestamp start_time
  export OMARCHY_START_TIME="${OMARCHY_START_TIME:-$start_time}"
  export OMARCHY_START_EPOCH="${OMARCHY_START_EPOCH:-$EPOCHSECONDS}"

  omarchy_log_line "=== Omarchy Setup Started: $OMARCHY_START_TIME ==="
}

stop_install_log() {
  local end_time end_epoch duration mins secs
  omarchy_log_timestamp end_time
  end_epoch=$EPOCHSECONDS

  omarchy_log_line "=== Omarchy Setup Completed: $end_time ==="

  if [[ -n ${OMARCHY_START_EPOCH:-} ]]; then
    duration=$((end_epoch - OMARCHY_START_EPOCH))
    mins=$((duration / 60))
    secs=$((duration % 60))
    omarchy_log_line "Omarchy setup: ${mins}m ${secs}s"
  fi
}

omarchy_is_aarch64_leaf() {
  case "$1" in
    hardware/gb10/sleep.sh | \
      hardware/gb10/cpuidle.sh | \
      hardware/gb10/memory-watermark.sh | \
      hardware/gb10/nvidia-memory-pools.sh | \
      hardware/nvidia/dgx-spark-boot.sh | \
      hardware/n1x.sh | \
      hardware/asus/fix-asus-zenbook-a16-speakers.sh | \
      hardware/asus/fix-asus-zenbook-14-ux3480qa-audio.sh | \
      hardware/asus/fix-asus-proart-pz13-speakers.sh | \
      hardware/acer/fix-acer-aspire-16-ai-speakers.sh | \
      hardware/acer/fix-acer-aspire-16-ai-boot.sh | \
      hardware/hp/fix-hp-omnibook-3-speakers.sh | \
      hardware/asus/fix-asus-zenbook-a16-boot.sh | \
      hardware/asus/fix-asus-zenbook-14-ux3480qa-boot.sh | \
      hardware/asus/fix-asus-zenbook-a14-boot.sh | \
      hardware/asus/fix-asus-vivobook-s15-boot.sh | \
      hardware/asus/fix-asus-vivobook-s16-boot.sh | \
      hardware/hp/fix-hp-omnibook-x14-boot.sh | \
      hardware/lenovo/fix-lenovo-ideacentre-mini-boot.sh | \
      hardware/fix-n1x-gpu-memory.sh | \
      hardware/raspberrypi/raspberry-pi-4.sh | \
      hardware/qualcomm/dtb-uki.sh | \
      hardware/qualcomm/kernel-params.sh | \
      hardware/qualcomm/initramfs.sh | \
      hardware/qualcomm/glymur-display.sh | \
      hardware/qualcomm/hamoa-display.sh | \
      hardware/asus/fix-asus-zenbook-a16-firmware.sh | \
      hardware/qualcomm/oem-firmware.sh | \
      hardware/qualcomm/firmware.sh | \
      hardware/qualcomm/camera.sh | \
      hardware/qualcomm/reboot-watchdog.sh | \
      hardware/qualcomm/powerprofiles-floor.sh | \
      hardware/lenovo/yoga-slim7x.sh | \
      hardware/lenovo/thinkpad-t14s-camera.sh | \
      hardware/lenovo/ideapad-slim-5x.sh | \
      hardware/microsoft/surface-pro-11.sh | \
      hardware/microsoft/surface-laptop-7.sh | \
      hardware/microsoft/surface-laptop8.sh | \
      hardware/samsung/galaxy-book4-edge-14.sh | \
      user/hardware/qualcomm/video-decode.sh)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

omarchy_skip_leaf() {
  local install_root="${OMARCHY_INSTALL:-}"
  [[ -n $install_root ]] || return 1
  local rel="${1#"${install_root%/}/"}"

  omarchy_is_aarch64_leaf "$rel" || return 1

  if [[ -z ${_omarchy_hw_is_aarch64:-} ]]; then
    if omarchy-hw-aarch64; then
      _omarchy_hw_is_aarch64=1
    else
      _omarchy_hw_is_aarch64=0
    fi
  fi

  (( ! _omarchy_hw_is_aarch64 ))
}

run_logged() {
  local script="$1"
  local exit_code errexit_was_set=0 ts

  if omarchy_skip_leaf "$script"; then
    return 0
  fi

  omarchy_log_timestamp ts
  omarchy_log_line "[$ts] Starting: $script"

  case $- in
    *e*)
      errexit_was_set=1
      set +e
      ;;
  esac

  local runner=(bash -eE)
  if [[ ${OMARCHY_INSTALL_DEBUG:-} == "1" ]]; then
    runner=(bash -x -eE)
  fi

  if omarchy_log_to_stdout; then
    PS4='+ ${BASH_SOURCE[0]##*/}:${LINENO}:${FUNCNAME[0]:-main}: ' \
      "${runner[@]}" -c 'source "$1"' bash "$script" </dev/null 2>&1
  else
    PS4='+ ${BASH_SOURCE[0]##*/}:${LINENO}:${FUNCNAME[0]:-main}: ' \
      "${runner[@]}" -c 'source "$1"' bash "$script" </dev/null >>"$OMARCHY_INSTALL_LOG_FILE" 2>&1
  fi

  exit_code=$?
  (( errexit_was_set )) && set -e

  omarchy_log_timestamp ts
  if (( exit_code == 0 )); then
    omarchy_log_line "[$ts] Completed: $script"
  else
    omarchy_log_line "[$ts] Failed: $script (exit code: $exit_code)"
  fi

  return $exit_code
}
