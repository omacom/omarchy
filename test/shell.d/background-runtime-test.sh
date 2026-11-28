#!/bin/bash
# omarchy:exclusive
# A full shell on llvmpipe beside a busy pool can land the theme fallback before the clear it is checked against.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "background runtime test"
require_command magick

setup_scratch_shell
images="$SCRATCH_DIR/images"
link="$SCRATCH_HOME/.local/state/omarchy/current/background"
gate="$SCRATCH_DIR/gate"
arrived="$SCRATCH_DIR/arrived"
release="$SCRATCH_DIR/release"
mkdir -p "$images" "$(dirname "$link")"

cleanup() {
  # A read held at the gate would outlive the shell that started it.
  [[ -p $release ]] && : <>"$release"
  scratch_shell_cleanup
}
trap cleanup EXIT

# Images that decode, or a failed load recovers the link's target over the
# wallpaper under test.
for name in a b c; do
  magick -size 16x16 xc:magenta "$images/$name.png"
done
mkfifo "$arrived" "$release"

# The background's own read of its link, once per armed gate, takes the
# link's target at once and then holds its answer until the test releases it,
# so the test can land a call while that read is in flight.
cat >"$SCRATCH_BIN/readlink" <<SH
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
chmod +x "$SCRATCH_BIN/readlink"

for offline in curl omarchy-update-available; do
  printf '#!/bin/bash\nexit 1\n' >"$SCRATCH_BIN/$offline"
  chmod +x "$SCRATCH_BIN/$offline"
done

fail_with_log() {
  local description="$1"
  local detail="${2:-}"
  sed -n '1,240p' "$SCRATCH_LOG" >&2
  fail "$description" "$detail"
}

# Prints the background's state once no link read is in flight or queued.
settled_state() {
  local state=""
  for _ in {1..100}; do
    state=$(scratch_ipc background state 2>/dev/null || true)
    if jq -e '.reading == false' <<<"$state" >/dev/null 2>&1; then
      printf '%s\n' "$state"
      return 0
    fi
    kill -0 "$SCRATCH_PID" 2>/dev/null || fail_with_log "test shell exited"
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
  scratch_ipc background refresh >/dev/null
  timeout 10 cat "$arrived" >/dev/null || fail_with_log "the background reads its link when asked"
}

release_read() {
  timeout 10 sh -c 'printf "go\n" >"$1"' _ "$release" || fail_with_log "a held read waits on the release"
}

a="$images/a.png"
b="$images/b.png"
c="$images/c.png"
ln -nsf "$a" "$link"

start_scratch_shell
wait_scratch_shell
expect_state "the background shows the linked wallpaper at startup" \
  --arg a "$a" '.current == $a and .displayed == $a'

start_held_read
scratch_ipc background setInstant "$b" >/dev/null
release_read
expect_state "a link read overtaken by a newer wallpaper is dropped" \
  --arg b "$b" '.current == $b and .displayed == $b'

start_held_read
scratch_ipc background clear >/dev/null
release_read
expect_state "a link read overtaken by a clear is dropped" \
  '.current == "" and .displayed == "" and .incoming == ""'

scratch_ipc background setInstant "$a" >/dev/null
start_held_read
ln -nsf "$c" "$link"
scratch_ipc background refresh >/dev/null
release_read
expect_state "a refresh asked for during a link read runs after it" \
  --arg c "$c" '.current == $c'

ln -nsf "$images/missing.png" "$link"
scratch_ipc background refresh >/dev/null
expect_state "a background link that resolves to no file clears the wallpaper" \
  '.current == "" and .displayed == "" and .incoming == ""'

# The incoming frame names no file, so it never loads and the theme waits on
# a reveal that cannot start; only the fallback timer would land it.
colors=$(printf 'accent = "#123456"\n' | base64 -w0)
scratch_ipc background setInstant "$a" >/dev/null
scratch_ipc background themeTransition "$a" "$images/never.png" "$images/never.png" "$colors" "" >/dev/null
waiting=$(scratch_ipc background state)
if jq -e '.pendingTheme' <<<"$waiting" >/dev/null; then
  scratch_ipc background clear >/dev/null
  expect_state "clearing lands a theme still waiting on its wallpaper" '.pendingTheme == false'
else
  skip "the theme fallback landed before the clear could; clearing a waiting theme went unchecked"
fi
