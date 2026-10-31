#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

real_mise=$(type -P mise || true)

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
agent_file="$test_home/.config/omarchy/defaults/agent"
notification_history="$test_tmp/notification-history"
agent_open_log="$test_tmp/agent-open"
launch_log="$test_tmp/launch"
inline_log="$test_tmp/inline"
mise_log="$test_tmp/mise"
mise_history="$test_tmp/mise-history"
stub_log="$test_tmp/stubs"
terminal_log="$test_tmp/terminal"
menu_log="$test_tmp/menu"
muse_login_log="$test_tmp/muse-login"
clipboard_log="$test_tmp/clipboard"
mkdir -p "$mock_bin" "$test_home"

cat >"$mock_bin/omarchy-install-chromium-claude" <<'SH'
#!/bin/bash
echo claude-extension >>"$OMARCHY_TEST_STUB_LOG"
if [[ ${OMARCHY_TEST_EXTENSION_FAIL:-false} == "true" ]]; then
  echo "Extension installation failed" >&2
  exit 1
fi
SH

cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >>"$OMARCHY_TEST_NOTIFICATION_HISTORY"
SH

cat >"$mock_bin/wl-copy" <<'SH'
#!/bin/bash
cat >"$OMARCHY_TEST_CLIPBOARD"
SH

cat >"$mock_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
[[ $1 == ${OMARCHY_TEST_MISSING_COMMAND:-} ]]
SH

cat >"$mock_bin/omarchy-launch-tui" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_AGENT_LAUNCH_LOG"
SH

cat >"$mock_bin/omarchy-launch-floating-terminal-with-presentation" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_AGENT_TERMINAL_LOG"
SH

cat >"$mock_bin/opencode" <<'SH'
#!/bin/bash
printf '%s\0' opencode "$@" >"$OMARCHY_TEST_AGENT_INLINE_LOG"
SH

cat >"$mock_bin/omarchy-mise-install" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_STUB_LOG"
SH

cat >"$mock_bin/mise" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_MISE_LOG"
printf '%s\n' "$*" >>"$OMARCHY_TEST_MISE_HISTORY"
if [[ -n ${MISE_PRERELEASES:-} ]]; then
  printf 'prereleases=%s %s\n' "$MISE_PRERELEASES" "$*" >>"$OMARCHY_TEST_MISE_HISTORY"
fi

if [[ $1 == "tool" && $3 == "--backend" ]]; then
  case "$2" in
  npm:*) printf '%s\n' "$2" ;;
  amp) printf '%s\n' "npm:@ampcode/cli" ;;
  qwen) printf '%s\n' "npm:@qwen-code/qwen-code" ;;
  *) printf '%s\n' "aqua:example/$2" ;;
  esac
  exit 0
fi

if [[ $1 == "settings" && $2 == "disable_tools" && $3 == "--json" ]]; then
  if [[ ${OMARCHY_TEST_AGENT_DISABLED:-false} == "true" ]]; then
    printf '["pi"]\n'
  else
    printf '[]\n'
  fi
  exit 0
fi

if [[ $1 == "tool" && $3 == "--requested" ]]; then
  if [[ ${OMARCHY_TEST_AGENT_UNMANAGED:-false} == "true" ]]; then
    printf 'null\n'
  else
    printf '["1.0.0"]\n'
  fi
  exit 0
fi

if [[ $1 == "ls" ]]; then
  if [[ ${OMARCHY_TEST_AGENT_UNMANAGED:-false} == "true" ]]; then
    printf '[]\n'
  else
    printf '[{"version":"1.0.0","installed":false}]\n'
  fi
  exit 0
fi

if [[ $1 == "where" || $1 == "which" ]]; then
  [[ ${OMARCHY_TEST_AGENT_INSTALLED:-false} == "true" ]]
  exit
fi

[[ ${OMARCHY_TEST_MISE_FAIL:-false} != "true" ]]
SH

cat >"$mock_bin/omarchy-menu" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_AGENT_MENU_LOG"
SH

cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
echo "Muse must install through mise" >&2
exit 1
SH
ln -s omarchy-pkg-add "$mock_bin/omarchy-pkg-aur-add"

cat >"$mock_bin/muse" <<'SH'
#!/bin/bash
if [[ ${1:-} == "login" ]]; then
  printf 'muse %s\n' "$*" >>"$OMARCHY_TEST_MUSE_LOGIN_LOG"
else
  printf '%s\0' muse "$@" >"$OMARCHY_TEST_AGENT_INLINE_LOG"
fi
SH

cat >"$mock_bin/omarchy-test-noop" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH

for command in gum hyprctl omarchy-webapp-remove-all omarchy-tui-remove-all omarchy-pkg-drop; do
  ln -s omarchy-test-noop "$mock_bin/$command"
done

chmod +x "$mock_bin"/*

export HOME="$test_home"
export PATH="$mock_bin:$ROOT/bin:$test_home/.local/bin:$PATH"
export OMARCHY_TEST_NOTIFICATION_HISTORY="$notification_history"
export OMARCHY_TEST_AGENT_OPEN_LOG="$agent_open_log"
export OMARCHY_TEST_AGENT_LAUNCH_LOG="$launch_log"
export OMARCHY_TEST_AGENT_INLINE_LOG="$inline_log"
export OMARCHY_TEST_MISE_LOG="$mise_log"
export OMARCHY_TEST_MISE_HISTORY="$mise_history"
export OMARCHY_TEST_STUB_LOG="$stub_log"
export OMARCHY_TEST_AGENT_TERMINAL_LOG="$terminal_log"
export OMARCHY_TEST_AGENT_MENU_LOG="$menu_log"
export OMARCHY_TEST_MUSE_LOGIN_LOG="$muse_login_log"
export OMARCHY_TEST_CLIPBOARD="$clipboard_log"
export OMARCHY_PATH="$ROOT"
export OMARCHY_MISE_CONFIG_PATH="$test_tmp/etc/mise/config.toml"

grok_package="grok"
omp_package="oh-my-pi"
crush_package="crush"
agy_package="antigravity-cli"
ori_package="ori"
kimi_package="npm:@moonshot-ai/kimi-code"
qwen_package="qwen"
dsh_package="npm:@deepseek-ai/dsh"
# Omarchy declares a tool with backend options under its bare name; the
# bracketed package is what a user without the declarations gets.
mcode_tool="npm:@minimax-ai/code"
mcode_package="$mcode_tool[allow_builds=better-sqlite3]"
kiro_cli_tool="http:kiro-cli"
kiro_cli_package="$kiro_cli_tool[platforms_linux_x64_url=https://prod.download.cli.kiro.dev/stable/{{version}}/kirocli-x86_64-linux.tar.gz,platforms_linux_arm64_url=https://prod.download.cli.kiro.dev/stable/{{version}}/kirocli-aarch64-linux.tar.gz,version_list_url=https://prod.download.cli.kiro.dev/stable/latest/manifest.json,version_json_path=.version]"
freebuff_package="npm:freebuff"
kilo_package="npm:@kilocode/cli"
devin_tool="http:devin"
devin_package="$devin_tool[platforms_linux_x64_url=https://static.devin.ai/cli/{{ version }}/devin-{{ version }}-x86_64-unknown-linux.tar.gz,platforms_linux_arm64_url=https://static.devin.ai/cli/{{ version }}/devin-{{ version }}-aarch64-unknown-linux.tar.gz,bin_path=bin,version_list_url=https://static.devin.ai/cli/current/manifest.json,version_json_path=.version]"
amp_package="amp"
commandcode_package="npm:command-code"
cursor_agent_package="cursor-agent"
muse_package="muse"

assert_lazy_stub() {
  local package=$1
  local command=$2

  : >"$mise_history"
  "$ROOT/bin/omarchy-mise-install" "$package" "$command"
  "$test_home/.local/bin/$command" --version
  mapfile -t mise_calls <"$mise_history"

  [[ ${mise_calls[0]} == "use -g --quiet $package" && ${mise_calls[1]} == "x $package -- $command --version" ]] ||
    fail "$command lazy stub preserves its mise package"
}

assert_lazy_stub "$grok_package" grok
assert_lazy_stub "$omp_package" omp
assert_lazy_stub "$crush_package" crush
assert_lazy_stub "$ori_package" ori
assert_lazy_stub "$kimi_package" kimi
assert_lazy_stub "$cursor_agent_package" cursor-agent
assert_lazy_stub "$muse_package" muse
pass "custom agent lazy stubs preserve their mise packages"

source "$ROOT/install/user/mise.sh"
lazy_config="$ROOT/etc/mise/conf.d/omarchy-tools.toml"
[[ -f $lazy_config ]] || fail "Omarchy ships the system mise config"
grep -Fx 'locked_scopes = ["project", "global"]' "$lazy_config" >/dev/null ||
  fail "system tools remain installable when the user enables locked mode"
for tool in "$agy_package" "$grok_package" "$omp_package" "$crush_package" "$cursor_agent_package" "$muse_package"; do
  grep -Eq "^$tool = \\{ version = \"latest\", lazy = true, auto_update = \"4h\", minimum_release_age = \"0s\" \\}$" "$lazy_config" ||
    fail "user setup declares $tool as a self-updating native lazy tool"
done
for tool in "$ori_package" basecamp; do
  grep -Eq "^$tool = \\{ version = \"latest\", lazy = true, minimum_release_age = \"0s\" \\}$" "$lazy_config" ||
    fail "user setup declares $tool as a native lazy tool"
done
for tool in codex claude copilot opencode pi "\"$kimi_package\""; do
  grep -Eq "^$tool = \\{ version = \"latest\", lazy = true, auto_update = \"4h\", " "$lazy_config" ||
    fail "user setup declares $tool as a self-updating native lazy tool"
done
grep -Eq "^$qwen_package = \\{ version = \"latest\", lazy = true, auto_update = \"4h\", minimum_release_age = \"0s\" \\}$" "$lazy_config" ||
  fail "user setup declares Qwen Code as a self-updating native lazy tool"
# A tool without registry bin metadata names the commands mise shims for it.
declare -A declared_bins=(
  [$amp_package]='"amp"'
  ["\"$dsh_package\""]='"dsh"'
  ["\"$freebuff_package\""]='"freebuff"'
  ["\"$kilo_package\""]='"kilo"'
  ["\"$commandcode_package\""]='"commandcode"'
)
for tool in "${!declared_bins[@]}"; do
  grep -Fx "$tool = { version = \"latest\", lazy = true, auto_update = \"4h\", lazy_bins = [${declared_bins[$tool]}], minimum_release_age = \"0s\" }" "$lazy_config" >/dev/null ||
    fail "user setup declares $tool as a self-updating native lazy tool with its commands"
done
# mise drops bracket options from a table-valued key, so a tool with backend
# options is declared by its bare name with the options inside the table: the
# same options the launcher hands a user without the declarations.
declare -A declared_option_bins=(
  [mcode]='"mcode"'
  [kiro_cli]='"kiro-cli"'
  [devin]='"devin"'
)
for agent in "${!declared_option_bins[@]}"; do
  tool_var="${agent}_tool"
  package_var="${agent}_package"
  declaration=$(grep -F "\"${!tool_var}\" = { version = \"latest\", lazy = true, auto_update = \"4h\", lazy_bins = [${declared_option_bins[$agent]}], minimum_release_age = \"0s\", " "$lazy_config") ||
    fail "user setup declares ${!tool_var} as a self-updating native lazy tool with its commands"
  options=${!package_var#*[}
  IFS=, read -ra options <<<"${options%]}"
  for option in "${options[@]}"; do
    [[ $declaration == *" ${option%%=*} = \"${option#*=}\""* ]] ||
      fail "user setup declares ${!tool_var} with ${option%%=*} inside its table"
  done
done
[[ $(grep -c 'auto_update = "4h"' "$lazy_config") == 21 ]] || fail "only the agent CLIs update themselves"
for tool in node uv; do
  grep -Eq "^$tool = \\{ version = \"latest\", lazy = true, minimum_release_age = \"0s\" \\}$" "$lazy_config" ||
    fail "user setup declares $tool as a native lazy tool"
done
[[ $(grep -c 'lazy = true' "$lazy_config") == 31 ]] || fail "user setup declares every default mise tool as lazy"
grep -Fx "reshim --system" "$mise_history" >/dev/null || fail "user setup builds the system lazy bootstrap shims"
pass "user setup configures system lazy tools from registry shorthands"
: >"$stub_log"
source "$ROOT/install/user/mise.sh"
[[ ! -s $stub_log ]] || fail "user setup must not create handwritten mise wrappers"
pass "user setup leaves ordinary lazy wrappers to mise"

"$ROOT/bin/omarchy-mise-install" "$muse_package" muse
"$ROOT/bin/omarchy-mise-install" "$kimi_package" kimi
"$ROOT/bin/omarchy-mise-install" "$cursor_agent_package" cursor-agent
"$ROOT/bin/omarchy-mise-install" "$grok_package" grok
"$ROOT/bin/omarchy-mise-install" "$omp_package" omp
"$ROOT/bin/omarchy-mise-install" "$crush_package" crush
touch "$test_home/.local/bin/agy" "$test_home/.local/bin/ori"
omarchy-remove-preinstalls >/dev/null
for command in agy omp ori grok crush cursor-agent muse kimi; do
  [[ ! -e $test_home/.local/bin/$command ]] || fail "Remove Preinstalls deletes the $command lazy stub"
done
pass "Remove Preinstalls deletes every optional agent lazy stub"

# Cursor's installer links the same path, so anything but the mise wrapper is
# the user's own install.
touch "$test_home/.local/bin/cursor-agent.official"
ln -s cursor-agent.official "$test_home/.local/bin/cursor-agent"
omarchy-remove-preinstalls >/dev/null
[[ -L $test_home/.local/bin/cursor-agent ]] || fail "Remove Preinstalls keeps an official Cursor CLI install"
rm -f "$test_home/.local/bin/cursor-agent" "$test_home/.local/bin/cursor-agent.official"
pass "Remove Preinstalls keeps an official Cursor CLI install"
printf '#!/bin/bash\necho user-muse\n' >"$test_home/.local/bin/muse"
chmod +x "$test_home/.local/bin/muse"
omarchy-remove-preinstalls >/dev/null
[[ $("$test_home/.local/bin/muse") == "user-muse" ]] || fail "Remove Preinstalls deletes a user-managed Muse"
rm "$test_home/.local/bin/muse"
pass "Remove Preinstalls keeps a user-managed Muse install"


[[ -z $(omarchy-default-agent) ]] || fail "default agent is unset until one is chosen"
pass "default agent is unset until one is chosen"

: >"$launch_log"
if omarchy-agent >"$test_tmp/no-agent-output" 2>&1; then
  fail "agent launcher refuses to launch without a default"
fi
grep -Fq "Choose default agent with" "$test_tmp/no-agent-output" ||
  fail "agent launcher explains that no default is set"
[[ ! -s $launch_log ]] || fail "agent launcher starts nothing without a default"
pass "agent launcher refuses to launch without a default"

# The keybinding uses --pick, where an error on stderr nobody sees would make
# the keypress look broken. It offers the choice instead.
: >"$launch_log"
: >"$menu_log"
omarchy-agent --pick
mapfile -d '' -t menu_args <"$menu_log"
[[ ${menu_args[*]} == "summon setup.default.agent" ]] ||
  fail "--pick opens the agent defaults menu when none is set"
[[ ! -s $launch_log ]] || fail "--pick starts nothing when no agent is set"
pass "--pick opens the agent defaults menu when none is set"

source "$ROOT/default/bash/aliases"
[[ $(alias a) == "alias a='omarchy-agent --inline'" ]] ||
  fail "terminal alias launches the default agent inline"
pass "terminal alias launches the default agent inline"

grep -Fq 'o.bind("SUPER + SHIFT + CTRL + A", "Agent", "omarchy-agent --pick")' \
  "$ROOT/default/hypr/bindings/utilities.lua" ||
  fail "agent launcher has a keyboard shortcut"
pass "agent launcher has a keyboard shortcut"

cat >"$mock_bin/omarchy-agent" <<'SH'
#!/bin/bash
printf '%s\0' omarchy-agent "$@" >"$OMARCHY_TEST_AGENT_OPEN_LOG"
SH
chmod +x "$mock_bin/omarchy-agent"
hash -r

declare -A expected_agents=(
  [pi]="pi"
  [omp]="omp"
  [oh-my-pi]="omp"
  [opencode]="opencode"
  [open-code]="opencode"
  [ori]="ori"
  [openrouter]="ori"
  [claude]="claude"
  [claude-code]="claude"
  [codex]="codex"
  [crush]="crush"
  [grok]="grok"
  [agy]="agy"
  [antigravity]="agy"
  [antigravity-cli]="agy"
  [gemini]="agy"
  [gemini-cli]="agy"
  [copilot]="copilot"
  [github-copilot]="copilot"
  [kimi]="kimi"
  [kimi-code]="kimi"
  [qwen]="qwen"
  [qwen-code]="qwen"
  [dsh]="dsh"
  [deepseek]="dsh"
  [deepseek-harness]="dsh"
  [mcode]="mcode"
  [minimax-code]="mcode"
  [minimax]="mcode"
  [kiro-cli]="kiro-cli"
  [kiro]="kiro-cli"
  [freebuff]="freebuff"
  [kilo]="kilo"
  [kilocode]="kilo"
  [kilo-code]="kilo"
  [devin]="devin"
  [devin-cli]="devin"
  [amp]="amp"
  [ampcode]="amp"
  [commandcode]="commandcode"
  [command-code]="commandcode"
  [cmdc]="commandcode"
  [cursor]="cursor-agent"
  [cursor-agent]="cursor-agent"
  [muse]="muse"
  [muse-code]="muse"
  [musecode]="muse"
)

declare -A expected_packages=(
  [pi]="pi"
  [omp]="$omp_package"
  [opencode]="opencode"
  [ori]="$ori_package"
  [claude]="claude"
  [codex]="codex"
  [crush]="$crush_package"
  [grok]="$grok_package"
  [agy]="$agy_package"
  [copilot]="copilot"
  [kimi]="$kimi_package"
  [qwen]="$qwen_package"
  [dsh]="$dsh_package"
  [mcode]="$mcode_package"
  [kiro-cli]="$kiro_cli_package"
  [freebuff]="$freebuff_package"
  [kilo]="$kilo_package"
  [devin]="$devin_package"
  [amp]="$amp_package"
  [commandcode]="$commandcode_package"
  [cursor-agent]="$cursor_agent_package"
  [muse]="$muse_package"
)

for selection in "${!expected_agents[@]}"; do
  expected=${expected_agents[$selection]}
  : >"$agent_open_log"
  : >"$stub_log"
  OMARCHY_TEST_AGENT_INSTALLED=true omarchy-default-agent "$selection"
  [[ $(omarchy-default-agent) == $expected ]] || fail "default agent canonicalizes $selection"

  if [[ $expected == "claude" ]]; then
    grep -qx claude-extension "$stub_log" || fail "Claude selection installs the browser extension"
  else
    [[ ! -s $stub_log ]] || fail "other agents do not install the Claude extension"
  fi

  mapfile -d '' -t mise_args <"$mise_log"
  [[ ${mise_args[0]} == "use" && ${mise_args[1]} == "-g" ]] ||
    fail "default agent installs $selection globally through mise"
  case ${mise_args[2]} in
    "${expected_packages[$expected]}") ;;
    *) fail "default agent preserves $selection backend options" ;;
  esac

  mapfile -d '' -t agent_open_args <"$agent_open_log"
  [[ ${#agent_open_args[@]} == 1 && ${agent_open_args[0]} == "omarchy-agent" ]] ||
    fail "default agent opens $selection after selecting it"
done
pass "default agent selects and opens every supported provider and alias"
[[ -f $agent_file && ! -e $test_home/.local/state/omarchy/defaults/agent ]] ||
  fail "default agent stores its selection in Omarchy user config"
pass "default agent stores its selection in Omarchy user config"

OMARCHY_TEST_AGENT_INSTALLED=true omarchy-default-agent pi
: >"$agent_open_log"
OMARCHY_TEST_AGENT_INSTALLED=true OMARCHY_TEST_EXTENSION_FAIL=true omarchy-default-agent claude >"$test_tmp/extension-failure" 2>&1
[[ $(omarchy-default-agent) == "claude" ]] || fail "extension installation failure still selects Claude"
mapfile -d '' -t agent_open_args <"$agent_open_log"
[[ ${agent_open_args[*]} == "omarchy-agent" ]] || fail "extension installation failure still launches Claude"
[[ ! -s $test_tmp/extension-failure ]] || fail "extension installation failure is silent"
pass "extension installation failure silently continues selecting and launching Claude"
OMARCHY_TEST_AGENT_INSTALLED=true omarchy-default-agent pi
: >"$notification_history"
: >"$agent_open_log"
: >"$terminal_log"
omarchy-default-agent github-copilot
mapfile -d '' -t terminal_args <"$terminal_log"
[[ ${terminal_args[0]} == "omarchy-default-agent" && ${terminal_args[1]} == "--install" && ${terminal_args[2]} == "copilot" ]] ||
  fail "missing agent installation opens in a terminal"
[[ ! -s $notification_history ]] || fail "missing agent installation skips notifications"
[[ ! -s $agent_open_log ]] || fail "missing agent installation waits to open the agent"
[[ $(omarchy-default-agent) == "pi" ]] || fail "missing agent installation waits to change the selection"

omarchy-default-agent --install github-copilot >"$test_tmp/install-output"
mapfile -d '' -t mise_args <"$mise_log"
[[ ${mise_args[0]} == "use" && ${mise_args[1]} == "-g" && ${mise_args[2]} == "copilot" ]] ||
  fail "visible agent installation activates the provider globally through mise"
[[ $(omarchy-default-agent) == "copilot" ]] || fail "visible agent installation changes the selection after mise succeeds"
[[ ! -s $notification_history ]] || fail "visible agent installation leaves progress to the terminal"
[[ $(<"$test_tmp/install-output") == $'\033[2J\033[3J\033[H' ]] ||
  fail "visible agent installation clears its terminal before opening the agent"
mapfile -d '' -t agent_open_args <"$agent_open_log"
[[ ${#agent_open_args[@]} == 2 && ${agent_open_args[0]} == "omarchy-agent" && ${agent_open_args[1]} == "--inline" ]] ||
  fail "newly installed agent opens in the installation terminal"
pass "missing agents install visibly and open in the same terminal"

: >"$notification_history"
: >"$agent_open_log"
: >"$terminal_log"
OMARCHY_TEST_AGENT_INSTALLED=true omarchy-default-agent github-copilot
[[ ! -s $terminal_log ]] || fail "installed agent selection skips the terminal"
[[ ! -s $notification_history ]] || fail "installed agent selection skips notifications"
mapfile -d '' -t mise_args <"$mise_log"
[[ ${mise_args[0]} == "use" && ${mise_args[1]} == "-g" && ${mise_args[2]} == "copilot" ]] ||
  fail "default agent still activates an installed provider globally through mise"
mapfile -d '' -t agent_open_args <"$agent_open_log"
[[ ${#agent_open_args[@]} == 1 && ${agent_open_args[0]} == "omarchy-agent" ]] ||
  fail "installed agent opens in a new terminal after selection"
pass "installed agents select and open without notifications"

# An explicitly unmanaged Cursor can use its official installation.
touch "$test_home/.local/bin/cursor-agent.official"
chmod +x "$test_home/.local/bin/cursor-agent.official"
ln -s cursor-agent.official "$test_home/.local/bin/cursor-agent"
: >"$terminal_log"
: >"$mise_log"
: >"$mise_history"
: >"$agent_open_log"
OMARCHY_TEST_AGENT_UNMANAGED=true omarchy-default-agent cursor-agent
[[ ! -s $terminal_log ]] || fail "an official Cursor CLI install needs no install terminal"
if grep -qE "^(install|use) " "$mise_history"; then
  fail "an opted-out Cursor CLI install is left to itself by mise"
fi
[[ $(<"$agent_file") == "cursor-agent" ]] || fail "an official Cursor CLI install becomes the default"
mapfile -d '' -t agent_open_args <"$agent_open_log"
[[ ${#agent_open_args[@]} == 1 && ${agent_open_args[0]} == "omarchy-agent" ]] ||
  fail "an official Cursor CLI install opens after selection"
# The same executable must not suppress installation of a configured tool.
: >"$terminal_log"
omarchy-default-agent cursor-agent
mapfile -d '' -t terminal_args <"$terminal_log"
[[ ${terminal_args[*]} == "omarchy-default-agent --install cursor-agent" ]] ||
  fail "a local executable does not opt a configured agent out of mise"
rm -f "$test_home/.local/bin/cursor-agent" "$test_home/.local/bin/cursor-agent.official"
printf '%s\n' copilot >"$agent_file"
pass "selecting an official Cursor CLI install skips mise"

# A file nothing can run is not an install; the wrapper is still wanted.
touch "$test_home/.local/bin/cursor-agent"
: >"$terminal_log"
omarchy-default-agent cursor-agent
mapfile -d '' -t terminal_args <"$terminal_log"
[[ ${terminal_args[*]} == "omarchy-default-agent --install cursor-agent" ]] ||
  fail "a dead file at the wrapper's path still installs Cursor CLI"
rm -f "$test_home/.local/bin/cursor-agent"
pass "a dead file at the wrapper's path does not pass for an install"

: >"$agent_open_log"
if omarchy-default-agent unsupported >"$test_tmp/invalid-output" 2>&1; then
  fail "default agent rejects unsupported providers"
fi
grep -F "Usage: omarchy-default-agent" "$test_tmp/invalid-output" >/dev/null ||
  fail "default agent explains supported providers"
[[ $(omarchy-default-agent) == "copilot" ]] || fail "invalid selection preserves the current default agent"
[[ ! -s $agent_open_log ]] || fail "invalid selection does not open an agent"
pass "default agent rejects unsupported providers without changing the selection"

: >"$notification_history"
: >"$agent_open_log"
if OMARCHY_TEST_MISE_FAIL=true omarchy-default-agent --install codex >"$test_tmp/install-failure-output" 2>&1; then
  fail "default agent rejects a failed mise installation"
fi
[[ $(omarchy-default-agent) == "copilot" ]] || fail "failed installation preserves the current default agent"
grep -F "Could not install Codex with mise" "$test_tmp/install-failure-output" >/dev/null ||
  fail "default agent reports a failed mise installation in the terminal"
[[ ! -s $notification_history ]] || fail "failed visible agent installation skips notifications"
[[ ! -s $agent_open_log ]] || fail "failed installation does not open an agent"
pass "default agent opens only after mise installs the provider"

: >"$notification_history"
: >"$agent_open_log"
if OMARCHY_TEST_AGENT_INSTALLED=true OMARCHY_TEST_MISE_FAIL=true omarchy-default-agent codex >"$test_tmp/setup-failure-output" 2>&1; then
  fail "default agent rejects a failed mise activation"
fi
[[ $(omarchy-default-agent) == "copilot" ]] || fail "failed activation preserves the current default agent"
grep -F "Could not set Codex as the default coding agent" "$test_tmp/setup-failure-output" >/dev/null ||
  fail "default agent reports a failed activation for an installed provider"
[[ ! -s $notification_history ]] || fail "failed activation skips notifications"
[[ ! -s $agent_open_log ]] || fail "failed activation does not open an agent"
pass "default agent reports mise failures without notifications"

# Muse follows the shared mise installation and launch path.
: >"$notification_history"
: >"$agent_open_log"
: >"$terminal_log"
omarchy-default-agent muse
mapfile -d '' -t terminal_args <"$terminal_log"
[[ ${terminal_args[0]} == "omarchy-default-agent" && ${terminal_args[1]} == "--install" && ${terminal_args[2]} == "muse" ]] ||
  fail "missing Muse installation opens in a terminal"
[[ ! -s $notification_history ]] || fail "missing Muse installation skips notifications"
[[ ! -s $agent_open_log ]] || fail "missing Muse installation waits to open the agent"
[[ $(omarchy-default-agent) == "copilot" ]] || fail "missing Muse installation waits to change the selection"

if OMARCHY_TEST_MISE_FAIL=true omarchy-default-agent --install muse >"$test_tmp/muse-install-failure-output" 2>&1; then
  fail "missing Muse rejects a failed mise installation"
fi
[[ $(omarchy-default-agent) == "copilot" ]] || fail "failed Muse installation preserves the current default"
[[ ! -s $muse_login_log && ! -s $agent_open_log ]] || fail "failed Muse installation skips login and launch"
grep -F "Could not install Muse Code with mise" "$test_tmp/muse-install-failure-output" >/dev/null ||
  fail "failed Muse installation identifies mise"
pass "failed Muse mise installation preserves the selection and skips login"

# Without Omarchy's declarations nothing declares Muse, so selecting it adds it
# to the user's config.
: >"$mise_history"
omarchy-default-agent --install muse >/dev/null
grep -Fx "use -g $muse_package" "$mise_history" >/dev/null ||
  fail "Muse selection adds Muse to the user config when no system config declares it"
rm -f "$agent_file"

# mise skips the declarations for a user who removed the preinstalls, so the
# same applies.
mkdir -p "$(dirname "$OMARCHY_MISE_CONFIG_PATH")" "$test_home/.config/mise"
cp "$ROOT/etc/mise/conf.d/omarchy-tools.toml" "$OMARCHY_MISE_CONFIG_PATH"
printf 'ignored_config_paths = ["%s"]\n' "$OMARCHY_MISE_CONFIG_PATH" >"$test_home/.config/mise/miserc.toml"
: >"$mise_history"
omarchy-default-agent --install muse >/dev/null
grep -Fx "use -g $muse_package" "$mise_history" >/dev/null ||
  fail "Muse selection adds Muse to the user config after Remove Preinstalls"
# Every DSH release is a prerelease, which `mise use` skips unless told otherwise.
: >"$mise_history"
omarchy-default-agent --install dsh >/dev/null
grep -Fx "prereleases=true use -g $dsh_package" "$mise_history" >/dev/null ||
  fail "DSH selection lets mise pick a prerelease after Remove Preinstalls"
: >"$mise_history"
omarchy-default-agent --install kilo >/dev/null
grep -q '^prereleases=' "$mise_history" && fail "other agents install only stable releases after Remove Preinstalls"
# An npm-backed agent brings node along here too, since node may still be
# declared without being installed; Muse isn't npm-backed and doesn't.
node_line=$(grep -nx "install node" "$mise_history" | cut -d: -f1)
kilo_line=$(grep -nFx "use -g $kilo_package" "$mise_history" | cut -d: -f1)
[[ -n $node_line && -n $kilo_line ]] && (( node_line < kilo_line )) ||
  fail "an npm-backed agent installs node before it after Remove Preinstalls"
: >"$mise_history"
omarchy-default-agent --install muse >/dev/null
grep -qx "install node" "$mise_history" && fail "an agent that isn't npm-backed installs no node after Remove Preinstalls"
rm -f "$agent_file" "$test_home/.config/mise/miserc.toml"

# With Omarchy's system config, installing is enough; the user config stays alone.
: >"$mise_history"
: >"$stub_log"
omarchy-default-agent --install muse >"$test_tmp/muse-install-output"
grep -Fx "install $muse_package" "$mise_history" >/dev/null || fail "visible Muse installation uses the registry shorthand"
grep -q '^use ' "$mise_history" && fail "Muse selection leaves the user config alone when the system config declares it"
[[ ! -s $stub_log ]] || fail "Muse selection recreates its preinstalled wrapper"
[[ ! -s $muse_login_log ]] || fail "Muse selection runs a separate login flow"
[[ $(omarchy-default-agent) == "muse" ]] || fail "visible Muse installation changes the selection"
mapfile -d '' -t agent_open_args <"$agent_open_log"
[[ ${#agent_open_args[@]} == 2 && ${agent_open_args[0]} == "omarchy-agent" && ${agent_open_args[1]} == "--inline" ]] ||
  fail "newly installed Muse opens in the installation terminal"
pass "Muse installs visibly through mise and opens directly"

saved_agent=$(<"$agent_file")
for agent in qwen dsh mcode kiro-cli freebuff kilo devin amp commandcode; do
  tool_var="${agent//-/_}_tool"
  package_var="${agent//-/_}_package"
  declared_tool=${!tool_var:-${!package_var}}
  : >"$mise_history"
  omarchy-default-agent --install "$agent" >/dev/null
  # npm-backed agents bring node along, which a fresh machine doesn't have yet.
  case "$agent" in
  kiro-cli | devin) expected_install="install $declared_tool" ;;
  *) expected_install="install node $declared_tool" ;;
  esac
  grep -Fx "$expected_install" "$mise_history" >/dev/null || fail "visible $agent installation installs Omarchy's declaration (expected: $expected_install)"
  : >"$mise_history"
  OMARCHY_TEST_AGENT_INSTALLED=true omarchy-default-agent "$agent" >/dev/null
  grep -Fx "where $declared_tool" "$mise_history" >/dev/null || fail "$agent selection looks for Omarchy's declaration"
  grep -q '^use ' "$mise_history" && fail "$agent selection leaves the user config alone when the system config declares it"
  [[ $(omarchy-default-agent) == "$agent" ]] || fail "visible $agent installation changes the selection"
done
printf '%s\n' "$saved_agent" >"$agent_file"
pass "the added agents install through Omarchy's mise declarations"

: >"$terminal_log"
: >"$muse_login_log"
: >"$agent_open_log"
OMARCHY_TEST_AGENT_INSTALLED=true omarchy-default-agent muse-code
[[ ! -s $terminal_log ]] || fail "installed Muse selection skips the terminal"
[[ ! -s $muse_login_log ]] || fail "installed Muse selection skips the login"
[[ $(omarchy-default-agent) == "muse" ]] || fail "default agent canonicalizes muse-code"
mapfile -d '' -t agent_open_args <"$agent_open_log"
[[ ${#agent_open_args[@]} == 1 && ${agent_open_args[0]} == "omarchy-agent" ]] ||
  fail "installed Muse opens in a new terminal after selection"
pass "installed Muse selects and opens directly"

OMARCHY_TEST_AGENT_INSTALLED=true omarchy-default-agent pi
: >"$agent_open_log"
if OMARCHY_TEST_AGENT_INSTALLED=true OMARCHY_TEST_MISE_FAIL=true omarchy-default-agent musecode >"$test_tmp/muse-failure-output" 2>&1; then
  fail "default agent rejects a failed Muse activation"
fi
[[ $(omarchy-default-agent) == "pi" ]] || fail "failed Muse activation preserves the current default agent"
grep -F "Could not set Muse Code as the default coding agent" "$test_tmp/muse-failure-output" >/dev/null ||
  fail "default agent reports a failed Muse activation"
[[ ! -s $agent_open_log ]] || fail "failed Muse activation does not open an agent"
pass "default agent reports Muse mise failures without changing the selection"

# A manually installed launcher belongs to the user; selecting it must not
# install a second copy or replace it with the Omarchy wrapper.
printf '#!/bin/bash\necho user-muse\n' >"$test_home/.local/bin/muse"
chmod +x "$test_home/.local/bin/muse"
: >"$mise_history"
: >"$stub_log"
: >"$terminal_log"
OMARCHY_TEST_AGENT_UNMANAGED=true omarchy-default-agent muse
[[ $(omarchy-default-agent) == "muse" ]] || fail "a user-installed Muse can be selected"
[[ ! -s $stub_log && ! -s $terminal_log ]] || fail "an unmanaged Muse skips installation and wrapper creation"
if grep -qE "^(install|use) " "$mise_history"; then
  fail "an unmanaged Muse is left to its existing installation"
fi
[[ $("$test_home/.local/bin/muse") == "user-muse" ]] || fail "a user-installed Muse is preserved"
rm "$test_home/.local/bin/muse"
pass "selecting a user-installed Muse preserves its launcher"

rm "$mock_bin/omarchy-agent"
hash -r

assert_launched() {
  local agent=$1
  local description=$2
  shift 2
  # Every agent window launches under the same app-id, whichever agent is
  # default, so window rules and themes see one class for all of them.
  local expected=(--app-id=org.omarchy.agent "$@")

  mapfile -d '' -t actual <"$launch_log"

  (( ${#actual[@]} == ${#expected[@]} )) ||
    fail "$agent launch $description" "expected: ${expected[*]}\nactual: ${actual[*]}"

  for ((index = 0; index < ${#expected[@]}; index++)); do
    case ${actual[$index]} in
    "${expected[$index]}") ;;
    *) fail "$agent launch $description" "expected: ${expected[*]}\nactual: ${actual[*]}" ;;
    esac
  done
}

assert_launch() {
  local agent=$1
  shift

  printf '%s\n' "$agent" >"$agent_file"
  omarchy-agent-prompt "Review this" project
  assert_launched "$agent" "forwards the interactive prompt" "$@"
}

assert_bypass() {
  local agent=$1
  shift

  printf '%s\n' "$agent" >"$agent_file"
  omarchy-agent
  assert_launched "$agent" "skips permission prompts" "$@"
}

assert_launch pi pi "Review this project"
assert_launch omp omp --auto-approve -- "Review this project"
assert_launch opencode opencode --auto --prompt "Review this project"
assert_launch ori ori code --interactive --prompt "Review this project"
assert_launch claude env -u CLAUDE_CONFIG_DIR OMARCHY_AGENT_CLAUDE_HOME= claude --permission-mode auto -- "Review this project"
assert_launch codex env -u CODEX_HOME OMARCHY_AGENT_CODEX_HOME= codex --approve-for-me -- "Review this project"
assert_launch muse muse --approval-mode never -- "Review this project"
assert_launch crush crush run "Review this project"
assert_launch grok env -u GROK_HOME OMARCHY_AGENT_GROK_HOME= grok --permission-mode bypassPermissions -- "Review this project"
assert_launch cursor-agent cursor-agent --yolo --trust agent -- "Review this project"
assert_launch hermes env -u HERMES_SESSION_SOURCE hermes chat --yolo --tui "--query=Review this project"
assert_launch agy agy --dangerously-skip-permissions --prompt-interactive "Review this project"
assert_launch copilot copilot --allow-all --interactive "Review this project"
assert_launch kimi kimi --prompt "Review this project"
assert_launch qwen qwen --yolo "--prompt-interactive=Review this project"
printf '%s\n' qwen >"$agent_file"
omarchy-agent-prompt '-n --help; echo literal'
assert_launched qwen "keeps an option-like prompt literal" qwen --yolo "--prompt-interactive=-n --help; echo literal"
# DSH's browser UI takes no prompt, and its headless profile would run one with
# full access in a window that closes with the answer.
: >"$notification_history"
printf '%s\n' dsh >"$agent_file"
omarchy-agent-prompt '-n --help; echo literal'
assert_launched dsh "opens its browser UI for a prompt" env DSH_PERMISSION_MODE=danger-full-access dsh web
[[ $(<"$clipboard_log") == '-n --help; echo literal' ]] || fail "DSH launcher puts the prompt on the clipboard"
mapfile -d '' -t notification_args <"$notification_history"
[[ ${notification_args[*]} == *"DeepSeek Harness takes no starting prompt"* ]] || fail "DSH launcher says where the prompt went"
assert_launch mcode mcode -- "Review this project"
assert_launch kiro-cli kiro-cli chat --trust-all-tools -- "Review this project"
: >"$notification_history"
assert_launch freebuff freebuff
assert_launch kilo kilo --auto "--prompt=Review this project"
assert_launch devin devin --permission-mode dangerous --respect-workspace-trust false -- "Review this project"
assert_launch amp bash -c 'printf "%s\n" "$1" | exec "$0" --dangerously-allow-all' amp "Review this project"
assert_launch commandcode commandcode --yolo -- "Review this project"
[[ $(<"$clipboard_log") == "Review this project" ]] || fail "Freebuff launcher puts the prompt on the clipboard"
mapfile -d '' -t notification_args <"$notification_history"
[[ ${notification_args[*]} == *"Freebuff takes no starting prompt"* ]] || fail "Freebuff launcher says where the prompt went"
pass "agent launcher adapts initial prompts for every supported agent"

literal_muse_prompt=$'--disable-sandbox !Crash {$(touch must-not-run)}\ntrailing\\ '
printf '%s\n' "muse" >"$agent_file"
omarchy-agent-prompt "$literal_muse_prompt"
assert_launched muse "separates prompt text from options" muse --approval-mode never -- "$literal_muse_prompt"
pass "Muse receives option-like prompts as one literal argument"

literal_hermes_prompt=$' --help !Crash /quit {$(touch must-not-run)}\ntrailing\\ '
printf '%s\n' "hermes" >"$agent_file"
omarchy-agent-prompt "$literal_hermes_prompt"
assert_launched hermes "binds its literal initial prompt" env -u HERMES_SESSION_SOURCE \
  hermes chat --yolo --tui "--query=$literal_hermes_prompt"
pass "Hermes receives prompted launches as one literal query argument"

assert_bypass pi pi
assert_bypass omp omp --auto-approve
assert_bypass opencode opencode --auto
assert_bypass ori ori code
assert_bypass claude env -u CLAUDE_CONFIG_DIR OMARCHY_AGENT_CLAUDE_HOME= claude --permission-mode auto
assert_bypass codex env -u CODEX_HOME OMARCHY_AGENT_CODEX_HOME= codex --approve-for-me
assert_bypass muse muse --approval-mode never
assert_bypass crush crush --yolo
assert_bypass grok env -u GROK_HOME OMARCHY_AGENT_GROK_HOME= grok --permission-mode bypassPermissions
assert_bypass cursor-agent cursor-agent --yolo --trust
assert_bypass hermes hermes --yolo
assert_bypass agy agy --dangerously-skip-permissions
assert_bypass copilot copilot --allow-all
assert_bypass kimi kimi --yolo
assert_bypass qwen qwen --yolo
assert_bypass dsh env DSH_PERMISSION_MODE=danger-full-access dsh web
assert_bypass mcode mcode
assert_bypass kiro-cli kiro-cli chat --trust-all-tools
: >"$clipboard_log"
: >"$notification_history"
assert_bypass freebuff freebuff
assert_bypass kilo kilo --auto
assert_bypass devin devin --permission-mode dangerous --respect-workspace-trust false
assert_bypass amp amp --dangerously-allow-all
assert_bypass commandcode commandcode --yolo
[[ ! -s $clipboard_log && ! -s $notification_history ]] || fail "Freebuff launcher leaves the clipboard alone without a prompt"
pass "agent launcher skips permission prompts for every supported agent"

printf '%s\n' "opencode" >"$agent_file"
omarchy-agent
mapfile -d '' -t launch_args <"$launch_log"
[[ ${launch_args[*]} == "--app-id=org.omarchy.agent opencode --auto" ]] ||
  fail "agent launcher starts the selected agent without an initial prompt"
pass "agent launcher starts the selected agent without an initial prompt"

omarchy-agent-prompt --inline "Review this project"
mapfile -d '' -t inline_args <"$inline_log"
[[ ${inline_args[*]} == "opencode --auto --prompt Review this project" ]] ||
  fail "inline agent launcher runs in the current terminal"
pass "inline agent launcher runs in the current terminal"

# The prompt route exists so the router can tell a prompt from a subcommand, so
# cover the public routes and not only the binaries behind them.
: >"$launch_log"
omarchy agent
mapfile -d '' -t launch_args <"$launch_log"
[[ ${launch_args[*]} == "--app-id=org.omarchy.agent opencode --auto" ]] ||
  fail "omarchy agent routes to the launcher"

# With an agent chosen there is nothing to pick, so the keybinding launches.
: >"$launch_log"
: >"$menu_log"
omarchy-agent --pick
mapfile -d '' -t launch_args <"$launch_log"
[[ ${launch_args[*]} == "--app-id=org.omarchy.agent opencode --auto" ]] ||
  fail "--pick launches once an agent is chosen"
[[ ! -s $menu_log ]] || fail "--pick opens no menu once an agent is chosen"
pass "--pick launches once an agent is chosen"

: >"$launch_log"
omarchy agent prompt "Review this project"
mapfile -d '' -t launch_args <"$launch_log"
[[ ${launch_args[*]} == "--app-id=org.omarchy.agent opencode --auto --prompt Review this project" ]] ||
  fail "omarchy agent prompt routes the prompt to the launcher"

: >"$launch_log"
if omarchy agent Review this project >"$test_tmp/positional-output" 2>&1; then
  fail "omarchy agent rejects a positional prompt"
fi
grep -F "omarchy agent prompt" "$test_tmp/positional-output" >/dev/null ||
  fail "omarchy agent points a positional prompt at the prompt route"
[[ ! -s $launch_log ]] || fail "omarchy agent starts nothing for a positional prompt"
pass "omarchy agent keeps prompts on the prompt route"

printf '%s\n' "missing" >"$agent_file"
if OMARCHY_TEST_MISSING_COMMAND=missing omarchy-agent >"$test_tmp/missing-output" 2>&1; then
  fail "agent launcher rejects a missing default command"
fi
grep -F "missing is not installed" "$test_tmp/missing-output" >/dev/null ||
  fail "agent launcher explains when the default command is missing"
pass "agent launcher reports a missing default command"

# OpenClaw is its own self-updating runtime, not mise's: choosing it must route
# through omarchy-install-openclaw-cli and never touch a mise environment.
# openclaw-cli-test.sh covers the installer itself.
cat >"$mock_bin/omarchy-install-openclaw-cli" <<'SH'
#!/bin/bash
if [[ $1 == "--check" ]]; then
  [[ ${OMARCHY_TEST_OPENCLAW_INSTALLED:-false} == "true" ]]
else
  printf '%s\n' "install-openclaw-cli $*" >>"$OMARCHY_TEST_STUB_LOG"
fi
SH
cat >"$mock_bin/omarchy-launch-openclaw" <<'SH'
#!/bin/bash
printf '%s\0' omarchy-launch-openclaw "$@" >"$OMARCHY_TEST_AGENT_INLINE_LOG"
SH
cat >"$mock_bin/openclaw" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin/omarchy-install-openclaw-cli" \
  "$mock_bin/omarchy-launch-openclaw" "$mock_bin/openclaw"

: >"$launch_log"
: >"$terminal_log"
: >"$mise_history"
OMARCHY_TEST_OPENCLAW_INSTALLED=true omarchy-default-agent openclaw
read -r chosen <"$agent_file"
[[ $chosen == openclaw ]] || fail "choosing OpenClaw records it as the default agent"
mapfile -d '' -t launch_args <"$launch_log"
[[ ${launch_args[*]} == "--app-id=org.omarchy.agent omarchy-launch-openclaw --tui" ]] ||
  fail "choosing OpenClaw launches its terminal UI"
[[ ! -s $terminal_log ]] || fail "an installed OpenClaw needs no install terminal"
! grep -q 'use -g openclaw' "$mise_history" || fail "OpenClaw never installs through mise"
pass "choosing OpenClaw uses its runtime and launches its terminal UI"

: >"$terminal_log"
OMARCHY_TEST_OPENCLAW_INSTALLED=false omarchy-default-agent openclaw
mapfile -d '' -t terminal_args <"$terminal_log"
[[ ${terminal_args[*]} == "omarchy-default-agent --install openclaw" ]] ||
  fail "a missing OpenClaw routes through the install terminal"
pass "a missing OpenClaw routes through the install terminal"

: >"$stub_log"
: >"$inline_log"
OMARCHY_TEST_OPENCLAW_INSTALLED=false omarchy-default-agent --install openclaw >/dev/null
grep -Fx "install-openclaw-cli --now" "$stub_log" >/dev/null ||
  fail "installing OpenClaw as default agent sets up its runtime"
mapfile -d '' -t inline_args <"$inline_log"
[[ ${inline_args[*]} == "omarchy-launch-openclaw --tui" ]] ||
  fail "installing OpenClaw as default agent hands over to its terminal UI"
pass "installing OpenClaw as default agent sets up its runtime"

: >"$launch_log"
omarchy agent prompt "Review this project"
mapfile -d '' -t launch_args <"$launch_log"
# Element-wise: the prompt must travel as one argv entry, which a space-joined
# comparison could not tell apart from a prompt split into words.
[[ ${#launch_args[@]} == 5 &&
  ${launch_args[0]} == "--app-id=org.omarchy.agent" &&
  ${launch_args[1]} == "omarchy-launch-openclaw" &&
  ${launch_args[2]} == "--tui" &&
  ${launch_args[3]} == "--message" &&
  ${launch_args[4]} == "Review this project" ]] ||
  fail "OpenClaw receives prompts through --message" "argv: ${launch_args[*]}"
pass "OpenClaw receives prompts through --message"

# With the package and no openclaw command, the launcher sets OpenClaw up, so
# the agent hands over to it rather than calling OpenClaw missing.
cat >"$mock_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ " ${OMARCHY_TEST_PACKAGES:-} " == *" $1 "* ]]
SH
chmod +x "$mock_bin/omarchy-pkg-present"
: >"$launch_log"
OMARCHY_TEST_MISSING_COMMAND=openclaw OMARCHY_TEST_PACKAGES=openclaw omarchy-agent >/dev/null 2>&1 ||
  fail "OpenClaw's agent launches with the package and no command yet"
mapfile -d '' -t launch_args <"$launch_log"
[[ ${launch_args[*]} == "--app-id=org.omarchy.agent omarchy-launch-openclaw --tui" ]] ||
  fail "OpenClaw's agent hands a missing command to its launcher when the package is there" "argv: ${launch_args[*]}"
: >"$launch_log"
if OMARCHY_TEST_MISSING_COMMAND=openclaw OMARCHY_TEST_PACKAGES= omarchy-agent >/dev/null 2>&1; then
  fail "OpenClaw's agent without the package is still missing"
fi
[[ ! -s $launch_log ]] || fail "OpenClaw's agent without the package starts nothing"
pass "OpenClaw's agent hands a missing command to its launcher only when the package is there"

# Launch through PATH whether mise has downloaded its configured tool or not,
# including agents wrapped in env or bash.
lazy_shims="$test_tmp/lazy-shims"
mkdir -p "$lazy_shims"
for agent in cursor-agent muse claude kiro-cli devin amp dsh hermes; do
  printf '#!/bin/bash\nprintf "official %s\\n"\n' "$agent" >"$test_home/.local/bin/$agent"
  printf '#!/bin/bash\nprintf "lazy shim %s\\n"\n' "$agent" >"$lazy_shims/$agent"
  chmod +x "$test_home/.local/bin/$agent" "$lazy_shims/$agent"
  printf '%s\n' "$agent" >"$agent_file"
  output=$(PATH="$lazy_shims:$PATH" "$ROOT/bin/omarchy-agent" --inline)
  [[ $output == "lazy shim $agent" ]] || fail "agent launcher honors the selected shim before an uninstalled local $agent"
  output=$(PATH="$lazy_shims:$PATH" omarchy-agent-prompt --inline "Review this project")
  [[ $output == "lazy shim $agent" ]] || fail "prompted agent launcher honors the selected shim for $agent"
  # Once mise has its own copy installed, a terminal runs that one, so the
  # launcher does too rather than a leftover install in ~/.local/bin.
  output=$(OMARCHY_TEST_AGENT_INSTALLED=true PATH="$lazy_shims:$PATH" "$ROOT/bin/omarchy-agent" --inline)
  [[ $output == "lazy shim $agent" ]] || fail "agent launcher runs mise's installed $agent over a leftover ~/.local/bin copy"
  # An older wrapper set its variable on the install line; it is still a
  # wrapper, not the user's own install.
  printf '#!/bin/bash\nMISE_MINIMUM_RELEASE_AGE=0 mise use -g --quiet "%s" || exit 1\nprintf "old wrapper %s\\n"\n' "$agent" "$agent" >"$test_home/.local/bin/$agent"
  output=$(PATH="$lazy_shims:$PATH" "$ROOT/bin/omarchy-agent" --inline)
  [[ $output == "lazy shim $agent" ]] || fail "agent launcher treats an older one-line mise wrapper for $agent as a wrapper"
  rm "$test_home/.local/bin/$agent" "$lazy_shims/$agent"
done
pass "agent launcher preserves PATH precedence before and after mise installation"

# This regression also runs without real mise. A valid external command later
# on PATH cannot make an earlier legacy wrapper or native shim usable. Both
# kinds of opt-out must keep the previous default, without invoking mise.
external_bin="$test_tmp/external-agent-bin"
shadow_shims="$test_tmp/shadow-shims"
mkdir -p "$external_bin" "$shadow_shims"
printf '#!/bin/bash\necho EXTERNAL_PI\n' >"$external_bin/pi"
chmod +x "$external_bin/pi"
for shadow in wrapper modern-wrapper cooldown-wrapper mise-exec-wrapper bare-exec-wrapper inline-wrapper single-command-wrapper symlink-single-command symlink-wrapper shim; do
  if [[ $shadow != shim ]]; then
    wrapper_path="$test_home/.local/bin/pi"
    if [[ $shadow == symlink-wrapper || $shadow == symlink-single-command ]]; then
      wrapper_path="$test_tmp/legacy-pi-wrapper"
      ln -s "$wrapper_path" "$test_home/.local/bin/pi"
    fi
    case "$shadow" in
      modern-wrapper)
        printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet "pi" || exit 25\nexec mise x "pi" -- "pi" "$@"\n' >"$wrapper_path"
        ;;
      cooldown-wrapper)
        printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g "pi" || exit 1\nexec mise x "pi" -- "pi" "$@"\n' >"$wrapper_path"
        ;;
      mise-exec-wrapper)
        printf '#!/bin/bash\nmise use -g "pi"\nexec mise exec "pi" -- "pi" "$@"\n' >"$wrapper_path"
        ;;
      bare-exec-wrapper)
        printf '#!/bin/bash\nmise use -g "pi"\nexec "pi" "$@"\n' >"$wrapper_path"
        ;;
      inline-wrapper)
        printf '#!/bin/bash\nMISE_MINIMUM_RELEASE_AGE=0 mise use -g --quiet "pi" || exit 25\nexec mise x "pi" -- "pi" "$@"\n' >"$wrapper_path"
        ;;
      single-command-wrapper | symlink-single-command)
        printf '#!/bin/bash\nMISE_MINIMUM_RELEASE_AGE=0 mise use -g --quiet "pi" || exit 25\nprintf "old wrapper\\n"\n' >"$wrapper_path"
        ;;
      *) printf '#!/bin/bash\nmise use -g pi || exit 25\nexec mise x pi -- pi "$@"\n' >"$wrapper_path" ;;
    esac
    chmod +x "$wrapper_path"
    shadow_path="$PATH:$external_bin"
  else
    ln -s "$mock_bin/mise" "$shadow_shims/pi"
    shadow_path="$shadow_shims:$PATH:$external_bin"
  fi
  for optout in disabled removed-preinstalls; do
    : >"$mise_history"
    : >"$terminal_log"
    : >"$agent_open_log"
    printf '%s\n' muse >"$agent_file"
    disabled=false
    [[ $optout == disabled ]] && disabled=true
    for args in pi '--install pi'; do
      read -r -a selection_args <<<"$args"
      if OMARCHY_TEST_AGENT_UNMANAGED=true OMARCHY_TEST_AGENT_DISABLED="$disabled" \
        OMARCHY_TEST_MISE_FAIL=true PATH="$shadow_path" omarchy-default-agent "${selection_args[@]}" \
        >"$test_tmp/shadow-failure" 2>&1; then
        fail "$optout rejects a $shadow shadowing the external agent ($args)"
      fi
      [[ $(<"$agent_file") == muse ]] || fail "$optout preserves Muse after a shadowing $shadow ($args)"
      [[ ! -s $terminal_log && ! -s $agent_open_log ]] || fail "$optout avoids launching a shadowed $shadow ($args)"
    done
    if grep -Eq '^(use|install|x) ' "$mise_history"; then
      fail "$optout must not invoke mise through a shadowed $shadow"
    fi
  done
  if [[ $shadow == shim ]]; then
    rm "$shadow_shims/pi"
  else
    rm "$test_home/.local/bin/pi"
    [[ $shadow == symlink-wrapper || $shadow == symlink-single-command ]] && rm "$test_tmp/legacy-pi-wrapper"
  fi
done
# When the real executable is first on PATH, the same disabled configuration
# must still permit selection and launch without ever invoking mise.
: >"$mise_history"
printf '%s\n' muse >"$agent_file"
OMARCHY_TEST_AGENT_UNMANAGED=true OMARCHY_TEST_AGENT_DISABLED=true \
  OMARCHY_TEST_MISE_FAIL=true PATH="$external_bin:$PATH" omarchy-default-agent pi
[[ $(<"$agent_file") == pi ]] || fail "an external PATH winner remains selectable"
output=$(OMARCHY_TEST_AGENT_UNMANAGED=true OMARCHY_TEST_AGENT_DISABLED=true \
  OMARCHY_TEST_MISE_FAIL=true PATH="$external_bin:$PATH" omarchy-agent --inline)
[[ $output == EXTERNAL_PI ]] || fail "the external PATH winner is launched"
# An official installer may itself create a symlink to an external binary.
# Comments mentioning mise operations must not make it look like a wrapper.
mv "$external_bin/pi" "$external_bin/pi.real"
printf '#!/bin/bash\n# mise use -g node installs an unrelated dependency\n# exec mise x node -- node is an example, not a wrapper\necho EXTERNAL_PI\n' >"$external_bin/pi.real"
chmod +x "$external_bin/pi.real"
ln -s pi.real "$external_bin/pi"
printf '%s\n' muse >"$agent_file"
OMARCHY_TEST_AGENT_UNMANAGED=true OMARCHY_TEST_AGENT_DISABLED=true \
  OMARCHY_TEST_MISE_FAIL=true PATH="$external_bin:$PATH" omarchy-default-agent pi
[[ $(<"$agent_file") == pi ]] || fail "a symlink to a real external agent remains selectable"
output=$(OMARCHY_TEST_AGENT_UNMANAGED=true OMARCHY_TEST_AGENT_DISABLED=true \
  OMARCHY_TEST_MISE_FAIL=true PATH="$external_bin:$PATH" omarchy-agent --inline)
[[ $output == EXTERNAL_PI ]] || fail "a symlink to a real external agent launches"
if grep -Eq '^(use|install|x) ' "$mise_history"; then
  fail "launching the external PATH winner does not activate mise"
fi
pass "shadowed wrappers and native shims cannot replace a working default after opting out"

# A user's own launcher may activate Node through mise without being an
# Omarchy wrapper for Pi. The mise tool named on the line matters, even when
# it has the historical inline environment-variable prefix.
for body in \
  'MISE_MINIMUM_RELEASE_AGE=0 mise use -g --quiet node >/dev/null 2>&1 || true' \
  'mise use -g --quiet node >/dev/null 2>&1 || true'; do
  printf '#!/bin/bash\n%s\necho EXTERNAL_PI\n' "$body" >"$external_bin/pi.real"
  chmod +x "$external_bin/pi.real"
  printf '%s\n' muse >"$agent_file"
  : >"$terminal_log"
  OMARCHY_TEST_AGENT_UNMANAGED=true OMARCHY_TEST_AGENT_DISABLED=true \
    OMARCHY_TEST_MISE_FAIL=true PATH="$external_bin:$PATH" omarchy-default-agent pi \
    >"$test_tmp/unrelated-mise" 2>&1 ||
    fail "Pi accepts an external launcher that activates only Node"
  [[ $(<"$agent_file") == pi && ! -s $terminal_log ]] ||
    fail "Pi selects the external launcher rather than reinstalling mise's Pi"
  output=$(OMARCHY_TEST_AGENT_UNMANAGED=true OMARCHY_TEST_AGENT_DISABLED=true \
    OMARCHY_TEST_MISE_FAIL=true PATH="$external_bin:$PATH" omarchy-agent --inline)
  [[ $output == EXTERNAL_PI ]] || fail "external Pi launcher using Node actually runs"
done

# An agent name and its mise package need not match: omp uses oh-my-pi.
# Recognize its own legacy wrapper but not another tool's use of mise.
printf '#!/bin/bash\necho EXTERNAL_OMP\n' >"$external_bin/omp"
chmod +x "$external_bin/omp"
printf '#!/bin/bash\nMISE_MINIMUM_RELEASE_AGE=0 mise use -g --quiet node >/dev/null 2>&1 || true\necho USER_OMP\n' >"$test_home/.local/bin/omp"
chmod +x "$test_home/.local/bin/omp"
printf '%s\n' muse >"$agent_file"
OMARCHY_TEST_AGENT_UNMANAGED=true PATH="$PATH:$external_bin" omarchy-default-agent omp \
  >"$test_tmp/unrelated-omp" 2>&1 || fail "unmanaged OMP can activate Node without being an Omarchy wrapper"
[[ $(<"$agent_file") == omp ]] || fail "unmanaged OMP is selected despite its Node dependency"
printf '#!/bin/bash\nMISE_MINIMUM_RELEASE_AGE=0 mise use -g --quiet "oh-my-pi" || exit 25\nprintf "legacy omp\\n"\n' >"$test_home/.local/bin/omp"
for args in omp '--install omp'; do
  read -r -a selection_args <<<"$args"
  printf '%s\n' muse >"$agent_file"
  : >"$terminal_log"
  if OMARCHY_TEST_AGENT_UNMANAGED=true PATH="$PATH:$external_bin" \
    omarchy-default-agent "${selection_args[@]}" >"$test_tmp/legacy-omp" 2>&1; then
    fail "the oh-my-pi package's legacy OMP wrapper is not an external agent ($args)"
  fi
  [[ $(<"$agent_file") == muse && ! -s $terminal_log ]] ||
    fail "the legacy OMP wrapper preserves Muse ($args)"
done
rm "$test_home/.local/bin/omp"

# Include backend names shipped before registry shorthands, as recorded in
# migration 1791382872.sh, as well as current packages with backend options.
for entry in \
  "omp|$omp_package" "mcode|$mcode_package" \
  'codex|aqua:openai/codex' 'codex|npm:@openai/codex' \
  'claude|aqua:anthropics/claude-code' 'crush|aqua:charmbracelet/crush' \
  'agy|aqua:google-antigravity/antigravity-cli' 'agy|gemini' 'agy|npm:@google/gemini-cli' \
  'copilot|aqua:github/copilot-cli' 'copilot|github:github/copilot-cli' 'copilot|npm:@github/copilot' \
  'opencode|aqua:anomalyco/opencode' \
  'pi|aqua:earendil-works/pi' 'pi|github:earendil-works/pi' 'pi|npm:@earendil-works/pi-coding-agent' \
  'omp|github:can1357/oh-my-pi' 'grok|npm:@xai-official/grok' 'ori|github:OpenRouterLabs/ori-releases' \
  'muse|http:muse[url=https://api.meta.ai/muse-launcher.sh,bin=muse,version_list_url=https://api.meta.ai/muse-code/channels/muse-stable,version_json_path=.version]'; do
  IFS='|' read -r selection package <<<"$entry"
  "$ROOT/bin/omarchy-mise-install" "$package" "$selection"
  printf '#!/bin/bash\necho EXTERNAL_AGENT\n' >"$external_bin/$selection"
  chmod +x "$external_bin/$selection"
  for args in "$selection" "--install $selection"; do
    read -r -a selection_args <<<"$args"
    printf '%s\n' muse >"$agent_file"
    : >"$terminal_log"
    if OMARCHY_TEST_AGENT_UNMANAGED=true PATH="$test_home/.local/bin:$PATH:$external_bin" \
      omarchy-default-agent "${selection_args[@]}" >"$test_tmp/generated-wrapper" 2>&1; then
      fail "the $selection generated wrapper cannot shadow the external agent ($args)"
    fi
    [[ $(<"$agent_file") == muse && ! -s $terminal_log ]] ||
      fail "the $selection generated wrapper leaves Muse selected ($args)"
  done
  rm "$test_home/.local/bin/$selection"
done
pass "agent detection distinguishes mise dependencies from the selected tool"

# Keep the dispatch check grounded in real mise selection rather than the stub's
# answer about whether a tool has been downloaded.
if [[ -z $real_mise ]]; then
  skip "native agent selection (mise is not installed)"
else
  python3 - "$ROOT" "$real_mise" "$test_tmp" <<'PY'
from pathlib import Path
import subprocess, sys

repo, mise, scratch = map(Path, sys.argv[1:])
root = scratch / "native-selection"
home, system, commands = root / "home", root / "system", root / "bin"
project, external = home / "project", home / ".local/bin"
for path in (project, external, commands, system, home / ".config/omarchy/defaults"):
    path.mkdir(parents=True, exist_ok=True)
(commands / "mise").symlink_to(mise)
terminal = root / "terminal"
def script(path, text):
    path.write_text("#!/bin/bash\n" + text + "\n")
    path.chmod(0o755)
script(commands / "omarchy-launch-floating-terminal-with-presentation",
       'printf "%s\\n" "$*" >>"$TEST_TERMINAL"')
script(commands / "omarchy-launch-tui", 'shift; exec "$@"')
script(external / "pi", 'echo EXTERNAL_PI; exit 42')
system_config = system / "config.toml"
system_config.write_text(
    '[settings]\nsystem_installs_dir="~/.local/share/mise/installs"\n'
    'system_shims_dir="~/.local/share/mise/shims"\n'
    '[tools]\npi = {version="0.1.0",lazy=true,minimum_release_age="0s"}\n')
project.joinpath("mise.toml").write_text('[tools]\npi="0.2.0"\n')
config = home / ".config/mise/config.toml"
config.parent.mkdir(parents=True, exist_ok=True)
agent_file = home / ".config/omarchy/defaults/agent"
env = {
    "HOME": str(home), "PATH": f"{commands}:{repo / 'bin'}:/usr/bin:{external}",
    "OMARCHY_PATH": str(repo), "OMARCHY_MISE_CONFIG_PATH": str(system_config),
    "MISE_SYSTEM_DIR": str(system), "MISE_OFFLINE": "1", "MISE_YES": "1",
    "MISE_COLOR": "0", "TERM": "dumb", "MISE_TRUSTED_CONFIG_PATHS": str(home),
    "TEST_TERMINAL": str(terminal),
    **{f"XDG_{kind}_HOME": str(home / suffix) for kind, suffix in (
        ("CONFIG", ".config"), ("DATA", ".local/share"),
        ("CACHE", ".cache"), ("STATE", ".local/state"))},
}
def run(args, cwd=project):
    return subprocess.run(list(map(str, args)), env=env, cwd=cwd,
                          text=True, capture_output=True, timeout=30)
def check(ok, message, result=None):
    if not ok:
        raise AssertionError(f"{message}\n{result}")
    print(f"ok - {message}", flush=True)
r = run(["mise", "reshim", "--system"], home)
check(r.returncode == 0, "native system lazy shims are generated", r)
env["PATH"] = f"{home / '.local/share/mise/shims'}:{env['PATH']}"

# Deliberately unavailable versions must fail rather than silently run an
# unrelated executable. The exact release's existence is not under test.
for label, cwd, version in (("system lazy", home, "0.1.0"),
                            ("project pin", project, "0.2.0"),
                            ("user pin", home, "0.3.0")):
    if label == "user pin":
        config.write_text('[tools]\npi="0.3.0"\n')
    agent_file.write_text("pi\n")
    r = run([repo / "bin/omarchy-agent", "--inline"], cwd)
    check(r.returncode != 42 and f"pi@{version}" in r.stderr,
          f"agent launcher preserves missing {label} selection", r)
    agent_file.write_text("muse\n")
    terminal.unlink(missing_ok=True)
    r = run([repo / "bin/omarchy-default-agent", "pi"], cwd)
    check(r.returncode == 0 and terminal.exists() and
          agent_file.read_text() == "muse\n",
          f"agent selector requires installation for {label}", r)

config.unlink()

# A cold cache can leave `latest` unresolved, but the raw request still owns
# selection. Cover every config scope with an external command or old wrapper.
system_defaults = system_config.read_text()
project_pin = (project / "mise.toml").read_text()
external_pi = (external / "pi").read_text()
for label, cwd in (("system lazy", home), ("project pin", project), ("user pin", home)):
    system_config.write_text(system_defaults.replace('version="0.1.0"', 'version="latest"')
                             if label == "system lazy" else system_defaults)
    (project / "mise.toml").write_text('[tools]\npi="latest"\n'
                                     if label == "project pin" else project_pin)
    config.unlink(missing_ok=True)
    if label == "user pin":
        config.write_text('[tools]\npi="latest"\n')
    paths = (system_config, project / "mise.toml", config)
    before = {p: p.read_bytes() if p.exists() else None for p in paths}
    for command in ("external command", "old wrapper"):
        if command == "external command":
            (external / "pi").write_text(external_pi)
        else:
            script(external / "pi", 'mise use -g --quiet pi || exit 1\nexec mise x pi -- pi "$@"')
        for args in (("pi",), ("--install", "pi")):
            agent_file.write_text("muse\n")
            terminal.unlink(missing_ok=True)
            r = run([repo / "bin/omarchy-default-agent", *args], cwd)
            if args == ("pi",):
                expected = r.returncode == 0 and terminal.exists()
            else:
                expected = r.returncode != 0 and not terminal.exists()
            check(expected and agent_file.read_text() == "muse\n" and
                  {p: p.read_bytes() if p.exists() else None for p in paths} == before,
                  f"unresolved {label} latest preserves Muse with {command} for {args}", r)
system_config.write_text(system_defaults)
(project / "mise.toml").write_text(project_pin)
config.unlink(missing_ok=True)
(external / "pi").write_text(external_pi)

# A locally linked version exercises installed selection without a download.
installed = root / "installed"
(installed / "bin").mkdir(parents=True)
script(installed / "bin/pi", 'echo SELECTED_PI; exit 43')
r = run(["mise", "link", "pi@0.2.0", installed])
check(r.returncode == 0, "native selected version can be linked offline", r)
agent_file.write_text("pi\n")
r = run([repo / "bin/omarchy-agent", "--inline"])
check(r.returncode == 43 and "SELECTED_PI" in r.stdout,
      "installed project version retains precedence", r)

# Explicit opt-out applies even to an installed project selection. Both launch
# and selection must leave user configuration intact and avoid an install.
disabled = '[settings]\ndisable_tools=["pi"]\n'
config.write_text(disabled)
for location in ("home", "other PATH directory"):
    if location != "home":
        elsewhere = root / "external/bin"
        elsewhere.mkdir(parents=True)
        (external / "pi").rename(elsewhere / "pi")
        env["PATH"] += f":{elsewhere}"
    terminal.unlink(missing_ok=True)
    r = run([repo / "bin/omarchy-agent", "--inline"])
    check(r.returncode == 42, f"disabled agent uses {location}", r)
    agent_file.write_text("muse\n")
    r = run([repo / "bin/omarchy-default-agent", "pi"])
    check(r.returncode == 42 and not terminal.exists() and
          agent_file.read_text() == "pi\n" and
          config.read_text() == disabled,
          f"selecting disabled agent changes Muse to external Pi at {location}", r)

(elsewhere / "pi").unlink()
agent_file.write_text("muse\n")
for args in (("pi",), ("--install", "pi")):
    terminal.unlink(missing_ok=True)
    r = run([repo / "bin/omarchy-default-agent", *args])
    check(r.returncode != 0 and not terminal.exists() and
          agent_file.read_text() == "muse\n" and
          config.read_text() == disabled,
          f"disabled missing agent rejects {args} and preserves Muse", r)
script(elsewhere / "pi", 'echo EXTERNAL_PI; exit 42')

config.unlink()
(home / ".config/mise/miserc.toml").write_text(
    f'ignored_config_paths=["{system_config}"]\n')
terminal.unlink(missing_ok=True)
r = run([repo / "bin/omarchy-default-agent", "pi"], home)
check(r.returncode == 42 and not terminal.exists() and not config.exists(),
      "removed preinstalls keep an existing agent unmanaged", r)

# The remaining native shim cannot stand in for a real external installation.
(elsewhere / "pi").unlink()
# Remove only the linked install, retaining the shim to exercise stale state.
(home / ".local/share/mise/installs/pi/0.2.0").unlink()
agent_file.write_text("muse\n")
terminal.unlink(missing_ok=True)
r = run([repo / "bin/omarchy-default-agent", "pi"], home)
check(r.returncode == 0 and terminal.exists() and
      agent_file.read_text() == "muse\n" and not config.exists(),
      "removed preinstalls with only a stale shim require installation", r)

# A leftover Omarchy wrapper ahead of a real external Pi still runs mise, even
# with an opt-out. Unlike a native shim, it cannot forward to that executable.
script(external / "pi", 'mise use -g --quiet pi || exit 25\nexec mise x pi -- pi "$@"')
script(elsewhere / "pi", 'echo EXTERNAL_PI; exit 42')
linked = root / "linked-wrapper"
linked.mkdir()
(linked / "pi").symlink_to(external / "pi")
single = root / "single-command-wrapper"
single.mkdir()
script(single / "pi", 'MISE_MINIMUM_RELEASE_AGE=0 mise use -g --quiet pi || exit 25\n'
       'printf "old wrapper\\n"')
single_linked = root / "linked-single-command-wrapper"
single_linked.mkdir()
(single_linked / "pi").symlink_to(single / "pi")
original_path = env["PATH"]
# All five shipped formats from migration 1791382872.sh must be rejected before
# they run, including formats that would recurse through PATH after a failed use.
shipped_paths = []
for form, body in (
        ("quiet", 'export MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet "pi" || exit 1\nexec mise x "pi" -- "pi" "$@"'),
        ("cooldown-export", 'export MISE_MINIMUM_RELEASE_AGE=0\nmise use -g "pi" || exit 1\nexec mise x "pi" -- "pi" "$@"'),
        ("bail-on-failure", 'mise use -g "pi" || exit 1\nexec mise x "pi" -- "pi" "$@"'),
        ("mise-exec", 'mise use -g "pi"\nexec mise exec "pi" -- "pi" "$@"'),
        ("bare-exec", 'mise use -g "pi"\nexec "pi" "$@"')):
    directory = root / form
    directory.mkdir()
    script(directory / "pi", body)
    shipped_paths.append((form, f"{directory}:{original_path}:{elsewhere}"))
for path_kind, path in (("old wrapper", f"{external}:{original_path}:{elsewhere}"),
                        ("symlink to old wrapper", f"{linked}:{original_path}:{elsewhere}"),
                        ("single-command wrapper", f"{single}:{original_path}:{elsewhere}"),
                        ("symlink to single-command wrapper", f"{single_linked}:{original_path}:{elsewhere}"),
                        ("native shim then wrapper", f"{original_path}:{elsewhere}"),
                        *shipped_paths):
    env["PATH"] = path
    for optout in ("removed preinstalls", "disabled tool"):
        if optout == "disabled tool":
            config.write_text(disabled)
        else:
            config.unlink(missing_ok=True)
        for args in (("pi",), ("--install", "pi")):
            agent_file.write_text("muse\n")
            terminal.unlink(missing_ok=True)
            r = run([repo / "bin/omarchy-default-agent", *args], home)
            check(r.returncode != 0 and not terminal.exists() and
                  agent_file.read_text() == "muse\n" and
                  (config.read_text() == disabled if config.exists()
                   else optout == "removed preinstalls"),
                  f"{optout} rejects {path_kind} for {args} without changing Muse", r)

# A real executable before the old wrapper must still launch without touching
# the explicitly disabled mise tool or changing the opt-out setting.
config.write_text(disabled)
env["PATH"] = f"{elsewhere}:{external}:{original_path}"
agent_file.write_text("muse\n")
r = run([repo / "bin/omarchy-default-agent", "pi"], home)
check(r.returncode == 42 and agent_file.read_text() == "pi\n" and
      config.read_text() == disabled, "external command ahead of wrapper can be selected", r)
r = run([repo / "bin/omarchy-agent", "--inline"], home)
check(r.returncode == 42 and "EXTERNAL_PI" in r.stdout,
      "external command ahead of wrapper actually launches", r)
(elsewhere / "pi").rename(elsewhere / "pi.real")
script(elsewhere / "pi.real", '# mise use -g node is an example, not this launcher\n'
       '# exec mise x node -- node is also only documentation\n'
       'echo EXTERNAL_PI; exit 42')
(elsewhere / "pi").symlink_to("pi.real")
agent_file.write_text("muse\n")
r = run([repo / "bin/omarchy-default-agent", "pi"], home)
check(r.returncode == 42 and agent_file.read_text() == "pi\n" and
      config.read_text() == disabled,
      "symlink to genuine external CLI remains selectable with real mise", r)

# Activating a different mise tool is not a legacy wrapper for Pi. Confirm
# both selection entry points with the native CLI and a symlinked launcher.
script(elsewhere / "pi.real", 'MISE_MINIMUM_RELEASE_AGE=0 mise use -g --quiet node >/dev/null 2>&1 || true\n'
       'echo EXTERNAL_PI; exit 42')
for args in (("pi",), ("--install", "pi")):
    agent_file.write_text("muse\n")
    terminal.unlink(missing_ok=True)
    r = run([repo / "bin/omarchy-default-agent", *args], home)
    check(r.returncode == 42 and agent_file.read_text() == "pi\n" and
          config.read_text() == disabled and not terminal.exists() and
          "EXTERNAL_PI" in r.stdout,
          f"native external Pi can activate Node with {args}", r)

# Omarchy shipped OMP under its full GitHub backend before the shorthand.
# That wrapper still installs the same tool and must respect either opt-out.
r = run([repo / "bin/omarchy-mise-install", "github:can1357/oh-my-pi", "omp"], home)
check(r.returncode == 0, "historical OMP wrapper can be generated", r)
script(elsewhere / "omp", 'echo EXTERNAL_OMP; exit 42')
env["PATH"] = f"{external}:{original_path}:{elsewhere}"
system_config.write_text(system_config.read_text() + '\noh-my-pi={version="0.1.0",lazy=true}\n')
miserc = home / ".config/mise/miserc.toml"
for optout in ("removed preinstalls", "disabled tool"):
    if optout == "disabled tool":
        disabled_omp = '[settings]\ndisable_tools=["oh-my-pi"]\n'
        config.write_text(disabled_omp)
        miserc.unlink()
    else:
        config.unlink()
    for args in (("omp",), ("--install", "omp")):
        agent_file.write_text("muse\n")
        terminal.unlink(missing_ok=True)
        r = run([repo / "bin/omarchy-default-agent", *args], home)
        check(r.returncode != 0 and not terminal.exists() and
              agent_file.read_text() == "muse\n" and
              (config.read_text() == disabled_omp if optout == "disabled tool"
               else not config.exists()),
              f"{optout} rejects historical OMP backend with {args}", r)
PY
fi
