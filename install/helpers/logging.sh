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

run_logged() {
  local script="$1"
  local exit_code errexit_was_set=0 ts

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
