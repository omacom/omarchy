#!/bin/bash

source "$(dirname "$0")/base-test.sh"

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

FAKE_BIN="$TEST_HOME/bin"
CURRENT_THEME="$TEST_HOME/.local/state/omarchy/current/theme"
mkdir -p "$FAKE_BIN" "$CURRENT_THEME"

cat >"$FAKE_BIN/omarchy-cmd-present" <<'EOF'
#!/bin/bash
printf '%s\n' "$1" >>"$EDITOR_PROBE_LOG"
exit 1
EOF

cat >"$FAKE_BIN/omarchy-toggle-enabled" <<'EOF'
#!/bin/bash
exit 1
EOF

cat >"$FAKE_BIN/cursor" <<'EOF'
#!/bin/bash
touch "$CURSOR_SHIM_CALLED"
exit 1
EOF

chmod +x "$FAKE_BIN"/*
printf '{"name":"Hackerman","extension":"akamud.vscode-theme-onedark"}\n' >"$CURRENT_THEME/vscode.json"

EDITOR_PROBE_LOG="$TEST_HOME/editor-probes.log" \
  CURSOR_SHIM_CALLED="$TEST_HOME/cursor-shim-called" \
  PATH="$FAKE_BIN:$ROOT/bin:$PATH" \
  HOME="$TEST_HOME" \
  "$ROOT/bin/omarchy-theme-set-vscode"

grep -Fxq '/usr/bin/cursor' "$TEST_HOME/editor-probes.log" || fail "VS Code theme sync probes the packaged Cursor executable"
[[ ! -e $TEST_HOME/cursor-shim-called ]] || fail "VS Code theme sync ignores a PATH-provided Cursor Agent shim"
[[ ! -e $TEST_HOME/.config/Cursor/User/settings.json ]] || fail "VS Code theme sync skips Cursor when the packaged executable is unavailable"
pass "VS Code theme sync selects the packaged Cursor executable"

tpl="$ROOT/default/themed/vscode-theme.json.tpl"
rg -Fq '"comment": {"foreground": "{{ muted }}"' "$tpl" || fail "generated VS Code theme still uses muted for comments"
rg -Fq '"button.secondaryBackground": "{{ mix background foreground 12% }}"' "$tpl" ||
  fail "generated VS Code theme does not use muted as a secondary-button fill"
rg -Fq '"commandCenter.activeBackground": "{{ mix background foreground 12% }}"' "$tpl" ||
  fail "generated VS Code theme does not use muted as a command-center fill"
rg -Fq '"extensionButton.background": "{{ mix background foreground 12% }}"' "$tpl" ||
  fail "generated VS Code theme does not use muted as an extension-button fill"
pass "generated VS Code theme keeps muted for comment text, not button fills"
