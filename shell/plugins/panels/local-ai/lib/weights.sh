#!/usr/bin/env bash
# Weights: the plugin downloads, containers only read. Sourced; do not run.
#
# Two mount kinds decide where a download goes:
#   ${MODEL_ROOT}/<dir>      -> $MODEL_ROOT/<dir>/<weights.subdir>   (local-dir layout, read-only in the container)
#   ~/.cache/huggingface     -> the shared HF cache                    (hub layout; the engine resolves repo@revision)
# A marker written after a verified download is the presence check; it carries the revision,
# so a revision bump re-downloads and a hand-placed copy is picked up by the idempotent download.

weights_dest() { # weights_dest <recipe> -> "dir\t<path>" or "hf\t<hf-home>"
  local r=$1 src tgt sub; sub=$(jq -r '.weights.subdir // ""' <<<"$r")
  while IFS=$'\t' read -r src tgt; do
    case $src in
      '${MODEL_ROOT}/'*) printf 'dir\t%s\n' "$(expand_mount "$src")${sub:+/$sub}"; return ;;
    esac
  done < <(jq -r '.launch.mounts[]?|[.source,.target]|@tsv' <<<"$r")
  printf 'hf\t%s\n' "$HF_HOME_DIR"
}
marker_path() { printf '%s/weights/%s.json\n' "$STATE" "$1"; }
weights_present() { # weights_present <recipe> : marker matches repository+revision
  local r=$1 m; m=$(marker_path "$(jq -r .id <<<"$r")")
  [[ -f $m ]] && jq -e --arg repo "$(jq -r .model.repository <<<"$r")" --arg rev "$(jq -r .model.revision <<<"$r")" \
    '.repository==$repo and .revision==$rev' "$m" >/dev/null 2>&1
}
dir_bytes() { [[ -d $1 ]] && du -skL "$1" 2>/dev/null | awk '{print $1*1024}' || printf 0; }

# download_weights <recipe>: host `hf` when present, else the recipe's own image, which always carries
# huggingface_hub because the engine loads from the Hub. Progress is reported through op().
# mount_dirs <recipe>: the host directories the recipe mounts, made before any container (as this user, shared)
mount_dirs() {
  local r=$1 src tgt real
  while IFS=$'\t' read -r src tgt; do
    case $src in
      '${MODEL_ROOT}/'*|'${CACHE_ROOT}/'*) real=$(canon "$(expand_mount "$src")"); mkdir_shared "$real" ;;
      '~/.cache/huggingface'*) real=$(canon "$HOME_DIR/${src#\~/}"); mkdir_shared "$real" ;;
    esac
  done < <(jq -r '.launch.mounts[]?|[.source,.target]|@tsv' <<<"$r")
}
weights_plan() { # weights_plan <recipe>: sets WKIND WBASE WEXP WPATTERN, makes the base dir, checks free space
  local r=$1 served
  WEXP=$(jq -r '((.model.sizeGb//0)*1073741824)|floor' <<<"$r")
  read -r WKIND WBASE < <(weights_dest "$r")
  mkdir_shared "$WBASE"; state_dir; mkdir -p "$(dirname "$(marker_path "$(jq -r .id <<<"$r")")")"
  local free bytes; free=$(df -Pk "$WBASE" 2>/dev/null | awk 'NR==2{print $4*1024}'); bytes=$(dir_bytes "$WBASE")
  if (( WEXP > 0 && ${free:-0} > 0 && free < WEXP - bytes )); then fail "need $(( (WEXP-bytes+1073741823)/1073741824 )) GB free under $WBASE"; return 1; fi
  # a GGUF recipe serves one file out of a repo full of quants: fetch only that file (and any mmproj)
  WPATTERN=""; served=$(jq -r .model.servedName <<<"$r"); [[ $served == *.gguf ]] && WPATTERN="${served##*/}"
  return 0
}
weights_mark() { # weights_mark <recipe>: the completion marker, written by this user after a verified download
  local r=$1
  jq -nc --arg repo "$(jq -r .model.repository <<<"$r")" --arg rev "$(jq -r .model.revision <<<"$r")" --arg t "$(now)" --arg k "$WKIND" --arg b "$WBASE" \
    '{repository:$repo,revision:$rev,completedAt:$t,kind:$k,path:$b}' >"$(marker_path "$(jq -r .id <<<"$r")")"
}
host_hf() { [[ -z ${OMARCHY_AI_NO_HOST_HF:-} ]] && bin_of hf 2>/dev/null; }

# download_host <recipe>: the host `hf` tool, as this user, with progress on the card. No docker.
download_host() {
  local r=$1 id hf repo rev pid bytes pct prev=0 rate eta detail
  id=$(jq -r .id <<<"$r"); repo=$(jq -r .model.repository <<<"$r"); rev=$(jq -r .model.revision <<<"$r"); hf=$(host_hf)
  local -a cmd
  if [[ $WKIND == dir ]]; then cmd=("$hf" download "$repo" --revision "$rev" --local-dir "$WBASE" ${WPATTERN:+--include "$WPATTERN" --include "*mmproj*"})
  else cmd=(env HF_HOME="$WBASE" "$hf" download "$repo" --revision "$rev" ${WPATTERN:+--include "$WPATTERN" --include "*mmproj*"}); fi
  op download "$id" "downloading weights" 0; log "download: ${cmd[*]}"
  spawn_child "${cmd[@]}" >>"$LOGFILE" 2>&1; pid=$!
  while kill -0 "$pid" 2>/dev/null; do
    bytes=$(dir_bytes "$WBASE")
    if (( WEXP > 0 )); then
      pct=$(( bytes*100/WEXP )); (( pct > 100 )) && pct=100
      detail="$((bytes/1073741824)) / $((WEXP/1073741824)) GB"
      if (( POLL > 0 && bytes > prev && prev > 0 )); then rate=$(( (bytes - prev) / POLL )); eta=$(( (WEXP - bytes) / rate )); (( eta < 0 )) && eta=0; detail+=" · about $((eta/60))m$((eta%60))s left"; fi
      op download "$id" "$detail" "$pct"
    fi
    prev=$bytes; sleep "$POLL"
  done
  wait "$pid" || { fail "weight download failed for $id (see $LOGFILE)"; return 1; }
}

# download_run <recipe>: the recipe's own image downloads the weights (it always carries huggingface_hub);
# runs inside a phase, blocking; the user's side reports progress from the directory's size.
download_run() {
  local r=$1 id repo rev img err
  id=$(jq -r .id <<<"$r"); repo=$(jq -r .model.repository <<<"$r"); rev=$(jq -r .model.revision <<<"$r"); img=$(jq -r .launch.image <<<"$r")
  weights_dest_vars "$r"
  local py="from huggingface_hub import snapshot_download as d; d('$repo', revision='$rev'"
  [[ -n $WPATTERN ]] && py+=", allow_patterns=['$WPATTERN', '*mmproj*']"
  if [[ $WKIND == dir ]]; then py+=", local_dir='/weights')"; else py+=")"; fi
  # HF_HOME must be writable for the hub cache and xet chunks: the mounted /hf in hub mode, /tmp in dir mode
  local -a cmd=(docker run --rm --user "$RUN_AS" --label "$LABEL.download=1" --network bridge
       --env HF_HOME="$([[ $WKIND == dir ]] && echo /tmp/hf || echo /hf)" --env HOME=/tmp
       ${HF_TOKEN:+--env HF_TOKEN}
       --volume "$WBASE:$([[ $WKIND == dir ]] && echo /weights || echo /hf)"
       --entrypoint python3 "$img" -c "$py")
  log "download: ${cmd[*]}"
  err=$(mktemp)
  if ! run_child "${cmd[@]}" >&2 2>"$err"; then printf 'reason %s\n' "$(docker_reason "$err" "weight download for $id")"; rm -f "$err"; return 1; fi
  rm -f "$err"
}
weights_dest_vars() { # the plan's variables from the recipe alone (a phase has no user-side state)
  local r=$1 served
  read -r WKIND WBASE < <(weights_dest "$r")
  WPATTERN=""; served=$(jq -r .model.servedName <<<"$r"); [[ $served == *.gguf ]] && WPATTERN="${served##*/}"
}

# docker_reason <stderr-file> <what>: docker's own last line, turned into the sentence a person can act on.
# The card has three lines; the fix comes first, the raw line goes to the log.
docker_reason() {
  local last; last=$(grep -v '^\s*$' "$1" 2>/dev/null | tail -1 | cut -c1-200)
  log "$2: ${last:-no output from docker}"
  case $last in
    *permission\ denied*docker.sock*|*permission\ denied*Docker\ daemon*) printf 'Docker refuses your user: sudo usermod -aG docker $USER, then log out and in' ;;
    *could\ not\ select\ device\ driver*|*nvidia-container*|*unknown\ or\ invalid\ runtime*) printf 'the NVIDIA container toolkit is not set up: sudo pacman -S nvidia-container-toolkit; sudo nvidia-ctk runtime configure --runtime=docker; sudo systemctl restart docker' ;;
    *Cannot\ connect\ to\ the\ Docker\ daemon*|*Is\ the\ docker\ daemon\ running*) printf 'Docker is not running: sudo systemctl enable --now docker' ;;
    *no\ space\ left*|*No\ space\ left*) printf 'out of disk space for %s' "$2" ;;
    *unauthorized*|*denied:*|*authentication\ required*) printf 'the registry refused the pull: run docker logout ghcr.io and try again' ;;
    *TLS\ handshake*|*no\ such\ host*|*i/o\ timeout*|*dial\ tcp*|*connection\ refused*|*network\ is\ unreachable*) printf 'no route to the image registry: check the network and try again' ;;
    *manifest\ unknown*|*not\ found*) printf 'the pinned image is missing from the registry: report this' ;;
    "") printf '%s failed (see %s)' "$2" "$LOGFILE" ;;
    *) printf '%s failed: %s' "$2" "$(cut -c1-90 <<<"$last")" ;;
  esac
}
docker_ok() { # docker_ok [nvidia]: the daemon answers this process, and the NVIDIA runtime is there when the recipe needs it
  local info err; info=$(mktemp); err=$(mktemp)
  docker info >"$info" 2>"$err" || { docker_reason "$err" "docker"; rm -f "$info" "$err"; return 1; }
  if [[ ${1:-} == nvidia ]] && ! grep -qi 'nvidia' "$info"; then rm -f "$info" "$err"
    printf 'the NVIDIA container toolkit is not set up: sudo pacman -S nvidia-container-toolkit; sudo nvidia-ctk runtime configure --runtime=docker; sudo systemctl restart docker'
    return 1
  fi
  rm -f "$info" "$err"
}
ensure_image() { # pull once; the digest guarantees what we get. Phase-safe: no state files, reason on stdout.
  local img=$1 id=$2 err
  docker image inspect "$img" >/dev/null 2>&1 && return 0
  err=$(mktemp)
  if ! run_child docker pull "$img" >&2 2>"$err"; then printf 'reason %s\n' "$(docker_reason "$err" "image pull for $id")"; rm -f "$err"; return 1; fi
  rm -f "$err"
}
