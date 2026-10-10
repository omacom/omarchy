#!/bin/bash

source "$(dirname "$0")/base-test.sh"
source "$ROOT/test/acceptance.d/base-test.sh"

monitor_json='[
  {"name":"DP-1","x":1920,"y":0,"width":3840,"height":2160,"scale":2},
  {"name":"DP-2","x":-2560,"y":-1440,"width":2560,"height":1440,"scale":1},
  {"name":"DP-3","x":0,"y":1080,"width":1920,"height":1080,"scale":1,"transform":1}
]'
layer_json='{
  "DP-1":{"levels":{"2":[
    {"x":0,"y":0,"w":1920,"h":26,"namespace":"visible-positive-offset"},
    {"x":1920,"y":0,"w":26,"h":1080,"namespace":"parked-positive-offset"}
  ]}},
  "DP-2":{"levels":{"2":[
    {"x":0,"y":0,"w":2560,"h":26,"namespace":"visible-negative-offset"},
    {"x":-26,"y":0,"w":26,"h":1440,"namespace":"parked-negative-offset"}
  ]}},
  "DP-3":{"levels":{"2":[
    {"x":0,"y":1500,"w":26,"h":26,"namespace":"visible-rotated"},
    {"x":1080,"y":0,"w":26,"h":1920,"namespace":"parked-rotated"}
  ]}}
}'

hyprctl() {
  if [[ $2 == "monitors" ]]; then
    printf '%s\n' "$monitor_json"
  elif [[ $2 == "layers" ]]; then
    printf '%s\n' "$layer_json"
  else
    return 1
  fi
}

assert_layer_on_screen() {
  local namespace="$1" description="$2"

  layer_on_screen "$namespace" && pass "$description" || fail "$description"
}

assert_layer_off_screen() {
  local namespace="$1" description="$2"

  layer_off_screen "$namespace" && pass "$description" || fail "$description"
}

assert_layer_on_screen "visible-positive-offset" "visible layer is found on a positively offset monitor"
assert_layer_off_screen "parked-positive-offset" "right-parked layer stays off a positively offset monitor"
assert_layer_on_screen "visible-negative-offset" "visible layer is found on a negatively offset monitor"
assert_layer_off_screen "parked-negative-offset" "left-parked layer stays off a negatively offset monitor"
assert_layer_on_screen "visible-rotated" "visible layer uses the transformed monitor height"
assert_layer_off_screen "parked-rotated" "parked layer uses the transformed monitor width"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"
export OCR_FIXTURE_CALLS="$test_tmp/calls"
cat >"$test_tmp/bin/grim" <<'SH'
#!/bin/bash
printf 'capture:%s\n' "${@: -1}" >>"$OCR_FIXTURE_CALLS"
printf 'same captured pixels\n' >"${@: -1}"
SH
cat >"$test_tmp/bin/tesseract" <<'SH'
#!/bin/bash
[[ $(cat "$1") == "same captured pixels" ]] || exit 1
printf 'ocr:%s:%s\n' "$1" "${@: -1}" >>"$OCR_FIXTURE_CALLS"
if [[ $OCR_FIXTURE_MODE == "sparse" || $OCR_FIXTURE_MODE == "fallback" && ${@: -1} == 6 ]]; then
  printf 'Acceptance [literal].* caption\n'
else
  printf 'Wallpaper fragments\n'
fi
SH
chmod +x "$test_tmp/bin/"*
export PATH="$test_tmp/bin:$PATH"

export OCR_FIXTURE_MODE=sparse
: >"$OCR_FIXTURE_CALLS"
screen_contains 'Acceptance [literal].* caption' || fail "sparse OCR match remains sufficient"
mapfile -t calls <"$OCR_FIXTURE_CALLS"
[[ ${#calls[@]} == 2 && ${calls[1]} == *:11 ]] || fail "sparse OCR success does not retry or recapture"
snapshot=${calls[0]#capture:}
[[ ! -e $snapshot ]] || fail "sparse OCR cleans its captured image"
pass "sparse OCR match preserves literal text, one capture, and cleanup"

export OCR_FIXTURE_MODE=fallback
: >"$OCR_FIXTURE_CALLS"
screen_contains 'Acceptance [literal].* caption' || fail "block OCR can find a caption missed by sparse segmentation"
mapfile -t calls <"$OCR_FIXTURE_CALLS"
[[ ${#calls[@]} == 3 && ${calls[1]} == "ocr:$snapshot:11" && ${calls[2]} == "ocr:$snapshot:6" ]] || fail "OCR fallback reuses the same captured pixels"
[[ ! -e $snapshot ]] || fail "OCR fallback cleans its captured image"
pass "block OCR fallback reuses the original capture and preserves cleanup"

export OCR_FIXTURE_MODE=missing
: >"$OCR_FIXTURE_CALLS"
screen_contains 'Acceptance [literal].* caption' && fail "OCR without literal visible text must fail"
mapfile -t calls <"$OCR_FIXTURE_CALLS"
[[ ${#calls[@]} == 3 && ! -e $snapshot ]] || fail "failed OCR preserves one capture and cleanup"
pass "missing visible text still fails after both segmentation modes"
