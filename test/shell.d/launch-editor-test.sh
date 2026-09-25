#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
stub_bin="$tmpdir/bin"
mkdir -p "$home/.local/state/omarchy/defaults" "$stub_bin"

# Stub the commands the script shells out to.
cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
command -v "$1" >/dev/null 2>&1
SH
chmod +x "$stub_bin/omarchy-cmd-present"

cat >"$stub_bin/setsid" <<'SH'
#!/bin/bash
printf 'setsid' >>"$LAUNCH_EDITOR_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$LAUNCH_EDITOR_LOG"
done
printf '\n' >>"$LAUNCH_EDITOR_LOG"
if [[ $1 == -w ]]; then
  shift
fi
exec "$@"
SH
chmod +x "$stub_bin/setsid"

cat >"$stub_bin/uwsm-app" <<'SH'
#!/bin/bash
printf 'uwsm-app' >>"$LAUNCH_EDITOR_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$LAUNCH_EDITOR_LOG"
done
printf '\n' >>"$LAUNCH_EDITOR_LOG"
exec "$@"
SH
chmod +x "$stub_bin/uwsm-app"

cat >"$stub_bin/code" <<'SH'
#!/bin/bash
printf 'code' >>"$LAUNCH_EDITOR_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$LAUNCH_EDITOR_LOG"
done
printf '\n' >>"$LAUNCH_EDITOR_LOG"
SH
chmod +x "$stub_bin/code"

run_launcher() {
  LAUNCH_EDITOR_LOG="$tmpdir/log" \
    HOME="$home" PATH="$stub_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
    bash "$ROOT/bin/omarchy-launch-editor" "$@"
}

# Without --inline, a GUI editor is launched detached and must not get --wait.
printf 'code\n' > "$home/.local/state/omarchy/defaults/editor"
: > "$tmpdir/log"
run_launcher /tmp/file.txt
grep -Fqx $'uwsm-app\t--\tcode\t--\t/tmp/file.txt' "$tmpdir/log" ||
  fail "non-inline launch passes no wait flag" "$(cat "$tmpdir/log")"
grep -Fq $'setsid\tuwsm-app' "$tmpdir/log" ||
  fail "non-inline launch does not wait for the GUI editor" "$(cat "$tmpdir/log")"
pass "non-inline launch passes no wait flag"

# With --inline, a GUI editor gets its wait flag and setsid waits.
: > "$tmpdir/log"
run_launcher --inline /tmp/file.txt
grep -Fqx $'uwsm-app\t--\tcode\t--wait\t--\t/tmp/file.txt' "$tmpdir/log" ||
  fail "inline launch passes --wait to code" "$(cat "$tmpdir/log")"
grep -Fq $'setsid\t-w\tuwsm-app' "$tmpdir/log" ||
  fail "inline launch waits for the GUI editor" "$(cat "$tmpdir/log")"
pass "inline launch passes --wait to code and setsid waits"

# gnome-text-editor rejects --wait, so it takes the unknown-GUI path even
# though gedit keeps the flag.
printf 'gnome-text-editor\n' > "$home/.local/state/omarchy/defaults/editor"
cat >"$stub_bin/gnome-text-editor" <<'SH'
#!/bin/bash
printf 'gnome-text-editor' >>"$LAUNCH_EDITOR_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$LAUNCH_EDITOR_LOG"
done
printf '\n' >>"$LAUNCH_EDITOR_LOG"
SH
chmod +x "$stub_bin/gnome-text-editor"

: > "$tmpdir/log"
run_launcher --inline /tmp/file.txt
grep -Fqx $'uwsm-app\t--\tgnome-text-editor\t--\t/tmp/file.txt' "$tmpdir/log" ||
  fail "inline launch passes no --wait to gnome-text-editor" "$(cat "$tmpdir/log")"
grep -Fq $'setsid\t-w\tuwsm-app' "$tmpdir/log" ||
  fail "inline launch of gnome-text-editor still waits" "$(cat "$tmpdir/log")"
pass "inline launch passes no --wait to gnome-text-editor and still waits"

# Unknown GUI editors get no wait flag but still wait via setsid.
printf 'unknown-gui\n' > "$home/.local/state/omarchy/defaults/editor"
cat >"$stub_bin/unknown-gui" <<'SH'
#!/bin/bash
printf 'unknown-gui' >>"$LAUNCH_EDITOR_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$LAUNCH_EDITOR_LOG"
done
printf '\n' >>"$LAUNCH_EDITOR_LOG"
SH
chmod +x "$stub_bin/unknown-gui"

: > "$tmpdir/log"
run_launcher --inline /tmp/file.txt
grep -Fqx $'uwsm-app\t--\tunknown-gui\t--\t/tmp/file.txt' "$tmpdir/log" ||
  fail "inline launch of an unknown GUI editor passes no wait flag" "$(cat "$tmpdir/log")"
grep -Fq $'setsid\t-w\tuwsm-app' "$tmpdir/log" ||
  fail "inline launch of an unknown GUI editor still waits" "$(cat "$tmpdir/log")"
pass "inline launch of an unknown GUI editor passes no wait flag and still waits"

# TUI editors ignore --inline wait flags entirely.
printf 'nvim\n' > "$home/.local/state/omarchy/defaults/editor"
cat >"$stub_bin/nvim" <<'SH'
#!/bin/bash
printf 'nvim' >>"$LAUNCH_EDITOR_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$LAUNCH_EDITOR_LOG"
done
printf '\n' >>"$LAUNCH_EDITOR_LOG"
SH
chmod +x "$stub_bin/nvim"

: > "$tmpdir/log"
run_launcher --inline /tmp/file.txt
grep -Fqx $'nvim\t--\t/tmp/file.txt' "$tmpdir/log" ||
  fail "inline TUI editor runs directly" "$(cat "$tmpdir/log")"
pass "inline TUI editor runs directly"
