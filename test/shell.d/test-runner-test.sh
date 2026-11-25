#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/test/shell.d"
cp "$ROOT/test/"{shell,all,headless} "$test_dir/test/"
cp "$SHELL_TEST_DIR/base-test.sh" "$test_dir/test/shell.d/"

# Run the real runners in a tiny fixture tree, without recursing into this test.
run_suite() {
  status=0
  output=$(WAYLAND_DISPLAY="" bash "$test_dir/test/${1:-shell}" 2>&1) || status=$?
}

run_suite
(( status == 1 )) && [[ $output == *"No shell tests found"* ]] ||
  fail "an empty suite fails instead of counting the helper as a test" "$output"
pass "an empty suite fails instead of counting the helper as a test"

cat >"$test_dir/test/shell.d/a-pass-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
captured=$(skip "captured fixture output is not a skipped check")
pass "the command skips an optional action"
SH
run_suite
(( status == 0 )) && [[ $output == *"All 1 test files passed."* ]] ||
  fail "passing assertions and captured skip output do not mark a file skipped" "$output"
pass "passing assertions and captured skip output do not mark a file skipped"

cat >"$test_dir/test/shell.d/b-partial-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
pass "static check"
skip "first unavailable runtime check"
skip "second unavailable runtime check"
pass "check after skips"
SH
cat >"$test_dir/test/shell.d/c-skipped-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
unset WAYLAND_DISPLAY
require_compositor "runtime fixture"
fail "unreachable after compositor skip"
SH
cat >"$test_dir/test/shell.d/z-last-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
pass "last file ran"
SH
run_suite
(( status == 0 )) && [[ $output == *"4 test files completed without failures; 2 had skipped checks."* ]] ||
  fail "whole and partial skips are counted once per file and remain successful" "$output"
[[ $output == *"ok - check after skips"* && $output == *"ok - last file ran"* ]] ||
  fail "skip returns normally and later files still run" "$output"
[[ $output == *$'Skipped checks in 2 of 4 test files:\n  test/shell.d/b-partial-test.sh\n  test/shell.d/c-skipped-test.sh\n'* ]] ||
  fail "the summary identifies only files with skipped checks" "$output"
pass "whole and partial skips are visible without failing or stopping the suite"

cat >"$test_dir/test/shell.d/d-failed-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
skip "unavailable check before failure"
echo "failure detail" >&2
false
pass "unreachable after failure"
SH
run_suite
(( status == 1 )) && [[ $output == *$'1 of 5 test files failed:\n  test/shell.d/d-failed-test.sh'* ]] ||
  fail "a failure after a skip still fails the suite through the output pipe" "$output"
[[ $output == *"Skipped checks in 3 of 5 test files:"* && $output == *"failure detail"* && $output == *"ok - last file ran"* && $output != *"ok - unreachable after failure"* ]] ||
  fail "failures preserve skip reporting, diagnostics, errexit, and later tests" "$output"
pass "failures remain fatal while skips and later test results stay visible"

printf '#!/bin/bash\necho "CLI fixture passed"\n' >"$test_dir/test/cli"
chmod +x "$test_dir/test/cli"
run_suite all
(( status == 1 )) && [[ $output == *"CLI fixture passed"* && $output == *"Skipped checks in 3 of 5 test files:"* && $output == *$'1 of 2 suites failed:\n  test/shell'* ]] ||
  fail "the aggregate runner preserves shell failures and skip reporting" "$output"
pass "the aggregate runner preserves shell failures and skip reporting"

# test/ci-vm prints a failed run's logs from that run's own directory: its
# failed and unfinished files, not its passing ones, and nothing from a
# nested test/shell run, whose announcement lands later in run.log.
out=$test_dir/out
run_dir=$(sed -n 's/^Logs for every file: //p' <<<"$output" | tail -n 1)
mkdir -p "$out/shell-logs/omarchy-test-shell.nested"
printf '%s\nLogging every file to /tmp/omarchy-test-shell.nested\n' "$output" >"$out/run.log"
cp -r "$run_dir" "$out/shell-logs/"
echo "hang detail" >"$out/shell-logs/${run_dir##*/}/e-hung-test.sh.out"
echo "nested detail" >"$out/shell-logs/omarchy-test-shell.nested/nested-test.sh.out"
echo 1 >"$out/shell-logs/omarchy-test-shell.nested/nested-test.sh.code"
source "$ROOT/test/ci-failure-logs"
printed=$(print_failure_logs "$out" 2>&1)
[[ $printed == *$'::group::test/cli\n'*"CLI fixture passed"* ]] ||
  fail "a failed CI run prints the CLI suite's output" "$printed"
[[ $printed == *"::group::test/shell.d/d-failed-test.sh failed (exit 1)"*"failure detail"* ]] ||
  fail "a failed CI run prints each failed file with its output" "$printed"
[[ $printed == *"::group::test/shell.d/e-hung-test.sh did not finish"*"hang detail"* ]] ||
  fail "a failed CI run prints a file that never finished" "$printed"
[[ $printed != *"::group::test/shell.d/a-pass-test.sh"* && $printed != *"nested detail"* ]] ||
  fail "a failed CI run prints neither passing files nor a nested run's logs" "$printed"
pass "a failed CI run prints its own failed and unfinished files"

# The overlap file starts beside the pool rather than in either batch; it
# must still run, print in file order, and count like any other file.
cat >"$test_dir/test/shell.d/shell-idle-spawn-test.sh" <<'SH'
# The real file is exclusive by its require_compositor; the overlap
# classification must win over it.
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
pass "overlap fixture ran"
SH
run_suite
(( status == 1 )) && [[ $output == *"ok - overlap fixture ran"* && $output == *$'1 of 6 test files failed:\n  test/shell.d/d-failed-test.sh'* && $output == *"Skipped checks in 3 of 6 test files:"* ]] ||
  fail "the overlap file runs and is reported like any other file" "$output"
[[ $output == *$'==> test/shell.d/shell-idle-spawn-test.sh\nok - overlap fixture ran'* && $output == *$'==> test/shell.d/z-last-test.sh'* ]] ||
  fail "the overlap file prints in file order" "$output"
pass "the overlap file runs beside the pool and is reported in order"

# lua with no script argument runs stdin but ignores its error and exits 0, so
# assertions in a bare heredoc cannot fail their test. lua - treats it as a script.
stdin_lua=$(rg -l -P '\blua[[:space:]]*<<' "$SHELL_TEST_DIR" || true)
[[ -z $stdin_lua ]] || fail "shell tests run Lua heredocs as scripts" "$stdin_lua"
pass "shell tests run Lua heredocs as scripts"

# test/headless must fail closed when a live Wayland socket exists and the
# private compositor cannot be probed, rather than running against the desktop.
fake_rt="$test_dir/rt"
fake_bin="$test_dir/bin"
mkdir -p "$fake_rt" "$fake_bin"
python3 -c 'import socket, sys; s = socket.socket(socket.AF_UNIX); s.bind(sys.argv[1])' "$fake_rt/wayland-1"
cat >"$fake_bin/hyprctl" <<SH
#!/bin/bash
echo x >>"$test_dir/hyprctl-calls"
exit 1
SH
printf '#!/bin/bash\nexit 0\n' >"$fake_bin/Hyprland"
printf '#!/bin/bash\nexit 0\n' >"$fake_bin/jq"
chmod +x "$fake_bin/hyprctl" "$fake_bin/Hyprland" "$fake_bin/jq"

headless_status=0
headless_out=$(
  PATH="$fake_bin:$PATH" \
  XDG_RUNTIME_DIR="$fake_rt" \
  WAYLAND_DISPLAY="wayland-1" \
  HYPRLAND_INSTANCE_SIGNATURE="fake" \
  OMARCHY_TEST_HEADLESS_ACTIVE=0 \
  OMARCHY_TEST_USE_LIVE_COMPOSITOR=0 \
    "$ROOT/test/headless" echo "ran-on-live" 2>&1
) || headless_status=$?
(( headless_status == 1 )) && [[ $headless_out != *"ran-on-live"* && $headless_out == *"OMARCHY_TEST_USE_LIVE_COMPOSITOR=1"* ]] ||
  fail "test/headless fails closed when hyprctl cannot reach the host compositor" "$headless_out"
(( $(wc -l <"$test_dir/hyprctl-calls") == 3 )) ||
  fail "test/headless retries the initial hyprctl probe before failing closed"
pass "test/headless retries the host probe and fails closed instead of touching the active desktop"

# Group and shard filters partition the suite cleanly with zero overlap or
# omissions, and --no-cli skips test/cli while forwarding shell flags.
shard_dir=$(mktemp -d)
trap 'rm -rf "$test_dir" "$shard_dir"' EXIT
mkdir -p "$shard_dir/test/shell.d"
cp "$ROOT/test/"{shell,all,headless} "$shard_dir/test/"
cp "$SHELL_TEST_DIR/base-test.sh" "$shard_dir/test/shell.d/"
printf '#!/bin/bash\necho "CLI ran"\n' >"$shard_dir/test/cli"
chmod +x "$shard_dir/test/cli"

cat >"$shard_dir/test/shell.d/a-noncomp-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
pass "noncomp a"
SH
cat >"$shard_dir/test/shell.d/b-noncomp-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
# extra padding so LPT puts b before a
pass "noncomp b"
SH
cat >"$shard_dir/test/shell.d/shell-idle-spawn-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
pass "overlap ran"
SH
cat >"$shard_dir/test/shell.d/c-comp-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
require_compositor "comp fixture"
SH
{
  printf '# %s\n' 'omarchy:exclusive'
  cat <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
pass "runtime smoke ran"
SH
} >"$shard_dir/test/shell.d/runtime-smoke-test.sh"
cat >"$shard_dir/test/shell.d/sleep-lock-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
pass "exclusive budget/sleep ran"
SH

s1=$(WAYLAND_DISPLAY="" bash "$shard_dir/test/all" --no-cli --group=noncomp --shard=1/2 2>&1)
s2=$(WAYLAND_DISPLAY="" bash "$shard_dir/test/all" --no-cli --group=noncomp --shard=2/2 2>&1)
sc=$(WAYLAND_DISPLAY="" bash "$shard_dir/test/all" --group=comp 2>&1)
se=$(WAYLAND_DISPLAY="" bash "$shard_dir/test/all" --no-cli --group=exclusive 2>&1)

[[ $s1 != *"CLI ran"* && $s2 != *"CLI ran"* && $se != *"CLI ran"* && $sc == *"CLI ran"* ]] ||
  fail "--no-cli skips test/cli and default runs it"
[[ $s1 == *"Slowest test files:"* ]] ||
  fail "test/shell prints the slowest test files summary"

ran_files=$(
  printf '%s\n%s\n%s\n%s\n' "$s1" "$s2" "$sc" "$se" |
    sed -n 's/^==> test\/shell\.d\///p' |
    sort
)
expected_files=$(printf '%s\n' \
  a-noncomp-test.sh \
  b-noncomp-test.sh \
  c-comp-test.sh \
  runtime-smoke-test.sh \
  shell-idle-spawn-test.sh \
  sleep-lock-test.sh)
[[ $ran_files == $expected_files ]] ||
  fail "CI shards partition every shell test file exactly once" "got:\n$ran_files"

a1=$(WAYLAND_DISPLAY="" bash "$shard_dir/test/shell" --shard=1/2 2>&1)
a2=$(WAYLAND_DISPLAY="" bash "$shard_dir/test/shell" --shard=2/2 2>&1)
all_sharded=$(
  printf '%s\n%s\n' "$a1" "$a2" |
    sed -n 's/^==> test\/shell\.d\///p' |
    sort
)
[[ $all_sharded == $expected_files ]] ||
  fail "default --group=all shards partition every shell test file exactly once" "got:\n$all_sharded"
pass "CI group and shard filters partition every shell test file exactly once and report timings"

# A test file that only mentions require_compositor inside a heredoc or indented
# inline script must stay in noncomp rather than being classified as comp.
cat >"$shard_dir/test/shell.d/heredoc-mention-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
cat >/dev/null <<'FIXTURE'
require_compositor "inside heredoc"
FIXTURE
pass "heredoc mention ran"
SH
sc_heredoc=$(WAYLAND_DISPLAY="" bash "$shard_dir/test/shell" --group=comp 2>&1)
sn_heredoc=$(WAYLAND_DISPLAY="" bash "$shard_dir/test/shell" --group=noncomp 2>&1)
[[ $sc_heredoc != *"heredoc-mention-test.sh"* && $sn_heredoc == *"heredoc-mention-test.sh"* ]] ||
  fail "heredoc require_compositor fixtures stay in noncomp" "comp:\n$sc_heredoc\nnoncomp:\n$sn_heredoc"
pass "heredoc require_compositor fixtures stay in noncomp"
