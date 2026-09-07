#!/usr/bin/env bash
# The derived read model. Sourced; do not run.
#
# snapshot_write derives everything from the ledger + reality (owned containers, the gateway's
# /v1/models, tailscale, installed agents) + recipes.json, and rewrites $SNAPSHOT. It never edits
# the ledger. Workers call it after every step so the panel, which watches the file, updates live;
# the panel also asks for one on a slow timer so a container that died outside an op shows up.
#
# State rule: busy while the op's pid is alive; else ready when an owned engine+gateway run and
# the gateway answers; else error when the ledger has one; else starting when they run but do
# not answer yet; else idle. Reality outranks the message: a model that answers is ready even
# when the last verb was refused (the error text still shows beside it).

snapshot_write() {
  state_dir
  # a ledger written by an older plugin carries the key under .share: scrub it once, here, where every path passes
  [[ -f $LEDGER ]] && jq -e 'has("share")' "$LEDGER" >/dev/null 2>&1 && lwrite 'del(.share)'
  local ledger match rec hw_id gpu reason state="" pid running_recipe="" served="" busy=false answering=false engine_up=false
  ledger=$(lread); match=$(match_hardware); hw_id=$(jq -r .hardwareId <<<"$match"); reason=$(jq -r .reason <<<"$match")
  rec=$(recipe_for "$hw_id"); [[ -n $rec ]] && rec=$(jq -c --argjson m "$match" '. + {gpuIndex:$m.gpu.index, match:{backend:$m.gpu.backend}}' <<<"$rec")
  pid=$(busy_pid); [[ -n $pid ]] && busy=true
  if owned "$ENGINE" && running "$ENGINE"; then engine_up=true; running_recipe=$(container_recipe "$ENGINE"); fi
  if $engine_up && owned "$GATEWAY" && running "$GATEWAY"; then
    served=$(api models 2 2>/dev/null | jq -r '.data[0].id // empty' || true); [[ -n $served ]] && answering=true
  fi
  if $busy; then state=$(jq -r .op.name <<<"$ledger")
  elif $answering; then state=ready
  elif [[ $(jq -r .error <<<"$ledger") != "" ]]; then state=error
  elif $engine_up; then state=starting
  else state=idle; fi
  # a running recipe that the vendored file no longer carries is still ours: say so instead of hiding it
  local running_known=true; [[ -n $running_recipe && $running_recipe != "$(jq -r '.id // ""' <<<"$rec")" ]] && running_known=false
  local downloaded=false; [[ -n $rec ]] && weights_present "$rec" && docker image inspect "$(jq -r .launch.image <<<"$rec")" >/dev/null 2>&1 && downloaded=true
  local gate=""; [[ -n $rec ]] && gate=$(gate_reason "$rec")
  local driver_min driver_have; driver_have=$(hardware_json | jq -r .driver); driver_min=$(jq -r '.minDriver // ""' <<<"${rec:-null}")
  [[ -n $rec && -z $gate ]] && ! driver_ok "$driver_have" "$driver_min" && gate="needs NVIDIA driver $driver_min or newer (have ${driver_have:-none})"
  jq -nc --argjson l "$ledger" --argjson rec "${rec:-null}" --argjson match "$match" --arg state "$state" --arg reason "$reason" --arg gate "$gate" \
    --arg hw "$hw_id" --arg served "$served" --arg rr "$running_recipe" --argjson known "$running_known" --argjson dl "$downloaded" \
    --argjson agents "$(agents_json)" --argjson share "$(share_state)" --arg reg "$(registry_commit)" --arg t "$(now)" '
    {schemaVersion:"omarchy-local-ai/snapshot/7", updatedAt:$t, state:$state, error:$l.error, lastStartSeconds:($l.lastStartSeconds//0),
     operation:{name:$l.op.name, detail:$l.op.detail, percent:$l.op.percent, startedAt:$l.op.startedAt,
       expectedSeconds:(if $l.op.name=="starting" then ($l.lastStartSeconds//0) else 0 end)},
     hardwareId:$hw, registry:$reg, gpus:$match.gpus, gpuPinned:$match.pinned,
     model:(if $rec==null then null else
       {recipeId:$rec.id, name:$rec.model.name, servedName:(if $served!="" then $served else $rec.model.servedName end),
        engine:$rec.engine, ctxTokens:$rec.serving.ctxTokens, tps:$rec.speed.tps, sizeGb:$rec.model.sizeGb, downloaded:$dl,
        endpoint:("http://127.0.0.1:"+($ENV.OMARCHY_AI_PORT // "12434")+"/v1")} end),
     reason:(if $gate!="" then ("recipe refused: "+$gate) elif $rec==null then $reason else "" end),
     running:(if $rr=="" then null else {recipeId:$rr, current:$known} end),
     apis:$l.accepted.apis, agents:$agents, share:$share}' >"$SNAPSHOT.tmp.$$" && mv "$SNAPSHOT.tmp.$$" "$SNAPSHOT"
}
