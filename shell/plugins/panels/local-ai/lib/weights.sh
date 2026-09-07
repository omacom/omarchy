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
download_weights() {
  local r=$1 id repo rev kind base exp bytes pct pid free img
  id=$(jq -r .id <<<"$r"); repo=$(jq -r .model.repository <<<"$r"); rev=$(jq -r .model.revision <<<"$r")
  exp=$(jq -r '((.model.sizeGb//0)*1073741824)|floor' <<<"$r"); img=$(jq -r .launch.image <<<"$r")
  read -r kind base < <(weights_dest "$r")
  mkdir_shared "$base"; state_dir; mkdir -p "$(dirname "$(marker_path "$id")")"
  free=$(df -Pk "$base" 2>/dev/null | awk 'NR==2{print $4*1024}')
  bytes=$(dir_bytes "$base")
  if (( exp > 0 && ${free:-0} > 0 && free < exp - bytes )); then
    oops "need $(( (exp-bytes+1073741823)/1073741824 )) GB free under $base"
  fi
  op download "$id" "downloading weights" 0
  # a GGUF recipe serves one file out of a repo full of quants: fetch only that file (and any mmproj)
  local served pattern=""; served=$(jq -r .model.servedName <<<"$r")
  [[ $served == *.gguf ]] && pattern="${served##*/}"
  local -a cmd
  if [[ -z ${OMARCHY_AI_NO_HOST_HF:-} ]] && hf=$(bin_of hf 2>/dev/null); then
    if [[ $kind == dir ]]; then cmd=("$hf" download "$repo" --revision "$rev" --local-dir "$base" ${pattern:+--include "$pattern" --include "*mmproj*"})
    else cmd=(env HF_HOME="$base" "$hf" download "$repo" --revision "$rev" ${pattern:+--include "$pattern" --include "*mmproj*"}); fi
  else
    local py="from huggingface_hub import snapshot_download as d; d('$repo', revision='$rev'"
    [[ -n $pattern ]] && py+=", allow_patterns=['$pattern', '*mmproj*']"
    if [[ $kind == dir ]]; then py+=", local_dir='/weights')"; else py+=")"; fi
    # HF_HOME must be writable for the hub cache and xet chunks: the mounted /hf in hub mode, /tmp in dir mode
    cmd=(docker run --rm --user "$(id -u):$(id -g)" --label "$LABEL.download=1" --network bridge
         --env HF_HOME="$([[ $kind == dir ]] && echo /tmp/hf || echo /hf)" --env HOME=/tmp
         ${HF_TOKEN:+--env HF_TOKEN}   # by name only: docker takes the value from this environment; it is never in argv or the log
         --volume "$base:$([[ $kind == dir ]] && echo /weights || echo /hf)"
         --entrypoint python3 "$img" -c "$py")
  fi
  log "download: ${cmd[*]}"
  spawn_child "${cmd[@]}" >>"$LOGFILE" 2>&1; pid=$!
  local prev=0 rate=0 eta=0 detail
  while kill -0 "$pid" 2>/dev/null; do
    bytes=$(dir_bytes "$base")
    if (( exp > 0 )); then
      pct=$(( bytes*100/exp )); (( pct > 100 )) && pct=100
      detail="$((bytes/1073741824)) / $((exp/1073741824)) GB"
      if (( POLL > 0 && bytes > prev && prev > 0 )); then   # a rate since the last poll gives an ETA
        rate=$(( (bytes - prev) / POLL )); eta=$(( (exp - bytes) / rate ))
        (( eta < 0 )) && eta=0; detail+=" · about $((eta/60))m$((eta%60))s left"
      fi
      op download "$id" "$detail" "$pct"
    fi
    prev=$bytes
    sleep "$POLL"
  done
  wait "$pid" || oops "weight download failed for $id (see $LOGFILE)"
  jq -nc --arg repo "$repo" --arg rev "$rev" --arg t "$(now)" --arg k "$kind" --arg b "$base" \
    '{repository:$repo,revision:$rev,completedAt:$t,kind:$k,path:$b}' >"$(marker_path "$id")"
  op download "$id" "weights complete" 100
}

ensure_image() { # pull once; the digest guarantees what we get
  local img=$1 id=$2
  docker image inspect "$img" >/dev/null 2>&1 && return 0
  op download "$id" "pulling image" 0
  run_child docker pull "$img" >>"$LOGFILE" 2>&1 || oops "image pull failed for $id (see $LOGFILE)"
}
