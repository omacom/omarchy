#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp="$(mktemp -d)"
socket_pid=""
cleanup() {
  [[ -n $socket_pid ]] && kill "$socket_pid" 2>/dev/null || true
  rm -rf "$test_tmp"
}
trap cleanup EXIT

export HOME="$test_tmp/home"
export XDG_CONFIG_HOME="$HOME/.config"
export TEST_LOG="$test_tmp/calls.log"
mkdir -p "$HOME" "$test_tmp/bin"
touch "$TEST_LOG"

cat >"$test_tmp/bin/curl" <<'SCRIPT'
#!/bin/bash
while (( $# > 0 )); do
  if [[ $1 == -o ]]; then
    output="$2"
    break
  fi
  shift
done
cat >"$output" <<'INSTALLER'
#!/bin/sh
printf 'installer:home=%s:dir=%s:noninteractive=%s:path=%s\n' \
  "$CODEX_HOME" "$CODEX_INSTALL_DIR" "$CODEX_NON_INTERACTIVE" "$PATH" >>"$TEST_LOG"
mkdir -p "$CODEX_INSTALL_DIR"
cat >"$CODEX_INSTALL_DIR/codex" <<'CODEX'
#!/bin/bash
printf '%s\0' "$@" >"$TEST_CODEX_ARGS"
printf '%s\n' "$CODEX_HOME" >"$TEST_CODEX_HOME"
CODEX
chmod +x "$CODEX_INSTALL_DIR/codex"
INSTALLER
SCRIPT
chmod +x "$test_tmp/bin/curl"

cat >"$test_tmp/bin/systemctl" <<'SCRIPT'
#!/bin/bash
printf 'systemctl:%s\n' "$*" >>"$TEST_LOG"
SCRIPT
chmod +x "$test_tmp/bin/systemctl"

PATH="$test_tmp/bin:$PATH" OMARCHY_PATH="$ROOT" CODEX_HOME="$HOME/.codex" \
  "$ROOT/bin/omarchy-setup-codex-remote" >"$test_tmp/setup-output"

launcher="$HOME/.local/bin/codex-remote"
unit="$XDG_CONFIG_HOME/systemd/user/omarchy-codex-remote.service"
config="$XDG_CONFIG_HOME/omarchy/codex-remote.conf"

[[ -x $launcher ]] || fail "Codex Remote setup installs its launcher"
[[ -r $unit ]] || fail "Codex Remote setup installs its user service"
[[ -r $config ]] || fail "Codex Remote setup records its Codex home"
pass "Codex Remote setup installs its launcher, service, and config"

grep -Fxq 'ConditionPathExists=%h/.local/bin/codex-remote' "$unit" ||
  fail "Codex Remote service only starts after setup installs its launcher"
grep -Fxq 'WantedBy=default.target' "$unit" ||
  fail "Codex Remote service starts with the user manager"
grep -Fxq 'Restart=on-failure' "$unit" ||
  fail "Codex Remote service retries transient startup failures"
pass "Codex Remote service is conditional and persistent"

grep -Fq "installer:home=$HOME/.codex:dir=$HOME/.local/share/omarchy/codex-remote/bin:noninteractive=1" "$TEST_LOG" ||
  fail "Codex Remote setup isolates the official standalone install" "$(<"$TEST_LOG")"
grep -Fq "path=$HOME/.local/share/omarchy/codex-remote/bin:" "$TEST_LOG" ||
  fail "Codex Remote setup prevents installer PATH changes"
pass "Codex Remote setup isolates the standalone runtime without shadowing Mise"

grep -Fxq 'systemctl:--user daemon-reload' "$TEST_LOG" ||
  fail "Codex Remote setup reloads user units"
grep -Fxq 'systemctl:--user enable --now omarchy-codex-remote.service' "$TEST_LOG" ||
  fail "Codex Remote setup enables and starts its service"
pass "Codex Remote setup enables its user service"

grep -Fq 'Remote officially supports macOS and Windows hosts' <(
  OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-setup-codex-remote" --help
) || fail "Codex Remote setup labels Linux support experimental"
pass "Codex Remote setup labels Linux support experimental"

mkdir -p "$HOME/.codex/app-server-control"
python - "$HOME/.codex/app-server-control/app-server-control.sock" <<'PY' &
import socket
import sys
import time

sock = socket.socket(socket.AF_UNIX)
sock.bind(sys.argv[1])
time.sleep(30)
PY
socket_pid=$!
for _ in {1..50}; do
  [[ -S $HOME/.codex/app-server-control/app-server-control.sock ]] && break
  sleep 0.1
done

export TEST_CODEX_ARGS="$test_tmp/codex-args"
export TEST_CODEX_HOME="$test_tmp/codex-home"
"$launcher" resume --last
mapfile -d '' -t codex_args <"$TEST_CODEX_ARGS"
expected=(--remote "unix://$HOME/.codex/app-server-control/app-server-control.sock" resume --last)
[[ ${codex_args[*]@Q} == "${expected[*]@Q}" ]] ||
  fail "codex-remote resumes sessions through the shared daemon" "${codex_args[*]@Q}"
pass "codex-remote resumes sessions through the shared daemon"

[[ $(<"$TEST_CODEX_HOME") == "$HOME/.codex" ]] ||
  fail "codex-remote keeps the daemon on its configured Codex home"
pass "codex-remote keeps the daemon on its configured Codex home"

"$launcher" queue --thread thread-1 --message hello
mapfile -d '' -t codex_args <"$TEST_CODEX_ARGS"
expected=(queue --remote "unix://$HOME/.codex/app-server-control/app-server-control.sock" --thread thread-1 --message hello)
[[ ${codex_args[*]@Q} == "${expected[*]@Q}" ]] ||
  fail "codex-remote queues messages through the shared daemon" "${codex_args[*]@Q}"
pass "codex-remote queues messages through the shared daemon"

if "$launcher" exec echo no >"$test_tmp/exec-output" 2>&1; then
  fail "codex-remote rejects non-interactive commands"
fi
grep -Fq "Run it with codex instead" "$test_tmp/exec-output" ||
  fail "codex-remote explains how to run non-interactive commands"
pass "codex-remote keeps non-interactive work on normal Codex"

printf '#!/bin/bash\necho mine\n' >"$launcher"
if PATH="$test_tmp/bin:$PATH" OMARCHY_PATH="$ROOT" CODEX_HOME="$HOME/.codex" \
  "$ROOT/bin/omarchy-setup-codex-remote" >"$test_tmp/foreign-output" 2>&1; then
  fail "Codex Remote setup refuses a foreign launcher"
fi
grep -Fxq 'echo mine' "$launcher" || fail "Codex Remote setup preserves a foreign launcher"
pass "Codex Remote setup preserves a foreign launcher"

install -Dm755 "$ROOT/default/codex/codex-remote" "$launcher"
PATH="$test_tmp/bin:$PATH" OMARCHY_PATH="$ROOT" CODEX_HOME="$HOME/.codex" \
  "$ROOT/bin/omarchy-setup-codex-remote" --remove >"$test_tmp/remove-output"
[[ ! -e $launcher && ! -e $unit && ! -e $config ]] ||
  fail "Codex Remote removal deletes only its integration files"
[[ -x $HOME/.local/share/omarchy/codex-remote/bin/codex ]] ||
  fail "Codex Remote removal preserves the standalone runtime"
pass "Codex Remote removal preserves runtime and user data"
