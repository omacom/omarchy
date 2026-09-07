#!/usr/bin/env bash
# Live GPU inventory and driver. Sourced; do not run.
# Output shape: {"gpus":[{backend,index,product,totalMiB,usedMiB,freeMiB}],"driver":"580.65.06"}

hardware_json() {
  [[ -n ${OMARCHY_AI_HARDWARE_JSON:-} ]] && { jq -c . <<<"$OMARCHY_AI_HARDWARE_JSON"; return; }
  local rows='' nvidia='[]' driver=''
  if command -v nvidia-smi >/dev/null 2>&1; then
    rows=$(nvidia-smi --query-gpu=index,name,memory.total,memory.used,memory.free --format=csv,noheader,nounits 2>/dev/null || true)
    driver=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -1 | tr -d ' ' || true)
  fi
  [[ -n $rows ]] && nvidia=$(jq -Rsc 'split("\n")|map(select(length>0)|split(",")|map(gsub("^ +| +$";"")))
    |map({backend:"nvidia",index:(.[0]|tonumber),product:.[1],totalMiB:(.[2]|tonumber),usedMiB:(.[3]|tonumber),freeMiB:(.[4]|tonumber)})' <<<"$rows")
  jq -nc --argjson n "$nvidia" --argjson i "$(intel_gpus)" --arg d "$driver" '{gpus:($n+$i),driver:$d}'
}

intel_gpus() { # Intel Arc Pro B70 by PCI id, only when a render node exists for it
  command -v lspci >/dev/null 2>&1 || { printf '[]'; return; }
  local dri="${OMARCHY_AI_DRI_PATH:-/dev/dri/by-path}" a idx=0 out='[]'
  while IFS= read -r a; do
    [[ -n $a && -e "$dri/pci-$a-render" ]] || continue
    out=$(jq -c --argjson i "$idx" '.+[{backend:"intel-xpu",index:$i,product:"Intel Arc Pro B70",totalMiB:32768,usedMiB:null,freeMiB:null}]' <<<"$out")
    idx=$((idx+1))
  done < <(lspci -Dnn 2>/dev/null | grep -i 'Arc Pro B70' | awk '{print $1}')
  printf '%s' "$out"
}

# normalize a product name the way the registry export does, so a match is a string compare
norm() { tr '[:upper:]' '[:lower:]' <<<"$1" | sed -E 's/nvidia|geforce|intel|amd|radeon|generation|workstation|edition|[0-9]+gb|[^a-z0-9]//g'; }

driver_ok() { # driver_ok <have> <min>  (dotted versions; empty min means no requirement)
  [[ -z $2 ]] && return 0
  [[ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" == "$2" ]]
}
