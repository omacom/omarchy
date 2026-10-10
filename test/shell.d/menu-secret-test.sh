#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

STUB_DIR="$TMPDIR/stub"
mkdir -p "$STUB_DIR"

# The prompt is a thin wrapper: it hands a payload to the shell over IPC and then
# blocks until the shell touches the doneFile named inside that payload. A stub
# that wrote a path of its own would let this test hang, so it reads the paths
# back out of the payload it was handed and answers those -- exactly what the
# real menu does.
cat >"$STUB_DIR/omarchy-shell" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >"$FAKE_CALL"

payload="${*: -1}"
selection_file=$(jq -r '.selectionFile // ""' <<<"$payload")
done_file=$(jq -r '.doneFile // ""' <<<"$payload")

if [[ -n ${FAKE_ANSWER:-} && -n $selection_file ]]; then
  printf '%s\n' "$FAKE_ANSWER" >"$selection_file"
fi
[[ -n $done_file ]] && : >"$done_file"
STUB

chmod +x "$STUB_DIR"/*

require_command jq

# Runs the prompt with a canned answer. Leaves the summon arguments in $CALL and
# what the prompt printed in $OUT.
run_prompt() {
  local answer="$1"
  shift

  : >"$TMPDIR/call"

  HOME="$TMPDIR/home" \
    PATH="$STUB_DIR:$PATH" \
    FAKE_CALL="$TMPDIR/call" \
    FAKE_ANSWER="$answer" \
    "$ROOT/bin/omarchy-menu-secret" "$@" >"$TMPDIR/out" 2>/dev/null || true

  CALL=$(cat "$TMPDIR/call")
  OUT=$(cat "$TMPDIR/out")
}

run_prompt "s3cret-token" "GitHub token"

# The masking lives in the menu's "secret" mode. A payload that asked for
# "input" would paint the value on screen, so the mode is the whole point of
# this command and a regression here is a visible secret.
[[ $CALL == *'"mode":"secret"'* ]] \
  || fail "prompt asks the menu for secret mode" "$CALL"
pass "prompt asks the menu for secret mode"

# The answer has to come back untouched -- leading and trailing characters are
# valid inside a token.
[[ $OUT == "s3cret-token" ]] \
  || fail "prompt prints the answer it was given" "$OUT"
pass "prompt prints the answer it was given"

[[ $CALL == *'"prompt":"GitHub token"'* ]] \
  || fail "prompt forwards its prompt text verbatim" "$CALL"
pass "prompt forwards its prompt text verbatim"

# An empty selection file is how the menu reports a cancel. The wrapper must exit
# non-zero instead of printing an empty line that callers could mistake for a
# value.
status=0
HOME="$TMPDIR/home" \
  PATH="$STUB_DIR:$PATH" \
  FAKE_CALL="$TMPDIR/call" \
  FAKE_ANSWER="" \
  "$ROOT/bin/omarchy-menu-secret" "GitHub token" >/dev/null 2>&1 || status=$?
(( status != 0 )) \
  || fail "prompt exits non-zero when nothing was entered" "status $status"
pass "prompt exits non-zero when nothing was entered"

# --width is passed through, and a bare call omits it so the menu keeps its own
# default width rather than being sent a zero.
run_prompt "tok" "Passphrase" --width 400
[[ $CALL == *'"width":400'* ]] \
  || fail "prompt forwards --width to the menu" "$CALL"
pass "prompt forwards --width to the menu"

run_prompt "tok" "Passphrase"
[[ $CALL != *'"width"'* ]] \
  || fail "prompt omits width when it was not given" "$CALL"
pass "prompt omits width when it was not given"

# A call with no prompt text still opens with the default label instead of
# sending an empty prompt the menu would render as a blank card.
run_prompt "tok"
[[ $CALL == *'"prompt":"Secret"'* ]] \
  || fail "prompt falls back to the default label" "$CALL"
pass "prompt falls back to the default label"
