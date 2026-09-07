#!/usr/bin/env bash
# Containers: the engine and the gateway, acceptance, rollback. Sourced; do not run.
#
# Every Start is two owned containers on a private bridge network:
#   $CTR-engine    the recipe's image, its port never published
#   $CTR-gateway   the attested gateway, 127.0.0.1:$PORT -> the engine, key enforced
# Both carry io.omarchy.local-ai=1, .recipe, .registry, .role. Only labeled containers are ever
# touched. The previous pair is set aside on Start and restored if the new one fails acceptance.

ENGINE="$CTR-engine"; GATEWAY="$CTR-gateway"
owned() { [[ $(docker inspect -f "{{index .Config.Labels \"$LABEL\"}}" "$1" 2>/dev/null) == 1 ]]; }
exists() { docker inspect "$1" >/dev/null 2>&1; }
running() { [[ $(docker inspect -f '{{.State.Running}}' "$1" 2>/dev/null) == true ]]; }
container_recipe() { docker inspect -f "{{index .Config.Labels \"$LABEL.recipe\"}}" "$1" 2>/dev/null; }
ensure_network() { docker network inspect "$NET" >/dev/null 2>&1 || docker network create --label "$LABEL=1" "$NET" >/dev/null; }

# write_assets <recipe>: config files the recipe mounts, from recipes.json, into a plugin-owned dir
write_assets() {
  local r=$1 f; state_dir; mkdir_shared "$STATE/assets"   # the engine container reads these as its own uid
  while IFS= read -r f; do
    [[ -n $f ]] || continue
    (umask 022; jq -r --arg f "$f" '.assets[$f]' "$RECIPES" >"$STATE/assets/$f")
  done < <(jq -r '.launch.mounts[]?|.source|select(startswith("asset/"))|ltrimstr("asset/")' <<<"$r")
}

engine_argv() { # engine_argv <recipe> -> NUL-separated docker argv
  local r=$1 id backend src tgt mode v real
  id=$(jq -r .id <<<"$r"); backend=$(jq -r .match.backend <<<"$r")
  local -a a=(docker run --detach --name "$ENGINE" --restart unless-stopped --network "$NET" --network-alias engine
    --label "$LABEL=1" --label "$LABEL.recipe=$id" --label "$LABEL.registry=$(registry_commit)" --label "$LABEL.role=engine")
  if [[ $backend == nvidia ]]; then
    a+=(--gpus "device=$(jq -r .gpuIndex <<<"$r")")
  else # Intel: render nodes only, resolved per device; no card* control nodes, no whole /dev/dri
    local -a nodes=()
    for v in "${OMARCHY_AI_DRI_PATH:-/dev/dri/by-path}"/*-render; do [[ -e $v ]] || continue; real=$(canon "$v"); nodes+=(--device "$real:$real"); done
    ((${#nodes[@]})) || { fail "no render nodes found"; return 1; }
    a+=("${nodes[@]}" --volume /dev/dri/by-path:/dev/dri/by-path:ro)
  fi
  v=$(jq -r '.launch.shm//empty' <<<"$r"); [[ -n $v ]] && a+=(--shm-size "$v")
  while IFS=$'\t' read -r src tgt mode; do
    [[ -n $src && -n $tgt ]] || continue
    case $src in
      '${MODEL_ROOT}/'*|'${CACHE_ROOT}/'*) real=$(canon "$(expand_mount "$src")"); mkdir_shared "$real" ;;
      '~/.cache/huggingface'*) real=$(canon "$HOME_DIR/${src#\~/}"); mkdir_shared "$real" ;;
      asset/*) real="$STATE/assets/${src#asset/}"; mode=":ro" ;;
      /dev/dri/by-path) real=$src ;;
      *) fail "mount outside boundary: $src"; return 1 ;;
    esac
    a+=(--volume "$real:$tgt$mode")
  done < <(jq -r '.launch.mounts[]?|[.source,.target,(if .read_only then ":ro" else "" end)]|@tsv' <<<"$r")
  while IFS= read -r v; do a+=(--env "$v"); done < <(jq -r '.launch.environment|to_entries[]?|"\(.key)=\(.value)"' <<<"$r")
  v=$(jq -r '.launch.entrypoint//empty' <<<"$r"); [[ -n $v ]] && a+=(--entrypoint "$v")
  a+=("$(jq -r .launch.image <<<"$r")")
  while IFS= read -r v; do a+=("$v"); done < <(jq -r '.launch.arguments[]?' <<<"$r")
  printf '%s\0' "${a[@]}"
}

gateway_argv() { # gateway_argv <recipe>
  local r=$1 img; img=$(gateway_image); [[ -n $img ]] || { fail "recipes.json has no gateway image"; return 1; }
  # as this user: the image's own uid (10001) cannot read the 0600 key file, and a gateway that
  # cannot read its key silently serves keyless. Port 12434 needs no root.
  printf '%s\0' docker run --detach --name "$GATEWAY" --restart unless-stopped --network "$NET" \
    --user "$(id -u):$(id -g)" --publish "127.0.0.1:$PORT:12434" --label "$LABEL=1" --label "$LABEL.recipe=$(jq -r .id <<<"$r")" \
    --label "$LABEL.registry=$(registry_commit)" --label "$LABEL.role=gateway"
  share_publish_argv   # the tailnet address too, while sharing is on
  printf '%s\0' --env "UPSTREAM=http://engine:$(jq -r .launch.containerPort <<<"$r")" --env "MODEL=$(jq -r .model.servedName <<<"$r")" \
    --env GATEWAY_KEY_FILE=/run/gateway.key --volume "$KEY_FILE:/run/gateway.key:ro" "$img"
}
# argv builders run in a subshell and can fail halfway (a mount root that cannot be made, a recipe
# field missing); a process substitution would hand docker the truncated half. Build into a file
# and check the builder's own status first.
read_argv() { # read_argv <builder> <recipe> -> ARGV (no namerefs: the suite runs on bash 3.2 too)
  local f; f=$(mktemp "$STATE/argv.XXXXXX") || return 1
  if ! "$1" "$2" >"$f"; then rm -f "$f"; return 1; fi
  ARGV=(); local v; while IFS= read -r -d '' v; do ARGV+=("$v"); done <"$f"; rm -f "$f"
  ((${#ARGV[@]}))
}
start_gateway() { # start_gateway <recipe>; remembers the recipe so the gateway can be restarted alone
  local r=$1; local -a argv=()
  read_argv gateway_argv "$r" || { fail "could not build the gateway command"; return 1; }; argv=("${ARGV[@]}")
  printf '%s\n' "$r" >"$STATE/gateway.recipe.json"
  log "gateway: ${argv[*]}"
  run_child "${argv[@]}" >>"$LOGFILE" 2>&1
}
restart_gateway() { # same recipe, fresh publish list (share on/off); the engine is untouched
  local r; r=$(cat "$STATE/gateway.recipe.json" 2>/dev/null || true)
  if [[ -z $r ]]; then # started before this file existed: the machine's recipe, if it is the one running
    r=$(current_recipe 2>/dev/null) || r=""
    [[ -n $r && $(jq -r .id <<<"$r") == "$(container_recipe "$GATEWAY")" ]] || { fail "no gateway to restart"; return 1; }
  fi
  exists "$GATEWAY" && owned "$GATEWAY" && docker rm -f "$GATEWAY" >/dev/null 2>&1
  start_gateway "$r" || return 1
  local i; for ((i=0; i<15; i++)); do api models 2 >/dev/null 2>&1 && return 0; sleep "${POLL:-1}"; done
  api models 2 >/dev/null 2>&1
}

# The bearer header travels to curl as a file (`-H @file`, 0600), never as an argument: argv is
# readable by every local account through /proc/<pid>/cmdline while the request runs.
AUTH_FILE="$STATE/gateway.auth"
auth_file() { # -> path of a 0600 file holding the Authorization header for the current key
  local want; want="Authorization: Bearer $(cat "$KEY_FILE")"
  [[ -f $AUTH_FILE && $(cat "$AUTH_FILE") == "$want" ]] || { state_dir; printf '%s\n' "$want" >"$AUTH_FILE.tmp.$$" && mv "$AUTH_FILE.tmp.$$" "$AUTH_FILE"; }
  printf '%s' "$AUTH_FILE"
}
api() { curl -fsS --max-time "${2:-30}" --max-filesize 1048576 -H "@$(auth_file)" "http://127.0.0.1:$PORT/v1/$1"; }
post() { curl -fsS --max-time 600 --max-filesize 4194304 -H 'Content-Type: application/json' -H "@$(auth_file)" -d "$2" "http://127.0.0.1:$PORT/v1/$1"; }

# accept <recipe>: the model is what the recipe says, all three dialects answer through the gateway,
# a tool call works when the recipe claims tools, and decode speed is not a CPU fallback.
accept() {
  local r=$1 id want served reply deadline=$((SECONDS+TIMEOUT)) t0 t1 toks tps floor apis='[]'
  id=$(jq -r .id <<<"$r"); want=$(jq -r .model.servedName <<<"$r")
  while :; do
    served=$(api models 5 2>/dev/null | jq -r '.data[0].id // empty' || true)
    [[ -n $served ]] && break
    (( SECONDS < deadline )) || { fail "engine did not answer within ${TIMEOUT}s"; return 1; }
    running "$ENGINE" || { fail "engine exited during startup (docker logs $ENGINE)"; return 1; }
    op starting "$id" "loading the model" "$(start_percent)"; sleep "$POLL"
  done
  [[ $served == "$want" || $want == */* && $served == *"${want##*/}"* ]] || { fail "served model $served is not $want"; return 1; }
  # a gateway that cannot read its key file serves keyless without a word; sharing that on a
  # tailnet is the one thing this plugin must never do, so an unkeyed request has to be refused
  if curl -fsS --max-time 10 --max-filesize 1048576 "http://127.0.0.1:$PORT/v1/models" >/dev/null 2>&1; then
    fail "gateway answers without the key (docker logs $GATEWAY)"; return 1
  fi
  op starting "$id" "chat acceptance" 0
  reply=$(post chat/completions "$(jq -nc --arg m "$served" '{model:$m,stream:false,messages:[{role:"user",content:"Reply with exactly: LOCAL_AI_READY"}]}')") || { fail "chat completion failed"; return 1; }
  jq -e '[(.choices[0].message.content//""),(.choices[0].message.reasoning_content//"")]|join(" ")|contains("LOCAL_AI_READY")' >/dev/null <<<"$reply" || { fail "chat acceptance failed"; return 1; }
  # decode speed, coarsely: this exists to catch a CPU fallback (one or two tok/s), not to benchmark.
  # Engines do not all report usage (TabbyAPI does not), so tokens fall back to words written,
  # thinking included, at 1.3 tokens a word. Two runs, the better counts: the first is cold. The
  # floor is a tenth of the validated speed, never under 3.
  op starting "$id" "speed check" 0
  local best=0 i
  for i in 1 2; do
    t0=$(date +%s%N)
    reply=$(post chat/completions "$(jq -nc --arg m "$served" '{model:$m,stream:false,max_tokens:160,messages:[{role:"user",content:"Count from 1 to 80 separated by single spaces. Write nothing else."}]}')") || { fail "speed check request failed"; return 1; }
    t1=$(date +%s%N)
    toks=$(jq -r '.usage.completion_tokens // 0' <<<"$reply")
    (( toks > 0 )) || toks=$(jq -r '[(.choices[0].message.content//""),(.choices[0].message.reasoning_content//"")]|join(" ")|[splits("\\s+")|select(length>0)]|length|.*1.3|floor' <<<"$reply")
    tps=$(( toks * 1000000000 / (t1 - t0 + 1) )); (( tps > best )) && best=$tps
  done
  tps=$best
  floor=$(jq -r '[3, ((.speed.tps//0)/10|floor)]|max' <<<"$r")
  (( toks < 16 || tps >= floor )) || { fail "decode ${tps} tok/s is below the ${floor} tok/s floor: the GPU is not being used (driver too old for this image?)"; return 1; }
  apis='["chat"]'
  op starting "$id" "messages acceptance" 0
  # the shapes agents really send: a system prompt plus a prior turn (Messages), instructions plus a
  # developer item after the user (Responses); a template that refuses a late system message fails here
  reply=$(post messages "$(jq -nc --arg m "$served" '{model:$m,max_tokens:2048,system:"You are a terse assistant.",messages:[{role:"user",content:"hi"},{role:"assistant",content:"hello"},{role:"user",content:"Reply with exactly: LOCAL_AI_READY"}]}')") \
    && jq -e '[.content[]?|select(.type=="text")|.text]|join(" ")|contains("LOCAL_AI_READY")' >/dev/null <<<"$reply" && apis=$(jq -c '.+["messages"]' <<<"$apis")
  op starting "$id" "responses acceptance" 0
  reply=$(post responses "$(jq -nc --arg m "$served" '{model:$m,instructions:"You are a terse assistant.",input:[{type:"message",role:"user",content:"Reply with exactly: LOCAL_AI_READY"},{type:"message",role:"developer",content:"Reply with the exact token requested."}]}')") \
    && jq -e '[.output[]?|select(.type=="message")|.content[]?|.text]|join(" ")|contains("LOCAL_AI_READY")' >/dev/null <<<"$reply" && apis=$(jq -c '.+["responses"]' <<<"$apis")
  if [[ $(jq -r '.capabilities.tools//false' <<<"$r") == true ]]; then
    op starting "$id" "tool-call acceptance" 0
    # the schema carries a regex pattern with an escape llama.cpp's grammar cannot take and a format hint,
    # as Claude Code's tools do: the gateway must scrub them or this fails here rather than in the agent
    local tools='[{"type":"function","function":{"name":"shell","description":"Run a shell command","parameters":{"type":"object","properties":{"command":{"type":"string","pattern":"^[A-Za-z0-9 _\\\\-.~:@+]+$"},"cwd":{"type":"string","format":"uri"}},"required":["command"]}}}]'
    reply=$(post chat/completions "$(jq -nc --arg m "$served" --argjson t "$tools" '{model:$m,stream:false,tools:$t,tool_choice:"auto",messages:[{role:"user",content:"Use the shell tool to run: echo LOCAL_AI_TOOL_OK"}]}')") || { fail "tool-call request failed"; return 1; }
    jq -e '[(.choices[0].message.tool_calls//[])[]|select(.function.name=="shell" and ((.function.arguments//"")|contains("LOCAL_AI_TOOL_OK")))]|length>0' >/dev/null <<<"$reply" || { fail "tool-call acceptance failed"; return 1; }
  fi
  lwrite '.accepted={recipeId:$r,servedModel:$s,registry:$g,apis:$a}' --arg r "$id" --arg s "$served" --arg g "$(registry_commit)" --argjson a "$apis"
  log "accepted $id served=$served tps=$tps apis=$apis"
}

# start_percent: elapsed share of the last successful Start, capped so it never claims done.
# A first Start has no history and stays at 0; the panel shows elapsed time either way.
start_percent() {
  local last t0 now; last=$(lread | jq -r '.lastStartSeconds // 0'); t0=$(lread | jq -r '.op.startedAt // ""')
  (( last > 0 )) && [[ -n $t0 ]] || { printf 0; return; }
  now=$(( $(date -u +%s) - $(date -u -d "$t0" +%s 2>/dev/null || date -u -j -f %Y-%m-%dT%H:%M:%SZ "$t0" +%s 2>/dev/null || echo 0) ))
  (( now < 0 )) && now=0; now=$(( now * 100 / last )); (( now > 95 )) && now=95; printf '%s' "$now"
}

set_aside() { # current pair -> *-previous (removing any older previous)
  local c
  for c in "$ENGINE" "$GATEWAY"; do
    exists "$c" || continue
    owned "$c" || { fail "$c exists but is not managed by this plugin"; return 1; }
    if exists "$c-previous"; then owned "$c-previous" || { fail "$c-previous is not managed by this plugin"; return 1; }; docker rm -f "$c-previous" >/dev/null 2>&1; fi
    running "$c" && docker stop "$c" >/dev/null 2>&1
    docker rename "$c" "$c-previous" >/dev/null || { fail "could not set aside $c"; return 1; }
  done
}
restore_previous() {
  local c
  for c in "$ENGINE" "$GATEWAY"; do
    exists "$c" && owned "$c" && docker rm -f "$c" >/dev/null 2>&1
    exists "$c-previous" && owned "$c-previous" && { docker rename "$c-previous" "$c" >/dev/null 2>&1; docker start "$c" >/dev/null 2>&1; }
  done
  return 0
}
drop_previous() { local c; for c in "$ENGINE" "$GATEWAY"; do exists "$c-previous" && owned "$c-previous" && docker rm -f "$c-previous" >/dev/null 2>&1; done; return 0; }
stop_all() { local c; for c in "$ENGINE" "$GATEWAY" "$ENGINE-previous" "$GATEWAY-previous"; do exists "$c" && owned "$c" && docker rm -f "$c" >/dev/null 2>&1; done; return 0; }

start_pair() { # start_pair <recipe>: engine then gateway; returns non-zero on any failure
  local r=$1; local -a argv=()
  ensure_network; ensure_key; write_assets "$r"
  read_argv engine_argv "$r" || { fail "could not build the engine command (see $LOGFILE)"; return 1; }; argv=("${ARGV[@]}")
  log "engine: ${argv[*]}"
  run_child "${argv[@]}" >>"$LOGFILE" 2>&1 || return 1
  start_gateway "$r" || return 1
}
