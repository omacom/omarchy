#!/usr/bin/env bash
# The vendored recipe file, the hardware match, and the safety gate. Sourced; do not run.

RECIPES="${OMARCHY_AI_RECIPES:-$HERE/../recipes.json}"

recipes_ok() { jq -e '.schemaVersion=="omarchy-local-ai/recipes/1" and (.hardware|type=="object")' "$RECIPES" >/dev/null 2>&1; }
registry_commit() { jq -r '.registryCommit' "$RECIPES"; }
gateway_image() { jq -r '.gateway.image // empty' "$RECIPES"; }

# match_hardware -> {"hardwareId":..,"gpu":{..},"reason":"..","gpus":[..]}
# gpus lists every card seen, each with its recipe's hardware id (or "") and whether it is the one
# in use, so the card can say what was detected and let the person choose. The default is the
# largest card that has a recipe (the tier map gives it the biggest model), ties by device order.
# `omarchy-local-ai gpu <backend:index>` pins a card; a pinned card without a recipe is still
# honoured, and the reason says so, because that is what the person asked to see.
GPU_PICK="$STATE/gpu"
gpu_pick() { printf '%s' "${OMARCHY_AI_GPU:-$(cat "$GPU_PICK" 2>/dev/null || true)}"; }
match_hardware() {
  local hw; hw=$(hardware_json)
  jq -c --argjson hw "$hw" --arg pick "$(gpu_pick)" '
    def norm: ascii_downcase|gsub("nvidia|geforce|intel|amd|radeon|generation|workstation|edition|[0-9]+gb|[^a-z0-9]";"");
    . as $file
    | [$hw.gpus | to_entries[] as $gi | $gi.value as $g
        | ([$file.hardware|to_entries[] as $e
            | select($g.backend==$e.value.match.backend)
            | select(($e.value.match.names|index($g.product|norm))!=null)
            | select(((($e.value.match.vramGb*1024)-$g.totalMiB)|fabs)<=1024)
            | $e.key] | .[0] // "") as $id
        | $g + {hardwareId:$id, key:($g.backend+":"+($g.index|tostring)), order:$gi.key,
                vramGb:(if $g.totalMiB==null then null else (($g.totalMiB/1024)+0.5|floor) end)}] as $gpus
    | ([$gpus[]|select(.key==$pick)]|.[0]) as $pinned
    | ([$gpus[]|select(.hardwareId!="")] | sort_by(-.totalMiB, .order) | .[0]) as $auto
    | ($pinned // $auto) as $use
    | {hardwareId:($use.hardwareId // ""),
       gpu:(if $use==null then null else ($use|del(.hardwareId,.key,.order,.vramGb,.chosen)) end),
       reason:(if $use!=null and $use.hardwareId!="" then ""
               elif ($gpus|length)==0 then "no supported GPU detected"
               else ("no validated recipe for "+(($use // $gpus[0]).product)+" yet") end),
       pinned:($pinned!=null),
       gpus:[$gpus[] | {key, backend, index, product, vramGb, hardwareId, chosen:(.key==($use.key // ""))}]}' "$RECIPES"
}

recipe_for() { jq -c --arg h "$1" '.hardware[$h].recipe // empty' "$RECIPES"; }

# gate_reason <recipe-json> -> one-line refusal on stdout; empty means launchable.
# Fail closed: anything malformed is refused. This is the trust boundary the marketplace reviewed.
gate_reason() {
  local r=$1 reason src tgt ro plug_root hf_root real
  plug_root=$(canon "$(dirname "$MODEL_ROOT")"); hf_root=$(canon "$HF_HOME_DIR")
  reason=$(jq -r '
    if (.launch.image|test("@sha256:[0-9a-f]{64}$")|not) then "image is not digest-pinned"
    elif (.model.revision|test("^[0-9a-f]{40,64}$")|not) then "model revision is not pinned"
    elif ((.launch.networkMode//"bridge")!="bridge") then "requires \(.launch.networkMode) networking"
    elif ((.launch.ipc//"")=="host") then "requires host IPC"
    elif ((.launch.capAdd//[])|length)>0 then "requires extra kernel capabilities"
    elif ((.launch.securityOpt//[])|length)>0 then "requires a weakened security profile"
    elif ((.launch.containerPort|type)!="number") then "invalid container port"
    elif ([.launch.arguments[]?|select(test("enforce.eager|disable.?cuda.?graph";"i"))]|length)>0 then "disallowed launch argument"
    elif ([.launch|..|strings|select(test("\\$\\{(?!MODEL_ROOT\\}|CACHE_ROOT\\})"))]|length)>0 then "needs an unsupported placeholder"
    else empty end' <<<"$r" 2>/dev/null) || { printf 'recipe data failed validation\n'; return; }
  [[ -z $reason ]] || { printf '%s\n' "$reason"; return; }
  while IFS=$'\t' read -r src tgt ro; do
    case $src in
      '${MODEL_ROOT}/'*|'${CACHE_ROOT}/'*)
        [[ $src != *..* ]] || { printf 'mounts unsafe host path %s\n' "$src"; return; }
        real=$(canon "$(expand_mount "$src")")
        [[ $real == "$plug_root"/* ]] || { printf 'mounts unsafe host path %s\n' "$src"; return; }
        [[ $src != '${MODEL_ROOT}/'* || $ro == true ]] || { printf 'model weights must be mounted read-only\n'; return; } ;;
      '~/.cache/huggingface'|'~/.cache/huggingface/'*)
        [[ $src != *..* ]] || { printf 'mounts unsafe host path %s\n' "$src"; return; }
        real=$(canon "$HOME_DIR/${src#\~/}")
        [[ $real == "$hf_root" || $real == "$hf_root"/* ]] || { printf 'mounts unsafe host path %s\n' "$src"; return; } ;;
      asset/*) [[ ${src#asset/} != *..* && ${src#asset/} != */* && -n ${src#asset/} ]] || { printf 'unsafe asset path %s\n' "$src"; return; }
        jq -e --arg f "${src#asset/}" '.assets[$f]|type=="string"' "$RECIPES" >/dev/null || { printf 'asset %s is not shipped\n' "$src"; return; } ;;
      /dev/dri/by-path) ;;
      *) printf 'mounts unsafe host path %s\n' "$src"; return ;;
    esac
  done < <(jq -r '.launch.mounts[]?|[.source,.target,(.read_only//false|tostring)]|@tsv' <<<"$r")
}

expand_mount() { local s=$1; s=${s//'${MODEL_ROOT}'/$MODEL_ROOT}; s=${s//'${CACHE_ROOT}'/$CACHE_ROOT}; printf '%s' "$s"; }
