#!/usr/bin/env bash
# Docker on Omarchy's terms. Sourced; do not run.
#
# Omarchy keeps users out of the docker group on purpose (the group is root-equivalent) and reaches
# the daemon through a polkit prompt instead; it does not install the NVIDIA container toolkit. So:
#   - when this user can write the Docker socket (Omarchy's "sudoless Docker" is on), docker is
#     called directly, as before;
#   - otherwise every docker call of one action (Start, Stop, share) is batched into ONE `pkexec`
#     of this same script (`_root <phase>`): one password prompt, through Omarchy's own polkit
#     agent, the way `omarchy-launch-docker-tui` does it. polkit here is auth_admin without keep,
#     so per-call elevation would prompt a dozen times;
#   - the card's refresh never touches docker in that mode: state comes from the ledger and from
#     whether the gateway answers;
#   - a missing NVIDIA container runtime is set up inside the same prompt (pacman, nvidia-ctk,
#     restart docker).
# A root phase creates no file under the user's state (root-owned files there would lock the user
# out of their own plugin): it reads the recipe and assets, drives docker, and reports through
# stdout ("step …" progress, "reason …" on failure) and stderr, both owned by the user's worker.
# Root trusts nothing a user-owned file says about who the user is or where their files are: the
# uid comes from pkexec (PKEXEC_UID), every root is derived from that user's home, and the env file
# and recipe file are pinned by hashes on pkexec's own command line, which no other process can
# change once the prompt is up. A same-uid process swapping a file while the prompt is open gets
# "nothing was run", not a root container on paths of its choosing.

DOCKER_SOCKET="${OMARCHY_DOCKER_SOCKET:-/var/run/docker.sock}"
RUN_AS="${OMARCHY_AI_RUN_AS:-$(id -u):$(id -g)}"   # the uid the gateway and downloader run as, even when docker is driven by root

docker_direct() { # this process can drive docker without a prompt
  case ${OMARCHY_AI_DOCKER:-} in direct) return 0 ;; prompt) return 1 ;; esac
  [[ $(id -u) == 0 || -w $DOCKER_SOCKET ]]
}

root_env() { # the plugin's paths, handed to the root phase since pkexec starts from a clean environment
  printf '%s\n' "OMARCHY_AI_USER_HOME=$HOME_DIR" "OMARCHY_AI_STATE=$STATE" "OMARCHY_AI_MODEL_ROOT=$MODEL_ROOT" \
    "OMARCHY_AI_CACHE_ROOT=$CACHE_ROOT" "OMARCHY_AI_HF_HOME=$HF_HOME_DIR" "OMARCHY_AI_PORT=$PORT" "OMARCHY_AI_NETWORK=$NET" \
    "OMARCHY_AI_CONTAINER=$CTR" "OMARCHY_AI_RECIPES=$RECIPES" "OMARCHY_AI_RUN_AS=$RUN_AS" "OMARCHY_AI_POLL=$POLL" \
    "OMARCHY_AI_DOCKER=direct" "OMARCHY_AI_ROOT_PHASE=1"
  local f; for f in recipe gateway.recipe; do [[ -f $STATE/$f.json ]] && printf 'OMARCHY_AI_%s_SHA=%s\n' "$(tr a-z. A-Z_ <<<"$f")" "$(sha_of "$(cat "$STATE/$f.json")")"; done   # pins what a phase may read
  local v; for v in HF_TOKEN http_proxy https_proxy no_proxy HTTP_PROXY HTTPS_PROXY NO_PROXY; do   # gated downloads and proxies work behind the prompt too
    [[ -n ${!v:-} ]] && printf '%s=%s\n' "$v" "${!v}"; done; return 0
}
elevated() { # elevated <phase> [args]: always through pkexec (root is needed regardless of the socket)
  command -v pkexec >/dev/null 2>&1 || { printf 'reason this needs a password prompt, and pkexec is not installed\n'; return 1; }
  # the paths travel in a 0600 file this user writes, not on the command line: the prompt then reads
  # as this script and a verb ("omarchy-local-ai _root stop"), and root reads only OMARCHY_AI_* lines
  state_dir; root_env >"$STATE/root.env"
  local rc=0; pkexec "$SELF" _root "$STATE/root.env" "$(sha_of "$(cat "$STATE/root.env")")" "$@" 8>&- 9>&- || rc=$?   # the hash rides on argv; the op lock never reaches root
  (( rc == 126 || rc == 127 || rc >= 128 )) && printf 'reason the password prompt was dismissed; nothing was changed\n'   # polkit: 126 dismissed, 127 not authorized; 128+ the prompt was closed by a signal
  return $rc
}
privileged() { # privileged <phase> [args]: in-process when docker is direct, one pkexec otherwise
  if docker_direct; then "phase_$1" "${@:2}"; else elevated "$@"; fi
}

pinned_read() { # pinned_read <file> <sha or empty> -> the file's content, only if it is what the user's own process wrote
  local c; c=$(cat "$1") || return 1
  [[ -z ${2:-} || $(sha_of "$c") == "$2" ]] || { printf 'reason %s changed while the password prompt was open; nothing was run\n' "$(basename "$1")"; return 1; }
  printf '%s' "$c"
}

# ---------------------------------------------------------------- the phases (run as root in prompt mode)
toolkit_install() { # the NVIDIA container runtime, from Omarchy's own package manager
  echo "step setting up the NVIDIA container toolkit"
  pacman -S --noconfirm --needed nvidia-container-toolkit >&2 && nvidia-ctk runtime configure --runtime=docker >&2 && systemctl restart docker >&2
}
phase_toolkit() { toolkit_install || { printf 'reason the NVIDIA container toolkit could not be set up (see %s)\n' "$LOGFILE"; return 1; }; }

phase_start() { # phase_start <recipe-file> <download 0|1>: images, weights when asked, set aside, engine, gateway
  local r id why; r=$(pinned_read "$1" "${OMARCHY_AI_RECIPE_SHA:-}") || { printf '%s\n' "$r"; return 1; }; id=$(jq -r .id <<<"$r")
  # what root is about to run is re-checked here, not trusted from the user's file
  [[ $RUN_AS =~ ^[0-9]+:[0-9]+$ ]] || { printf 'reason internal: the user id did not reach the root phase\n'; return 1; }
  why=$(gate_reason "$r"); [[ -z $why ]] || { printf 'reason recipe refused: %s\n' "$why"; return 1; }
  echo "step checking docker"
  if ! why=$(docker_ok "$(jq -r .match.backend <<<"$r")"); then
    if [[ $why == *"NVIDIA container toolkit"* && -n ${OMARCHY_AI_ROOT_PHASE:-} ]]; then   # a root phase can set it up; the user side asks for one prompt instead
      toolkit_install || { printf 'reason %s\n' "$why"; return 1; }
      why=$(docker_ok "$(jq -r .match.backend <<<"$r")") || { printf 'reason %s\n' "$why"; return 1; }
    else printf 'reason %s\n' "$why"; return 1; fi
  fi
  echo "step pulling image"
  ensure_image "$(jq -r .launch.image <<<"$r")" "$id" || return 1
  ensure_image "$(gateway_image)" "$id" || return 1
  if [[ ${2:-0} == 1 ]]; then echo "step downloading weights"; download_run "$r" || return 1; fi
  echo "step setting aside the previous model"
  drop_previous
  set_aside || { printf 'reason could not set aside the running containers\n'; return 1; }
  echo "step starting"
  start_pair "$r" || { restore_previous || true; printf 'reason engine failed to start (see %s)\n' "$LOGFILE"; return 1; }   # the previous model comes back in this same prompt
}
phase_restore() { restore_previous || { printf 'reason the previous model could not be restored (see %s)\n' "$LOGFILE"; return 1; }; }
phase_stop() { stop_all || { printf 'reason the containers could not be removed (see %s)\n' "$LOGFILE"; return 1; }; }
phase_restart_gateway() { # phase_restart_gateway <recipe-file>: the gateway alone, with a fresh publish list
  local r; r=$(pinned_read "$1" "${OMARCHY_AI_GATEWAY_RECIPE_SHA:-}") || { printf '%s\n' "$r"; return 1; }
  exists "$GATEWAY" && owned "$GATEWAY" && docker rm -f "$GATEWAY" >/dev/null 2>&1
  start_gateway "$r" && return 0
  if [[ -f $SHARE_MARK ]]; then rm -f "$SHARE_MARK"; start_gateway "$r" >/dev/null 2>&1 || true; fi   # back to loopback in this same prompt
  printf 'reason the gateway did not start (see %s)\n' "$LOGFILE"; return 1
}

# The user's side of a phase: run it, keep the card current, collect the outcome.
# phase_run <name> <op-name> <recipe-id> [args] -> 0, or 1 with the reason in PHASE_REASON
phase_run() {
  local name=$1 opname=$2 id=$3; shift 3
  local out="$STATE/phase.out" pid step last="" bytes prev=0 rate eta pct detail base exp
  : >"$out"
  spawn_child privileged "$name" "$@" >"$out" 2>>"$LOGFILE"; pid=$!
  docker_direct || op "$opname" "$id" "waiting for your password" 0
  exp=${PHASE_EXPECT_BYTES:-0}; base=${PHASE_WEIGHTS_DIR:-}
  while kill -0 "$pid" 2>/dev/null; do
    step=$(grep '^step ' "$out" 2>/dev/null | tail -1 | cut -c6-)
    if [[ $step == "downloading weights" && -n $base && $exp -gt 0 ]]; then
      bytes=$(dir_bytes "$base"); pct=$(( bytes*100/exp )); (( pct > 100 )) && pct=100
      detail="$((bytes/1073741824)) / $((exp/1073741824)) GB"
      if (( POLL > 0 && bytes > prev && prev > 0 )); then rate=$(( (bytes - prev) / POLL )); eta=$(( (exp - bytes) / rate )); (( eta < 0 )) && eta=0; detail+=" · about $((eta/60))m$((eta%60))s left"; fi
      prev=$bytes; op download "$id" "$detail" "$pct"
    elif [[ -n $step && $step != "$last" ]]; then
      case $step in starting|"setting aside the previous model") op starting "$id" "$step" 0 ;; *) op download "$id" "$step" 0 ;; esac
    fi
    last=$step; sleep "$POLL"
  done
  if ! wait "$pid"; then
    PHASE_REASON=$(grep '^reason ' "$out" 2>/dev/null | tail -1 | cut -c8-)
    [[ -n $PHASE_REASON ]] || PHASE_REASON="$opname failed (see $LOGFILE)"
    return 1
  fi
}
