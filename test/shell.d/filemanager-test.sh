#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"
export FM_STATE="$test_tmp/default" FM_ARGS="$test_tmp/args"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"

cat >"$test_tmp/bin/xdg-mime" <<'EOF'
#!/bin/bash
case "$1" in
query)
  [[ $2 == "default" && $3 == "inode/directory" ]] || exit 2
  [[ ${FM_QUERY_FAIL:-0} == 0 ]] || exit 1
  cat "$FM_STATE"
  ;;
default)
  [[ $3 == "inode/directory" ]] || exit 2
  [[ ${FM_WRITE_FAIL:-0} == 0 ]] || exit 1
  if [[ ${FM_IGNORE_WRITE:-0} == 0 ]]; then
    printf '%s\n' "$2" >"$FM_STATE"
  fi
  ;;
esac
EOF
cat >"$test_tmp/bin/setsid" <<'EOF'
#!/bin/bash
exec "$@"
EOF
cat >"$test_tmp/bin/uwsm-app" <<'EOF'
#!/bin/bash
printf '%s\0' "$@" >"$FM_ARGS"
EOF
cat >"$test_tmp/bin/omarchy-cmd-terminal-cwd" <<'EOF'
#!/bin/bash
[[ ${FM_CWD_FAIL:-0} == 0 ]] || exit 1
printf '%s\n' "${FM_CWD:-}"
EOF
chmod +x "$test_tmp/bin/"*

assert_launch() {
  local desktop="$1" directory="$2"
  local -a actual
  mapfile -d '' -t actual <"$FM_ARGS"
  [[ ${#actual[@]} == 3 && ${actual[0]} == "--" && ${actual[1]} == "$desktop" && ${actual[2]} == "$directory" ]] ||
    fail "desktop entry and folder are forwarded as separate UWSM arguments"
}

echo 'com.thisisgm.flea.desktop' >"$FM_STATE"
omarchy-launch-filemanager
assert_launch com.thisisgm.flea.desktop "$HOME"
pass "the configured desktop entry opens the home folder"

directory="$test_tmp/a folder with 'quotes' and \$(literal)"
mkdir -p "$directory"
omarchy-launch-filemanager "$directory"
assert_launch com.thisisgm.flea.desktop "$directory"
pass "folder spaces and shell metacharacters remain literal"

omarchy-default-filemanager org.kde.dolphin.desktop
[[ $(omarchy-default-filemanager) == "org.kde.dolphin.desktop" ]] || fail "the default changes"
omarchy-launch-filemanager "$directory"
assert_launch org.kde.dolphin.desktop "$directory"
pass "a changed XDG default is used on the next launch"

FM_CWD="$directory" omarchy-launch-filemanager-cwd
assert_launch org.kde.dolphin.desktop "$directory"
FM_CWD='' omarchy-launch-filemanager-cwd
assert_launch org.kde.dolphin.desktop "$HOME"
pass "the cwd launcher preserves the terminal folder and falls back to home"

: >"$FM_STATE"
omarchy-launch-filemanager
assert_launch org.gnome.Nautilus.desktop "$HOME"
pass "an unset association retains Nautilus as the fallback"

for args in 'nautilus' '/tmp/example.desktop' '--example.desktop'; do
  if omarchy-default-filemanager "$args" >/dev/null 2>&1; then fail "invalid desktop IDs are refused"; fi
done
if omarchy-default-filemanager a.desktop b.desktop >/dev/null 2>&1; then fail "extra setter arguments are refused"; fi
if FM_IGNORE_WRITE=1 omarchy-default-filemanager missing.desktop >/dev/null 2>&1; then fail "an ineffective selection is reported"; fi
if FM_WRITE_FAIL=1 omarchy-default-filemanager example.desktop >/dev/null 2>&1; then fail "a failed selection is reported"; fi
pass "invalid and unsuccessful selections fail instead of reporting success"

rm "$FM_ARGS"
if FM_QUERY_FAIL=1 omarchy-launch-filemanager; then fail "a failed default lookup stops the launch"; fi
if FM_CWD_FAIL=1 omarchy-launch-filemanager-cwd; then fail "a failed cwd lookup stops the launch"; fi
[[ ! -e $FM_ARGS ]] || fail "lookup failures do not launch an app"
pass "lookup failures do not silently launch a different file manager"
