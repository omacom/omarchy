#!/bin/bash
# CPU-only selection must depend on the ISA and must never acquire a GPU device.
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
export OMARCHY_PATH=$ROOT
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
sed '/^paths "\$HOME"$/,$d' "${BACKEND:-$ROOT/bin/omarchy-local-ai}" >"$TMP/functions"
source "$TMP/functions"
ALLOCATION_LOCK=$TMP/docker.pid
: >"$ALLOCATION_LOCK"
paths "$TMP/home"
mkdir -p "$STATE"
RECIPES=$TMP/recipes.json
CPUINFO=$TMP/cpuinfo
MEMINFO=$TMP/meminfo
printf 'flags : sse avx avx2\n' >"$CPUINFO"
printf 'MemTotal: 8388608 kB\nMemAvailable: 6291456 kB\n' >"$MEMINFO"
jq -n '{hardware:{cpu:{match:{backend:"cpu",names:["x8664avx2cpu"],vramGb:0},recipes:[{id:"cpu",name:"CPU model",image:("ghcr.io/test/cpu@sha256:"+("a"*64)),weights:[],launch:{entrypoint:"/app/llama-server",port:8080,shm:"1g",environment:{},arguments:["--n-gpu-layers","0"]}}]}},gateway:{image:("ghcr.io/test/gateway@sha256:"+("b"*64))}}' >"$RECIPES"
uname() { echo x86_64; }
nvidia() { :; }
intel() { :; }
amd() { echo '[]'; }
docker_ok() { return 1; }
gpus | jq -e 'length == 1 and .[0].key == "cpu:0" and .[0].hw == "cpu" and .[0].ramGb == 8 and .[0].held == false' >/dev/null
valid_key cpu:0 && ! valid_key cpu:1
echo 'ok - AVX2 CPU is selectable with host RAM and no VRAM requirement'
echo 'flags : sse' >"$CPUINFO"
[[ $(cpu) == '[]' ]]
echo 'ok - an incompatible CPU is not offered the AVX2 recipe'
echo 'flags : avx2' >"$CPUINFO"
owned() { :; }
remove() { :; }
docker() { printf '%s\n' "$*" >>"$TMP/docker.log"; }
phase_start cpu 12434 cpu:0 >"$TMP/start.log"
engine_args=$(grep '^run .*engine ' "$TMP/docker.log")
[[ -n $engine_args && $engine_args != *--device* && $engine_args != *--gpus* && $engine_args != *--group-add* && $engine_args != */dev/dri* ]]
echo 'ok - a CPU engine starts without GPU devices, GPU groups or driver setup'
