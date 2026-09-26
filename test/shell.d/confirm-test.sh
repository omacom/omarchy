#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

grep -Fq 'omarchy-confirm "Continue with update?"' "$ROOT/bin/omarchy-update-confirm" ||
  fail "update confirm uses the mouse-capable helper"
if grep -Fq 'gum confirm' "$ROOT/bin/omarchy-update-confirm"; then
  fail "update confirm no longer calls gum confirm"
fi
pass "update confirm uses the mouse-capable helper"

grep -Fq 'omarchy-confirm "$1"' "$ROOT/bin/omarchy-update-restart" ||
  fail "update restart prompt uses the mouse-capable helper"
if grep -Fq 'gum confirm' "$ROOT/bin/omarchy-update-restart"; then
  fail "update restart prompt no longer calls gum confirm"
fi
pass "update restart prompt uses the mouse-capable helper"

helper="$ROOT/bin/omarchy-confirm"
grep -Fq -- '--bind "left-click:accept"' "$helper" ||
  fail "confirm binds left-click to accept"
grep -Fq -- '--no-input' "$helper" ||
  fail "confirm hides the fzf query line"
grep -Fq -- '--height=6' "$helper" ||
  fail "confirm stays inline so script(1) does not log a fullscreen TUI"
pass "confirm is an inline fzf widget with mouse accept"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/fzf" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$FZF_ARGS"
printf 'OPTS=%s\nFILE=%s\n' "${FZF_DEFAULT_OPTS-unset}" "${FZF_DEFAULT_OPTS_FILE-unset}" >"$FZF_ENV"
if [[ ${FZF_EXIT:-0} != 0 ]]; then
  exit "$FZF_EXIT"
fi
printf '%s\n' "${FZF_CHOICE:-Yes}"
SH
chmod +x "$stub_bin/fzf"

cat >"$stub_bin/gum" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$GUM_ARGS"
exit "${GUM_EXIT:-0}"
SH
chmod +x "$stub_bin/gum"

run_confirm() {
  OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" FZF_ARGS="$test_tmp/args" FZF_ENV="$test_tmp/env" \
    GUM_ARGS="$test_tmp/gum-args" \
    "$ROOT/bin/omarchy-confirm" "$@"
}

FZF_CHOICE=Yes FZF_DEFAULT_OPTS='--tac' FZF_DEFAULT_OPTS_FILE='/tmp/not-ours' \
  run_confirm "Continue with update?" >/dev/null
grep -Fq -- '--bind' "$test_tmp/args" || fail "confirm passes bind flags to fzf"
grep -Fq -- 'left-click:accept' "$test_tmp/args" || fail "confirm asks fzf to accept a left click"
grep -Fq -- '--no-input' "$test_tmp/args" || fail "confirm disables the fzf query line"
grep -Fq -- 'load:pos(1)' "$test_tmp/args" || fail "confirm selects Yes after the list has loaded"
grep -Fq -- 'n:pos(2)+accept' "$test_tmp/args" || fail "confirm binds n to No"
grep -Fq -- 'y:pos(1)+accept' "$test_tmp/args" || fail "confirm binds y to Yes"
grep -Fx 'OPTS=unset' "$test_tmp/env" >/dev/null || fail "confirm ignores FZF_DEFAULT_OPTS"
grep -Fx 'FILE=unset' "$test_tmp/env" >/dev/null || fail "confirm ignores FZF_DEFAULT_OPTS_FILE"
pass "confirm launches fzf with mouse accept, gum keys, and Yes selected"

set +e
FZF_CHOICE=No run_confirm "Continue?" >/dev/null
status=$?
set -e
(( status == 1 )) || fail "confirm exits 1 when No is chosen" "status=$status"
pass "confirm exits 1 when No is chosen"

set +e
FZF_EXIT=130 run_confirm "Continue?" >/dev/null
status=$?
set -e
(( status == 130 )) || fail "confirm maps fzf abort to 130" "status=$status"
pass "confirm maps fzf abort to 130"

set +e
FZF_EXIT=2 run_confirm "Continue?" >/dev/null
status=$?
set -e
(( status == 2 )) || fail "confirm passes an fzf failure through" "status=$status"
pass "confirm passes an fzf failure through"

set +e
FZF_CHOICE=No FZF_EXIT=0 run_confirm --default=false "Remove?" >/dev/null
set -e
grep -Fq -- 'load:pos(2)' "$test_tmp/args" || fail "confirm --default=false selects No after the list has loaded"
pass "confirm --default=false selects No after the list has loaded"

# The stub directory is prepended to the real PATH, which still contains fzf.
# The fallback has to be checked with a PATH that cannot see it.
nofzf_bin="$test_tmp/nofzf-bin"
mkdir -p "$nofzf_bin"
ln -s "$stub_bin/gum" "$nofzf_bin/gum"
ln -s "$(command -v awk)" "$nofzf_bin/awk"
set +e
GUM_EXIT=1 PATH="$nofzf_bin" OMARCHY_PATH="$ROOT" GUM_ARGS="$test_tmp/gum-args" \
  "$ROOT/bin/omarchy-confirm" --default=false --affirmative Keep --negative Drop "Remove orphans?" >/dev/null
status=$?
set -e
(( status == 1 )) || fail "confirm falls back to gum when fzf is missing" "status=$status"
grep -Fx 'confirm' "$test_tmp/gum-args" >/dev/null || fail "confirm fallback invokes gum confirm"
grep -Fx -- '--default=false' "$test_tmp/gum-args" >/dev/null || fail "confirm fallback keeps --default=false"
grep -Fx 'Keep' "$test_tmp/gum-args" >/dev/null || fail "confirm fallback keeps the affirmative label"
grep -Fx 'Drop' "$test_tmp/gum-args" >/dev/null || fail "confirm fallback keeps the negative label"
grep -Fx 'Remove orphans?' "$test_tmp/gum-args" >/dev/null || fail "confirm fallback keeps the prompt"
pass "confirm falls back to gum when fzf is missing"

if ! command -v fzf >/dev/null || ! command -v python3 >/dev/null; then
  pass "real fzf keyboard check skipped"
else
  python3 - "$ROOT/bin/omarchy-confirm" <<'PY'
import os, pty, sys, time, fcntl, termios, struct

script = sys.argv[1]

def run(keys, args, extra=None):
    pid, fd = pty.fork()
    if pid == 0:
        env = os.environ.copy()
        env.pop("OMARCHY_PATH", None)
        env.pop("FZF_DEFAULT_OPTS", None)
        env.pop("FZF_DEFAULT_OPTS_FILE", None)
        if extra:
            env.update(extra)
        os.execvpe(script, [script, *args], env)
    fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 80, 0, 0))
    time.sleep(0.8)
    os.write(fd, keys)
    _, status = os.waitpid(pid, 0)
    os.close(fd)
    return os.waitstatus_to_exitcode(status)

cases = [
    (b"n", ["Continue?"], None, 1),
    (b"y", ["Continue?"], None, 0),
    (b"q", ["Continue?"], None, 1),
    (b"\r", ["--default=false", "Remove?"], None, 1),
    (b"\r", ["Continue?"], {"FZF_DEFAULT_OPTS": "--tac"}, 0),
]
failed = False
for keys, args, extra, expect in cases:
    rc = run(keys, args, extra)
    if rc != expect:
        print(f"not ok - real fzf keys={keys!r} args={args} rc={rc} expect={expect}", file=sys.stderr)
        failed = True
sys.exit(1 if failed else 0)
PY
  pass "confirm answers y, n, q, and the default row in real fzf"
fi
