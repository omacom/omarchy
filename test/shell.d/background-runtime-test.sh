#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=""
QS_PID=""

cleanup() {
  # A read held at the gate would outlive the shell that started it.
  [[ -n ${release:-} && -p $release ]] && : <>"$release"
  if [[ -n $QS_PID ]] && kill -0 "$QS_PID" 2>/dev/null; then
    kill "$QS_PID" 2>/dev/null || true
    wait "$QS_PID" 2>/dev/null || true
  fi
  [[ -n ${test_root:-} ]] && rm -f "$(shell_ipc_socket "$test_root")"
  [[ -n $TMPDIR && -d $TMPDIR ]] && rm -rf "$TMPDIR"
  return 0
}
trap cleanup EXIT

require_compositor "background runtime test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping background runtime test"
  exit 0
fi

require_command jq

TMPDIR=$(mktemp -d)
test_root="$TMPDIR/omarchy"
test_home="$TMPDIR/home"
stub_bin="$TMPDIR/bin"
images="$TMPDIR/images"
log="$TMPDIR/quickshell.log"
link="$test_home/.local/state/omarchy/current/background"
gate="$TMPDIR/gate"
arrived="$TMPDIR/arrived"
release="$TMPDIR/release"
mkdir -p "$test_root" "$test_home" "$stub_bin" "$images" "$(dirname "$link")"
cp -a "$ROOT/shell" "$test_root/shell"
ln -s "$ROOT/config" "$test_root/config"
ln -s "$ROOT/bin" "$test_root/bin"
touch "$images/a.png" "$images/b.png" "$images/c.png"
mkfifo "$arrived" "$release"

# The background's own read of its link, once per armed gate, takes the
# link's target at once and then holds its answer until the test releases it,
# so the test can land a call while that read is in flight.
cat >"$stub_bin/readlink" <<SH
#!/bin/bash
target=\$("$(command -v readlink)" "\$@")
status=\$?
if [[ \$# == 2 && \$1 == -e && \$2 == "$link" ]] && mv "$gate" "$gate.taken" 2>/dev/null; then
  printf 'arrived\n' >"$arrived"
  cat "$release" >/dev/null
fi
[[ -n \$target ]] && printf '%s\n' "\$target"
exit \$status
SH
chmod +x "$stub_bin/readlink"

for offline in curl omarchy-update-available; do
  printf '#!/bin/bash\nexit 1\n' >"$stub_bin/$offline"
  chmod +x "$stub_bin/$offline"
done

shell_ipc() {
  OMARCHY_PATH="$test_root" "$ROOT/bin/omarchy-shell" "$@"
}

fail_with_log() {
  local description="$1"
  local detail="${2:-}"
  sed -n '1,240p' "$log" >&2
  fail "$description" "$detail"
}

# Prints the background's state once no link read is in flight or queued.
settled_state() {
  local state=""
  for _ in {1..100}; do
    state=$(shell_ipc background state 2>/dev/null || true)
    if jq -e '.reading == false' <<<"$state" >/dev/null 2>&1; then
      printf '%s\n' "$state"
      return 0
    fi
    kill -0 "$QS_PID" 2>/dev/null || fail_with_log "test shell exited"
    sleep 0.1
  done
  fail_with_log "the background finishes reading its link" "last state: $state"
}

# expect_state <description> <jq args...>: the settled state must satisfy the
# jq filter that ends the arguments.
expect_state() {
  local description="$1" state
  shift
  state=$(settled_state)
  jq -e "$@" <<<"$state" >/dev/null || fail "$description" "state: $state"
  pass "$description"
}

# Arms the gate, asks for a read, and returns once that read holds the link's
# target and waits on the release.
start_held_read() {
  touch "$gate"
  shell_ipc background refresh >/dev/null
  timeout 10 cat "$arrived" >/dev/null || fail_with_log "the background reads its link when asked"
}

release_read() {
  timeout 10 sh -c 'printf "go\n" >"$1"' _ "$release" || fail_with_log "a held read waits on the release"
}

a="$images/a.png"
b="$images/b.png"
c="$images/c.png"
ln -nsf "$a" "$link"

OMARCHY_PATH="$test_root" \
HOME="$test_home" \
XDG_CONFIG_HOME="$test_home/.config" \
XDG_CACHE_HOME="$test_home/.cache" \
XDG_STATE_HOME="$test_home/.local/state" \
PATH="$stub_bin:$ROOT/bin:$PATH" \
  quickshell -p "$test_root/shell" --no-color >"$log" 2>&1 &
QS_PID=$!

for _ in {1..100}; do
  shell_ipc background state >/dev/null 2>&1 && break
  kill -0 "$QS_PID" 2>/dev/null || fail_with_log "test shell exited before the background answered"
  sleep 0.1
done
expect_state "the background shows the linked wallpaper at startup" \
  --arg a "$a" '.current == $a and .displayed == $a'

start_held_read
shell_ipc background setInstant "$b" >/dev/null
release_read
expect_state "a link read overtaken by a newer wallpaper is dropped" \
  --arg b "$b" '.current == $b and .displayed == $b'

start_held_read
shell_ipc background clear >/dev/null
release_read
expect_state "a link read overtaken by a clear is dropped" \
  '.current == "" and .displayed == "" and .incoming == ""'

shell_ipc background setInstant "$a" >/dev/null
start_held_read
ln -nsf "$c" "$link"
shell_ipc background refresh >/dev/null
release_read
expect_state "a refresh asked for during a link read runs after it" \
  --arg c "$c" '.current == $c'

ln -nsf "$images/missing.png" "$link"
shell_ipc background refresh >/dev/null
expect_state "a background link that resolves to no file clears the wallpaper" \
  '.current == "" and .displayed == "" and .incoming == ""'

# The incoming frame names no file, so it never loads and the theme waits on
# a reveal that cannot start; only the fallback timer would land it.
colors=$(printf 'accent = "#123456"\n' | base64 -w0)
shell_ipc background setInstant "$a" >/dev/null
shell_ipc background themeTransition "$a" "$images/never.png" "$images/never.png" "$colors" "" >/dev/null
waiting=$(shell_ipc background state)
if jq -e '.pendingTheme' <<<"$waiting" >/dev/null; then
  shell_ipc background clear >/dev/null
  expect_state "clearing lands a theme still waiting on its wallpaper" '.pendingTheme == false'
else
  skip "the theme fallback landed before the clear could; clearing a waiting theme went unchecked"
fi
