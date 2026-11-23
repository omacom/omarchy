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
export OMARCHY_CAPTURE_TEST_DIR="$test_tmp"
export ARTIFACTS="$test_tmp/artifacts"
mkdir -p "$ARTIFACTS"

cat >"$test_tmp/bin/grim" <<'SH'
#!/bin/bash
if [[ -e $OMARCHY_CAPTURE_TEST_DIR/fail ]]; then
  exit 7
fi
if [[ -e $OMARCHY_CAPTURE_TEST_DIR/fail-once ]]; then
  rm "$OMARCHY_CAPTURE_TEST_DIR/fail-once"
  exit 7
fi
touch "${@: -1}"
SH
cat >"$test_tmp/bin/tesseract" <<'SH'
#!/bin/bash
touch "$OMARCHY_CAPTURE_TEST_DIR/ocr-ran"
printf '%s\n' 'Visible text'
SH
chmod +x "$test_tmp/bin/"*
export PATH="$test_tmp/bin:$PATH"

touch "$test_tmp/fail"
status=0
output=$(screen_contains "Visible text" 2>&1) || status=$?
[[ $status == 2 && $output == *"screen capture failed (grim exit 7)"* && ! -e $test_tmp/ocr-ran ]] ||
  fail "capture failure is distinct from absent content and does not run OCR" "$output"
pass "capture failure is distinct from absent content and does not run OCR"

status=0
output=$(screenshot "broken" 2>&1) || status=$?
[[ $status == 7 && $output == *"could not capture screenshot"* && ! -e $ARTIFACTS/broken.png ]] ||
  fail "diagnostic screenshot failure is reported" "$output"
pass "diagnostic screenshot failure is reported"

status=0
output=$(wait_until "OCR content" 0 screen_contains "Visible text" 2>&1) || status=$?
[[ $status == 1 && $output == *"screen capture failed (grim exit 7)"* && $output == *"not ok - OCR content"* ]] ||
  fail "polling timeout retains the capture failure diagnostic" "$output"
pass "polling timeout retains the capture failure diagnostic"

rm "$test_tmp/fail"
status=0
output=$(screen_contains "Absent text" 2>&1) || status=$?
[[ $status == 1 && -z $output ]] || fail "missing OCR content remains an ordinary mismatch" "$output"
pass "missing OCR content remains an ordinary mismatch"

touch "$test_tmp/fail-once"
wait_until "transient capture failure is retried" 3 screen_contains "Visible text"
[[ -z $(find "$ARTIFACTS" -name 'wait.*.log' -print -quit) ]] || fail "polling cleans its temporary log"
pass "polling cleans its temporary log"

# Exercise the real callers in the conditional context used by their runners.
source <(sed -n '/^launch_and_verify() {$/,/^}$/p' "$ROOT/test/acceptance.d/apps-test.sh")
source <(sed -n '/^open_and_capture_panel() {$/,/^}$/p' "$ROOT/test/acceptance.d/panels-test.sh")
(
  sleep() { :; }
  launch_app() { touch "$test_tmp/window"; }
  window_present() { [[ -e $test_tmp/window ]]; }
  close_windows() { rm -f "$test_tmp/window"; }
  layer_present() { [[ -e $test_tmp/panel ]]; }
  layer_absent() { [[ ! -e $test_tmp/panel ]]; }
  omarchy-shell() {
    if [[ $2 == "summon" ]]; then
      touch "$test_tmp/panel"
    else
      rm -f "$test_tmp/panel"
    fi
  }

  for capture in failed successful; do
    if [[ $capture == "failed" ]]; then
      touch "$test_tmp/fail"
    else
      rm "$test_tmp/fail"
    fi
    for check in launch_and_verify open_and_capture_panel; do
      status=0
      if ! ("$check" fixture fixture fixture >"$test_tmp/caller.log" 2>&1); then
        status=1
      fi
      [[ ! -e $test_tmp/window && ! -e $test_tmp/panel ]] ||
        fail "$check cleans up after a $capture capture" "$(cat "$test_tmp/caller.log")"
      if [[ $capture == "failed" ]]; then
        (( status != 0 )) || fail "$check rejects a failed capture" "$(cat "$test_tmp/caller.log")"
      else
        (( status == 0 )) || fail "$check accepts a successful capture" "$(cat "$test_tmp/caller.log")"
      fi
      pass "$check preserves cleanup and the $capture capture result"
    done
  done
) || exit 1
