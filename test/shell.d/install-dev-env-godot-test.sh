#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
stub_bin="$test_tmp/bin"
log_file="$test_tmp/log"
mkdir -p "$home" "$stub_bin"

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg-add' >>"$OMARCHY_TEST_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$OMARCHY_TEST_LOG"
done
printf '\n' >>"$OMARCHY_TEST_LOG"

if [[ $* == *godot* ]]; then
  cat >"$OMARCHY_TEST_STUB_BIN/godot" <<'GODOT'
#!/bin/bash
if [[ ${1:-} == "--version" ]]; then
  printf '4.7.2.stable.test\n'
  exit 0
fi
exit 0
GODOT
  chmod +x "$OMARCHY_TEST_STUB_BIN/godot"
fi
SH

cat >"$stub_bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
printf 'pkg-drop' >>"$OMARCHY_TEST_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$OMARCHY_TEST_LOG"
done
printf '\n' >>"$OMARCHY_TEST_LOG"
rm -f "$OMARCHY_TEST_STUB_BIN/godot"
SH

cat >"$stub_bin/update-desktop-database" <<'SH'
#!/bin/bash
printf 'update-desktop-database\t%s\n' "$*" >>"$OMARCHY_TEST_LOG"
SH

cat >"$stub_bin/code" <<'SH'
#!/bin/bash
printf 'code' >>"$OMARCHY_TEST_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$OMARCHY_TEST_LOG"
done
printf '\n' >>"$OMARCHY_TEST_LOG"
SH

cat >"$stub_bin/cursor" <<'SH'
#!/bin/bash
printf 'cursor' >>"$OMARCHY_TEST_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$OMARCHY_TEST_LOG"
done
printf '\n' >>"$OMARCHY_TEST_LOG"
SH

cat >"$stub_bin/nvim" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$stub_bin"/*

run_godot() {
  local action=$1
  shift
  HOME="$home" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_TEST_LOG="$log_file" \
    OMARCHY_TEST_STUB_BIN="$stub_bin" \
    "$ROOT/bin/omarchy-$action-dev-env" godot "$@" </dev/null
}

settings_file() {
  printf '%s' "$home/.config/godot/editor_settings-4.7.tres"
}

desktop_file() {
  printf '%s' "$home/.local/share/applications/org.godotengine.Godot.desktop"
}

nvim_lsp_file() {
  printf '%s' "$home/.config/nvim/after/plugin/omarchy-godot.lua"
}

: >"$log_file"
run_godot install >"$test_tmp/install.out"

grep -Fxq $'pkg-add\tgodot' "$log_file" || fail "godot install adds the godot package" "$(cat "$log_file")"
pass "godot install adds the godot package"

[[ -f $(desktop_file) ]] || fail "godot install writes a desktop file"
grep -Fxq 'Exec=godot --display-driver wayland %f' "$(desktop_file)" ||
  fail "godot install launches Godot on native Wayland" "$(cat "$(desktop_file)")"
grep -Fxq 'X-Omarchy-Managed=godot' "$(desktop_file)" ||
  fail "godot install marks the desktop file as Omarchy-managed"
pass "godot install writes a Wayland desktop entry"

[[ -f $(settings_file) ]] || fail "godot install writes editor settings for the installed version" "$(ls -A "$home/.config/godot" 2>/dev/null || true)"
grep -Fq 'run/platforms/linuxbsd/prefer_wayland = true' "$(settings_file)" ||
  fail "godot install prefers Wayland in editor settings" "$(cat "$(settings_file)")"
grep -Fq 'network/language_server/enable = true' "$(settings_file)" ||
  fail "godot install enables the GDScript language server" "$(cat "$(settings_file)")"
grep -Fq 'network/language_server/remote_port = 6005' "$(settings_file)" ||
  fail "godot install uses the default GDScript language server port" "$(cat "$(settings_file)")"
grep -Fq 'text_editor/external/use_external_editor = false' "$(settings_file)" ||
  fail "non-interactive godot install keeps the built-in editor" "$(cat "$(settings_file)")"
if grep -Fq 'omarchy-launch-tui' "$(settings_file)"; then
  fail "non-interactive godot install does not wire an external editor" "$(cat "$(settings_file)")"
fi
[[ ! -e $(nvim_lsp_file) ]] || fail "non-interactive godot install does not write a Neovim LSP snippet"
if grep -Fq $'code\t--install-extension' "$log_file"; then
  fail "non-interactive godot install does not install VSCode extensions" "$(cat "$log_file")"
fi
pass "godot install enables Wayland, LSP, and the built-in editor when non-interactive"

run_godot install >"$test_tmp/install-again.out"
settings_count=$(grep -c 'network/language_server/enable = true' "$(settings_file)")
(( settings_count == 1 )) || fail "godot install is idempotent for editor settings" "$(cat "$(settings_file)")"
pass "godot install is idempotent"

run_godot remove >"$test_tmp/remove.out"
grep -Fxq $'pkg-drop\tgodot' "$log_file" || fail "godot remove drops the godot package" "$(cat "$log_file")"
[[ ! -e $(desktop_file) ]] || fail "godot remove deletes the managed desktop file"
[[ ! -e $(nvim_lsp_file) ]] || fail "godot remove has no Neovim LSP snippet to delete"
[[ -f $(settings_file) ]] || fail "godot remove leaves editor settings in place"
pass "godot remove uninstalls the engine and Omarchy-managed files"

: >"$log_file"
run_godot install nvim >"$test_tmp/install-nvim.out"

grep -Fq 'text_editor/external/use_external_editor = true' "$(settings_file)" ||
  fail "godot install nvim enables the external editor" "$(cat "$(settings_file)")"
grep -Fq "text_editor/external/exec_path = \"$ROOT/bin/omarchy-launch-tui\"" "$(settings_file)" ||
  fail "godot install nvim opens scripts in a terminal" "$(cat "$(settings_file)")"
grep -Fq 'text_editor/external/exec_flags = "nvim +{line} {file}"' "$(settings_file)" ||
  fail "godot install nvim uses Neovim jump flags" "$(cat "$(settings_file)")"
if grep -Fq -- '--inline' "$(settings_file)"; then
  fail "godot install must not use --inline; Godot has no terminal" "$(cat "$(settings_file)")"
fi
[[ -f $(nvim_lsp_file) ]] || fail "godot install nvim writes a Neovim LSP snippet"
grep -Fq 'omarchy-godot-lsp: managed by omarchy-install-dev-env' "$(nvim_lsp_file)" ||
  fail "godot install nvim marks the Neovim LSP snippet"
pass "godot install nvim wires Neovim in a terminal"

run_godot remove >"$test_tmp/remove-nvim.out"
[[ ! -e $(nvim_lsp_file) ]] || fail "godot remove deletes the managed Neovim LSP snippet"
pass "godot remove deletes the managed Neovim LSP snippet"

mkdir -p "$home/.local/state/omarchy/defaults" "$home/.config/Code/User"
printf '%s\n' code >"$home/.local/state/omarchy/defaults/editor"
printf '%s\n' '{ "update.mode": "none" }' >"$home/.config/Code/User/settings.json"
: >"$log_file"
run_godot install >"$test_tmp/install-ignores-default.out"

grep -Fq 'text_editor/external/use_external_editor = false' "$(settings_file)" ||
  fail "non-interactive godot install ignores the Omarchy default editor" "$(cat "$(settings_file)")"
if grep -Fq $'code\t--install-extension' "$log_file"; then
  fail "non-interactive godot install does not follow the default editor" "$(cat "$log_file")"
fi
pass "non-interactive godot install ignores the Omarchy default editor"

: >"$log_file"
run_godot install code >"$test_tmp/install-code.out"

grep -Fq "text_editor/external/exec_path = \"$stub_bin/code\"" "$(settings_file)" ||
  fail "godot install code opens scripts in VSCode" "$(cat "$(settings_file)")"
grep -Fq 'text_editor/external/exec_flags = "--reuse-window {project} --goto {file}:{line}:{col}"' "$(settings_file)" ||
  fail "godot install code uses VSCode jump flags" "$(cat "$(settings_file)")"
grep -Fq $'code\t--install-extension\tgeeq1.godot-tools\t--force' "$log_file" ||
  fail "godot install code installs the Godot Tools VSCode extension" "$(cat "$log_file")"
jq -e '.["godotTools.lsp.headless"] == true and .["update.mode"] == "none"' \
  "$home/.config/Code/User/settings.json" >/dev/null ||
  fail "godot install merges Godot Tools settings without clobbering VSCode settings" \
    "$(cat "$home/.config/Code/User/settings.json")"
[[ ! -e $(nvim_lsp_file) ]] || fail "godot install code does not write a Neovim snippet"
pass "godot install code wires VSCode"

mkdir -p "$(dirname "$(nvim_lsp_file)")"
printf '%s\n' '-- user godot config' >"$(nvim_lsp_file)"
printf '%s\n' nvim >"$home/.local/state/omarchy/defaults/editor"
run_godot install nvim >"$test_tmp/install-keep-nvim.out"
grep -Fxq -- '-- user godot config' "$(nvim_lsp_file)" ||
  fail "godot install does not overwrite an unmanaged Neovim Godot config"
pass "godot install preserves an unmanaged Neovim Godot config"

run_godot remove >"$test_tmp/remove-keep-nvim.out"
[[ -f $(nvim_lsp_file) ]] || fail "godot remove keeps an unmanaged Neovim Godot config"
grep -Fxq -- '-- user godot config' "$(nvim_lsp_file)" ||
  fail "godot remove does not rewrite an unmanaged Neovim Godot config"
pass "godot remove keeps an unmanaged Neovim Godot config"

if PATH="$stub_bin:$ROOT/bin" HOME="$home" OMARCHY_PATH="$ROOT" \
  "$ROOT/bin/omarchy-install-dev-env" godot zed >"$test_tmp/install-zed.out" 2>"$test_tmp/install-zed.err" </dev/null; then
  fail "godot install rejects an editor that is not installed" "$(cat "$test_tmp/install-zed.out")"
fi
grep -Fq "not installed" "$test_tmp/install-zed.err" ||
  fail "godot install explains when the editor is missing" "$(cat "$test_tmp/install-zed.err")"
pass "godot install rejects an editor that is not installed"

cat >"$stub_bin/gum" <<'SH'
#!/bin/bash
printf 'gum' >>"$OMARCHY_TEST_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$OMARCHY_TEST_LOG"
done
printf '\n' >>"$OMARCHY_TEST_LOG"
cat >"$OMARCHY_TEST_STUB_BIN/gum.stdin"
printf '%s\n' 'Godot (built-in)'
SH
chmod +x "$stub_bin/gum"

if command -v script >/dev/null; then
  : >"$log_file"
  rm -f "$(settings_file)" "$stub_bin/gum.stdin"
  PATH="$stub_bin:$ROOT/bin:$PATH" \
    HOME="$home" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_TEST_LOG="$log_file" \
    OMARCHY_TEST_STUB_BIN="$stub_bin" \
    script -qefc "$ROOT/bin/omarchy-install-dev-env godot" /dev/null \
    >"$test_tmp/install-prompt.out" 2>"$test_tmp/install-prompt.err" ||
    fail "interactive godot install should succeed" "$(cat "$test_tmp/install-prompt.err")"
  grep -Fq $'gum\tchoose' "$log_file" ||
    fail "interactive godot install prompts with gum" "$(cat "$log_file"; cat "$test_tmp/install-prompt.err")"
  grep -Fq -- '--selected' "$log_file" ||
    fail "interactive godot install preselects an editor" "$(cat "$log_file")"
  grep -Fq $'\tNeovim' "$log_file" ||
    fail "interactive godot install preselects the Omarchy default editor" "$(cat "$log_file")"
  grep -Fxq 'Godot (built-in)' "$stub_bin/gum.stdin" ||
    fail "interactive godot install offers the built-in editor" "$(cat "$stub_bin/gum.stdin" 2>/dev/null || true)"
  grep -Fxq Neovim "$stub_bin/gum.stdin" ||
    fail "interactive godot install offers installed Neovim" "$(cat "$stub_bin/gum.stdin" 2>/dev/null || true)"
  grep -Fq 'text_editor/external/use_external_editor = false' "$(settings_file)" ||
    fail "interactive godot install honors the gum choice" "$(cat "$(settings_file)")"
  pass "interactive godot install prompts for an installed editor"
else
  pass "no script(1); skipping interactive godot editor prompt"
fi

grep -Fq 'org\\.godotengine\\.Godot' "$ROOT/default/hypr/apps/godot.lua" ||
  fail "Hyprland ships Godot window rules"
grep -Fq 'prefer_wayland' "$ROOT/bin/omarchy-install-dev-env" ||
  fail "godot install prefers Wayland in editor settings"
pass "Hyprland window rules cover the Godot editor and game windows"
