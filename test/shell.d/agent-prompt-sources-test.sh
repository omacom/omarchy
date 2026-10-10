#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
agent_log="$test_tmp/agent.log"
mkdir -p "$mock_bin" "$test_home/.config/omarchy/defaults"
printf 'claude\n' >"$test_home/.config/omarchy/defaults/agent"

cat >"$mock_bin/omarchy-agent" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_AGENT_LOG"
SH
chmod +x "$mock_bin/omarchy-agent"

run_prompt() {
  HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" \
    OMARCHY_TEST_AGENT_LOG="$agent_log" \
    "$@"
}

expect_args() {
  local description=$1
  shift
  if ! python3 - "$agent_log" "$@" <<'PY'
import sys
got = [part.decode() for part in open(sys.argv[1], "rb").read().split(b"\0") if part]
want = sys.argv[2:]
if got != want:
  raise SystemExit(f"got {got!r} want {want!r}")
PY
  then
    fail "$description" "$(tr '\0' ' ' <"$agent_log")"
  fi
  pass "$description"
}

: >"$agent_log"
printf 'review this; echo $(whoami)\n' | run_prompt "$ROOT/bin/omarchy-agent-prompt" -
expect_args "stdin prompt (-) reaches omarchy-agent" --prompt 'review this; echo $(whoami)'

cat >"$mock_bin/wl-paste" <<'SH'
#!/bin/bash
[[ $# == 3 && $1 == "--no-newline" && $2 == "--type" && $3 == "text" ]] || exit 2
printf 'clipboard body; rm -rf /'
SH
chmod +x "$mock_bin/wl-paste"

: >"$agent_log"
run_prompt "$ROOT/bin/omarchy-agent-prompt" --clipboard 2>"$test_tmp/err"
expect_args "--clipboard reaches omarchy-agent" --prompt 'clipboard body; rm -rf /'

cat >"$mock_bin/wl-paste" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin/wl-paste"
if run_prompt "$ROOT/bin/omarchy-agent-prompt" --clipboard 2>"$test_tmp/err"; then
  fail "empty clipboard still launched an agent"
fi
grep -Fq 'Clipboard is empty' "$test_tmp/err" ||
  fail "empty clipboard does not explain the failure" "$(cat "$test_tmp/err")"
pass "empty clipboard is refused"

: >"$agent_log"
run_prompt "$ROOT/bin/omarchy-agent-prompt" --inline "keep argv prompts"
expect_args "argv prompts still work alongside the new sources" --inline --prompt "keep argv prompts"

: >"$agent_log"
run_prompt "$ROOT/bin/omarchy-agent-prompt" '--disable-sandbox is literal prompt text'
expect_args "option-like prompt text is preserved" --prompt '--disable-sandbox is literal prompt text'

: >"$agent_log"
if printf '' | run_prompt "$ROOT/bin/omarchy-agent-prompt" - 2>"$test_tmp/err"; then
  fail "empty stdin still launched an agent"
fi
if [[ -s $agent_log ]] || ! grep -Fq 'Prompt on stdin was empty' "$test_tmp/err"; then
  fail "empty stdin must explain the failure without launching" "$(cat "$test_tmp/err")"
fi
pass "empty stdin is refused before launch"

cat >"$mock_bin/wl-paste" <<'SH'
#!/bin/bash
printf 'partial selection'
echo 'synthetic clipboard connection failure' >&2
exit 1
SH
chmod +x "$mock_bin/wl-paste"
: >"$agent_log"
if run_prompt "$ROOT/bin/omarchy-agent-prompt" --clipboard 2>"$test_tmp/err"; then
  fail "failed clipboard read still launched an agent"
fi
if [[ -s $agent_log ]] || ! grep -Fq 'Unable to read clipboard' "$test_tmp/err" ||
  ! grep -Fq 'synthetic clipboard connection failure' "$test_tmp/err" ||
  grep -Fq 'Clipboard is empty' "$test_tmp/err"; then
  fail "clipboard failure must retain its cause without launching" "$(cat "$test_tmp/err")"
fi
pass "clipboard command failure is distinguished from an empty selection"

for prompt_source in "ignored prompt" "-"; do
  : >"$agent_log"
  if run_prompt "$ROOT/bin/omarchy-agent-prompt" --clipboard "$prompt_source" 2>"$test_tmp/err"; then
    fail "clipboard accepts a conflicting prompt source"
  fi
  [[ ! -s $agent_log ]] && grep -Fq 'cannot be combined' "$test_tmp/err" ||
    fail "conflicting source must fail before clipboard access or launch" "$(cat "$test_tmp/err")"
done
pass "clipboard rejects positional and stdin sources before reading"

cat >"$mock_bin/wl-paste" <<'SH'
#!/bin/bash
[[ $# == 3 && $1 == "--no-newline" && $2 == "--type" && $3 == "text" ]] || exit 2
printf 'secret prompt'
SH
chmod +x "$mock_bin/wl-paste"
run_prompt "$ROOT/bin/omarchy-agent-prompt" --inline --clipboard 2>"$test_tmp/err"
expect_args "inline clipboard prompt preserves arguments" --inline --prompt 'secret prompt'
grep -Fq '13 clipboard characters' "$test_tmp/err" &&
  grep -Fq 'visible in process arguments' "$test_tmp/err" &&
  ! grep -Fq 'secret prompt' "$test_tmp/err" ||
  fail "clipboard launch shows length and exposure without echoing its contents" "$(cat "$test_tmp/err")"
pass "clipboard preview shows length without disclosing contents"
