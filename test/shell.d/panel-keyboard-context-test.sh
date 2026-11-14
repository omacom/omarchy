#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A foreign overlay must fail before input, while ordinary shell surfaces and
# the test fixture's explicitly allowed anchor must remain usable.
stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
mkdir -p "$stage/bin" "$stage/artifacts"
cat > "$stage/bin/hyprctl" <<'SH'
#!/bin/bash
[[ $* == "-j layers" ]] || exit 2
cat "$LAYER_FIXTURE"
exit "${LAYER_EXIT:-0}"
SH
chmod +x "$stage/bin/hyprctl"

check_context() {
  local name="$1" expected="$2" raw="$3" command_exit="${4:-0}" context="${5:-panels-test}" result=0
  printf '%s\n' "$raw" > "$stage/layers.json"
  PATH="$stage/bin:$PATH" LAYER_FIXTURE="$stage/layers.json" LAYER_EXIT="$command_exit" \
    bash -c '
      ARTIFACTS=$1
      fail() { printf "not ok - %s\n%s\n" "$1" "${2:-}"; exit 1; }
      source "$2/test/acceptance.d/panel-keyboard-context.sh"
      assert_panel_keyboard_context omarchy-acceptance-anchor
    ' "$context.sh" "$stage/artifacts" "$ROOT" > "$stage/output" 2>&1 || result=$?
  [[ $result == "$expected" ]] || fail "$name returns $expected" "exit=$result: $(cat "$stage/output")"
  if ((expected)); then
    [[ -s $stage/artifacts/$context-keyboard-layers.json ]] || fail "$name retains layer evidence"
  fi
  pass "$name"
}

check_context 'ordinary shell surfaces permit keyboard testing' 0 \
  '{"Virtual-1":{"levels":{"0":[{"namespace":"omarchy-background"}],"2":[{"namespace":"omarchy-bar"}],"3":[{"namespace":"omarchy-notifications"},{"namespace":"omarchy-keyboard-panel"},{"namespace":"omarchy-acceptance-anchor"}]}}}'
check_context 'OWE wallpaper on the background layer permits keyboard testing' 0 \
  '{"Virtual-1":{"levels":{"0":[{"namespace":"owe-background"}],"2":[{"namespace":"omarchy-bar"}],"3":[]}}}'
check_context 'authentication overlay blocks input' 1 \
  '{"Virtual-1":{"levels":{"3":[{"namespace":"omarchy-polkit","pid":42}]}}}'
check_context 'OWE namespace on an unexpected overlay layer blocks input' 1 \
  '{"Virtual-1":{"levels":{"3":[{"namespace":"owe-background","pid":43}]}}}'
check_context 'unexpected picker on the background layer blocks input' 1 \
  '{"Virtual-1":{"levels":{"0":[{"namespace":"omarchy-image-selector","pid":43}]}}}'
check_context 'a competing overlay on another monitor blocks input' 1 \
  '{"Virtual-1":{"levels":{"3":[]}},"HEADLESS-1":{"levels":{"3":[{"namespace":"omarchy-image-selector"}]}}}'
check_context 'malformed compositor output fails closed' 1 'not-json'
check_context 'missing compositor layer levels fail closed' 1 '{"Virtual-1":{}}'
check_context 'failed compositor query fails closed' 1 '{"error":"unavailable"}' 1
check_context 'first test retains its failure context' 1 \
  '{"Virtual-1":{"levels":{"3":[{"namespace":"omarchy-polkit"}]}}}' 0 panels-test
check_context 'second test records its own failure context' 1 \
  '{"Virtual-1":{"levels":{"3":[{"namespace":"omarchy-image-selector"}]}}}' 0 panel-reopen-test
jq -e '.["Virtual-1"].levels["3"][0].namespace == "omarchy-polkit"' "$stage/artifacts/panels-test-keyboard-layers.json" >/dev/null || fail "second test preserves the first failure's layer evidence"
grep -q 'panel-reopen-test' "$stage/output" || fail "failure screenshot description identifies its test"
pass "suite tests preserve separate failure evidence"
