#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command tmux

REAL_TMUX=$(command -v tmux)
TEST_HOME=$(mktemp -d) || fail "create a scratch home"
# A tmux socket path must stay short, so the scratch server's socket lives in
# /tmp. Every tmux call names it, so none can reach the user's own server.
SOCKET_DIR=$(mktemp -d /tmp/omarchy-tmux-test.XXXXXX) || fail "create a scratch tmux socket directory"
TMUX_SOCKET="$SOCKET_DIR/tmux"
unset TMUX
trap '"$REAL_TMUX" -S "$TMUX_SOCKET" kill-server 2>/dev/null; rm -rf "$TEST_HOME" "$SOCKET_DIR"' EXIT

tmux() {
  "$REAL_TMUX" -S "$TMUX_SOCKET" "$@"
}

FAKE_BIN="$TEST_HOME/bin"
CURRENT_THEME="$TEST_HOME/.local/state/omarchy/current/theme"
TMUX_LOG="$TEST_HOME/tmux.log"
mkdir -p "$FAKE_BIN" "$CURRENT_THEME"

cat >"$FAKE_BIN/tmux" <<EOF
#!/bin/bash
printf '%s\n' "\$1" >>"$TMUX_LOG"
exec "$REAL_TMUX" -S "$TMUX_SOCKET" -f /dev/null "\$@"
EOF
chmod +x "$FAKE_BIN/tmux"

cat >"$CURRENT_THEME/colors.toml" <<'EOF'
background = "#f4f4f4"
foreground = "#222222"
bright_foreground = "#111111"
EOF

{
  for i in $(seq 1 40); do
    printf 'hl.env("GUM_VAR_%s", "#%06x")\n' "$i" "$i"
  done
  printf '%s\n' "hl.env(\"QUOTED\", \"it's \$HOME ~ #{session_name} a;b\")"
} >"$CURRENT_THEME/gum_env.lua"

# Panes run a plain sleep under the scratch home, so no shell startup file of
# the developer's runs or writes anywhere.
for session in one two three; do
  HOME="$TEST_HOME" "$FAKE_BIN/tmux" new-session -d -s "$session" "exec sleep 600"
done
: >"$TMUX_LOG"

PATH="$FAKE_BIN:$ROOT/bin:$PATH" HOME="$TEST_HOME" "$ROOT/bin/omarchy-theme-set-tmux"

for target in -g "-t one" "-t two" "-t three"; do
  [[ $(tmux show-environment $target GUM_VAR_40) == "GUM_VAR_40=#000028" ]] || fail "tmux theme sync sets gum variables ($target)"
  [[ $(tmux show-environment $target COLORFGBG) == "COLORFGBG=0;15" ]] || fail "tmux theme sync sets a light COLORFGBG ($target)"
done
pass "tmux theme sync sets theme variables globally and in every session"

[[ $(tmux show-environment -t two QUOTED) == "QUOTED=it's \$HOME ~ #{session_name} a;b" ]] || \
  fail "tmux theme sync passes values through literally" "$(tmux show-environment -t two QUOTED)"
pass "tmux theme sync passes values through literally"

[[ $(tmux show-options -gv window-style) == "fg=#222222,bg=#f4f4f4" ]] || fail "tmux theme sync sets the window style"
[[ $(tmux show-options -gv window-active-style) == "fg=#222222,bg=#f4f4f4" ]] || fail "tmux theme sync sets the active window style"
[[ $(tmux show-options -gv cursor-colour) == "#111111" ]] || fail "tmux theme sync sets the cursor colour"
pass "tmux theme sync sets window styles and the cursor colour"

(( $(wc -l <"$TMUX_LOG") <= 8 )) || fail "tmux theme sync batches its settings into a few tmux clients" "$(sort "$TMUX_LOG" | uniq -c)"
pass "tmux theme sync batches its settings into a few tmux clients"
