#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

cat >"$tmp_dir/setsid" <<'SCRIPT'
#!/bin/bash
printf 'setsid\t%s\n' "$*" >>"$TEST_LOG"
SCRIPT
chmod +x "$tmp_dir/setsid"

export TEST_LOG="$tmp_dir/log"
export PATH="$tmp_dir:$ROOT/bin:$PATH"

OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-launch-floating-terminal-with-presentation" "echo hello"

launch=$(tail -n 1 "$TEST_LOG")
[[ $launch == *"xdg-terminal-exec --app-id=org.omarchy.terminal"* ]] || fail "floating terminal launches Omarchy terminal" "$launch"
pass "floating terminal launches Omarchy terminal"

[[ $launch == *"$ROOT/bin/omarchy-show-logo; echo hello;"* ]] ||
  fail "floating terminal fixes the logo callback to the Omarchy tree" "$launch"
[[ $launch == *"then $ROOT/bin/omarchy-show-done; fi"* ]] ||
  fail "floating terminal fixes the completion callback to the Omarchy tree" "$launch"
pass "floating terminal presentation callbacks bypass the user PATH"

gum_home="$tmp_dir/gum-home"
mkdir -p "$gum_home/.local/state/omarchy/current/theme"
cat >"$gum_home/.local/state/omarchy/current/theme/gum_env.lua" <<'LUA'
hl.env("FOREGROUND", "7")
hl.env("GUM_INPUT_PROMPT_FOREGROUND", "6")
hl.env("PATH", "/theme-controlled")
hl.env("BASH_ENV", "/theme-controlled/bash-env")
LUA

gum_state=$(
  HOME="$gum_home" PATH="/usr/bin:/bin" BASH_ENV="/inherited/bash-env" /usr/bin/bash -p -c '
    source "$1"
    printf "%s\t%s\t%s\t%s\n" "$PATH" "$BASH_ENV" "$FOREGROUND" "$GUM_INPUT_PROMPT_FOREGROUND"
  ' omarchy-gum-test "$ROOT/bin/omarchy-restart-gum"
)
[[ $gum_state == $'/usr/bin:/bin\t/inherited/bash-env\t7\t6' ]] ||
  fail "gum theme loading exports only presentation variables" "$gum_state"
pass "gum theme loading cannot replace execution-control environment variables"

launcher="$ROOT/bin/omarchy-launch-floating-terminal-with-presentation"
grep -Fq 'omarchy_security_sanitize_bash_environment "$security_entrypoint" "$@"' "$launcher" ||
  fail "presentation wrapper re-executes through its canonical entrypoint"
cold_root="$tmp_dir/omarchy root"
launcher_copy="$cold_root/bin/omarchy-launch-floating-terminal-with-presentation"
sudo_invalidated="$tmp_dir/sudo-invalidated"
mkdir -p "$cold_root/bin"

occurrences=$(grep -Foc '/usr/bin/sudo' "$launcher") || occurrences=0
(( occurrences == 1 )) || fail "floating terminal names fixed sudo exactly once" "found $occurrences occurrences"
occurrences=$(grep -Foc '/usr/bin/setsid' "$launcher") || occurrences=0
(( occurrences == 1 )) || fail "cold floating terminal names fixed setsid exactly once" "found $occurrences occurrences"
sed -e "s|/usr/bin/sudo|$tmp_dir/sudo|" \
  -e "s|/usr/bin/setsid|$tmp_dir/setsid|" \
  "$launcher" >"$launcher_copy"
cp "$ROOT/bin/omarchy-security-functions" "$cold_root/bin/omarchy-security-functions"

[[ $(head -n 1 "$launcher") == '#!/bin/bash -p' ]] ||
  fail "presentation wrapper requests privileged Bash at the kernel boundary"
unsafe_startup_status=0
/usr/bin/bash "$launcher_copy" -p >/dev/null 2>&1 || unsafe_startup_status=$?
(( unsafe_startup_status == 126 )) ||
  fail "presentation wrapper rejects an ordinary Bash launch with a decoy -p argument" "got status $unsafe_startup_status"
sourced_startup_status=0
/usr/bin/bash -p -c 'source "$1"' omarchy-source-test "$launcher_copy" >/dev/null 2>&1 || sourced_startup_status=$?
(( sourced_startup_status == 126 )) ||
  fail "presentation wrapper rejects being sourced by a privileged parent shell" "got status $sourced_startup_status"
pass "presentation wrapper requires a verified privileged Bash startup"

mismatched_root_status=0
OMARCHY_PATH="$tmp_dir/mismatched-root" /usr/bin/bash -p "$launcher_copy" >/dev/null 2>&1 || mismatched_root_status=$?
(( mismatched_root_status == 126 )) ||
  fail "presentation wrapper rejects a mismatched Omarchy source root" "got status $mismatched_root_status"
pass "presentation wrapper binds runtime helpers to its own source root"

linked_root="$tmp_dir/linked Omarchy root"
ln -s "$cold_root" "$linked_root"
normalized_root=$(
  OMARCHY_PATH="$linked_root" /usr/bin/bash -p -c '
    source "$1"
    omarchy_security_require_source_root "$2"
    printf "%s\n" "$OMARCHY_PATH"
  ' omarchy-source-root-test "$cold_root/bin/omarchy-security-functions" "$launcher_copy"
)
[[ $normalized_root == "$cold_root" ]] ||
  fail "presentation wrapper accepts a matching symlinked runtime root" "$normalized_root"
pass "presentation wrapper normalizes a matching symlinked runtime root"

cat >"$tmp_dir/sudo" <<'SCRIPT'
#!/bin/bash
printf 'sudo\t%s\n' "$*" >>"$TEST_LOG"
: >"$TEST_SUDO_INVALIDATED"
SCRIPT

cat >"$cold_root/bin/omarchy-restart-gum" <<'SCRIPT'
#!/bin/bash
if [[ ! -e $TEST_SUDO_INVALIDATED ]]; then
  printf 'restart-gum-before-sudo\n' >>"$TEST_LOG"
else
  printf 'restart-gum\n' >>"$TEST_LOG"
fi
SCRIPT

for command in omarchy-show-logo omarchy-show-done; do
  printf '#!/bin/bash\nexit 0\n' >"$cold_root/bin/$command"
done

chmod +x "$launcher_copy" "$tmp_dir/sudo" "$cold_root/bin"/*
: >"$TEST_LOG"
startup_poison="$tmp_dir/cold-bash-env"
poison_calls="$tmp_dir/poison-calls"
cat >"$startup_poison" <<'SCRIPT'
if [[ -e $TEST_SUDO_INVALIDATED ]]; then
  printf '%s\n' bash-env-after-sudo-invalidation >>"$TEST_POISON_CALLS"
fi
SCRIPT

/usr/bin/env TEST_LOG="$TEST_LOG" TEST_POISON_CALLS="$poison_calls" \
  TEST_SUDO_INVALIDATED="$sudo_invalidated" OMARCHY_PATH="$cold_root" \
  BASH_ENV="$startup_poison" ENV="$startup_poison" \
  'BASH_FUNC_printf%%=() { if [[ -e $TEST_SUDO_INVALIDATED ]]; then builtin echo exported-printf-after-sudo-invalidation >>"$TEST_POISON_CALLS"; fi; builtin printf "$@"; }' \
  "$launcher_copy" --cold-sudo "$cold_root/bin/omarchy-setup-security-fido2" "argument with spaces"

mapfile -t calls <"$TEST_LOG"
[[ ${calls[0]:-} == $'sudo\t-k' ]] || fail "cold presentation launch invalidates sudo first" "$(<"$TEST_LOG")"
[[ ${calls[1]:-} == "restart-gum" ]] || fail "cold presentation launch invalidates sudo before theming" "$(<"$TEST_LOG")"
[[ ${calls[2]:-} == $'setsid\t'* ]] || fail "cold presentation launch invalidates sudo before terminal launch" "$(<"$TEST_LOG")"
printf -v escaped_setup '%q' "$cold_root/bin/omarchy-setup-security-fido2"
printf -v escaped_argument '%q' "argument with spaces"
[[ ${calls[2]:-} == *"$escaped_setup $escaped_argument;"* ]] ||
  fail "cold presentation launch preserves command arguments and paths with spaces" "${calls[2]:-}"
[[ ! -s $poison_calls ]] ||
  fail "cold presentation launch preserves inherited Bash callbacks" "$(<"$poison_calls")"
pass "cold presentation launch sanitizes Bash state, preserves argv, and revokes sudo before pre-entry callbacks"
