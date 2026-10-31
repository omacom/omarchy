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

# Exercise the real lifecycle functions when output discovery fails after
# creation. No compositor is used; the stub owns only this temporary file.
python3 - "$ROOT" <<'PY'
import os, pathlib, re, subprocess, sys, tempfile
source = (pathlib.Path(sys.argv[1]) / 'test/acceptance.d/overlay-monitor-test.sh').read_text()
functions = []
for name in ('focus_monitor', 'cleanup', 'create_source_monitor'):
    match = re.search(r'^' + name + r'\(\) \{\n.*?^\}', source, re.M | re.S)
    if match:
        functions.append(match[0])
with tempfile.TemporaryDirectory(prefix='overlay-cleanup-') as directory:
    owned = pathlib.Path(directory) / 'created-output'
    driver = r'''
set -euo pipefail
virtual_monitor=""
virtual_sequence=0
remaining_monitor=Virtual-1
original_cursor_x=640
original_cursor_y=400
tall_height=3200
hyprctl() {
  if [[ $1 == output && $2 == create ]]; then
    printf '%s' "${4:-HEADLESS-TEST}" > "$OWNED_OUTPUT"
  elif [[ $1 == output && $2 == remove ]]; then
    [[ $(cat "$OWNED_OUTPUT") == "$3" ]] && rm "$OWNED_OUTPUT"
  elif [[ $1 == -j && $2 == monitors ]]; then
    if [[ ${COLLISION:-false} == true ]]; then
      name="omarchy-overlay-$$-$virtual_sequence"
      if [[ ! -e $OWNED_OUTPUT.initialized ]]; then
        printf '%s' "$name" > "$OWNED_OUTPUT"
        touch "$OWNED_OUTPUT.initialized"
      fi
      if [[ -e $OWNED_OUTPUT ]]; then
        printf '[{"name":"Virtual-1","x":0,"y":0},{"name":"%s","x":1280,"y":0}]\n' "$name"
      else
        printf '[{"name":"Virtual-1","x":0,"y":0}]\n'
      fi
      return
    fi
    printf '%s\n' '[{"name":"Virtual-1","x":0,"y":0,"width":1280,"height":800,"scale":1}]'
  elif [[ $1 == cursorpos ]]; then
    printf '%s\n' "${CURSOR_POSITION:-640, 400}"
  fi
  return 0
}
omarchy-shell() { return "${HIDE_STATUS:-0}"; }
fail() { return 1; }
wait_until() { return 1; }
'''
    driver += '\n'.join(functions) + '\ntrap cleanup EXIT\ncreate_source_monitor\n'
    result = subprocess.run(['bash', '-c', driver], env=dict(os.environ, OWNED_OUTPUT=str(owned)), capture_output=True, text=True, timeout=10)
    assert result.returncode == 1, (result.returncode, result.stderr)
    assert not owned.exists(), 'output created before failed discovery must be removed'
    collision = subprocess.run(['bash', '-c', driver], env=dict(os.environ, OWNED_OUTPUT=str(owned), COLLISION='true'), capture_output=True, text=True, timeout=10)
    assert collision.returncode == 1, (collision.returncode, collision.stderr)
    assert owned.exists(), 'a pre-existing colliding output must never become owned by cleanup'
    for factor, value, message in [('CURSOR_POSITION', '65, 64', 'pointer restore mismatch'),
                                   ('HIDE_STATUS', '1', 'menu close failed')]:
        owned.unlink(missing_ok=True)
        failure = subprocess.run(['bash', '-c', driver], env=dict(os.environ, OWNED_OUTPUT=str(owned), **{factor:value}), capture_output=True, text=True, timeout=10)
        assert failure.returncode == 1, (factor, failure.returncode)
        assert message in failure.stderr, (factor, failure.stderr)
print('ok - failed overlay monitor discovery removes its owned output')
print('ok - a colliding output remains untouched')
print('ok - cleanup identifies a pointer restoration mismatch')
print('ok - cleanup identifies a menu close failure')
PY
