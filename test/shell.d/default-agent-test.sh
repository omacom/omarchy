#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

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
reachable_log="$test_tmp/agent-reachable"
ssh_kill_log="$test_tmp/ssh-kill"
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

cat >"$mock_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
[[ $1 == ${OMARCHY_TEST_MISSING_COMMAND:-} ]]
SH

cat >"$mock_bin/omarchy-agent-host-reachable" <<'SH'
#!/bin/bash
printf '%s\n' "$1" >>"$OMARCHY_TEST_AGENT_REACHABLE_LOG"
[[ ${OMARCHY_TEST_AGENT_HOST_UNREACHABLE:-false} != "true" ]]
SH

# Answers the two questions omarchy-agent-stop asks a remote machine, and
# records the kills so the test can tell one from several.
cat >"$mock_bin/ssh" <<'SH'
#!/bin/bash
remote=${!#}

case $remote in
*list-sessions*)
  if [[ -n ${OMARCHY_TEST_TMUX_SESSIONS:-} ]]; then
    printf '%s\n' "$OMARCHY_TEST_TMUX_SESSIONS"
  fi
  ;;
*kill-session*)
  # eval because the far side is a shell: the session name arrives quoted and
  # is unquoted by the shell that runs tmux, not handed over with its quotes.
  eval "printf '%s\n' ${remote#tmux kill-session -t }" >>"$OMARCHY_TEST_SSH_KILL_LOG"
  ;;
esac

# A trailing conditional would leave the mock exiting 1 and the caller reading
# a reachable host as unreachable.
exit 0
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

if [[ $1 == "where" ]]; then
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

for command in gum hyprctl omarchy-webapp-remove-all omarchy-tui-remove-all omarchy-pkg-drop; do
  ln -s omarchy-test-noop "$mock_bin/$command"
done

chmod +x "$mock_bin"/*

export HOME="$test_home"
export PATH="$mock_bin:$ROOT/bin:$PATH"
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
export OMARCHY_TEST_AGENT_REACHABLE_LOG="$reachable_log"
export OMARCHY_TEST_SSH_KILL_LOG="$ssh_kill_log"
export OMARCHY_PATH="$ROOT"

grok_package="npm:@xai-official/grok"
omp_package="github:can1357/oh-my-pi"
crush_package="crush"
agy_package="antigravity-cli"
ori_package="github:OpenRouterLabs/ori-releases"
cursor_agent_package="cursor-agent"
muse_package="http:muse[url=https://api.meta.ai/muse-launcher.sh,bin=muse,version_list_url=https://api.meta.ai/muse-code/channels/muse-stable,version_json_path=.version]"

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
assert_lazy_stub "$cursor_agent_package" cursor-agent
assert_lazy_stub "$muse_package" muse
pass "custom agent lazy stubs preserve their mise packages"

OMARCHY_TEST_MISSING_COMMAND=cursor-agent source "$ROOT/install/user/mise.sh"
grep -Fx "$agy_package agy" "$stub_log" >/dev/null || fail "user setup creates the Antigravity lazy stub"
grep -Fx "$grok_package grok" "$stub_log" >/dev/null || fail "user setup creates the Grok lazy stub"
grep -Fx "$cursor_agent_package" "$stub_log" >/dev/null || fail "user setup creates the Cursor CLI lazy stub"
grep -Fx "$omp_package omp" "$stub_log" >/dev/null || fail "user setup creates the Oh My Pi lazy stub"
grep -Fx "$crush_package" "$stub_log" >/dev/null || fail "user setup creates the Crush lazy stub"
grep -Fx "$ori_package ori" "$stub_log" >/dev/null || fail "user setup creates the Ori lazy stub"
OMARCHY_TEST_MISSING_COMMAND=muse source "$ROOT/install/user/mise.sh"
grep -Fx "$muse_package muse" "$stub_log" >/dev/null || fail "user setup creates the Muse lazy stub"
pass "user setup creates the custom agent lazy stubs"

: >"$stub_log"
source "$ROOT/install/user/mise.sh"
grep -Fx "$cursor_agent_package" "$stub_log" >/dev/null && fail "user setup replaces an existing cursor-agent command"
pass "user setup keeps an existing Cursor CLI install"
grep -Fx "$muse_package muse" "$stub_log" >/dev/null && fail "user setup replaces an existing Muse command"

: >"$stub_log"
OMARCHY_TEST_MISSING_COMMAND=muse source "$ROOT/migrations/1788724825.sh" >/dev/null
grep -Fx "$muse_package muse" "$stub_log" >/dev/null || fail "Muse migration creates its lazy stub"
: >"$stub_log"
source "$ROOT/migrations/1788724825.sh" >/dev/null
[[ ! -s $stub_log ]] || fail "Muse migration replaces an existing command"
mkdir -p "$test_home/.local/state/omarchy"
touch "$test_home/.local/state/omarchy/preinstalls-removed"
OMARCHY_TEST_MISSING_COMMAND=muse source "$ROOT/migrations/1788724825.sh" >/dev/null
[[ ! -s $stub_log ]] || fail "Muse migration ignores the preinstall opt-out"
rm "$test_home/.local/state/omarchy/preinstalls-removed"
pass "Muse migration preserves existing installs and the preinstall opt-out"


: >"$stub_log"
source "$ROOT/migrations/1785617047.sh" >/dev/null
grep -Fx "$omp_package omp" "$stub_log" >/dev/null || fail "Oh My Pi migration creates a working lazy stub"

: >"$stub_log"
source "$ROOT/migrations/1787342993.sh" >/dev/null
grep -Fx "$ori_package ori" "$stub_log" >/dev/null || fail "Ori migration creates a working lazy stub"

: >"$stub_log"
export OMARCHY_TEST_MISSING_COMMAND=cursor-agent
source "$ROOT/migrations/1788577553.sh" >/dev/null
unset OMARCHY_TEST_MISSING_COMMAND
grep -Fx "$cursor_agent_package" "$stub_log" >/dev/null || fail "Cursor CLI migration creates a working lazy stub"

: >"$stub_log"
source "$ROOT/migrations/1788577553.sh" >/dev/null
[[ ! -s $stub_log ]] || fail "Cursor CLI migration reinstalls an existing cursor-agent command"
pass "Cursor CLI migration preserves an existing Cursor CLI install"

: >"$stub_log"
source "$ROOT/migrations/1785846769.sh" >/dev/null
grep -Fx "$omp_package omp" "$stub_log" >/dev/null || fail "agent migration repairs the Oh My Pi lazy stub"
grep -Fx "$grok_package grok" "$stub_log" >/dev/null || fail "agent migration creates the Grok lazy stub"
grep -Fx "$crush_package" "$stub_log" >/dev/null || fail "agent migration creates the Crush lazy stub"

: >"$stub_log"
mkdir -p "$(dirname "$agent_file")"
printf '%s\n' gemini >"$agent_file"
"$ROOT/bin/omarchy-mise-install" gemini
export OMARCHY_TEST_MISSING_COMMAND=agy
source "$ROOT/migrations/1786719479.sh" >/dev/null
unset OMARCHY_TEST_MISSING_COMMAND
grep -Fx "$agy_package agy" "$stub_log" >/dev/null || fail "Antigravity migration creates its lazy stub"
[[ $(<"$agent_file") == "agy" ]] || fail "Antigravity migration replaces a Gemini default"

: >"$stub_log"
printf '  %s  \n' gemini >"$agent_file"
export OMARCHY_TEST_MISSING_COMMAND=agy
source "$ROOT/migrations/1786719479.sh" >/dev/null
unset OMARCHY_TEST_MISSING_COMMAND
[[ $(<"$agent_file") == "agy" ]] ||
  fail "Antigravity migration replaces a padded Gemini default the launcher would still read"
pass "Antigravity migration reads the default the way the launcher does"

for obsolete_form in 'mise use -g "gemini"' 'mise use -g --quiet "gemini"'; do
  printf '#!/bin/bash\n%s || exit 1\n' "$obsolete_form" >"$test_home/.local/bin/gemini"
  chmod +x "$test_home/.local/bin/gemini"
  source "$ROOT/migrations/1786719479.sh" >/dev/null
  [[ ! -e $test_home/.local/bin/gemini ]] ||
    fail "Antigravity migration removes a wrapper built on [$obsolete_form]"
done

printf '#!/bin/bash\nexec /opt/gemini "$@"\n' >"$test_home/.local/bin/gemini"
chmod +x "$test_home/.local/bin/gemini"
source "$ROOT/migrations/1786719479.sh" >/dev/null
[[ -e $test_home/.local/bin/gemini ]] || fail "Antigravity migration leaves a hand-written gemini alone"

printf '#!/bin/bash\n# replaced: mise use -g --quiet "gemini"\nexec /opt/gemini "$@"\n' >"$test_home/.local/bin/gemini"
chmod +x "$test_home/.local/bin/gemini"
source "$ROOT/migrations/1786719479.sh" >/dev/null
[[ -e $test_home/.local/bin/gemini ]] ||
  fail "Antigravity migration leaves a wrapper that only mentions the installer line"
rm -f "$test_home/.local/bin/gemini"
pass "Antigravity migration only removes the Gemini wrapper Omarchy wrote"

[[ -L "$test_home/.gemini/config/skills/omarchy" && $(readlink "$test_home/.gemini/config/skills/omarchy") == "$ROOT/default/agents/skills/omarchy" ]] ||
   fail "Antigravity migration provisions the omarchy skill"
[[ -L "$test_home/.gemini/config/skills/diagnose-crash" && $(readlink "$test_home/.gemini/config/skills/diagnose-crash") == "$ROOT/default/agents/skills/diagnose-crash" ]] ||
   fail "Antigravity migration provisions the diagnose-crash skill"
pass "Antigravity migration provisions Antigravity skills"


: >"$stub_log"
mkdir -p "$test_home/.local/state/omarchy"
touch "$test_home/.local/state/omarchy/preinstalls-removed"
export OMARCHY_TEST_MISSING_COMMAND=agy
source "$ROOT/migrations/1786719479.sh" >/dev/null
[[ ! -s $stub_log ]] || fail "Antigravity migration preserves removed preinstalls"
pass "Antigravity migration respects removed preinstalls"

: >"$stub_log"
printf '%s\n' gemini >"$agent_file"
source "$ROOT/migrations/1786719479.sh" >/dev/null
unset OMARCHY_TEST_MISSING_COMMAND
grep -Fx "$agy_package agy" "$stub_log" >/dev/null || fail "Antigravity migration installs the agent a Gemini default now names"
[[ $(<"$agent_file") == "agy" ]] || fail "Antigravity migration replaces a Gemini default after opt-out"
pass "Antigravity migration never leaves the default naming a missing agent"

: >"$stub_log"
rm "$test_home/.local/state/omarchy/preinstalls-removed"
source "$ROOT/migrations/1786719479.sh" >/dev/null
[[ ! -s $stub_log ]] || fail "Antigravity migration reinstalls an existing Antigravity command"
pass "Antigravity migration preserves an existing Antigravity install"

mkdir -p "$test_home/.local/state/omarchy"
touch "$test_home/.local/state/omarchy/preinstalls-removed"
"$ROOT/bin/omarchy-mise-install" oh-my-pi omp
: >"$stub_log"
source "$ROOT/migrations/1785617047.sh" >/dev/null
source "$ROOT/migrations/1785846769.sh" >/dev/null
source "$ROOT/migrations/1787342993.sh" >/dev/null
OMARCHY_TEST_MISSING_COMMAND=cursor-agent source "$ROOT/migrations/1788577553.sh" >/dev/null
[[ ! -s $stub_log ]] || fail "agent migrations respect the preinstall opt-out"
[[ ! -e $test_home/.local/bin/omp ]] || fail "agent migration removes the obsolete Oh My Pi wrapper after opt-out"

# The matcher has to catch a bare oh-my-pi wrapper from either generation of the
# installer, and leave a wrapper built on the fully qualified package alone.
for obsolete_form in 'mise use -g "oh-my-pi"' 'mise use -g --quiet "oh-my-pi"'; do
  printf '#!/bin/bash\n%s || exit 1\n' "$obsolete_form" >"$test_home/.local/bin/omp"
  chmod +x "$test_home/.local/bin/omp"
  source "$ROOT/migrations/1785846769.sh" >/dev/null
  [[ ! -e $test_home/.local/bin/omp ]] ||
    fail "agent migration removes a wrapper built on [$obsolete_form]"
done

printf '#!/bin/bash\nmise use -g --quiet "%s" || exit 1\n' "$omp_package" >"$test_home/.local/bin/omp"
chmod +x "$test_home/.local/bin/omp"
source "$ROOT/migrations/1785846769.sh" >/dev/null
[[ -e $test_home/.local/bin/omp ]] ||
  fail "agent migration keeps a wrapper built on $omp_package"
rm -f "$test_home/.local/bin/omp"

rm "$test_home/.local/state/omarchy/preinstalls-removed"
rm -f "$agent_file"
pass "agent migrations install working wrappers without overriding the preinstall opt-out"

"$ROOT/bin/omarchy-mise-install" "$muse_package" muse
touch "$test_home/.local/bin/agy" "$test_home/.local/bin/ori"
omarchy-remove-preinstalls >/dev/null
for command in agy omp ori grok crush cursor-agent muse; do
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

# Cursor's installer links the wrapper's path, and the mise shims precede
# ~/.local/bin, so a mise copy would shadow the user's own install.
touch "$test_home/.local/bin/cursor-agent.official"
chmod +x "$test_home/.local/bin/cursor-agent.official"
ln -s cursor-agent.official "$test_home/.local/bin/cursor-agent"
: >"$terminal_log"
: >"$mise_log"
: >"$agent_open_log"
omarchy-default-agent cursor-agent
[[ ! -s $terminal_log ]] || fail "an official Cursor CLI install needs no install terminal"
[[ ! -s $mise_log ]] || fail "an official Cursor CLI install is left to itself by mise"
[[ $(<"$agent_file") == "cursor-agent" ]] || fail "an official Cursor CLI install becomes the default"
mapfile -d '' -t agent_open_args <"$agent_open_log"
[[ ${#agent_open_args[@]} == 1 && ${agent_open_args[0]} == "omarchy-agent" ]] ||
  fail "an official Cursor CLI install opens after selection"
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

: >"$mise_history"
: >"$stub_log"
omarchy-default-agent --install muse >"$test_tmp/muse-install-output"
grep -Fx "use -g $muse_package" "$mise_history" >/dev/null || fail "visible Muse installation uses the HTTP backend"
[[ ! -s $stub_log ]] || fail "Muse selection recreates its preinstalled wrapper"
[[ ! -s $muse_login_log ]] || fail "Muse selection runs a separate login flow"
[[ $(omarchy-default-agent) == "muse" ]] || fail "visible Muse installation changes the selection"
mapfile -d '' -t agent_open_args <"$agent_open_log"
[[ ${#agent_open_args[@]} == 2 && ${agent_open_args[0]} == "omarchy-agent" && ${agent_open_args[1]} == "--inline" ]] ||
  fail "newly installed Muse opens in the installation terminal"
pass "Muse installs visibly through mise and opens directly"

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
omarchy-default-agent muse
[[ $(omarchy-default-agent) == "muse" ]] || fail "a user-installed Muse can be selected"
[[ ! -s $mise_history && ! -s $stub_log && ! -s $terminal_log ]] || fail "a user-installed Muse skips installation and wrapper creation"
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
assert_launch claude claude --permission-mode auto -- "Review this project"
assert_launch codex codex --approve-for-me -- "Review this project"
assert_launch muse muse --approval-mode never -- "Review this project"
assert_launch crush crush run "Review this project"
assert_launch grok grok --permission-mode bypassPermissions -- "Review this project"
assert_launch cursor-agent cursor-agent --yolo --trust agent -- "Review this project"
assert_launch hermes env -u HERMES_SESSION_SOURCE hermes chat --yolo --tui "--query=Review this project"
assert_launch agy agy --dangerously-skip-permissions --prompt-interactive "Review this project"
assert_launch copilot copilot --allow-all --interactive "Review this project"
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
assert_bypass claude claude --permission-mode auto
assert_bypass codex codex --approve-for-me
assert_bypass muse muse --approval-mode never
assert_bypass crush crush --yolo
assert_bypass grok grok --permission-mode bypassPermissions
assert_bypass cursor-agent cursor-agent --yolo --trust
assert_bypass hermes hermes --yolo
assert_bypass agy agy --dangerously-skip-permissions
assert_bypass copilot copilot --allow-all
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

# OpenClaw comes from its pacman package, not mise: choosing it must route
# through omarchy-install-openclaw-cli and never touch a mise environment.
cat >"$mock_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ $1 == openclaw && ${OMARCHY_TEST_OPENCLAW_INSTALLED:-false} == "true" ]]
SH
cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf '%s\n' "pkg-add $*" >>"$OMARCHY_TEST_STUB_LOG"
SH
cat >"$mock_bin/omarchy-launch-openclaw" <<'SH'
#!/bin/bash
printf '%s\0' omarchy-launch-openclaw "$@" >"$OMARCHY_TEST_AGENT_INLINE_LOG"
SH
cat >"$mock_bin/openclaw" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin/omarchy-pkg-present" "$mock_bin/omarchy-pkg-add" \
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
pass "choosing OpenClaw uses the package and launches its terminal UI"

: >"$terminal_log"
OMARCHY_TEST_OPENCLAW_INSTALLED=false omarchy-default-agent openclaw
mapfile -d '' -t terminal_args <"$terminal_log"
[[ ${terminal_args[*]} == "omarchy-default-agent --install openclaw" ]] ||
  fail "a missing OpenClaw routes through the install terminal"
pass "a missing OpenClaw routes through the install terminal"

: >"$stub_log"
: >"$inline_log"
OMARCHY_TEST_OPENCLAW_INSTALLED=false omarchy-default-agent --install openclaw >/dev/null
grep -Fx "pkg-add openclaw" "$stub_log" >/dev/null ||
  fail "installing OpenClaw as default agent adds its package"
mapfile -d '' -t inline_args <"$inline_log"
[[ ${inline_args[*]} == "omarchy-launch-openclaw --tui" ]] ||
  fail "installing OpenClaw as default agent hands over to its terminal UI"
pass "installing OpenClaw as default agent adds its package"

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

# Remote agents: the machine the agent runs on is the only thing that changes,
# so every per-agent flag above has to survive the trip unaltered.
host_file="$test_home/.config/omarchy/defaults/agent-host"

omarchy-default-agent --host gpu-box
[[ $(omarchy-default-agent --host) == "gpu-box" ]] || fail "the agent host is recorded and read back"
pass "the agent host is recorded and read back"

: >"$launch_log"
remote_prompt=$' --help !Crash /quit {$(touch must-not-run)}\ntrailing\\ '
printf '%s\n' "hermes" >"$agent_file"
omarchy-agent-prompt "$remote_prompt"
mapfile -d '' -t launch_args <"$launch_log"
# Located by the -- separator rather than by index, so adding an ssh option
# does not renumber the assertion.
for ((separator = 0; separator < ${#launch_args[@]}; separator++)); do
  [[ ${launch_args[$separator]} == "--" ]] && break
done
[[ ${launch_args[0]} == "--app-id=org.omarchy.agent" &&
  ${launch_args[1]} == "ssh" &&
  ${launch_args[2]} == "-t" &&
  ${launch_args[separator - 1]} == "gpu-box" &&
  ${launch_args[separator]} == "--" ]] ||
  fail "a remote agent launches over ssh" "argv: ${launch_args[*]}"
[[ ${launch_args[*]} == *"ControlPath="* ]] ||
  fail "a remote agent reuses one connection" "argv: ${launch_args[*]}"
remote_shell_command=${launch_args[separator + 1]}
[[ $remote_shell_command == "bash -lic "* ]] ||
  fail "a remote agent runs through a login+interactive shell" "argv: $remote_shell_command"
pass "a remote agent launches over ssh under the shared app-id"

# Parsed twice, because the far side parses twice: the login shell ssh hands
# the line to resolves one layer and passes bash a single command string, which
# bash then splits into argv. A prompt carrying quotes, newlines and a command
# substitution has to survive both as one literal argument rather than as
# something the far side runs.
remote_command=$(eval "printf '%s' ${remote_shell_command#bash -lic }")
# ssh lands in the remote $HOME, the one directory agents refuse to remember
# trust for, so the far side gets the same redirect a local launch from $HOME
# gets.
[[ $remote_command == '[[ -d ~/Work ]] && cd ~/Work'* ]] ||
  fail "a remote agent starts outside the remote home" "command: $remote_command"

# The session outlives its window, and a second launch joins the one already
# there rather than starting a rival agent over the top of it.
tmux_line=$(grep -F 'exec tmux new-session' <<<"$remote_command") ||
  fail "a remote agent runs inside tmux" "command: $remote_command"
[[ $tmux_line == *"new-session -A -s"* ]] ||
  fail "a second launch attaches instead of starting a rival agent" "line: $tmux_line"

# A machine without tmux still runs the agent, so the command appears twice and
# both copies have to be quoted correctly.
grep -qE '^exec ' <<<"$remote_command" ||
  fail "a remote machine without tmux still runs the agent" "command: $remote_command"

# Two more parses on this path: bash reads the line and hands tmux one
# argument, and tmux hands that to sh, which splits it into the agent's argv.
tmux_argument=${tmux_line#*-s \"\$session\" }
sh_command=$(eval "printf '%s' $tmux_argument")
mapfile -d '' -t remote_argv < <(eval "printf '%s\0' $sh_command")
[[ ${#remote_argv[@]} == 8 &&
  ${remote_argv[0]} == "env" &&
  ${remote_argv[6]} == "--tui" &&
  ${remote_argv[7]} == "--query=$remote_prompt" ]] ||
  fail "the remote command survives quoting intact" "argv: ${remote_argv[*]}"
[[ ! -e must-not-run ]] || fail "a prompt cannot run commands on the remote host"
pass "the remote command and its prompt survive quoting intact"

: >"$launch_log"
: >"$mise_history"
: >"$terminal_log"
OMARCHY_TEST_MISSING_COMMAND=claude omarchy-default-agent claude
read -r chosen <"$agent_file"
[[ $chosen == claude ]] || fail "choosing a remote agent records it"
[[ ! -s $mise_history && ! -s $terminal_log ]] ||
  fail "a remote agent is never installed locally"
mapfile -d '' -t launch_args <"$launch_log"
[[ ${launch_args[1]} == "ssh" ]] ||
  fail "an agent missing locally still launches remotely" "argv: ${launch_args[*]}"
pass "a remote agent is chosen without installing it locally"

: >"$launch_log"
omarchy-default-agent --host ""
[[ ! -f $host_file ]] || fail "clearing the agent host removes the file"
[[ -z $(omarchy-default-agent --host) ]] || fail "a cleared agent host reads back empty"
printf '%s\n' "pi" >"$agent_file"
omarchy-agent
assert_launched pi "runs locally again once the host is cleared" pi
pass "clearing the agent host returns the agent to this machine"

# Work that is about this machine cannot be done from another one, so it stays
# here whatever the default agent's usual home is.
: >"$launch_log"
omarchy-default-agent --host gpu-box
printf '%s\n' "pi" >"$agent_file"
omarchy-agent --local
assert_launched pi "stays on this machine with --local" pi
pass "--local runs the agent here even when it normally runs elsewhere"

: >"$launch_log"
printf '%s\n' "claude" >"$agent_file"
omarchy-agent-crash 1234 hyprland /usr/bin/hyprland SIGSEGV
mapfile -d '' -t launch_args <"$launch_log"
[[ ${launch_args[1]} == "claude" ]] ||
  fail "crash diagnosis runs on the machine that crashed" "argv: ${launch_args[*]}"
[[ ${launch_args[*]} == *"diagnose-crash"* ]] ||
  fail "crash diagnosis still points at the skill" "argv: ${launch_args[*]}"
pass "crash diagnosis runs on the machine that crashed, not the agent's host"

# A remote agent is not installed here, so the local probe must not be the thing
# that decides whether it can run -- but it still guards a local launch.
: >"$launch_log"
if OMARCHY_TEST_MISSING_COMMAND=claude omarchy-agent --local >"$test_tmp/local-missing" 2>&1; then
  fail "--local still reports an agent that is missing here"
fi
grep -q "not installed" "$test_tmp/local-missing" ||
  fail "--local explains that the agent is missing here" "$(cat "$test_tmp/local-missing")"
pass "--local reports an agent that is missing on this machine"

omarchy-default-agent --host ""

# An unreachable machine has to say so: a terminal that opens and closes again
# is the least informative way to report it.
: >"$launch_log"
: >"$notification_history"
omarchy-default-agent --host gpu-box
printf '%s\n' "hermes" >"$agent_file"
if OMARCHY_TEST_AGENT_HOST_UNREACHABLE=true omarchy-agent; then
  fail "an unreachable agent host fails the launch"
fi
[[ ! -s $launch_log ]] || fail "an unreachable agent host opens no window" "argv: $(cat "$launch_log")"
mapfile -d '' -t notification <"$notification_history"
[[ ${notification[*]} == *"gpu-box"* ]] ||
  fail "an unreachable agent host is reported on the desktop" "notification: ${notification[*]}"
pass "an unreachable agent host is reported instead of flashing a window"

: >"$notification_history"
if OMARCHY_TEST_AGENT_HOST_UNREACHABLE=true omarchy-agent --inline >"$test_tmp/unreachable-inline" 2>&1; then
  fail "an unreachable agent host fails an inline launch"
fi
[[ ! -s $notification_history ]] ||
  fail "an inline launch reports in the terminal rather than on the desktop"
grep -q "omarchy agent --local" "$test_tmp/unreachable-inline" ||
  fail "an unreachable agent host points at the local escape hatch" "$(cat "$test_tmp/unreachable-inline")"
pass "an inline launch reports an unreachable host in the terminal it was run from"

: >"$reachable_log"
omarchy-agent
[[ $(cat "$reachable_log") == "gpu-box" ]] ||
  fail "the reachability check is asked about the configured host" "asked: $(cat "$reachable_log")"
pass "the agent host is checked before its window is spawned"

: >"$reachable_log"
omarchy-agent --local
[[ ! -s $reachable_log ]] || fail "--local never probes a remote host"
pass "--local skips the reachability check entirely"

omarchy-default-agent --host ""

# A session that outlives its window needs a way to end it, or the sessions
# pile up on the machine nobody is looking at.
omarchy-default-agent --host ""
if omarchy-agent-stop >"$test_tmp/stop-local" 2>&1; then
  fail "stopping a local agent is refused"
fi
grep -q "runs on this machine" "$test_tmp/stop-local" ||
  fail "stopping a local agent explains why there is nothing to stop" "$(cat "$test_tmp/stop-local")"
pass "there is nothing to stop when the agent runs on this machine"

omarchy-default-agent --host gpu-box
: >"$ssh_kill_log"
OMARCHY_TEST_TMUX_SESSIONS="" omarchy-agent-stop >"$test_tmp/stop-none" 2>&1
grep -q "No agent session" "$test_tmp/stop-none" ||
  fail "an idle host says so" "$(cat "$test_tmp/stop-none")"
[[ ! -s $ssh_kill_log ]] || fail "an idle host has nothing killed on it"
pass "stopping an idle host reports that nothing was running"

# Every session, not just the first: ssh reads stdin, so a loop that feeds it
# the list it is still reading ends one session and silently swallows the rest.
: >"$ssh_kill_log"
OMARCHY_TEST_TMUX_SESSIONS=$'omarchy-agent-work\nomarchy-agent-notes' omarchy-agent-stop >/dev/null 2>&1
[[ $(wc -l <"$ssh_kill_log") == 2 ]] ||
  fail "every remote agent session is ended" "killed: $(cat "$ssh_kill_log")"
pass "stopping a remote agent ends every session it started"

: >"$ssh_kill_log"
OMARCHY_TEST_TMUX_SESSIONS=$'omarchy-agent-work\nomarchy-agent-notes' omarchy-agent-stop notes >/dev/null 2>&1
[[ $(cat "$ssh_kill_log") == "omarchy-agent-notes" ]] ||
  fail "a named session is the only one ended" "killed: $(cat "$ssh_kill_log")"
pass "a named session is the only one ended"

omarchy-default-agent --host ""
